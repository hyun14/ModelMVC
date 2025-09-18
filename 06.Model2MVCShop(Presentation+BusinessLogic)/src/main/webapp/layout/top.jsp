<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<html>
<head>
<title>Model2 MVC Shop</title>

<link href="/css/left.css" rel="stylesheet" type="text/css">

</head>

<body topmargin="0" leftmargin="0">
 
<table width="100%" height="50" border="0" cellpadding="0" cellspacing="0">
  <tr>
	<td height="10"></td>
	<td height="10" >&nbsp;</td>
  </tr>
  <tr>
    <td width="800" height="30"><h2>Model2 MVC Shop</h2></td>
  </tr>
  <tr>
    <td height="20" align="right" background="/images/img_bg.gif">
	    <table width="200" border="0" cellspacing="0" cellpadding="0">
	        <tr> 
	          <td width="115">
		          <c:if test="${empty user}">
		              <a href="${ctx}/user/loginView.jsp" target="rightFrame">login</a>   
		          </c:if>        
	          </td>
	          <td width="14">&nbsp;</td>
	          <td width="56">
		          <c:if test="${not empty user}">
		            	<a href="${ctx}/logout.do" target="_parent">logout</a>  
		           </c:if>
	          </td>
	        </tr>
	      </table>
      </td>
    <td height="20" background="${ctx}/images/img_bg.gif">&nbsp;</td>
  </tr>
</table>

</body>
</html>