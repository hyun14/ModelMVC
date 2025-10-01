package com.model2.mvc.service.purchase.test;

import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.Purchase;
import com.model2.mvc.service.domain.User;
import com.model2.mvc.service.product.ProductService;
import com.model2.mvc.service.purchase.PurchaseService;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.test.annotation.Rollback;

import java.util.List;
import java.util.Map;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {
    "classpath:config/context-common.xml",
    "classpath:config/context-aspect.xml",
    "classpath:config/context-mybatis.xml",
    "classpath:config/context-transaction.xml"
})
public class PurchaseServiceTest {

    @Autowired
    @Qualifier("purchaseServiceImpl")
    private PurchaseService purchaseService;

    @Autowired
    @Qualifier("productServiceImpl")
    private ProductService productService;

    /**
     * [검증 3] 구매 로직 테스트
     * prodNo 10011 상품(초기 수량 35개)을 5개 구매했을 때, 수량이 30개로 정상 감소하는지 확인합니다.
     */
    @Test
    @Transactional
    @Rollback(true)
    public void testAddPurchase() throws Exception {
        // Given: 구매할 상품(10011), 구매자(user03), 구매 수량(5)
        int prodNo = 10011;
        int purchaseQty = 5;

        Product product = productService.findProduct(prodNo);
        int initialQty = product.getQuantity(); // 초기 수량: 35

        User buyer = new User();
        buyer.setUserId("user03");

        Purchase purchase = new Purchase();
        purchase.setPurchaseProd(product);
        purchase.setBuyer(buyer);
        purchase.setSellQuantity(purchaseQty);
        purchase.setPaymentOption("CRD"); // 카드결제
        purchase.setReceiverName("테스트구매자");
        purchase.setReceiverPhone("010-0000-0000");
        purchase.setDivyAddr("테스트 주소");

        System.out.println(":: 구매 전 수량 :: " + initialQty);

        // When: 구매 서비스 호출
        purchaseService.addPurchase(purchase);

        // Then: 수량이 정상적으로 감소했는지 검증
        Product purchasedProduct = productService.findProduct(prodNo);
        int finalQty = purchasedProduct.getQuantity();
        System.out.println(":: 구매 후 수량 :: " + finalQty);

        Assert.assertEquals(initialQty - purchaseQty, finalQty);
    }

    /**
     * [검증 4] 관리자의 상품별 거래 내역 조회 테스트
     * prodNo 10031 상품의 거래 내역이 3건이 맞는지 확인합니다.
     */
    @Test
    public void testGetPurchaseListByProd() throws Exception {
        // Given: 거래 내역이 존재하는 상품 번호
        int prodNo = 10031;

        // When: 상품별 거래 내역 조회 서비스 호출
        List<Map<String, Object>> purchaseList = purchaseService.getPurchaseListByProd(prodNo);
        
        // Then: 조회된 거래 내역 건수 검증
        Assert.assertNotNull(purchaseList);
        Assert.assertEquals(3, purchaseList.size());
        
        System.out.println(":: 상품번호 " + prodNo + "의 거래 내역 " + purchaseList.size() + "건 확인 완료 ::");
    }
}