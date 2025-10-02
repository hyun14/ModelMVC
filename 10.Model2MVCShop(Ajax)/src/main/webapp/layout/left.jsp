<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page pageEncoding="UTF-8" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 컨텍스트/세션 사용자/권한 JSTL 변수로 세팅 -->
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="vo"  value="${sessionScope.loginUser}" />
<c:set var="role" value="${empty vo ? '' : vo.role}" />

<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Model2 MVC Shop</title>

	<link href="${ctx}/css/left.css" rel="stylesheet" type="text/css">

	<!-- jQuery -->
	<script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>

	<script type="text/javascript">
		// 최근 본 상품 팝업 (기존 로직 유지)
		function history(){
			popWin = window.open("/history.jsp",
								"popWin",
								"left=300, top=200, width=300, height=200, marginwidth=0, marginheight=0, scrollbars=no, scrolling=no, menubar=no, resizable=no");
		}

		// jQuery로 모든 액션 처리
		$(function () {
			// 공용 클릭 핸들러: data-url 이 있으면 우측 프레임으로 이동, data-action이 history면 팝업
			$(document).on("click", ".link-item", function () {
				var url = $(this).data("url");
				var action = $(this).data("action");

				if (action === "history") {
					history();
					return;
				}

				if (url) {
					// 우측 프레임으로 이동
					$(window.parent.frames["rightFrame"].document.location).attr("href", url);
				}
			});
		});
	</script>
</head>

<body background="/images/left/imgLeftBg.gif" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

<table width="159" border="0" cellspacing="0" cellpadding="0">

  <!-- menu 01 line -->
  <tr>
    <td valign="top">
      <table border="0" cellspacing="0" cellpadding="0" width="159">
        <tr>
          <c:if test="${ !empty loginUser }">
            <tr>
              <td class="Depth03">
                <!-- 개인정보조회: a 태그 제거, jQuery로 이동 -->
                <span class="link-item"
                      data-url="${ctx}/user/getUser?userId=${loginUser.userId}">개인정보조회</span>
              </td>
            </tr>
          </c:if>

          <c:if test="${loginUser.role == 'admin'}">
            <tr>
              <td class="Depth03">
                <!-- 회원정보조회: a 태그 제거, jQuery로 이동 -->
                <span class="link-item"
                      data-url="${ctx}/user/listUser">회원정보조회</span>
              </td>
            </tr>
          </c:if>

          <tr>
            <td class="DepthEnd">&nbsp;</td>
          </tr>
        </tr>
      </table>
    </td>
  </tr>

  <!-- menu 02 line (admin 전용) -->
  <c:if test="${loginUser.role == 'admin'}">
    <tr>
      <td valign="top">
        <table border="0" cellspacing="0" cellpadding="0" width="159">
          <tr>
            <td class="Depth03">
              <!-- 판매상품등록 -->
              <span class="link-item"
                    data-url="${ctx}/product/addProductView.jsp">판매상품등록</span>
            </td>
          </tr>
          <tr>
            <td class="Depth03">
              <!-- 판매상품관리 -->
              <span class="link-item"
                    data-url="${ctx}/product/listProduct?menu=manage">판매상품관리</span>
            </td>
          </tr>
          <tr>
            <td class="DepthEnd">&nbsp;</td>
          </tr>
        </table>
      </td>
    </tr>
  </c:if>

  <!-- menu 03 line -->
  <tr>
    <td valign="top">
      <table border="0" cellspacing="0" cellpadding="0" width="159">

        <c:if test="${ !empty loginUser && loginUser.role == 'user'}">
          <tr>
            <td class="Depth03">
              <!-- 상품검색 -->
              <span class="link-item"
                    data-url="${ctx}/product/listProductByUser?menu=search">상 품 검 색</span>
            </td>
          </tr>

          <tr>
            <td class="Depth03">
              <!-- 구매이력조회 -->
              <span class="link-item"
                    data-url="${ctx}/purchase/listPurchase">구매이력조회</span>
            </td>
          </tr>
        </c:if>

        <tr>
          <td class="DepthEnd">&nbsp;</td>
        </tr>

        <tr>
          <td class="Depth03">
            <!-- 최근 본 상품 팝업: a/href 제거, jQuery로 history() 호출 -->
            <span class="link-item" data-action="history">최근 본 상품</span>
          </td>
        </tr>
      </table>
    </td>
  </tr>

</table>

</body>
</html>
