<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
<head>
<title>상품등록 확인</title>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/css/admin.css" type="text/css">
</head>
<body bgcolor="#ffffff" text="#000000">

	<!-- 타이틀 바 -->
	<table width="100%" height="37" border="0" cellpadding="0"
		cellspacing="0">
		<tr>
			<td width="15" height="37"><img
				src="${pageContext.request.contextPath}/images/ct_ttl_img01.gif"
				width="15" height="37" /></td>
			<td
				background="${pageContext.request.contextPath}/images/ct_ttl_img02.gif"
				style="padding-left: 10px;">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td class="ct_ttl01">상품등록 확인</td>
						<td align="right">&nbsp;</td>
					</tr>
				</table>
			</td>
			<td width="12" height="37"><img
				src="${pageContext.request.contextPath}/images/ct_ttl_img03.gif"
				width="12" height="37" /></td>
		</tr>
	</table>

	<!-- 내용 테이블 -->
	<table width="100%" border="0" cellpadding="0" cellspacing="0"
		style="margin-top: 13px;">
		<tr>
			<td colspan="3" height="1" bgcolor="#D6D6D6"></td>
		</tr>
		<tr>
			<td width="104" class="ct_write">상품명</td>
			<td width="1" bgcolor="#D6D6D6"></td>
			<td class="ct_write01">${product.prodName}</td>
		</tr>
		<tr>
			<td colspan="3" height="1" bgcolor="#D6D6D6"></td>
		</tr>
		<tr>
			<td class="ct_write">상품상세정보</td>
			<td bgcolor="#D6D6D6"></td>
			<td class="ct_write01">${product.prodDetail}</td>
		</tr>
		<tr>
			<td colspan="3" height="1" bgcolor="#D6D6D6"></td>
		</tr>
		<tr>
			<td class="ct_write">제조일자</td>
			<td bgcolor="#D6D6D6"></td>
			<td class="ct_write01">${product.manuDate}</td>
		</tr>
		<tr>
			<td colspan="3" height="1" bgcolor="#D6D6D6"></td>
		</tr>
		<tr>
			<td class="ct_write">가격</td>
			<td bgcolor="#D6D6D6"></td>
			<td class="ct_write01">${product.price}원</td>
		</tr>
		<tr>
			<td colspan="3" height="1" bgcolor="#D6D6D6"></td>
		</tr>
		<tr>
			<td class="ct_write">상품이미지</td>
			<td bgcolor="#D6D6D6"></td>
			<td class="ct_write01">${product.fileName}</td>
		</tr>

		<tr>
			<td colspan="3" height="1" bgcolor="#D6D6D6"></td>
		</tr>
	</table>

	<!-- 버튼 -->
	<table width="100%" border="0" cellpadding="0" cellspacing="0"
		style="margin-top: 10px;">
		<tr>
			<td></td>
			<td align="right">
				<table border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td><a
							href="${pageContext.request.contextPath}/listProduct.do?menu=manage"
							class="ct_btn01" style="padding: 3px 10px;">확인</a></td>
						<td width="10"></td>
						<td><a
							href="${pageContext.request.contextPath}/product/addProductView.jsp"
							class="ct_btn01" style="padding: 3px 10px;">추가등록</a></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>

</body>
</html>