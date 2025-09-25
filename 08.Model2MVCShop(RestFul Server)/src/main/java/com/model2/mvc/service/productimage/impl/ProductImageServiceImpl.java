package com.model2.mvc.service.productimage.impl;

// [의미] 서비스 인터페이스
import com.model2.mvc.service.productimage.ProductImageService;

// [의미] 마이바티스 SqlSessionTemplate 주입 사용 (인터페이스 바인딩 사용 안함)
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;

// [의미] 트랜잭션 관리
import org.springframework.transaction.annotation.Transactional;

// [의미] 멀티파트 파일 처리
import org.springframework.web.multipart.MultipartFile;

// [의미] 업로드 경로 계산 및 파일 저장을 위한 표준 API
import javax.servlet.ServletContext;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

// [의미] 파일명 생성(중복 방지), 날짜 포맷
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

// [의미] 파라미터 전달용 맵, 유틸
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class ProductImageServiceImpl implements ProductImageService {

    // [의미] MyBatis SqlSessionTemplate 주입 (id=sqlSessionTemplate)
    @Autowired
    @Qualifier("sqlSessionTemplate")
    private SqlSession sqlSession;

    // [의미] 업로드 경로 계산에 사용할 ServletContext
    private ServletContext servletContext;

    // [의미] 스프링 XML에서 servletContext를 주입받기 위한 setter
    public void setServletContext(ServletContext c) {
        this.servletContext = c;
    }

    // [의미] 이 서비스가 참조하는 MyBatis 매퍼 네임스페이스 상수 (옵션 B: 짧은 namespace)
    private static final String NS = "ProductImageMapper";

    // [의미] 업로드 경로 계산: /images/product/{prodNo}/ 실제 경로를 반환
    private Path resolveDir(int prodNo) {
        String base = servletContext.getRealPath("/images/product/" + prodNo + "/");
        return Paths.get(base);
    }

    // [의미] 다중 이미지 저장: 파일시스템에 저장 후 product_image 테이블에 메타데이터 insert
    @Override
    @Transactional
    public void saveProductImages(int prodNo, List<MultipartFile> images) {
        if (images == null || images.isEmpty()) {
            return;
        }

        try {
            Path dir = resolveDir(prodNo);
            System.out.println("[IMG] resolveDir prodNo=" + prodNo + ", dir=" + dir);
            Files.createDirectories(dir);

            int sort = 0;
            boolean primaryAssigned = false;

            for (MultipartFile mf : images) {
                if (mf == null || mf.isEmpty()) {
                    continue;
                }

                // [의미] 안전한 저장 파일명 생성 (원본 확장자 유지, 중복 방지용 UUID)
                String original = mf.getOriginalFilename();
                String ext = (original != null && original.lastIndexOf('.') >= 0)
                        ? original.substring(original.lastIndexOf('.')) : "";
                String stored = LocalDateTime.now().format(
                        DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss_SSS"))
                        + "_" + UUID.randomUUID().toString().replace("-", "") + ext;

                // [의미] 실제 파일 저장
                Path target = dir.resolve(stored);
                mf.transferTo(target.toFile());

                // [의미] DB에 저장할 메타데이터 구성
                Map<String, Object> p = new HashMap<String, Object>();
                p.put("prodNo", prodNo);
                p.put("fileName", stored);
                p.put("filePath", "/images/product/" + prodNo + "/" + stored); // 상대 경로
                p.put("sortOrder", sort++);
                p.put("isPrimary", primaryAssigned ? "N" : "Y");

                // [의미] 인터페이스 바인딩 없이 문자열 키로 직접 호출
                sqlSession.insert(NS + ".addImage", p);

                primaryAssigned = true;
            }
        } catch (Exception e) {
            // [의미] 예외 발생 시 롤백 유도
            throw new RuntimeException("이미지 저장 중 오류", e);
        }
    }

    // [의미] 이미지 교체: replace=true면 기존 이미지를 전량 삭제 후 새로 저장, false면 추가만
    @Override
    @Transactional
    public void replaceProductImages(int prodNo, List<MultipartFile> images, boolean replace) {
        if (replace) {
            sqlSession.delete(NS + ".deleteImagesByProdNo", prodNo);
        }
        saveProductImages(prodNo, images);
    }

    // [의미] 상세/수정 화면용: 해당 상품의 이미지 목록 조회
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> listImagesByProdNo(int prodNo) {
        return sqlSession.selectList(NS + ".listImagesByProdNo", prodNo);
    }
}
