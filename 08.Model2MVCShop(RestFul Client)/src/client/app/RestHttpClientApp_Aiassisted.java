package client.app;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Map;

import org.codehaus.jackson.map.ObjectMapper;

import com.model2.mvc.service.domain.User;
import com.model2.mvc.common.Search;

/**
 * UserRestController 테스트용 Java 클라이언트
 * HttpURLConnection + Jackson 사용
 */
public class RestHttpClientApp_Aiassisted {

	///Field
    private static final String BASE_URL = "http://localhost:8080/user/json/";

    ///Main Method
    public static void main(String[] args) throws Exception {
        // 개별 메서드 호출로 테스트
//        addUser_test();
//        login_test();
//        getUser_test("user01");
//        getUserList_test();
//        updateUser_test();
        checkDuplication_test("user01");
    }

    // 1. 회원가입 테스트
    public static void addUser_test() throws Exception {
        System.out.println("==> addUser_test()");

        User user = new User();
        user.setUserId("user99");
        user.setUserName("이순신");
        user.setPassword("9999");
        user.setRole("user");
        user.setSsn("9001011234567");
        user.setPhone("010-9999-9999");
        user.setAddr("서울시 강남구");
        user.setEmail("lee99@example.com");

        ObjectMapper mapper = new ObjectMapper();
        String json = mapper.writeValueAsString(user);

        String result = sendPost("addUser", json);
        System.out.println("결과 : " + result);
    }

    // 2. 로그인 테스트
    public static void login_test() throws Exception {
        System.out.println("==> login_test()");

        User user = new User();
        user.setUserId("user99");
        user.setPassword("9999");

        ObjectMapper mapper = new ObjectMapper();
        String json = mapper.writeValueAsString(user);

        String result = sendPost("login", json);
        System.out.println("로그인 응답 : " + result);
    }

    // 3.회원 상세 조회 테스트
    public static void getUser_test(String userId) throws Exception {
        System.out.println("==> getUser_test()");

        String result = sendGet("getUser/" + userId);
        System.out.println("회원 정보 : " + result);
    }

    // 4. 회원 목록 조회 테스트
    public static void getUserList_test() throws Exception {
    	System.out.println("==> getUserList_test()");

        // 1. 검색 조건 구성
        Search search = new Search();
        search.setCurrentPage(1);
        search.setPageSize(10);
        search.setSearchCondition("");
        search.setSearchKeyword("");

        // 2. ObjectMapper 를 이용해 Search 객체 → JSON 문자열
        ObjectMapper mapper = new ObjectMapper();
        String json = mapper.writeValueAsString(search);

        // 3. POST 요청으로 결과 JSON 문자열 수신
        String result = sendPost("getUserList", json);
        // 3.1 출력
        System.out.println("회원 리스트 :\n" + result);

        // 4. 문자열을 Map 으로 역직렬화 (JSON → Map)
        Map<String, Object> resultMap = mapper.readValue(result, Map.class);

        // 5. Map 을 Pretty JSON 으로 출력
        String prettyResult = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(resultMap);
        
        // 6. 출력
        System.out.println("회원 리스트 (Pretty Print):\n" + prettyResult);
    }

    // 5. 회원 정보 수정 테스트
    public static void updateUser_test() throws Exception {
        System.out.println("==> updateUser_test()");

        User user = new User();
        user.setUserId("user99");
        user.setUserName("이순신-수정");
        user.setPhone("010-1111-2222");
        user.setAddr("서울시 수정구");
        user.setEmail("a@a.com");

        ObjectMapper mapper = new ObjectMapper();
        String json = mapper.writeValueAsString(user);

        String result = sendPost("updateUser", json);
        System.out.println("수정 결과 : " + result);
    }

    // 6. 아이디 중복 확인 테스트
    public static void checkDuplication_test(String userId) throws Exception {
        System.out.println("==> checkDuplication_test()");

        String result = sendGet("checkDuplication/" + userId);
        System.out.println("중복 여부 : " + result);
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // POST 요청 보내기
    private static String sendPost(String endpoint, String json) throws Exception {
        URL url = new URL(BASE_URL + endpoint);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(json.getBytes("UTF-8"));
            os.flush();
        }
        return readResponse(conn);
    }

    // GET 요청 보내기
    private static String sendGet(String endpoint) throws Exception {
        URL url = new URL(BASE_URL + endpoint);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        return readResponse(conn);
    }

    // 응답 읽기
    private static String readResponse(HttpURLConnection conn) throws Exception {
        StringBuilder response = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"))) {
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
        }
        return response.toString();
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}