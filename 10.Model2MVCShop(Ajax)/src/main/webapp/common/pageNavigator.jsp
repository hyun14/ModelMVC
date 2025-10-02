<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
  .pagination { display:inline-flex; gap:8px; align-items:center; }
  .page-link { text-decoration:none; }
  .page-current { font-weight:700; }
</style>

<div class="pagination">
  <!-- 이전: only show if there is a previous block -->
  <c:if test="${resultPage.beginUnitPage > 1}">
    <a class="page-link" href="javascript:fncGetList('${resultPage.beginUnitPage-1}')">◀ 이전</a>
  </c:if>

  <!-- 페이지 번호들 -->
  <c:forEach var="i" begin="${resultPage.beginUnitPage}" end="${resultPage.endUnitPage}" step="1">
    <c:choose>
      <c:when test="${i == resultPage.currentPage}">
        <span class="page-current">${i}</span>
      </c:when>
      <c:otherwise>
        <a class="page-link" href="javascript:fncGetList('${i}')">${i}</a>
      </c:otherwise>
    </c:choose>
  </c:forEach>

  <!-- 이후: only show if there is a next block -->
  <c:if test="${resultPage.endUnitPage < resultPage.maxPage}">
    <a class="page-link" href="javascript:fncGetList('${resultPage.endUnitPage+1}')">이후 ▶</a>
  </c:if>
</div>
