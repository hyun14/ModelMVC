package client.app;

import java.io.UnsupportedEncodingException;
import java.net.CookieManager;
import java.net.CookiePolicy;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpClient.Redirect;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.*;

import org.json.simple.*;
import org.json.simple.parser.JSONParser;

/**
 * ==============================================================
 * REST API 스모크 테스트 (User / Product / Purchase)
 * --------------------------------------------------------------
 * 목적
 *  - /user/json, /product/json, /purchase/json 의 "존재하는 모든 엔드포인트"를
 *    최소 1회 이상 호출하고, 각 요청/응답을 콘솔에 출력하여
 *    "데이터가 정상적으로 이동하는지"를 빠르게 확인한다.
 *
 * 테스트 구조
 *  1) 사용자(User) 기능 묶음
 *     - admin 로그인 → 임시 유저 생성 → 상세/목록/수정/중복체크
 *  2) 상품(Product) 기능 묶음
 *     - 관리자 세션 상태에서 상품 등록 → 목록에서 방금 등록한 상품의 prodNo 찾기
 *       → 상세조회 → 수정 → 목록 라우팅(listProductEntry) → 사용자별 목록
 *  3) 거래(Purchase) 기능 묶음
 *     - 일반 사용자로 로그인 전환 → 구매 입력 화면(addPurchaseView)
 *       → 구매 등록(addPurchase)로 tranNo 취득 → 상세/수정화면/수정/내 구매목록
 *       → (사용자) SHP→DLV 시도 → (관리자 복귀) 판매목록/상품기준 코드변경
 *
 * 특징
 *  - Java 11 표준 HttpClient 사용 (외부 HTTP 클라이언트 불필요)
 *  - CookieManager 로 JSESSIONID 유지 (로그인 세션 연속 요청 검증)
 *  - JSON 파싱은 json-simple-1.1 사용
 *  - 테스트 간 공유 데이터(prodNo, tranNo, …)는 Ctx 객체로 전달
 *
 * 사용 방법
 *  - BASE를 실제 컨텍스트 경로까지 포함해 수정
 *  - 서버 기동 후 main() 실행
 *  - 콘솔에 요청/응답(상태/헤더/바디)이 상세 로깅됨
 * ==============================================================
 */
public class RestApiSmokeTesterForGpt {

    // ==========================================================
    // 0) 환경 설정 : 실행 전 수정 요망
    //    - BASE는 "컨텍스트 루트까지" 포함해야 함
    //      예) "http://127.0.0.1:8080/03.Model2MVCShop(EL,JSTL)"
    // ==========================================================
    private static final String BASE = "http://127.0.0.1:8080";

    private static final Duration TIMEOUT = Duration.ofSeconds(20);

    // ==========================================================
    // 공통 HTTP/쿠키/JSON 리소스
    // ==========================================================
    private final CookieManager cookieManager = new CookieManager(null, CookiePolicy.ACCEPT_ALL);
    private final HttpClient client = HttpClient.newBuilder()
            .cookieHandler(cookieManager)
            .followRedirects(Redirect.NORMAL)
            .connectTimeout(TIMEOUT)
            .build();
    private final JSONParser parser = new JSONParser();

    // ==========================================================
    // (공유) 테스트 컨텍스트: 단계 간 전달 변수
    // ==========================================================
    private static class Ctx {
        String tempUserId;   // 임시로 생성한 사용자 ID
        String markerName;   // 방금 등록한 상품을 식별하기 위한 이름
        Integer prodNo;      // 등록/목록에서 획득한 상품 번호
        Integer tranNo;      // 구매 등록에서 획득한 거래 번호
    }

    // ==========================================================
    // 공통 로깅/HTTP 유틸
    // ==========================================================
    private void logReq(String title, String method, String url, Map<String, String> headers, String body) {
        System.out.println("==================================================");
        System.out.println("[요청] " + title);
        System.out.println(" - 메서드 : " + method);
        System.out.println(" - URL    : " + url);
        if (headers != null && !headers.isEmpty()) {
            System.out.println(" - 헤더   : " + headers);
        }
        if (body != null && !body.isEmpty()) {
            System.out.println(" - 바디   : " + body);
        }
    }
    private void logRes(HttpResponse<String> res) {
        System.out.println("[응답]");
        System.out.println(" - 상태코드 : " + res.statusCode());
        System.out.println(" - 헤더     : " + res.headers().map());
        System.out.println(" - 바디     : " + res.body());
        System.out.println("==================================================");
    }

