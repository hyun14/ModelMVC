package com.model2.mvc.service.productimage;

import java.util.List;
import java.util.Map;

public interface ProductImageMapper {
    int addImage(Map<String,Object> param);
    int deleteImagesByProdNo(int prodNo);
    List<Map<String,Object>> listImagesByProdNo(int prodNo);
}
