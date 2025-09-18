package com.model2.mvc.web.purchase;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

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

import com.model2.mvc.common.Page;
import com.model2.mvc.common.Search;
import com.model2.mvc.common.web.SearchSupport;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.Purchase;
import com.model2.mvc.service.domain.User;
import com.model2.mvc.service.product.ProductService;
import com.model2.mvc.service.purchase.PurchaseService;

@Controller
public class PurchaseController {

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

    // ===== 공통: 페이징 유틸 (User/Product 컨트롤러와 동일 스타일) =====
    private int resolveCurrentPage(Integer currentPage, Integer page) {
        Integer cp = (currentPage != null ? currentPage : page);
        return (cp == null || cp <= 0) ? 1 : cp;
    }

    private int resolvePageSize(Integer size) {
        return (size == null || size <= 0) ? this.pageSize : size;
    }

    // =========================================================================
    // 1) 구매 입력 화면 : /addPurchaseView.do  (액션: AddPurchaseViewAction)
    //    - 입력: prodNo
    //    - 모델: product, loginUser
    //    - 리턴: forward:/purchase/purchaseView.jsp
    // =========================================================================
    @RequestMapping("/addPurchaseView.do")
    public String addPurchaseView(@RequestParam("prodNo") int prodNo,
                                  HttpSession session,
                                  Model model) throws Exception {

        // 액션과 동일: 화면에 상품/로그인 사용자 전달
        Product product = productService.findProduct(prodNo);
        model.addAttribute("product", product);

        User loginUser = (User) (session != null ? session.getAttribute("user") : null);
        model.addAttribute("loginUser", loginUser);

        return "forward:/purchase/purchaseView.jsp";
    }

    // =========================================================================
    // 2) 구매 등록 : /addPurchase.do  (액션: AddPurchaseAction)
    //    - 입력: prodNo, paymentOption, receiverName, receiverPhone, divyAddr, divyRequest, divyDate
    //    - 세션 buyerId 사용
    //    - 리턴: redirect:/getPurchase.do?tranNo=...
    // =========================================================================
    @RequestMapping("/addPurchase.do")
    public String addPurchase(HttpSession session,
                              @RequestParam("prodNo") int prodNo,
                              @RequestParam(value="paymentOption", required=false) String paymentOption,
                              @RequestParam(value="receiverName",   required=false) String receiverName,
                              @RequestParam(value="receiverPhone",  required=false) String receiverPhone,
                              @RequestParam(value="divyAddr",       required=false) String divyAddr,
                              @RequestParam(value="divyRequest",    required=false) String divyRequest,
                              @RequestParam(value="divyDate",       required=false) String divyDate) throws Exception {

        User loginUser = (User) (session != null ? session.getAttribute("user") : null);

        Purchase vo = new Purchase();
        Product p = new Product();
        p.setProdNo(prodNo);
        vo.setPurchaseProd(p);

        if (loginUser != null) {
            vo.setBuyer(loginUser);
        }
        vo.setPaymentOption(paymentOption);
        vo.setReceiverName(receiverName);
        vo.setReceiverPhone(receiverPhone);
        vo.setDivyAddr(divyAddr);
        vo.setDivyRequest(divyRequest);
        vo.setDivyDate((divyDate != null && !divyDate.isEmpty()) ? divyDate : null); // YYYYMMDD or null

        int tranNo = purchaseService.addPurchase(vo);
        return "redirect:/getPurchase.do?tranNo=" + tranNo;
    }

    // =========================================================================
    // 3) 구매 상세 : /getPurchase.do  (액션: GetPurchaseAction)
    //    - 입력: tranNo
    //    - 권한: 관리자 또는 구매자 본인만
    //    - 리턴: forward:/purchase/purchaseDetailView.jsp
    //            (없으면 forward:/common/error.jsp, 권한없음 403)
    // =========================================================================
    // [의미] 단건 주문 상세를 조회한다. 목록 복귀를 위해 Search를 항상 모델에 넣어 둔다.
    @RequestMapping("/getPurchase.do")
    public String getPurchase(@RequestParam("tranNo") int tranNo,
                              @ModelAttribute("search") Search search,
                              Model model) throws Exception {

        // [의미] 검색 상태 정규화(페이지/사이즈 보정, 키워드/조건 정리)
        SearchSupport.normalizeAlways(search, this.pageSize);

        // [의미] 상세 조회(기존 서비스 호출 유지)
        Purchase purchase = purchaseService.getPurchase(tranNo);

        // [의미] 조회 실패 시 기존 플로우 유지(필요 시 프로젝트의 처리 방식에 맞춤)
        if (purchase == null) {
            return "redirect:/listPurchase.do";
        }

        // [의미] 모델 바인딩(키 이름 유지)
        model.addAttribute("purchase", purchase);
        model.addAttribute("search", search);

        // [의미] 기존 상세 JSP로 포워드(경로/파일명 변경 없음)
        return "forward:/purchase/purchaseDetailView.jsp";
    }

