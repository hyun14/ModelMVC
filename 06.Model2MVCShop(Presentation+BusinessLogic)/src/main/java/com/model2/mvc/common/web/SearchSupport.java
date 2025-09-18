// 파일 위치 : src/main/java/com/model2/mvc/common/web/SearchSupport.java
package com.model2.mvc.common.web;

import com.model2.mvc.common.Search;

public final class SearchSupport {

    private SearchSupport() { /* 유틸 클래스 */ }

    // 기존: 넘어온 파라미터가 하나라도 있는지 체크(호환용)
    public static boolean hasAny(String sc, String sk, Integer currentPage, Integer pageSize) {
        return sc != null || sk != null || currentPage != null || pageSize != null;
    }

    // 기존: Search 생성 + 기본값 보정(호환용)
    public static Search buildAndNormalize(String sc, String sk, Integer currentPage, Integer pageSize, int defaultPageSize) {
        Search s = new Search();
        if (sc != null) s.setSearchCondition(sc);
        if (sk != null) s.setSearchKeyword(sk);
        if (currentPage != null) s.setCurrentPage(Math.max(currentPage, 1));
        if (pageSize != null) s.setPageSize(Math.max(pageSize, 1));
        if (s.getCurrentPage() <= 0) s.setCurrentPage(1);
        if (s.getPageSize() <= 0) s.setPageSize(defaultPageSize);
        return s;
    }

    // 추가(권장): 항상 호출 가능한 정규화(디폴트 주입 + 트림 + 빈키워드 null)
    public static void normalizeAlways(Search s, int defaultPageSize) {
        if (s == null) {
            return; // @ModelAttribute가 null을 주지 않지만, 방어적으로 처리
        }

        // 1) 키워드 트림 후 빈 문자열이면 null
        if (s.getSearchKeyword() != null) {
            String kw = s.getSearchKeyword().trim();
            s.setSearchKeyword(kw.isEmpty() ? null : kw);
        }

        // 2) 조건 트림 후 비어있으면 기본값(all)
        if (s.getSearchCondition() == null || s.getSearchCondition().trim().isEmpty()) {
            s.setSearchCondition(null);
        } else {
            s.setSearchCondition(s.getSearchCondition().trim());
        }

        // 3) 페이징 보정(primitive int이므로 미지정 시 0 → 보정 필요)
        if (s.getCurrentPage() <= 0) {
            s.setCurrentPage(1);
        }
        if (s.getPageSize() <= 0) {
            s.setPageSize(defaultPageSize);
        }
    }

    // 추가(선택): 파라미터에서 만들어 바로 정규화까지
    public static Search fromParamsOrDefaults(String sc, String sk, Integer currentPage, Integer pageSize, int defaultPageSize) {
        Search s = new Search();
        if (sc != null) s.setSearchCondition(sc);
        if (sk != null) s.setSearchKeyword(sk);
        if (currentPage != null) s.setCurrentPage(currentPage);
        if (pageSize != null) s.setPageSize(pageSize);
        normalizeAlways(s, defaultPageSize);
        return s;
    }
}
