package com.model2.mvc.web.product;

import java.util.HashMap;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.model2.mvc.common.Page;
import com.model2.mvc.common.Search;
import com.model2.mvc.common.web.SearchSupport;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.User;
import com.model2.mvc.service.product.ProductService;

@RestController
@RequestMapping("/product/json")
public class ProductRestController {

    @Autowired
    @Qualifier("productServiceImpl")
    private ProductService productService;

    @Value("#{commonProperties['pageUnit']}")
    private int pageUnit;

    @Value("#{commonProperties['pageSize']}")
    private int pageSize;

    public ProductRestController() {
        System.out.println(this.getClass());
    }

    // =========================
    // 1) 상품 등록
    // 경로 동일: POST /product/json/addProduct
    // 파일 업로드 로직/권한 체크 그대로 유지
    // 기존 forward는 JSON의 "view" 정보로 전달
    // =========================
    @PostMapping("/addProduct")
    public Map<String, Object> addProduct(HttpServletRequest request,
                                          @ModelAttribute("product") Product product,
                                          @RequestParam(value = "imageFile", required = false) MultipartFile imageFile)
            throws Exception {

        HttpSession session = request.getSession(false);
        User loginUser = (session != null) ? (User) session.getAttribute("loginUser") : null;
        if (loginUser == null || "user".equals(loginUser.getRole())) {
            Map<String, Object> res = new HashMap<>();
            res.put("redirect", "/error/forbidden.jsp");
            res.put("forbidden", true);
            return res;
        }

        if (imageFile != null && !imageFile.isEmpty()) {
            String uploadDir = request.getServletContext().getRealPath("/upload");
            java.nio.file.Files.createDirectories(java.nio.file.Paths.get(uploadDir));

            String original = imageFile.getOriginalFilename();
            String ext = (original != null && original.lastIndexOf('.') != -1)
                    ? original.substring(original.lastIndexOf('.')) : "";
            String saved = java.util.UUID.randomUUID().toString().replace("-", "") + ext;

            java.io.File target = new java.io.File(uploadDir, saved);
            imageFile.transferTo(target);

            product.setFileName("/upload/" + saved);
        }

        if (product.getPrice() < 0) {
            product.setPrice(0);
        }

        productService.insertProduct(product);

        Map<String, Object> res = new HashMap<>();
        res.put("product", product);
        res.put("view", "/product/productResult.jsp");
        return res;
    }

    // =========================
    // 2) 상품 수정
    // 경로 동일: POST /product/json/updateProduct
    // 기존 redirect는 JSON의 "redirect"로 전달
    // =========================
    @PostMapping("/updateProduct")
    public Map<String, Object> updateProduct(HttpServletRequest request,
                                             @ModelAttribute("product") Product product,
                                             @RequestParam(value = "imageFile", required = false) MultipartFile imageFile)
            throws Exception {

        HttpSession session = request.getSession(false);
        User loginUser = (session != null) ? (User) session.getAttribute("loginUser") : null;
        if (loginUser == null || "user".equals(loginUser.getRole())) {
            Map<String, Object> res = new HashMap<>();
            res.put("redirect", "/error/forbidden.jsp");
            res.put("forbidden", true);
            return res;
        }

        if (product.getPrice() < 0) {
            product.setPrice(0);
        }

        Product before = productService.findProduct(product.getProdNo());

        if (imageFile != null && !imageFile.isEmpty()) {
            String uploadDir = request.getServletContext().getRealPath("/upload");
            java.nio.file.Files.createDirectories(java.nio.file.Paths.get(uploadDir));

            String original = imageFile.getOriginalFilename();
            String ext = (original != null && original.lastIndexOf('.') != -1)
                    ? original.substring(original.lastIndexOf('.')) : "";
            String saved = java.util.UUID.randomUUID().toString().replace("-", "") + ext;

            java.io.File target = new java.io.File(uploadDir, saved);
            imageFile.transferTo(target);

            product.setFileName("/upload/" + saved);
        } else {
            if (before != null) {
                product.setFileName(before.getFileName());
            }
        }

        productService.updateProduct(product);

        Map<String, Object> res = new HashMap<>();
        res.put("success", true);
        res.put("redirect", "/product/getProduct?prodNo=" + product.getProdNo() + "&menu=search");
        return res;
    }

