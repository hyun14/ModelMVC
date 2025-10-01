<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html>
<head>
  <title>상품별 구매 이력 조회</title>
  <link rel="stylesheet" href="${ctx}/css/admin.css" type="text/css" />
  <script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
  <script type="text/javascript">
    $(function(){
      // '배송하기' 버튼 클릭 이벤트
      $(document).on("click", ".btn-ship", function(e){
        e.preventDefault();
        var tranNo = $(this).data("tranno");
        var form = $('<form action="${ctx}/purchase/updateTranCodeByProd" method="get"></form>');
        form.append('<input type="hidden" name="tranNo" value="' + tranNo + '" />');
        form.append('<input type="hidden" name="prodNo" value="${param.prodNo}" />'); // 현재 상품 번호 유지를 위해 추가
        $('body').append(form);
        form.submit();
      });
    });
  </script>
</head>
<body>
<div class="content">
  <table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="15" height="37"><img src="${ctx}/images/ct_ttl_img01.gif" width="15" height="37" /></td>
      <td background="${ctx}/images/ct_ttl_img02.gif" width="100%" style="padding-left:10px;">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="93%" class="ct_ttl01">상품별 구매 이력 (상품번호: ${param.prodNo})</td>
            <td width="20%" align="right">&nbsp;</td>
          </tr>
        </table>
      </td>
      <td width="12" height="37"><img src="${ctx}/images/ct_ttl_img03.gif" width="12" height="37" /></td>
    </tr>
  </table>

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
      <th class="ct_list_b" width="220">배송상태</th>
    </tr>

    <c:choose>
      <c:when test="${not empty orders}">
        <c:forEach var="p" items="${orders}">
          <tr class="ct_list_pop">
            <td align="center">${p.tranNo}</td>
            <td></td>
            <td align="center">${p.buyer.userId}</td>
            <td></td>
            <td align="left">${p.receiverName}</td>
            <td></td>
            <td align="center">${p.receiverPhone}</td>
            <td></td>
            <td align="center">
              <c:choose>
                <c:when test="${p.tranCode eq 'BEF'}">
                  <span class="btn-ship" data-tranno="${p.tranNo}" style="color:#0066cc; cursor:pointer; text-decoration:underline;">배송하기</span>
                </c:when>
                <c:when test="${p.tranCode eq 'SHP'}">배송중</c:when>
                <c:when test="${p.tranCode eq 'DLV'}">상품 도착</c:when>
                <c:otherwise>-</c:otherwise>
              </c:choose>
            </td>
          </tr>
          <tr><td colspan="9" class="dot"></td></tr>
        </c:forEach>
      </c:when>
      <c:otherwise>
        <tr>
          <td colspan="9" align="center" style="padding: 20px;">구매 이력이 없습니다.</td>
        </tr>
      </c:otherwise>
    </c:choose>
  </table>

  <div style="text-align: right; margin-top: 10px;">
      <a href="javascript:history.back()" style="text-decoration: none;">
          <img src="${ctx}/images/ct_btn_search.gif" alt="뒤로가기" style="cursor:pointer;">
      </a>
  </div>
</div>
</body>
</html>