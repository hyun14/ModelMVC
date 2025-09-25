<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="menuVal" value="${not empty param.menu ? param.menu : menu}" />
<c:set var="isUserList" value="${menuVal eq 'search'}" />

<%-- 타이틀 문자열 계산 --%>
<c:set var="pageTitle" value="상품 목록조회" />
<c:if test="${menuVal eq 'manage'}">
  <c:set var="pageTitle" value="상품관리" />
</c:if>

<!DOCTYPE html>
<html>
<head>
  <title>${pageTitle}</title>
  <link rel="stylesheet" href="${ctx}/css/admin.css" type="text/css" />
  <link rel="stylesheet" href="${ctx}/css/rowClick.css" type="text/css" />

  <!-- jQuery -->
  <script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>

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
      $f.attr("method", method);  // "get" | "post"
      $f.trigger("submit");
    }

    // ===== 검색/페이지 이동 =====
    function fncGetList(page){
      // 숫자 조건일 때 숫자만 허용
      var sc = $("#sc").val();
      var sk = $.trim($("#sk").val());
      if ((sc === '0' || sc === '2') && sk !== '' && !/^[0-9]+$/.test(sk)){
        alert('숫자만 입력하세요.');
        return false;
      }
      // currentPage, page 둘 다 세팅 (서버 호환)
      $("#currentPage").val(page);
      $("input[name='page']").val(page);

      clearDynamicHidden();
      submitWith("./listProductEntry", "post");
    }
    // pageNavigator.jsp 호환
    function fncGetUserList(n){ return fncGetList(n); }

    // ===== DOMReady =====
    $(function(){
      // 검색 버튼 (a→span 전환 버전용)
      $(document).on("click", ".btn-search", function(){
        fncGetList(1);
      });

      // 행 클릭 → 상세(GET /getProduct)
      $(document).on("click", ".click-row", function(){
        // 사용자 검색 목록에서 거래완료/배송상태면 링크 비활성화하는 케이스 유지
        if ($(this).data("disabled") === true) return;

        var prodNo = $(this).data("prodno");
        var code   = $(this).data("code") || "";
        var menu   = $(this).data("mode"); // search | manage

        clearDynamicHidden();
        addHidden("menu", menu);
        addHidden("prodNo", prodNo);
        if (code) addHidden("code", code);

        submitWith("./getProduct", "get");
      });

      // 배송하기 (관리자, code=BEF인 경우만 표출)
      $(document).on("click", ".btn-ship", function(e){
        e.stopPropagation(); // 행 클릭과 충돌 방지
        var prodNo = $(this).data("prodno");

        clearDynamicHidden();
        addHidden("prodNo", prodNo);
        // 페이지/검색조건은 폼의 고정 hidden이 같이 전송됨
        submitWith("${ctx}/purchase/updateTranCodeByProd", "get");
      });
    });
  </script>
</head>

<body bgcolor="#ffffff" text="#000000">

<!-- [Title Bar] START -->
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
<!-- [Title Bar] END -->

