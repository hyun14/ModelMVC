
DROP TABLE transaction;
DROP TABLE product;
DROP TABLE users;
DROP TABLE product_image;


DROP SEQUENCE seq_product_prod_no;
DROP SEQUENCE seq_transaction_tran_no;
DROP SEQUENCE seq_product_image_img_no;


CREATE SEQUENCE seq_product_prod_no		 	INCREMENT BY 1 START WITH 10000;
CREATE SEQUENCE seq_transaction_tran_no	INCREMENT BY 1 START WITH 10000;
CREATE SEQUENCE seq_product_image_img_no INCREMENT BY 1 START WITH 1;


CREATE TABLE users ( 
	user_id 			VARCHAR2(20)	NOT NULL,
	user_name 	VARCHAR2(50)	NOT NULL,
	password 		VARCHAR2(10)	NOT NULL,
	role 					VARCHAR2(5) 		DEFAULT 'user',
	ssn 					VARCHAR2(13),
	cell_phone 		VARCHAR2(14),
	addr 				VARCHAR2(100),
	email 				VARCHAR2(50),
	reg_date 		DATE,
	PRIMARY KEY(user_id)
);


CREATE TABLE product ( 
	prod_no 						NUMBER 				NOT NULL,
	prod_name 				VARCHAR2(100) 	NOT NULL,
	prod_detail 				VARCHAR2(200),
	manufacture_day		VARCHAR2(8),
	price 							NUMBER(10),
	image_file 					VARCHAR2(100),
	reg_date 					DATE,
	PRIMARY KEY(prod_no)
);

CREATE TABLE transaction ( 
	tran_no 					NUMBER 			NOT NULL,
	prod_no 					NUMBER(16)		NOT NULL REFERENCES product(prod_no),
	buyer_id 				VARCHAR2(20)	NOT NULL REFERENCES users(user_id),
	payment_option		CHAR(3),
	receiver_name 		VARCHAR2(20),
	receiver_phone		VARCHAR2(14),
	demailaddr 			VARCHAR2(100),
	dlvy_request 			VARCHAR2(100),
	tran_status_code	CHAR(3),
	order_data 			DATE,
	dlvy_date 				DATE,
	PRIMARY KEY(tran_no)
);

