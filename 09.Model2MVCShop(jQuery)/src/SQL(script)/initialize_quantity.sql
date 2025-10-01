
DROP TABLE transaction CASCADE CONSTRAINTS;
DROP TABLE product CASCADE CONSTRAINTS;
DROP TABLE users CASCADE CONSTRAINTS;
DROP TABLE product_image CASCADE CONSTRAINTS;


DROP SEQUENCE seq_product_prod_no;
DROP SEQUENCE seq_transaction_tran_no;
DROP SEQUENCE seq_product_image_no;

DROP INDEX idx_product_image_prod;


CREATE SEQUENCE seq_product_prod_no		 	INCREMENT BY 1 START WITH 10000;
CREATE SEQUENCE seq_transaction_tran_no	INCREMENT BY 1 START WITH 10000;
CREATE SEQUENCE seq_product_image_no INCREMENT BY 1 START WITH 1;

CREATE TABLE users (
    user_id      VARCHAR2(20)   NOT NULL,
    user_name    VARCHAR2(50)   NOT NULL,
    password     VARCHAR2(10)   NOT NULL,
    role         VARCHAR2(5)    DEFAULT 'user',
    ssn          VARCHAR2(13),
    cell_phone   VARCHAR2(14),
    addr         VARCHAR2(100),
    email        VARCHAR2(50),
    reg_date     DATE,
    PRIMARY KEY(user_id)
);

CREATE TABLE product (
    prod_no         NUMBER          NOT NULL,
    prod_name       VARCHAR2(100)   NOT NULL,
    prod_detail     VARCHAR2(200),
    manufacture_day VARCHAR2(8),
    price           NUMBER(10),
    image_file      VARCHAR2(100),
    reg_date        DATE,
    quantity        NUMBER(10)      DEFAULT 0 NOT NULL,
    is_sell         CHAR(1)         DEFAULT 'N' NOT NULL,
    PRIMARY KEY(prod_no),
    CONSTRAINT ck_product_quantity_nonneg CHECK (quantity >= 0),
    CONSTRAINT ck_product_is_sell_yn CHECK (is_sell IN ('Y','N'))
);

CREATE TABLE transaction (
    tran_no          NUMBER         NOT NULL,
    prod_no          NUMBER(16)     NOT NULL REFERENCES product(prod_no),
    buyer_id         VARCHAR2(20)   NOT NULL REFERENCES users(user_id),
    payment_option   CHAR(3),
    receiver_name    VARCHAR2(20),
    receiver_phone   VARCHAR2(14),
    demailaddr       VARCHAR2(100),
    dlvy_request     VARCHAR2(100),
    tran_status_code CHAR(3),
    order_data       DATE,
    dlvy_date        DATE,
    sell_quantity    NUMBER(10)     NOT NULL,
    PRIMARY KEY(tran_no),
    CONSTRAINT ck_tran_sell_qty_pos CHECK (sell_quantity >= 1)
);

CREATE TABLE product_image (
    image_no   NUMBER         NOT NULL,
    prod_no    NUMBER         NOT NULL REFERENCES product(prod_no) ON DELETE CASCADE,
    image_path VARCHAR2(300)  NOT NULL,
    sort_ord   NUMBER         DEFAULT 1,
    PRIMARY KEY(image_no)
);

CREATE INDEX idx_product_image_prod ON product_image(prod_no);

INSERT 
INTO users ( user_id, user_name, password, role, ssn, cell_phone, addr, email, reg_date ) 
VALUES ( 'admin', 'admin', '1234', 'admin', NULL, NULL, '서울시 서초구', 'admin@mvc.com',to_date('2012/01/14 10:48:43', 'YYYY/MM/DD HH24:MI:SS')); 

INSERT 
INTO users ( user_id, user_name, password, role, ssn, cell_phone, addr, email, reg_date ) 
VALUES ( 'manager', 'manager', '1234', 'admin', NULL, NULL, NULL, 'manager@mvc.com', to_date('2012/01/14 10:48:43', 'YYYY/MM/DD HH24:MI:SS'));          

INSERT INTO users 
VALUES ( 'user01', 'SCOTT', '1111', 'user', NULL, NULL, NULL, NULL, sysdate); 

INSERT INTO users 
VALUES ( 'user02', 'SCOTT', '2222', 'user', NULL, NULL, NULL, NULL, sysdate); 

INSERT INTO users 
VALUES ( 'user03', 'SCOTT', '3333', 'user', NULL, NULL, NULL, NULL, sysdate); 

INSERT INTO users 
VALUES ( 'user04', 'SCOTT', '4444', 'user', NULL, NULL, NULL, NULL, sysdate); 

INSERT INTO users 
VALUES ( 'user05', 'SCOTT', '5555', 'user', NULL, NULL, NULL, NULL, sysdate); 

INSERT INTO users 
VALUES ( 'user06', 'SCOTT', '6666', 'user', NULL, NULL, NULL, NULL, sysdate); 

