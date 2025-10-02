package com.model2.mvc.web.purchase;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import com.model2.mvc.common.Page;
import com.model2.mvc.common.Search;
import com.model2.mvc.common.web.SearchSupport;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.Purchase;
import com.model2.mvc.service.domain.User;
import com.model2.mvc.service.product.ProductService;
import com.model2.mvc.service.purchase.PurchaseService;

@RestController
@RequestMapping("/purchase/json")
public class PurchaseRestController {

    @Autowired
    @Qualifier("purchaseServiceImpl")
    private PurchaseService purchaseService;

    @Autowired
    @Qualifier("productServiceImpl")
    private ProductService productService;

    @Value("#{commonProperties['pageUnit']}")
    private int pageUnit;

    @Value("#{commonProperties['pageSize']}")
    private int pageSize;

    public PurchaseRestController() {
        System.out.println(this.getClass());
    }

    // =========================================================================
    // 1) 구매 입력 화면 : GET /purchase/json/addPurchaseView?prodNo=...
    //    (원래 forward 하던 JSP 경로를 view 키로 반환, product/loginUser 포함)
    // =========================================================================
    @GetMapping("/addPurchaseView")
    public Map<String, Object> addPurchaseView(@RequestParam("prodNo") int prodNo,
                                               HttpSession session) throws Exception {
        Product product = productService.findProduct(prodNo);
        User loginUser = (User) (session != null ? session.getAttribute("loginUser") : null);

        Map<String, Object> res = new HashMap<>();
        res.put("product", product);
        res.put("loginUser", loginUser);
        res.put("view", "/purchase/purchaseView.jsp");
        return res;
    }

    // =========================================================================
    // 2) 구매 등록 : POST /purchase/json/addPurchase
    //    폼 전체를 Purchase로 바인딩(원본과 동일), 세션의 loginUser를 buyer로 세팅
    //    등록 후 상세로 redirect URL 반환
    // =========================================================================
    @PostMapping("/addPurchase")
    public Map<String, Object> addPurchase(HttpSession session,
                                           @ModelAttribute("purchase") Purchase purchase) throws Exception {

        User loginUser = (User) (session != null ? session.getAttribute("loginUser") : null);
        if (loginUser != null) {
            purchase.setBuyer(loginUser);
        }

        String dd = purchase.getDivyDate();
        purchase.setDivyDate((dd != null && !dd.trim().isEmpty()) ? dd.trim() : null);

        int tranNo = purchaseService.addPurchase(purchase);

        Map<String, Object> res = new HashMap<>();
        res.put("tranNo", tranNo);
        res.put("redirect", "/purchase/getPurchase?tranNo=" + tranNo);
        return res;
    }

    // =========================================================================
    // 3) 구매 상세 : GET /purchase/json/getPurchase?tranNo=...
    //    (검색 컨텍스트 Search를 그대로 받고 normalize, purchase+search 반환)
    //    원본의 redirect:/listPurchase 흐름은 redirect 키로 전달
    // =========================================================================
    @GetMapping("/getPurchase")
    public Map<String, Object> getPurchase(@RequestParam("tranNo") int tranNo,
                                           @ModelAttribute("search") Search search) throws Exception {

        SearchSupport.normalizeAlways(search, this.pageSize);

        Purchase purchase = purchaseService.getPurchase(tranNo);

        Map<String, Object> res = new HashMap<>();
        if (purchase == null) {
            res.put("redirect", "/listPurchase"); // 원본 경로 그대로
            return res;
        }

        res.put("purchase", purchase);
        res.put("search", search);
        res.put("view", "/purchase/purchaseDetailView.jsp");
        return res;
    }

