<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.model2.mvc.service.domain.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- =====================[ 상단 변수 세팅 (EL/JSTL) ]===================== -->
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="mode" value="${requestScope.mode}" />
<c:set var="isUpdate" value="${mode == 'update'}" />
<c:set var="p" value="${requestScope.product}" />
<c:choose>
  <c:when test="${isUpdate}">
    <c:set var="title" value="상품수정" />
    <c:set var="actionPath" value="./updateProduct" />
  </c:when>
  <c:otherwise>
    <c:set var="title" value="상품등록" />
    <c:set var="actionPath" value="./addProduct" />
  </c:otherwise>
</c:choose>
<!-- ===================================================================== -->

<html>
<head>
  <title>${title}</title>
  <link rel="stylesheet" href="${ctx}/css/admin.css" type="text/css" />
  <script type="text/javascript" src="${ctx}/javascript/calendar.js"></script>

  <script type="text/javascript">
  // 유효성 검사 + 제출
  function fncSubmit(){
    var f = document.detailForm;
    var name = f.prodName.value.trim();
    var detail = f.prodDetail.value.trim();
    var manuDate = f.manuDate.value.trim();
    var price = f.price.value.trim();

    if(!name){
      alert("상품명은 반드시 입력하여야 합니다.");
      return;
    }
    if(!detail){
      alert("상품상세정보는 반드시 입력하여야 합니다.");
      return;
    }
    if(!manuDate){
      alert("제조일자는 반드시 입력하셔야 합니다.");
      return;
    }
    // manuDate → 8자리(YYYYMMDD)로 정규화
    manuDate = manuDate.replace(/-/g, "");
    if(!/^\d{8}$/.test(manuDate)){
      alert("제조일자는 YYYYMMDD 형식으로 입력하세요.");
      return;
    }
    f.manuDate.value = manuDate;

    if(!price || !/^\d+$/.test(price)){
      alert("가격은 숫자만 입력하세요.");
      return;
    }

    // 모드에 따라 액션 전환 (서버에서 미리 결정한 actionPath 사용)
    f.action = document.getElementById('actionPath').value;
    f.submit();
  }

  function resetData(){
    document.detailForm.reset();
  }
  </script>
</head>

<body bgcolor="#ffffff" text="#000000">

<form name="detailForm" method="post" enctype="multipart/form-data">
  <!-- actionPath 히든: JS에서 사용 -->
  <input type="hidden" id="actionPath" value="${actionPath}" />

  <c:if test="${isUpdate and not empty p}">
    <!-- 수정 시에는 prodNo 필수 -->
    <input type="hidden" name="prodNo" value="${p.prodNo}" />
  </c:if>

  <!-- 상단 타이틀 바 -->
  <table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="15" height="37">
        <img src="${ctx}/images/ct_ttl_img01.gif" width="15" height="37" />
      </td>
      <td background="${ctx}/images/ct_ttl_img02.gif" width="100%" style="padding-left: 10px;">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="93%" class="ct_ttl01">${title}</td>
            <td width="20%" align="right">&nbsp;</td>
          </tr>
        </table>
      </td>
      <td width="12" height="37">
        <img src="${ctx}/images/ct_ttl_img03.gif" width="12" height="37" />
      </td>
    </tr>
  </table>

  <!-- 입력 폼 -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top: 13px;">
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td width="104" class="ct_write">
        상품명 <img src="${ctx}/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" />
      </td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="105">
              <input type="text" name="prodName" class="ct_input_g"
                     style="width: 100px; height: 19px" maxlength="20"
                     value="${p.prodName}" />
            </td>
          </tr>
        </table>
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td width="104" class="ct_write">
        상품상세정보 <img src="${ctx}/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" />
      </td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="prodDetail" class="ct_input_g"
               style="width: 100px; height: 19px" maxlength="200"
               value="${p.prodDetail}" />
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td width="104" class="ct_write">
        제조일자 <img src="${ctx}/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" />
      </td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="manuDate" class="ct_input_g"
               style="width: 100px; height: 19px" maxlength="10"
               placeholder="YYYYMMDD"
               value="${p.manuDate}" />
        &nbsp;
        <img src="${ctx}/images/ct_icon_date.gif" width="15" height="15"
             onclick="show_calendar('document.detailForm.manuDate', document.detailForm.manuDate.value)" />
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td width="104" class="ct_write">
        가격 <img src="${ctx}/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" />
      </td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="price" class="ct_input_g"
               style="width: 100px; height: 19px" maxlength="10"
               value="${p.price}" />&nbsp;원
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td width="104" class="ct_write">상품이미지</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="file" name="imageFile" accept="image/*" class="ct_input_g"
               style="width: 200px; height: 19px" maxlength="100"
               value="${p.fileName}" />
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  </table>

  <!-- 버튼 영역 -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top: 10px;">
    <tr>
      <td width="53%"></td>
      <td align="right">
        <table border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="17" height="23">
              <img src="${ctx}/images/ct_btnbg01.gif" width="17" height="23" />
            </td>
            <td background="${ctx}/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top: 3px;">
              <a href="javascript:fncSubmit();">
                <c:choose><c:when test="${isUpdate}">수정</c:when><c:otherwise>등록</c:otherwise></c:choose>
              </a>
            </td>
            <td width="14" height="23">
              <img src="${ctx}/images/ct_btnbg03.gif" width="14" height="23" />
            </td>
            <td width="30"></td>
            <td width="17" height="23">
              <img src="${ctx}/images/ct_btnbg01.gif" width="17" height="23" />
            </td>
            <td background="${ctx}/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top: 3px;">
			  <c:choose>
			    <c:when test="${isUpdate or isUpdate eq 'true' or param.isUpdate eq 'true'}">
			      <c:url var="manageUrl" value="./listProduct">
			        <c:param name="menu" value="manage"/>
			        <!-- 검색조건 함께 전달 -->
				  	<c:if test="${not empty search}">
					  <c:if test="${not empty search.searchCondition}">
					    <c:param name="searchCondition" value="${search.searchCondition}" />
					  </c:if>
				   	  <c:if test="${not empty search.searchKeyword}">
					    <c:param name="searchKeyword" value="${search.searchKeyword}" />
				      </c:if>
					
					  <!-- 페이지 정보: 서버가 어떤 이름을 읽든 대비 -->
					  <c:if test="${not empty search.currentPage}">
					    <c:param name="page"        value="${search.currentPage}" />
					    <c:param name="currentPage" value="${search.currentPage}" />
					  </c:if>
					  <c:if test="${not empty search.pageSize}">
					    <c:param name="pageSize" value="${search.pageSize}" />
					  </c:if>
				    </c:if>
			      </c:url>
			      <a href="${manageUrl}">취소</a>
			    </c:when>
			    <c:otherwise>
			      <a href="javascript:resetData();">취소</a>
			    </c:otherwise>
			  </c:choose>
			</td>
            <td width="14" height="23">
              <img src="${ctx}/images/ct_btnbg03.gif" width="14" height="23" />
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</form>

</body>
</html>
