package com.model2.mvc.service.productimage;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

public interface ProductImageService {
    // 등록 직후 이미지 저장
    void saveProductImages(int prodNo, List<MultipartFile> images);

    // 수정 시 이미지 교체(전체 삭제 후 재등록 여부 선택)
    void replaceProductImages(int prodNo, List<MultipartFile> images, boolean replace);

    // [추가] 상세/수정 화면용 조회
    List<Map<String, Object>> listImagesByProdNo(int prodNo);
}
