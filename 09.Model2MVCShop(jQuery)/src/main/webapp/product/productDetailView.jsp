<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- [상단 변수 세팅] START -->
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="product" value="${requestScope.product}" />
<c:set var="user" value="${sessionScope.loginUser}" />
<c:set var="isAdmin" value="${not empty loginUser and loginUser.role == 'admin'}" />
<c:set var="menuVal" value="${not empty param.menu ? param.menu : menu}" />
<c:if test="${empty menuVal}">
  <c:set var="menuVal" value="search"/>
</c:if>

<!-- 제조일자 표시용(YYYYMMDD -> YYYY-MM-DD) -->
<c:choose>
  <c:when test="${not empty product.manuDate and fn:length(product.manuDate) == 8}">
    <c:set var="manuDateDisp" value="${fn:substring(product.manuDate,0,4)}-${fn:substring(product.manuDate,4,6)}-${fn:substring(product.manuDate,6,8)}" />
  </c:when>
  <c:otherwise>
    <c:set var="manuDateDisp" value="${product.manuDate}" />
  </c:otherwise>
</c:choose>

<!-- 등록일 표시용(Date -> yyyy-MM-dd) -->
<fmt:formatDate value="${product.regDate}" pattern="yyyy-MM-dd" var="regDateDisp" />

<!-- 상태 표시용 -->
<c:set var="code" value="${product.proTranCode}" />
<c:choose>
  <c:when test="${empty code}"><c:set var="statusDisp" value="판매중" /></c:when>
  <c:when test="${code == 'BEF'}"><c:set var="statusDisp" value="배송예정" /></c:when>
  <c:when test="${code == 'SHP'}"><c:set var="statusDisp" value="배송중" /></c:when>
  <c:when test="${code == 'DLV'}"><c:set var="statusDisp" value="배송완료" /></c:when>
  <c:otherwise><c:set var="statusDisp" value="${code}" /></c:otherwise>
</c:choose>
<!-- [상단 변수 세팅] END -->

<!DOCTYPE html>
<html>
<head>
  <title>상품상세보기</title>
  <link rel="stylesheet" href="${ctx}/css/admin.css" type="text/css" />
  <link rel="stylesheet" href="${ctx}/css/bnt-click.css" type="text/css" />
  
  <script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
  <script type="text/javascript">
    // 동적 hidden 관리
    function clearDynamicHidden(){ $("#detailForm").find("input.dynamic-extra").remove(); }
    function addHidden(name, val){
      $("<input>",{type:"hidden",name:name,value:val,class:"dynamic-extra"}).appendTo("#detailForm");
    }
    function submitWith(actionUrl, method){
      var $f = $("#detailForm");
      $f.attr("action", actionUrl);
      $f.attr("method", method); // "get" or "post"
      $f.trigger("submit");
    }

    $(function(){
      // 목록 버튼: listProductEntry 로 이동 (GET)
      $(".btn-list").on("click", function(){
        clearDynamicHidden();
        // 필요한 경우 추가 파라미터를 붙일 수 있음
        submitWith("./listProductEntry", "get");
      });

      // 구매 버튼(사용자에게만 보임): addPurchaseView 로 이동 (GET)
      $(".btn-buy").on("click", function(){
        clearDynamicHidden();
        // prodNo는 기본 hidden에 이미 존재하지만 안전하게 한번 더 세팅 가능
        // addHidden("prodNo", $("input[name='prodNo']").val());
        submitWith("${ctx}/purchase/addPurchaseView", "get");
      });
      
   	  // 수정(관리자 전용) → updateProductView 로 이동
      $(".btn-edit").on("click", function(){
        clearDynamicHidden();
        // 필요 시 menu를 명확히 관리모드로 덮어쓰기
        // addHidden("menu", "manage");
        submitWith("${ctx}/product/updateProductView", "get");
      });
   	  
   // [버튼 확장] 버튼 테이블 구조: [좌캡][가운데버튼(td.ct_btn01 .btn-like)][우캡]
   // 1) 가운데 td 클릭 시, 내부 .btn-like 클릭과 동일 처리
   $("td.ct_btn01").on("click", function(e){
     // 내부 span(.btn-like)의 클릭 이벤트를 트리거
     const $btn = $(this).find(".btn-like").first();
     if ($btn.length) {
       $btn.trigger("click");
     }
   });

   // 2) 좌/우 캡 td에도 클릭 핸들러 연결 (바로 옆 가운데 td로 위임)
   $("td.ct_btn01").each(function(){
     const $center = $(this);
     const $leftCap  = $center.prev("td").addClass("cap-left");
     const $rightCap = $center.next("td").addClass("cap-right");

     $leftCap.on("click", function(){
       $center.trigger("click");
     });
     $rightCap.on("click", function(){
       $center.trigger("click");
     });
   });

   // 3) 좌/우 캡 hover 시에도 가운데 td와 동일한 hover 느낌 주기(선택적)
   $("td.cap-left, td.cap-right").hover(
     function(){ $(this).siblings("td.ct_btn01").addClass("hover"); },
     function(){ $(this).siblings("td.ct_btn01").removeClass("hover"); }
   );

   
    });
  </script>
</head>
<body bgcolor="#ffffff" text="#000000">