    // =========================================================================
    // 4) 구매 수정 화면 : /updatePurchaseView.do  (액션: UpdatePurchaseViewAction)
    //    - 입력: tranNo
    //    - 권한: 관리자 또는 구매자 본인
    //    - 제약: tranCode == DLV 면 수정 불가 → error.jsp
    //    - 리턴: forward:/purchase/purchaseEditView.jsp
    // =========================================================================
    // [의미] 주문 수정 폼을 노출한다. 목록 복귀를 위해 Search를 항상 모델에 넣어 둔다.
    @RequestMapping("/updatePurchaseView.do")
    public String updatePurchaseView(@RequestParam("tranNo") int tranNo,
                                     @ModelAttribute("search") Search search,
                                     Model model) throws Exception {

        // [의미] 검색 상태 정규화(페이지/사이즈 보정, 키워드/조건 정리)
        SearchSupport.normalizeAlways(search, this.pageSize);

        // [의미] 수정 대상 조회(기존 서비스 호출 유지)
        Purchase purchase = purchaseService.getPurchase(tranNo);

        // [의미] 조회 실패 시 기존 플로우 유지
        if (purchase == null) {
            return "redirect:/listPurchase.do";
        }

        // [의미] 모델 바인딩(키 이름 유지)
        model.addAttribute("purchase", purchase);
        model.addAttribute("search", search);

        // [의미] 기존 수정 JSP로 포워드(경로/파일명 변경 없음)
        return "forward:/purchase/purchaseEditView.jsp";
    }

    // =========================================================================
    // 5) 구매 수정 : /updatePurchase.do  (액션: UpdatePurchaseAction)
    //    - 입력: tranNo + 수정 필드
    //    - 권한: 구매자 본인(일반 사용자)만
    //    - 리턴: redirect:/getPurchase.do?tranNo=...
    // =========================================================================
    @RequestMapping("/updatePurchase.do")
    public String updatePurchase(@ModelAttribute("purchase") Purchase form,
                                 HttpSession session,
                                 HttpServletResponse response) throws Exception {

        // 0) 필수 키 확인(폼에 hidden name="tranNo" 있어야 함)
        final int tranNo = form.getTranNo();
        if (tranNo <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return null;
        }

        // 1) 소유자 확인(조회는 최소 1회만)
        User loginUser = (User) (session != null ? session.getAttribute("user") : null);
        Purchase db = purchaseService.getPurchase(tranNo);
        if (db == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return null;
        }
        boolean isOwner = (loginUser != null
                        && db.getBuyer() != null
                        && loginUser.getUserId() != null
                        && loginUser.getUserId().equals(db.getBuyer().getUserId()));
        if (!isOwner) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }

        // 2) 최소 정규화(빈 문자열이면 null) – form을 그대로 수정
        String dd = form.getDivyDate();
        form.setDivyDate((dd != null && !dd.trim().isEmpty()) ? dd.trim() : null);

        // 3) 바로 업데이트(오버포스팅 방지는 @InitBinder 허용필드로 커버)
        purchaseService.updatePurchase(form);

