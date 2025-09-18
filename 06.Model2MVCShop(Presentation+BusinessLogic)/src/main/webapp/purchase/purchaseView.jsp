<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- [상단 변수 세팅] START --%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="product"   value="${requestScope.product}" />
<c:choose>
  <c:when test="${not empty requestScope.loginUser}">
    <c:set var="loginUser" value="${requestScope.loginUser}" />
  </c:when>
  <c:otherwise>
    <c:set var="loginUser" value="${sessionScope.user}" />
  </c:otherwise>
</c:choose>

<%-- 제조일자 표시용(YYYYMMDD -> YYYY-MM-DD) --%>
<c:choose>
  <c:when test="${not empty product.manuDate and fn:length(product.manuDate) == 8}">
    <c:set var="manuDateDisp"
           value="${fn:substring(product.manuDate,0,4)}-${fn:substring(product.manuDate,4,6)}-${fn:substring(product.manuDate,6,8)}" />
  </c:when>
  <c:otherwise>
    <c:set var="manuDateDisp" value="${product.manuDate}" />
  </c:otherwise>
</c:choose>
<fmt:formatDate value="${product.regDate}" pattern="yyyy-MM-dd" var="regDateDisp" />
<%-- [상단 변수 세팅] END --%>

<!DOCTYPE html>
<html>
<head>
  <title>구매하기</title>
  <link rel="stylesheet" href="${ctx}/css/admin.css" type="text/css" />
</head>

<body>
<div class="content">

  <%-- [가드] START: product 없을 때 --%>
  <c:if test="${empty product}">
    <div style="padding:16px;">
      잘못된 접근입니다. <a href="${ctx}/listProduct.do?menu=search">목록으로</a>
    </div>
  </c:if>
  <%-- [가드] END --%>

  <c:if test="${not empty product}">
    <h2>구매하기</h2>

    <%-- [폼] START --%>
    <form method="post" action="${ctx}/addPurchase.do">
      <input type="hidden" name="prodNo" value="${product.prodNo}" />

      <%-- [섹션] 상품 정보 START --%>
      <fieldset>
        <legend>상품 정보</legend>
        <div>상품번호: ${product.prodNo}</div>
        <div>상품명: ${product.prodName}</div>
        <div>상세정보: ${product.prodDetail}</div>
        <div>제조일자: ${manuDateDisp}</div>
        <div>가격: <fmt:formatNumber value="${product.price}" /></div>
        <div>등록일자: ${regDateDisp}</div>
      </fieldset>
      <%-- [섹션] 상품 정보 END --%>

      <%-- [섹션] 구매자 정보 START --%>
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
      <%-- [섹션] 구매자 정보 END --%>

      <%-- [섹션] 결제/요청 START --%>
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
      <%-- [섹션] 결제/요청 END --%>

      <div style="margin-top:12px;">
        <button type="submit">구매</button>
        <a href="${ctx}/getProduct.do?prodNo=${product.prodNo}">취소</a>
      </div>
    </form>
    <%-- [폼] END --%>
  </c:if>

</div>
</body>
</html>
