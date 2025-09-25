package com.model2.mvc.web.product;

import java.net.URLEncoder;
import java.io.File;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.model2.mvc.common.Page;
import com.model2.mvc.common.Search;
import com.model2.mvc.common.web.SearchSupport;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.ProductImage;
import com.model2.mvc.service.domain.User;
import com.model2.mvc.service.product.ProductService;

@Controller
@RequestMapping("/product")
public class ProductController {

	@Autowired
	@Qualifier("productServiceImpl")
	private ProductService productService;

	@Value("#{commonProperties['pageUnit']}")
	private int pageUnit;

	@Value("#{commonProperties['pageSize']}")
	private int pageSize;

	// =========================
	// 1) 상품 등록 (둘 다 허용: 추후 메소드 제한 리팩터링 가능)
	// =========================
	// [의미] 상품 등록 처리. 폼 필드를 Product 도메인으로 직접 바인딩
	@PostMapping("/addProduct") 
	public String addProduct(
	        HttpServletRequest request,
	        @ModelAttribute("product") Product product,
	        // 1. 파라미터를 List<MultipartFile>로 변경
	        @RequestParam(value = "uploadFiles", required = false) List<MultipartFile> uploadFiles, 
	        Model model) throws Exception {

	    // 권한 체크(관리자만) : 기존 로직 유지
	    HttpSession session = request.getSession(false);
	    User user = (session != null) ? (User) session.getAttribute("loginUser") : null;
	    if (user == null || "user".equals(user.getRole())) {
	        return "redirect:/error/forbidden.jsp";
	    }

	    // 가격 등 숫자 필드 보정
	    if (product.getPrice() < 0) {
	        product.setPrice(0);
	    }

	    // 2. 상품 기본 정보 먼저 등록 (prodNo가 생성됨)
	    productService.insertProduct(product);

	    // 3. 다중 파일 업로드 처리 로직 추가
	    if (uploadFiles != null && !uploadFiles.isEmpty()) {
	        String uploadDir = request.getServletContext().getRealPath("/upload");
	        File uploadPath = new File(uploadDir);
	        if (!uploadPath.exists()) {
	            uploadPath.mkdirs();
	        }

	        List<ProductImage> imageList = new ArrayList<>();
	        int sortOrder = 1;

	        for (MultipartFile file : uploadFiles) {
	            if (!file.isEmpty()) {
	                String original = file.getOriginalFilename();
	                String ext = (original != null && original.lastIndexOf('.') != -1)
	                        ? original.substring(original.lastIndexOf('.'))
	                        : "";
	                String saved = UUID.randomUUID().toString().replace("-", "") + ext;

	                File target = new File(uploadDir, saved);
	                file.transferTo(target);

	                // ProductImage 객체 생성
	                ProductImage image = new ProductImage();
	                image.setProdNo(product.getProdNo()); // 방금 생성된 상품 번호
	                image.setImagePath("/upload/" + saved); // DB에 저장될 경로
	                image.setSortOrd(sortOrder++); // 정렬 순서
	                
	                imageList.add(image);
	            }
	        }

	        // 4. 이미지 정보 일괄 저장
	        if (!imageList.isEmpty()) {
	            productService.replaceProductImages(product.getProdNo(), imageList);
	        }
	    }

	 // 저장 후, 새로 만들 결과 페이지 컨트롤러로 리다이렉트
	    return "redirect:/product/addProductResult?prodNo=" + product.getProdNo();
	}
	
	// 2. 등록 결과 페이지를 보여줄 메서드를 새로 추가
	@GetMapping("/addProductResult")
	public String addProductResult(@RequestParam("prodNo") int prodNo, Model model) throws Exception {
	    // DB에서 방금 등록된 상품의 최신 정보를 (이미지 포함) 다시 조회
	    Product product = productService.findProduct(prodNo);

	    // 모델에 담아서 productResult.jsp로 전달
	    model.addAttribute("product", product);
	    return "forward:/product/productResult.jsp";
	}

