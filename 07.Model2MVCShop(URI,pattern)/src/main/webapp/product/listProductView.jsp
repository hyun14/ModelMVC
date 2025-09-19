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
  
  <!-- row-click stylesheet and script (external management) -->
  <link rel="stylesheet" href="${ctx}/css/rowClick.css" type="text/css" />
  <script src="${ctx}/javascript/rowClick.js" defer></script>

  <script type="text/javascript">
    function fncGetList(page){
      var sc = document.getElementById('sc').value;
      var sk = document.getElementById('sk').value.trim();
      if ((sc === '0' || sc === '2') && sk !== '' && !/^[0-9]+$/.test(sk)){
        alert('숫자만 입력하세요.');
        return false;
      }
      // 🔧 핵심 수정: 둘 다 세팅
      if (document.detailForm.page)        document.detailForm.page.value = page;
      if (document.detailForm.currentPage) document.detailForm.currentPage.value = page;
  
      document.detailForm.submit();
    }
    function fncGetUserList(n){ return fncGetList(n); } // alias 그대로 유지
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
  <%-- 액션을 라우터로 단일화하여 JSP의 분기 복잡도 제거 --%>
  <form name="detailForm" method="post" action="./listProductEntry">
    <input type="hidden" name="menu" value="${menuVal}" />
    <input type="hidden" name="page" value="${search.currentPage}" />
    <input type="hidden" name="currentPage" value="${search.currentPage}" />
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
          <a href="javascript:fncGetList(1)" class="btn-search">
            <img src="${ctx}/images/ct_btn_search.gif" width="45" height="23" style="vertical-align:middle;" />
          </a>
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
      <c:url var="prodDetailUrl" value="./getProduct">
		  <!-- 기존 파라미터 -->
		  <c:param name="menu"   value="${menuVal}" />
		  <c:param name="prodNo" value="${product.prodNo}" />
		  <c:param name="code"   value="${code}" />
		
		  <!-- 검색조건 함께 전달 -->
		  <c:if test="${not empty search}">
		    <c:if test="${not empty search.searchCondition}">
		      <c:param name="searchCondition" value="${search.searchCondition}" />
		    </c:if>
		    <c:if test="${not empty search.searchKeyword}">
		      <c:param name="searchKeyword" value="${search.searchKeyword}" />
		    </c:if>
		
		    <!-- 페이지 정보: 서버가 어떤 이름을 읽든 대비 -->
		    <c:if test="${not empty search.currentPage}">
		      <c:param name="page"        value="${search.currentPage}" />
		      <c:param name="currentPage" value="${search.currentPage}" />
		    </c:if>
		    <c:if test="${not empty search.pageSize}">
		      <c:param name="pageSize" value="${search.pageSize}" />
		    </c:if>
		  </c:if>
		</c:url>
		
	  <tr class="ct_list_pop click-row" data-mode="${menuVal}" data-href="${prodDetailUrl}">
        <td align="center">${product.prodNo}</td>
        <td></td>
        <td align="left" class="name-cell">
          <c:choose>
            <%-- 사용자 검색 목록에서는(DAO에서 이미 걸러지므로) 링크 비활성화 케이스가 사실상 발생하지 않지만, 안전하게 유지 --%>
            <c:when test="${isUserList and not empty product.proTranCode}">
              <span class="ellipsis">${product.prodName}</span>
            </c:when>
            <c:otherwise>
              <%-- <a href="${ctx}/getProduct?menu=${menuVal}&prodNo=${product.prodNo}&code=${code}"> --%>
                <span class="ellipsis">${product.prodName}</span>
              <!-- </a> -->
            </c:otherwise>
          </c:choose>
        </td>
        <td></td>
        <td align="center"><fmt:formatDate value="${product.regDate}" pattern="yyyy-MM-dd" /></td>
        <td></td>
        <td class="price-cell"><fmt:formatNumber value="${product.price}" /></td>
        <td></td>
        <td class="status-cell">
          

          <c:choose>
            <%-- 관리자이며, 관리 모드(menu=manage)일 때: 상세 상태 + 배송하기 링크 --%>
            <c:when test="${user.role == 'admin' and menuVal == 'manage'}">
              <c:choose>
                <c:when test="${empty code}">판매중</c:when>
                <c:when test="${code == 'BEF'}">배송예정</c:when>
                <c:when test="${code == 'SHP'}">배송중</c:when>
                <c:when test="${code == 'DLV'}">배송완료</c:when>
                <c:otherwise>${code}</c:otherwise>
              </c:choose>

              <c:if test="${code == 'BEF'}">
                &nbsp;|&nbsp;
                <a class="status-link" href="${ctx}/purchase/updateTranCodeByProd?prodNo=${product.prodNo}&page=${search.currentPage}">배송하기</a>
              </c:if>
            </c:when>

            <%-- 그 외(관리자가 아니거나, 검색 모드 등): 간략 표기 --%>
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
  <table width="100%" border="0" cellspacing="0" cellpadding="0"	style="margin-top:10px;">
  	<tr>
  		<td align="center">
  		   <input type="hidden" id="currentPage" name="currentPage" value=""/>
  	
  			<jsp:include page="../common/pageNavigator.jsp"/>	
  			
      	</td>
  	</tr>
  </table>
  <!-- PageNavigation End... -->

</div>
</body>
</html>