    private HttpResponse<String> GET(String url) throws Exception {
        logReq("GET 호출", "GET", url, Map.of(), null);
        HttpRequest req = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .timeout(TIMEOUT)
                .GET()
                .build();
        HttpResponse<String> res = client.send(req, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        logRes(res);
        return res;
    }

    private HttpResponse<String> POST_JSON(String url, String json) throws Exception {
        Map<String, String> headers = Map.of("Content-Type", "application/json; charset=UTF-8");
        logReq("POST(JSON) 호출", "POST", url, headers, json);
        HttpRequest req = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .timeout(TIMEOUT)
                .header("Content-Type", "application/json; charset=UTF-8")
                .POST(HttpRequest.BodyPublishers.ofString(json, StandardCharsets.UTF_8))
                .build();
        HttpResponse<String> res = client.send(req, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        logRes(res);
        return res;
    }

    private HttpResponse<String> POST_FORM(String url, Map<String, String> form) throws Exception {
        String encoded = encodeForm(form);
        Map<String, String> headers = Map.of("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
        logReq("POST(FORM) 호출", "POST", url, headers, encoded);
        HttpRequest req = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .timeout(TIMEOUT)
                .header("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8")
                .POST(HttpRequest.BodyPublishers.ofString(encoded, StandardCharsets.UTF_8))
                .build();
        HttpResponse<String> res = client.send(req, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        logRes(res);
        return res;
    }

    private static String encodeForm(Map<String, String> form) throws UnsupportedEncodingException {
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, String> e : form.entrySet()) {
            if (sb.length() > 0) sb.append('&');
            sb.append(URLEncoder.encode(e.getKey(), "UTF-8"));
            sb.append('=');
            sb.append(URLEncoder.encode(e.getValue() != null ? e.getValue() : "", "UTF-8"));
        }
        return sb.toString();
    }

    private JSONObject parseObj(String body) {
        try { return (JSONObject) parser.parse(body); } catch (Exception e) { return null; }
    }
    private Integer pickInt(JSONObject obj, String key) {
        if (obj == null) return null;
        Object v = obj.get(key);
        if (v == null) return null;
        if (v instanceof Number) return ((Number) v).intValue();
        try { return Integer.parseInt(String.valueOf(v)); } catch (Exception ignore) { return null; }
    }

    // ==========================================================
    // 1) 유저 기능 묶음
    //    - admin 로그인으로 관리자 세션 획득
    //    - 임시 사용자 생성(addUser)
    //    - 상세(getUser) / 목록(getUserList) / 수정(updateUser) / 중복체크(checkDuplication)
    // ==========================================================
    private void testUserApis(Ctx ctx) throws Exception {
        final String USER = BASE + "/user/json";

        // (1) 관리자 로그인 : 이후 관리자 권한이 필요한 API 호출 가능해짐
        POST_JSON(USER + "/login", "{\"userId\":\"admin\",\"password\":\"1234\"}");

        // (2) 임시 유저 생성 : 중복 방지 위해 타임스탬프 기반 ID
        ctx.tempUserId = "temp" + System.currentTimeMillis();
        POST_JSON(USER + "/addUser",
                "{\"userId\":\"" + ctx.tempUserId + "\",\"userName\":\"임시사용자\",\"password\":\"pw\","
              + "\"role\":\"user\",\"email\":\"" + ctx.tempUserId + "@test.com\"}");

        // (3) 유저 상세 : admin 계정 조회 (세션/권한 문제 없이 읽히는지)
        GET(USER + "/getUser?userId=admin");

        // (4) 유저 목록 : 페이지/검색 파라미터 전달 → 서버 페이징/검색 로직 확인
        GET(USER + "/listUser?currentPage=1&pageSize=5&searchCondition=&searchKeyword=");

        // (5) 유저 수정 : 방금 만든 임시 유저의 일부 필드 변경
        POST_JSON(USER + "/updateUser",
                "{\"userId\":\"" + ctx.tempUserId + "\",\"userName\":\"임시사용자수정\",\"password\":\"pw\","
              + "\"role\":\"user\",\"email\":\"" + ctx.tempUserId + "@test.com\"}");

        // (6) 아이디 중복 체크 : 생성한 임시 ID가 중복으로 인식되는지 확인
        GET(USER + "/checkDuplication?userId=" + URLEncoder.encode(ctx.tempUserId, "UTF-8"));
    }

    // ==========================================================
    // 2) 상품 기능 묶음
    //    - (관리자 세션 유지 상태) 상품 등록(addProduct : FORM 전송)
    //    - 목록(listProduct)에서 방금 등록한 상품명을 기준으로 prodNo 찾기
    //    - 상세(getProduct) → 수정(updateProduct) → 라우팅(listProductEntry) → 사용자별 목록
    // ==========================================================
    private void testProductApis(Ctx ctx) throws Exception {
        final String PROD = BASE + "/product/json";

        // (1) 신규 상품 등록 : FORM 바인딩 기반(@ModelAttribute), 파일 없이 필드만
        ctx.markerName = "스모크상품-" + System.currentTimeMillis();
        Map<String, String> addP = new LinkedHashMap<>();
        addP.put("prodName", ctx.markerName);
        addP.put("prodDetail", "스모크 테스트용 상품");
        addP.put("manufactureDay", "20250101");
        addP.put("price", "12345");
        POST_FORM(PROD + "/addProduct", addP);

        // (2) 상품 목록에서 방금 등록한 상품을 이름으로 찾아 prodNo 확보
        HttpResponse<String> listRes = GET(PROD + "/listProduct?currentPage=1&pageSize=10&menu=manage");
        JSONObject listObj = parseObj(listRes.body());
        if (listObj != null) {
            Object list = listObj.get("list");
            if (list instanceof JSONArray) {
                for (Object o : (JSONArray) list) {
                    JSONObject p = (JSONObject) o;
                    Object name = p.get("prodName");
                    if (name != null && ctx.markerName.equals(String.valueOf(name))) {
                        ctx.prodNo = pickInt(p, "prodNo");
                        break;
                    }
                }
            }
        }
        System.out.println(">>> [상품] 신규 prodNo = " + ctx.prodNo);

        // (3) 상품 상세 조회 : 메뉴 파라미터 포함(뷰 흐름 메타 유지용)
        if (ctx.prodNo != null) {
            GET(PROD + "/getProduct?prodNo=" + ctx.prodNo + "&menu=search");
        }

        // (4) 상품 수정 : 일부 필드 변경(FORM)
        if (ctx.prodNo != null) {
            Map<String, String> up = new LinkedHashMap<>();
            up.put("prodNo", String.valueOf(ctx.prodNo));
            up.put("prodName", ctx.markerName + "-수정");
            up.put("prodDetail", "수정된 상세");
            up.put("price", "20000");
            POST_FORM(PROD + "/updateProduct", up);
        }

        // (5) 목록 라우팅 : listProductEntry를 통해 manage/search 분기/파라미터 보존 확인
        GET(PROD + "/listProductEntry?menu=manage&currentPage=1&pageSize=5");

        // (6) 사용자별 목록 : 거래중 제외/일반 사용자 기준 목록 API
        GET(PROD + "/listProductByUser?currentPage=1&pageSize=5");
    }

    // ==========================================================
    // 3) 거래(구매) 기능 묶음
    //    - user01로 로그인 전환 → 구매 입력 화면(addPurchaseView)
    //    - 구매 등록(addPurchase : FORM) → tranNo 확보
    //    - 상세(getPurchase) / 수정화면(updatePurchaseView) / 수정(updatePurchase)
    //    - 내 구매목록(listPurchase)
    //    - (사용자) 배송완료(DLV) 전환 시도
    //    - (관리자 복귀) 판매목록(listSale) / 상품기준 코드변경(updateTranCodeByProd)
    // ==========================================================
    private void testPurchaseApis(Ctx ctx) throws Exception {
        final String USER = BASE + "/user/json";
        final String PURC = BASE + "/purchase/json";

        // (1) 일반 사용자로 로그인 전환 : 이후 구매 API는 user01 세션으로 진행
        POST_JSON(USER + "/login", "{\"userId\":\"user01\",\"password\":\"1111\"}");

        // (2) 구매 입력 화면 : 상품/로그인 사용자/뷰 경로 메타 확인
        if (ctx.prodNo != null) {
            GET(PURC + "/addPurchaseView?prodNo=" + ctx.prodNo);
        }

        // (3) 구매 등록 : FORM(@ModelAttribute) - 중첩 필드는 "purchaseProd.prodNo" 규칙 사용
        if (ctx.prodNo != null) {
            Map<String, String> pur = new LinkedHashMap<>();
            pur.put("purchaseProd.prodNo", String.valueOf(ctx.prodNo));
            pur.put("paymentOption", "C");
            pur.put("receiverName", "수신자");
            pur.put("receiverPhone", "010-1111-2222");
            pur.put("divyAddr", "서울시 어딘가");
            pur.put("divyRequest", "문 앞에 놔주세요");
            pur.put("divyDate", "2025-10-01");
            HttpResponse<String> addPurRes = POST_FORM(PURC + "/addPurchase", pur);
            JSONObject addPurObj = parseObj(addPurRes.body());
            ctx.tranNo = pickInt(addPurObj, "tranNo");
        }
        System.out.println(">>> [구매] tranNo = " + ctx.tranNo);

        // (4) 구매 상세/수정 화면 진입/수정
        if (ctx.tranNo != null) {
            GET(PURC + "/getPurchase?tranNo=" + ctx.tranNo);
            GET(PURC + "/updatePurchaseView?tranNo=" + ctx.tranNo);

            Map<String, String> upd = new LinkedHashMap<>();
            upd.put("tranNo", String.valueOf(ctx.tranNo));
            upd.put("divyDate", "2025-10-03");
            POST_FORM(PURC + "/updatePurchase", upd);

            // (5) 내 구매 목록 : user01 기준 목록 + 페이징 메타 확인
            GET(PURC + "/listPurchase?currentPage=1&pageSize=5");

            // (6) 사용자 측 상태 전환 시도 : SHP → DLV (서버의 현재 tranCode에 따라 거절될 수 있음)
            GET(PURC + "/updateTranCode?tranNo=" + ctx.tranNo + "&tranCode=DLV");
        }

        // (7) 관리자 복귀 → 판매 목록/상품 기준 상태 변경
        POST_JSON(USER + "/login", "{\"userId\":\"admin\",\"password\":\"1234\"}");
        //GET(PURC + "/listSale?currentPage=1&pageSize=5");
        if (ctx.prodNo != null) {
            GET(PURC + "/updateTranCodeByProd?prodNo=" + ctx.prodNo + "&page=1");
        }
    }

    // ==========================================================
    // runAll : 전체 시나리오 오케스트레이션
    // ----------------------------------------------------------
    // 이 메서드는 "실제 테스트 수행의 큰 흐름"만 관리하고,
    // 상세 API 호출/검증 로깅은 각 기능 묶음 메서드로 위임한다.
    //
    // [실행 순서]
    //  1) 사용자(User) 묶음
    //  2) 상품(Product) 묶음
    //  3) 거래(Purchase) 묶음
    //
    // 각 단계에서 생성/획득한 식별자(prodNo, tranNo)는 Ctx를 통해
    // 다음 단계로 자연스럽게 전달되어 시나리오가 이어지도록 구성했다.
    // ==========================================================
    public void runAll() throws Exception {
        Ctx ctx = new Ctx();

        // 1) 사용자 기능 전반 테스트
        testUserApis(ctx);

        // 2) 상품 기능 전반 테스트 (관리자 세션 상태를 그대로 이어받음)
        testProductApis(ctx);

        // 3) 거래(구매) 기능 전반 테스트 (중간에 사용자 세션으로 전환했다가, 관리자 복귀까지)
        testPurchaseApis(ctx);

        // (참고) 현재 세션/쿠키 상태 확인
        System.out.println(">>> [디버그] 현재 쿠키 = " + cookieManager.getCookieStore().getCookies());
    }

    // ==========================================================
    // main : 진입점
    // ==========================================================
    public static void main(String[] args) {
        try {
            System.out.println("=== REST 스모크 테스트 시작 ===");
            System.out.println("BASE = " + BASE);
            new RestApiSmokeTesterForGpt().runAll();
            System.out.println("=== REST 스모크 테스트 종료 ===");
        } catch (Exception e) {
            System.out.println("[오류] 테스트 실행 중 예외 : " + e.getMessage());
            e.printStackTrace(System.out);
        }
    }
}
