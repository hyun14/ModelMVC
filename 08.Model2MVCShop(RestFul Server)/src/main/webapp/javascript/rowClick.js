// [목적] 행 전체를 클릭 가능하게 만들고, 모드에 따라 우선 링크 또는 상세로 이동
// [적용 규칙]
// 1) 행에 class="click-row" 필수
// 2) 기본 이동 경로: data-href 속성에 지정
// 3) 관리 모드: data-mode="manage" 이면 우선적으로 a.status-link를 이동 대상으로 사용
// 4) a, button, input 등 인터랙티브 요소 클릭은 가로채지 않음
// 5) 접근성: Enter 키로도 이동 가능(행에 tabindex="0" 권장)

document.addEventListener('DOMContentLoaded', function () {
  var rows = document.querySelectorAll('tr.click-row');

  rows.forEach(function (tr) {
    // 키보드 접근성: 필요 시 JSP에서 tabindex="0"도 함께 부여
    if (!tr.hasAttribute('tabindex')) {
      tr.setAttribute('tabindex', '0');
    }

    function go(e) {
      // 인터랙티브 요소 클릭은 그대로 두기
      if (e.type === 'click' && e.target.closest('a, button, input, label, select, textarea')) {
        return;
      }

      var mode = tr.getAttribute('data-mode') || 'search';
      var href = tr.getAttribute('data-href');

      // 관리 모드: status-link가 있으면 그걸 우선
      if (mode === 'manage') {
        var statusLink = tr.querySelector('a.status-link');
        if (statusLink && statusLink.getAttribute('href')) {
          window.location.href = statusLink.getAttribute('href');
          return;
        }
      }

      // 기본 이동
      if (href) {
        window.location.href = href;
      }
    }

    tr.addEventListener('click', go);

    tr.addEventListener('keydown', function (e) {
      // Enter 키로 이동
      if (e.key === 'Enter') {
        go(e);
      }
    });
  });
});
