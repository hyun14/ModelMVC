package com.model2.mvc.web.product;

import java.net.URLEncoder;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashSet;
import java.util.Map;
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
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.model2.mvc.common.Page;
import com.model2.mvc.common.Search;
import com.model2.mvc.common.web.SearchSupport;
import com.model2.mvc.service.domain.Product;
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
	@RequestMapping("/addProduct")
	public String addProduct(HttpServletRequest request, @ModelAttribute("product") Product product,
			@RequestParam(value = "imageFile", required = false) MultipartFile imageFile, Model model) throws Exception {

		// 권한 체크(관리자만) : 기존 로직 유지
		HttpSession session = request.getSession(false);
		User user = (session != null) ? (User) session.getAttribute("loginUser") : null;
		if (user == null || "user".equals(user.getRole())) {
			return "redirect:/error/forbidden.jsp";
		}

		if (imageFile != null && !imageFile.isEmpty()) {
			// 2) 업로드 폴더(아주 단순 버전: 웹앱 내부 /upload)
			String uploadDir = request.getServletContext().getRealPath("/upload");
			java.nio.file.Files.createDirectories(java.nio.file.Paths.get(uploadDir));

			// 3) 안전한 파일명 생성 (원본 확장자 유지, 이름은 UUID)
			String original = imageFile.getOriginalFilename();
			String ext = (original != null && original.lastIndexOf('.') != -1)
					? original.substring(original.lastIndexOf('.'))
					: "";
			String saved = java.util.UUID.randomUUID().toString().replace("-", "") + ext;

			// 4) 실제 저장
			java.io.File target = new java.io.File(uploadDir, saved);
			imageFile.transferTo(target);

			// 5) DB에는 접근 경로(문자열)만 저장
			product.setFileName("/upload/" + saved);
		}

		// 가격 등 숫자 필드가 비었을 때 바인딩 실패를 피하고 싶으면 여기서 보정
		// (또는 @InitBinder에서 커스텀 에디터 사용)
		if (product.getPrice() < 0) {
			product.setPrice(0);
		}

		// 등록 처리(서비스 메서드명은 기존 유지)
		productService.insertProduct(product);

		// 결과 화면으로(기존 포워드 유지)
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
	@RequestMapping("/updateProduct")
	public String updateProduct(HttpServletRequest request,
			@RequestParam(value = "menu", required = false) String menu,
            @ModelAttribute("search") Search search,
			@ModelAttribute("product") Product product,
			@RequestParam(value = "imageFile", required = false) MultipartFile imageFile)
			throws Exception {
		
		// [권한 체크] : 관리자만 접근 가능 (기존 로직 유지)
		HttpSession session = request.getSession(false);
		User user = (session != null) ? (User) session.getAttribute("loginUser") : null;
				
		if (user == null || "user".equals(user.getRole())) {
			return "redirect:/error/forbidden.jsp";
		}

		// [가격 보정] : 음수 방지 (기존 로직 유지)
		if (product.getPrice() < 0) {
			product.setPrice(0);
		}

		// [기존 이미지 경로 보존 준비] : 새 파일이 없을 때를 대비해 기존 DB값을 조회
		// - 폼에서 fileName이 비어 들어와도, 새 이미지가 없다면 기존 DB값으로 유지
		Product before = productService.findProduct(product.getProdNo());

		// [이미지 업로드 처리] : 이미지가 넘어온 경우에만 저장 및 경로 갱신
		if (imageFile != null && !imageFile.isEmpty()) {
			// 1) 업로드 대상 폴더(/upload)의 실제 경로 확보 및 생성
			String uploadDir = request.getServletContext().getRealPath("/upload");
			java.nio.file.Files.createDirectories(java.nio.file.Paths.get(uploadDir));

			// 2) 안전한 저장 파일명 생성(확장자 유지, UUID 기반)
			String original = imageFile.getOriginalFilename();
			String ext = (original != null && original.lastIndexOf('.') != -1)
					? original.substring(original.lastIndexOf('.'))
					: "";
			String saved = java.util.UUID.randomUUID().toString().replace("-", "") + ext;

			// 3) 실제 파일 저장
			java.io.File target = new java.io.File(uploadDir, saved);
			imageFile.transferTo(target);

			// 4) DB에는 접근용 경로만 저장(문자열)
			product.setFileName("/upload/" + saved);

		} else {
			// [새 이미지 미업로드 시] : 기존 fileName을 유지하도록 보정
			// - 폼에서 fileName이 비어 들어와도 여기서 덮어써서 기존 값 보존
			if (before != null) {
				product.setFileName(before.getFileName());
			}
		}

		// [수정 처리] : 서비스 호출 (기존 로직 유지)
		productService.updateProduct(product);
		
		String safeMenu = (menu == null || menu.trim().isEmpty()) ? "search" : menu.trim();
		String qs = SearchSupport.toQueryString(search);
		
		// [리다이렉트] : 수정 후 상세 화면으로 이동 (기존 규칙 유지)
		return "redirect:/product/getProduct?prodNo=" + product.getProdNo()
        + "&menu=" + safeMenu + "&forceDetail=Y" + (qs != null ? qs : "");
	}

	// =========================
	// 3) 상품 상세 (수정모드/상세보기 분기 + history 쿠키)
	// =========================
	// [의미] 상품 상세. 목록 복귀를 위해 항상 search를 모델에 함께 내려줌
	@RequestMapping("/getProduct")
	public String getProduct(HttpServletRequest request, HttpServletResponse response,
			@RequestParam("prodNo") int prodNo, @RequestParam(value = "menu", required = false) String menu,
			@RequestParam(value = "code", required = false) String code, @ModelAttribute("search") Search search,
			@RequestParam(value = "forceDetail", required = false) String forceDetail,
			Model model) throws Exception {

		// 검색 상태 정규화
		SearchSupport.normalizeAlways(search, this.pageSize);

		// 상세 조회
		Product product = productService.findProduct(prodNo);
		if (product == null) {
			if ("search".equals(menu)) {
				return "redirect:/product/listProduct?menu=search";
			} else {
				return "redirect:/product/listProduct?menu=manage";
			}
		}

		// 상세 보기/수정 모드 분기(기존 로직 유지)
		boolean isCodeEmpty = (code == null || code.trim().isEmpty());
		boolean skipEdit = "Y".equalsIgnoreCase(forceDetail);
		
		if ("manage".equals(menu) && isCodeEmpty && !skipEdit) {
			// 수정 모드로 등록폼 재사용
			model.addAttribute("mode", "update");
			model.addAttribute("product", product);
			model.addAttribute("search", search);
			model.addAttribute("menu", menu);
			return "forward:/product/addProductView.jsp";
		} else {
			// 상세보기
			model.addAttribute("product", product);
			model.addAttribute("menu", "search");
			model.addAttribute("search", search);
			return "forward:/product/productDetailView.jsp";
		}
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
