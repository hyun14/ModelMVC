<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="currentStatus" value="${not empty param.searchStatus ? param.searchStatus : 'ALL'}" />
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>구매 이력 조회 (AJAX)</title>
  <link rel="stylesheet" href="${ctx}/css/admin.css" type="text/css" />
  
  <script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
  
  <style>
    .loading-overlay { position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: rgba(255,255,255,0.7); z-index: 10; display: flex; align-items: center; justify-content: center; font-weight: bold; color: #555; }
    .card-grid-container { position: relative; min-height: 200px; }
    .purchase-tabs { display: flex; border-bottom: 2px solid #e5e5e5; margin-bottom: 16px; }
    .purchase-tabs a { padding: 10px 20px; text-decoration: none; color: #888; font-weight: bold; border-bottom: 2px solid transparent; margin-bottom: -2px; cursor: pointer; }
    .purchase-tabs a.active, .purchase-tabs a:hover { color: #333; border-color: #333; }
    .card-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 16px; margin-top: 10px; }
    .purchase-card { border: 1px solid #e5e5e5; padding: 12px; background: #fff; cursor: pointer; transition: box-shadow 0.2s; }
    .purchase-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
    .prod-thumb { width: 100%; aspect-ratio: 4/3; object-fit: cover; border: 1px solid #f0f0f0; background: #fafafa; margin-bottom: 10px; border-radius: 4px; }
    .card-meta { font-size: 13px; line-height: 1.6; color: #333; }
    .card-meta strong { display: inline-block; min-width: 75px; color: #555; }
    .card-title { font-size: 14px; font-weight: bold; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-bottom: 8px; }
    .card-actions { margin-top: 10px; padding-top: 10px; border-top: 1px solid #f0f0f0; text-align: right; }
    .mark-arrived { color: #0066cc; text-decoration: underline; font-size: 13px; }
    @media (max-width: 1400px) { .card-grid { grid-template-columns: repeat(4, 1fr); } }
    @media (max-width: 1024px) { .card-grid { grid-template-columns: repeat(3, 1fr); } }
    @media (max-width: 768px) { .card-grid { grid-template-columns: repeat(2, 1fr); } }
    @media (max-width: 480px) { .card-grid { grid-template-columns: repeat(1, 1fr); } }
  </style>

  <script type="text/javascript">
    var g_ctx = "${ctx}";

    // ===== 공용 유틸 =====
    function goTo(actionUrl, params) {
      var form = $('<form></form>');
      form.attr('method', 'get');
      form.attr('action', actionUrl);
      $.each(params, function(key, val){
        form.append($('<input type="hidden" name="'+key+'" value="'+val+'">'));
      });
      $('body').append(form);
      form.submit();
    }

 	// ===== DOM Ready =====
    $(function(){
      $('.purchase-tabs a').on('click', function(e){
        e.preventDefault();
        var status = $(this).data('status');
        $('.purchase-tabs a').removeClass('active');
        $(this).addClass('active');
        loadPurchases(status);
      });

      $(document).on("click", ".click-row", function(){
        var tranNo = $(this).data("tranno");
        if(tranNo) {
          goTo('./getPurchase', { tranNo: tranNo });
        }
      });

      $(document).on("click", ".mark-arrived", function(e){
        e.stopPropagation();
        var tranNo = $(this).data("tranno");
        var currentStatus = $('.purchase-tabs a.active').data('status');

        if(confirm(tranNo + '번 주문을 배송 완료 처리하시겠습니까?')) {
            $.ajax({
                url: g_ctx + "/purchase/json/updateTranCode",
                method: "GET",
                data: { tranNo: tranNo, tranCode: "DLV" }
            }).done(function(){
                alert("처리되었습니다.");
                loadPurchases(currentStatus);
            }).fail(function(){
                alert("처리 중 오류가 발생했습니다.");
            });
        }
      });

      loadPurchases($('.purchase-tabs a.active').data('status') || 'ALL');
    });

    /**
     * AJAX로 구매 목록 데이터를 로드하는 함수
     */
    function loadPurchases(status) {
      var $container = $('#cardGridContainer');
      var $grid = $container.find('.card-grid');
      var ajaxData = {};
      if (status !== 'ALL') {
        ajaxData.searchStatus = status;
      }
      $container.append('<div class="loading-overlay">로딩 중...</div>');
      $.ajax({
        url: g_ctx + "/purchase/json/listPurchase",
        method: "GET",
        data: ajaxData,
        dataType: "json"
      }).done(function(response){
        var list = response.list || [];
        var totalCount = response.resultPage ? response.resultPage.totalCount : 0;
        $('#totalCount').text(totalCount.toLocaleString());
        renderCards(list);
      }).fail(function(jqXHR, textStatus, errorThrown){
        // [추가] AJAX 실패 시 에러를 콘솔에 출력
        console.error("AJAX Error:", textStatus, errorThrown);
        $grid.html('<div>데이터를 불러오는 중 오류가 발생했습니다. 개발자 도구(F12)의 Console 탭을 확인해주세요.</div>');
      }).always(function(){
        $container.find('.loading-overlay').remove();
      });
    }

    /**
     * 카드 목록을 화면에 그리는 함수
     */
    function renderCards(list) {
      var $grid = $('.card-grid');
      $grid.empty();
      if (list.length === 0) {
        $grid.css('display', 'block').html('<div style="text-align:center; padding:20px; color:#888;">조회된 주문이 없습니다.</div>');
        return;
      }
      $grid.css('display', 'grid');
      var frag = $(document.createDocumentFragment());
      $.each(list, function(_, purchase){
        frag.append(createCardHtml(purchase));
      });
      $grid.append(frag);
    }
    
    /**
     * 구매 내역 객체 하나로 카드 HTML 문자열을 생성하는 템플릿 함수
     * [최종 수정] 템플릿 리터럴(``) 대신 안정적인 문자열 더하기(+) 방식으로 변경하고,
     * 서버에서 제공하는 포맷팅된 날짜(divyDateDash)를 사용합니다.
     */
    function createCardHtml(p) {
      // 디버깅용 로그는 그대로 둡니다.
      console.log("createCardHtml에 전달된 데이터:", p);

      // 1. 이미지 경로 처리
      var firstImage = (p.purchaseProd && p.purchaseProd.images && p.purchaseProd.images.length > 0) ? p.purchaseProd.images[0].imagePath : '';
      var imgSrc = firstImage ? g_ctx + firstImage : g_ctx + "/images/noimg.png";
      
      // 2. 배송 희망일 처리 (서버에서 받은 divyDateDash 값을 바로 사용)
      var divyDate = p.divyDateDash || '-';
      
      // 3. '물건도착' 버튼 HTML 생성
      var actionHtml = '';
      if (p.tranCode === 'SHP') {
        actionHtml = '<span class="mark-arrived" data-tranno="' + p.tranNo + '">물건도착</span>';
      }

      // 4. 최종 카드 HTML 조합 (안정적인 문자열 더하기 방식으로 변경)
      var cardHtml = 
          '<div class="purchase-card click-row" data-tranno="' + p.tranNo + '">' +
              '<img src="' + imgSrc + '" class="prod-thumb" alt="상품 썸네일">' +
              '<div class="card-title">' + (p.purchaseProd ? p.purchaseProd.prodName : '알 수 없음') + '</div>' +
              '<div class="card-meta"><strong>주문번호</strong> : ' + p.tranNo + '</div>' +
              '<div class="card-meta"><strong>구매수량</strong> : ' + p.sellQuantity + ' 개</div>' +
              '<div class="card-meta"><strong>배송희망일</strong> : ' + divyDate + '</div>' +
              '<div class="card-actions">' + actionHtml + '</div>' +
          '</div>';

      return cardHtml;
    }
  </script>
</head>

<body>

<form id="listForm" name="listForm"></form>

<table style="width:100%; height:37px;" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="15" height="37"><img src="${ctx}/images/ct_ttl_img01.gif" width="15" height="37" /></td>
    <td background="${ctx}/images/ct_ttl_img02.gif" width="100%" style="padding-left:10px;">
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr><td class="ct_ttl01">구매 이력 조회</td></tr>
      </table>
    </td>
    <td width="12" height="37"><img src="${ctx}/images/ct_ttl_img03.gif" width="12" height="37" /></td>
  </tr>
</table>

<div style="width:98%; margin-left:10px;">

  <div class="purchase-tabs">
    <a href="#" data-status="ALL" class="${currentStatus eq 'ALL' ? 'active' : ''}">전체</a>
    <a href="#" data-status="BEF" class="${currentStatus eq 'BEF' ? 'active' : ''}">배송전</a>
    <a href="#" data-status="SHP" class="${currentStatus eq 'SHP' ? 'active' : ''}">배송중</a>
    <a href="#" data-status="DLV" class="${currentStatus eq 'DLV' ? 'active' : ''}">도착</a>
    <a href="#" data-status="CNL" class="${currentStatus eq 'CNL' ? 'active' : ''}">주문취소</a>
  </div>

  <div style="margin:8px 0;">
    조회된 주문 수: <strong id="totalCount">0</strong> 건
  </div>

  <div id="cardGridContainer" class="card-grid-container">
    <div class="card-grid">
      </div>
  </div>

</div>
</body>
</html>