<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%-- 상단 변수 --%>
<c:set var="product"   value="${requestScope.product}" />
<c:choose>
  <c:when test="${not empty requestScope.loginUser}">
    <c:set var="loginUser" value="${requestScope.loginUser}" />
  </c:when>
  <c:otherwise>
    <c:set var="loginUser" value="${sessionScope.loginUser}" />
  </c:otherwise>
</c:choose>

<%-- 제조일자 표기 --%>
<c:choose>
  <c:when test="${not empty product.manuDate and fn:length(product.manuDate) == 8}">
    <c:set var="manuDateDisp" value="${fn:substring(product.manuDate,0,4)}-${fn:substring(product.manuDate,4,6)}-${fn:substring(product.manuDate,6,8)}" />
  </c:when>
  <c:otherwise>
    <c:set var="manuDateDisp" value="${product.manuDate}" />
  </c:otherwise>
</c:choose>
<fmt:formatDate value="${product.regDate}" pattern="yyyy-MM-dd" var="regDateDisp" />

<!DOCTYPE html>
<html>
<head>
  <title>구매하기</title>
  <link rel="stylesheet" href="${ctx}/css/admin.css" type="text/css" />
  <script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
  <style>
    .btn-like { cursor:pointer; color:#0066cc; }
    .btn-like:hover { text-decoration: underline; }
  </style>
  <script type="text/javascript">
    // 동적 hidden 유틸
    function clearDynamicHidden(){ $("#purchaseForm").find("input.dynamic-extra").remove(); }
    function addHidden(name, val){
      $("<input>", {type:"hidden", name:name, value:val, class:"dynamic-extra"}).appendTo("#purchaseForm");
    }
    function submitWith(actionUrl, method){
      var $f = $("#purchaseForm");
      $f.attr("action", actionUrl);
      $f.attr("method", method); // "post" | "get"
      $f.trigger("submit");
    }

    $(function(){
      // 구매(제출): ./addPurchase (POST)
      $(document).on("click", ".btn-buy", function(){
        clearDynamicHidden();
        submitWith("./addPurchase", "post");
      });

      // 취소: 상품상세로 복귀 (GET)
      $(document).on("click", ".btn-cancel", function(){
        clearDynamicHidden();
        // prodNo는 기본 hidden 존재 → 그대로 전송
        submitWith("${ctx}/product/getProduct", "get");
      });

      // 가드(잘못된 접근)에서 목록 이동
      $(document).on("click", ".btn-goto-list", function(){
        clearDynamicHidden();
        addHidden("menu", "search");
        submitWith("${ctx}/product/listProduct", "get");
      });
    });
  </script>
</head>

<body>
<div class="content">

  <%-- [가드] product 없음 --%>
  <c:if test="${empty product}">
    <form id="purchaseForm" name="purchaseForm">
      <div style="padding:16px;">
        잘못된 접근입니다.
        <span class="btn-like btn-goto-list">목록으로</span>
      </div>
    </form>
  </c:if>

  <c:if test="${not empty product}">
    <%-- 액션 전환/파라미터 유지용 폼 (method/action 미기재) --%>
    <form id="purchaseForm" name="purchaseForm">
      <!-- 필수 키 -->
      <input type="hidden" name="purchaseProd.prodNo" value="${product.prodNo}" />
      <input type="hidden" name="prodNo" value="${product.prodNo}" />

      <!-- (선택) 검색조건/페이지 유지: 있으면 전달 -->
      <c:if test="${not empty param.currentPage or (not empty search and not empty search.currentPage)}">
        <input type="hidden" name="currentPage" value="${not empty param.currentPage ? param.currentPage : search.currentPage}" />
        <input type="hidden" name="page"        value="${not empty param.currentPage ? param.currentPage : search.currentPage}" />
      </c:if>
      <c:if test="${not empty param.pageSize or (not empty search and not empty search.pageSize)}">
        <input type="hidden" name="pageSize" value="${not empty param.pageSize ? param.pageSize : search.pageSize}" />
      </c:if>
      <c:if test="${not empty param.searchCondition or (not empty search and not empty search.searchCondition)}">
        <input type="hidden" name="searchCondition" value="${not empty param.searchCondition ? param.searchCondition : search.searchCondition}" />
      </c:if>
      <c:if test="${not empty param.searchKeyword or (not empty search and not empty search.searchKeyword)}">
        <input type="hidden" name="searchKeyword" value="${not empty param.searchKeyword ? param.searchKeyword : search.searchKeyword}" />
      </c:if>
      <c:if test="${not empty param.menu or not empty menu}">
        <input type="hidden" name="menu" value="${not empty param.menu ? param.menu : menu}" />
      </c:if>

      <h2>구매하기</h2>

      <%-- [섹션] 상품 정보 --%>
      <fieldset>
        <legend>상품 정보</legend>
        <div>상품번호: ${product.prodNo}</div>
        <div>상품명: ${product.prodName}</div>
        <div>상세정보: ${product.prodDetail}</div>
        <div>제조일자: ${manuDateDisp}</div>
        <div>가격: <fmt:formatNumber value="${product.price}" /></div>
        <div>등록일자: ${regDateDisp}</div>
      </fieldset>

      <%-- [섹션] 구매자 정보 --%>
      <fieldset>
        <legend>구매자 정보</legend>
        <div>구매자 아이디: ${loginUser.userId}</div>

        <div>
          <label>구매자 이름</label>
          <input type="text" name="receiverName" value="${loginUser.userName}" />
        </div>
        <div>
          <label>구매자 연락처</label>
          <input type="text" name="receiverPhone" value="${loginUser.phone}" />
        </div>
        <div>
          <label>구매자 주소</label>
          <input type="text" name="divyAddr" value="${loginUser.addr}" />
        </div>
      </fieldset>

      <%-- [섹션] 결제/요청 --%>
      <fieldset>
        <legend>결제/요청</legend>
        <div>
          <label>구매방법</label>
          <select name="paymentOption">
            <option value="CSH">현금구매</option>
            <option value="CRD">카드결제</option>
          </select>
        </div>
        <div>
          <label>구매요청사항</label>
          <input type="text" name="divyRequest" maxlength="100" />
        </div>
        <div>
          <label>배송희망날짜</label>
          <input type="date" name="divyDate" />
        </div>
      </fieldset>

      <div style="margin-top:12px;">
        <span class="btn-like btn-buy">구매</span>
        &nbsp;&nbsp;
        <span class="btn-like btn-cancel">취소</span>
      </div>
    </form>
  </c:if>

</div>
</body>
</html>
