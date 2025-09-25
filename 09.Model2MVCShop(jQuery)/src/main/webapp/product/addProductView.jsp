<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.model2.mvc.service.domain.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- =====================[ 상단 변수 세팅 (EL/JSTL) ]===================== -->
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="mode" value="${requestScope.mode}" />
<c:set var="isUpdate" value="${mode == 'update'}" />
<c:set var="p" value="${requestScope.product}" />
<c:choose>
  <c:when test="${isUpdate}">
    <c:set var="title" value="상품수정" />
    <c:set var="actionPath" value="./updateProduct" />
  </c:when>
  <c:otherwise>
    <c:set var="title" value="상품등록" />
    <c:set var="actionPath" value="./addProduct" />
  </c:otherwise>
</c:choose>
<!-- ===================================================================== -->

<html>
<head>
  <title>${title}</title>
  <link rel="stylesheet" href="${ctx}/css/admin.css" type="text/css" />
  <link rel="stylesheet" href="${ctx}/css/bnt-click.css" type="text/css" />
  
  <script type="text/javascript" src="${ctx}/javascript/calendar.js"></script>
  <script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>

  <script type="text/javascript">
    // 공용: 동적 hidden 정리
    function clearDynamicHidden() {
      $("#productForm").find("input.dynamic-extra").remove();
    }

    // 공용: hidden 추가
    function addHidden(name, value) {
      $("<input>", {
        type: "hidden",
        name: name,
        value: value,
        class: "dynamic-extra"
      }).appendTo("#productForm");
    }

    // 공용: 제출
    function submitWith(actionUrl, method) {
      var $f = $("#productForm");
      $f.attr("action", actionUrl);
      $f.attr("method", method); // GET 또는 POST
      $f.trigger("submit");
    }

    // 이메일/숫자 등 유효성은 여기서 처리
    function validateAndNormalize() {
      var $name = $("input[name='prodName']");
      var $detail = $("input[name='prodDetail']");
      var $manu = $("input[name='manuDate']");
      var $price = $("input[name='price']");

      var name = $.trim($name.val());
      var detail = $.trim($detail.val());
      var manuDate = $.trim($manu.val());
      var price = $.trim($price.val());

      if (!name) { alert("상품명은 반드시 입력하여야 합니다."); $name.focus(); return false; }
      if (!detail) { alert("상품상세정보는 반드시 입력하여야 합니다."); $detail.focus(); return false; }
      if (!manuDate) { alert("제조일자는 반드시 입력하셔야 합니다."); $manu.focus(); return false; }

      // 하이픈 허용 → 제거 후 8자리 체크
      manuDate = manuDate.replace(/-/g, "");
      if (!/^\d{8}$/.test(manuDate)) {
        alert("제조일자는 YYYYMMDD 형식으로 입력하세요.");
        $manu.focus(); return false;
      }
      $manu.val(manuDate);

      if (!price || !/^\d+$/.test(price)) {
        alert("가격은 숫자만 입력하세요.");
        $price.focus(); return false;
      }
      return true;
    }

    $(function() {
      // 달력 아이콘 클릭 (인라인 onclick 제거)
      $(".calendar-trigger").on("click", function() {
        // 기존 calendar.js 인터페이스 유지
        show_calendar('document.detailForm.manuDate', document.detailForm.manuDate.value);
      });

      // 등록/수정 버튼 (a 제거 → span 클릭)
      $(".btn-submit").on("click", function() {
        if (!validateAndNormalize()) return;

        // actionPath(hidden)에 정리된 서버 액션으로 POST (파일 업로드 있으므로 POST 필수)
        var actionUrl = $("#actionPath").val();
        clearDynamicHidden();
        submitWith(actionUrl, "post");
      });

      // 취소 버튼
      $(".btn-cancel").on("click", function() {
        clearDynamicHidden();
        <c:choose>
          <c:when test="${isUpdate}">
            // 수정 모드: 관리 목록으로 이동(GET) + 검색조건/분기 유지
            addHidden("menu", "manage");
            submitWith("./getProduct", "get");
          </c:when>
          <c:otherwise>
            // 등록 모드: 폼 초기화
            document.detailForm.reset();
          </c:otherwise>
        </c:choose>
      });
      
   // === 버튼 전체(좌캡/가운데/우캡) 클릭 확장 ===

   // 1) 가운데 td 클릭 시, 내부 버튼(span: .btn-submit/.btn-cancel/.btn-like) 실행
   $("td.ct_btn01").on("click", function () {
     $(this).find(".btn-submit, .btn-cancel, .btn-like").first().trigger("click");
   });

   // 2) 좌/우 캡을 눌러도 가운데 td 클릭으로 위임
   $("td.ct_btn01").each(function () {
     const $center = $(this);
     const $left  = $center.prev("td").addClass("cap-left");
     const $right = $center.next("td").addClass("cap-right");
     $left.on("click",  function(){ $center.trigger("click"); });
     $right.on("click", function(){ $center.trigger("click"); });
   });

   // 3) 좌/우 캡 hover 시 중앙 td에도 hover 느낌 주기(선택)
   $("td.cap-left, td.cap-right").hover(
     function(){ $(this).siblings("td.ct_btn01").addClass("hover"); },
     function(){ $(this).siblings("td.ct_btn01").removeClass("hover"); }
   );

    });
  </script>
</head>

<body bgcolor="#ffffff" text="#000000">

