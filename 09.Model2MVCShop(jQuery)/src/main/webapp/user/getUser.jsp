<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<html>
<head>
  <title>회원정보조회</title>
  <link rel="stylesheet" href="/css/admin.css" type="text/css">

  <!-- jQuery : 링크 없이 버튼 클릭으로 페이지 이동/검색조건 유지 -->
  <script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
  <script type="text/javascript">
    /* 공용 함수 : 숨은 폼에 action을 지정하고, 필요 시 추가 파라미터를 붙여 제출 */
    function submitWithSearch(actionUrl, extraParams) {
      var $f = $("#navForm");
      $f.attr("action", actionUrl);

      // 직전에 동적으로 추가했던 hidden 제거(중복 방지)
      $f.find("input.dynamic-extra").remove();

      // 필요 시 추가 파라미터(userId 등) 주입
      if (extraParams) {
        $.each(extraParams, function (name, value) {
          $("<input>", {
            type: "hidden",
            name: name,
            value: value,
            class: "dynamic-extra"
          }).appendTo($f);
        });
      }

      $f.trigger("submit");
    }

    $(function () {
      /* 수정 버튼 : ./updateUserView 로 이동 + userId 추가 전달
         (검색조건은 숨은 폼에서 자동 전송) */
      $(".btn-edit").on("click", function () {
        submitWithSearch("./updateUserView", {
          userId: "${user.userId}"
        });
      });

      /* 목록 버튼 : ./listUser 로 이동 (추가 파라미터 없음, 검색조건만 전송) */
      $(".btn-list").on("click", function () {
        submitWithSearch("./listUser");
      });
    });
  </script>
</head>

<body bgcolor="#ffffff" text="#000000">

<!-- [검색조건 유지용 숨은 폼] : currentPage/pageSize/조건/키워드 보관 -->
<form id="navForm" method="get">
  <input type="hidden" name="currentPage" value="${search.currentPage}" />
  <input type="hidden" name="pageSize" value="${search.pageSize}" />
  <c:if test="${not empty search.searchCondition}">
    <input type="hidden" name="searchCondition" value="<c:out value='${search.searchCondition}'/>" />
  </c:if>
  <c:if test="${not empty search.searchKeyword}">
    <input type="hidden" name="searchKeyword" value="<c:out value='${search.searchKeyword}'/>" />
  </c:if>
</form>

<!-- 상단 타이틀 영역 -->
<table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="15" height="37"><img src="/images/ct_ttl_img01.gif" width="15" height="37"></td>
    <td background="/images/ct_ttl_img02.gif" width="100%" style="padding-left:10px;">
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="93%" class="ct_ttl01">회원정보조회</td>
          <td width="20%" align="right">&nbsp;</td>
        </tr>
      </table>
    </td>
    <td width="12" height="37"><img src="/images/ct_ttl_img03.gif" width="12" height="37"/></td>
  </tr>
</table>

<!-- 본문 정보 테이블 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:13px;">
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  <tr>
    <td width="104" class="ct_write">아이디 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle"/></td>
    <td bgcolor="D6D6D6" width="1"></td>
    <td class="ct_write01">${user.userId}</td>
  </tr>
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

  <tr>
    <td width="104" class="ct_write">이름 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" /></td>
    <td bgcolor="D6D6D6" width="1"></td>
    <td class="ct_write01">${user.userName}</td>
  </tr>
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

  <tr>
    <td width="104" class="ct_write">주소</td>
    <td bgcolor="D6D6D6" width="1"></td>
    <td class="ct_write01">${user.addr}</td>
  </tr>
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

  <tr>
    <td width="104" class="ct_write">휴대전화번호</td>
    <td bgcolor="D6D6D6" width="1"></td>
    <td class="ct_write01">${ !empty user.phone ? user.phone : ''}</td>
  </tr>
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

  <tr>
    <td width="104" class="ct_write">이메일</td>
    <td bgcolor="D6D6D6" width="1"></td>
    <td class="ct_write01">${user.email}</td>
  </tr>
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

  <tr>
    <td width="104" class="ct_write">가입일자</td>
    <td bgcolor="D6D6D6" width="1"></td>
    <td class="ct_write01">${user.regDate}</td>
  </tr>
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
</table>

<!-- 하단 버튼 영역 : a 태그 제거, span + jQuery 로 이동 처리 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
  <tr>
    <td width="53%"></td>
    <td align="right">
      <table border="0" cellspacing="0" cellpadding="0">
        <tr>
          <!-- 수정 버튼 (updateUserView 로 이동) -->
          <td width="17" height="23"><img src="/images/ct_btnbg01.gif" width="17" height="23"></td>
          <td background="/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">
            <span class="btn-edit">수정</span>
          </td>
          <td width="14" height="23"><img src="/images/ct_btnbg03.gif" width="14" height="23"></td>

          <td width="30"></td>

          <!-- 목록 버튼 (관리자에게만 노출, listUser 로 이동) -->
          <c:if test="${sessionScope.loginUser.role == 'admin'}">
            <td width="17" height="23"><img src="/images/ct_btnbg01.gif" width="17" height="23"></td>
            <td background="/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">
              <span class="btn-list">목록</span>
            </td>
            <td width="14" height="23"><img src="/images/ct_btnbg03.gif" width="14" height="23"></td>
          </c:if>
        </tr>
      </table>
    </td>
  </tr>
</table>

</body>
</html>
