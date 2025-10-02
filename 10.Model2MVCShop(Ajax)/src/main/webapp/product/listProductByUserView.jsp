<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="menuVal" value="${not empty param.menu ? param.menu : menu}" />
<c:set var="isUserList" value="${menuVal eq 'search'}" />

<c:if test="${empty isAdmin}">
  <c:set var="isAdmin" value="${not empty loginUser and loginUser.role eq 'admin'}" />
</c:if>


<c:set var="isAdmin" value="false" /> <%-- 타이틀 문자열 계산 --%>
<c:set var="pageTitle" value="상품 목록조회" />
<c:if test="${menuVal eq 'manage'}">
  <c:set var="pageTitle" value="상품관리" />
</c:if>

<!DOCTYPE html>
<html>
<head>
  <title>${pageTitle}</title>
  <link rel="stylesheet" href="${ctx}/css/admin.css" type="text/css" />
  <%-- <link rel="stylesheet" href="${ctx}/css/rowClick.css" type="text/css" /> --%> <%-- 리스트 뷰 전용이므로 제거 --%>
  <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.3/themes/base/jquery-ui.css">

  <script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
  <script src="https://code.jquery.com/ui/1.13.3/jquery-ui.min.js"></script>

  <style>
    .card-grid{display:block;width:100%;box-sizing:border-box;margin-top:10px;}
    .card-grid-inner{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;}
    .prod-card{border:1px solid #e5e5e5;padding:10px;background:#fff;box-sizing:border-box;cursor:pointer;}
    .prod-thumb{width:100%;aspect-ratio:4/3;object-fit:cover;border:1px solid #f0f0f0;background:#fafafa;margin-bottom:8px;}
    .prod-title{font-weight:bold;margin:4px 0 6px;font-size:14px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
    .badge{display:inline-block;padding:2px 6px;border:1px solid #ddd;font-size:12px;margin-left:6px;border-radius:3px;background:#fafafa;}
    .prod-meta{font-size:13px;line-height:1.5;}
    .loading-row{text-align:center;padding:14px 0;color:#888;font-size:13px;}
    @media (max-width:1200px){.card-grid-inner{grid-template-columns:repeat(2,1fr);}}
    @media (max-width:720px){.card-grid-inner{grid-template-columns:repeat(1,1fr);}}
  </style>

  <script type="text/javascript">
    // ===== 공용 유틸 =====
    function clearDynamicHidden() {
      $("#productListForm").find("input.dynamic-extra").remove();
    }
    function addHidden(name, value) {
      $("<input>", { type:"hidden", name:name, value:value, class:"dynamic-extra" })
        .appendTo("#productListForm");
    }
    function submitWith(actionUrl, method) {
      var $f = $("#productListForm");
      $f.attr("action", actionUrl);
      $f.attr("method", method);
      $f[0].submit();
    }

    // ===== DOMReady =====
    $(function(){
      // 검색 버튼 클릭 시 카드 목록 새로고침
      $(document).on("click", ".btn-search", function(){
        resetCardStateAndLoad();
      });

      // '모두보기' 체크박스 변경 시 카드 목록 새로고침
      $('#seeAllToggle').on('change', function(){
        $('input[name=seeAll]').val(this.checked);
        resetCardStateAndLoad();
      });

      // 페이지 로드 시 바로 카드 목록 로드 시작
      resetCardStateAndLoad();
    });

    // ====== jQuery UI 오토컴플리트 (검색 기능) ======
    $(function () {
      var $sk = $("#sk");
      var $sc = $("#sc");

      if ($sc.val() !== "1") {
        $sc.val("1").trigger("change");
      }

      $sk.attr("autocomplete", "off");
      if (!$("head style#ac-zfix").length) {
        $("<style id='ac-zfix'>.ui-autocomplete{z-index:10000;}</style>").appendTo(document.head);
      }

      $sk.autocomplete({
        minLength: 1,
        delay: 150,
        appendTo: "body",
        source: function (req, resp) {
          if ($sc.val() !== "1") return resp([]);
          $.ajax({
            url: "${ctx}/product/json/suggest",
            method: "GET",
            dataType: "json",
            data: { q: req.term, limit: 10 },
            success: function (data) {
              if (Array.isArray(data)) return resp(data);
              var mapped = $.map(data || [], function (it) {
                if (!it) return null;
                return it.prodName || it.PRODNAME || it.name || it.NAME || null;
              });
              resp(mapped);
            },
            error: function () { resp([]); }
          });
        },
        focus: function (e, ui) {
          $sk.val(typeof ui.item === "string" ? ui.item : (ui.item.value || ui.item.label || ""));
          return false;
        },
        select: function (e, ui) {
          $sk.val(typeof ui.item === "string" ? ui.item : (ui.item.value || ui.item.label || ""));
          $(".btn-search").trigger("click"); // 검색 실행
          return false;
        }
      });

      $sk.on("focus", function () { $(this).autocomplete("search", $(this).val()); });
      $sc.on("change", function () {
        if ($(this).val() === "1") $sk.trigger("focus");
        else if ($sk.data("ui-autocomplete")) $sk.autocomplete("close");
      });
    });

    /* ===========================
       카드형 뷰 + 무한 스크롤
       =========================== */
    var CARD_STATE = {
      currentPage: 1,
      pageSize: 9, // 3열 그리드에 맞춰 3의 배수로 조정 (선택사항)
      totalCount: 0,
      loading: false,
      finished: false
    };

    $(function(){
      // 무한 스크롤 이벤트 바인딩
      var scrollTimer = null;
      $(window).on("scroll", function(){
        if (CARD_STATE.loading || CARD_STATE.finished) return;
        if (scrollTimer) clearTimeout(scrollTimer);
        scrollTimer = setTimeout(function(){
          var nearBottom = ($(window).scrollTop() + $(window).height()) >= ($(document).height() - 200);
          if (nearBottom) loadNextPageForCard();
        }, 150);
      });
    });

    // 검색 또는 페이지 첫 로드 시 카드 상태 초기화 및 1페이지 로드
    function resetCardStateAndLoad(){
      CARD_STATE.currentPage = 1;
      CARD_STATE.loading = false;
      CARD_STATE.finished = false;
      $("#cardGridInner").empty();
      $("#cardLoading").text("로딩 중...");
      loadPageForCard(1, true);
    }

    // 다음 페이지 카드 로드
    function loadNextPageForCard(){
      var next = CARD_STATE.currentPage + 1;
      var maxPage = Math.ceil(CARD_STATE.totalCount / CARD_STATE.pageSize) || 1;
      if (next > maxPage){
        CARD_STATE.finished = true;
        $("#cardLoading").text("더 이상 로드할 데이터가 없습니다.");
        return;
      }
      loadPageForCard(next, false);
    }

    // 특정 페이지 카드 데이터 AJAX 로드
    function loadPageForCard(pageNum, replaceTotal){
      CARD_STATE.loading = true;
      $("#cardLoading").show().text("로딩 중...");

      $.ajax({
        url: "${ctx}/product/json/list",
        method: "GET",
        dataType: "json",
        data: {
          searchCondition: $("#sc").val() || "",
          searchKeyword:   $.trim($("#sk").val() || ""),
          currentPage:     pageNum,
          pageSize:        CARD_STATE.pageSize,
          menu:            $("input[name='menu']").val() || "${menuVal}",
          seeAll:          $('input[name=seeAll]').val() || "false"
        }
      }).done(function(res){
        var list = res && res.list ? res.list : [];
        var total = res && res.totalCount ? res.totalCount : 0;
        if (replaceTotal) {
          CARD_STATE.totalCount = total;
          // 요약 정보 업데이트
          $("#totalCount").text(total.toLocaleString());
        }

        if (pageNum === 1 && list.length === 0){
          $("#cardGridInner").html('<div class="loading-row" style="grid-column: 1 / -1;">조회 결과가 없습니다.</div>');
          CARD_STATE.finished = true;
          $("#cardLoading").hide();
          return;
        }

        var frag = $(document.createDocumentFragment());
        $.each(list, function(_, p){ frag.append(renderCard(p)); });
        $("#cardGridInner").append(frag);

        CARD_STATE.currentPage = pageNum;

        var loadedCount = $("#cardGridInner .prod-card").length;
        if (loadedCount >= CARD_STATE.totalCount){
          CARD_STATE.finished = true;
          $("#cardLoading").text("마지막 페이지입니다.");
        } else {
          $("#cardLoading").hide();
        }
      }).fail(function(){
        $("#cardLoading").text("로딩 중 오류가 발생했습니다.");
      }).always(function(){
        CARD_STATE.loading = false;
      });
    }

    // 카드 1개 렌더링
    function renderCard(p){
      var img = (p.images && p.images.length > 0) ? p.images[0].imagePath : "";
      var isAbs = /^https?:\/\//.test(img) || (img && img.charAt(0) === "/");
      var imgSrc = img ? (isAbs ? img : ("${ctx}/upload/" + img)) : ("${ctx}/images/noimg.png");

      var statusText = (p.isSell === 'Y') ? "판매중" : "판매대기";
      var regDate = p.regDate || "";
      var priceTxt = (typeof p.price === "number") ? p.price.toLocaleString() : (p.price || "");
      var qtyTxt   = (typeof p.quantity === "number") ? p.quantity.toLocaleString() : (p.quantity || "");

      var $card = $('<div class="prod-card"></div>');
      $card.append('<img class="prod-thumb" alt="상품 이미지" src="'+ imgSrc +'">');
      $card.append('<div class="prod-title">'+ escapeHtml(p.prodName || "") +'<span class="badge">#'+ (p.prodNo || "") +'</span></div>');
      $card.append(
        '<div class="prod-meta">등록일 : '+ escapeHtml(regDate) +'</div>'+
        '<div class="prod-meta">가격 : '+ escapeHtml(priceTxt) +' 원</div>'+
        '<div class="prod-meta">수량 : '+ escapeHtml(qtyTxt) +'</div>'+
        '<div class="prod-meta">거래상태 : '+ escapeHtml(statusText) +'</div>'
      );

      // 카드 클릭 시 상세 페이지로 이동
      $card.on("click", function(){
        clearDynamicHidden();
        addHidden("menu", $("input[name='menu']").val() || "${menuVal}");
        addHidden("prodNo", p.prodNo);
        submitWith("./getProduct", "get");
      });

      return $card;
    }

    function escapeHtml(str){
      if (str == null) return "";
      return String(str)
        .replace(/&/g,"&amp;")
        .replace(/</g,"&lt;")
        .replace(/>/g,"&gt;")
        .replace(/"/g,"&quot;")
        .replace(/'/g,"&#039;");
    }
  </script>
</head>

<body bgcolor="#ffffff" text="#000000">

<table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="15" height="37"><img src="${ctx}/images/ct_ttl_img01.gif" width="15" height="37" /></td>
    <td background="${ctx}/images/ct_ttl_img02.gif" width="100%" style="padding-left:10px;">
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr><td width="93%" class="ct_ttl01">${pageTitle}</td></tr>
      </table>
    </td>
    <td width="12" height="37"><img src="${ctx}/images/ct_ttl_img03.gif" width="12" height="37" /></td>
  </tr>
</table>
<div style="width:98%; margin-left:10px;">

  <form id="productListForm" name="detailForm" onsubmit="return false;"> <%-- form 기본 submit 방지 --%>
    <input type="hidden" name="menu" value="${menuVal}" />
    <%-- 페이지 관련 hidden input은 더 이상 필요 없으므로 제거 --%>
    <input type="hidden" name="seeAll" value="${search.seeAll == 'true' || seeAll == true ? 'true' : 'false'}" />

    <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
      <tr>
        <td align="right" class="search-row">
          <select name="searchCondition" id="sc" class="ct_input_g" style="width:80px">
            <option value="0" <c:if test="${search.searchCondition == '0'}">selected</c:if>>상품번호</option>
            <option value="1" <c:if test="${search.searchCondition == '1'}">selected</c:if>>상품명</option>
            <option value="2" <c:if test="${search.searchCondition == '2'}">selected</c:if>>가격</option>
          </select>
          <input type="text" name="searchKeyword" id="sk" class="ct_input_g" style="width:200px"
                 value="${search.searchKeyword}" placeholder="검색어" autocomplete="off"/>
          <span class="btn-search" style="cursor:pointer; vertical-align:middle;">
            <img src="${ctx}/images/ct_btn_search.gif" width="45" height="23" style="vertical-align:middle;" alt="검색" />
          </span>
        </td>
      </tr>
    </table>
  </form>

	<div style="margin-top: 5px;">
	  <label><input type="checkbox" id="seeAllToggle" name="seeAll" value="true"
	      <c:if test="${search.seeAll == 'true' or seeAll == true}">checked</c:if>/> 모두보기(재고 0 포함)</label>
	</div>
	
  <div style="margin:8px 0;">
    전체 <strong id="totalCount">${resultPage.totalCount}</strong> 건
  </div>
  <div id="cardGrid" class="card-grid">
    <div id="cardGridInner" class="card-grid-inner"></div>
    <div id="cardLoading" class="loading-row"></div>
  </div>
  </div>
</body>
</html>