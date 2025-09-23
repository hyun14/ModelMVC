<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html>
<head>
  <title>구매 이력 조회</title>
  <link rel="stylesheet" href="${ctx}/css/admin.css" type="text/css" />
  
  <script type="text/javascript">
    function fncGetList(currentPage){
      document.getElementById('currentPage').value = currentPage;
      document.getElementById('listForm').submit();
    }
  </script>
  
</head>
<body>

<%-- [제출 폼] START --%>
<form id="listForm" name="listForm" method="post" action="./listPurchase">
  <input type="hidden" id="currentPage" name="currentPage" value="${resultPage.currentPage}" />
</form>
<%-- [제출 폼] END --%>

<%-- [Title Bar] START --%>
<table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="15" height="37"><img src="${ctx}/images/ct_ttl_img01.gif" width="15" height="37" /></td>
    <td background="${ctx}/images/ct_ttl_img02.gif" width="100%" style="padding-left:10px;">
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="93%" class="ct_ttl01">구매 이력 조회</td>
          <td width="20%" align="right">&nbsp;</td>
        </tr>
      </table>
    </td>
    <td width="12" height="37"><img src="${ctx}/images/ct_ttl_img03.gif" width="12" height="37" /></td>
  </tr>
</table>
<%-- [Title Bar] END --%>

<div style="width:98%; margin-left:10px;">

  <%-- [요약 정보] START --%>
  <div style="margin:8px 0;">
    전체 <strong>${resultPage.totalCount}</strong> 건수, 현재 <strong>${resultPage.currentPage}</strong> 페이지
  </div>
  <%-- [요약 정보] END --%>

  <%-- [목록 테이블] START --%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
	  <tr>
	    <th class="ct_list_b" width="100">주문번호</th>
	    <th class="ct_list_b" width="1"></th>
	    <th class="ct_list_b" width="140">회원ID</th>
	    <th class="ct_list_b" width="1"></th>
	    <th class="ct_list_b" width="160">회원명</th>
	    <th class="ct_list_b" width="1"></th>
	    <th class="ct_list_b" width="160">전화번호</th>
	    <th class="ct_list_b" width="1"></th>
	    <th class="ct_list_b" width="220">배송현황</th>
	    <th class="ct_list_b" width="1"></th>
	    <th class="ct_list_b" width="120">정보수정</th>
	  </tr>
	
	  <c:forEach var="p" items="${list}">
	    <tr class="ct_list_pop">
	      <td align="center"><a href="./getPurchase?tranNo=${p.tranNo}">${p.tranNo}</a></td>
	      <td></td>
	      <td align="center">${p.buyer.userId}</td>
	      <td></td>
	      <td align="left">${p.receiverName}</td>
	      <td></td>
	      <td align="center">${p.receiverPhone}</td>
	      <td></td>
	
	      <%-- 배송현황 --%>
	      <td align="left">
	        <c:set var="code" value="${p.tranCode}" />
	        <c:choose>
	          <%-- 숫자/문자 코드 모두 지원 --%>
	          <c:when test="${code eq '4' or code eq 'DLV'}">현재 배송완료 상태 입니다.</c:when>
	          <c:when test="${code eq '3' or code eq 'SHP'}">현재 배송중 상태 입니다.</c:when>
	          <c:when test="${code eq '2' or code eq 'BEF'}">현재 배송전 상태 입니다.</c:when>
	          <c:otherwise>-</c:otherwise>
	        </c:choose>
	      </td>
	
	      <td></td>
	
	      <%-- 정보수정: 배송중일 때만 '물건도착' 링크 노출 --%>
	      <td align="center">
	        <c:choose>
	          <c:when test="${code eq '3' or code eq 'SHP'}">
	            <a
	              href="./updateTranCode?tranNo=${p.tranNo}&amp;tranCode=DLV">
	              물건도착
	            </a>
	          </c:when>
	          <c:otherwise>-</c:otherwise>
	        </c:choose>
	      </td>
	    </tr>
	    <tr><td colspan="11" class="dot"></td></tr>
	  </c:forEach>
	</table>
	<%-- [목록 테이블] END --%>


	<%-- [페이지네이션] START // class="pagination-center 페이제네이션 중앙정렬용 아직 구현 X--%>
	<div class="pagination-center">
	  <jsp:include page="../common/pageNavigator.jsp" />
	</div>
	<%-- [페이지네이션] END --%>


</div>
</body>
</html>
