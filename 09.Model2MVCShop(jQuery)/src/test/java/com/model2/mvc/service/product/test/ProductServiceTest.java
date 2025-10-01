package com.model2.mvc.service.product.test;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.product.ProductService;
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
import java.util.Optional;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {
    "classpath:config/context-common.xml",
    "classpath:config/context-aspect.xml",
    "classpath:config/context-mybatis.xml",
    "classpath:config/context-transaction.xml"
})
public class ProductServiceTest {

    @Autowired
    @Qualifier("productServiceImpl")
    private ProductService productService;

    /**
     * [검증 1] 재입고 로직 테스트
     * prodNo 10017 상품(초기 수량 44개)에 10개를 재입고 시켰을 때, 수량이 54개로 정상 증가하는지 확인합니다.
     */
    @Test
    @Transactional
    @Rollback(true)
    public void testRestock() throws Exception {
        // Given: 재입고할 상품 정보
        int prodNo = 10017; // 노트북 스탠드 S360
        int addQty = 10;
        Product initialProduct = productService.findProduct(prodNo);
        int initialQty = initialProduct.getQuantity(); // 초기 수량: 44

        System.out.println(":: 재입고 전 수량 :: " + initialQty);

        // When: 재입고 서비스 호출
        productService.restock(prodNo, addQty);

        // Then: 수량이 정상적으로 증가했는지 검증
        Product restockedProduct = productService.findProduct(prodNo);
        int finalQty = restockedProduct.getQuantity();
        System.out.println(":: 재입고 후 수량 :: " + finalQty);
        
        Assert.assertEquals(initialQty + addQty, finalQty);
    }

    /**
     * [검증 2-1] getProductListByUser 테스트 (재고 0 상품 필터링)
     * seeAll=false 조건에서, 재고가 0인 상품(10018)이 목록에서 제외되는지 확인합니다.
     */
    @Test
    public void testGetProductListByUser_ExcludeZeroQuantity() throws Exception {
        // Given: seeAll=false (기본값) 설정
        Search search = new Search();
        search.setCurrentPage(1);
        search.setPageSize(100); // 모든 상품을 다 보기 위해 페이지 사이즈를 크게 설정
        search.setSeeAll(false);

        // When: 사용자 상품 목록 조회
        Map<String, Object> map = productService.getProductListByUser(search);
        List<Product> list = (List<Product>) map.get("list");

        // Then: 재고가 0인 상품(prodNo=10018)이 없는지 확인
        boolean zeroQtyProductFound = false;
        for (Product p : list) {
            if (p.getProdNo() == 10018) {
                zeroQtyProductFound = true;
                break;
            }
        }
        Assert.assertFalse("재고가 0인 상품(10018)이 목록에 포함되면 안됩니다.", zeroQtyProductFound);
        System.out.println(":: 재고 0 상품 필터링 테스트 통과 ::");
    }

    /**
     * [검증 2-2] getProductListByUser 테스트 (모든 상품 보기)
     * seeAll=true 조건에서, 재고가 0인 상품(10018)이 목록에 포함되는지 확인합니다.
     */
    @Test
    public void testGetProductListByUser_IncludeZeroQuantity() throws Exception {
        // Given: seeAll=true 설정
        Search search = new Search();
        search.setCurrentPage(1);
        search.setPageSize(100);
        search.setSeeAll(true);

        // When: 사용자 상품 목록 조회
        Map<String, Object> map = productService.getProductListByUser(search);
        List<Product> list = (List<Product>) map.get("list");

        // Then: 재고가 0인 상품(prodNo=10018)이 있는지 확인
        Optional<Product> zeroQtyProduct = list.stream().filter(p -> p.getProdNo() == 10018).findFirst();
        
        Assert.assertTrue("재고가 0인 상품(10018)이 목록에 포함되어야 합니다.", zeroQtyProduct.isPresent());
        System.out.println(":: 모든 상품 보기(seeAll=true) 테스트 통과 ::");
    }
}