    // =========================================================================
    // 4) 구매 수정 화면 : GET /purchase/json/updatePurchaseView?tranNo=...
    //    (purchase+search 반환, view 키로 JSP 경로 안내)
    // =========================================================================
    @GetMapping("/updatePurchaseView")
    public Map<String, Object> updatePurchaseView(@RequestParam("tranNo") int tranNo,
                                                  @ModelAttribute("search") Search search) throws Exception {

        SearchSupport.normalizeAlways(search, this.pageSize);

        Purchase purchase = purchaseService.getPurchase(tranNo);
        Map<String, Object> res = new HashMap<>();
        if (purchase == null) {
            res.put("redirect", "/purchase/listPurchase");
            return res;
        }

        res.put("purchase", purchase);
        res.put("search", search);
        res.put("view", "/purchase/purchaseEditView.jsp");
        return res;
    }

    // =========================================================================
    // 5) 구매 수정 : POST /purchase/json/updatePurchase
    //    (권한/소유자 확인 로직은 원본과 동일, 성공 시 상세로 redirect)
    // =========================================================================
    @PostMapping("/updatePurchase")
    public Map<String, Object> updatePurchase(@ModelAttribute("purchase") Purchase form,
                                              HttpSession session,
                                              HttpServletResponse response) throws Exception {

        final int tranNo = form.getTranNo();
        if (tranNo <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return null;
        }

        User loginUser = (User) (session != null ? session.getAttribute("loginUser") : null);
        Purchase db = purchaseService.getPurchase(tranNo);
        if (db == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return null;
        }
        boolean isOwner = (loginUser != null && db.getBuyer() != null && loginUser.getUserId() != null
                && loginUser.getUserId().equals(db.getBuyer().getUserId()));
        if (!isOwner) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }

        String dd = form.getDivyDate();
        form.setDivyDate((dd != null && !dd.trim().isEmpty()) ? dd.trim() : null);

        purchaseService.updatePurchase(form);

