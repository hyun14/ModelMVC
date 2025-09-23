// 파일 위치 : src/main/java/com/model2/mvc/common/web/SearchSupport.java
package com.model2.mvc.common.web;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

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
    
 // =========================================================
    //  toQueryString(Search) : 리다이렉트 URL에 검색조건을 붙여주는 유틸리티
    //  - 용도 : "redirect:/user/getUser?userId=..." 뒤에 + SearchSupport.toQueryString(search)
    //  - 규칙 : 항상 '&'로 시작하여 바로 이어붙일 수 있게 함
    //  - 인코딩 : UTF-8 (한글/공백 포함 안정)
    // =========================================================
    public static String toQueryString(Search search) {
        // [의미/사용처] search 객체가 없으면 붙일 파라미터가 없으므로 빈 문자열 반환
        if (search == null) {
            return "";
        }

        // [의미/사용처] currentPage, pageSize 는 항상 포함 (normalizeAlways 로 정규화 가정)
        StringBuilder sb = new StringBuilder();
        sb.append("&currentPage=").append(encode(String.valueOf(search.getCurrentPage())));
        sb.append("&pageSize=").append(encode(String.valueOf(search.getPageSize())));

        // [의미/사용처] 선택 파라미터는 값이 있을 때만 포함
        if (!isEmpty(search.getSearchCondition())) {
            sb.append("&searchCondition=").append(encode(search.getSearchCondition()));
        }
        if (!isEmpty(search.getSearchKeyword())) {
            sb.append("&searchKeyword=").append(encode(search.getSearchKeyword()));
        }

        // 필요 시 여기에서 추가 필터(category, onlyRecruiting 등)도 동일 패턴으로 확장 가능
        // ex)
        // if (!isEmpty(search.getCategory())) {
        //     sb.append("&category=").append(encode(search.getCategory()));
        // }
        // if (!isEmpty(search.getOnlyRecruiting())) {
        //     sb.append("&onlyRecruiting=").append(encode(search.getOnlyRecruiting()));
        // }

        return sb.toString();
    }

    // =========================================================
    //  encode(String) : URL 파라미터 안전화를 위한 UTF-8 인코딩
    // =========================================================
    private static String encode(String value) {
        // [의미/사용처] 널 안전 처리 후 UTF-8 URL 인코딩 (JDK 8 호환)
        String val = (value == null) ? "" : value;
        try {
            return URLEncoder.encode(val, "UTF-8");
        } catch (java.io.UnsupportedEncodingException e) {
            // UTF-8은 항상 제공되므로 정상적으로는 오지 않음. 혹시 모를 예외는 런타임으로 감싸서 던짐.
            throw new RuntimeException("UTF-8 인코딩을 지원하지 않습니다.", e);
        }
    }

    // =========================================================
    //  isEmpty(String) : 널/빈문자/공백만 있는 문자열 판정
    // =========================================================
    private static boolean isEmpty(String s) {
        // [의미/사용처] 검색어/조건의 존재 여부 판단
        return s == null || s.trim().isEmpty();
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