        // 4) 상세로 리다이렉트
        return "redirect:/getPurchase.do?tranNo=" + tranNo;
    }

    // =========================================================================
    // 6) 내 구매 목록 : /listPurchase.do  (액션: ListPurchaseAction)
    //    - 입력: currentPage/page, pageSize
    //    - 모델: list, resultPage, search
    //    - 리턴: forward:/purchase/purchaseProductView.jsp
    // =========================================================================
    // [의미] 내 구매 목록을 조회한다. 검색 안 함도 하나의 상태로 보고 Search를 항상 사용한다.
    @RequestMapping("/listPurchase.do")
    public String listPurchase(@ModelAttribute("search") Search search,
                               HttpSession session,
                               Model model) throws Exception {

        // [의미] 검색 상태 정규화(페이지/사이즈 보정, 키워드/조건 정리)
        SearchSupport.normalizeAlways(search, this.pageSize);

        // [의미] 로그인 사용자 ID 추출(구매자 기준 목록)
        User loginUser = (User)(session != null ? session.getAttribute("user") : null);
        String buyerId = (loginUser != null ? loginUser.getUserId() : null);

        // [의미] 서비스 호출(기존 서비스/DAO 시그니처 그대로 사용)
        Map<String, Object> map = purchaseService.getPurchaseList(buyerId, search);

        // [의미] 페이지 정보 계산 및 모델 바인딩(키 이름 유지)
        int totalCount = ((Integer)map.get("totalCount")).intValue();
        Page resultPage = new Page(search.getCurrentPage(), totalCount, pageUnit, search.getPageSize());

        model.addAttribute("list", map.get("list"));
        model.addAttribute("resultPage", resultPage);
        model.addAttribute("search", search);

        // [의미] 기존 목록 JSP로 포워드(경로/파일명 변경 없음)
        return "forward:/purchase/purchaseProductView.jsp";
    }

    // =========================================================================
    // 7) 판매 목록(관리자 전역) : /listSale.do  (액션: ListSaleAction)
    //    - 입력: page (currentPage 병행), pageSize(옵션)
    //    - 권한: 관리자만
    //    - 모델: map, search
    //    - 리턴: forward:/purchase/saleListView.jsp
    // =========================================================================
    @RequestMapping("/listSale.do")
    public String listSale(HttpSession session,
                           @RequestParam(value="currentPage", required=false) Integer currentPage,
                           @RequestParam(value="page",        required=false) Integer page,
                           @RequestParam(value="pageSize",    required=false) Integer size,
                           HttpServletResponse response,
                           Model model) throws Exception {

        User loginUser = (User) (session != null ? session.getAttribute("user") : null);
        boolean isAdmin = (loginUser != null && loginUser.getRole() != null && !"user".equals(loginUser.getRole()));
        if (!isAdmin) { response.sendError(HttpServletResponse.SC_FORBIDDEN); return null; }

        int cp = resolveCurrentPage(currentPage, page);
        int ps = resolvePageSize(size);

        Search search = new Search();
        search.setCurrentPage(cp);
        search.setPageSize(ps);

        Map<String, Object> map = purchaseService.getSaleList(search);

        model.addAttribute("map", map);
        model.addAttribute("search", search);

        return "forward:/purchase/saleListView.jsp";
    }

    // =========================================================================
    // 8) 거래상태 변경 : /updateTranCode.do  (액션: UpdateTranCodeAction)
    //    - 입력: tranNo, tranCode (SHP | DLV)
    //    - 권한: 일반(구매자) : SHP → DLV,  관리자 : BEF → SHP
    //    - 리턴: redirect:/listPurchase.do
    // =========================================================================
    @RequestMapping("/updateTranCode.do")
    public String updateTranCode(@RequestParam("tranNo") int tranNo,
                                 @RequestParam("tranCode") String toCode,
                                 HttpSession session,
                                 HttpServletResponse response) throws Exception {

        User loginUser = (User) (session != null ? session.getAttribute("user") : null);

        Purchase purchase = purchaseService.getPurchase(tranNo);
        if (purchase == null) { response.sendError(HttpServletResponse.SC_NOT_FOUND); return null; }

        boolean isAdmin = (loginUser != null && loginUser.getRole() != null && !"user".equals(loginUser.getRole()));
        boolean isOwner = (loginUser != null
                         && purchase.getBuyer() != null
                         && loginUser.getUserId() != null
                         && loginUser.getUserId().equals(purchase.getBuyer().getUserId()));

        if (!isAdmin) {
            // 일반 사용자(구매자) : SHP -> DLV 만 허용
            if (isOwner
             && Purchase.TRAN_SHIPPING.equals(purchase.getTranCode())
             && Purchase.TRAN_DELIVERY.equals(toCode)) {
                purchaseService.updateTranCode(tranNo, Purchase.TRAN_DELIVERY);
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return null;
            }
        } else {
            // 관리자 : BEF -> SHP 만 허용
            if (Purchase.TRAN_BEFORE.equals(purchase.getTranCode())
             && Purchase.TRAN_SHIPPING.equals(toCode)) {
                purchaseService.updateTranCode(tranNo, Purchase.TRAN_SHIPPING);
            }
        }
        return "redirect:/listPurchase.do";
    }

    // =========================================================================
    // 9) (관리자) 상품 기준 최신 거래를 SHP로 : /updateTranCodeByProd.do
    //    - 입력: prodNo, page
    //    - 리턴: redirect:/listProduct.do?menu=manage&page=...
    //    - 액션: UpdateTranCodeByProdAction
    // =========================================================================
    @RequestMapping("/updateTranCodeByProd.do")
    public String updateTranCodeByProd(@RequestParam("prodNo") int prodNo,
                                       @RequestParam(value="page", required=false) Integer page,
                                       HttpSession session) throws Exception {

        User loginUser = (User) (session != null ? session.getAttribute("user") : null);
        boolean isAdmin = (loginUser != null && loginUser.getRole() != null && !"user".equals(loginUser.getRole()));
        // 액션은 비정상 접근 시 검색 목록으로 돌려보냈지만, 여기서는 동일한 결과로 수렴
        if (!isAdmin) {
            return "redirect:/listProduct.do?menu=search";
        }
        
        int tranNo = purchaseService.findPurchaseByProdNo(prodNo);
        int goPage = (page != null && page > 0) ? page : 1;
        
        if (tranNo > 0) {
            // tranNo 사용
            purchaseService.updateTranCode(tranNo, Purchase.TRAN_SHIPPING);
        }
        
        return "redirect:/listProduct.do?menu=manage&page=" + goPage;
    }
}