CREATE TABLE product_image (
  img_no      NUMBER        NOT NULL,
  prod_no     NUMBER        NOT NULL REFERENCES product(prod_no),
  file_name   VARCHAR2(200) NOT NULL,  -- 원본 파일명 or 저장 파일명
  file_path   VARCHAR2(300),           -- /images/product/{prodNo}/... 상대경로
  sort_order  NUMBER        DEFAULT 0,
  is_primary  CHAR(1)       DEFAULT 'N',   -- 'Y'면 대표 이미지
  reg_date    DATE          DEFAULT SYSDATE,
  CONSTRAINT pk_product_image PRIMARY KEY(img_no)
);


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
           
           
insert into product values (seq_product_prod_no.nextval,'vaio vgn FS70B','소니 바이오 노트북 신동품','20120514',2000000, 'AHlbAAAAtBqyWAAA.jpg',to_date('2012/12/14 11:27:27', 'YYYY/MM/DD HH24:MI:SS'));
insert into product values (seq_product_prod_no.nextval,'자전거','자전거 좋아요~','20120514',10000, 'AHlbAAAAvetFNwAA.jpg',to_date('2012/11/14 10:48:43', 'YYYY/MM/DD HH24:MI:SS'));
insert into product values (seq_product_prod_no.nextval,'보르도','최고 디자인 신품','20120201',1170000, 'AHlbAAAAvewfegAB.jpg',to_date('2012/10/14 10:49:39', 'YYYY/MM/DD HH24:MI:SS'));
insert into product values (seq_product_prod_no.nextval,'보드세트','한시즌 밖에 안썼습니다. 눈물을 머금고 내놓음 ㅠ.ㅠ','20120217', 200000, 'AHlbAAAAve1WwgAC.jpg',to_date('2012/11/14 10:50:58', 'YYYY/MM/DD HH24:MI:SS'));
insert into product values (seq_product_prod_no.nextval,'인라인','좋아욥','20120819', 20000, 'AHlbAAAAve37LwAD.jpg',to_date('2012/11/14 10:51:40', 'YYYY/MM/DD HH24:MI:SS'));
insert into product values (seq_product_prod_no.nextval,'삼성센스 2G','sens 메모리 2Giga','20121121',800000, 'AHlbAAAAtBqyWAAA.jpg',to_date('2012/11/14 18:46:58', 'YYYY/MM/DD HH24:MI:SS'));
insert into product values (seq_product_prod_no.nextval,'연꽃','정원을 가꿔보세요','20121022',232300, 'AHlbAAAAtDPSiQAA.jpg',to_date('2012/11/15 17:39:01', 'YYYY/MM/DD HH24:MI:SS'));
insert into product values (seq_product_prod_no.nextval,'삼성센스','노트북','20120212',600000, 'AHlbAAAAug1vsgAA.jpg',to_date('2012/11/12 13:04:31', 'YYYY/MM/DD HH24:MI:SS'));
-- 9
insert into product values (seq_product_prod_no.nextval,'LG그램','초경량 노트북, 학생/직장인에게 최적','20230315',1500000, 'BHlcBBBAtCqyWAAA.jpg',to_date('2023/05/10 09:30:00', 'YYYY/MM/DD HH24:MI:SS'));
-- 10
insert into product values (seq_product_prod_no.nextval,'아이폰 15 Pro','새것 같은 중고, 배터리 성능 98%','20230922',1200000, 'BHlcBBBAtCqyWAAB.jpg',to_date('2023/11/20 14:00:55', 'YYYY/MM/DD HH24:MI:SS'));
-- 11
insert into product values (seq_product_prod_no.nextval,'나이키 에어포스 1','클래식한 디자인, 사이즈 270mm','20221101',110000, 'CHldCCCAtDqyWAAA.jpg',to_date('2023/01/15 11:11:21', 'YYYY/MM/DD HH24:MI:SS'));
-- 12
insert into product values (seq_product_prod_no.nextval,'시디즈 의자 T50','허리가 편한 사무용 의자','20210820',250000, 'DHleDDDAtEqyWAAA.jpg',to_date('2022/02/28 16:25:30', 'YYYY/MM/DD HH24:MI:SS'));
-- 13
insert into product values (seq_product_prod_no.nextval,'기계식 키보드 (청축)','타건감이 좋은 게이밍 키보드','20230110',85000, 'EHlfEEEAtFqyWAAA.jpg',to_date('2023/03/05 18:45:10', 'YYYY/MM/DD HH24:MI:SS'));
-- 14
insert into product values (seq_product_prod_no.nextval,'삼성 32인치 4K 모니터','UHD 해상도, 전문가용 모니터','20220719',450000, 'FHlgFFFAtGqyWAAA.jpg',to_date('2022/09/12 20:10:05', 'YYYY/MM/DD HH24:MI:SS'));
-- 15
insert into product values (seq_product_prod_no.nextval,'반지의 제왕 전집','톨킨의 명작 소설 세트','20200505',40000, 'GHlhGGGGtHqyWAAA.jpg',to_date('2021/04/19 12:00:00', 'YYYY/MM/DD HH24:MI:SS'));
-- 16
insert into product values (seq_product_prod_no.nextval,'콜트 어쿠스틱 기타','입문용으로 좋은 통기타','20191201',180000, 'IHliHHHAtIqyWAAA.jpg',to_date('2020/10/30 13:30:45', 'YYYY/MM/DD HH24:MI:SS'));
-- 17
insert into product values (seq_product_prod_no.nextval,'코베아 4인용 텐트','가족 캠핑에 적합한 텐트','20230411',320000, 'JHljJJJAtJqyWAAA.jpg',to_date('2023/06/01 10:05:15', 'YYYY/MM/DD HH24:MI:SS'));
-- 18
insert into product values (seq_product_prod_no.nextval,'네스프레소 커피머신','간편하게 즐기는 캡슐 커피','20220630',130000, 'KHlkKKKAtKqyWAAA.jpg',to_date('2022/08/22 21:55:00', 'YYYY/MM/DD HH24:MI:SS'));
-- 19
insert into product values (seq_product_prod_no.nextval,'구찌 마몬트백','클래식한 디자인의 명품 핸드백','20211015',1800000, 'LHllLLLAtLqyWAAA.jpg',to_date('2022/01/07 15:18:29', 'YYYY/MM/DD HH24:MI:SS'));
-- 20
insert into product values (seq_product_prod_no.nextval,'JBL 블루투스 스피커','풍부한 사운드, 휴대성 좋음','20230228',99000, 'MHlmMMMAtMqyWAAA.jpg',to_date('2023/04/14 17:28:33', 'YYYY/MM/DD HH24:MI:SS'));
-- 21
insert into product values (seq_product_prod_no.nextval,'이케아 4인용 식탁세트','모던한 디자인의 원목 식탁과 의자','20220310',280000, 'NHlnNNNAtNqyWAAA.jpg',to_date('2022/05/20 19:00:11', 'YYYY/MM/DD HH24:MI:SS'));
-- 22
insert into product values (seq_product_prod_no.nextval,'조립식 덤벨 세트','무게 조절 가능한 가정용 덤벨','20230501',75000, 'OHloOOOAtOqyWAAA.jpg',to_date('2023/07/11 08:30:00', 'YYYY/MM/DD HH24:MI:SS'));
-- 23
insert into product values (seq_product_prod_no.nextval,'GeForce RTX 4070','고사양 게임을 위한 그래픽카드','20230413',850000, 'PHlpPPPAtPqyWAAA.jpg',to_date('2023/08/01 22:10:50', 'YYYY/MM/DD HH24:MI:SS'));
-- 24
insert into product values (seq_product_prod_no.nextval,'파타고니아 레트로-X 자켓','따뜻한 플리스 소재의 겨울 자켓','20220915',210000, 'QHlqQQQAtQqyWAAA.jpg',to_date('2022/11/18 12:43:00', 'YYYY/MM/DD HH24:MI:SS'));
-- 25
insert into product values (seq_product_prod_no.nextval,'티쏘 PRC200 시계','클래식한 디자인의 남성용 메탈시계','20201125',420000, 'RHlrRRRAtRqyWAAA.jpg',to_date('2021/02/10 16:00:00', 'YYYY/MM/DD HH24:MI:SS'));
-- 26
insert into product values (seq_product_prod_no.nextval,'비틀즈 LP판 컬렉션','Abbey Road 등 명반 3장 세트','19690926',150000, 'SHlsSSSAtSqyWAAA.jpg',to_date('2023/09/05 14:22:13', 'YYYY/MM/DD HH24:MI:SS'));
-- 27
insert into product values (seq_product_prod_no.nextval,'DJI 미니3 드론','4K 촬영이 가능한 입문용 드론','20221209',680000, 'THltTTTAtTqyWAAA.jpg',to_date('2023/02/14 11:35:00', 'YYYY/MM/DD HH24:MI:SS'));
-- 28
insert into product values (seq_product_prod_no.nextval,'캐논 EOS 200D II','가볍고 쓰기 편한 DSLR 카메라','20190410',550000, 'UHluUUUAtUqyWAAA.jpg',to_date('2019/08/20 10:10:10', 'YYYY/MM/DD HH24:MI:SS'));

commit;