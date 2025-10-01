package com.model2.mvc.service.purchase;

import java.util.List;
import java.util.Map;
import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Purchase;

/**
 * Purchase 관련 DB 작업을 위한 추상화 인터페이스
 */
public interface PurchaseDao {

	/**
	 * 거래 번호로 단일 구매 정보를 조회합니다.
	 * @param tranNo 조회할 거래 번호
	 * @return 조회된 구매 정보
	 */
	public Purchase findPurchase(int tranNo) throws Exception;

	/**
	 * 특정 구매자의 구매 목록을 조회합니다.
	 * @param buyerId 구매자 ID
	 * @param search 페이징 정보
	 * @return 구매 목록과 전체 개수를 포함한 Map
	 */
	public Map<String, Object> getPurchaseList(String buyerId, Search search) throws Exception;

	/**
	 * 전체 판매 목록을 조회합니다. (관리자용)
	 * @param search 페이징 정보
	 * @return 판매 목록과 전체 개수를 포함한 Map
	 */
	public Map<String, Object> getSaleList(Search search) throws Exception;

	/**
	 * 새로운 구매 정보를 등록합니다.
	 * @param purchaseVO 등록할 구매 정보
	 * @return 생성된 거래 번호
	 */
	public int insertPurchase(Purchase purchaseVO) throws Exception;

	/**
	 * 구매 정보를 수정합니다.
	 * @param purchaseVO 수정할 구매 정보
	 * @return 수정된 행의 수
	 */
	public int updatePurchase(Purchase purchaseVO) throws Exception;

	/**
	 * 거래 상태 코드를 수정합니다.
	 * @param tranNo 거래 번호
	 * @param tranCode 변경할 상태 코드
	 * @return 수정된 행의 수
	 */
	public int updateTranCode(int tranNo, String tranCode) throws Exception;
	
	public int findPurchaseByProdNo(int prodNo) throws Exception;
	
	public List<Map<String,Object>> getPurchaseListByProd(int prodNo) throws Exception;
}