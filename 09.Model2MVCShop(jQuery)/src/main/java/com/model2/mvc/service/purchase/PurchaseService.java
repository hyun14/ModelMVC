package com.model2.mvc.service.purchase;

import java.util.List;
import java.util.Map;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Purchase;

public interface PurchaseService {
    Purchase getPurchase(int tranNo) throws Exception;
    Map<String,Object> getPurchaseList(String buyerId, Search search) throws Exception;
    Map<String,Object> getSaleList(Search search) throws Exception;
    int addPurchase(Purchase vo) throws Exception;
    int updatePurchase(Purchase vo) throws Exception;
    int updateTranCode(int tranNo, String tranCode) throws Exception;
    int updateLatestTranCodeByProdToShipping(int prodNo) throws Exception;
    int findPurchaseByProdNo(int prodNo) throws Exception;
    List<Map<String,Object>> getPurchaseListByProd(int prodNo) throws Exception;
}