INSERT INTO users 
VALUES ( 'user07', 'SCOTT', '7777', 'user', NULL, NULL, NULL, NULL, sysdate); 

INSERT INTO users 
VALUES ( 'user08', 'SCOTT', '8888', 'user', NULL, NULL, NULL, NULL, sysdate); 

INSERT INTO users 
VALUES ( 'user09', 'SCOTT', '9999', 'user', NULL, NULL, NULL, NULL, sysdate); 

INSERT INTO users 
VALUES ( 'user10', 'SCOTT', '1010', 'user', NULL, NULL, NULL, NULL, sysdate); 

INSERT INTO users 
VALUES ( 'user11', 'SCOTT', '1111', 'user', NULL, NULL, NULL, NULL, sysdate);

INSERT INTO users 
VALUES ( 'user12', 'SCOTT', '1212', 'user', NULL, NULL, NULL, NULL, sysdate);

INSERT INTO users 
VALUES ( 'user13', 'SCOTT', '1313', 'user', NULL, NULL, NULL, NULL, sysdate);

INSERT INTO users 
VALUES ( 'user14', 'SCOTT', '1414', 'user', NULL, NULL, NULL, NULL, sysdate);

INSERT INTO users 
VALUES ( 'user15', 'SCOTT', '1515', 'user', NULL, NULL, NULL, NULL, sysdate);

INSERT INTO users 
VALUES ( 'user16', 'SCOTT', '1616', 'user', NULL, NULL, NULL, NULL, sysdate);

INSERT INTO users 
VALUES ( 'user17', 'SCOTT', '1717', 'user', NULL, NULL, NULL, NULL, sysdate);

INSERT INTO users 
VALUES ( 'user18', 'SCOTT', '1818', 'user', NULL, NULL, NULL, NULL, sysdate);

INSERT INTO users 
VALUES ( 'user19', 'SCOTT', '1919', 'user', NULL, NULL, NULL, NULL, sysdate);
           
           
--------------------------------------------------------------------------------
-- 1) 상품 더미 데이터 20건 (각 행 직후 동일 세션에서 CURRVAL로 이미지 2건 추가)
--    주의: 아래 스크립트는 "한 세션"에서 순서대로 실행되어야 합니다.
--------------------------------------------------------------------------------

-- 001
INSERT INTO product (
  prod_no, prod_name, prod_detail, manufacture_day, price, image_file, reg_date, quantity, is_sell
) VALUES (
  seq_product_prod_no.NEXTVAL,
  '무선 이어폰 A1',
  '블루투스 5.3, 액티브 노이즈 캔슬링, 최대 24시간 재생',
  '20250415', 129000, 'a1_main.jpg', SYSDATE-20, 35, 'Y'
);
INSERT INTO product_image (image_no, prod_no, image_path, sort_ord)
VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/a1_01.jpg', 1);
INSERT INTO product_image (image_no, prod_no, image_path, sort_ord)
VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/a1_02.jpg', 2);

