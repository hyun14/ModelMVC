package com.model2.mvc.service.product;

import java.util.List;
import java.util.Map;
import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.ProductImage;

/**
 * Product 관련 DB 작업을 위한 추상화 인터페이스
 */
public interface ProductDao {

	/**
	 * 새로운 상품을 등록합니다.
	 * @param productVO 등록할 상품 정보
	 */
	public void insertProduct(Product productVO) throws Exception;

	/**
	 * 상품 번호로 단일 상품 정보를 조회합니다.
	 * @param prodNo 조회할 상품 번호
	 * @return 조회된 상품 정보
	 */
	public Product findProduct(int prodNo) throws Exception;

	/**
	 * 관리자용 상품 목록을 조회합니다. (모든 상품)
	 * @param search 검색 및 페이징 정보
	 * @return 상품 목록과 전체 개수를 포함한 Map
	 */
	public Map<String, Object> getProductList(Search search) throws Exception;
	
	/**
	 * 사용자용 상품 목록을 조회합니다. (거래가 없는 상품만)
	 * @param search 검색 및 페이징 정보
	 * @return 상품 목록과 전체 개수를 포함한 Map
	 */
	public Map<String, Object> getProductListByUser(Search search) throws Exception;

	/**
	 * 기존 상품 정보를 수정합니다.
	 * @param productVO 수정할 상품 정보
	 */
	public void updateProduct(Product productVO) throws Exception;
	
	
	// === 신규 추가 ===
	public int getNextImageNo();
	public void insertProductImage(ProductImage img);
	public List<ProductImage> selectProductImages(int prodNo);
	public int deleteProductImagesByProd(int prodNo);
	
	public int restock(int prodNo, int addQty);
	public int decreaseQuantity(int prodNo, int qty);
	public int updateIsSell(int prodNo);
	List<String> suggestProducts(Map<String, Object> param) throws Exception;

}