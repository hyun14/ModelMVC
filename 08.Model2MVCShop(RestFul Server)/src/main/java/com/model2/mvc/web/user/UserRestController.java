package com.model2.mvc.web.user;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import com.model2.mvc.common.Page;
import com.model2.mvc.common.Search;
import com.model2.mvc.common.web.SearchSupport;
import com.model2.mvc.service.domain.User;
import com.model2.mvc.service.user.UserService;

@RestController
@RequestMapping("/user/json")
public class UserRestController {

    @Autowired
    @Qualifier("userServiceImpl")
    private UserService userService;

    @Value("#{commonProperties['pageUnit']}")
    int pageUnit;

    @Value("#{commonProperties['pageSize']}")
    int pageSize;

    public UserRestController() {
        System.out.println(this.getClass());
    }

    // -------------------------------------------
    // addUser (GET) : 기존 MVC는 뷰 리다이렉트였음 → REST에서는 뷰 정보를 JSON으로 전달
    // 최종 경로: GET /user/json/addUser
    // -------------------------------------------
    @GetMapping("/addUser")
    public Map<String, String> addUserView() throws Exception {
        System.out.println("/user/json/addUser : GET");
        Map<String, String> res = new HashMap<>();
        // 기존 "redirect:/user/addUserView.jsp" 정보를 그대로 노출 (참고용)
        res.put("view", "/user/addUserView.jsp");
        return res;
    }

    // -------------------------------------------
    // addUser (POST) : 사용자 등록 후 true 반환
    // 최종 경로: POST /user/json/addUser
    // -------------------------------------------
    @PostMapping("/addUser")
    public boolean addUser(@RequestBody User user) throws Exception {
        System.out.println("/user/json/addUser : POST");
        userService.addUser(user);
        return true;
    }

    // -------------------------------------------
    // getUser (GET) : 사용자 상세
    // 최종 경로: GET /user/json/getUser?userId=...
    // (MVC 원본이 @RequestParam 사용이므로 PathVariable 대신 RequestParam 유지)
    // -------------------------------------------
    @GetMapping("/getUser")
    public User getUser(@RequestParam("userId") String userId,
                        @ModelAttribute("search") Search search) throws Exception {
        System.out.println("/user/json/getUser : GET");
        // MVC와 동일하게 search 정규화 (뷰 컨텍스트 유지 호환)
        SearchSupport.normalizeAlways(search, this.pageSize);
        return userService.getUser(userId);
    }

    // -------------------------------------------
    // updateUserView (GET) : 기존 MVC는 뷰 포워드였음 → REST에서는 user + search 반환
    // 최종 경로: GET /user/json/updateUserView?userId=...
    // -------------------------------------------
    @GetMapping("/updateUserView")
    public Map<String, Object> updateUserView(@RequestParam("userId") String userId,
                                              @ModelAttribute("search") Search search) throws Exception {
        System.out.println("/user/json/updateUserView : GET");
        User user = userService.getUser(userId);
        SearchSupport.normalizeAlways(search, this.pageSize);

        Map<String, Object> res = new HashMap<>();
        res.put("user", user);
        res.put("search", search);
        // 기존 "forward:/user/updateUser.jsp"는 뷰 용이라 참고용으로만 넘김
        res.put("view", "/user/updateUser.jsp");
        return res;
    }

    // -------------------------------------------
    // updateUser (POST) : 사용자 수정 후 세션 동기화, true 반환
    // 최종 경로: POST /user/json/updateUser
    // -------------------------------------------
    @PostMapping("/updateUser")
    public boolean updateUser(@RequestBody User user,
                              HttpSession session) throws Exception {
        System.out.println("/user/json/updateUser : POST");
        userService.updateUser(user);

        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser != null && loginUser.getUserId().equals(user.getUserId())) {
            session.setAttribute("loginUser", user);
        }
        return true;
    }

    // -------------------------------------------
    // login (GET) : 기존 MVC는 뷰 리다이렉트였음 → REST에서는 뷰 정보 JSON으로 전달
    // 최종 경로: GET /user/json/login
    // -------------------------------------------
    @GetMapping("/login")
    public Map<String, String> loginView() throws Exception {
        System.out.println("/user/json/login : GET");
        Map<String, String> res = new HashMap<>();
        res.put("view", "/user/loginView.jsp");
        return res;
    }

    // -------------------------------------------
    // login (POST) : 로그인 처리 (서비스에 위임), 세션 저장, DB 사용자 반환
    // 최종 경로: POST /user/json/login
    // -------------------------------------------
    @PostMapping("/login")
    public User login(@RequestBody User user, HttpSession session) throws Exception {
        System.out.println("/user/json/login : POST");
        User dbUser = userService.loginUser(user);
        session.setAttribute("loginUser", dbUser);
        return dbUser;
    }

    // -------------------------------------------
    // logout (GET) : 세션 무효화 후 true
    // 최종 경로: GET /user/json/logout
    // -------------------------------------------
    @GetMapping("/logout")
    public boolean logout(HttpSession session) throws Exception {
        System.out.println("/user/json/logout : GET");
        session.invalidate();
        return true;
    }

    // -------------------------------------------
    // checkDuplication (GET) : 아이디 중복 확인
    // 최종 경로: GET /user/json/checkDuplication?userId=...
    // -------------------------------------------
    @GetMapping("/checkDuplication")
    public boolean checkDuplication(@RequestParam("userId") String userId) throws Exception {
        System.out.println("/user/json/checkDuplication : GET");
        return userService.checkDuplication(userId);
    }

    // -------------------------------------------
    // listUser (GET) : 검색/페이징 목록 (MVC와 동일 키 구성: list, resultPage, search)
    // 최종 경로: GET /user/json/listUser?currentPage=...&pageSize=...&searchKeyword=...
    // -------------------------------------------
    @GetMapping("/listUser")
    public Map<String, Object> listUser(@ModelAttribute("search") Search search) throws Exception {
        System.out.println("/user/json/listUser : GET");

        if (search.getCurrentPage() == 0) {
            search.setCurrentPage(1);
        }
        search.setPageSize(pageSize);

        Map<String, Object> map = userService.getUserList(search);
        Page resultPage = new Page(
                search.getCurrentPage(),
                ((Integer) map.get("totalCount")).intValue(),
                pageUnit,
                pageSize
        );

        Map<String, Object> res = new HashMap<>();
        res.put("list", map.get("list"));
        res.put("resultPage", resultPage);
        res.put("search", search);
        return res;
    }
}
