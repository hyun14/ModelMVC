<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>회원 정보 수정</title>
	<link rel="stylesheet" href="/css/admin.css" type="text/css">

	<script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
	<script type="text/javascript">
		// 전화번호 hidden 합성
		function buildPhone() {
			var p1 = $("select[name='phone1']").val();
			var p2 = $.trim($("input[name='phone2']").val());
			var p3 = $.trim($("input[name='phone3']").val());
			return (p2 && p3) ? (p1 + "-" + p2 + "-" + p3) : "";
		}

		// 이메일 간단 검증
		function isValidEmail(email) {
			if (!email) return true; // 필수 아님 가정
			return email.indexOf('@') > 0 && email.indexOf('.') > email.indexOf('@') + 1;
		}

		// 공용 제출 함수 (검색조건/hidden은 폼에 이미 포함되어 함께 전송됨)
		function submitTo(actionUrl, method) {
			var $f = $("form[name='detailForm']");
			$f.attr("action", actionUrl);
			$f.attr("method", method || "post");
			$f.submit();
		}

		// 수정 처리
		function fncUpdateUser() {
			var name = $.trim($("input[name='userName']").val());
			if (!name) {
				alert("이름은 반드시 입력하셔야 합니다.");
				$("input[name='userName']").focus();
				return;
			}
			var email = $.trim($("input[name='email']").val());
			if (!isValidEmail(email)) {
				alert("이메일 형식이 아닙니다.");
				$("input[name='email']").focus();
				return;
			}
			$("input:hidden[name='phone']").val(buildPhone());

			// 수정은 POST /user/updateUser 로, 검색조건 hidden 함께 전송
			submitTo("/user/updateUser", "post");
		}

		$(function () {
			// 초기 포커스
			$("input[name='userName']").focus();

			// 휴대폰 앞자리 바꾸면 다음 칸 포커스
			$("select[name='phone1']").on("change", function () {
				$("input[name='phone2']").focus();
			});

			// 이메일 변경시 즉석 검증
			$("input[name='email']").on("change", function () {
				var email = $.trim($(this).val());
				if (!isValidEmail(email)) {
					alert("이메일 형식이 아닙니다.");
					$(this).focus();
				}
			});

			// "수정" 클릭
			$("td.ct_btn01:contains('수정')").on("click", function () {
				fncUpdateUser();
			});

			// "취소" 클릭 → 상세 화면으로 이동(GET /user/getUser)
			// userId 및 검색조건 hidden 들이 폼에 있으므로 그대로 전달됨
			$("td.ct_btn01:contains('취소')").on("click", function () {
				submitTo("/user/getUser", "get");
			});
		});
	</script>
</head>

<body bgcolor="#ffffff" text="#000000">

<form name="detailForm">
	<!-- 상세/수정 공통 파라미터 -->
	<input type="hidden" name="userId" value="${user.userId}">

	<!-- 검색조건 유지용 hidden (수정/취소 둘 다 함께 전송됨) -->
	<input type="hidden" name="currentPage" value="${search.currentPage}">
	<input type="hidden" name="pageSize" value="${search.pageSize}">
	<c:if test="${not empty search.searchCondition}">
		<input type="hidden" name="searchCondition" value="<c:out value='${search.searchCondition}'/>">
	</c:if>
	<c:if test="${not empty search.searchKeyword}">
		<input type="hidden" name="searchKeyword" value="<c:out value='${search.searchKeyword}'/>">
	</c:if>

	<table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="15" height="37"><img src="/images/ct_ttl_img01.gif" width="15" height="37"/></td>
			<td background="/images/ct_ttl_img02.gif" width="100%" style="padding-left:10px;">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td width="93%" class="ct_ttl01">회원정보수정</td>
						<td width="20%" align="right">&nbsp;</td>
					</tr>
				</table>
			</td>
			<td width="12" height="37"><img src="/images/ct_ttl_img03.gif" width="12" height="37"/></td>
		</tr>
	</table>

	<table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:13px;">
		<tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
		<tr>
			<td width="104" class="ct_write">아이디 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" /></td>
			<td bgcolor="D6D6D6" width="1"></td>
			<td class="ct_write01">${user.userId}</td>
		</tr>
		<tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

		<tr>
			<td width="104" class="ct_write">이름 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" /></td>
			<td bgcolor="D6D6D6" width="1"></td>
			<td class="ct_write01">
				<input type="text" name="userName" value="${user.userName}" class="ct_input_g" style="width:100px; height:19px" maxlength="50">
			</td>
		</tr>
		<tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

		<tr>
			<td width="104" class="ct_write">주소</td>
			<td bgcolor="D6D6D6" width="1"></td>
			<td class="ct_write01">
				<input type="text" name="addr" value="${user.addr}" class="ct_input_g" style="width:370px; height:19px" maxlength="100">
			</td>
		</tr>
		<tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

		<tr>
			<td width="104" class="ct_write">휴대전화번호</td>
			<td bgcolor="D6D6D6" width="1"></td>
			<td class="ct_write01">
				<select name="phone1" class="ct_input_g" style="width:50px; height:25px">
					<option value="010" ${ ! empty user.phone1 && user.phone1 == "010" ? "selected" : "" }>010</option>
					<option value="011" ${ ! empty user.phone1 && user.phone1 == "011" ? "selected" : "" }>011</option>
					<option value="016" ${ ! empty user.phone1 && user.phone1 == "016" ? "selected" : "" }>016</option>
					<option value="018" ${ ! empty user.phone1 && user.phone1 == "018" ? "selected" : "" }>018</option>
					<option value="019" ${ ! empty user.phone1 && user.phone1 == "019" ? "selected" : "" }>019</option>
				</select>
				<input type="text" name="phone2" value="${ ! empty user.phone2 ? user.phone2 : ''}" class="ct_input_g" style="width:100px; height:19px" maxlength="9"> -
				<input type="text" name="phone3" value="${ ! empty user.phone3 ? user.phone3 : ''}" class="ct_input_g" style="width:100px; height:19px" maxlength="9">
				<input type="hidden" name="phone" class="ct_input_g">
			</td>
		</tr>

		<tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

		<tr>
			<td width="104" class="ct_write">이메일</td>
			<td bgcolor="D6D6D6" width="1"></td>
			<td class="ct_write01">
				<input type="text" name="email" value="${user.email}" class="ct_input_g" style="width:100px; height:19px">
			</td>
		</tr>
		<tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
	</table>

	<table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
		<tr>
			<td width="53%"></td>
			<td align="right">
				<table border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td width="17" height="23"><img src="/images/ct_btnbg01.gif" width="17" height="23" /></td>
						<td background="/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">수정</td>
						<td width="14" height="23"><img src="/images/ct_btnbg03.gif" width="14" height="23" /></td>

						<td width="30"></td>

						<td width="17" height="23"><img src="/images/ct_btnbg01.gif" width="17" height="23" /></td>
						<td background="/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">취소</td>
						<td width="14" height="23"><img src="/images/ct_btnbg03.gif" width="14" height="23" /></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</form>

</body>
</html>
