package com.model2.mvc.web.user;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.model2.mvc.common.Page;
import com.model2.mvc.common.Search;
import com.model2.mvc.common.web.SearchSupport;
import com.model2.mvc.service.domain.User;
import com.model2.mvc.service.user.UserService;


//==> 회원관리 Controller
@Controller
public class UserController {
	
	///Field
	@Autowired
	@Qualifier("userServiceImpl")
	private UserService userService;
	//setter Method 구현 않음
		
	public UserController(){
		System.out.println(this.getClass());
	}
	
	//==> classpath:config/common.properties  ,  classpath:config/commonservice.xml 참조 할것
	//==> 아래의 두개를 주석을 풀어 의미를 확인 할것
	@Value("#{commonProperties['pageUnit']}")
	//@Value("#{commonProperties['pageUnit'] ?: 3}")
	int pageUnit;
	
	@Value("#{commonProperties['pageSize']}")
	//@Value("#{commonProperties['pageSize'] ?: 2}")
	int pageSize;
	
	
	@RequestMapping("/addUserView.do")//
	public String addUserView() throws Exception {

		System.out.println("/addUserView.do");
		
		return "redirect:/user/addUserView.jsp";
	}
	
	@RequestMapping("/addUser.do")
	public String addUser( @ModelAttribute("user") User user ) throws Exception {

		System.out.println("/addUser.do");
		//Business Logic
		userService.addUser(user);
		
		return "redirect:/user/loginView.jsp";
	}
	
	// [상세조회] : 검색컨텍스트가 있을 때만 Search를 생성/전달
	@RequestMapping("/getUser.do")
	public String getUser(@RequestParam("userId") String userId,
	                      @ModelAttribute("search") Search search,  // 항상 바인딩
	                      Model model) throws Exception {

	    // [의미] 상세 조회 대상 사용자 로딩
	    User user = userService.getUser(userId);
	    model.addAttribute("user", user);

	    // [의미] 검색 상태를 항상 정규화(없으면 기본값으로 채움)
	    // - currentPage 미지정/이상값 ⇒ 1
	    // - pageSize 미지정/이상값 ⇒ this.pageSize
	    // - condition 기본값 세팅(예: "all")
	    // - keyword trim, 비었으면 null 처리(= 필터 생략 신호)
	    SearchSupport.normalizeAlways(search, this.pageSize);

	    model.addAttribute("search", search); // 항상 올림
	    return "forward:/user/getUser.jsp";
	}
	
	@RequestMapping("/updateUserView.do")
	public String updateUserView( @RequestParam("userId") String userId , Model model ) throws Exception{

		System.out.println("/updateUserView.do");
		//Business Logic
		User user = userService.getUser(userId);
		// Model 과 View 연결
		model.addAttribute("user", user);
		
		return "forward:/user/updateUser.jsp";
	}
	
	@RequestMapping("/updateUser.do")
	public String updateUser( @ModelAttribute("user") User user , Model model , HttpSession session) throws Exception{

		System.out.println("/updateUser.do");
		//Business Logic
		userService.updateUser(user);
		
		String sessionId=((User)session.getAttribute("user")).getUserId();
		if(sessionId.equals(user.getUserId())){
			session.setAttribute("user", user);
		}
		
		return "redirect:/getUser.do?userId="+user.getUserId();
	}
	
	@RequestMapping("/loginView.do")//
	public String loginView() throws Exception{
		
		System.out.println("/loginView.do");

		return "redirect:/user/loginView.jsp";
	}
	
	// 1) 로그인: 액션(LoginAction)과 동일한 검증 흐름으로 수정
	@RequestMapping("/login.do")
	public String login(@ModelAttribute("user") User user, HttpSession session) throws Exception {

	    System.out.println("/login.do");
	    // [변경] 서비스에 로그인 위임 : 검증/예외 처리 일원화
	    User dbUser = userService.loginUser(user);

	    // [동일] 로그인 성공 시 세션 저장
	    session.setAttribute("user", dbUser);

	    return "redirect:/index.jsp";
	}
	
	@RequestMapping("/logout.do")
	public String logout(HttpSession session ) throws Exception{
		
		System.out.println("/logout.do");
		
		session.invalidate();
		
		return "redirect:/index.jsp";
	}
	
	@RequestMapping("/checkDuplication.do")
	public String checkDuplication( @RequestParam("userId") String userId , Model model ) throws Exception{
		
		System.out.println("/checkDuplication.do");
		//Business Logic
		boolean result=userService.checkDuplication(userId);
		// Model 과 View 연결
		model.addAttribute("result", new Boolean(result));
		model.addAttribute("userId", userId);

		return "forward:/user/checkDuplication.jsp";
	}
	
	@RequestMapping("/listUser.do")
	public String listUser( @ModelAttribute("search") Search search , Model model , HttpServletRequest request) throws Exception{
		
		System.out.println("/listUser.do");
		
		if(search.getCurrentPage() ==0 ){
			search.setCurrentPage(1);
		}
		search.setPageSize(pageSize);
		
		// Business logic 수행
		Map<String , Object> map=userService.getUserList(search);
		
		Page resultPage = new Page( search.getCurrentPage(), ((Integer)map.get("totalCount")).intValue(), pageUnit, pageSize);
		System.out.println(resultPage);
		
		// Model 과 View 연결
		model.addAttribute("list", map.get("list"));
		model.addAttribute("resultPage", resultPage);
		model.addAttribute("search", search);
		
		return "forward:/user/listUser.jsp";
	}
}