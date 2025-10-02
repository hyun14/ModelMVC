<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page pageEncoding="UTF-8" %>

<c:if test="${not empty loginError}">
  <script>
    // XSS 방지를 위해 JSTL fn:escapeXml 사용
    alert("${fn:escapeXml(loginError)}");
  </script>
</c:if>

<!DOCTYPE html>
<html>

<head>
	<meta charset="UTF-8">
	
	<title>로그인 화면</title>
	
	<link rel="stylesheet" href="/css/admin.css" type="text/css">
	
	<!-- CDN(Content Delivery Network) 호스트 사용 -->
	<script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
	<script type="text/javascript">

	  // 공통: 로그인 처리 함수 (클릭/엔터 모두 여기로 모음)
	  function doLogin() {
	    // 1) DOM 선택은 명시적으로
	    var $id = $("#userId");
	    var $pw = $("input[name='password']");

	    var id = $.trim($id.val());
	    var pw = $.trim($pw.val());

	    // 2) 간단한 유효성 검사
	    if (!id) {
	      alert('ID 를 입력하지 않으셨습니다.');
	      $id.focus();
	      return;
	    }
	    if (!pw) {
	      alert('패스워드를 입력하지 않으셨습니다.');
	      $pw.focus();
	      return;
	    }

	    // 3) 폼 전송 (기존과 동일)
	    $("form")
	      .attr("method", "POST")
	      .attr("action", "/user/login")
	      .attr("target", "_parent")
	      .submit();
	  }

	  $(function () {
	    // 초기 포커스
	    $("#userId").focus();

	    // 로그인 버튼 클릭
	    $("img[src='/images/btn_login.gif']").on("click", function () {
	      doLogin();
	    });

	    // 비밀번호 입력창에서 엔터 입력 시 로그인
	    $("input[name='password']").on("keydown", function (e) {
	      // keyCode: 13, which: 13 (jQuery 2.x 호환)
	      if (e.keyCode === 13 || e.which === 13) {
	        e.preventDefault(); // 폼의 기본 엔터 제출 방지
	        doLogin();          // 공통 로그인 함수 호출
	      }
	    });
	  });

	  // 회원가입 화면 이동 (기존 동작 유지)
	  $(function () {
	    $("img[src='/images/btn_add.gif']").on("click", function () {
	      self.location = "/user/addUser";
	    });
	  });
		
	</script>		
	
</head>

<body bgcolor="#ffffff" text="#000000" >

<form>

<div align="center" >

<TABLE WITH="100%" HEIGHT="100%" BORDER="0" CELLPADDING="0" CELLSPACING="0">
<TR>
<TD ALIGN="CENTER" VALIGN="MIDDLE">

<table width="650" height="390" border="5" cellpadding="0" cellspacing="0" bordercolor="#D6CDB7">
  <tr> 
    <td width="10" height="5" align="left" valign="top" bordercolor="#D6CDB7">
    	<table width="650" height="390" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td width="305">
            <img src="/images/logo-spring.png" width="305" height="390"/>
          </td>
          <td width="345" align="left" valign="top" background="/images/login02.gif">
          	<table width="100%" height="220" border="0" cellpadding="0" cellspacing="0">
              <tr> 
                <td width="30" height="100">&nbsp;</td>
                <td width="100" height="100">&nbsp;</td>
                <td height="100">&nbsp;</td>
                <td width="20" height="100">&nbsp;</td>
              </tr>
              <tr> 
                <td width="30" height="50">&nbsp;</td>
                <td width="100" height="50">
                	<img src="/images/text_login.gif" width="91" height="32"/>
                </td>
                <td height="50">&nbsp;</td>
                <td width="20" height="50">&nbsp;</td>
              </tr>
              <tr> 
                <td width="200" height="50" colspan="4"></td>
              </tr>              
              <tr> 
                <td width="30" height="30">&nbsp;</td>
                <td width="100" height="30">
                	<img src="/images/text_id.gif" width="100" height="30"/>
                </td>
                <td height="30">
                  <input 	type="text" name="userId" value="${userId}"   id="userId"  class="ct_input_g" 
                  				style="width:180px; height:19px"  maxLength='50'/>          
          		</td>
                <td width="20" height="30">&nbsp;</td>
              </tr>
              <tr> 
                <td width="30" height="30">&nbsp;</td>
                <td width="100" height="30">
                	<img src="/images/text_pas.gif" width="100" height="30"/>
                </td>
                <td height="30">                    
                    <input 	type="password" name="password" class="ct_input_g" 
                    				style="width:180px; height:19px"  maxLength="50" />
                </td>
                <td width="20" height="30">&nbsp;</td>
              </tr>
              <tr> 
                <td width="30" height="20">&nbsp;</td>
                <td width="100" height="20">&nbsp;</td>
                <td height="20" align="center">
   				    <table width="136" height="20" border="0" cellpadding="0" cellspacing="0">
                       <tr> 
                         <td width="56">
                         		<img src="/images/btn_login.gif" width="56" height="20" border="0"/>
                         </td>
                         <td width="10">&nbsp;</td>
                         <td width="70">
                       			<img src="/images/btn_add.gif" width="70" height="20" border="0">
                         </td>
                       </tr>
                     </table>
                 </td>
                 <td width="20" height="20">&nbsp;</td>
                </tr>
              </table>
            </td>
      	</tr>                            
      </table>
      </td>
  </tr>
</table>
</TD>
</TR>
</TABLE>

</div>

</form>

</body>

</html>