<form id="productForm" name="detailForm" enctype="multipart/form-data">
  <!-- actionPath 히든: JS에서 사용 -->
  <input type="hidden" id="actionPath" value="${actionPath}" />

  <c:if test="${isUpdate and not empty p}">
    <!-- 수정 시에는 prodNo 필수 -->
    <input type="hidden" name="prodNo" value="${p.prodNo}" />
  </c:if>

  <!-- 업데이트 후 상세/리스트 분기 유지를 위해 POST/GET 모두에 같이 보냄 -->
  <input type="hidden" name="menu" value="${not empty param.menu ? param.menu : menu}" />

  <!-- 검색조건 유지 (존재 시 그대로 전송) -->
  <c:if test="${not empty search}">
    <c:if test="${search.currentPage > 0}">
      <input type="hidden" name="currentPage" value="${search.currentPage}" />
      <input type="hidden" name="page"        value="${search.currentPage}" />
    </c:if>
    <c:if test="${not empty search.pageSize}">
      <input type="hidden" name="pageSize" value="${search.pageSize}" />
    </c:if>
    <c:if test="${not empty search.searchCondition}">
      <input type="hidden" name="searchCondition" value="${search.searchCondition}" />
    </c:if>
    <c:if test="${not empty search.searchKeyword}">
      <input type="hidden" name="searchKeyword" value="${search.searchKeyword}" />
    </c:if>
  </c:if>

  <!-- 상단 타이틀 바 -->
  <table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="15" height="37">
        <img src="${ctx}/images/ct_ttl_img01.gif" width="15" height="37" />
      </td>
      <td background="${ctx}/images/ct_ttl_img02.gif" width="100%" style="padding-left: 10px;">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="93%" class="ct_ttl01">${title}</td>
            <td width="20%" align="right">&nbsp;</td>
          </tr>
        </table>
      </td>
      <td width="12" height="37">
        <img src="${ctx}/images/ct_ttl_img03.gif" width="12" height="37" />
      </td>
    </tr>
  </table>

  <!-- 입력 폼 -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top: 13px;">
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td width="104" class="ct_write">
        상품명 <img src="${ctx}/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" />
      </td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="105">
              <input type="text" name="prodName" class="ct_input_g"
                     style="width: 100px; height: 19px" maxlength="20"
                     value="${p.prodName}" />
            </td>
          </tr>
        </table>
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td width="104" class="ct_write">
        상품상세정보 <img src="${ctx}/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" />
      </td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="prodDetail" class="ct_input_g"
               style="width: 100px; height: 19px" maxlength="200"
               value="${p.prodDetail}" />
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td width="104" class="ct_write">
        제조일자 <img src="${ctx}/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" />
      </td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="manuDate" class="ct_input_g"
               style="width: 100px; height: 19px" maxlength="10"
               placeholder="YYYYMMDD"
               value="${p.manuDate}" />
        &nbsp;
        <!-- 인라인 onclick 제거 → jQuery에서 처리 -->
        <img src="${ctx}/images/ct_icon_date.gif" width="15" height="15" class="calendar-trigger" style="cursor:pointer;" />
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td width="104" class="ct_write">
        가격 <img src="${ctx}/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" />
      </td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="price" class="ct_input_g"
               style="width: 100px; height: 19px" maxlength="10"
               value="${p.price}" />&nbsp;원
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
  <td width="104" class="ct_write">상품이미지</td>
  <td bgcolor="D6D6D6" width="1"></td>
  <td class="ct_write01">
    <%-- 1. 다중 파일 선택이 가능하도록 multiple 속성 추가 및 name 변경 --%>
    <input type="file" name="uploadFiles" accept="image/*" class="ct_input_g"
           style="width: 300px; height: 22px;" multiple="multiple" />

    <%-- 2. 수정 모드일 경우, 현재 등록된 이미지 목록 표시 --%>
      <c:if test="${isUpdate and not empty p.images}">
        <div style="margin-top: 10px;">
          <strong>현재 이미지:</strong><br/>
          <c:forEach var="image" items="${p.images}">
            <div style="display: inline-block; margin: 5px; text-align: center;">
              <img src="${ctx}${image.imagePath}" style="width: 80px; height: 80px; border: 1px solid #ccc; object-fit: cover;">
              <br/>
              <%-- (선택) 이미지 삭제나 순서 변경 기능 추가 가능 --%>
            </div>
          </c:forEach>
          <p style="color: #888;">(새 이미지를 업로드하면 기존 이미지는 모두 교체됩니다.)</p>
        </div>
      </c:if>
    </td>
  </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  </table>

  <!-- 버튼 영역 -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top: 10px;">
    <tr>
      <td width="53%"></td>
      <td align="right">
        <table border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="17" height="23">
              <img src="${ctx}/images/ct_btnbg01.gif" width="17" height="23" />
            </td>
            <td background="${ctx}/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top: 3px;">
              <!-- a 제거 → span -->
              <span class="btn-submit" style="cursor:pointer;">
                <c:choose><c:when test="${isUpdate}">수정</c:when><c:otherwise>등록</c:otherwise></c:choose>
              </span>
            </td>
            <td width="14" height="23">
              <img src="${ctx}/images/ct_btnbg03.gif" width="14" height="23" />
            </td>
            <td width="30"></td>
            <td width="17" height="23">
              <img src="${ctx}/images/ct_btnbg01.gif" width="17" height="23" />
            </td>
            <td background="${ctx}/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top: 3px;">
              <!-- a 제거 → span -->
              <span class="btn-cancel" style="cursor:pointer;">취소</span>
            </td>
            <td width="14" height="23">
              <img src="${ctx}/images/ct_btnbg03.gif" width="14" height="23" />
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</form>

</body>
</html>
