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
  <link rel="stylesheet" href="${ctx}/css/rowClick.css" type="text/css" />
  
  <script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
  <script type="text/javascript">
    // ===== 동적 hidden 유틸 =====
    function clearDynamicHidden(){ $("#listForm").find("input.dynamic-extra").remove(); }
    function addHidden(name, val){
      $("<input>", {type:"hidden", name:name, value:val, class:"dynamic-extra"}).appendTo("#listForm");
    }
    function submitWith(actionUrl, method){
      var $f = $("#listForm");
      $f.attr("action", actionUrl);
      $f.attr("method", method); // "get" | "post"
      $f.trigger("submit");
    }

    // ===== 페이지 이동 (pageNavigator.jsp 호환) =====
    function fncGetList(currentPage){
      $("#currentPage").val(currentPage);
      $("input[name='page']").val(currentPage); // 호환용
      clearDynamicHidden();
      submitWith("./listPurchase", "post");
    }

 	// ===== DOM Ready =====
    $(function(){
      // 행 전체 클릭 → 상세 이동(GET)
      $(document).on("click", ".click-row", function(){
        var tranNo = $(this).data("tranno");
        if(!tranNo) return;
        clearDynamicHidden();
        addHidden("tranNo", tranNo);
        submitWith("./getPurchase", "get");
      });

      // 물건도착(배송중일 때만 노출) → 상태 변경(GET)
      $(document).on("click", ".mark-arrived", function(e){
        e.stopPropagation(); // 행 클릭 이벤트와 충돌 방지용(혹시 나중에 행 클릭을 붙일 경우 대비)
        var tranNo = $(this).data("tranno");
        clearDynamicHidden();
        addHidden("tranNo", tranNo);
        addHidden("tranCode", "DLV");
        submitWith("./updateTranCode", "get");
      });
    });
  </script>
</head>
<body>

<!-- [제출 폼] START -->
<form id="listForm" name="listForm">
  <input type="hidden" id="currentPage" name="currentPage" value="${resultPage.currentPage}" />
  <!-- 호환용 page 파라미터도 함께 유지 -->
  <input type="hidden" name="page" value="${resultPage.currentPage}" />
</form>
<!-- [제출 폼] END -->

<!-- [Title Bar] START -->
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
<!-- [Title Bar] END -->

<div style="width:98%; margin-left:10px;">

  <!-- [요약 정보] START -->
  <div style="margin:8px 0;">
    전체 <strong>${resultPage.totalCount}</strong> 건수, 현재 <strong>${resultPage.currentPage}</strong> 페이지
  </div>
  <!-- [요약 정보] END -->

  <!-- [목록 테이블] START -->
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
      <th class="ct_list_b" width="100">구매수량</th>
      <th class="ct_list_b" width="1"></th>
      <th class="ct_list_b" width="220">배송현황</th>
      <th class="ct_list_b" width="1"></th>
      <th class="ct_list_b" width="120">정보수정</th>
    </tr>

    <c:forEach var="p" items="${list}">
      <c:set var="code" value="${p.tranCode}" />
      <!-- ★ 여기: 행 전체가 클릭 대상이 되도록 클래스/데이터 부여 -->
      <tr class="ct_list_pop click-row" data-tranno="${p.tranNo}" style="cursor:pointer;">
        <!-- 주문번호: a/span 제거, 그냥 텍스트로 놔둬도 행 클릭으로 이동 -->
        <td align="center">${p.tranNo}</td>
        <td></td>
        <td align="center">${p.buyer.userId}</td>
        <td></td>
        <td align="left">${p.receiverName}</td>
        <td></td>
        <td align="center">${p.receiverPhone}</td>
        <td></td>
        <td align="center">${p.sellQuantity} 개</td>
        <td></td>
        
        <!-- 배송현황 -->
        <td align="left">
          <c:choose>
            <c:when test="${code eq '4' or code eq 'DLV'}">현재 배송완료 상태 입니다.</c:when>
            <c:when test="${code eq '3' or code eq 'SHP'}">현재 배송중 상태 입니다.</c:when>
            <c:when test="${code eq '2' or code eq 'BEF'}">현재 배송전 상태 입니다.</c:when>
            <c:otherwise>-</c:otherwise>
          </c:choose>
        </td>

        <td></td>

        <!-- 정보수정: 배송중일 때만 '물건도착' 노출 -->
        <td align="center">
          <c:choose>
            <c:when test="${code eq '3' or code eq 'SHP'}">
              <span class="mark-arrived" data-tranno="${p.tranNo}" style="cursor:pointer; text-decoration:underline;">물건도착</span>
            </c:when>
            <c:otherwise>-</c:otherwise>
          </c:choose>
        </td>
      </tr>
      <tr><td colspan="13" class="dot"></td></tr>
    </c:forEach>
  </table>
  <!-- [목록 테이블] END -->

  <!-- PageNavigation Start... -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
    <tr>
      <td align="center">
        <!-- currentPage hidden은 상단에 이미 존재 -->
        <jsp:include page="../common/pageNavigator.jsp"/>
      </td>
    </tr>
  </table>
  <!-- PageNavigation End... -->

</div>
</body>
</html>