<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<html>
<head>
  <title>상품등록 확인</title>
  <link rel="stylesheet" href="${ctx}/css/admin.css" type="text/css">

  <script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
  <style>
    .btn-like { cursor:pointer; color:#0066cc; }
    .btn-like:hover { text-decoration: underline; }
  </style>
  <script type="text/javascript">
    function clearDynamicHidden(){ $("#confirmForm").find("input.dynamic-extra").remove(); }
    function addHidden(name, val){
      $("<input>", {type:"hidden", name:name, value:val, class:"dynamic-extra"}).appendTo("#confirmForm");
    }
    function submitWith(actionUrl, method){
      var $f = $("#confirmForm");
      $f.attr("action", actionUrl);
      $f.attr("method", method);
      $f.trigger("submit");
    }

    $(function(){
      // 확인: 관리 목록으로 이동 (GET)
      $(".btn-ok").on("click", function(){
        clearDynamicHidden();
        submitWith("./listProductEntry", "get");
      });

      // 추가등록: 등록 화면으로 이동 (GET)
      $(".btn-add").on("click", function(){
        clearDynamicHidden();
        submitWith("${ctx}/product/addProductView.jsp", "get");
      });
    });
  </script>
</head>
<body bgcolor="#ffffff" text="#000000">

<form id="confirmForm" name="confirmForm">
  <!-- 관리 모드로 복귀 기준만 유지 -->
  <input type="hidden" name="menu" value="${not empty param.menu ? param.menu : 'manage'}" />

  <!-- 타이틀 바 -->
  <table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="15" height="37"><img src="${ctx}/images/ct_ttl_img01.gif" width="15" height="37" /></td>
      <td background="${ctx}/images/ct_ttl_img02.gif" style="padding-left:10px;">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td class="ct_ttl01">상품등록 확인</td>
            <td align="right">&nbsp;</td>
          </tr>
        </table>
      </td>
      <td width="12" height="37"><img src="${ctx}/images/ct_ttl_img03.gif" width="12" height="37" /></td>
    </tr>
  </table>

  <!-- 내용 테이블 -->
  <table width="100%" border="0" cellpadding="0" cellspacing="0" style="margin-top:13px;">
    <tr><td colspan="3" height="1" bgcolor="#D6D6D6"></td></tr>
    <tr>
      <td width="104" class="ct_write">상품명</td>
      <td width="1" bgcolor="#D6D6D6"></td>
      <td class="ct_write01">${product.prodName}</td>
    </tr>
    <tr><td colspan="3" height="1" bgcolor="#D6D6D6"></td></tr>
    <tr>
      <td class="ct_write">상품상세정보</td>
      <td bgcolor="#D6D6D6"></td>
      <td class="ct_write01">${product.prodDetail}</td>
    </tr>
    <tr><td colspan="3" height="1" bgcolor="#D6D6D6"></td></tr>
    <tr>
      <td class="ct_write">제조일자</td>
      <td bgcolor="#D6D6D6"></td>
      <td class="ct_write01">${product.manuDate}</td>
    </tr>
    <tr><td colspan="3" height="1" bgcolor="#D6D6D6"></td></tr>
    <tr>
      <td class="ct_write">가격</td>
      <td bgcolor="#D6D6D6"></td>
      <td class="ct_write01">${product.price}원</td>
    </tr>
    <tr><td colspan="3" height="1" bgcolor="#D6D6D6"></td></tr>

    <!-- 이미지 미리보기 -->
    <tr>
      <td class="ct_write">상품이미지</td>
      <td bgcolor="#D6D6D6"></td>
      <td class="ct_write01">
        <div style="margin-top:8px;">
          <c:choose>
            <c:when test="${not empty product.images}">
              <%-- c:forEach를 사용해 이미지 목록을 반복 출력 --%>
              <c:forEach var="image" items="${product.images}">
                <img src="${ctx}${image.imagePath}" alt="상품 이미지"
                     style="max-width:240px; height:auto; border:1px solid #e6e9ef; border-radius:8px; margin-bottom: 5px;" />
              </c:forEach>
            </c:when>
            <c:otherwise>
              <div style="color:#666666;">등록된 이미지가 없습니다.</div>
            </c:otherwise>
          </c:choose>
        </div>
      </td>
    </tr>

    <tr><td colspan="3" height="1" bgcolor="#D6D6D6"></td></tr>
  </table>

  <!-- 버튼 영역 -->
  <table width="100%" border="0" cellpadding="0" cellspacing="0" style="margin-top:10px;">
    <tr>
      <td></td>
      <td align="right">
        <table border="0" cellpadding="0" cellspacing="0">
          <tr>
            <td>
              <span class="ct_btn01 btn-like btn-ok" style="display:inline-block; padding:3px 10px;">확인</span>
            </td>
            <td width="10"></td>
            <td>
              <span class="ct_btn01 btn-like btn-add" style="display:inline-block; padding:3px 10px;">추가등록</span>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</form>

</body>
</html>