<!-- 검색조건/페이지/키 유지 + 액션 전환용 폼 -->
<form id="detailForm" name="detailForm">
  <!-- 복귀 기준 -->
  <input type="hidden" name="menu" value="${menuVal}"/>
  <!-- 상품키 -->
  <input type="hidden" name="prodNo" value="${product.prodNo}"/>
  <!-- 상세에서 다른 화면으로 갈 때도 그대로 들고가도록 검색조건/페이지 유지 -->
  <c:if test="${not empty search}">
    <c:if test="${not empty search.currentPage}">
      <input type="hidden" name="currentPage" value="${search.currentPage}"/>
      <input type="hidden" name="page"        value="${search.currentPage}"/>
    </c:if>
    <c:if test="${not empty search.pageSize}">
      <input type="hidden" name="pageSize" value="${search.pageSize}"/>
    </c:if>
    <c:if test="${not empty search.searchCondition}">
      <input type="hidden" name="searchCondition" value="${search.searchCondition}"/>
    </c:if>
    <c:if test="${not empty search.searchKeyword}">
      <input type="hidden" name="searchKeyword" value="${search.searchKeyword}"/>
    </c:if>
  </c:if>

<!-- [가드: 잘못된 접근] -->
<c:if test="${empty product}">
  <div style="padding:16px;">잘못된 접근입니다.</div>
</c:if>

<c:if test="${not empty product}">
  <!-- [상단 타이틀] -->
  <table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="15" height="37"><img src="${ctx}/images/ct_ttl_img01.gif" width="15" height="37" /></td>
      <td background="${ctx}/images/ct_ttl_img02.gif" width="100%" style="padding-left:10px;">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="93%" class="ct_ttl01">상품상세보기</td>
            <td width="20%" align="right">&nbsp;</td>
          </tr>
        </table>
      </td>
      <td width="12" height="37"><img src="${ctx}/images/ct_ttl_img03.gif" width="12" height="37" /></td>
    </tr>
  </table>

  <!-- [상세 테이블] -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:13px;">
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
    <tr><td width="104" class="ct_write">상품번호</td><td bgcolor="D6D6D6" width="1"></td><td class="ct_write01">${product.prodNo}</td></tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
    <tr><td class="ct_write">상품명</td><td bgcolor="D6D6D6" width="1"></td><td class="ct_write01">${product.prodName}</td></tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
    <tr><td class="ct_write">가격</td><td bgcolor="D6D6D6" width="1"></td><td class="ct_write01"><fmt:formatNumber value="${product.price}" /> 원</td></tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
    <tr><td class="ct_write">제조일자</td><td bgcolor="D6D6D6" width="1"></td><td class="ct_write01">${manuDateDisp}</td></tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
    <tr><td class="ct_write">등록일</td><td bgcolor="D6D6D6" width="1"></td><td class="ct_write01">${regDateDisp}</td></tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
    <tr><td class="ct_write">현재상태</td><td bgcolor="D6D6D6" width="1"></td><td class="ct_write01">${statusDisp}</td></tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
    <tr><td class="ct_write">상품상세정보</td><td bgcolor="D6D6D6" width="1"></td><td class="ct_write01">${product.prodDetail}</td></tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
    
    <tr>
      <td class="ct_write">상품이미지</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <div style="margin-top: 12px;">
          <c:choose>
            <c:when test="${not empty product.images}">
              <%-- c:forEach를 사용해 이미지 목록을 반복 출력 --%>
              <c:forEach var="image" items="${product.images}">
                <img src="${ctx}${image.imagePath}" alt="상품 이미지"
                     style="max-width: 320px; height: auto; border: 1px solid #e6e9ef; border-radius: 8px; margin-bottom: 10px; display: block;" />
              </c:forEach>
            </c:when>
            <c:otherwise>
              <div style="color: #666666;">등록된 상품 이미지가 없습니다.</div>
            </c:otherwise>
          </c:choose>
        </div>
      </td>
    </tr>
    
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  </table>

  <!-- [버튼 영역] -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
    <tr>
      <td width="53%"></td>
      <td align="right" style="padding-right:20px;">
        <table border="0" cellspacing="0" cellpadding="0">
          <tr>
            <!-- 버튼 테이블 내부 -->
            <td width="17" height="23"><img src="${ctx}/images/ct_btnbg01.gif" width="17" height="23" /></td>
            <td background="${ctx}/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">
              <span class="btn-like btn-list">목록</span>
            </td>
            <td width="14" height="23"><img src="${ctx}/images/ct_btnbg03.gif" width="14" height="23" /></td>
            
            <c:choose>
              <c:when test="${isAdmin}">
                <td width="10"></td>
                <td width="17" height="23"><img src="${ctx}/images/ct_btnbg01.gif" width="17" height="23" /></td>
                <td background="${ctx}/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">
                  <span class="btn-like btn-edit">수정</span>
                </td>
                <td width="14" height="23"><img src="${ctx}/images/ct_btnbg03.gif" width="14" height="23" /></td>
              </c:when>
              <c:otherwise>
                <td width="10"></td>
                <td width="17" height="23"><img src="${ctx}/images/ct_btnbg01.gif" width="17" height="23" /></td>
                <td background="${ctx}/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">
                  <span class="btn-like btn-buy">구매</span>
                </td>
                <td width="14" height="23"><img src="${ctx}/images/ct_btnbg03.gif" width="14" height="23" /></td>
              </c:otherwise>
            </c:choose>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</c:if>

</form>

<!-- 페이지 하단 여백(임시 공백) -->
<div style="height:48px;"></div>


</body>
</html>
