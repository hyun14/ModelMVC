// ProductServiceImpl.java
package com.model2.mvc.service.product.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.ProductImage;
import com.model2.mvc.service.product.ProductDao;
import com.model2.mvc.service.product.ProductService;

/**
 * ProductService 구현체
 */
@Service("productServiceImpl") // Spring이 서비스 Bean으로 관리하도록 @Service 어노테이션 추가
public class ProductServiceImpl implements ProductService {

	// ниже 의존성 주입(DI)을 위해 @Autowired 추가
	@Autowired
	@Qualifier("productDaoImpl")
	private ProductDao productDao; 

	// 직접 new로 생성하는 생성자 삭제
	public ProductServiceImpl() {
		System.out.println(this.getClass());
	}

	@Override
	public Product findProduct(int prodNo) throws Exception {
		return productDao.findProduct(prodNo);
	}

	@Override
	public Map<String, Object> getProductList(Search search) throws Exception {
	    
	    // 1. DAO를 통해 기본 상품 목록만 먼저 조회 (이미지 X)
	    Map<String, Object> map = productDao.getProductList(search);
	    List<Product> list = (List<Product>) map.get("list");

	    // 2. 조회된 목록을 하나씩 반복하면서
	    for (Product product : list) {
	        
	        // 3. 바로 이 부분에서 지적해주신 메소드를 사용해 각 상품의 이미지 정보를 가져와서
	        List<ProductImage> images = this.selectProductImages(product.getProdNo());
	        
	        // 4. Product 객체에 채워줍니다.
	        product.setImages(images);
	    }

	    // 5. 이미지 정보가 모두 채워진 목록을 반환합니다.
	    return map;
	}

	@Override
	public Map<String, Object> getProductListByUser(Search search) throws Exception {
		
		// 1. DAO를 통해 기본 상품 목록만 먼저 조회 (이미지 X)
	    Map<String, Object> map = productDao.getProductList(search);
	    List<Product> list = (List<Product>) map.get("list");

	    // 2. 조회된 목록을 하나씩 반복하면서
	    for (Product product : list) {
	        
	        // 3. 바로 이 부분에서 지적해주신 메소드를 사용해 각 상품의 이미지 정보를 가져와서
	        List<ProductImage> images = this.selectProductImages(product.getProdNo());
	        
	        // 4. Product 객체에 채워줍니다.
	        product.setImages(images);
	    }

	    // 5. 이미지 정보가 모두 채워진 목록을 반환합니다.
	    return map;
	}

	@Override
	public void insertProduct(Product productVO) throws Exception {
		productDao.insertProduct(productVO);
	}

	@Override
	public void updateProduct(Product productVO) throws Exception {
		productDao.updateProduct(productVO);
	}

	// ===== 신규 메서드 단순 위임 =====
	@Override
	public int getNextImageNo() {
		return productDao.getNextImageNo();
	}

	@Override
	public void insertProductImage(ProductImage img) {
		productDao.insertProductImage(img);
	}

	@Override
	public List<ProductImage> selectProductImages(int prodNo) {
		return productDao.selectProductImages(prodNo);
	}

	@Override
	public int deleteProductImagesByProd(int prodNo) {
		return productDao.deleteProductImagesByProd(prodNo);
	}

	@Override
	public int restock(int prodNo, int addQty) {
		return productDao.restock(prodNo, addQty);
	}

	@Override
	public int decreaseQuantity(int prodNo, int qty) {
		return productDao.decreaseQuantity(prodNo, qty);
	}

	@Override
	public int updateIsSell(int prodNo) {
		return productDao.updateIsSell(prodNo);
	}

	@Override
	@Transactional
	public void replaceProductImages(int prodNo, List<ProductImage> newImages) {
		productDao.deleteProductImagesByProd(prodNo);
		if (newImages != null) {
			int sort = 1;
			for (ProductImage img : newImages) {
				if (img.getImageNo() == 0) {
					img.setImageNo(productDao.getNextImageNo());
				}
				img.setProdNo(prodNo);
				if (img.getSortOrd() == null)
					img.setSortOrd(sort++);
				productDao.insertProductImage(img);
			}
		}
	}
	
	@Override
	public List<String> suggestProducts(String q, int limit) throws Exception {
	    if (q == null) q = "";
	    if (limit <= 0) limit = 5;
	    Map<String, Object> param = new HashMap<>();
	    param.put("q", q.trim());
	    param.put("limit", limit);
	    return productDao.suggestProducts(param);
	}

}