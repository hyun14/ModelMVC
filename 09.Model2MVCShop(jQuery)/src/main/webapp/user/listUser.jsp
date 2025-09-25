<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<html>
<head>
<title>회원 목록 조회</title>

<link rel="stylesheet" href="/css/admin.css" type="text/css">
<link rel="stylesheet" href="/css/rowClick.css" type="text/css" />

<!-- jQuery 추가 -->
<script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>

<script type="text/javascript">
  // 페이지 네비게이션용 함수 : 네비게이터에서 호출 가능
  function fncGetList(currentPage) {
    // 현재 페이지 번호 세팅
    document.getElementById("currentPage").value = currentPage;
    // 목록 재조회는 POST로 유지 (서버 기존 컨트롤러 로직 보존)
    var f = document.detailForm;
    f.method = "post";
    f.action = "./listUser";
    f.submit();
  }

  // 공용 유틸 : 동적으로 추가했던 hidden 제거
  function removeDynamicHidden() {
    $("#detailForm").find("input.dynamic-extra").remove();
  }

  // 공용 유틸 : name=value 형태로 hidden 추가
  function appendHidden(name, value) {
    $("<input>", {
      type : "hidden",
      name : name,
      value: value,
      class: "dynamic-extra" // 동적 추가 표시
    }).appendTo("#detailForm");
  }

  // 공용 제출
  function submitWith(actionUrl, method){
    var $f = $("#detailForm");
    $f.attr("action", actionUrl);
    $f.attr("method", method); // get | post
    $f.trigger("submit");
  }

  // 문서 로드 후 이벤트 바인딩
  $(function(){

    // 검색 버튼 : currentPage=1, POST 로 ./listUser
    $(document).on("click", ".btn-search", function(){
      removeDynamicHidden();
      $("#currentPage").val("1");
      submitWith("./listUser", "post");
    });

    // 행 전체 클릭 : GET 으로 ./getUser + userId 전달
    $(document).on("click", ".click-row", function(){
      var userId = $(this).data("userid");
      if(!userId){ return; }

      removeDynamicHidden();
      appendHidden("userId", userId);
      submitWith("./getUser", "get");
    });
  });
</script>

</head>

<body bgcolor="#ffffff" text="#000000">

<div style="width:98%; margin-left:10px;">

<form id="detailForm" name="detailForm" action="./listUser" method="post">
  <!-- 페이지 네비에서 사용할 hidden -->
  <input type="hidden" id="currentPage" name="currentPage" value="${search.currentPage}" />
  <!-- 필요 시 pageSize도 숨은값으로 유지(서버 기본값이 있다면 생략 가능) -->
  <input type="hidden" name="pageSize" value="${search.pageSize}" />

  <table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="15" height="37">
        <img src="/images/ct_ttl_img01.gif" width="15" height="37" />
      </td>
      <td background="/images/ct_ttl_img02.gif" width="100%" style="padding-left:10px;">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="93%" class="ct_ttl01">회원 목록조회</td>
          </tr>
        </table>
      </td>
      <td width="12" height="37">
        <img src="/images/ct_ttl_img03.gif" width="12" height="37"/>
      </td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
    <tr>
      <td align="right">
        <!-- 검색조건(셀렉트/인풋은 그대로 유지: 폼 제출 시 자동 포함) -->
        <select name="searchCondition" class="ct_input_g" style="width:80px">
          <option value="0"  ${ ! empty search.searchCondition && search.searchCondition==0 ? "selected" : "" }>회원ID</option>
          <option value="1"  ${ ! empty search.searchCondition && search.searchCondition==1 ? "selected" : "" }>회원명</option>
        </select>

        <input type="text" name="searchKeyword"
          value="${! empty search.searchKeyword ? search.searchKeyword : ""}"
          class="ct_input_g" style="width:200px; height:20px">
      </td>

      <td align="right" width="70">
        <table border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="17" height="23"><img src="/images/ct_btnbg01.gif" width="17" height="23"></td>
            <td background="/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">
              <!-- a 태그 제거, jQuery로 동작 -->
              <span class="btn-search" style="cursor:pointer;">검색</span>
            </td>
            <td width="14" height="23"><img src="/images/ct_btnbg03.gif" width="14" height="23"></td>
          </tr>
        </table>
      </td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
    <tr>
      <td colspan="11">
        전체 ${resultPage.totalCount} 건수, 현재 ${resultPage.currentPage} 페이지
      </td>
    </tr>
    <tr>
      <td class="ct_list_b" width="100">No</td>
      <td class="ct_line02"></td>
      <td class="ct_list_b" width="150">회원ID</td>
      <td class="ct_line02"></td>
      <td class="ct_list_b" width="150">회원명</td>
      <td class="ct_line02"></td>
      <td class="ct_list_b">이메일</td>
    </tr>
    <tr>
      <td colspan="11" bgcolor="808285" height="1"></td>
    </tr>

    <c:set var="i" value="0" />
    <c:forEach var="user" items="${list}">
      <c:set var="i" value="${i + 1}" />
      <!-- ★ 행 전체 클릭 가능 -->
      <tr class="ct_list_pop click-row" data-userid="${user.userId}" style="cursor:pointer;">
        <td align="center">${i}</td>
        <td></td>
        <td align="left">${user.userId}</td>
        <td></td>
        <td align="left">${user.userName}</td>
        <td></td>
        <td align="left">${user.email}</td>
      </tr>
      <tr>
        <td colspan="11" bgcolor="D6D7D6" height="1"></td>
      </tr>
    </c:forEach>
  </table>

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

</form>
</div>

</body>
</html>
