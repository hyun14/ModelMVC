package com.model2.mvc.service.product.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Repository;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.ProductImage;
import com.model2.mvc.service.product.ProductDao;

/**
 * ProductDAO 인터페이스의 MyBatis 구현체
 */
@Repository("productDaoImpl")
public class ProductDaoImpl implements ProductDao {

	// MyBatis 연동을 위한 SqlSession 의존성 주입
	@Autowired
	@Qualifier("sqlSessionTemplate")
	private SqlSession sqlSession;

	public ProductDaoImpl() {
		System.out.println(this.getClass());
	}

	@Override
	public void insertProduct(Product productVO) throws Exception {
		// ProductMapper.xml의 "addProduct" 쿼리 호출
		sqlSession.insert("ProductMapper.addProduct", productVO);
	}

	@Override
	public Product findProduct(int prodNo) throws Exception {
		// ProductMapper.xml의 "findProduct" 쿼리 호출
		return sqlSession.selectOne("ProductMapper.findProduct", prodNo);
	}

	@Override
	public void updateProduct(Product productVO) throws Exception {
		// ProductMapper.xml의 "updateProduct" 쿼리 호출
		sqlSession.update("ProductMapper.updateProduct", productVO);
	}

	@Override
	public Map<String, Object> getProductList(Search search) throws Exception {
		// ProductMapper.xml의 "getProductList" 쿼리를 호출하여 목록 조회
		List<Product> list = sqlSession.selectList("ProductMapper.getProductList", search);

		// ProductMapper.xml의 "getProductTotalCount" 쿼리를 호출하여 전체 개수 조회
		int totalCount = sqlSession.selectOne("ProductMapper.getProductTotalCount", search);

		// 결과를 Map에 담아 반환
		Map<String, Object> map = new HashMap<>();
		map.put("list", list);
		map.put("totalCount", totalCount);

		return map;
	}

	@Override
	public Map<String, Object> getProductListByUser(Search search) throws Exception {
		// ProductMapper.xml의 "getProductListByUser" 쿼리를 호출하여 목록 조회
		List<Product> list = sqlSession.selectList("ProductMapper.getProductListByUser", search);

		// ProductMapper.xml의 "getProductTotalCountByUser" 쿼리를 호출하여 전체 개수 조회
		int totalCount = sqlSession.selectOne("ProductMapper.getProductTotalCountByUser", search);

		// 결과를 Map에 담아 반환
		Map<String, Object> map = new HashMap<>();
		map.put("list", list);
		map.put("totalCount", totalCount);

		return map;
	}

	// ====== 신규 ======
	@Override
	public int getNextImageNo() {
		return sqlSession.selectOne("ProductMapper.getNextImageNo");
	}

	@Override
	public void insertProductImage(ProductImage img) {
		sqlSession.insert("ProductMapper.insertProductImage", img);
	}

	@Override
	public List<ProductImage> selectProductImages(int prodNo) {
		return sqlSession.selectList("ProductMapper.selectProductImages", prodNo);
	}

	@Override
	public int deleteProductImagesByProd(int prodNo) {
		return sqlSession.delete("ProductMapper.deleteProductImagesByProd", prodNo);
	}

	@Override
	public int restock(int prodNo, int addQty) {
		Map<String, Object> p = new HashMap<>();
		p.put("prodNo", prodNo);
		p.put("addQty", addQty);
		return sqlSession.update("ProductMapper.restock", p);
	}

	@Override
	public int decreaseQuantity(int prodNo, int qty) {
		Map<String, Object> p = new HashMap<>();
		p.put("prodNo", prodNo);
		p.put("qty", qty);
		return sqlSession.update("ProductMapper.decreaseQuantity", p);
	}

	@Override
	public int updateIsSell(int prodNo) {
		return sqlSession.update("ProductMapper.updateIsSell", prodNo);
	}

	@Override
	public List<String> suggestProducts(Map<String, Object> param) throws Exception {
	    return sqlSession.selectList("ProductMapper.suggestProducts", param);
	}

}