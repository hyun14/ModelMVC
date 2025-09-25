<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- [상단 변수 세팅] START -->
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="p"   value="${requestScope.purchase}" />
<!-- input[type=date]는 빈 값이어야 오류가 없으므로 '-'는 공란 처리 -->
<c:choose>
  <c:when test="${not empty p.divyDateDash and p.divyDateDash ne '-'}">
    <c:set var="divyVal" value="${p.divyDateDash}" />
  </c:when>
  <c:otherwise>
    <c:set var="divyVal" value="" />
  </c:otherwise>
</c:choose>
<!-- [상단 변수 세팅] END -->

<!DOCTYPE html>
<html>
<head>
  <title>구매 정보 수정</title>
  <link rel="stylesheet" href="${ctx}/css/admin.css" type="text/css" />
  <script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
  <style>
    .btn-like { cursor:pointer; color:#0066cc; }
    .btn-like:hover { text-decoration: underline; }
  </style>
  <script type="text/javascript">
    // 동적 hidden 유틸
    function clearDynamicHidden(){ $("#updateForm").find("input.dynamic-extra").remove(); }
    function addHidden(name, val){
      $("<input>", {type:"hidden", name:name, value:val, class:"dynamic-extra"})
        .appendTo("#updateForm");
    }
    function submitWith(actionUrl, method){
      var $f = $("#updateForm");
      $f.attr("action", actionUrl);
      $f.attr("method", method); // "post" | "get"
      $f.trigger("submit");
    }

    $(function(){
      // 수정(저장) → /updatePurchase (POST)
      $(document).on("click", ".btn-save", function(){
        clearDynamicHidden();
        submitWith("./updatePurchase", "post");
      });

      // 취소(상세 복귀) → /getPurchase (GET)
      $(document).on("click", ".btn-cancel", function(){
        clearDynamicHidden();
        // tranNo는 기본 hidden으로 이미 존재, 검색조건 hidden들도 폼에 유지되어 같이 전송됨
        submitWith("./getPurchase", "get");
      });
    });
  </script>
</head>

<body bgcolor="#ffffff" text="#000000">

<!-- [타이틀 바] START -->
<table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="15" height="37"><img src="${ctx}/images/ct_ttl_img01.gif" width="15" height="37" /></td>
    <td background="${ctx}/images/ct_ttl_img02.gif" width="100%" style="padding-left: 10px;">
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="93%" class="ct_ttl01">구매 정보 수정</td>
          <td width="20%" align="right">&nbsp;</td>
        </tr>
      </table>
    </td>
    <td width="12" height="37"><img src="${ctx}/images/ct_ttl_img03.gif" width="12" height="37" /></td>
  </tr>
</table>
<!-- [타이틀 바] END -->

<div style="width: 98%; margin-left: 10px;">

  <!-- [수정 폼] START -->
  <!-- method/action 미지정: jQuery에서 지정 -->
  <form id="updateForm" name="updateForm">
    <input type="hidden" name="tranNo" value="${p.tranNo}" />

    <!-- 검색조건/페이지 유지 -->
    <c:if test="${not empty search or not empty param}">
      <c:set var="cp" value="${not empty param.currentPage ? param.currentPage : (not empty search.currentPage ? search.currentPage : '')}" />
      <c:if test="${not empty cp}">
        <input type="hidden" name="currentPage" value="${cp}" />
        <input type="hidden" name="page"        value="${cp}" />
      </c:if>
      <c:if test="${not empty param.pageSize or not empty search.pageSize}">
        <input type="hidden" name="pageSize" value="${not empty param.pageSize ? param.pageSize : search.pageSize}" />
      </c:if>
      <c:if test="${not empty param.searchCondition or not empty search.searchCondition}">
        <input type="hidden" name="searchCondition" value="${not empty param.searchCondition ? param.searchCondition : search.searchCondition}" />
      </c:if>
      <c:if test="${not empty param.searchKeyword or not empty search.searchKeyword}">
        <input type="hidden" name="searchKeyword" value="${not empty param.searchKeyword ? param.searchKeyword : search.searchKeyword}" />
      </c:if>
    </c:if>

    <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
      <tr><td colspan="2" bgcolor="#808285" height="1"></td></tr>

      <tr class="ct_list_pop">
        <td width="150" class="ct_list_b" align="center">구매자 아이디</td>
        <td style="padding-left:10px;">${p.buyer.userId}</td>
      </tr>
      <tr><td colspan="2" bgcolor="#D6D7D6" height="1"></td></tr>

      <tr class="ct_list_pop">
        <td class="ct_list_b" align="center">구매방법</td>
        <td style="padding: 5px 0 5px 10px;">
          <select name="paymentOption" class="ct_input_g" style="width:100px;">
            <option value="CSH" <c:if test="${p.paymentOption eq 'CSH'}">selected</c:if>>현금구매</option>
            <option value="CRD" <c:if test="${p.paymentOption eq 'CRD'}">selected</c:if>>카드결제</option>
          </select>
        </td>
      </tr>
      <tr><td colspan="2" bgcolor="#D6D7D6" height="1"></td></tr>

      <tr class="ct_list_pop">
        <td class="ct_list_b" align="center">구매자 이름</td>
        <td style="padding: 5px 0 5px 10px;">
          <input type="text" name="receiverName" class="ct_input_g" style="width:300px;" value="${p.receiverName}" />
        </td>
      </tr>
      <tr><td colspan="2" bgcolor="#D6D7D6" height="1"></td></tr>

      <tr class="ct_list_pop">
        <td class="ct_list_b" align="center">구매자 연락처</td>
        <td style="padding: 5px 0 5px 10px;">
          <input type="text" name="receiverPhone" class="ct_input_g" style="width:300px;" value="${p.receiverPhone}" />
        </td>
      </tr>
      <tr><td colspan="2" bgcolor="#D6D7D6" height="1"></td></tr>

      <tr class="ct_list_pop">
        <td class="ct_list_b" align="center">구매자 주소</td>
        <td style="padding: 5px 0 5px 10px;">
          <input type="text" name="divyAddr" class="ct_input_g" style="width:500px;" value="${p.divyAddr}" />
        </td>
      </tr>
      <tr><td colspan="2" bgcolor="#D6D7D6" height="1"></td></tr>

      <tr class="ct_list_pop">
        <td class="ct_list_b" align="center">구매요청사항</td>
        <td style="padding: 5px 0 5px 10px;">
          <input type="text" name="divyRequest" class="ct_input_g" style="width:500px;" value="${p.divyRequest}" />
        </td>
      </tr>
      <tr><td colspan="2" bgcolor="#D6D7D6" height="1"></td></tr>

      <tr class="ct_list_pop">
        <td class="ct_list_b" align="center">배송희망날짜</td>
        <td style="padding: 5px 0 5px 10px;">
          <input type="date" name="divyDate" class="ct_input_g" value="${divyVal}" />
        </td>
      </tr>
      <tr><td colspan="2" bgcolor="#D6D7D6" height="1"></td></tr>
    </table>
  </form>
  <!-- [수정 폼] END -->

  <!-- [버튼 영역] START -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
    <tr>
      <td align="right">
        <table border="0" cellspacing="0" cellpadding="0" style="display:inline-block; margin-right:5px;">
          <tr>
            <td width="17" height="23"><img src="${ctx}/images/ct_btnbg01.gif" width="17" height="23" /></td>
            <td background="${ctx}/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top: 3px;">
              <span class="btn-like btn-save">수정</span>
            </td>
            <td width="14" height="23"><img src="${ctx}/images/ct_btnbg03.gif" width="14" height="23" /></td>
          </tr>
        </table>

        <table border="0" cellspacing="0" cellpadding="0" style="display:inline-block;">
          <tr>
            <td width="17" height="23"><img src="${ctx}/images/ct_btnbg01.gif" width="17" height="23" /></td>
            <td background="${ctx}/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top: 3px;">
              <span class="btn-like btn-cancel">취소</span>
            </td>
            <td width="14" height="23"><img src="${ctx}/images/ct_btnbg03.gif" width="14" height="23" /></td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
  <!-- [버튼 영역] END -->

</div>

</body>
</html>
