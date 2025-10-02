<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="menuVal" value="${not empty param.menu ? param.menu : menu}" />
<c:set var="isAdmin" value="true" /> <%-- 타이틀 문자열 계산 --%>
<c:set var="pageTitle" value="상품관리" />

<!DOCTYPE html>
<html>
<head>
  <title>${pageTitle}</title>
  <link rel="stylesheet" href="${ctx}/css/admin.css" type="text/css" />
  <link rel="stylesheet" href="${ctx}/css/rowClick.css" type="text/css" />
  <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.3/themes/base/jquery-ui.css">

  <script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
  <script src="https://code.jquery.com/ui/1.13.3/jquery-ui.min.js"></script>

  <style>
    .view-toggle-bar{display:flex;gap:8px;align-items:center;justify-content:flex-end;margin:8px 0;}
    .btn-view{padding:6px 10px;border:1px solid #ccc;background:#fff;cursor:pointer}
    .btn-view.active{border-color:#333;font-weight:bold}

    .card-grid{display:none;width:100%;box-sizing:border-box;margin-top:10px;}
    .card-grid-inner{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;}
    .prod-card{border:1px solid #e5e5e5;padding:10px;background:#fff;box-sizing:border-box;}
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
      $f.trigger("submit");
    }

    // ===== 검색/페이지 이동 =====
    function fncGetList(page){
      var sc = $("#sc").val();
      var sk = $.trim($("#sk").val());
      if ((sc === '0' || sc === '2') && sk !== '' && !/^[0-9]+$/.test(sk)){
        alert('숫자만 입력하세요.');
        return false;
      }
      $("#currentPage").val(page);
      $("input[name='page']").val(page);

      clearDynamicHidden();
      submitWith("./listProductEntry", "post");
    }
    // fncGetUserList는 관리자 화면에서 사용되지 않지만, pageNavigator.jsp에서 호출할 수 있으므로 유지
    function fncGetUserList(n){ return fncGetList(n); }

    // ===== DOMReady =====
    $(function(){
      // 검색 버튼
      $(document).on("click", ".btn-search", function(){
        fncGetList(1);
      });

      // 행 클릭 → 상세 (수정 모드)
      $(document).on("click", ".click-row", function(){
        if ($(this).data("disabled") === true) return;

        var prodNo = $(this).data("prodno");
        var menu   = $(this).data("mode");

        clearDynamicHidden();
        addHidden("menu", menu);
        addHidden("prodNo", prodNo);
        
        // 관리자 상세는 수정 화면으로 바로 이동
        submitWith("./getProduct", "get");
      });

      // 배송하기 버튼 (리스트/카드 공용)
      $(document).on("click", ".btn-ship", function(e){
        e.stopPropagation(); // 카드 클릭 이벤트 전파 방지
        var prodNo = $(this).data("prodno");

        var form = $('<form></form>');
        form.attr('method', 'get');
        form.attr('action', '${ctx}/purchase/listPurchaseByProd');
        form.append($('<input type="hidden" name="prodNo" value="' + prodNo + '">'));
        $('body').append(form);
        form.submit();
      });
    });

    // ====== jQuery UI 오토컴플리트 ======
	// ====== jQuery UI 오토컴플리트 ======
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
            // [수정] 서버가 문자열 배열을 반환하므로 받은 데이터를 그대로 사용합니다.
            success: function (data) {
              resp(data);
            },
            error: function () { resp([]); }
          });
        },
        focus: function (e, ui) {
          $sk.val(ui.item.value);
          return false;
        },
        select: function (e, ui) {
          $sk.val(ui.item.value);
          $("#currentPage").val("1");
          $(".btn-search").trigger("click");
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
       카드형 토글 + 무한 스크롤
       =========================== */
    var CARD_STATE = {
      currentPage: Number("${search.currentPage != null ? search.currentPage : 1}") || 1,
      pageSize: Number("${search.pageSize != null ? search.pageSize : 10}") || 10,
      totalCount: Number("${resultPage.totalCount != null ? resultPage.totalCount : 0}") || 0,
      loading: false,
      finished: false
    };

    $(function(){
      // 토글 버튼 클릭 바인딩
      $(document).on("click", ".btn-view", function(){
        var mode = $(this).data("mode");
        setViewMode(mode);
      });

      // 기본: 리스트형
      setViewMode("list");

      // 카드형일 때만 스크롤 감지
      var scrollTimer = null;
      $(window).on("scroll", function(){
        if ($("#cardGrid").is(":visible") !== true) return;
        if (CARD_STATE.loading || CARD_STATE.finished) return;
        if (scrollTimer) clearTimeout(scrollTimer);
        scrollTimer = setTimeout(function(){
          var nearBottom = ($(window).scrollTop() + $(window).height()) >= ($(document).height() - 200);
          if (nearBottom) loadNextPageForCard();
        }, 150);
      });
    });

    function setViewMode(mode){
      $(".btn-view").removeClass("active");
      $('.btn-view[data-mode="'+mode+'"]').addClass("active");
      if (mode === "card"){
        $("#listTable, #pageNavWrap").hide();
        $("#cardGrid").show();
        if ($("#cardGridInner").is(":empty")) { // 최초 클릭 시에만 로드
            resetCardStateAndLoad();
        }
      } else {
        $("#cardGrid").hide();
        $("#listTable, #pageNavWrap").show();
      }
    }

    function resetCardStateAndLoad(){
      CARD_STATE.currentPage = 1;
      CARD_STATE.loading = false;
      CARD_STATE.finished = false;
      $("#cardGridInner").empty();
      $("#cardLoading").text("로딩 중...");
      loadPageForCard(1, true);
    }

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

    function loadPageForCard(pageNum, replaceTotal){
      CARD_STATE.loading = true;
      $("#cardLoading").text("로딩 중...");

      $.ajax({
        url: "${ctx}/product/json/list",
        method: "GET",
        dataType: "json",
        data: {
          searchCondition: $("#sc").val() || "",
          searchKeyword:   $.trim($("#sk").val() || ""),
          currentPage:     pageNum,
          pageSize:        CARD_STATE.pageSize,
          menu:            $("input[name='menu']").val() || "${menuVal}"
        }
      }).done(function(res){
        var list = res && res.list ? res.list : [];
        var total = res && res.totalCount ? res.totalCount : 0;
        if (replaceTotal) CARD_STATE.totalCount = total;

        if (pageNum === 1 && list.length === 0){
          $("#cardGridInner").html('<div class="loading-row">조회 결과가 없습니다.</div>');
          CARD_STATE.finished = true;
          $("#cardLoading").text("");
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
          $("#cardLoading").text("");
        }
      }).fail(function(){
        $("#cardLoading").text("로딩 중 오류가 발생했습니다.");
      }).always(function(){
        CARD_STATE.loading = false;
      });
    }

    function renderCard(p){
      // [수정] p.images 배열의 첫 번째 이미지 경로를 사용하도록 변경
      var img = (p.images && p.images.length > 0) ? p.images[0].imagePath : "";
      var isAbs = /^https?:\/\//.test(img) || (img && img.charAt(0) === "/");
      var imgSrc = img ? (isAbs ? img : ("${ctx}" + img)) : ("${ctx}/images/noimg.png");

      var regDate = p.regDate || "";
      var priceTxt = (typeof p.price === "number") ? p.price.toLocaleString() : (p.price || "");
      var qtyTxt   = (typeof p.quantity === "number") ? p.quantity.toLocaleString() : (p.quantity || "");

      var $card = $('<div class="prod-card click-row"></div>');
      $card.data("mode", $("input[name='menu']").val() || "${menuVal}");
      $card.data("prodno", p.prodNo);

      $card.append('<img class="prod-thumb" alt="상품 이미지" src="'+ imgSrc +'">');
      $card.append('<div class="prod-title">'+ escapeHtml(p.prodName || "") +'<span class="badge">#'+ (p.prodNo || "") +'</span></div>');
      $card.append(
        '<div class="prod-meta">등록일 : '+ escapeHtml(regDate) +'</div>'+
        '<div class="prod-meta">가격 : '+ escapeHtml(priceTxt) +' 원</div>'+
        '<div class="prod-meta">수량 : '+ escapeHtml(qtyTxt) +'</div>'
      );

      // [수정] 관리자용 "배송확인" 버튼 추가
      var $statusLine = $('<div class="prod-meta"></div>');
      var $shipLink = $('<span class="btn-ship" style="color:#0066cc; cursor:pointer; text-decoration:underline;">배송확인</span>');
      $shipLink.data("prodno", p.prodNo);
      $statusLine.append($shipLink);
      $card.append($statusLine);

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

  <form id="productListForm" name="detailForm">
    <input type="hidden" name="menu" value="${menuVal}" />
    <input type="hidden" name="page"        value="${search.currentPage}" />
    <input type="hidden" id="currentPage"   name="currentPage" value="${search.currentPage}" />
    <c:if test="${not empty search.pageSize}">
      <input type="hidden" name="pageSize" value="${search.pageSize}" />
    </c:if>
    <c:if test="${not empty search.searchCondition}">
      <input type="hidden" name="searchCondition" value="${search.searchCondition}" />
    </c:if>
    <c:if test="${not empty search.searchKeyword}">
      <input type="hidden" name="searchKeyword" value="${search.searchKeyword}" />
    </c:if>
    <%-- 'seeAll' 관련 hidden input 제거 (관리자 불필요) --%>

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

  <%-- '모두보기' 체크박스 제거 (관리자 불필요) --%>
  <div style="margin:8px 0;">
    전체 <strong>${resultPage.totalCount}</strong> 건수, 현재 <strong>${resultPage.currentPage}</strong> 페이지
  </div>
  <div class="view-toggle-bar">
    <button type="button" class="btn-view active" data-mode="list">리스트형</button>
    <button type="button" class="btn-view" data-mode="card">카드형</button>
  </div>

  <table id="listTable" width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;" class="table-list">
    <tr>
      <th class="ct_list_b" width="80">번호</th>
      <th class="ct_list_b" width="1"></th>
      <th class="ct_list_b">상품명</th>
      <th class="ct_list_b" width="1"></th>
      <th class="ct_list_b" width="120">등록일</th>
      <th class="ct_list_b" width="1"></th>
      <th class="ct_list_b" width="120">가격</th>
      <th class="ct_list_b" width="1"></th>
      <th class="ct_list_b" width="80">수량</th>
      <th class="ct_list_b" width="1"></th>
      <th class="ct_list_b" width="150">거래상태</th>
    </tr>

    <c:forEach var="product" items="${list}">
      <tr class="ct_list_pop click-row"
          data-mode="${menuVal}"
          data-prodno="${product.prodNo}">
        <td align="center">${product.prodNo}</td>
        <td></td>
        <td align="left" class="name-cell">
          <span class="ellipsis">${product.prodName}</span>
        </td>
        <td></td>
        <td align="center"><fmt:formatDate value="${product.regDate}" pattern="yyyy-MM-dd" /></td>
        <td></td>
        <td class="price-cell"><fmt:formatNumber value="${product.price}" /></td>
        <td></td>
        <td align="center">${product.quantity}</td>
        <td></td>
        <td class="status-cell">
          <%-- [수정] 관리자 전용이므로 분기문 제거 --%>
          <span class="btn-ship" data-prodno="${product.prodNo}"
                style="color:#0066cc; cursor:pointer; text-decoration:underline;">
            배송확인
          </span>
        </td>
      </tr>
      <tr><td colspan="11" class="dot"></td></tr>
    </c:forEach>
  </table>
  <div id="cardGrid" class="card-grid">
    <div id="cardGridInner" class="card-grid-inner"></div>
    <div id="cardLoading" class="loading-row"></div>
  </div>

  <table id="pageNavWrap" width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
    <tr>
      <td align="center">
        <input type="hidden" id="currentPage" name="currentPage" value=""/>
        <jsp:include page="../common/pageNavigator.jsp"/>
      </td>
    </tr>
  </table>
  </div>
</body>
</html>