    // =========================
    // 3) 상품 상세
    // 경로 동일: GET /product/json/getProduct?prodNo=...&menu=...&code=...
    // 기존 분기(수정모드/상세보기) 유지, 뷰 경로를 JSON으로 알려줌
    // =========================
    @GetMapping("/getProduct")
    public Map<String, Object> getProduct(HttpServletRequest request,
                                          @RequestParam("prodNo") int prodNo,
                                          @RequestParam(value = "menu", required = false) String menu,
                                          @RequestParam(value = "code", required = false) String code,
                                          @ModelAttribute("search") Search search)
            throws Exception {

        SearchSupport.normalizeAlways(search, this.pageSize);

        Product product = productService.findProduct(prodNo);
        Map<String, Object> res = new HashMap<>();
        if (product == null) {
            res.put("redirect", "/product/listProduct?menu=search");
            return res;
        }

        boolean isCodeEmpty = (code == null || code.trim().isEmpty());
        if ("manage".equals(menu) && isCodeEmpty) {
            res.put("mode", "update");
            res.put("product", product);
            res.put("search", search);
            res.put("view", "/product/addProductView.jsp");
        } else {
            res.put("product", product);
            res.put("menu", "search");
            res.put("search", search);
            res.put("view", "/product/productDetailView.jsp");
        }
        return res;
    }

    // =========================
    // 4) 상품 목록(관리자/공통)
    // 경로 동일: GET /product/json/listProduct
    // =========================
    @GetMapping("/listProduct")
    public Map<String, Object> listProduct(@ModelAttribute("search") Search search,
                                           @RequestParam(value = "menu", required = false) String menu)
            throws Exception {

        SearchSupport.normalizeAlways(search, this.pageSize);

        Map<String, Object> resultMap = productService.getProductList(search);
        int totalCount = ((Integer) resultMap.get("totalCount")).intValue();
        Page resultPage = new Page(search.getCurrentPage(), totalCount, pageUnit, search.getPageSize());

        Map<String, Object> res = new HashMap<>();
        res.put("list", resultMap.get("list"));
        res.put("resultPage", resultPage);
        res.put("search", search);
        if (menu != null) {
            res.put("menu", menu);
        }
        return res;
    }

    // =========================
    // 5) 상품 목록(일반 사용자: 거래중 제외)
    // 경로 동일: GET /product/json/listProductByUser
    // =========================
    @GetMapping("/listProductByUser")
    public Map<String, Object> listProductByUser(@ModelAttribute("search") Search search,
                                                 @RequestParam(value = "menu", required = false) String menu)
            throws Exception {

        SearchSupport.normalizeAlways(search, this.pageSize);

        Map<String, Object> resultMap = productService.getProductListByUser(search);
        int totalCount = ((Integer) resultMap.get("totalCount")).intValue();
        Page resultPage = new Page(search.getCurrentPage(), totalCount, pageUnit, search.getPageSize());

        Map<String, Object> res = new HashMap<>();
        res.put("list", resultMap.get("list"));
        res.put("resultPage", resultPage);
        res.put("search", search);
        if (menu != null) {
            res.put("menu", menu);
        }
        return res;
    }

    // =========================
    // 6) 목록 단일 진입점 (라우팅)
    // 경로 동일: GET /product/json/listProductEntry
    // 기존 redirect를 JSON "redirect"로 반환
    // =========================
    @GetMapping("/listProductEntry")
    public Map<String, Object> listProductEntry(@RequestParam(value = "menu", required = false) String menu,
                                                @ModelAttribute("search") Search search)
            throws Exception {

        SearchSupport.normalizeAlways(search, this.pageSize);

        boolean manage = "manage".equals(menu);
        StringBuilder q = new StringBuilder();
        q.append("?menu=").append(manage ? "manage" : "search");
        q.append("&currentPage=").append(search.getCurrentPage());
        q.append("&pageSize=").append(search.getPageSize());
        if (search.getSearchCondition() != null) {
            q.append("&searchCondition=").append(search.getSearchCondition());
        }
        if (search.getSearchKeyword() != null) {
            q.append("&searchKeyword=").append(search.getSearchKeyword());
        }

        String target = (manage ? "/product/listProduct" : "/product/listProductByUser") + q.toString();

        Map<String, Object> res = new HashMap<>();
        res.put("redirect", target);
        res.put("search", search);
        return res;
    }
}
