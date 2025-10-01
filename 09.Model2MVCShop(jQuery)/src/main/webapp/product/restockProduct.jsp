<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html>
<head>
  <title>상품 재입고</title>
  <link rel="stylesheet" href="${ctx}/css/admin.css" type="text/css" />
  <script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
  <script>
    function validateAndSubmit() {
      var quantity = $("input[name='quantity']").val().trim();
      if (!quantity || !/^\d+$/.test(quantity) || parseInt(quantity) <= 0) {
        alert("재입고 수량은 1 이상의 숫자만 입력하세요.");
        $("input[name='quantity']").focus();
        return false;
      }
      $("#restockForm").submit();
    }

    $(function() {
      // 확인 버튼 클릭
      $(".btn-ok").on("click", function() {
        validateAndSubmit();
      });

      // 취소 버튼 클릭
      $(".btn-cancel").on("click", function() {
        history.back();
      });
    });
  </script>
</head>
<body bgcolor="#ffffff" text="#000000">

<form id="restockForm" name="restockForm" action="${ctx}/product/restock" method="post">
  <input type="hidden" name="prodNo" value="${param.prodNo}" />
  <input type="hidden" name="menu" value="manage" />

  <table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="15" height="37"><img src="${ctx}/images/ct_ttl_img01.gif" width="15" height="37" /></td>
      <td background="${ctx}/images/ct_ttl_img02.gif" width="100%" style="padding-left: 10px;">
        <span class="ct_ttl01">상품 재입고 (상품번호: ${param.prodNo})</span>
      </td>
      <td width="12" height="37"><img src="${ctx}/images/ct_ttl_img03.gif" width="12" height="37" /></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top: 13px;">
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
    <tr>
      <td width="104" class="ct_write">
        재입고 수량 <img src="${ctx}/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" />
      </td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="quantity" class="ct_input_g" style="width: 100px; height: 19px" maxlength="7" />
      </td>
    </tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  </table>

  <div style="text-align: right; margin-top: 10px; padding-right: 20px;">
    <span class="btn-ok" style="cursor:pointer; color:#0066cc; text-decoration: underline;">확인</span>
    &nbsp;&nbsp;
    <span class="btn-cancel" style="cursor:pointer; color:#0066cc; text-decoration: underline;">취소</span>
  </div>
</form>

</body>
</html>