-- 002
INSERT INTO product (
  prod_no, prod_name, prod_detail, manufacture_day, price, image_file, reg_date, quantity, is_sell
) VALUES (
  seq_product_prod_no.NEXTVAL,
  '기계식 키보드 K87',
  '87키 텐키리스, 핫스왑, 적축, RGB 백라이트',
  '20250302', 89000, 'k87_main.jpg', SYSDATE-28, 12, 'Y'
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/k87_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/k87_02.jpg', 2);

-- 003
INSERT INTO product VALUES (
  seq_product_prod_no.NEXTVAL,
  '게이밍 마우스 G520',
  'PAW3395 센서, 4K 폴링, 59g 초경량',
  '20250530', 79000, 'g520_main.jpg', SYSDATE-15, 50, 'Y'
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/g520_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/g520_02.jpg', 2);

-- 004
INSERT INTO product VALUES (
  seq_product_prod_no.NEXTVAL,
  '27인치 모니터 Q27',
  '27" 2560x1440, 165Hz, IPS, HDR400',
  '20250220', 269000, 'q27_main.jpg', SYSDATE-40, 8, 'Y'
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/q27_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/q27_02.jpg', 2);

-- 005
INSERT INTO product VALUES (
  seq_product_prod_no.NEXTVAL,
  'USB-C 허브 H8',
  '8-in-1, 100W PD, HDMI 4K, SD/TF',
  '20250325', 49000, 'h8_main.jpg', SYSDATE-9, 72, 'Y'
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/h8_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/h8_02.jpg', 2);

-- 006
INSERT INTO product VALUES (
  seq_product_prod_no.NEXTVAL,
  '외장 SSD X1 1TB',
  'USB 3.2 Gen2, 최대 1050MB/s',
  '20250118', 119000, 'x1_main.jpg', SYSDATE-60, 25, 'Y'
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/x1_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/x1_02.jpg', 2);

-- 007
INSERT INTO product VALUES (
  seq_product_prod_no.NEXTVAL,
  '노트북 스탠드 S360',
  '알루미늄, 각도/높이 조절, 맥북 호환',
  '20250401', 39000, 's360_main.jpg', SYSDATE-7, 44, 'Y'
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/s360_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/s360_02.jpg', 2);

-- 008
INSERT INTO product VALUES (
  seq_product_prod_no.NEXTVAL,
  '블루투스 스피커 B3',
  'IPX7 방수, 20W 출력, TWS 페어링',
  '20250505', 69000, 'b3_main.jpg', SYSDATE-11, 0, 'N'  -- 품절 예시
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/b3_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/b3_02.jpg', 2);

-- 009
INSERT INTO product VALUES (
  seq_product_prod_no.NEXTVAL,
  '액션캠 AC9',
  '4K60, 손떨림보정, 방수하우징 포함',
  '20250318', 229000, 'ac9_main.jpg', SYSDATE-25, 13, 'Y'
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/ac9_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/ac9_02.jpg', 2);

-- 010
INSERT INTO product VALUES (
  seq_product_prod_no.NEXTVAL,
  '스마트워치 W2',
  'AMOLED, GPS, 5ATM, 7일 배터리',
  '20250428', 159000, 'w2_main.jpg', SYSDATE-17, 31, 'Y'
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/w2_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/w2_02.jpg', 2);

-- 011
INSERT INTO product VALUES (
  seq_product_prod_no.NEXTVAL,
  '충전기 C140',
  '140W GaN, 듀얼 USB-C + USB-A',
  '20250211', 89000, 'c140_main.jpg', SYSDATE-48, 19, 'Y'
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/c140_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/c140_02.jpg', 2);

-- 012
INSERT INTO product VALUES (
  seq_product_prod_no.NEXTVAL,
  '휴대용 선풍기 F9',
  'BLDC 모터, 3단 풍량, 저소음',
  '20240510', 29000, 'f9_main.jpg', SYSDATE-120, 6, 'Y'
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/f9_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/f9_02.jpg', 2);

-- 013
INSERT INTO product VALUES (
  seq_product_prod_no.NEXTVAL,
  '전동 드라이버 D20',
  '토크 10단, USB-C 충전, 비트 세트 포함',
  '20241122', 59000, 'd20_main.jpg', SYSDATE-200, 27, 'Y'
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/d20_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/d20_02.jpg', 2);

-- 014
INSERT INTO product VALUES (
  seq_product_prod_no.NEXTVAL,
  '캠핑 랜턴 L300',
  '300lm, 무드등, 보조배터리 기능',
  '20250312', 39000, 'l300_main.jpg', SYSDATE-33, 18, 'Y'
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/l300_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/l300_02.jpg', 2);

-- 015
INSERT INTO product VALUES (
  seq_product_prod_no.NEXTVAL,
  '전동 면도기 S5',
  '3헤드 플로팅, 방수, 고속충전',
  '20250205', 79000, 's5_main.jpg', SYSDATE-55, 9, 'Y'
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/s5_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/s5_02.jpg', 2);

-- 016
INSERT INTO product VALUES (
  seq_product_prod_no.NEXTVAL,
  '무선 청소기 V10',
  '220W 흡입, 멀티 브러시, 벽걸이 거치',
  '20250127', 259000, 'v10_main.jpg', SYSDATE-70, 14, 'Y'
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/v10_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/v10_02.jpg', 2);

-- 017
INSERT INTO product VALUES (
  seq_product_prod_no.NEXTVAL,
  '전기포트 EK1',
  '1.7L, 온도제어, 보온 기능',
  '20241205', 49000, 'ek1_main.jpg', SYSDATE-180, 22, 'Y'
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/ek1_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/ek1_02.jpg', 2);

-- 018
INSERT INTO product VALUES (
  seq_product_prod_no.NEXTVAL,
  '공기청정기 A50',
  'HEPA13, 40㎡, 스마트앱 연동',
  '20250322', 199000, 'a50_main.jpg', SYSDATE-22, 5, 'Y'
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/a50_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/a50_02.jpg', 2);

-- 019
INSERT INTO product VALUES (
  seq_product_prod_no.NEXTVAL,
  '전동 킥보드 E-Plus',
  '최대 30km, 전후 서스펜션, 앱 잠금',
  '20250405', 369000, 'eplus_main.jpg', SYSDATE-14, 3, 'Y'
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/eplus_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/eplus_02.jpg', 2);

-- 020
INSERT INTO product VALUES (
  seq_product_prod_no.NEXTVAL,
  '스마트 체중계 S-Scale',
  'BIA 체지방, 15가지 지표, 앱 연동',
  '20250501', 39000, 'sscale_main.jpg', SYSDATE-10, 41, 'Y'
);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/sscale_01.jpg', 1);
INSERT INTO product_image VALUES (seq_product_image_no.NEXTVAL, seq_product_prod_no.CURRVAL, '/upload/sscale_02.jpg', 2);

COMMIT;


commit;