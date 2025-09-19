<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>History</title>
  <style>
    .hist      { padding: 8px 10px; }
    .hist h3   { margin: 0 0 8px; font-size: 16px; font-weight: 600; }
    .hist a    { display:block; margin: 4px 0; text-decoration:none; }
    .empty     { color:#666; font-size:14px; }
  </style>
</head>
<body>
<div class="hist">

  <%-- 0) Action이 세팅한 histVal을 우선 사용. 없으면 쿠키 fallback --%>
  <c:set var="src" value="${not empty requestScope.histVal ? requestScope.histVal : cookie.history.value}" />
  <%-- 과거에 URL 인코딩된 상태로 저장된 경우 대비: %2C -> ,  --%>
  <c:set var="src" value="${fn:replace(src, '%2C', ',')}" />
  <c:set var="src" value="${fn:replace(src, '%2c', ',')}" />
  <%-- 개행 인코딩이 포함되었다면 콤마로 정규화 --%>
  <c:set var="src" value="${fn:replace(src, '%0D%0A', ',')}" />
  <c:set var="src" value="${fn:replace(src, '%0d%0a', ',')}" />
  <c:set var="src" value="${fn:replace(src, '%0A', ',')}" />
  <c:set var="src" value="${fn:replace(src, '%0a', ',')}" />
  <c:set var="src" value="${fn:replace(src, '%0D', ',')}" />
  <c:set var="src" value="${fn:replace(src, '%0d', ',')}" />

  <%-- 유효성 체크: 콤마 제거하고 공백만 남으면 없음 처리 --%>
  <c:set var="hasHist" value="${not empty fn:trim(fn:replace(src, ',', ''))}" />

  <c:choose>
    <c:when test="${hasHist}">
      <h3>당신이 열어본 상품을 알고 있다</h3>
      <%-- 1) 콤마 기준 분리 --%>
      <c:forTokens items="${src}" delims="," var="rawId">
        <c:set var="tid" value="${fn:trim(rawId)}" />
        <c:if test="${not empty tid and tid ne 'null'}">
          <%-- 2) 상세 링크 안전 생성 --%>
          <c:url var="prodUrl" value="/getProduct">
            <c:param name="prodNo" value="${tid}" />
            <c:param name="menu"   value="search" />
          </c:url>
          <!-- 프레임 레이아웃을 쓰면 target 유지, 아니면 제거하세요 -->
          <a href="${prodUrl}" target="rightFrame">${tid}</a>
        </c:if>
      </c:forTokens>
    </c:when>
    <c:otherwise>
      <div class="empty">조회 이력이 없습니다.</div>
    </c:otherwise>
  </c:choose>

</div>
</body>
</html>
