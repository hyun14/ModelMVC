/*
 * package com.model2.mvc.service.Product.test;
 * 
 * import com.model2.mvc.service.domain.Product; import
 * com.model2.mvc.service.domain.User; import
 * com.model2.mvc.service.product.ProductService; import org.junit.Before;
 * import org.junit.Test; import org.junit.runner.RunWith; import
 * org.mockito.InjectMocks; import org.mockito.Mock; import
 * org.mockito.MockitoAnnotations; import
 * org.springframework.beans.factory.annotation.Autowired; import
 * org.springframework.mock.web.MockHttpSession; import
 * org.springframework.mock.web.MockMultipartFile; import
 * org.springframework.test.context.ContextConfiguration; import
 * org.springframework.test.context.junit4.SpringJUnit4ClassRunner; import
 * org.springframework.test.context.web.WebAppConfiguration; import
 * org.springframework.test.web.servlet.MockMvc; import
 * org.springframework.test.web.servlet.setup.MockMvcBuilders; import
 * org.springframework.web.context.WebApplicationContext;
 * 
 * import static org.mockito.ArgumentMatchers.any; import static
 * org.mockito.Mockito.doNothing; import static org.mockito.Mockito.when; import
 * static
 * org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
 * import static
 * org.springframework.test.web.servlet.request.MockMvcRequestBuilders.
 * multipart; import static
 * org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
 * 
 * // 1. 테스트 실행기 변경 (Spring Boot -> Spring Framework)
 * 
 * @RunWith(SpringJUnit4ClassRunner.class) // 2. Web Application Context를 사용하도록
 * 설정
 * 
 * @WebAppConfiguration // 3. 스프링 설정 파일 위치 지정
 * 
 * @ContextConfiguration(locations = { "file:src/main/webapp/WEB-INF/web.xml",
 * "classpath:config/context-*.xml" // 실제 설정 파일 경로에 맞게 수정하세요. }) public class
 * ProductControllerTest {
 * 
 * @Autowired private WebApplicationContext webApplicationContext;
 * 
 * private MockMvc mockMvc;
 * 
 * // 4. @MockBean 대신 @Mock 사용 (Mockito)
 * 
 * @Mock private ProductService productService;
 * 
 * // 5. 테스트 대상 컨트롤러 지정
 * 
 * @InjectMocks private ProductController productController;
 * 
 * private MockHttpSession adminSession; private Product sampleProduct;
 * 
 * // 6. @BeforeEach 대신 @Before 사용 (JUnit 4)
 * 
 * @Before public void setUp() { // Mockito 초기화
 * MockitoAnnotations.initMocks(this);
 * 
 * // MockMvc 설정 this.mockMvc =
 * MockMvcBuilders.webAppContextSetup(webApplicationContext).build(); // 만약
 * 필터(e.g., 한글 인코딩)가 있다면 아래처럼 추가합니다. // this.mockMvc =
 * MockMvcBuilders.webAppContextSetup(webApplicationContext) // .addFilter(new
 * CharacterEncodingFilter("UTF-8", true)) // .build();
 * 
 * // 세션 및 테스트 데이터 준비 User admin = new User("admin", "admin", "pass", null,
 * null, null, null); admin.setRole("admin"); adminSession = new
 * MockHttpSession(); adminSession.setAttribute("loginUser", admin);
 * 
 * sampleProduct = new Product(); sampleProduct.setProdNo(10001);
 * sampleProduct.setProdName("Test Product"); }
 * 
 * // 7. @DisplayName 대신 @Test 사용
 * 
 * @Test public void testAddProduct() throws Exception { // given (준비)
 * MockMultipartFile file = new MockMultipartFile("uploadFiles", "test.jpg",
 * "image/jpeg", "test".getBytes()); // @MockBean 대신 사용한 @Mock 객체의 동작 정의
 * doNothing().when(productService).insertProduct(any(Product.class));
 * 
 * // when & then (실행 및 검증) mockMvc.perform(multipart("/product/addProduct")
 * .file(file) .param("prodName", "New Product") .session(adminSession))
 * .andExpect(status().is3xxRedirection())
 * .andExpect(redirectedUrlPattern("/product/addProductResult?prodNo=*")); }
 * 
 * @Test public void testGetProduct() throws Exception { // given
 * when(productService.findProduct(10001)).thenReturn(sampleProduct);
 * 
 * // when & then mockMvc.perform(get("/product/getProduct") .param("prodNo",
 * "10001") .param("menu", "search")) .andExpect(status().isOk())
 * .andExpect(view().name("forward:/product/productDetailView.jsp"))
 * .andExpect(model().attributeExists("product")); }
 * 
 * // ... 나머지 테스트 메소드들도 위와 같은 방식으로 수정 ... }
 */
package com.model2.mvc.service.product.test;

