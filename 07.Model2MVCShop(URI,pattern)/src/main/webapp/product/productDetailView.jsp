<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- [상단 변수 세팅] START -->
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!-- 컨트롤러에서 넣어준 requestScope.product 를 지역변수처럼 참조 -->
<c:set var="product" value="${requestScope.product}" />
<!-- 세션 사용자/권한 -->
<c:set var="user" value="${sessionScope.user}" />
<c:set var="isAdmin" value="${not empty user and user.role == 'admin'}" />
<%-- [의미] 목록 복귀용 기준(menu) : param.menu > requestScope.menu > 기본값 'search' --%>
<c:set var="menuVal" value="${not empty param.menu ? param.menu : menu}" />
<c:if test="${empty menuVal}">
  <c:set var="menuVal" value="search"/>
</c:if>


<!-- 제조일자 표시용(YYYYMMDD -> YYYY-MM-DD) -->
<c:choose>
  <c:when test="${not empty product.manuDate and fn:length(product.manuDate) == 8}">
  <c:set var="manuDateDisp"
         value="${fn:substring(product.manuDate,0,4)}-${fn:substring(product.manuDate,4,6)}-${fn:substring(product.manuDate,6,8)}" />
  </c:when>
  <c:otherwise>
    <c:set var="manuDateDisp" value="${product.manuDate}" />
  </c:otherwise>
</c:choose>

<!-- 등록일 표시용(Date -> yyyy-MM-dd) -->
<fmt:formatDate value="${product.regDate}" pattern="yyyy-MM-dd" var="regDateDisp" />

<!-- 상태 표시용 -->
<c:set var="code" value="${product.proTranCode}" />
<c:choose>
  <c:when test="${empty code}">
    <c:set var="statusDisp" value="판매중" />
  </c:when>
  <c:when test="${code == 'BEF'}">
    <c:set var="statusDisp" value="배송예정" />
  </c:when>
  <c:when test="${code == 'SHP'}">
    <c:set var="statusDisp" value="배송중" />
  </c:when>
  <c:when test="${code == 'DLV'}">
    <c:set var="statusDisp" value="배송완료" />
  </c:when>
  <c:otherwise>
    <c:set var="statusDisp" value="${code}" />
  </c:otherwise>
</c:choose>
<!-- [상단 변수 세팅] END -->

<!DOCTYPE html>
<html>
<head>
  <title>상품상세보기</title>
  <link rel="stylesheet" href="${ctx}/css/admin.css" type="text/css" />
</head>
<body bgcolor="#ffffff" text="#000000">

<!-- [가드: 잘못된 접근] START -->
<c:if test="${empty product}">
  <div style="padding:16px;">
    잘못된 접근입니다.
    <a href="./listProduct?menu=search">목록으로</a>
  </div>
</c:if>
<!-- [가드: 잘못된 접근] END -->

<c:if test="${not empty product}">
  <!-- [상단 타이틀] START -->
  <table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="15" height="37"><img src="${ctx}/images/ct_ttl_img01.gif" width="15" height="37" /></td>
      <td background="${ctx}/images/ct_ttl_img02.gif" width="100%" style="padding-left:10px;">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="93%" class="ct_ttl01">상품상세보기</td>
            <td width="20%" align="right">&nbsp;</td>
          </tr>
        </table>
      </td>
      <td width="12" height="37"><img src="${ctx}/images/ct_ttl_img03.gif" width="12" height="37" /></td>
    </tr>
  </table>
  <!-- [상단 타이틀] END -->

  <!-- [상세 테이블] START -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:13px;">
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td width="104" class="ct_write">상품번호</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">${product.prodNo}</td>
    </tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td class="ct_write">상품명</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">${product.prodName}</td>
    </tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td class="ct_write">가격</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01"><fmt:formatNumber value="${product.price}" /> 원</td>
    </tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td class="ct_write">제조일자</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">${manuDateDisp}</td>
    </tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td class="ct_write">등록일</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">${regDateDisp}</td>
    </tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td class="ct_write">현재상태</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">${statusDisp}</td>
    </tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td class="ct_write">상품상세정보</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">${product.prodDetail}</td>
    </tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

      <%-- [이미지 표시 블록] : product.fileName이 있을 때만 노출 --%>
      <c:if test="${not empty product.fileName}">
        <tr>
          <td class="ct_write">상품이미지</td>
          <td bgcolor="D6D6D6" width="1"></td>
          <td class="ct_write01"><c:choose>
              <c:when test="${fn:startsWith(product.fileName, '/')}">
                <c:set var="imgSrc" value="${ctx}${product.fileName}" />
              </c:when>
              <c:otherwise>
                <c:set var="imgSrc" value="${product.fileName}" />
              </c:otherwise>
            </c:choose></td>
        </tr>
        <%-- [이미지 렌더링] : 크기 제한만 적용, 비율 유지 --%>
        <div style="margin-top: 12px;">
          <img src="${imgSrc}" alt="상품 이미지"
            style="max-width: 320px; height: auto; border: 1px solid #e6e9ef; border-radius: 8px;" />
        </div>
      </c:if>

      <%-- [이미지 없음 안내] : 경로가 비어있을 경우 간단 안내 --%>
      <c:if test="${empty product.fileName}">
        <div style="margin-top: 12px; color: #666666;">등록된 상품 이미지가
          없습니다.</div>
      </c:if>

      <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  </table>
  <!-- [상세 테이블] END -->

  <!-- [버튼 영역] START -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
    <tr>
      <td width="53%"></td>
      <td align="right" style="padding-right:20px;">
        <table border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="17" height="23"><img src="${ctx}/images/ct_btnbg01.gif" width="17" height="23" /></td>
            <td background="${ctx}/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">

			<%-- [의미] 목록 엔트리로 단일 진입. 컨트롤러가 리다이렉트 분기 수행 --%>
            <c:url var="backToListUrl" value="./listProductEntry">
              <c:param name="menu" value="${menuVal}"/>
              <c:param name="currentPage" value="${search.currentPage}"/>
              <c:param name="pageSize"     value="${search.pageSize}"/>
              <c:if test="${not empty search.searchCondition}">
                <c:param name="searchCondition" value="${search.searchCondition}"/>
              </c:if>
              <c:if test="${not empty search.searchKeyword}">
                <c:param name="searchKeyword" value="${search.searchKeyword}"/>
              </c:if>
            </c:url>
            
            <a href="${backToListUrl}">목록</a>
            </td>
            <td width="14" height="23"><img src="${ctx}/images/ct_btnbg03.gif" width="14" height="23" /></td>

            <c:if test="${not isAdmin}">
              <td width="10"></td>
              <td width="17" height="23"><img src="${ctx}/images/ct_btnbg01.gif" width="17" height="23" /></td>
              <td background="${ctx}/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">
                <a href="${ctx}/purchase/addPurchaseView?prodNo=${product.prodNo}">구매</a>
              </td>
              <td width="14" height="23"><img src="${ctx}/images/ct_btnbg03.gif" width="14" height="23" /></td>
            </c:if>
          </tr>
        </table>
      </td>
    </tr>
  </table>
  <!-- [버튼 영역] END -->
</c:if>

</body>
</html>
