<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="p"   value="${requestScope.purchase}" />
<c:set var="prod" value="${p.purchaseProd}" />

<!DOCTYPE html>
<html>
<head>
  <title>구매 상세정보</title>
  <link rel="stylesheet" href="${ctx}/css/admin.css" type="text/css" />
  <script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
  <style>
    .btn-like { cursor:pointer; color:#0066cc; }
    .btn-like:hover { text-decoration: underline; }
  </style>
  <script type="text/javascript">
    // 동적 hidden 관리 유틸
    function clearDynamicHidden(){ $("#purchaseDetailForm").find("input.dynamic-extra").remove(); }
    function addHidden(name, val){
      $("<input>", {type:"hidden", name:name, value:val, class:"dynamic-extra"})
        .appendTo("#purchaseDetailForm");
    }
    function submitWith(actionUrl, method){
      var $f = $("#purchaseDetailForm");
      $f.attr("action", actionUrl);
      $f.attr("method", method); // "get" | "post"
      $f.trigger("submit");
    }

    $(function(){
      // 잘못된 접근 → 목록
      $(document).on("click", ".btn-goto-list", function(){
        clearDynamicHidden();
        submitWith("./listPurchase", "get");
      });

      // 수정(배송예정일 때만 노출)
      $(document).on("click", ".btn-edit", function(){
        clearDynamicHidden();
        // tranNo는 기본 hidden에 있으니 그대로 전송
        submitWith("./updatePurchaseView", "get");
      });

      // 확인(목록으로)
      $(document).on("click", ".btn-ok", function(){
        clearDynamicHidden();
        submitWith("./listPurchase", "get");
      });
    });
  </script>
</head>
<body bgcolor="#ffffff" text="#000000">

<!-- 액션·검색조건 유지용 폼 -->
<form id="purchaseDetailForm" name="purchaseDetailForm">
  <!-- 키 값 -->
  <c:if test="${not empty p}">
    <input type="hidden" name="tranNo" value="${p.tranNo}" />
  </c:if>

  <!-- 검색조건/페이지 유지(파라미터나 search 객체가 있으면 가져옴) -->
  <c:if test="${not empty param.currentPage || (not empty search and not empty search.currentPage)}">
    <input type="hidden" name="currentPage" value="${not empty param.currentPage ? param.currentPage : search.currentPage}" />
    <input type="hidden" name="page"        value="${not empty param.currentPage ? param.currentPage : search.currentPage}" />
  </c:if>
  <c:if test="${not empty param.pageSize || (not empty search and not empty search.pageSize)}">
    <input type="hidden" name="pageSize" value="${not empty param.pageSize ? param.pageSize : search.pageSize}" />
  </c:if>
  <c:if test="${not empty param.searchCondition || (not empty search and not empty search.searchCondition)}">
    <input type="hidden" name="searchCondition" value="${not empty param.searchCondition ? param.searchCondition : search.searchCondition}" />
  </c:if>
  <c:if test="${not empty param.searchKeyword || (not empty search and not empty search.searchKeyword)}">
    <input type="hidden" name="searchKeyword" value="${not empty param.searchKeyword ? param.searchKeyword : search.searchKeyword}" />
  </c:if>

  <!-- [가드: 잘못된 접근] -->
  <c:if test="${empty p}">
    <div style="padding:16px;">
      잘못된 접근입니다.
      <span class="btn-like btn-goto-list">목록으로</span>
    </div>
  </c:if>

  <c:if test="${not empty p}">
    <!-- [타이틀 바] -->
    <table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="15" height="37"><img src="${ctx}/images/ct_ttl_img01.gif" width="15" height="37" /></td>
        <td background="${ctx}/images/ct_ttl_img02.gif" width="100%" style="padding-left:10px;">
          <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td width="93%" class="ct_ttl01">구매 상세정보</td>
              <td width="20%" align="right">&nbsp;</td>
            </tr>
          </table>
        </td>
        <td width="12" height="37"><img src="${ctx}/images/ct_ttl_img03.gif" width="12" height="37" /></td>
      </tr>
    </table>

    <div style="width:98%; margin-left:10px;">
      <!-- [상세 테이블] -->
      <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
        <tr><td colspan="2" bgcolor="#808285" height="1"></td></tr>

        <tr class="ct_list_pop">
          <td width="150" class="ct_list_b" align="center">주문번호</td>
          <td style="padding-left:10px;">${p.tranNo}</td>
        </tr>
        <tr><td colspan="2" bgcolor="#D6D7D6" height="1"></td></tr>

        <tr class="ct_list_pop">
          <td class="ct_list_b" align="center">물품번호</td>
          <td style="padding-left:10px;"><c:out value="${prod.prodNo}" default="0" /></td>
        </tr>
        <tr><td colspan="2" bgcolor="#D6D7D6" height="1"></td></tr>

        <tr class="ct_list_pop">
          <td class="ct_list_b" align="center">구매자아이디</td>
          <td style="padding-left:10px;">${p.buyer.userId}</td>
        </tr>
        <tr><td colspan="2" bgcolor="#D6D7D6" height="1"></td></tr>

        <tr class="ct_list_pop">
          <td class="ct_list_b" align="center">구매방법</td>
          <td style="padding-left:10px;">${p.paymentOptionLabel}</td>
        </tr>
        <tr><td colspan="2" bgcolor="#D6D7D6" height="1"></td></tr>

        <tr class="ct_list_pop">
          <td class="ct_list_b" align="center">구매자이름</td>
          <td style="padding-left:10px;">${p.receiverName}</td>
        </tr>
        <tr><td colspan="2" bgcolor="#D6D7D6" height="1"></td></tr>

        <tr class="ct_list_pop">
          <td class="ct_list_b" align="center">구매자연락처</td>
          <td style="padding-left:10px;">${p.receiverPhone}</td>
        </tr>
        <tr><td colspan="2" bgcolor="#D6D7D6" height="1"></td></tr>

        <tr class="ct_list_pop">
          <td class="ct_list_b" align="center">구매자주소</td>
          <td style="padding-left:10px;">${p.divyAddr}</td>
        </tr>
        <tr><td colspan="2" bgcolor="#D6D7D6" height="1"></td></tr>

        <tr class="ct_list_pop">
          <td class="ct_list_b" align="center">구매요청사항</td>
          <td style="padding-left:10px;">${p.divyRequest}</td>
        </tr>
        <tr><td colspan="2" bgcolor="#D6D7D6" height="1"></td></tr>

        <tr class="ct_list_pop">
          <td class="ct_list_b" align="center">배송희망일</td>
          <td style="padding-left:10px;">${p.divyDateDash}</td>
        </tr>
        <tr><td colspan="2" bgcolor="#D6D7D6" height="1"></td></tr>

        <tr class="ct_list_pop">
          <td class="ct_list_b" align="center">주문일</td>
          <td style="padding-left:10px;"><fmt:formatDate value="${p.orderDate}" pattern="yyyy-MM-dd" /></td>
        </tr>
        <tr><td colspan="2" bgcolor="#D6D7D6" height="1"></td></tr>

        <tr class="ct_list_pop">
          <td class="ct_list_b" align="center">배송현황</td>
          <td style="padding-left:10px;">${p.tranStatusLabel}</td>
        </tr>
        <tr><td colspan="2" bgcolor="#D6D7D6" height="1"></td></tr>
      </table>

      <!-- [버튼 영역] -->
      <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
        <tr>
          <td align="right">
            <!-- 수정: 배송예정(BEF)일 때만 노출 -->
            <c:if test="${p.tranCode eq 'BEF'}">
              <table border="0" cellspacing="0" cellpadding="0" style="display:inline-block; margin-right:5px;">
                <tr>
                  <td width="17" height="23"><img src="${ctx}/images/ct_btnbg01.gif" width="17" height="23" /></td>
                  <td background="${ctx}/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">
                    <span class="btn-like btn-edit">수정</span>
                  </td>
                  <td width="14" height="23"><img src="${ctx}/images/ct_btnbg03.gif" width="14" height="23" /></td>
                </tr>
              </table>
            </c:if>

            <!-- 확인 -->
            <table border="0" cellspacing="0" cellpadding="0" style="display:inline-block;">
              <tr>
                <td width="17" height="23"><img src="${ctx}/images/ct_btnbg01.gif" width="17" height="23" /></td>
                <td background="${ctx}/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">
                  <span class="btn-like btn-ok">확인</span>
                </td>
                <td width="14" height="23"><img src="${ctx}/images/ct_btnbg03.gif" width="14" height="23" /></td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
    </div>
  </c:if>
</form>

</body>
</html>