        Map<String, Object> res = new HashMap<>();
        res.put("redirect", "/purchase/getPurchase?tranNo=" + tranNo);
        res.put("success", true);
        return res;
    }

    // =========================================================================
    // 6) 내 구매 목록 : GET /purchase/json/listPurchase
    //    (list, resultPage, search 반환 — 키 이름 원본 유지)
    // =========================================================================
    @GetMapping(value = "/listPurchase", produces = "application/json; charset=UTF-8")
    public Map<String, Object> listPurchase(@ModelAttribute("search") Search search,
                                            HttpSession session) throws Exception {

        SearchSupport.normalizeAlways(search, this.pageSize);

        User loginUser = (User) (session != null ? session.getAttribute("loginUser") : null);
        String buyerId = (loginUser != null ? loginUser.getUserId() : null);

        Map<String, Object> map = purchaseService.getPurchaseList(buyerId, search);

        int totalCount = ((Integer) map.get("totalCount")).intValue();
        Page resultPage = new Page(search.getCurrentPage(), totalCount, pageUnit, search.getPageSize());

        Map<String, Object> res = new HashMap<>();
        res.put("list", map.get("list"));
        res.put("resultPage", resultPage);
        res.put("search", search);
        res.put("view", "/purchase/purchaseProductView.jsp");
        return res;
    }

	/*
	 * // =========================================================================
	 * // 7) 판매 목록(관리자) : GET /purchase/json/listSale // (원본처럼 관리자만 허용, map+search
	 * 반환) //
	 * =========================================================================
	 * 
	 * @GetMapping("/listSale") public Map<String, Object> listSale(HttpSession
	 * session,
	 * 
	 * @RequestParam(value = "currentPage", required = false) Integer currentPage,
	 * 
	 * @RequestParam(value = "page", required = false) Integer page,
	 * 
	 * @RequestParam(value = "pageSize", required = false) Integer size,
	 * HttpServletResponse response) throws Exception {
	 * 
	 * User loginUser = (User) (session != null ? session.getAttribute("loginUser")
	 * : null); boolean isAdmin = (loginUser != null && loginUser.getRole() != null
	 * && !"user".equals(loginUser.getRole())); if (!isAdmin) {
	 * response.sendError(HttpServletResponse.SC_FORBIDDEN); return null; }
	 * 
	 * int cp = (currentPage != null ? currentPage : page); if (cp <= 0) cp = 1; int
	 * ps = (size != null && size > 0) ? size : this.pageSize;
	 * 
	 * Search search = new Search(); search.setCurrentPage(cp);
	 * search.setPageSize(ps);
	 * 
	 * Map<String, Object> map = purchaseService.getSaleList(search);
	 * 
	 * Map<String, Object> res = new HashMap<>(); res.put("map", map);
	 * res.put("search", search); res.put("view", "/purchase/saleListView.jsp");
	 * return res; }
	 */

    // =========================================================================
    // 8) 거래상태 변경 : GET /purchase/json/updateTranCode?tranNo=...&tranCode=...
    //    (원본 규칙 동일: 일반= SHP→DLV, 관리자= BEF→SHP, 완료 후 listPurchase로 redirect)
    // =========================================================================
    @GetMapping("/updateTranCode")
    public Map<String, Object> updateTranCode(@RequestParam("tranNo") int tranNo,
                                              @RequestParam("tranCode") String toCode,
                                              HttpSession session,
                                              HttpServletResponse response) throws Exception {

        User loginUser = (User) (session != null ? session.getAttribute("loginUser") : null);

        Purchase purchase = purchaseService.getPurchase(tranNo);
        if (purchase == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return null;
        }

        boolean isAdmin = (loginUser != null && loginUser.getRole() != null && !"user".equals(loginUser.getRole()));
        boolean isOwner = (loginUser != null && purchase.getBuyer() != null && loginUser.getUserId() != null
                && loginUser.getUserId().equals(purchase.getBuyer().getUserId()));

        if (!isAdmin) {
            if (isOwner && Purchase.TRAN_SHIPPING.equals(purchase.getTranCode())
                    && Purchase.TRAN_DELIVERY.equals(toCode)) {
                purchaseService.updateTranCode(tranNo, Purchase.TRAN_DELIVERY);
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return null;
            }
        } else {
            if (Purchase.TRAN_BEFORE.equals(purchase.getTranCode())
                    && Purchase.TRAN_SHIPPING.equals(toCode)) {
                purchaseService.updateTranCode(tranNo, Purchase.TRAN_SHIPPING);
            }
        }

        Map<String, Object> res = new HashMap<>();
        res.put("redirect", "/purchase/listPurchase");
        return res;
    }

    // =========================================================================
    // 9) (관리자) 상품 기준 최신 거래를 SHP로 : GET /purchase/json/updateTranCodeByProd?prodNo=...&page=...
    //    (원본과 동일하게 처리 후 /product/listProduct?menu=manage&page=.. 로 redirect)
    // =========================================================================
    @GetMapping("/updateTranCodeByProd")
    public Map<String, Object> updateTranCodeByProd(@RequestParam("prodNo") int prodNo,
                                                    @RequestParam(value = "page", required = false) Integer page,
                                                    HttpSession session) throws Exception {

        User loginUser = (User) (session != null ? session.getAttribute("loginUser") : null);
        boolean isAdmin = (loginUser != null && loginUser.getRole() != null && !"user".equals(loginUser.getRole()));
        if (!isAdmin) {
            Map<String, Object> res = new HashMap<>();
            res.put("redirect", "/purchase/listProduct?menu=search");
            return res;
        }

        int tranNo = purchaseService.findPurchaseByProdNo(prodNo);
        int goPage = (page != null && page > 0) ? page : 1;

        if (tranNo > 0) {
            purchaseService.updateTranCode(tranNo, Purchase.TRAN_SHIPPING);
        }

        Map<String, Object> res = new HashMap<>();
        res.put("redirect", "/product/listProduct?menu=manage&page=" + goPage);
        return res;
    }
}