<div style="width:98%; margin-left:10px;">

  <!-- [검색 폼] START -->
  <form id="productListForm" name="detailForm">
    <!-- 라우팅 분기값 -->
    <input type="hidden" name="menu" value="${menuVal}" />
    <!-- 페이지 값(서버 호환을 위해 둘 다 유지) -->
    <input type="hidden" name="page"        value="${search.currentPage}" />
    <input type="hidden" id="currentPage"   name="currentPage" value="${search.currentPage}" />
    <!-- pageSize/검색조건 유지 -->
    <c:if test="${not empty search.pageSize}">
      <input type="hidden" name="pageSize" value="${search.pageSize}" />
    </c:if>
    <c:if test="${not empty search.searchCondition}">
      <input type="hidden" name="searchCondition" value="${search.searchCondition}" />
    </c:if>
    <c:if test="${not empty search.searchKeyword}">
      <input type="hidden" name="searchKeyword" value="${search.searchKeyword}" />
    </c:if>

    <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
      <tr>
        <td align="right" class="search-row">
          <select name="searchCondition" id="sc" class="ct_input_g" style="width:80px">
            <option value="0" <c:if test="${search.searchCondition == '0'}">selected</c:if>>상품번호</option>
            <option value="1" <c:if test="${search.searchCondition == '1'}">selected</c:if>>상품명</option>
            <option value="2" <c:if test="${search.searchCondition == '2'}">selected</c:if>>가격</option>
          </select>
          <input type="text" name="searchKeyword" id="sk" class="ct_input_g" style="width:200px"
                 value="${search.searchKeyword}" placeholder="검색어" />
          <!-- a 제거 → span 으로 클릭 처리 -->
          <span class="btn-search" style="cursor:pointer; vertical-align:middle;">
            <img src="${ctx}/images/ct_btn_search.gif" width="45" height="23" style="vertical-align:middle;" alt="검색" />
          </span>
        </td>
      </tr>
    </table>
  </form>
  <!-- [검색 폼] END -->

  <!-- [요약 정보] START -->
  <div style="margin:8px 0;">
    전체 <strong>${resultPage.totalCount}</strong> 건수, 현재 <strong>${resultPage.currentPage}</strong> 페이지
  </div>
  <!-- [요약 정보] END -->

  <!-- [목록 테이블] START -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;" class="table-list">
    <tr>
      <th class="ct_list_b" width="80">번호</th>
      <th class="ct_list_b" width="1"></th>
      <th class="ct_list_b">상품명</th>
      <th class="ct_list_b" width="1"></th>
      <th class="ct_list_b" width="120">등록일</th>
      <th class="ct_list_b" width="1"></th>
      <th class="ct_list_b" width="120">가격</th>
      <th class="ct_list_b" width="1"></th>
      <th class="ct_list_b" width="150">거래상태</th>
    </tr>

    <c:forEach var="product" items="${list}">
      <c:set var="code" value="${product.proTranCode}" />
      <%-- 클릭 시 상세로 보낼 필수 데이터는 data-*로 저장 --%>
      <tr class="ct_list_pop click-row"
          data-mode="${menuVal}"
          data-prodno="${product.prodNo}"
          data-code="${code}"
          <c:if test="${isUserList and not empty product.proTranCode}">data-disabled="true"</c:if>
      >
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
        <td class="status-cell">
          <c:choose>
            <c:when test="${loginUser.role == 'admin' and menuVal == 'manage'}">
              <c:choose>
                <c:when test="${empty code}">판매중</c:when>
                <c:when test="${code == 'BEF'}">배송예정</c:when>
                <c:when test="${code == 'SHP'}">배송중</c:when>
                <c:when test="${code == 'DLV'}">배송완료</c:when>
                <c:otherwise>${code}</c:otherwise>
              </c:choose>

              <c:if test="${code == 'BEF'}">
                &nbsp;|&nbsp;
                <!-- a 제거 → span 버튼화 -->
                <span class="btn-ship"
                      data-prodno="${product.prodNo}"
                      style="color:#0066cc; cursor:pointer; text-decoration:underline;">
                  배송하기
                </span>
              </c:if>
            </c:when>

            <c:otherwise>
              <c:choose>
                <c:when test="${empty code}">판매중</c:when>
                <c:otherwise>재고소진</c:otherwise>
              </c:choose>
            </c:otherwise>
          </c:choose>
        </td>
      </tr>
      <tr><td colspan="9" class="dot"></td></tr>
    </c:forEach>
  </table>
  <!-- [목록 테이블] END -->

  <!-- PageNavigation Start... -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
    <tr>
      <td align="center">
        <!-- 네비게이터가 이 hidden을 쓰므로 유지 -->
        <input type="hidden" id="currentPage" name="currentPage" value=""/>
        <jsp:include page="../common/pageNavigator.jsp"/>
      </td>
    </tr>
  </table>
  <!-- PageNavigation End... -->

</div>
</body>
</html>
