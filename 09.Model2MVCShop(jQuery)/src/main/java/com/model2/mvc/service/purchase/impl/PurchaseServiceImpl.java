// PurchaseServiceImpl.java
package com.model2.mvc.service.purchase.impl;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Purchase;
import com.model2.mvc.service.product.ProductDao;
import com.model2.mvc.service.purchase.PurchaseDao;
import com.model2.mvc.service.purchase.PurchaseService;

@Service("purchaseServiceImpl") // Spring이 서비스 Bean으로 관리하도록 @Service 어노테이션 추가
public class PurchaseServiceImpl implements PurchaseService {

	// ниже 의존성 주입(DI)을 위해 @Autowired 추가
	@Autowired
	@Qualifier("purchaseDaoImpl")
	private PurchaseDao purchaseDao; // 구현 클래스가 아닌 인터페이스에 의존

	@Autowired
	@Qualifier("productDaoImpl")
	private ProductDao productDao;

	public PurchaseServiceImpl() {
		System.out.println(this.getClass());
	}

	@Override
	public Purchase getPurchase(int tranNo) throws Exception {
		return purchaseDao.findPurchase(tranNo);
	}

	@Override
	public Map<String, Object> getPurchaseList(String buyerId, Search search) throws Exception {
		return purchaseDao.getPurchaseList(buyerId, search);
	}

	@Override
	public Map<String, Object> getSaleList(Search search) throws Exception {
		return purchaseDao.getSaleList(search);
	}

	@Override
	@Transactional
	public int addPurchase(Purchase purchase) throws Exception {
		// 1) 거래 생성 (sell_quantity 포함)
		purchaseDao.insertPurchase(purchase);
		int prodNo = purchase.getPurchaseProd().getProdNo();
		int qty = Math.max(1, purchase.getSellQuantity());
		// 2) 상품 수량 차감
		productDao.decreaseQuantity(prodNo, qty);
		// 3) 판매여부 플래그 ON
		productDao.updateIsSell(prodNo);
		return purchase.getTranNo();
	}

	@Override
	public List<Map<String, Object>> getPurchaseListByProd(int prodNo) throws Exception {
		return purchaseDao.getPurchaseListByProd(prodNo);
	}

	@Override
	public int updatePurchase(Purchase vo) throws Exception {
		return purchaseDao.updatePurchase(vo);
	}

	@Override
	public int updateTranCode(int tranNo, String tranCode) throws Exception {
		return purchaseDao.updateTranCode(tranNo, tranCode);
	}

	@Override
	public int findPurchaseByProdNo(int prodNo) throws Exception {
		return purchaseDao.findPurchaseByProdNo(prodNo);
	}

	// 이 메서드는 Service에서 별도 로직이 필요 없어 DAO 호출을 그대로 유지합니다.
	@Override
	public int updateLatestTranCodeByProdToShipping(int prodNo) throws Exception {
		// DAO에 이미 같은 이름의 메서드가 있으므로 그대로 호출
		// 만약 '상품 상태 확인 -> 업데이트' 같은 복합 로직이 필요하면 이 부분에 추가합니다.
		// 현재는 DAOImpl에 로직이 위임되어 있으므로 수정 없이 진행합니다.

		// return purchaseDAO.updateLatestTranCodeByProdToShipping(prodNo);
		// 위임된 메서드가 없으므로 주석처리.
		// 해당 DAO 메소드를 만들지 않았습니다.
		return 0;
	}
}