	// =========================
	// 2) 상품 수정 (POST 전용 로직을 그대로 유지)
	// =========================
	// [의미] 상품 수정 처리. prodNo 포함 폼 전체를 Product로 받음
	// 이미지 업데이트를 옵션으로 처리하는 업데이트 메서드
	// - 새 파일 업로드 시: /upload 폴더에 저장 후 product.fileName 갱신
	// - 새 파일이 없으면: DB의 기존 fileName을 보존(덮어쓰지 않음)
	@PostMapping("/updateProduct") // POST 방식이므로 변경 권장
	public String updateProduct(
	        HttpServletRequest request,
	        @RequestParam(value = "menu", required = false) String menu,
	        @ModelAttribute("search") Search search,
	        @ModelAttribute("product") Product product,
	        // 1. 파라미터를 List<MultipartFile>로 변경
	        @RequestParam(value = "uploadFiles", required = false) List<MultipartFile> uploadFiles)
	        throws Exception {
	    
	    // [권한 체크] : 기존 로직 유지
	    HttpSession session = request.getSession(false);
	    User user = (session != null) ? (User) session.getAttribute("loginUser") : null;
	    if (user == null || "user".equals(user.getRole())) {
	        return "redirect:/error/forbidden.jsp";
	    }

	    // [가격 보정] : 기존 로직 유지
	    if (product.getPrice() < 0) {
	        product.setPrice(0);
	    }

	    // 2. 상품 기본 정보 먼저 수정
	    productService.updateProduct(product);

	    // 3. 다중 파일 업로드 및 정보 교체 로직 추가
	    // (addProduct와 동일한 로직)
	    if (uploadFiles != null && !uploadFiles.isEmpty()) {
	        String uploadDir = request.getServletContext().getRealPath("/upload");
	        File uploadPath = new File(uploadDir);
	        if (!uploadPath.exists()) {
	            uploadPath.mkdirs();
	        }

	        List<com.model2.mvc.service.domain.ProductImage> imageList = new ArrayList<>();
	        int sortOrder = 1;

	        for (MultipartFile file : uploadFiles) {
	            if (!file.isEmpty()) {
	                String original = file.getOriginalFilename();
	                String ext = (original != null && original.lastIndexOf('.') != -1)
	                        ? original.substring(original.lastIndexOf('.'))
	                        : "";
	                String saved = UUID.randomUUID().toString().replace("-", "") + ext;

	                File target = new File(uploadDir, saved);
	                file.transferTo(target);

	                com.model2.mvc.service.domain.ProductImage image = new com.model2.mvc.service.domain.ProductImage();
	                image.setProdNo(product.getProdNo());
	                image.setImagePath("/upload/" + saved);
	                image.setSortOrd(sortOrder++);
	                
	                imageList.add(image);
	            }
	        }
	        
	        // 4. 이미지 정보 일괄 교체 (기존 이미지 삭제 후 새로 추가)
	        productService.replaceProductImages(product.getProdNo(), imageList);
	    }
	    
	    String safeMenu = (menu == null || menu.trim().isEmpty()) ? "search" : menu.trim();
	    String qs = SearchSupport.toQueryString(search);
	    
	    return "redirect:/product/getProduct?prodNo=" + product.getProdNo()
	            + "&menu=" + safeMenu + "&forceDetail=Y" + (qs != null ? qs : "");
	}

	// =========================
	// 3) 상품 상세 (수정모드/상세보기 분기 + history 쿠키)
	// =========================
	// [의미] 상품 상세. 목록 복귀를 위해 항상 search를 모델에 함께 내려줌
	@GetMapping(value="/getProduct")
	public String getProduct(HttpServletRequest request,
	                         @RequestParam("prodNo") int prodNo,
	                         @RequestParam(value="menu", required=false) String menu,
	                         @ModelAttribute("search") Search search,
	                         Model model) throws Exception {

	    // 검색 상태 정규화(기존 유틸)
	    SearchSupport.normalizeAlways(search, this.pageSize);

	    Product product = productService.findProduct(prodNo);
	    if (product == null) {
	        String target = "manage".equals(menu) ? "manage" : "search";
	        return "redirect:/product/listProduct?menu=" + target;
	    }

	    String menuVal = (menu == null || menu.trim().isEmpty()) ? "search" : menu.trim();

	    model.addAttribute("product", product);
	    model.addAttribute("menu", menuVal);
	    model.addAttribute("search", search);
	    return "forward:/product/productDetailView.jsp";
	}
	
