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
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.model2.mvc.common.Page;
import com.model2.mvc.common.Search;
import com.model2.mvc.common.web.SearchSupport;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.User;
import com.model2.mvc.service.product.ProductService;

@Controller
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
    @RequestMapping("/addProduct.do")
    public String addProduct(HttpServletRequest request,
                             @ModelAttribute("product") Product product,
                             Model model) throws Exception {

        // 권한 체크(관리자만) : 기존 로직 유지
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || "user".equals(user.getRole())) {
            return "redirect:/error/forbidden.jsp";
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
    @RequestMapping("/updateProduct.do")
    public String updateProduct(HttpServletRequest request,
                                @ModelAttribute("product") Product product) throws Exception {

        // 권한 체크(관리자만)
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || "user".equals(user.getRole())) {
            return "redirect:/error/forbidden.jsp";
        }

        // 가격 보정(필요 시)
        if (product.getPrice() < 0) {
            product.setPrice(0);
        }

        // 수정 처리
        productService.updateProduct(product);

        // 수정 후 상세로(기존 리다이렉트 유지)
        return "redirect:/getProduct.do?prodNo=" + product.getProdNo() + "&menu=search";
    }

    // =========================
    // 3) 상품 상세 (수정모드/상세보기 분기 + history 쿠키)
    // =========================
    // [의미] 상품 상세. 목록 복귀를 위해 항상 search를 모델에 함께 내려줌
    @RequestMapping("/getProduct.do")
    public String getProduct(HttpServletRequest request, HttpServletResponse response,
                             @RequestParam("prodNo") int prodNo,
                             @RequestParam(value="menu", required=false) String menu,
                             @RequestParam(value="code", required=false) String code,
                             @ModelAttribute("search") Search search,
                             Model model) throws Exception {

        // 검색 상태 정규화
        SearchSupport.normalizeAlways(search, this.pageSize);

        // 상세 조회
        Product product = productService.findProduct(prodNo);
        if (product == null) {
            return "redirect:/listProduct.do?menu=search";
        }

        // 상세 보기/수정 모드 분기(기존 로직 유지)
        boolean isCodeEmpty = (code == null || code.trim().isEmpty());
        if ("manage".equals(menu) && isCodeEmpty) {
            // 수정 모드로 등록폼 재사용
            model.addAttribute("mode", "update");
            model.addAttribute("product", product);
            model.addAttribute("search", search);
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
    @RequestMapping("/listProduct.do")
    public String listProduct(@ModelAttribute("search") Search search,
                              @RequestParam(value="menu", required=false) String menu,
                              Model model) throws Exception {

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
        if (menu != null) model.addAttribute("menu", menu);

        return "forward:/product/listProductView.jsp";
    }

    // =========================
    // 5) 상품 목록(일반 사용자: 거래중인 상품 제외)
    // =========================
    // [의미] 사용자 소유 상품 목록. 동작은 listProduct와 동일한 패턴
    @RequestMapping("/listProductByUser.do")
    public String listProductByUser(@ModelAttribute("search") Search search,
                                    @RequestParam(value="menu", required=false) String menu,
                                    Model model) throws Exception {

        SearchSupport.normalizeAlways(search, this.pageSize);

        Map<String, Object> resultMap = productService.getProductListByUser(search);
        int totalCount = ((Integer) resultMap.get("totalCount")).intValue();
        Page resultPage = new Page(search.getCurrentPage(), totalCount, pageUnit, search.getPageSize());

        model.addAttribute("list", resultMap.get("list"));
        model.addAttribute("resultPage", resultPage);
        model.addAttribute("search", search);
        if (menu != null) model.addAttribute("menu", menu);

        return "forward:/product/listProductView.jsp";
    }

    // =========================
    // 6) 목록 단일 진입점 라우터 (JSP -> 여기로 POST)
    // =========================
    // [의미] 목록 진입점. 메뉴에 따라 대상 목록으로 리다이렉트하며 검색컨텍스트를 붙임
    @RequestMapping("/listProductEntry.do")
    public String listProductEntry(@RequestParam(value="menu", required=false) String menu,
                                   @ModelAttribute("search") Search search,
                                   RedirectAttributes attrs) throws Exception {

        // 검색 상태 정규화
        SearchSupport.normalizeAlways(search, this.pageSize);

        // 리다이렉트 대상 결정
        boolean manage = "manage".equals(menu);
        String target = manage ? "redirect:/listProduct.do" : "redirect:/listProductByUser.do";

        // 파라미터 구성(페이지 관련은 항상, 조건/키워드는 있을 때만)
        attrs.addAttribute("menu", manage ? "manage" : "search");
        attrs.addAttribute("currentPage", search.getCurrentPage());
        attrs.addAttribute("pageSize", search.getPageSize());
        if (search.getSearchCondition() != null) attrs.addAttribute("searchCondition", search.getSearchCondition());
        if (search.getSearchKeyword()   != null) attrs.addAttribute("searchKeyword",   search.getSearchKeyword());

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
        if (cs == null) return null;
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

    private void writeCookie(HttpServletRequest request, HttpServletResponse response,
                             String name, String value, int maxAgeSec) {
        try {
            value = URLEncoder.encode(value, StandardCharsets.UTF_8.name());
        } catch (Exception ignore) { }
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
                    if (!t.isEmpty()) ordered.add(t);
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
        newestFirst.add(pn);          // 이번 상품이 맨 앞
        newestFirst.addAll(ordered);  // 그 다음 기존 순서

        String joined = String.join(",", newestFirst);
        writeCookie(request, response, "history", joined, 60 * 60 * 24 * 30);
        request.setAttribute("histVal", joined);
    }

    private boolean hasAny(String sc, String sk, Integer currentPage, Integer page, Integer size) {
        return (sc != null && !sc.isEmpty())
            || (sk != null && !sk.isEmpty())
            || (currentPage != null)
            || (page != null)
            || (size != null);
    }

    private Search buildSearch(String sc, String sk, Integer cp, Integer p, Integer size) {
        Search s = new Search();
        int current = (cp != null) ? cp : (p != null ? p : 1);
        if (current <= 0) current = 1;
        int ps = (size != null && size > 0) ? size : this.pageSize;
        s.setSearchCondition(sc);
        s.setSearchKeyword(sk);
        s.setCurrentPage(current);
        s.setPageSize(ps);
        return s;
    }
}
