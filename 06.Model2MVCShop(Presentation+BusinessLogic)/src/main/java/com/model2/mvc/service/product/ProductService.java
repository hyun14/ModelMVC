package com.model2.mvc.service.product;

import java.util.HashMap;
import java.util.Map;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;


/**
 * Product 관련 비즈니스 로직 인터페이스
 */
public interface ProductService {
    /** 단일 상품 조회 */
    Product findProduct(int prodNo) throws Exception;
    /** 상품 목록 및 건수 조회 */
    Map<String, Object> getProductList(Search search) throws Exception;
    /** 상품 등록 */
    void insertProduct(Product productVO) throws Exception;
    /** 상품 수정 */
    void updateProduct(Product productVO) throws Exception;
    // ▼ 추가 : 사용자 검색 화면 전용(구매 불가 상품 미노출)
    // - 의미 : 가장 최근 거래 상태 코드가 존재하지 않는 상품만 조회
    Map<String, Object> getProductListByUser(Search search) throws Exception;
}