	// 수정폼 전용 (관리자만 접근)
	@GetMapping(value="/updateProductView")
	public String updateProductView(HttpServletRequest request,
	                                @RequestParam("prodNo") int prodNo,
	                                @RequestParam(value="menu", required=false) String menu,
	                                @ModelAttribute("search") Search search,
	                                Model model) throws Exception {

	    // 권한 체크
	    HttpSession session = request.getSession(false);
	    User loginUser = (session != null) ? (User) session.getAttribute("loginUser") : null;
	    if (loginUser == null || !"admin".equals(loginUser.getRole())) {
	        return "redirect:/error/forbidden.jsp";
	    }

	    // 검색 상태 정규화
	    SearchSupport.normalizeAlways(search, this.pageSize);

	    Product product = productService.findProduct(prodNo);
	    if (product == null) {
	        String target = "manage".equals(menu) ? "manage" : "search";
	        return "redirect:/product/listProduct?menu=" + target;
	    }

	    String menuVal = (menu == null || menu.trim().isEmpty()) ? "manage" : menu.trim();

	    // 수정 모드로 addProductView 재사용
	    model.addAttribute("mode", "update");
	    model.addAttribute("product", product);
	    model.addAttribute("menu", menuVal);
	    model.addAttribute("search", search);

	    return "forward:/product/addProductView.jsp";
	}

	// =========================
	// 4) 상품 목록(관리자)
	// =========================
	// [의미] 상품 목록(관리자/일반 공통). "검색 안 함"도 하나의 상태로 처리
	@RequestMapping("/listProduct")
	public String listProduct(@ModelAttribute("search") Search search,
			@RequestParam(value = "menu", required = false) String menu, Model model) throws Exception {

		// 1) 검색 상태 정규화(페이지/사이즈 보정, 키워드/조건 정리)
		SearchSupport.normalizeAlways(search, this.pageSize);

		// 2) 서비스 호출
		Map<String, Object> resultMap = productService.getProductList(search);
		int totalCount = ((Integer) resultMap.get("totalCount")).intValue();
		Page resultPage = new Page(search.getCurrentPage(), totalCount, pageUnit, search.getPageSize());

		// 3) 모델 바인딩(항상 search를 내려줌)
		model.addAttribute("list", resultMap.get("list"));
		model.addAttribute("resultPage", resultPage);
		model.addAttribute("search", search);
		if (menu != null)
			model.addAttribute("menu", menu);

		return "forward:/product/listProductView.jsp";
	}

	// =========================
	// 5) 상품 목록(일반 사용자: 거래중인 상품 제외)
	// =========================
	// [의미] 사용자 소유 상품 목록. 동작은 listProduct와 동일한 패턴
	@RequestMapping("/listProductByUser")
	public String listProductByUser(@ModelAttribute("search") Search search,
			@RequestParam(value = "menu", required = false) String menu, Model model) throws Exception {

		SearchSupport.normalizeAlways(search, this.pageSize);

		Map<String, Object> resultMap = productService.getProductListByUser(search);
		int totalCount = ((Integer) resultMap.get("totalCount")).intValue();
		Page resultPage = new Page(search.getCurrentPage(), totalCount, pageUnit, search.getPageSize());

		model.addAttribute("list", resultMap.get("list"));
		model.addAttribute("resultPage", resultPage);
		model.addAttribute("search", search);
		if (menu != null)
			model.addAttribute("menu", menu);

		return "forward:/product/listProductView.jsp";
	}

