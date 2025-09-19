<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ page import="com.model2.mvc.service.domain.User" %>

<!-- 컨텍스트/세션 사용자/권한 JSTL 변수로 세팅 -->
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="vo"  value="${sessionScope.user}" />
<c:set var="role" value="${empty vo ? '' : vo.role}" />

<html>
<head>
  <title>Model2 MVC Shop</title>
  <link href="${ctx}/css/left.css" rel="stylesheet" type="text/css" />
  
  <script type="text/javascript">
  function history(){
    window.open(
      "${ctx}/history.jsp",
      "popWin",
      "left=300,top=200,width=300,height=200,scrollbars=no,menubar=no,resizable=no"
    );
  }
  </script>
  
</head>

<body background="${ctx}/images/left/imgLeftBg.gif" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

<table width="159" border="0" cellspacing="0" cellpadding="0">

  <!-- menu 01 -->
  <tr>
    <td valign="top">
      <table border="0" cellspacing="0" cellpadding="0" width="159">
        <c:if test="${not empty vo}">
          <tr>
            <td class="Depth03">
              <a href="${ctx}/user/getUser?userId=${vo.userId}" target="rightFrame">개인정보조회</a>
            </td>
          </tr>
        </c:if>
        <c:if test="${role == 'admin'}">
          <tr>
            <td class="Depth03">
              <a href="${ctx}/user/listUser" target="rightFrame">회원정보조회</a>
            </td>
          </tr>
        </c:if>
        <tr>
          <td class="DepthEnd">&nbsp;</td>
        </tr>
      </table>
    </td>
  </tr>

  <!-- admin 전용 menu 02 -->
  <c:if test="${role == 'admin'}">
    <tr>
      <td valign="top">
        <table border="0" cellspacing="0" cellpadding="0" width="159">
          <tr>
            <td class="Depth03">
              <a href="${ctx}/product/addProductView.jsp" target="rightFrame">판매상품등록</a>
            </td>
          </tr>
          <tr>
            <td class="Depth03">
              <a href="${ctx}/product/listProduct?menu=manage" target="rightFrame">판매상품관리</a>
            </td>
          </tr>
          <tr>
            <td class="DepthEnd">&nbsp;</td>
          </tr>
        </table>
      </td>
    </tr>
  </c:if>

  <!-- menu 03 -->
  <tr>
    <td valign="top">
      <table border="0" cellspacing="0" cellpadding="0" width="159">
        <c:if test="${not empty vo and role == 'user'}">
          <tr>
            <td class="Depth03">
              <a href="${ctx}/product/listProductByUser?menu=search" target="rightFrame">상 품 검 색</a>
            </td>
          </tr>
          <tr>
            <td class="Depth03">
              <a href="${ctx}/purchase/listPurchase" target="rightFrame">구매이력조회</a>
            </td>
          </tr>
        </c:if>
        <tr>
          <td class="DepthEnd">&nbsp;</td>
        </tr>
        <tr>
          <td class="Depth03">
            <a href="javascript:history()">최근 본 상품</a>
          </td>
        </tr>
      </table>
    </td>
  </tr>

</table>

</body>
</html>
