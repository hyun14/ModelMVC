package com.model2.mvc.service.purchase.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Repository;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Purchase;
import com.model2.mvc.service.purchase.PurchaseDao;

/**
 * PurchaseDAO 인터페이스의 MyBatis 구현체
 */
@Repository("purchaseDAOImpl")
public class PurchaseDaoImpl implements PurchaseDao {

	@Autowired
	@Qualifier("sqlSessionTemplate")
	private SqlSession sqlSession;

	public PurchaseDaoImpl() {
		System.out.println(this.getClass());
	}

	@Override
	public Purchase findPurchase(int tranNo) throws Exception {
		return sqlSession.selectOne("PurchaseMapper.findPurchase", tranNo);
	}

	@Override
	public Map<String, Object> getPurchaseList(String buyerId, Search search) throws Exception {
		Map<String, Object> params = new HashMap<>();
		params.put("buyerId", buyerId);
		params.put("search", search);

		List<Purchase> list = sqlSession.selectList("PurchaseMapper.getPurchaseList", params);
		int totalCount = sqlSession.selectOne("PurchaseMapper.getPurchaseTotalCount", params);

		Map<String, Object> map = new HashMap<>();
		map.put("list", list);
		map.put("totalCount", totalCount);
		
		return map;
	}

	@Override
	public Map<String, Object> getSaleList(Search search) throws Exception {
		// getSaleList와 getSaleTotalCount는 아래 수정된 PurchaseMapper.xml에 추가되어 있습니다.
		List<Purchase> list = sqlSession.selectList("PurchaseMapper.getSaleList", search);
		int totalCount = sqlSession.selectOne("PurchaseMapper.getSaleTotalCount", search);
		
		Map<String, Object> map = new HashMap<>();
		map.put("list", list);
		map.put("totalCount", totalCount);
		
		return map;
	}

	@Override
	public int insertPurchase(Purchase purchaseVO) throws Exception {
		sqlSession.insert("PurchaseMapper.insertPurchase", purchaseVO);
		// <selectKey>를 통해 purchaseVO에 tranNo가 세팅됩니다.
		return purchaseVO.getTranNo();
	}

	@Override
	public int updatePurchase(Purchase purchaseVO) throws Exception {
		return sqlSession.update("PurchaseMapper.updatePurchase", purchaseVO);
	}

	@Override
	public int updateTranCode(int tranNo, String tranCode) throws Exception {
		Map<String, Object> params = new HashMap<>();
		params.put("tranNo", tranNo);
		params.put("tranCode", tranCode);
		return sqlSession.update("PurchaseMapper.updateTranCode", params);
	}

	@Override
	public int findPurchaseByProdNo(int prodNo) throws Exception {
	    Integer tranNo = sqlSession.selectOne("PurchaseMapper.findPurchaseByProdNo", prodNo);
	    return (tranNo != null) ? tranNo : 0; // 없으면 0 반환(필요 시 정책에 맞게 변경)
	}
}