	// =========================
	// 6) 목록 단일 진입점 라우터 (JSP -> 여기로 POST)
	// =========================
	// [의미] 목록 진입점. 메뉴에 따라 대상 목록으로 리다이렉트하며 검색컨텍스트를 붙임
	@RequestMapping("/listProductEntry")
	public String listProductEntry(@RequestParam(value = "menu", required = false) String menu,
			@ModelAttribute("search") Search search, RedirectAttributes attrs) throws Exception {

		// 검색 상태 정규화
		SearchSupport.normalizeAlways(search, this.pageSize);

		// 리다이렉트 대상 결정
		boolean manage = "manage".equals(menu);
		String target = manage ? "redirect:/product/listProduct" : "redirect:/product/listProductByUser";

		// 파라미터 구성(페이지 관련은 항상, 조건/키워드는 있을 때만)
		attrs.addAttribute("menu", manage ? "manage" : "search");
		attrs.addAttribute("currentPage", search.getCurrentPage());
		attrs.addAttribute("pageSize", search.getPageSize());
		if (search.getSearchCondition() != null)
			attrs.addAttribute("searchCondition", search.getSearchCondition());
		if (search.getSearchKeyword() != null)
			attrs.addAttribute("searchKeyword", search.getSearchKeyword());

		return target;
	}

	// =========================
	// Web-layer helpers (액션 로직 이식)
	// =========================
	private String cookiePath(HttpServletRequest request) {
		String ctx = request.getContextPath();
		return (ctx == null || ctx.isEmpty()) ? "/" : ctx;
	}

	private String readCookie(HttpServletRequest request, String name) {
		Cookie[] cs = request.getCookies();
		if (cs == null)
			return null;
		for (Cookie c : cs) {
			if (name.equals(c.getName())) {
				try {
					return URLDecoder.decode(c.getValue(), StandardCharsets.UTF_8.name());
				} catch (Exception ignore) {
					return c.getValue();
				}
			}
		}
		return null;
	}

	private void writeCookie(HttpServletRequest request, HttpServletResponse response, String name, String value,
			int maxAgeSec) {
		try {
			value = URLEncoder.encode(value, StandardCharsets.UTF_8.name());
		} catch (Exception ignore) {
		}
		Cookie c = new Cookie(name, value);
		c.setPath(cookiePath(request));
		c.setMaxAge(maxAgeSec);
		response.addCookie(c);
	}

	/** history 쿠키 갱신 (액션과 동일): CSV(최신 우선), 30일 보관 + request 속성(histVal) 제공 */
	private void updateHistoryCookie(HttpServletRequest request, HttpServletResponse response, int prodNo) {
		String current = readCookie(request, "history"); // 디코드 상태
		LinkedHashSet<String> ordered = new LinkedHashSet<>();
		if (current != null && !current.isEmpty()) {
			if (current.contains(",")) {
				for (String s : current.split(",")) {
					String t = s.trim();
					if (!t.isEmpty())
						ordered.add(t);
				}
			} else {
				Matcher m = Pattern.compile("\\d{5,}").matcher(current);
				while (m.find()) {
					ordered.add(m.group());
				}
			}
		}
		String pn = String.valueOf(prodNo);
		ordered.remove(pn);

		LinkedHashSet<String> newestFirst = new LinkedHashSet<>();
		newestFirst.add(pn); // 이번 상품이 맨 앞
		newestFirst.addAll(ordered); // 그 다음 기존 순서

		String joined = String.join(",", newestFirst);
		writeCookie(request, response, "history", joined, 60 * 60 * 24 * 30);
		request.setAttribute("histVal", joined);
	}

	private boolean hasAny(String sc, String sk, Integer currentPage, Integer page, Integer size) {
		return (sc != null && !sc.isEmpty()) || (sk != null && !sk.isEmpty()) || (currentPage != null) || (page != null)
				|| (size != null);
	}

	private Search buildSearch(String sc, String sk, Integer cp, Integer p, Integer size) {
		Search s = new Search();
		int current = (cp != null) ? cp : (p != null ? p : 1);
		if (current <= 0)
			current = 1;
		int ps = (size != null && size > 0) ? size : this.pageSize;
		s.setSearchCondition(sc);
		s.setSearchKeyword(sk);
		s.setCurrentPage(current);
		s.setPageSize(ps);
		return s;
	}
}
