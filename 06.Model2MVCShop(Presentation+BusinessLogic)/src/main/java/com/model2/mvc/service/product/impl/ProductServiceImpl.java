// ProductServiceImpl.java
package com.model2.mvc.service.product.impl;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.product.ProductDao;
import com.model2.mvc.service.product.ProductService;

/**
 * ProductService 구현체
 */
@Service("productServiceImpl") // Spring이 서비스 Bean으로 관리하도록 @Service 어노테이션 추가
public class ProductServiceImpl implements ProductService {

    //  ниже 의존성 주입(DI)을 위해 @Autowired 추가
    @Autowired
    @Qualifier("productDAOImpl")
    private ProductDao productDAO; // 구현 클래스(ProductDaoImpl)가 아닌 인터페이스(ProductDAO)에 의존

    // 직접 new로 생성하는 생성자 삭제
    public ProductServiceImpl() {
        System.out.println(this.getClass());
    }

    @Override
    public Product findProduct(int prodNo) throws Exception {
        return productDAO.findProduct(prodNo);
    }

    @Override
    public Map<String, Object> getProductList(Search search) throws Exception {
        return productDAO.getProductList(search);
    }
    
    @Override
    public Map<String, Object> getProductListByUser(Search search) throws Exception {
        return productDAO.getProductListByUser(search);
    }

    @Override
    public void insertProduct(Product productVO) throws Exception {
        productDAO.insertProduct(productVO);
    }

    @Override
    public void updateProduct(Product productVO) throws Exception {
        productDAO.updateProduct(productVO);
    }
}