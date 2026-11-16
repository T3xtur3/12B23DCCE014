-- OnlineSupermarket/ database/02_demo_seed.sql (merged development data)
-- Run database/01_schema.sql FIRST; this file contains *data only*.
-- Safe to re-import: unique usernames/codes and NOT EXISTS avoid duplicates;
-- existing member registrations and previous transactions are not overwritten.
-- This is SYNTHETIC TEST DATA only. NEVER import into production.
-- Expected on a fresh database: 112 users (2 original + 10 test + 100 extended),
-- 112 customer/staff identities? = 111 customer rows + 1 management staff row;
-- 1863 transactions (3 original + 400 in June + 1460 across 365 days).
-- DEMO ONLY login password for all customer_demo, customer_test and demo_kh users: Demo@12345
-- Note: date range covers the full year 2026, including simulated future dates.

USE OnlineSupermarketDB;
SET NAMES utf8mb4;
START TRANSACTION;

-- Original GitHub 02_demo_seed.sql (same INSERT operations, unchanged records).
-- Demo only: the two original accounts use password Demo@12345.
INSERT INTO tblMember4(id,userName,passwordHash,fullName,dateOfBirth,address,email,phoneNumber,role)
VALUES(101,'customer_demo','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Nguyễn Văn An','2003-08-15','123 Lê Lợi, Hà Nội','nguyenvanan@gmail.com','0912345678','CUSTOMER')
ON DUPLICATE KEY UPDATE userName=userName;
INSERT INTO tblCustomer4(tblMember4id,customerCode,memberStatus,registrationDate)
VALUES(101,'KH001',FALSE,NULL) ON DUPLICATE KEY UPDATE customerCode=customerCode;
INSERT INTO tblMember4(id,userName,passwordHash,fullName,dateOfBirth,address,email,phoneNumber,role)
VALUES(201,'manager_demo','pbkdf2_sha256$210000$0pNI2UnEv0XYqFarUxMqJA==$tGfm6uzc9t2UsZGyz+Ey2fdVSf/W3PaBG59uk27R9f8=','Trần Thị Bình','1992-04-20','18 Nguyễn Trãi, Hà Nội','manager@example.local','0987654321','MANAGEMENT')
ON DUPLICATE KEY UPDATE userName=userName;
INSERT INTO tblStaff4(tblMember4id,staffCode) VALUES(201,'NV001') ON DUPLICATE KEY UPDATE staffCode=staffCode;
INSERT INTO tblManagementStaff4(tblStaff4id) VALUES(201) ON DUPLICATE KEY UPDATE tblStaff4id=tblStaff4id;
INSERT INTO tblTransaction4(transactionCode,customerId,transactionTime,transactionValue,status,orderId)
VALUES('GD0001',101,'2026-06-05 09:30:00',4500000,'SUCCESS',NULL)
ON DUPLICATE KEY UPDATE transactionCode=transactionCode;
INSERT INTO tblTransaction4(transactionCode,customerId,transactionTime,transactionValue,status,orderId)
VALUES('GD0002',101,'2026-06-18 14:30:00',8000000,'SUCCESS',NULL)
ON DUPLICATE KEY UPDATE transactionCode=transactionCode;
INSERT INTO tblTransaction4(transactionCode,customerId,transactionTime,transactionValue,status,orderId)
VALUES('GD0003',101,'2026-06-20 10:00:00',2500000,'CANCELLED',NULL)
ON DUPLICATE KEY UPDATE transactionCode=transactionCode;

-- TEN UNREGISTERED TEST ACCOUNTS: customer_test_01 ... customer_test_10
-- Password matches customer_demo, because the password hash is selected from that row.
-- Existing account/member status is never reset during a re-import.
INSERT INTO tblMember4(userName,passwordHash,fullName,dateOfBirth,address,email,phoneNumber,role)
SELECT CONCAT('customer_test_', LPAD(n.n, 2, '0')), base.passwordHash,
       CONCAT('Khách hàng kiểm thử ', LPAD(n.n, 2, '0')),
       DATE('2002-01-01'), CONCAT('Địa chỉ kiểm thử ', n.n, ', Hà Nội'),
       CONCAT('customer_test_', LPAD(n.n, 2, '0'), '@example.local'),
       CONCAT('090', LPAD(n.n, 7, '0')), 'CUSTOMER'
FROM (
  SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
  UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
) n
CROSS JOIN tblMember4 base
WHERE base.userName='customer_demo'
ON DUPLICATE KEY UPDATE userName=userName;

INSERT INTO tblCustomer4(tblMember4id,customerCode,memberStatus,registrationDate)
SELECT m.id, CONCAT('CUST-TEST-', RIGHT(m.userName,2)), FALSE, NULL
FROM tblMember4 m
WHERE m.userName REGEXP '^customer_test_(0[1-9]|10)$'
  AND NOT EXISTS (SELECT 1 FROM tblCustomer4 c WHERE c.tblMember4id=m.id);

-- PART A: 100 MEMBER4 (login identities for customers).
INSERT INTO `tblMember4` (`userName`,`passwordHash`,`fullName`,`dateOfBirth`,`address`,`email`,`phoneNumber`,`role`) VALUES
('demo_kh_001','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Đặng Thu Lan','1988-08-12','41 Giải Phóng, Hà Nội','demo.kh001@example.com','0910083917','CUSTOMER'),
('demo_kh_002','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Mai Hữu Quân','2001-03-23','72 Lạc Long Quân, Hà Nội','demo.kh002@example.com','0910167834','CUSTOMER'),
('demo_kh_003','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Trần Đức Vy','1984-10-06','103 Cầu Giấy, Hà Nội','demo.kh003@example.com','0910251751','CUSTOMER'),
('demo_kh_004','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Bùi Khánh Huy','1997-05-17','134 Đội Cấn, Hà Nội','demo.kh004@example.com','0910335668','CUSTOMER'),
('demo_kh_005','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Trịnh Hải Phúc','1980-12-28','165 Nguyễn Trãi, Hà Nội','demo.kh005@example.com','0910419585','CUSTOMER'),
('demo_kh_006','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Lê Quang Tú','1993-07-11','196 Giải Phóng, Hà Nội','demo.kh006@example.com','0910503502','CUSTOMER'),
('demo_kh_007','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Đỗ Minh Hòa','1976-02-22','227 Lạc Long Quân, Hà Nội','demo.kh007@example.com','0910587419','CUSTOMER'),
('demo_kh_008','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Lý Bảo Nhung','1989-09-05','258 Cầu Giấy, Hà Nội','demo.kh008@example.com','0910671336','CUSTOMER'),
('demo_kh_009','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Phạm Phương Trinh','2002-04-16','289 Đội Cấn, Hà Nội','demo.kh009@example.com','0910755253','CUSTOMER'),
('demo_kh_010','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Hồ Thanh Hải','1985-11-27','40 Nguyễn Trãi, Hà Nội','demo.kh010@example.com','0910839170','CUSTOMER'),
('demo_kh_011','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Cao Thị Ngân','1998-06-10','71 Giải Phóng, Hà Nội','demo.kh011@example.com','0910923087','CUSTOMER'),
('demo_kh_012','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Hoàng Anh Thủy','1981-01-21','102 Lạc Long Quân, Hà Nội','demo.kh012@example.com','0911007004','CUSTOMER'),
('demo_kh_013','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Ngô Gia Giang','1994-08-04','133 Cầu Giấy, Hà Nội','demo.kh013@example.com','0911090921','CUSTOMER'),
('demo_kh_014','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Tạ Ngọc Nam','1977-03-15','164 Đội Cấn, Hà Nội','demo.kh014@example.com','0911174838','CUSTOMER'),
('demo_kh_015','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Phan Văn Thắng','1990-10-26','195 Nguyễn Trãi, Hà Nội','demo.kh015@example.com','0911258755','CUSTOMER'),
('demo_kh_016','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Dương Thu Dung','2003-05-09','226 Giải Phóng, Hà Nội','demo.kh016@example.com','0911342672','CUSTOMER'),
('demo_kh_017','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Tô Hữu Mai','1986-12-20','257 Lạc Long Quân, Hà Nội','demo.kh017@example.com','0911426589','CUSTOMER'),
('demo_kh_018','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Vũ Đức Thảo','1999-07-03','288 Cầu Giấy, Hà Nội','demo.kh018@example.com','0911510506','CUSTOMER'),
('demo_kh_019','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Đinh Khánh Bình','1982-02-14','39 Đội Cấn, Hà Nội','demo.kh019@example.com','0911594423','CUSTOMER'),
('demo_kh_020','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Nguyễn Hải Linh','1995-09-25','70 Nguyễn Trãi, Hà Nội','demo.kh020@example.com','0911678340','CUSTOMER'),
('demo_kh_021','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Đặng Quang Quỳnh','1978-04-08','101 Giải Phóng, Hà Nội','demo.kh021@example.com','0911762257','CUSTOMER'),
('demo_kh_022','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Mai Minh Yến','1991-11-19','132 Lạc Long Quân, Hà Nội','demo.kh022@example.com','0911846174','CUSTOMER'),
('demo_kh_023','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Trần Bảo Khánh','2004-06-02','163 Cầu Giấy, Hà Nội','demo.kh023@example.com','0911930091','CUSTOMER'),
('demo_kh_024','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Bùi Phương Phương','1987-01-13','194 Đội Cấn, Hà Nội','demo.kh024@example.com','0912014008','CUSTOMER'),
('demo_kh_025','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Trịnh Thanh Tuấn','2000-08-24','225 Nguyễn Trãi, Hà Nội','demo.kh025@example.com','0912097925','CUSTOMER'),
('demo_kh_026','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Lê Thị Hùng','1983-03-07','256 Giải Phóng, Hà Nội','demo.kh026@example.com','0912181842','CUSTOMER'),
('demo_kh_027','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Đỗ Anh Phong','1996-10-18','287 Lạc Long Quân, Hà Nội','demo.kh027@example.com','0912265759','CUSTOMER'),
('demo_kh_028','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Lý Gia Trung','1979-05-01','38 Cầu Giấy, Hà Nội','demo.kh028@example.com','0912349676','CUSTOMER'),
('demo_kh_029','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Phạm Ngọc Hân','1992-12-12','69 Đội Cấn, Hà Nội','demo.kh029@example.com','0912433593','CUSTOMER'),
('demo_kh_030','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Hồ Văn Ngọc','1975-07-23','100 Nguyễn Trãi, Hà Nội','demo.kh030@example.com','0912517510','CUSTOMER'),
('demo_kh_031','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Cao Thu Trang','1988-02-06','131 Giải Phóng, Hà Nội','demo.kh031@example.com','0912601427','CUSTOMER'),
('demo_kh_032','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Hoàng Hữu Hà','2001-09-17','162 Lạc Long Quân, Hà Nội','demo.kh032@example.com','0912685344','CUSTOMER'),
('demo_kh_033','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Ngô Đức Nga','1984-04-28','193 Cầu Giấy, Hà Nội','demo.kh033@example.com','0912769261','CUSTOMER'),
('demo_kh_034','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Tạ Khánh Thu','1997-11-11','224 Đội Cấn, Hà Nội','demo.kh034@example.com','0912853178','CUSTOMER'),
('demo_kh_035','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Phan Hải Đạt','1980-06-22','255 Nguyễn Trãi, Hà Nội','demo.kh035@example.com','0912937095','CUSTOMER'),
('demo_kh_036','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Dương Quang Minh','1993-01-05','286 Giải Phóng, Hà Nội','demo.kh036@example.com','0913021012','CUSTOMER'),
('demo_kh_037','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Tô Minh Thành','1976-08-16','37 Lạc Long Quân, Hà Nội','demo.kh037@example.com','0913104929','CUSTOMER'),
('demo_kh_038','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Vũ Bảo Chi','1989-03-27','68 Cầu Giấy, Hà Nội','demo.kh038@example.com','0913188846','CUSTOMER'),
('demo_kh_039','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Đinh Phương Long','2002-10-10','99 Đội Cấn, Hà Nội','demo.kh039@example.com','0913272763','CUSTOMER'),
('demo_kh_040','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Nguyễn Thanh Sơn','1985-05-21','130 Nguyễn Trãi, Hà Nội','demo.kh040@example.com','0913356680','CUSTOMER'),
('demo_kh_041','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Đặng Thị An','1998-12-04','161 Giải Phóng, Hà Nội','demo.kh041@example.com','0913440597','CUSTOMER'),
('demo_kh_042','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Mai Anh Lan','1981-07-15','192 Lạc Long Quân, Hà Nội','demo.kh042@example.com','0913524514','CUSTOMER'),
('demo_kh_043','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Trần Gia Quân','1994-02-26','223 Cầu Giấy, Hà Nội','demo.kh043@example.com','0913608431','CUSTOMER'),
('demo_kh_044','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Bùi Ngọc Vy','1977-09-09','254 Đội Cấn, Hà Nội','demo.kh044@example.com','0913692348','CUSTOMER'),
('demo_kh_045','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Trịnh Văn Huy','1990-04-20','285 Nguyễn Trãi, Hà Nội','demo.kh045@example.com','0913776265','CUSTOMER'),
('demo_kh_046','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Lê Thu Phúc','2003-11-03','36 Giải Phóng, Hà Nội','demo.kh046@example.com','0913860182','CUSTOMER'),
('demo_kh_047','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Đỗ Hữu Tú','1986-06-14','67 Lạc Long Quân, Hà Nội','demo.kh047@example.com','0913944099','CUSTOMER'),
('demo_kh_048','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Lý Đức Hòa','1999-01-25','98 Cầu Giấy, Hà Nội','demo.kh048@example.com','0914028016','CUSTOMER'),
('demo_kh_049','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Phạm Khánh Nhung','1982-08-08','129 Đội Cấn, Hà Nội','demo.kh049@example.com','0914111933','CUSTOMER'),
('demo_kh_050','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Hồ Hải Trinh','1995-03-19','160 Nguyễn Trãi, Hà Nội','demo.kh050@example.com','0914195850','CUSTOMER'),
('demo_kh_051','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Cao Quang Hải','1978-10-02','191 Giải Phóng, Hà Nội','demo.kh051@example.com','0914279767','CUSTOMER'),
('demo_kh_052','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Hoàng Minh Ngân','1991-05-13','222 Lạc Long Quân, Hà Nội','demo.kh052@example.com','0914363684','CUSTOMER'),
('demo_kh_053','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Ngô Bảo Thủy','2004-12-24','253 Cầu Giấy, Hà Nội','demo.kh053@example.com','0914447601','CUSTOMER'),
('demo_kh_054','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Tạ Phương Giang','1987-07-07','284 Đội Cấn, Hà Nội','demo.kh054@example.com','0914531518','CUSTOMER'),
('demo_kh_055','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Phan Thanh Nam','2000-02-18','35 Nguyễn Trãi, Hà Nội','demo.kh055@example.com','0914615435','CUSTOMER'),
('demo_kh_056','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Dương Thị Thắng','1983-09-01','66 Giải Phóng, Hà Nội','demo.kh056@example.com','0914699352','CUSTOMER'),
('demo_kh_057','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Tô Anh Dung','1996-04-12','97 Lạc Long Quân, Hà Nội','demo.kh057@example.com','0914783269','CUSTOMER'),
('demo_kh_058','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Vũ Gia Mai','1979-11-23','128 Cầu Giấy, Hà Nội','demo.kh058@example.com','0914867186','CUSTOMER'),
('demo_kh_059','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Đinh Ngọc Thảo','1992-06-06','159 Đội Cấn, Hà Nội','demo.kh059@example.com','0914951103','CUSTOMER'),
('demo_kh_060','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Nguyễn Văn Bình','1975-01-17','190 Nguyễn Trãi, Hà Nội','demo.kh060@example.com','0915035020','CUSTOMER'),
('demo_kh_061','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Đặng Thu Linh','1988-08-28','221 Giải Phóng, Hà Nội','demo.kh061@example.com','0915118937','CUSTOMER'),
('demo_kh_062','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Mai Hữu Quỳnh','2001-03-11','252 Lạc Long Quân, Hà Nội','demo.kh062@example.com','0915202854','CUSTOMER'),
('demo_kh_063','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Trần Đức Yến','1984-10-22','283 Cầu Giấy, Hà Nội','demo.kh063@example.com','0915286771','CUSTOMER'),
('demo_kh_064','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Bùi Khánh Khánh','1997-05-05','34 Đội Cấn, Hà Nội','demo.kh064@example.com','0915370688','CUSTOMER'),
('demo_kh_065','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Trịnh Hải Phương','1980-12-16','65 Nguyễn Trãi, Hà Nội','demo.kh065@example.com','0915454605','CUSTOMER'),
('demo_kh_066','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Lê Quang Tuấn','1993-07-27','96 Giải Phóng, Hà Nội','demo.kh066@example.com','0915538522','CUSTOMER'),
('demo_kh_067','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Đỗ Minh Hùng','1976-02-10','127 Lạc Long Quân, Hà Nội','demo.kh067@example.com','0915622439','CUSTOMER'),
('demo_kh_068','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Lý Bảo Phong','1989-09-21','158 Cầu Giấy, Hà Nội','demo.kh068@example.com','0915706356','CUSTOMER'),
('demo_kh_069','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Phạm Phương Trung','2002-04-04','189 Đội Cấn, Hà Nội','demo.kh069@example.com','0915790273','CUSTOMER'),
('demo_kh_070','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Hồ Thanh Hân','1985-11-15','220 Nguyễn Trãi, Hà Nội','demo.kh070@example.com','0915874190','CUSTOMER'),
('demo_kh_071','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Cao Thị Ngọc','1998-06-26','251 Giải Phóng, Hà Nội','demo.kh071@example.com','0915958107','CUSTOMER'),
('demo_kh_072','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Hoàng Anh Trang','1981-01-09','282 Lạc Long Quân, Hà Nội','demo.kh072@example.com','0916042024','CUSTOMER'),
('demo_kh_073','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Ngô Gia Hà','1994-08-20','33 Cầu Giấy, Hà Nội','demo.kh073@example.com','0916125941','CUSTOMER'),
('demo_kh_074','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Tạ Ngọc Nga','1977-03-03','64 Đội Cấn, Hà Nội','demo.kh074@example.com','0916209858','CUSTOMER'),
('demo_kh_075','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Phan Văn Thu','1990-10-14','95 Nguyễn Trãi, Hà Nội','demo.kh075@example.com','0916293775','CUSTOMER'),
('demo_kh_076','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Dương Thu Đạt','2003-05-25','126 Giải Phóng, Hà Nội','demo.kh076@example.com','0916377692','CUSTOMER'),
('demo_kh_077','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Tô Hữu Minh','1986-12-08','157 Lạc Long Quân, Hà Nội','demo.kh077@example.com','0916461609','CUSTOMER'),
('demo_kh_078','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Vũ Đức Thành','1999-07-19','188 Cầu Giấy, Hà Nội','demo.kh078@example.com','0916545526','CUSTOMER'),
('demo_kh_079','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Đinh Khánh Chi','1982-02-02','219 Đội Cấn, Hà Nội','demo.kh079@example.com','0916629443','CUSTOMER'),
('demo_kh_080','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Nguyễn Hải Long','1995-09-13','250 Nguyễn Trãi, Hà Nội','demo.kh080@example.com','0916713360','CUSTOMER'),
('demo_kh_081','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Đặng Quang Sơn','1978-04-24','281 Giải Phóng, Hà Nội','demo.kh081@example.com','0916797277','CUSTOMER'),
('demo_kh_082','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Mai Minh An','1991-11-07','32 Lạc Long Quân, Hà Nội','demo.kh082@example.com','0916881194','CUSTOMER'),
('demo_kh_083','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Trần Bảo Lan','2004-06-18','63 Cầu Giấy, Hà Nội','demo.kh083@example.com','0916965111','CUSTOMER'),
('demo_kh_084','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Bùi Phương Quân','1987-01-01','94 Đội Cấn, Hà Nội','demo.kh084@example.com','0917049028','CUSTOMER'),
('demo_kh_085','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Trịnh Thanh Vy','2000-08-12','125 Nguyễn Trãi, Hà Nội','demo.kh085@example.com','0917132945','CUSTOMER'),
('demo_kh_086','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Lê Thị Huy','1983-03-23','156 Giải Phóng, Hà Nội','demo.kh086@example.com','0917216862','CUSTOMER'),
('demo_kh_087','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Đỗ Anh Phúc','1996-10-06','187 Lạc Long Quân, Hà Nội','demo.kh087@example.com','0917300779','CUSTOMER'),
('demo_kh_088','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Lý Gia Tú','1979-05-17','218 Cầu Giấy, Hà Nội','demo.kh088@example.com','0917384696','CUSTOMER'),
('demo_kh_089','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Phạm Ngọc Hòa','1992-12-28','249 Đội Cấn, Hà Nội','demo.kh089@example.com','0917468613','CUSTOMER'),
('demo_kh_090','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Hồ Văn Nhung','1975-07-11','280 Nguyễn Trãi, Hà Nội','demo.kh090@example.com','0917552530','CUSTOMER'),
('demo_kh_091','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Cao Thu Trinh','1988-02-22','31 Giải Phóng, Hà Nội','demo.kh091@example.com','0917636447','CUSTOMER'),
('demo_kh_092','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Hoàng Hữu Hải','2001-09-05','62 Lạc Long Quân, Hà Nội','demo.kh092@example.com','0917720364','CUSTOMER'),
('demo_kh_093','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Ngô Đức Ngân','1984-04-16','93 Cầu Giấy, Hà Nội','demo.kh093@example.com','0917804281','CUSTOMER'),
('demo_kh_094','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Tạ Khánh Thủy','1997-11-27','124 Đội Cấn, Hà Nội','demo.kh094@example.com','0917888198','CUSTOMER'),
('demo_kh_095','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Phan Hải Giang','1980-06-10','155 Nguyễn Trãi, Hà Nội','demo.kh095@example.com','0917972115','CUSTOMER'),
('demo_kh_096','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Dương Quang Nam','1993-01-21','186 Giải Phóng, Hà Nội','demo.kh096@example.com','0918056032','CUSTOMER'),
('demo_kh_097','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Tô Minh Thắng','1976-08-04','217 Lạc Long Quân, Hà Nội','demo.kh097@example.com','0918139949','CUSTOMER'),
('demo_kh_098','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Vũ Bảo Dung','1989-03-15','248 Cầu Giấy, Hà Nội','demo.kh098@example.com','0918223866','CUSTOMER'),
('demo_kh_099','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Đinh Phương Mai','2002-10-26','279 Đội Cấn, Hà Nội','demo.kh099@example.com','0918307783','CUSTOMER'),
('demo_kh_100','pbkdf2_sha256$210000$NNgI4jgb0sZbMva7FD5eCA==$oxolWltGXqohpBG4rSUxhh+RCb+AO1LPfQ5k1mdqBwQ=','Nguyễn Thanh Thảo','1985-05-09','30 Nguyễn Trãi, Hà Nội','demo.kh100@example.com','0918391700','CUSTOMER')
ON DUPLICATE KEY UPDATE `userName` = `userName`;

-- PART B: customer records with some registered members and some not yet registered.
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-001', 1, '2026-05-02' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-002', 1, '2026-05-03' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-003', 1, '2026-05-04' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-004', 1, '2026-05-05' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-005', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-006', 1, '2026-05-07' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-007', 1, '2026-05-08' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-008', 1, '2026-05-09' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-009', 1, '2026-05-10' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-010', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-011', 1, '2026-05-12' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-012', 1, '2026-05-13' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-013', 1, '2026-05-14' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-014', 1, '2026-05-15' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-015', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-016', 1, '2026-05-17' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-017', 1, '2026-05-18' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-018', 1, '2026-05-19' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-019', 1, '2026-05-20' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-020', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-021', 1, '2026-05-22' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-022', 1, '2026-05-23' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-023', 1, '2026-05-24' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-024', 1, '2026-05-25' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-025', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-026', 1, '2026-05-27' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-027', 1, '2026-05-01' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-028', 1, '2026-05-02' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-029', 1, '2026-05-03' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-030', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-031', 1, '2026-05-05' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-032', 1, '2026-05-06' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-033', 1, '2026-05-07' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-034', 1, '2026-05-08' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-035', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-036', 1, '2026-05-10' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-037', 1, '2026-05-11' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-038', 1, '2026-05-12' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-039', 1, '2026-05-13' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-040', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-041', 1, '2026-05-15' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-042', 1, '2026-05-16' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-043', 1, '2026-05-17' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-044', 1, '2026-05-18' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-045', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-046', 1, '2026-05-20' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-047', 1, '2026-05-21' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-048', 1, '2026-05-22' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-049', 1, '2026-05-23' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-050', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-051', 1, '2026-05-25' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-052', 1, '2026-05-26' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-053', 1, '2026-05-27' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-054', 1, '2026-05-01' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-055', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-056', 1, '2026-05-03' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-057', 1, '2026-05-04' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-058', 1, '2026-05-05' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-059', 1, '2026-05-06' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-060', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-061', 1, '2026-05-08' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-062', 1, '2026-05-09' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-063', 1, '2026-05-10' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-064', 1, '2026-05-11' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-065', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-066', 1, '2026-05-13' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-067', 1, '2026-05-14' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-068', 1, '2026-05-15' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-069', 1, '2026-05-16' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-070', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-071', 1, '2026-05-18' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-072', 1, '2026-05-19' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-073', 1, '2026-05-20' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-074', 1, '2026-05-21' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-075', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-076', 1, '2026-05-23' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-077', 1, '2026-05-24' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-078', 1, '2026-05-25' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-079', 1, '2026-05-26' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-080', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-081', 1, '2026-05-01' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-082', 1, '2026-05-02' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-083', 1, '2026-05-03' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-084', 1, '2026-05-04' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-085', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-086', 1, '2026-05-06' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-087', 1, '2026-05-07' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-088', 1, '2026-05-08' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-089', 1, '2026-05-09' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-090', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-091', 1, '2026-05-11' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-092', 1, '2026-05-12' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-093', 1, '2026-05-13' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-094', 1, '2026-05-14' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-095', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-096', 1, '2026-05-16' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-097', 1, '2026-05-17' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-098', 1, '2026-05-18' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-099', 1, '2026-05-19' FROM `tblMember4` m
WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);
INSERT INTO `tblCustomer4` (`tblMember4id`,`customerCode`,`memberStatus`,`registrationDate`)
SELECT m.`id`, 'DEMO-KH-100', 0, NULL FROM `tblMember4` m
WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblCustomer4` c WHERE c.`tblMember4id`=m.`id`);

-- PART C: 4 transactions per customer, dates from 2026-06-01 through 2026-06-28.
-- All orderId=NULL on purpose: this module allows standalone transactions.
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0001', m.`id`, '2026-06-13 12:18:00', 230000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0001');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0002', m.`id`, '2026-06-20 15:29:00', 273000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0002');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0003', m.`id`, '2026-06-27 18:40:00', 316000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0003');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0004', m.`id`, '2026-06-06 08:51:00', 359000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0004');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0005', m.`id`, '2026-06-18 13:25:00', 327000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0005');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0006', m.`id`, '2026-06-25 16:36:00', 370000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0006');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0007', m.`id`, '2026-06-04 19:47:00', 413000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0007');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0008', m.`id`, '2026-06-11 09:58:00', 456000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0008');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0009', m.`id`, '2026-06-23 14:32:00', 424000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0009');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0010', m.`id`, '2026-06-02 17:43:00', 467000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0010');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0011', m.`id`, '2026-06-09 20:54:00', 510000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0011');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0012', m.`id`, '2026-06-16 10:05:00', 553000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0012');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0013', m.`id`, '2026-06-28 15:39:00', 521000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0013');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0014', m.`id`, '2026-06-07 18:50:00', 564000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0014');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0015', m.`id`, '2026-06-14 08:01:00', 607000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0015');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0016', m.`id`, '2026-06-21 11:12:00', 650000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0016');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0017', m.`id`, '2026-06-05 16:46:00', 618000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0017');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0018', m.`id`, '2026-06-12 19:57:00', 661000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0018');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0019', m.`id`, '2026-06-19 09:08:00', 704000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0019');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0020', m.`id`, '2026-06-26 12:19:00', 747000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0020');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0021', m.`id`, '2026-06-10 17:53:00', 715000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0021');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0022', m.`id`, '2026-06-17 20:04:00', 758000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0022');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0023', m.`id`, '2026-06-24 10:15:00', 801000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0023');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0024', m.`id`, '2026-06-03 13:26:00', 844000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0024');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0025', m.`id`, '2026-06-15 18:00:00', 812000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0025');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0026', m.`id`, '2026-06-22 08:11:00', 855000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0026');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0027', m.`id`, '2026-06-01 11:22:00', 898000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0027');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0028', m.`id`, '2026-06-08 14:33:00', 941000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0028');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0029', m.`id`, '2026-06-20 19:07:00', 909000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0029');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0030', m.`id`, '2026-06-27 09:18:00', 952000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0030');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0031', m.`id`, '2026-06-06 12:29:00', 995000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0031');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0032', m.`id`, '2026-06-13 15:40:00', 1038000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0032');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0033', m.`id`, '2026-06-25 20:14:00', 1006000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0033');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0034', m.`id`, '2026-06-04 10:25:00', 1049000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0034');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0035', m.`id`, '2026-06-11 13:36:00', 132000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0035');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0036', m.`id`, '2026-06-18 16:47:00', 175000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0036');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0037', m.`id`, '2026-06-02 08:21:00', 143000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0037');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0038', m.`id`, '2026-06-09 11:32:00', 186000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0038');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0039', m.`id`, '2026-06-16 14:43:00', 229000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0039');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0040', m.`id`, '2026-06-23 17:54:00', 272000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0040');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0041', m.`id`, '2026-06-07 09:28:00', 240000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0041');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0042', m.`id`, '2026-06-14 12:39:00', 283000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0042');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0043', m.`id`, '2026-06-21 15:50:00', 326000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0043');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0044', m.`id`, '2026-06-28 18:01:00', 369000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0044');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0045', m.`id`, '2026-06-12 10:35:00', 337000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0045');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0046', m.`id`, '2026-06-19 13:46:00', 380000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0046');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0047', m.`id`, '2026-06-26 16:57:00', 423000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0047');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0048', m.`id`, '2026-06-05 19:08:00', 466000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0048');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0049', m.`id`, '2026-06-17 11:42:00', 434000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0049');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0050', m.`id`, '2026-06-24 14:53:00', 477000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0050');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0051', m.`id`, '2026-06-03 17:04:00', 520000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0051');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0052', m.`id`, '2026-06-10 20:15:00', 563000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0052');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0053', m.`id`, '2026-06-22 12:49:00', 531000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0053');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0054', m.`id`, '2026-06-01 15:00:00', 574000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0054');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0055', m.`id`, '2026-06-08 18:11:00', 617000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0055');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0056', m.`id`, '2026-06-15 08:22:00', 660000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0056');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0057', m.`id`, '2026-06-27 13:56:00', 628000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0057');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0058', m.`id`, '2026-06-06 16:07:00', 671000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0058');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0059', m.`id`, '2026-06-13 19:18:00', 714000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0059');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0060', m.`id`, '2026-06-20 09:29:00', 757000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0060');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0061', m.`id`, '2026-06-04 14:03:00', 725000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0061');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0062', m.`id`, '2026-06-11 17:14:00', 768000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0062');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0063', m.`id`, '2026-06-18 20:25:00', 811000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0063');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0064', m.`id`, '2026-06-25 10:36:00', 854000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0064');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0065', m.`id`, '2026-06-09 15:10:00', 822000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0065');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0066', m.`id`, '2026-06-16 18:21:00', 865000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0066');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0067', m.`id`, '2026-06-23 08:32:00', 908000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0067');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0068', m.`id`, '2026-06-02 11:43:00', 951000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0068');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0069', m.`id`, '2026-06-14 16:17:00', 919000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0069');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0070', m.`id`, '2026-06-21 19:28:00', 962000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0070');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0071', m.`id`, '2026-06-28 09:39:00', 1005000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0071');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0072', m.`id`, '2026-06-07 12:50:00', 1048000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0072');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0073', m.`id`, '2026-06-19 17:24:00', 1016000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0073');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0074', m.`id`, '2026-06-26 20:35:00', 99000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0074');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0075', m.`id`, '2026-06-05 10:46:00', 142000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0075');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0076', m.`id`, '2026-06-12 13:57:00', 185000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0076');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0077', m.`id`, '2026-06-24 18:31:00', 153000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0077');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0078', m.`id`, '2026-06-03 08:42:00', 196000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0078');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0079', m.`id`, '2026-06-10 11:53:00', 239000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0079');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0080', m.`id`, '2026-06-17 14:04:00', 282000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0080');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0081', m.`id`, '2026-06-01 19:38:00', 250000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0081');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0082', m.`id`, '2026-06-08 09:49:00', 293000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0082');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0083', m.`id`, '2026-06-15 12:00:00', 336000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0083');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0084', m.`id`, '2026-06-22 15:11:00', 379000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0084');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0085', m.`id`, '2026-06-06 20:45:00', 347000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0085');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0086', m.`id`, '2026-06-13 10:56:00', 390000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0086');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0087', m.`id`, '2026-06-20 13:07:00', 433000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0087');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0088', m.`id`, '2026-06-27 16:18:00', 476000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0088');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0089', m.`id`, '2026-06-11 08:52:00', 444000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0089');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0090', m.`id`, '2026-06-18 11:03:00', 487000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0090');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0091', m.`id`, '2026-06-25 14:14:00', 530000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0091');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0092', m.`id`, '2026-06-04 17:25:00', 573000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0092');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0093', m.`id`, '2026-06-16 09:59:00', 541000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0093');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0094', m.`id`, '2026-06-23 12:10:00', 584000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0094');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0095', m.`id`, '2026-06-02 15:21:00', 627000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0095');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0096', m.`id`, '2026-06-09 18:32:00', 670000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0096');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0097', m.`id`, '2026-06-21 10:06:00', 638000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0097');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0098', m.`id`, '2026-06-28 13:17:00', 681000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0098');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0099', m.`id`, '2026-06-07 16:28:00', 724000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0099');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0100', m.`id`, '2026-06-14 19:39:00', 767000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0100');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0101', m.`id`, '2026-06-26 11:13:00', 735000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0101');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0102', m.`id`, '2026-06-05 14:24:00', 778000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0102');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0103', m.`id`, '2026-06-12 17:35:00', 821000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0103');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0104', m.`id`, '2026-06-19 20:46:00', 864000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0104');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0105', m.`id`, '2026-06-03 12:20:00', 832000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0105');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0106', m.`id`, '2026-06-10 15:31:00', 875000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0106');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0107', m.`id`, '2026-06-17 18:42:00', 918000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0107');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0108', m.`id`, '2026-06-24 08:53:00', 961000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0108');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0109', m.`id`, '2026-06-08 13:27:00', 929000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0109');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0110', m.`id`, '2026-06-15 16:38:00', 972000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0110');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0111', m.`id`, '2026-06-22 19:49:00', 1015000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0111');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0112', m.`id`, '2026-06-01 09:00:00', 98000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0112');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0113', m.`id`, '2026-06-13 14:34:00', 1026000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0113');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0114', m.`id`, '2026-06-20 17:45:00', 109000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0114');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0115', m.`id`, '2026-06-27 20:56:00', 152000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0115');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0116', m.`id`, '2026-06-06 10:07:00', 195000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0116');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0117', m.`id`, '2026-06-18 15:41:00', 163000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0117');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0118', m.`id`, '2026-06-25 18:52:00', 206000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0118');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0119', m.`id`, '2026-06-04 08:03:00', 249000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0119');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0120', m.`id`, '2026-06-11 11:14:00', 292000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0120');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0121', m.`id`, '2026-06-23 16:48:00', 260000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0121');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0122', m.`id`, '2026-06-02 19:59:00', 303000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0122');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0123', m.`id`, '2026-06-09 09:10:00', 346000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0123');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0124', m.`id`, '2026-06-16 12:21:00', 389000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0124');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0125', m.`id`, '2026-06-28 17:55:00', 357000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0125');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0126', m.`id`, '2026-06-07 20:06:00', 400000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0126');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0127', m.`id`, '2026-06-14 10:17:00', 443000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0127');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0128', m.`id`, '2026-06-21 13:28:00', 486000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0128');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0129', m.`id`, '2026-06-05 18:02:00', 454000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0129');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0130', m.`id`, '2026-06-12 08:13:00', 497000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0130');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0131', m.`id`, '2026-06-19 11:24:00', 540000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0131');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0132', m.`id`, '2026-06-26 14:35:00', 583000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0132');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0133', m.`id`, '2026-06-10 19:09:00', 551000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0133');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0134', m.`id`, '2026-06-17 09:20:00', 594000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0134');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0135', m.`id`, '2026-06-24 12:31:00', 637000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0135');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0136', m.`id`, '2026-06-03 15:42:00', 680000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0136');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0137', m.`id`, '2026-06-15 20:16:00', 648000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0137');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0138', m.`id`, '2026-06-22 10:27:00', 691000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0138');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0139', m.`id`, '2026-06-01 13:38:00', 734000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0139');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0140', m.`id`, '2026-06-08 16:49:00', 777000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0140');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0141', m.`id`, '2026-06-20 08:23:00', 745000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0141');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0142', m.`id`, '2026-06-27 11:34:00', 788000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0142');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0143', m.`id`, '2026-06-06 14:45:00', 831000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0143');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0144', m.`id`, '2026-06-13 17:56:00', 874000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0144');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0145', m.`id`, '2026-06-25 09:30:00', 842000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0145');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0146', m.`id`, '2026-06-04 12:41:00', 885000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0146');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0147', m.`id`, '2026-06-11 15:52:00', 928000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0147');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0148', m.`id`, '2026-06-18 18:03:00', 971000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0148');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0149', m.`id`, '2026-06-02 10:37:00', 939000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0149');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0150', m.`id`, '2026-06-09 13:48:00', 982000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0150');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0151', m.`id`, '2026-06-16 16:59:00', 1025000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0151');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0152', m.`id`, '2026-06-23 19:10:00', 108000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0152');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0153', m.`id`, '2026-06-07 11:44:00', 1036000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0153');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0154', m.`id`, '2026-06-14 14:55:00', 119000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0154');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0155', m.`id`, '2026-06-21 17:06:00', 162000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0155');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0156', m.`id`, '2026-06-28 20:17:00', 205000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0156');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0157', m.`id`, '2026-06-12 12:51:00', 173000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0157');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0158', m.`id`, '2026-06-19 15:02:00', 216000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0158');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0159', m.`id`, '2026-06-26 18:13:00', 259000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0159');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0160', m.`id`, '2026-06-05 08:24:00', 302000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0160');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0161', m.`id`, '2026-06-17 13:58:00', 270000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0161');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0162', m.`id`, '2026-06-24 16:09:00', 313000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0162');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0163', m.`id`, '2026-06-03 19:20:00', 356000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0163');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0164', m.`id`, '2026-06-10 09:31:00', 399000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0164');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0165', m.`id`, '2026-06-22 14:05:00', 367000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0165');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0166', m.`id`, '2026-06-01 17:16:00', 410000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0166');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0167', m.`id`, '2026-06-08 20:27:00', 453000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0167');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0168', m.`id`, '2026-06-15 10:38:00', 496000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0168');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0169', m.`id`, '2026-06-27 15:12:00', 464000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0169');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0170', m.`id`, '2026-06-06 18:23:00', 507000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0170');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0171', m.`id`, '2026-06-13 08:34:00', 550000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0171');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0172', m.`id`, '2026-06-20 11:45:00', 593000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0172');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0173', m.`id`, '2026-06-04 16:19:00', 561000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0173');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0174', m.`id`, '2026-06-11 19:30:00', 604000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0174');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0175', m.`id`, '2026-06-18 09:41:00', 647000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0175');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0176', m.`id`, '2026-06-25 12:52:00', 690000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0176');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0177', m.`id`, '2026-06-09 17:26:00', 658000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0177');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0178', m.`id`, '2026-06-16 20:37:00', 701000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0178');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0179', m.`id`, '2026-06-23 10:48:00', 744000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0179');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0180', m.`id`, '2026-06-02 13:59:00', 787000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0180');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0181', m.`id`, '2026-06-14 18:33:00', 755000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0181');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0182', m.`id`, '2026-06-21 08:44:00', 798000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0182');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0183', m.`id`, '2026-06-28 11:55:00', 841000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0183');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0184', m.`id`, '2026-06-07 14:06:00', 884000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0184');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0185', m.`id`, '2026-06-19 19:40:00', 852000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0185');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0186', m.`id`, '2026-06-26 09:51:00', 895000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0186');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0187', m.`id`, '2026-06-05 12:02:00', 938000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0187');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0188', m.`id`, '2026-06-12 15:13:00', 981000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0188');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0189', m.`id`, '2026-06-24 20:47:00', 949000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0189');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0190', m.`id`, '2026-06-03 10:58:00', 992000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0190');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0191', m.`id`, '2026-06-10 13:09:00', 1035000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0191');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0192', m.`id`, '2026-06-17 16:20:00', 118000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0192');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0193', m.`id`, '2026-06-01 08:54:00', 1046000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0193');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0194', m.`id`, '2026-06-08 11:05:00', 129000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0194');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0195', m.`id`, '2026-06-15 14:16:00', 172000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0195');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0196', m.`id`, '2026-06-22 17:27:00', 215000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0196');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0197', m.`id`, '2026-06-06 09:01:00', 183000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0197');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0198', m.`id`, '2026-06-13 12:12:00', 226000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0198');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0199', m.`id`, '2026-06-20 15:23:00', 269000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0199');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0200', m.`id`, '2026-06-27 18:34:00', 312000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0200');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0201', m.`id`, '2026-06-11 10:08:00', 280000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0201');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0202', m.`id`, '2026-06-18 13:19:00', 323000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0202');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0203', m.`id`, '2026-06-25 16:30:00', 366000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0203');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0204', m.`id`, '2026-06-04 19:41:00', 409000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0204');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0205', m.`id`, '2026-06-16 11:15:00', 377000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0205');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0206', m.`id`, '2026-06-23 14:26:00', 420000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0206');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0207', m.`id`, '2026-06-02 17:37:00', 463000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0207');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0208', m.`id`, '2026-06-09 20:48:00', 506000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0208');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0209', m.`id`, '2026-06-21 12:22:00', 474000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0209');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0210', m.`id`, '2026-06-28 15:33:00', 517000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0210');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0211', m.`id`, '2026-06-07 18:44:00', 560000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0211');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0212', m.`id`, '2026-06-14 08:55:00', 603000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0212');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0213', m.`id`, '2026-06-26 13:29:00', 571000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0213');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0214', m.`id`, '2026-06-05 16:40:00', 614000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0214');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0215', m.`id`, '2026-06-12 19:51:00', 657000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0215');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0216', m.`id`, '2026-06-19 09:02:00', 700000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0216');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0217', m.`id`, '2026-06-03 14:36:00', 668000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0217');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0218', m.`id`, '2026-06-10 17:47:00', 711000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0218');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0219', m.`id`, '2026-06-17 20:58:00', 754000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0219');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0220', m.`id`, '2026-06-24 10:09:00', 797000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0220');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0221', m.`id`, '2026-06-08 15:43:00', 765000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0221');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0222', m.`id`, '2026-06-15 18:54:00', 808000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0222');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0223', m.`id`, '2026-06-22 08:05:00', 851000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0223');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0224', m.`id`, '2026-06-01 11:16:00', 894000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0224');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0225', m.`id`, '2026-06-13 16:50:00', 862000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0225');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0226', m.`id`, '2026-06-20 19:01:00', 905000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0226');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0227', m.`id`, '2026-06-27 09:12:00', 948000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0227');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0228', m.`id`, '2026-06-06 12:23:00', 991000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0228');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0229', m.`id`, '2026-06-18 17:57:00', 959000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0229');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0230', m.`id`, '2026-06-25 20:08:00', 1002000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0230');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0231', m.`id`, '2026-06-04 10:19:00', 1045000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0231');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0232', m.`id`, '2026-06-11 13:30:00', 128000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0232');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0233', m.`id`, '2026-06-23 18:04:00', 96000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0233');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0234', m.`id`, '2026-06-02 08:15:00', 139000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0234');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0235', m.`id`, '2026-06-09 11:26:00', 182000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0235');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0236', m.`id`, '2026-06-16 14:37:00', 225000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0236');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0237', m.`id`, '2026-06-28 19:11:00', 193000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0237');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0238', m.`id`, '2026-06-07 09:22:00', 236000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0238');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0239', m.`id`, '2026-06-14 12:33:00', 279000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0239');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0240', m.`id`, '2026-06-21 15:44:00', 322000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0240');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0241', m.`id`, '2026-06-05 20:18:00', 290000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0241');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0242', m.`id`, '2026-06-12 10:29:00', 333000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0242');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0243', m.`id`, '2026-06-19 13:40:00', 376000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0243');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0244', m.`id`, '2026-06-26 16:51:00', 419000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0244');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0245', m.`id`, '2026-06-10 08:25:00', 387000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0245');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0246', m.`id`, '2026-06-17 11:36:00', 430000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0246');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0247', m.`id`, '2026-06-24 14:47:00', 473000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0247');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0248', m.`id`, '2026-06-03 17:58:00', 516000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0248');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0249', m.`id`, '2026-06-15 09:32:00', 484000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0249');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0250', m.`id`, '2026-06-22 12:43:00', 527000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0250');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0251', m.`id`, '2026-06-01 15:54:00', 570000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0251');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0252', m.`id`, '2026-06-08 18:05:00', 613000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0252');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0253', m.`id`, '2026-06-20 10:39:00', 581000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0253');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0254', m.`id`, '2026-06-27 13:50:00', 624000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0254');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0255', m.`id`, '2026-06-06 16:01:00', 667000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0255');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0256', m.`id`, '2026-06-13 19:12:00', 710000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0256');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0257', m.`id`, '2026-06-25 11:46:00', 678000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0257');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0258', m.`id`, '2026-06-04 14:57:00', 721000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0258');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0259', m.`id`, '2026-06-11 17:08:00', 764000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0259');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0260', m.`id`, '2026-06-18 20:19:00', 807000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0260');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0261', m.`id`, '2026-06-02 12:53:00', 775000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0261');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0262', m.`id`, '2026-06-09 15:04:00', 818000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0262');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0263', m.`id`, '2026-06-16 18:15:00', 861000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0263');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0264', m.`id`, '2026-06-23 08:26:00', 904000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0264');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0265', m.`id`, '2026-06-07 13:00:00', 872000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0265');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0266', m.`id`, '2026-06-14 16:11:00', 915000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0266');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0267', m.`id`, '2026-06-21 19:22:00', 958000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0267');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0268', m.`id`, '2026-06-28 09:33:00', 1001000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0268');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0269', m.`id`, '2026-06-12 14:07:00', 969000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0269');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0270', m.`id`, '2026-06-19 17:18:00', 1012000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0270');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0271', m.`id`, '2026-06-26 20:29:00', 95000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0271');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0272', m.`id`, '2026-06-05 10:40:00', 138000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0272');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0273', m.`id`, '2026-06-17 15:14:00', 106000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0273');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0274', m.`id`, '2026-06-24 18:25:00', 149000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0274');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0275', m.`id`, '2026-06-03 08:36:00', 192000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0275');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0276', m.`id`, '2026-06-10 11:47:00', 235000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0276');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0277', m.`id`, '2026-06-22 16:21:00', 203000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0277');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0278', m.`id`, '2026-06-01 19:32:00', 246000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0278');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0279', m.`id`, '2026-06-08 09:43:00', 289000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0279');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0280', m.`id`, '2026-06-15 12:54:00', 332000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0280');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0281', m.`id`, '2026-06-27 17:28:00', 300000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0281');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0282', m.`id`, '2026-06-06 20:39:00', 343000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0282');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0283', m.`id`, '2026-06-13 10:50:00', 386000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0283');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0284', m.`id`, '2026-06-20 13:01:00', 429000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0284');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0285', m.`id`, '2026-06-04 18:35:00', 397000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0285');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0286', m.`id`, '2026-06-11 08:46:00', 440000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0286');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0287', m.`id`, '2026-06-18 11:57:00', 483000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0287');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0288', m.`id`, '2026-06-25 14:08:00', 526000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0288');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0289', m.`id`, '2026-06-09 19:42:00', 494000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0289');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0290', m.`id`, '2026-06-16 09:53:00', 537000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0290');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0291', m.`id`, '2026-06-23 12:04:00', 580000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0291');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0292', m.`id`, '2026-06-02 15:15:00', 623000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0292');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0293', m.`id`, '2026-06-14 20:49:00', 591000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0293');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0294', m.`id`, '2026-06-21 10:00:00', 634000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0294');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0295', m.`id`, '2026-06-28 13:11:00', 677000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0295');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0296', m.`id`, '2026-06-07 16:22:00', 720000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0296');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0297', m.`id`, '2026-06-19 08:56:00', 688000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0297');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0298', m.`id`, '2026-06-26 11:07:00', 731000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0298');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0299', m.`id`, '2026-06-05 14:18:00', 774000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0299');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0300', m.`id`, '2026-06-12 17:29:00', 817000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0300');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0301', m.`id`, '2026-06-24 09:03:00', 785000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0301');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0302', m.`id`, '2026-06-03 12:14:00', 828000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0302');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0303', m.`id`, '2026-06-10 15:25:00', 871000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0303');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0304', m.`id`, '2026-06-17 18:36:00', 914000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0304');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0305', m.`id`, '2026-06-01 10:10:00', 882000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0305');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0306', m.`id`, '2026-06-08 13:21:00', 925000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0306');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0307', m.`id`, '2026-06-15 16:32:00', 968000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0307');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0308', m.`id`, '2026-06-22 19:43:00', 1011000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0308');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0309', m.`id`, '2026-06-06 11:17:00', 979000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0309');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0310', m.`id`, '2026-06-13 14:28:00', 1022000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0310');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0311', m.`id`, '2026-06-20 17:39:00', 105000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0311');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0312', m.`id`, '2026-06-27 20:50:00', 148000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0312');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0313', m.`id`, '2026-06-11 12:24:00', 116000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0313');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0314', m.`id`, '2026-06-18 15:35:00', 159000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0314');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0315', m.`id`, '2026-06-25 18:46:00', 202000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0315');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0316', m.`id`, '2026-06-04 08:57:00', 245000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0316');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0317', m.`id`, '2026-06-16 13:31:00', 213000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0317');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0318', m.`id`, '2026-06-23 16:42:00', 256000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0318');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0319', m.`id`, '2026-06-02 19:53:00', 299000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0319');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0320', m.`id`, '2026-06-09 09:04:00', 342000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0320');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0321', m.`id`, '2026-06-21 14:38:00', 310000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0321');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0322', m.`id`, '2026-06-28 17:49:00', 353000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0322');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0323', m.`id`, '2026-06-07 20:00:00', 396000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0323');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0324', m.`id`, '2026-06-14 10:11:00', 439000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0324');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0325', m.`id`, '2026-06-26 15:45:00', 407000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0325');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0326', m.`id`, '2026-06-05 18:56:00', 450000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0326');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0327', m.`id`, '2026-06-12 08:07:00', 493000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0327');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0328', m.`id`, '2026-06-19 11:18:00', 536000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0328');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0329', m.`id`, '2026-06-03 16:52:00', 504000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0329');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0330', m.`id`, '2026-06-10 19:03:00', 547000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0330');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0331', m.`id`, '2026-06-17 09:14:00', 590000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0331');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0332', m.`id`, '2026-06-24 12:25:00', 633000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0332');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0333', m.`id`, '2026-06-08 17:59:00', 601000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0333');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0334', m.`id`, '2026-06-15 20:10:00', 644000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0334');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0335', m.`id`, '2026-06-22 10:21:00', 687000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0335');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0336', m.`id`, '2026-06-01 13:32:00', 730000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0336');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0337', m.`id`, '2026-06-13 18:06:00', 698000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0337');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0338', m.`id`, '2026-06-20 08:17:00', 741000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0338');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0339', m.`id`, '2026-06-27 11:28:00', 784000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0339');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0340', m.`id`, '2026-06-06 14:39:00', 827000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0340');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0341', m.`id`, '2026-06-18 19:13:00', 795000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0341');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0342', m.`id`, '2026-06-25 09:24:00', 838000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0342');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0343', m.`id`, '2026-06-04 12:35:00', 881000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0343');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0344', m.`id`, '2026-06-11 15:46:00', 924000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0344');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0345', m.`id`, '2026-06-23 20:20:00', 892000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0345');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0346', m.`id`, '2026-06-02 10:31:00', 935000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0346');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0347', m.`id`, '2026-06-09 13:42:00', 978000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0347');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0348', m.`id`, '2026-06-16 16:53:00', 1021000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0348');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0349', m.`id`, '2026-06-28 08:27:00', 989000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0349');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0350', m.`id`, '2026-06-07 11:38:00', 1032000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0350');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0351', m.`id`, '2026-06-14 14:49:00', 115000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0351');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0352', m.`id`, '2026-06-21 17:00:00', 158000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0352');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0353', m.`id`, '2026-06-05 09:34:00', 126000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0353');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0354', m.`id`, '2026-06-12 12:45:00', 169000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0354');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0355', m.`id`, '2026-06-19 15:56:00', 212000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0355');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0356', m.`id`, '2026-06-26 18:07:00', 255000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0356');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0357', m.`id`, '2026-06-10 10:41:00', 223000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0357');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0358', m.`id`, '2026-06-17 13:52:00', 266000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0358');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0359', m.`id`, '2026-06-24 16:03:00', 309000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0359');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0360', m.`id`, '2026-06-03 19:14:00', 352000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0360');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0361', m.`id`, '2026-06-15 11:48:00', 320000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0361');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0362', m.`id`, '2026-06-22 14:59:00', 363000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0362');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0363', m.`id`, '2026-06-01 17:10:00', 406000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0363');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0364', m.`id`, '2026-06-08 20:21:00', 449000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0364');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0365', m.`id`, '2026-06-20 12:55:00', 417000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0365');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0366', m.`id`, '2026-06-27 15:06:00', 460000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0366');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0367', m.`id`, '2026-06-06 18:17:00', 503000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0367');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0368', m.`id`, '2026-06-13 08:28:00', 546000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0368');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0369', m.`id`, '2026-06-25 13:02:00', 514000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0369');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0370', m.`id`, '2026-06-04 16:13:00', 557000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0370');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0371', m.`id`, '2026-06-11 19:24:00', 600000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0371');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0372', m.`id`, '2026-06-18 09:35:00', 643000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0372');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0373', m.`id`, '2026-06-02 14:09:00', 611000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0373');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0374', m.`id`, '2026-06-09 17:20:00', 654000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0374');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0375', m.`id`, '2026-06-16 20:31:00', 697000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0375');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0376', m.`id`, '2026-06-23 10:42:00', 740000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0376');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0377', m.`id`, '2026-06-07 15:16:00', 708000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0377');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0378', m.`id`, '2026-06-14 18:27:00', 751000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0378');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0379', m.`id`, '2026-06-21 08:38:00', 794000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0379');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0380', m.`id`, '2026-06-28 11:49:00', 837000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0380');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0381', m.`id`, '2026-06-12 16:23:00', 805000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0381');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0382', m.`id`, '2026-06-19 19:34:00', 848000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0382');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0383', m.`id`, '2026-06-26 09:45:00', 891000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0383');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0384', m.`id`, '2026-06-05 12:56:00', 934000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0384');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0385', m.`id`, '2026-06-17 17:30:00', 902000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0385');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0386', m.`id`, '2026-06-24 20:41:00', 945000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0386');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0387', m.`id`, '2026-06-03 10:52:00', 988000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0387');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0388', m.`id`, '2026-06-10 13:03:00', 1031000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0388');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0389', m.`id`, '2026-06-22 18:37:00', 999000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0389');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0390', m.`id`, '2026-06-01 08:48:00', 1042000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0390');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0391', m.`id`, '2026-06-08 11:59:00', 125000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0391');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0392', m.`id`, '2026-06-15 14:10:00', 168000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0392');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0393', m.`id`, '2026-06-27 19:44:00', 136000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0393');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0394', m.`id`, '2026-06-06 09:55:00', 179000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0394');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0395', m.`id`, '2026-06-13 12:06:00', 222000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0395');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0396', m.`id`, '2026-06-20 15:17:00', 265000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0396');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0397', m.`id`, '2026-06-04 20:51:00', 233000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0397');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0398', m.`id`, '2026-06-11 10:02:00', 276000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0398');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0399', m.`id`, '2026-06-18 13:13:00', 319000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0399');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'DEMO-GD-0400', m.`id`, '2026-06-25 16:24:00', 362000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='DEMO-GD-0400');


-- PART C: DAILY TRANSACTIONS, ALL 365 DAYS OF YEAR 2026.
-- Each day: 3 SUCCESS + 1 CANCELLED/PENDING.
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-001-1', m.`id`, '2026-01-01 08:00:00', 95000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-001-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-001-2', m.`id`, '2026-01-01 12:13:00', 145000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-001-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-001-3', m.`id`, '2026-01-01 16:26:00', 588000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-001-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-001-4', m.`id`, '2026-01-01 20:39:00', 246000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-001-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-002-1', m.`id`, '2026-01-02 11:17:00', 238000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-002-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-002-2', m.`id`, '2026-01-02 15:30:00', 288000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-002-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-002-3', m.`id`, '2026-01-02 19:43:00', 339000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-002-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-002-4', m.`id`, '2026-01-02 09:56:00', 229000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-002-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-003-1', m.`id`, '2026-01-03 14:34:00', 112000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-003-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-003-2', m.`id`, '2026-01-03 18:47:00', 162000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-003-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-003-3', m.`id`, '2026-01-03 08:00:00', 212000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-003-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-003-4', m.`id`, '2026-01-03 12:13:00', 103000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-003-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-004-1', m.`id`, '2026-01-04 17:51:00', 255000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-004-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-004-2', m.`id`, '2026-01-04 21:04:00', 305000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-004-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-004-3', m.`id`, '2026-01-04 11:17:00', 86000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-004-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-004-4', m.`id`, '2026-01-04 15:30:00', 246000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-004-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-005-1', m.`id`, '2026-01-05 20:08:00', 128000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-005-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-005-2', m.`id`, '2026-01-05 10:21:00', 179000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-005-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-005-3', m.`id`, '2026-01-05 14:34:00', 339000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-005-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-005-4', m.`id`, '2026-01-05 18:47:00', 120000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-005-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-006-1', m.`id`, '2026-01-06 09:25:00', 272000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-006-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-006-2', m.`id`, '2026-01-06 13:38:00', 322000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-006-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-006-3', m.`id`, '2026-01-06 17:51:00', 212000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-006-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-006-4', m.`id`, '2026-01-06 21:04:00', 263000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-006-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-007-1', m.`id`, '2026-01-07 12:42:00', 145000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-007-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-007-2', m.`id`, '2026-01-07 16:55:00', 306000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-007-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-007-3', m.`id`, '2026-01-07 20:08:00', 86000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-007-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-007-4', m.`id`, '2026-01-07 10:21:00', 136000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-007-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-008-1', m.`id`, '2026-01-08 15:59:00', 86000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-008-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-008-2', m.`id`, '2026-01-08 19:12:00', 247000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-008-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-008-3', m.`id`, '2026-01-08 09:25:00', 297000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-008-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-008-4', m.`id`, '2026-01-08 13:38:00', 348000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-008-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-009-1', m.`id`, '2026-01-09 18:16:00', 340000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-009-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-009-2', m.`id`, '2026-01-09 08:29:00', 120000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-009-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-009-3', m.`id`, '2026-01-09 12:42:00', 171000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-009-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-009-4', m.`id`, '2026-01-09 16:55:00', 221000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-009-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-010-1', m.`id`, '2026-01-10 21:33:00', 213000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-010-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-010-2', m.`id`, '2026-01-10 11:46:00', 264000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-010-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-010-3', m.`id`, '2026-01-10 15:59:00', 314000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-010-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-010-4', m.`id`, '2026-01-10 19:12:00', 204000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-010-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-011-1', m.`id`, '2026-01-11 10:50:00', 87000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-011-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-011-2', m.`id`, '2026-01-11 14:03:00', 137000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-011-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-011-3', m.`id`, '2026-01-11 18:16:00', 561000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-011-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-011-4', m.`id`, '2026-01-11 08:29:00', 348000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-011-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-012-1', m.`id`, '2026-01-12 13:07:00', 230000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-012-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-012-2', m.`id`, '2026-01-12 17:20:00', 280000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-012-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-012-3', m.`id`, '2026-01-12 21:33:00', 171000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-012-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-012-4', m.`id`, '2026-01-12 11:46:00', 221000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-012-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-013-1', m.`id`, '2026-01-13 16:24:00', 103000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-013-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-013-2', m.`id`, '2026-01-13 20:37:00', 154000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-013-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-013-3', m.`id`, '2026-01-13 10:50:00', 314000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-013-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-013-4', m.`id`, '2026-01-13 14:03:00', 95000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-013-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-014-1', m.`id`, '2026-01-14 19:41:00', 247000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-014-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-014-2', m.`id`, '2026-01-14 09:54:00', 137000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-014-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-014-3', m.`id`, '2026-01-14 13:07:00', 188000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-014-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-014-4', m.`id`, '2026-01-14 17:20:00', 238000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-014-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-015-1', m.`id`, '2026-01-15 08:58:00', 188000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-015-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-015-2', m.`id`, '2026-01-15 12:11:00', 348000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-015-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-015-3', m.`id`, '2026-01-15 16:24:00', 129000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-015-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-015-4', m.`id`, '2026-01-15 20:37:00', 179000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-015-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-016-1', m.`id`, '2026-01-16 11:15:00', 172000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-016-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-016-2', m.`id`, '2026-01-16 15:28:00', 222000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-016-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-016-3', m.`id`, '2026-01-16 19:41:00', 272000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-016-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-016-4', m.`id`, '2026-01-16 09:54:00', 323000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-016-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-017-1', m.`id`, '2026-01-17 14:32:00', 315000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-017-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-017-2', m.`id`, '2026-01-17 18:45:00', 95000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-017-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-017-3', m.`id`, '2026-01-17 08:58:00', 146000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-017-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-017-4', m.`id`, '2026-01-17 12:11:00', 306000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-017-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-018-1', m.`id`, '2026-01-18 17:49:00', 188000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-018-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-018-2', m.`id`, '2026-01-18 21:02:00', 239000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-018-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-018-3', m.`id`, '2026-01-18 11:15:00', 289000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-018-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-018-4', m.`id`, '2026-01-18 15:28:00', 180000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-018-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-019-1', m.`id`, '2026-01-19 20:06:00', 332000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-019-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-019-2', m.`id`, '2026-01-19 10:19:00', 112000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-019-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-019-3', m.`id`, '2026-01-19 14:32:00', 272000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-019-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-019-4', m.`id`, '2026-01-19 18:45:00', 323000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-019-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-020-1', m.`id`, '2026-01-20 09:23:00', 205000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-020-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-020-2', m.`id`, '2026-01-20 13:36:00', 256000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-020-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-020-3', m.`id`, '2026-01-20 17:49:00', 146000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-020-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-020-4', m.`id`, '2026-01-20 21:02:00', 196000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-020-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-021-1', m.`id`, '2026-01-21 12:40:00', 348000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-021-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-021-2', m.`id`, '2026-01-21 16:53:00', 239000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-021-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-021-3', m.`id`, '2026-01-21 20:06:00', 867000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-021-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-021-4', m.`id`, '2026-01-21 10:19:00', 340000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-021-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-022-1', m.`id`, '2026-01-22 15:57:00', 290000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-022-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-022-2', m.`id`, '2026-01-22 19:10:00', 180000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-022-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-022-3', m.`id`, '2026-01-22 09:23:00', 231000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-022-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-022-4', m.`id`, '2026-01-22 13:36:00', 281000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-022-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-023-1', m.`id`, '2026-01-23 18:14:00', 273000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-023-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-023-2', m.`id`, '2026-01-23 08:27:00', 324000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-023-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-023-3', m.`id`, '2026-01-23 12:40:00', 104000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-023-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-023-4', m.`id`, '2026-01-23 16:53:00', 154000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-023-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-024-1', m.`id`, '2026-01-24 21:31:00', 147000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-024-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-024-2', m.`id`, '2026-01-24 11:44:00', 197000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-024-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-024-3', m.`id`, '2026-01-24 15:57:00', 247000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-024-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-024-4', m.`id`, '2026-01-24 19:10:00', 138000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-024-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-025-1', m.`id`, '2026-01-25 10:48:00', 290000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-025-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-025-2', m.`id`, '2026-01-25 14:01:00', 340000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-025-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-025-3', m.`id`, '2026-01-25 18:14:00', 121000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-025-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-025-4', m.`id`, '2026-01-25 08:27:00', 281000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-025-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-026-1', m.`id`, '2026-01-26 13:05:00', 163000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-026-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-026-2', m.`id`, '2026-01-26 17:18:00', 214000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-026-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-026-3', m.`id`, '2026-01-26 21:31:00', 104000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-026-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-026-4', m.`id`, '2026-01-26 11:44:00', 155000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-026-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-027-1', m.`id`, '2026-01-27 16:22:00', 307000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-027-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-027-2', m.`id`, '2026-01-27 20:35:00', 87000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-027-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-027-3', m.`id`, '2026-01-27 10:48:00', 248000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-027-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-027-4', m.`id`, '2026-01-27 14:01:00', 298000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-027-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-028-1', m.`id`, '2026-01-28 19:39:00', 180000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-028-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-028-2', m.`id`, '2026-01-28 09:52:00', 341000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-028-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-028-3', m.`id`, '2026-01-28 13:05:00', 121000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-028-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-028-4', m.`id`, '2026-01-28 17:18:00', 171000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-028-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-029-1', m.`id`, '2026-01-29 08:56:00', 122000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-029-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-029-2', m.`id`, '2026-01-29 12:09:00', 282000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-029-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-029-3', m.`id`, '2026-01-29 16:22:00', 332000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-029-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-029-4', m.`id`, '2026-01-29 20:35:00', 113000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-029-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-030-1', m.`id`, '2026-01-30 11:13:00', 105000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-030-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-030-2', m.`id`, '2026-01-30 15:26:00', 155000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-030-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-030-3', m.`id`, '2026-01-30 19:39:00', 206000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-030-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-030-4', m.`id`, '2026-01-30 09:52:00', 256000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-030-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-031-1', m.`id`, '2026-01-31 14:30:00', 248000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-031-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-031-2', m.`id`, '2026-01-31 18:43:00', 299000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-031-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-031-3', m.`id`, '2026-01-31 08:56:00', 1047000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-031-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-031-4', m.`id`, '2026-01-31 12:09:00', 240000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-031-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-032-1', m.`id`, '2026-02-01 17:47:00', 122000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-032-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-032-2', m.`id`, '2026-02-01 21:00:00', 172000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-032-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-032-3', m.`id`, '2026-02-01 11:13:00', 222000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-032-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-032-4', m.`id`, '2026-02-01 15:26:00', 113000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-032-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-033-1', m.`id`, '2026-02-02 20:04:00', 265000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-033-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-033-2', m.`id`, '2026-02-02 10:17:00', 316000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-033-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-033-3', m.`id`, '2026-02-02 14:30:00', 206000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-033-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-033-4', m.`id`, '2026-02-02 18:43:00', 256000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-033-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-034-1', m.`id`, '2026-02-03 09:21:00', 138000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-034-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-034-2', m.`id`, '2026-02-03 13:34:00', 189000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-034-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-034-3', m.`id`, '2026-02-03 17:47:00', 349000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-034-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-034-4', m.`id`, '2026-02-03 21:00:00', 130000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-034-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-035-1', m.`id`, '2026-02-04 12:38:00', 282000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-035-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-035-2', m.`id`, '2026-02-04 16:51:00', 332000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-035-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-035-3', m.`id`, '2026-02-04 20:04:00', 223000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-035-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-035-4', m.`id`, '2026-02-04 10:17:00', 273000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-035-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-036-1', m.`id`, '2026-02-05 15:55:00', 223000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-036-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-036-2', m.`id`, '2026-02-05 19:08:00', 114000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-036-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-036-3', m.`id`, '2026-02-05 09:21:00', 164000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-036-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-036-4', m.`id`, '2026-02-05 13:34:00', 214000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-036-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-037-1', m.`id`, '2026-02-06 18:12:00', 207000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-037-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-037-2', m.`id`, '2026-02-06 08:25:00', 257000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-037-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-037-3', m.`id`, '2026-02-06 12:38:00', 307000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-037-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-037-4', m.`id`, '2026-02-06 16:51:00', 88000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-037-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-038-1', m.`id`, '2026-02-07 21:29:00', 350000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-038-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-038-2', m.`id`, '2026-02-07 11:42:00', 130000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-038-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-038-3', m.`id`, '2026-02-07 15:55:00', 181000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-038-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-038-4', m.`id`, '2026-02-07 19:08:00', 341000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-038-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-039-1', m.`id`, '2026-02-08 10:46:00', 223000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-039-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-039-2', m.`id`, '2026-02-08 14:59:00', 274000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-039-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-039-3', m.`id`, '2026-02-08 18:12:00', 324000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-039-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-039-4', m.`id`, '2026-02-08 08:25:00', 215000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-039-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-040-1', m.`id`, '2026-02-09 13:03:00', 97000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-040-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-040-2', m.`id`, '2026-02-09 17:16:00', 147000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-040-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-040-3', m.`id`, '2026-02-09 21:29:00', 308000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-040-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-040-4', m.`id`, '2026-02-09 11:42:00', 88000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-040-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-041-1', m.`id`, '2026-02-10 16:20:00', 240000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-041-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-041-2', m.`id`, '2026-02-10 20:33:00', 291000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-041-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-041-3', m.`id`, '2026-02-10 10:46:00', 543000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-041-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-041-4', m.`id`, '2026-02-10 14:59:00', 231000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-041-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-042-1', m.`id`, '2026-02-11 19:37:00', 114000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-042-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-042-2', m.`id`, '2026-02-11 09:50:00', 164000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-042-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-042-3', m.`id`, '2026-02-11 13:03:00', 324000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-042-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-042-4', m.`id`, '2026-02-11 17:16:00', 105000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-042-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-043-1', m.`id`, '2026-02-12 08:54:00', 325000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-043-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-043-2', m.`id`, '2026-02-12 12:07:00', 215000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-043-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-043-3', m.`id`, '2026-02-12 16:20:00', 266000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-043-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-043-4', m.`id`, '2026-02-12 20:33:00', 316000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-043-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-044-1', m.`id`, '2026-02-13 11:11:00', 308000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-044-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-044-2', m.`id`, '2026-02-13 15:24:00', 89000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-044-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-044-3', m.`id`, '2026-02-13 19:37:00', 139000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-044-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-044-4', m.`id`, '2026-02-13 09:50:00', 190000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-044-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-045-1', m.`id`, '2026-02-14 14:28:00', 182000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-045-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-045-2', m.`id`, '2026-02-14 18:41:00', 232000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-045-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-045-3', m.`id`, '2026-02-14 08:54:00', 282000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-045-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-045-4', m.`id`, '2026-02-14 12:07:00', 173000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-045-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-046-1', m.`id`, '2026-02-15 17:45:00', 325000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-046-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-046-2', m.`id`, '2026-02-15 21:58:00', 106000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-046-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-046-3', m.`id`, '2026-02-15 11:11:00', 156000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-046-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-046-4', m.`id`, '2026-02-15 15:24:00', 316000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-046-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-047-1', m.`id`, '2026-02-16 20:02:00', 198000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-047-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-047-2', m.`id`, '2026-02-16 10:15:00', 249000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-047-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-047-3', m.`id`, '2026-02-16 14:28:00', 299000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-047-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-047-4', m.`id`, '2026-02-16 18:41:00', 190000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-047-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-048-1', m.`id`, '2026-02-17 09:19:00', 342000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-048-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-048-2', m.`id`, '2026-02-17 13:32:00', 122000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-048-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-048-3', m.`id`, '2026-02-17 17:45:00', 283000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-048-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-048-4', m.`id`, '2026-02-17 21:58:00', 333000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-048-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-049-1', m.`id`, '2026-02-18 12:36:00', 215000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-049-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-049-2', m.`id`, '2026-02-18 16:49:00', 266000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-049-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-049-3', m.`id`, '2026-02-18 20:02:00', 156000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-049-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-049-4', m.`id`, '2026-02-18 10:15:00', 206000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-049-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-050-1', m.`id`, '2026-02-19 15:53:00', 157000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-050-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-050-2', m.`id`, '2026-02-19 19:06:00', 317000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-050-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-050-3', m.`id`, '2026-02-19 09:19:00', 97000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-050-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-050-4', m.`id`, '2026-02-19 13:32:00', 148000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-050-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-051-1', m.`id`, '2026-02-20 18:10:00', 300000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-051-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-051-2', m.`id`, '2026-02-20 08:23:00', 190000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-051-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-051-3', m.`id`, '2026-02-20 12:36:00', 723000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-051-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-051-4', m.`id`, '2026-02-20 16:49:00', 291000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-051-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-052-1', m.`id`, '2026-02-21 21:27:00', 283000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-052-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-052-2', m.`id`, '2026-02-21 11:40:00', 334000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-052-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-052-3', m.`id`, '2026-02-21 15:53:00', 114000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-052-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-052-4', m.`id`, '2026-02-21 19:06:00', 165000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-052-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-053-1', m.`id`, '2026-02-22 10:44:00', 157000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-053-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-053-2', m.`id`, '2026-02-22 14:57:00', 207000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-053-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-053-3', m.`id`, '2026-02-22 18:10:00', 258000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-053-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-053-4', m.`id`, '2026-02-22 08:23:00', 148000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-053-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-054-1', m.`id`, '2026-02-23 13:01:00', 300000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-054-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-054-2', m.`id`, '2026-02-23 17:14:00', 351000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-054-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-054-3', m.`id`, '2026-02-23 21:27:00', 131000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-054-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-054-4', m.`id`, '2026-02-23 11:40:00', 291000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-054-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-055-1', m.`id`, '2026-02-24 16:18:00', 174000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-055-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-055-2', m.`id`, '2026-02-24 20:31:00', 224000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-055-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-055-3', m.`id`, '2026-02-24 10:44:00', 114000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-055-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-055-4', m.`id`, '2026-02-24 14:57:00', 165000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-055-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-056-1', m.`id`, '2026-02-25 19:35:00', 317000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-056-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-056-2', m.`id`, '2026-02-25 09:48:00', 97000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-056-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-056-3', m.`id`, '2026-02-25 13:01:00', 258000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-056-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-056-4', m.`id`, '2026-02-25 17:14:00', 308000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-056-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-057-1', m.`id`, '2026-02-26 08:52:00', 258000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-057-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-057-2', m.`id`, '2026-02-26 12:05:00', 149000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-057-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-057-3', m.`id`, '2026-02-26 16:18:00', 199000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-057-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-057-4', m.`id`, '2026-02-26 20:31:00', 250000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-057-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-058-1', m.`id`, '2026-02-27 11:09:00', 132000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-058-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-058-2', m.`id`, '2026-02-27 15:22:00', 292000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-058-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-058-3', m.`id`, '2026-02-27 19:35:00', 342000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-058-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-058-4', m.`id`, '2026-02-27 09:48:00', 123000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-058-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-059-1', m.`id`, '2026-02-28 14:26:00', 115000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-059-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-059-2', m.`id`, '2026-02-28 18:39:00', 166000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-059-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-059-3', m.`id`, '2026-02-28 08:52:00', 216000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-059-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-059-4', m.`id`, '2026-02-28 12:05:00', 266000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-059-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-060-1', m.`id`, '2026-03-01 17:43:00', 258000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-060-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-060-2', m.`id`, '2026-03-01 21:56:00', 309000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-060-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-060-3', m.`id`, '2026-03-01 11:09:00', 89000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-060-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-060-4', m.`id`, '2026-03-01 15:22:00', 250000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-060-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-061-1', m.`id`, '2026-03-02 20:00:00', 132000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-061-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-061-2', m.`id`, '2026-03-02 10:13:00', 182000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-061-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-061-3', m.`id`, '2026-03-02 14:26:00', 699000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-061-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-061-4', m.`id`, '2026-03-02 18:39:00', 123000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-061-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-062-1', m.`id`, '2026-03-03 09:17:00', 275000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-062-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-062-2', m.`id`, '2026-03-03 13:30:00', 326000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-062-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-062-3', m.`id`, '2026-03-03 17:43:00', 216000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-062-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-062-4', m.`id`, '2026-03-03 21:56:00', 266000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-062-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-063-1', m.`id`, '2026-03-04 12:34:00', 149000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-063-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-063-2', m.`id`, '2026-03-04 16:47:00', 199000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-063-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-063-3', m.`id`, '2026-03-04 20:00:00', 90000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-063-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-063-4', m.`id`, '2026-03-04 10:13:00', 140000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-063-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-064-1', m.`id`, '2026-03-05 15:51:00', 90000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-064-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-064-2', m.`id`, '2026-03-05 19:04:00', 250000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-064-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-064-3', m.`id`, '2026-03-05 09:17:00', 301000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-064-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-064-4', m.`id`, '2026-03-05 13:30:00', 351000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-064-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-065-1', m.`id`, '2026-03-06 18:08:00', 233000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-065-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-065-2', m.`id`, '2026-03-06 08:21:00', 124000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-065-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-065-3', m.`id`, '2026-03-06 12:34:00', 174000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-065-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-065-4', m.`id`, '2026-03-06 16:47:00', 225000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-065-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-066-1', m.`id`, '2026-03-07 21:25:00', 217000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-066-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-066-2', m.`id`, '2026-03-07 11:38:00', 267000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-066-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-066-3', m.`id`, '2026-03-07 15:51:00', 318000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-066-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-066-4', m.`id`, '2026-03-07 19:04:00', 98000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-066-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-067-1', m.`id`, '2026-03-08 10:42:00', 90000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-067-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-067-2', m.`id`, '2026-03-08 14:55:00', 141000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-067-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-067-3', m.`id`, '2026-03-08 18:08:00', 191000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-067-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-067-4', m.`id`, '2026-03-08 08:21:00', 351000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-067-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-068-1', m.`id`, '2026-03-09 13:59:00', 234000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-068-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-068-2', m.`id`, '2026-03-09 17:12:00', 284000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-068-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-068-3', m.`id`, '2026-03-09 21:25:00', 334000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-068-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-068-4', m.`id`, '2026-03-09 11:38:00', 225000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-068-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-069-1', m.`id`, '2026-03-10 16:16:00', 107000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-069-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-069-2', m.`id`, '2026-03-10 20:29:00', 157000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-069-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-069-3', m.`id`, '2026-03-10 10:42:00', 318000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-069-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-069-4', m.`id`, '2026-03-10 14:55:00', 98000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-069-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-070-1', m.`id`, '2026-03-11 19:33:00', 250000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-070-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-070-2', m.`id`, '2026-03-11 09:46:00', 301000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-070-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-070-3', m.`id`, '2026-03-11 13:59:00', 191000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-070-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-070-4', m.`id`, '2026-03-11 17:12:00', 242000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-070-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-071-1', m.`id`, '2026-03-12 08:50:00', 192000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-071-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-071-2', m.`id`, '2026-03-12 12:03:00', 352000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-071-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-071-3', m.`id`, '2026-03-12 16:16:00', 396000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-071-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-071-4', m.`id`, '2026-03-12 20:29:00', 183000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-071-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-072-1', m.`id`, '2026-03-13 11:07:00', 335000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-072-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-072-2', m.`id`, '2026-03-13 15:20:00', 226000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-072-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-072-3', m.`id`, '2026-03-13 19:33:00', 276000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-072-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-072-4', m.`id`, '2026-03-13 09:46:00', 326000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-072-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-073-1', m.`id`, '2026-03-14 14:24:00', 318000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-073-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-073-2', m.`id`, '2026-03-14 18:37:00', 99000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-073-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-073-3', m.`id`, '2026-03-14 08:50:00', 149000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-073-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-073-4', m.`id`, '2026-03-14 12:03:00', 200000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-073-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-074-1', m.`id`, '2026-03-15 17:41:00', 192000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-074-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-074-2', m.`id`, '2026-03-15 21:54:00', 242000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-074-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-074-3', m.`id`, '2026-03-15 11:07:00', 293000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-074-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-074-4', m.`id`, '2026-03-15 15:20:00', 183000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-074-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-075-1', m.`id`, '2026-03-16 20:58:00', 335000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-075-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-075-2', m.`id`, '2026-03-16 10:11:00', 116000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-075-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-075-3', m.`id`, '2026-03-16 14:24:00', 166000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-075-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-075-4', m.`id`, '2026-03-16 18:37:00', 326000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-075-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-076-1', m.`id`, '2026-03-17 09:15:00', 209000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-076-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-076-2', m.`id`, '2026-03-17 13:28:00', 259000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-076-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-076-3', m.`id`, '2026-03-17 17:41:00', 150000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-076-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-076-4', m.`id`, '2026-03-17 21:54:00', 200000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-076-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-077-1', m.`id`, '2026-03-18 12:32:00', 352000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-077-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-077-2', m.`id`, '2026-03-18 16:45:00', 132000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-077-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-077-3', m.`id`, '2026-03-18 20:58:00', 293000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-077-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-077-4', m.`id`, '2026-03-18 10:11:00', 343000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-077-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-078-1', m.`id`, '2026-03-19 15:49:00', 293000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-078-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-078-2', m.`id`, '2026-03-19 19:02:00', 184000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-078-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-078-3', m.`id`, '2026-03-19 09:15:00', 234000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-078-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-078-4', m.`id`, '2026-03-19 13:28:00', 285000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-078-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-079-1', m.`id`, '2026-03-20 18:06:00', 167000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-079-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-079-2', m.`id`, '2026-03-20 08:19:00', 327000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-079-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-079-3', m.`id`, '2026-03-20 12:32:00', 108000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-079-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-079-4', m.`id`, '2026-03-20 16:45:00', 158000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-079-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-080-1', m.`id`, '2026-03-21 21:23:00', 150000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-080-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-080-2', m.`id`, '2026-03-21 11:36:00', 201000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-080-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-080-3', m.`id`, '2026-03-21 15:49:00', 251000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-080-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-080-4', m.`id`, '2026-03-21 19:02:00', 301000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-080-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-081-1', m.`id`, '2026-03-22 10:40:00', 294000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-081-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-081-2', m.`id`, '2026-03-22 14:53:00', 344000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-081-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-081-3', m.`id`, '2026-03-22 18:06:00', 372000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-081-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-081-4', m.`id`, '2026-03-22 08:19:00', 285000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-081-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-082-1', m.`id`, '2026-03-23 13:57:00', 167000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-082-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-082-2', m.`id`, '2026-03-23 17:10:00', 217000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-082-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-082-3', m.`id`, '2026-03-23 21:23:00', 268000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-082-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-082-4', m.`id`, '2026-03-23 11:36:00', 158000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-082-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-083-1', m.`id`, '2026-03-24 16:14:00', 310000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-083-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-083-2', m.`id`, '2026-03-24 20:27:00', 91000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-083-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-083-3', m.`id`, '2026-03-24 10:40:00', 251000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-083-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-083-4', m.`id`, '2026-03-24 14:53:00', 302000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-083-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-084-1', m.`id`, '2026-03-25 19:31:00', 184000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-084-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-084-2', m.`id`, '2026-03-25 09:44:00', 234000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-084-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-084-3', m.`id`, '2026-03-25 13:57:00', 125000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-084-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-084-4', m.`id`, '2026-03-25 17:10:00', 175000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-084-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-085-1', m.`id`, '2026-03-26 08:48:00', 125000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-085-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-085-2', m.`id`, '2026-03-26 12:01:00', 286000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-085-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-085-3', m.`id`, '2026-03-26 16:14:00', 336000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-085-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-085-4', m.`id`, '2026-03-26 20:27:00', 116000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-085-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-086-1', m.`id`, '2026-03-27 11:05:00', 268000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-086-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-086-2', m.`id`, '2026-03-27 15:18:00', 159000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-086-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-086-3', m.`id`, '2026-03-27 19:31:00', 209000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-086-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-086-4', m.`id`, '2026-03-27 09:44:00', 260000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-086-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-087-1', m.`id`, '2026-03-28 14:22:00', 252000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-087-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-087-2', m.`id`, '2026-03-28 18:35:00', 302000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-087-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-087-3', m.`id`, '2026-03-28 08:48:00', 353000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-087-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-087-4', m.`id`, '2026-03-28 12:01:00', 133000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-087-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-088-1', m.`id`, '2026-03-29 17:39:00', 125000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-088-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-088-2', m.`id`, '2026-03-29 21:52:00', 176000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-088-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-088-3', m.`id`, '2026-03-29 11:05:00', 226000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-088-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-088-4', m.`id`, '2026-03-29 15:18:00', 116000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-088-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-089-1', m.`id`, '2026-03-30 20:56:00', 269000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-089-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-089-2', m.`id`, '2026-03-30 10:09:00', 319000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-089-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-089-3', m.`id`, '2026-03-30 14:22:00', 100000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-089-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-089-4', m.`id`, '2026-03-30 18:35:00', 260000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-089-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-090-1', m.`id`, '2026-03-31 09:13:00', 142000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-090-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-090-2', m.`id`, '2026-03-31 13:26:00', 192000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-090-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-090-3', m.`id`, '2026-03-31 17:39:00', 243000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-090-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-090-4', m.`id`, '2026-03-31 21:52:00', 133000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-090-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-091-1', m.`id`, '2026-04-01 12:30:00', 286000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-091-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-091-2', m.`id`, '2026-04-01 16:43:00', 336000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-091-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-091-3', m.`id`, '2026-04-01 20:56:00', 678000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-091-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-091-4', m.`id`, '2026-04-01 10:09:00', 277000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-091-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-092-1', m.`id`, '2026-04-02 15:47:00', 227000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-092-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-092-2', m.`id`, '2026-04-02 19:00:00', 117000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-092-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-092-3', m.`id`, '2026-04-02 09:13:00', 168000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-092-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-092-4', m.`id`, '2026-04-02 13:26:00', 218000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-092-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-093-1', m.`id`, '2026-04-03 18:04:00', 100000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-093-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-093-2', m.`id`, '2026-04-03 08:17:00', 261000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-093-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-093-3', m.`id`, '2026-04-03 12:30:00', 311000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-093-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-093-4', m.`id`, '2026-04-03 16:43:00', 91000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-093-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-094-1', m.`id`, '2026-04-04 21:21:00', 354000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-094-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-094-2', m.`id`, '2026-04-04 11:34:00', 134000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-094-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-094-3', m.`id`, '2026-04-04 15:47:00', 184000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-094-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-094-4', m.`id`, '2026-04-04 19:00:00', 235000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-094-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-095-1', m.`id`, '2026-04-05 10:38:00', 227000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-095-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-095-2', m.`id`, '2026-04-05 14:51:00', 277000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-095-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-095-3', m.`id`, '2026-04-05 18:04:00', 328000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-095-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-095-4', m.`id`, '2026-04-05 08:17:00', 218000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-095-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-096-1', m.`id`, '2026-04-06 13:55:00', 100000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-096-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-096-2', m.`id`, '2026-04-06 17:08:00', 151000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-096-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-096-3', m.`id`, '2026-04-06 21:21:00', 201000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-096-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-096-4', m.`id`, '2026-04-06 11:34:00', 92000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-096-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-097-1', m.`id`, '2026-04-07 16:12:00', 244000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-097-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-097-2', m.`id`, '2026-04-07 20:25:00', 294000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-097-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-097-3', m.`id`, '2026-04-07 10:38:00', 345000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-097-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-097-4', m.`id`, '2026-04-07 14:51:00', 235000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-097-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-098-1', m.`id`, '2026-04-08 19:29:00', 117000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-098-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-098-2', m.`id`, '2026-04-08 09:42:00', 168000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-098-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-098-3', m.`id`, '2026-04-08 13:55:00', 328000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-098-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-098-4', m.`id`, '2026-04-08 17:08:00', 108000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-098-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-099-1', m.`id`, '2026-04-09 08:46:00', 328000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-099-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-099-2', m.`id`, '2026-04-09 12:59:00', 219000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-099-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-099-3', m.`id`, '2026-04-09 16:12:00', 269000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-099-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-099-4', m.`id`, '2026-04-09 20:25:00', 320000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-099-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-100-1', m.`id`, '2026-04-10 11:03:00', 202000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-100-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-100-2', m.`id`, '2026-04-10 15:16:00', 92000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-100-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-100-3', m.`id`, '2026-04-10 19:29:00', 143000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-100-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-100-4', m.`id`, '2026-04-10 09:42:00', 193000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-100-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-101-1', m.`id`, '2026-04-11 14:20:00', 345000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-101-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-101-2', m.`id`, '2026-04-11 18:33:00', 236000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-101-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-101-3', m.`id`, '2026-04-11 08:46:00', 858000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-101-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-101-4', m.`id`, '2026-04-11 12:59:00', 336000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-101-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-102-1', m.`id`, '2026-04-12 17:37:00', 329000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-102-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-102-2', m.`id`, '2026-04-12 21:50:00', 109000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-102-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-102-3', m.`id`, '2026-04-12 11:03:00', 160000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-102-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-102-4', m.`id`, '2026-04-12 15:16:00', 210000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-102-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-103-1', m.`id`, '2026-04-13 20:54:00', 202000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-103-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-103-2', m.`id`, '2026-04-13 10:07:00', 252000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-103-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-103-3', m.`id`, '2026-04-13 14:20:00', 303000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-103-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-103-4', m.`id`, '2026-04-13 18:33:00', 193000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-103-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-104-1', m.`id`, '2026-04-14 09:11:00', 346000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-104-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-104-2', m.`id`, '2026-04-14 13:24:00', 126000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-104-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-104-3', m.`id`, '2026-04-14 17:37:00', 176000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-104-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-104-4', m.`id`, '2026-04-14 21:50:00', 337000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-104-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-105-1', m.`id`, '2026-04-15 12:28:00', 219000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-105-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-105-2', m.`id`, '2026-04-15 16:41:00', 269000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-105-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-105-3', m.`id`, '2026-04-15 20:54:00', 160000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-105-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-105-4', m.`id`, '2026-04-15 10:07:00', 210000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-105-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-106-1', m.`id`, '2026-04-16 15:45:00', 160000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-106-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-106-2', m.`id`, '2026-04-16 19:58:00', 211000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-106-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-106-3', m.`id`, '2026-04-16 09:11:00', 101000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-106-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-106-4', m.`id`, '2026-04-16 13:24:00', 151000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-106-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-107-1', m.`id`, '2026-04-17 18:02:00', 304000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-107-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-107-2', m.`id`, '2026-04-17 08:15:00', 194000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-107-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-107-3', m.`id`, '2026-04-17 12:28:00', 244000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-107-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-107-4', m.`id`, '2026-04-17 16:41:00', 295000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-107-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-108-1', m.`id`, '2026-04-18 21:19:00', 177000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-108-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-108-2', m.`id`, '2026-04-18 11:32:00', 337000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-108-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-108-3', m.`id`, '2026-04-18 15:45:00', 118000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-108-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-108-4', m.`id`, '2026-04-18 19:58:00', 168000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-108-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-109-1', m.`id`, '2026-04-19 10:36:00', 160000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-109-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-109-2', m.`id`, '2026-04-19 14:49:00', 211000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-109-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-109-3', m.`id`, '2026-04-19 18:02:00', 261000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-109-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-109-4', m.`id`, '2026-04-19 08:15:00', 312000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-109-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-110-1', m.`id`, '2026-04-20 13:53:00', 304000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-110-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-110-2', m.`id`, '2026-04-20 17:06:00', 354000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-110-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-110-3', m.`id`, '2026-04-20 21:19:00', 135000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-110-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-110-4', m.`id`, '2026-04-20 11:32:00', 295000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-110-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-111-1', m.`id`, '2026-04-21 16:10:00', 177000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-111-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-111-2', m.`id`, '2026-04-21 20:23:00', 228000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-111-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-111-3', m.`id`, '2026-04-21 10:36:00', 834000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-111-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-111-4', m.`id`, '2026-04-21 14:49:00', 168000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-111-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-112-1', m.`id`, '2026-04-22 19:27:00', 321000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-112-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-112-2', m.`id`, '2026-04-22 09:40:00', 101000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-112-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-112-3', m.`id`, '2026-04-22 13:53:00', 261000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-112-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-112-4', m.`id`, '2026-04-22 17:06:00', 312000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-112-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-113-1', m.`id`, '2026-04-23 08:44:00', 262000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-113-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-113-2', m.`id`, '2026-04-23 12:57:00', 312000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-113-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-113-3', m.`id`, '2026-04-23 16:10:00', 203000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-113-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-113-4', m.`id`, '2026-04-23 20:23:00', 253000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-113-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-114-1', m.`id`, '2026-04-24 11:01:00', 135000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-114-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-114-2', m.`id`, '2026-04-24 15:14:00', 296000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-114-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-114-3', m.`id`, '2026-04-24 19:27:00', 346000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-114-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-114-4', m.`id`, '2026-04-24 09:40:00', 126000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-114-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-115-1', m.`id`, '2026-04-25 14:18:00', 279000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-115-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-115-2', m.`id`, '2026-04-25 18:31:00', 169000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-115-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-115-3', m.`id`, '2026-04-25 08:44:00', 220000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-115-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-115-4', m.`id`, '2026-04-25 12:57:00', 270000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-115-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-116-1', m.`id`, '2026-04-26 17:35:00', 262000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-116-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-116-2', m.`id`, '2026-04-26 21:48:00', 312000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-116-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-116-3', m.`id`, '2026-04-26 11:01:00', 93000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-116-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-116-4', m.`id`, '2026-04-26 15:14:00', 143000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-116-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-117-1', m.`id`, '2026-04-27 20:52:00', 136000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-117-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-117-2', m.`id`, '2026-04-27 10:05:00', 186000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-117-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-117-3', m.`id`, '2026-04-27 14:18:00', 236000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-117-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-117-4', m.`id`, '2026-04-27 18:31:00', 127000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-117-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-118-1', m.`id`, '2026-04-28 09:09:00', 279000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-118-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-118-2', m.`id`, '2026-04-28 13:22:00', 329000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-118-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-118-3', m.`id`, '2026-04-28 17:35:00', 110000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-118-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-118-4', m.`id`, '2026-04-28 21:48:00', 270000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-118-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-119-1', m.`id`, '2026-04-29 12:26:00', 152000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-119-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-119-2', m.`id`, '2026-04-29 16:39:00', 203000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-119-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-119-3', m.`id`, '2026-04-29 20:52:00', 93000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-119-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-119-4', m.`id`, '2026-04-29 10:05:00', 144000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-119-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-120-1', m.`id`, '2026-04-30 15:43:00', 94000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-120-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-120-2', m.`id`, '2026-04-30 19:56:00', 144000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-120-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-120-3', m.`id`, '2026-04-30 09:09:00', 304000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-120-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-120-4', m.`id`, '2026-04-30 13:22:00', 355000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-120-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-121-1', m.`id`, '2026-05-01 18:00:00', 237000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-121-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-121-2', m.`id`, '2026-05-01 08:13:00', 127000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-121-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-121-3', m.`id`, '2026-05-01 12:26:00', 534000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-121-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-121-4', m.`id`, '2026-05-01 16:39:00', 228000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-121-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-122-1', m.`id`, '2026-05-02 21:17:00', 110000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-122-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-122-2', m.`id`, '2026-05-02 11:30:00', 271000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-122-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-122-3', m.`id`, '2026-05-02 15:43:00', 321000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-122-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-122-4', m.`id`, '2026-05-02 19:56:00', 102000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-122-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-123-1', m.`id`, '2026-05-03 10:34:00', 94000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-123-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-123-2', m.`id`, '2026-05-03 14:47:00', 144000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-123-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-123-3', m.`id`, '2026-05-03 18:00:00', 195000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-123-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-123-4', m.`id`, '2026-05-03 08:13:00', 245000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-123-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-124-1', m.`id`, '2026-05-04 13:51:00', 237000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-124-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-124-2', m.`id`, '2026-05-04 17:04:00', 288000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-124-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-124-3', m.`id`, '2026-05-04 21:17:00', 338000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-124-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-124-4', m.`id`, '2026-05-04 11:30:00', 228000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-124-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-125-1', m.`id`, '2026-05-05 16:08:00', 111000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-125-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-125-2', m.`id`, '2026-05-05 20:21:00', 161000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-125-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-125-3', m.`id`, '2026-05-05 10:34:00', 211000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-125-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-125-4', m.`id`, '2026-05-05 14:47:00', 102000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-125-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-126-1', m.`id`, '2026-05-06 19:25:00', 254000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-126-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-126-2', m.`id`, '2026-05-06 09:38:00', 304000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-126-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-126-3', m.`id`, '2026-05-06 13:51:00', 195000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-126-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-126-4', m.`id`, '2026-05-06 17:04:00', 245000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-126-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-127-1', m.`id`, '2026-05-07 08:42:00', 195000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-127-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-127-2', m.`id`, '2026-05-07 12:55:00', 246000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-127-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-127-3', m.`id`, '2026-05-07 16:08:00', 136000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-127-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-127-4', m.`id`, '2026-05-07 20:21:00', 186000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-127-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-128-1', m.`id`, '2026-05-08 11:59:00', 339000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-128-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-128-2', m.`id`, '2026-05-08 15:12:00', 229000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-128-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-128-3', m.`id`, '2026-05-08 19:25:00', 280000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-128-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-128-4', m.`id`, '2026-05-08 09:38:00', 330000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-128-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-129-1', m.`id`, '2026-05-09 14:16:00', 212000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-129-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-129-2', m.`id`, '2026-05-09 18:29:00', 102000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-129-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-129-3', m.`id`, '2026-05-09 08:42:00', 153000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-129-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-129-4', m.`id`, '2026-05-09 12:55:00', 203000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-129-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-130-1', m.`id`, '2026-05-10 17:33:00', 196000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-130-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-130-2', m.`id`, '2026-05-10 21:46:00', 246000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-130-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-130-3', m.`id`, '2026-05-10 11:59:00', 296000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-130-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-130-4', m.`id`, '2026-05-10 15:12:00', 347000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-130-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-131-1', m.`id`, '2026-05-11 20:50:00', 339000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-131-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-131-2', m.`id`, '2026-05-11 10:03:00', 119000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-131-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-131-3', m.`id`, '2026-05-11 14:16:00', 510000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-131-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-131-4', m.`id`, '2026-05-11 18:29:00', 330000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-131-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-132-1', m.`id`, '2026-05-12 09:07:00', 212000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-132-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-132-2', m.`id`, '2026-05-12 13:20:00', 263000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-132-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-132-3', m.`id`, '2026-05-12 17:33:00', 313000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-132-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-132-4', m.`id`, '2026-05-12 21:46:00', 204000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-132-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-133-1', m.`id`, '2026-05-13 12:24:00', 86000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-133-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-133-2', m.`id`, '2026-05-13 16:37:00', 136000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-133-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-133-3', m.`id`, '2026-05-13 20:50:00', 296000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-133-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-133-4', m.`id`, '2026-05-13 10:03:00', 347000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-133-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-134-1', m.`id`, '2026-05-14 15:41:00', 297000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-134-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-134-2', m.`id`, '2026-05-14 19:54:00', 347000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-134-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-134-3', m.`id`, '2026-05-14 09:07:00', 238000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-134-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-134-4', m.`id`, '2026-05-14 13:20:00', 288000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-134-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-135-1', m.`id`, '2026-05-15 18:58:00', 170000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-135-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-135-2', m.`id`, '2026-05-15 08:11:00', 331000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-135-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-135-3', m.`id`, '2026-05-15 12:24:00', 111000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-135-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-135-4', m.`id`, '2026-05-15 16:37:00', 162000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-135-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-136-1', m.`id`, '2026-05-16 21:15:00', 314000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-136-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-136-2', m.`id`, '2026-05-16 11:28:00', 204000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-136-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-136-3', m.`id`, '2026-05-16 15:41:00', 255000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-136-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-136-4', m.`id`, '2026-05-16 19:54:00', 305000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-136-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-137-1', m.`id`, '2026-05-17 10:32:00', 297000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-137-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-137-2', m.`id`, '2026-05-17 14:45:00', 348000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-137-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-137-3', m.`id`, '2026-05-17 18:58:00', 128000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-137-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-137-4', m.`id`, '2026-05-17 08:11:00', 178000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-137-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-138-1', m.`id`, '2026-05-18 13:49:00', 171000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-138-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-138-2', m.`id`, '2026-05-18 17:02:00', 221000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-138-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-138-3', m.`id`, '2026-05-18 21:15:00', 271000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-138-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-138-4', m.`id`, '2026-05-18 11:28:00', 162000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-138-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-139-1', m.`id`, '2026-05-19 16:06:00', 314000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-139-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-139-2', m.`id`, '2026-05-19 20:19:00', 94000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-139-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-139-3', m.`id`, '2026-05-19 10:32:00', 145000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-139-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-139-4', m.`id`, '2026-05-19 14:45:00', 305000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-139-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-140-1', m.`id`, '2026-05-20 19:23:00', 187000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-140-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-140-2', m.`id`, '2026-05-20 09:36:00', 238000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-140-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-140-3', m.`id`, '2026-05-20 13:49:00', 288000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-140-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-140-4', m.`id`, '2026-05-20 17:02:00', 179000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-140-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-141-1', m.`id`, '2026-05-21 08:40:00', 129000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-141-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-141-2', m.`id`, '2026-05-21 12:53:00', 179000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-141-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-141-3', m.`id`, '2026-05-21 16:06:00', 1020000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-141-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-141-4', m.`id`, '2026-05-21 20:19:00', 120000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-141-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-142-1', m.`id`, '2026-05-22 11:57:00', 272000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-142-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-142-2', m.`id`, '2026-05-22 15:10:00', 162000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-142-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-142-3', m.`id`, '2026-05-22 19:23:00', 213000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-142-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-142-4', m.`id`, '2026-05-22 09:36:00', 263000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-142-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-143-1', m.`id`, '2026-05-23 14:14:00', 146000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-143-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-143-2', m.`id`, '2026-05-23 18:27:00', 306000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-143-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-143-3', m.`id`, '2026-05-23 08:40:00', 86000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-143-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-143-4', m.`id`, '2026-05-23 12:53:00', 137000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-143-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-144-1', m.`id`, '2026-05-24 17:31:00', 289000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-144-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-144-2', m.`id`, '2026-05-24 21:44:00', 179000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-144-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-144-3', m.`id`, '2026-05-24 11:57:00', 230000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-144-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-144-4', m.`id`, '2026-05-24 15:10:00', 280000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-144-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-145-1', m.`id`, '2026-05-25 20:48:00', 272000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-145-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-145-2', m.`id`, '2026-05-25 10:01:00', 323000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-145-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-145-3', m.`id`, '2026-05-25 14:14:00', 103000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-145-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-145-4', m.`id`, '2026-05-25 18:27:00', 154000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-145-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-146-1', m.`id`, '2026-05-26 09:05:00', 146000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-146-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-146-2', m.`id`, '2026-05-26 13:18:00', 196000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-146-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-146-3', m.`id`, '2026-05-26 17:31:00', 246000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-146-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-146-4', m.`id`, '2026-05-26 21:44:00', 137000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-146-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-147-1', m.`id`, '2026-05-27 12:22:00', 289000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-147-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-147-2', m.`id`, '2026-05-27 16:35:00', 340000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-147-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-147-3', m.`id`, '2026-05-27 20:48:00', 120000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-147-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-147-4', m.`id`, '2026-05-27 10:01:00', 280000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-147-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-148-1', m.`id`, '2026-05-28 15:39:00', 230000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-148-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-148-2', m.`id`, '2026-05-28 19:52:00', 281000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-148-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-148-3', m.`id`, '2026-05-28 09:05:00', 171000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-148-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-148-4', m.`id`, '2026-05-28 13:18:00', 222000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-148-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-149-1', m.`id`, '2026-05-29 18:56:00', 104000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-149-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-149-2', m.`id`, '2026-05-29 08:09:00', 264000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-149-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-149-3', m.`id`, '2026-05-29 12:22:00', 315000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-149-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-149-4', m.`id`, '2026-05-29 16:35:00', 95000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-149-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-150-1', m.`id`, '2026-05-30 21:13:00', 247000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-150-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-150-2', m.`id`, '2026-05-30 11:26:00', 138000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-150-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-150-3', m.`id`, '2026-05-30 15:39:00', 188000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-150-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-150-4', m.`id`, '2026-05-30 19:52:00', 238000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-150-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-151-1', m.`id`, '2026-05-31 10:30:00', 121000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-151-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-151-2', m.`id`, '2026-05-31 14:43:00', 281000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-151-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-151-3', m.`id`, '2026-05-31 18:56:00', 993000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-151-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-151-4', m.`id`, '2026-05-31 08:09:00', 112000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-151-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-152-1', m.`id`, '2026-06-01 13:47:00', 104000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-152-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-152-2', m.`id`, '2026-06-01 17:00:00', 154000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-152-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-152-3', m.`id`, '2026-06-01 21:13:00', 205000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-152-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-152-4', m.`id`, '2026-06-01 11:26:00', 255000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-152-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-153-1', m.`id`, '2026-06-02 16:04:00', 247000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-153-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-153-2', m.`id`, '2026-06-02 20:17:00', 298000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-153-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-153-3', m.`id`, '2026-06-02 10:30:00', 348000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-153-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-153-4', m.`id`, '2026-06-02 14:43:00', 239000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-153-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-154-1', m.`id`, '2026-06-03 19:21:00', 121000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-154-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-154-2', m.`id`, '2026-06-03 09:34:00', 171000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-154-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-154-3', m.`id`, '2026-06-03 13:47:00', 222000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-154-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-154-4', m.`id`, '2026-06-03 17:00:00', 112000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-154-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-155-1', m.`id`, '2026-06-04 08:38:00', 332000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-155-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-155-2', m.`id`, '2026-06-04 12:51:00', 112000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-155-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-155-3', m.`id`, '2026-06-04 16:04:00', 273000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-155-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-155-4', m.`id`, '2026-06-04 20:17:00', 323000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-155-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-156-1', m.`id`, '2026-06-05 11:55:00', 206000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-156-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-156-2', m.`id`, '2026-06-05 15:08:00', 256000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-156-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-156-3', m.`id`, '2026-06-05 19:21:00', 146000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-156-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-156-4', m.`id`, '2026-06-05 09:34:00', 197000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-156-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-157-1', m.`id`, '2026-06-06 14:12:00', 349000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-157-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-157-2', m.`id`, '2026-06-06 18:25:00', 239000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-157-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-157-3', m.`id`, '2026-06-06 08:38:00', 290000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-157-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-157-4', m.`id`, '2026-06-06 12:51:00', 340000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-157-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-158-1', m.`id`, '2026-06-07 17:29:00', 222000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-158-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-158-2', m.`id`, '2026-06-07 21:42:00', 113000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-158-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-158-3', m.`id`, '2026-06-07 11:55:00', 163000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-158-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-158-4', m.`id`, '2026-06-07 15:08:00', 214000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-158-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-159-1', m.`id`, '2026-06-08 20:46:00', 206000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-159-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-159-2', m.`id`, '2026-06-08 10:59:00', 256000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-159-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-159-3', m.`id`, '2026-06-08 14:12:00', 306000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-159-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-159-4', m.`id`, '2026-06-08 18:25:00', 87000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-159-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-160-1', m.`id`, '2026-06-09 09:03:00', 349000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-160-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-160-2', m.`id`, '2026-06-09 13:16:00', 130000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-160-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-160-3', m.`id`, '2026-06-09 17:29:00', 180000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-160-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-160-4', m.`id`, '2026-06-09 21:42:00', 340000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-160-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-161-1', m.`id`, '2026-06-10 12:20:00', 222000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-161-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-161-2', m.`id`, '2026-06-10 16:33:00', 273000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-161-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-161-3', m.`id`, '2026-06-10 20:46:00', 969000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-161-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-161-4', m.`id`, '2026-06-10 10:59:00', 214000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-161-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-162-1', m.`id`, '2026-06-11 15:37:00', 164000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-162-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-162-2', m.`id`, '2026-06-11 19:50:00', 214000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-162-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-162-3', m.`id`, '2026-06-11 09:03:00', 105000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-162-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-162-4', m.`id`, '2026-06-11 13:16:00', 155000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-162-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-163-1', m.`id`, '2026-06-12 18:54:00', 307000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-163-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-163-2', m.`id`, '2026-06-12 08:07:00', 88000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-163-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-163-3', m.`id`, '2026-06-12 12:20:00', 248000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-163-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-163-4', m.`id`, '2026-06-12 16:33:00', 298000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-163-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-164-1', m.`id`, '2026-06-13 21:11:00', 181000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-164-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-164-2', m.`id`, '2026-06-13 11:24:00', 341000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-164-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-164-3', m.`id`, '2026-06-13 15:37:00', 121000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-164-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-164-4', m.`id`, '2026-06-13 19:50:00', 172000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-164-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-165-1', m.`id`, '2026-06-14 10:28:00', 324000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-165-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-165-2', m.`id`, '2026-06-14 14:41:00', 214000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-165-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-165-3', m.`id`, '2026-06-14 18:54:00', 265000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-165-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-165-4', m.`id`, '2026-06-14 08:07:00', 315000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-165-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-166-1', m.`id`, '2026-06-15 13:45:00', 307000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-166-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-166-2', m.`id`, '2026-06-15 17:58:00', 88000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-166-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-166-3', m.`id`, '2026-06-15 21:11:00', 138000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-166-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-166-4', m.`id`, '2026-06-15 11:24:00', 189000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-166-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-167-1', m.`id`, '2026-06-16 16:02:00', 181000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-167-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-167-2', m.`id`, '2026-06-16 20:15:00', 231000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-167-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-167-3', m.`id`, '2026-06-16 10:28:00', 282000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-167-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-167-4', m.`id`, '2026-06-16 14:41:00', 172000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-167-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-168-1', m.`id`, '2026-06-17 19:19:00', 324000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-168-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-168-2', m.`id`, '2026-06-17 09:32:00', 105000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-168-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-168-3', m.`id`, '2026-06-17 13:45:00', 155000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-168-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-168-4', m.`id`, '2026-06-17 17:58:00', 315000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-168-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-169-1', m.`id`, '2026-06-18 08:36:00', 266000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-169-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-169-2', m.`id`, '2026-06-18 12:49:00', 316000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-169-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-169-3', m.`id`, '2026-06-18 16:02:00', 206000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-169-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-169-4', m.`id`, '2026-06-18 20:15:00', 257000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-169-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-170-1', m.`id`, '2026-06-19 11:53:00', 139000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-170-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-170-2', m.`id`, '2026-06-19 15:06:00', 189000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-170-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-170-3', m.`id`, '2026-06-19 19:19:00', 350000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-170-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-170-4', m.`id`, '2026-06-19 09:32:00', 130000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-170-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-171-1', m.`id`, '2026-06-20 14:10:00', 282000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-171-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-171-2', m.`id`, '2026-06-20 18:23:00', 173000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-171-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-171-3', m.`id`, '2026-06-20 08:36:00', 669000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-171-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-171-4', m.`id`, '2026-06-20 12:49:00', 274000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-171-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-172-1', m.`id`, '2026-06-21 17:27:00', 156000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-172-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-172-2', m.`id`, '2026-06-21 21:40:00', 316000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-172-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-172-3', m.`id`, '2026-06-21 11:53:00', 96000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-172-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-172-4', m.`id`, '2026-06-21 15:06:00', 147000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-172-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-173-1', m.`id`, '2026-06-22 20:44:00', 139000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-173-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-173-2', m.`id`, '2026-06-22 10:57:00', 190000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-173-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-173-3', m.`id`, '2026-06-22 14:10:00', 240000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-173-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-173-4', m.`id`, '2026-06-22 18:23:00', 290000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-173-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-174-1', m.`id`, '2026-06-23 09:01:00', 282000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-174-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-174-2', m.`id`, '2026-06-23 13:14:00', 333000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-174-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-174-3', m.`id`, '2026-06-23 17:27:00', 113000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-174-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-174-4', m.`id`, '2026-06-23 21:40:00', 274000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-174-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-175-1', m.`id`, '2026-06-24 12:18:00', 156000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-175-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-175-2', m.`id`, '2026-06-24 16:31:00', 206000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-175-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-175-3', m.`id`, '2026-06-24 20:44:00', 257000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-175-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-175-4', m.`id`, '2026-06-24 10:57:00', 147000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-175-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-176-1', m.`id`, '2026-06-25 15:35:00', 97000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-176-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-176-2', m.`id`, '2026-06-25 19:48:00', 148000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-176-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-176-3', m.`id`, '2026-06-25 09:01:00', 308000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-176-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-176-4', m.`id`, '2026-06-25 13:14:00', 88000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-176-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-177-1', m.`id`, '2026-06-26 18:52:00', 241000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-177-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-177-2', m.`id`, '2026-06-26 08:05:00', 291000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-177-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-177-3', m.`id`, '2026-06-26 12:18:00', 181000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-177-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-177-4', m.`id`, '2026-06-26 16:31:00', 232000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-177-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-178-1', m.`id`, '2026-06-27 21:09:00', 114000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-178-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-178-2', m.`id`, '2026-06-27 11:22:00', 274000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-178-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-178-3', m.`id`, '2026-06-27 15:35:00', 325000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-178-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-178-4', m.`id`, '2026-06-27 19:48:00', 105000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-178-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-179-1', m.`id`, '2026-06-28 10:26:00', 257000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-179-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-179-2', m.`id`, '2026-06-28 14:39:00', 148000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-179-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-179-3', m.`id`, '2026-06-28 18:52:00', 198000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-179-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-179-4', m.`id`, '2026-06-28 08:05:00', 249000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-179-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-180-1', m.`id`, '2026-06-29 13:43:00', 241000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-180-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-180-2', m.`id`, '2026-06-29 17:56:00', 291000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-180-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-180-3', m.`id`, '2026-06-29 21:09:00', 342000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-180-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-180-4', m.`id`, '2026-06-29 11:22:00', 122000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-180-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-181-1', m.`id`, '2026-06-30 16:00:00', 114000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-181-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-181-2', m.`id`, '2026-06-30 20:13:00', 165000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-181-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-181-3', m.`id`, '2026-06-30 10:26:00', 645000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-181-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-181-4', m.`id`, '2026-06-30 14:39:00', 105000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-181-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-182-1', m.`id`, '2026-07-01 19:17:00', 258000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-182-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-182-2', m.`id`, '2026-07-01 09:30:00', 308000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-182-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-182-3', m.`id`, '2026-07-01 13:43:00', 88000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-182-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-182-4', m.`id`, '2026-07-01 17:56:00', 249000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-182-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-183-1', m.`id`, '2026-07-02 08:34:00', 199000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-183-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-183-2', m.`id`, '2026-07-02 12:47:00', 249000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-183-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-183-3', m.`id`, '2026-07-02 16:00:00', 140000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-183-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-183-4', m.`id`, '2026-07-02 20:13:00', 190000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-183-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-184-1', m.`id`, '2026-07-03 11:51:00', 342000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-184-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-184-2', m.`id`, '2026-07-03 15:04:00', 123000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-184-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-184-3', m.`id`, '2026-07-03 19:17:00', 283000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-184-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-184-4', m.`id`, '2026-07-03 09:30:00', 334000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-184-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-185-1', m.`id`, '2026-07-04 14:08:00', 216000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-185-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-185-2', m.`id`, '2026-07-04 18:21:00', 106000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-185-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-185-3', m.`id`, '2026-07-04 08:34:00', 156000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-185-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-185-4', m.`id`, '2026-07-04 12:47:00', 207000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-185-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-186-1', m.`id`, '2026-07-05 17:25:00', 89000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-186-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-186-2', m.`id`, '2026-07-05 21:38:00', 250000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-186-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-186-3', m.`id`, '2026-07-05 11:51:00', 300000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-186-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-186-4', m.`id`, '2026-07-05 15:04:00', 350000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-186-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-187-1', m.`id`, '2026-07-06 20:42:00', 342000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-187-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-187-2', m.`id`, '2026-07-06 10:55:00', 123000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-187-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-187-3', m.`id`, '2026-07-06 14:08:00', 173000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-187-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-187-4', m.`id`, '2026-07-06 18:21:00', 224000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-187-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-188-1', m.`id`, '2026-07-07 09:59:00', 216000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-188-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-188-2', m.`id`, '2026-07-07 13:12:00', 266000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-188-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-188-3', m.`id`, '2026-07-07 17:25:00', 317000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-188-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-188-4', m.`id`, '2026-07-07 21:38:00', 207000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-188-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-189-1', m.`id`, '2026-07-08 12:16:00', 89000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-189-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-189-2', m.`id`, '2026-07-08 16:29:00', 140000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-189-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-189-3', m.`id`, '2026-07-08 20:42:00', 190000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-189-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-189-4', m.`id`, '2026-07-08 10:55:00', 350000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-189-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-190-1', m.`id`, '2026-07-09 15:33:00', 301000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-190-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-190-2', m.`id`, '2026-07-09 19:46:00', 351000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-190-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-190-3', m.`id`, '2026-07-09 09:59:00', 241000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-190-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-190-4', m.`id`, '2026-07-09 13:12:00', 292000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-190-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-191-1', m.`id`, '2026-07-10 18:50:00', 174000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-191-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-191-2', m.`id`, '2026-07-10 08:03:00', 224000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-191-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-191-3', m.`id`, '2026-07-10 12:16:00', 345000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-191-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-191-4', m.`id`, '2026-07-10 16:29:00', 165000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-191-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-192-1', m.`id`, '2026-07-11 21:07:00', 317000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-192-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-192-2', m.`id`, '2026-07-11 11:20:00', 208000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-192-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-192-3', m.`id`, '2026-07-11 15:33:00', 258000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-192-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-192-4', m.`id`, '2026-07-11 19:46:00', 309000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-192-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-193-1', m.`id`, '2026-07-12 10:24:00', 191000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-193-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-193-2', m.`id`, '2026-07-12 14:37:00', 351000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-193-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-193-3', m.`id`, '2026-07-12 18:50:00', 132000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-193-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-193-4', m.`id`, '2026-07-12 08:03:00', 182000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-193-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-194-1', m.`id`, '2026-07-13 13:41:00', 334000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-194-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-194-2', m.`id`, '2026-07-13 17:54:00', 225000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-194-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-194-3', m.`id`, '2026-07-13 21:07:00', 275000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-194-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-194-4', m.`id`, '2026-07-13 11:20:00', 325000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-194-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-195-1', m.`id`, '2026-07-14 16:58:00', 318000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-195-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-195-2', m.`id`, '2026-07-14 20:11:00', 98000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-195-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-195-3', m.`id`, '2026-07-14 10:24:00', 148000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-195-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-195-4', m.`id`, '2026-07-14 14:37:00', 199000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-195-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-196-1', m.`id`, '2026-07-15 19:15:00', 191000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-196-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-196-2', m.`id`, '2026-07-15 09:28:00', 241000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-196-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-196-3', m.`id`, '2026-07-15 13:41:00', 292000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-196-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-196-4', m.`id`, '2026-07-15 17:54:00', 182000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-196-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-197-1', m.`id`, '2026-07-16 08:32:00', 132000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-197-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-197-2', m.`id`, '2026-07-16 12:45:00', 183000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-197-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-197-3', m.`id`, '2026-07-16 16:58:00', 343000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-197-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-197-4', m.`id`, '2026-07-16 20:11:00', 124000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-197-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-198-1', m.`id`, '2026-07-17 11:49:00', 276000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-198-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-198-2', m.`id`, '2026-07-17 15:02:00', 326000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-198-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-198-3', m.`id`, '2026-07-17 19:15:00', 216000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-198-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-198-4', m.`id`, '2026-07-17 09:28:00', 267000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-198-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-199-1', m.`id`, '2026-07-18 14:06:00', 149000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-199-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-199-2', m.`id`, '2026-07-18 18:19:00', 200000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-199-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-199-3', m.`id`, '2026-07-18 08:32:00', 90000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-199-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-199-4', m.`id`, '2026-07-18 12:45:00', 140000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-199-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-200-1', m.`id`, '2026-07-19 17:23:00', 292000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-200-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-200-2', m.`id`, '2026-07-19 21:36:00', 183000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-200-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-200-3', m.`id`, '2026-07-19 11:49:00', 233000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-200-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-200-4', m.`id`, '2026-07-19 15:02:00', 284000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-200-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-201-1', m.`id`, '2026-07-20 20:40:00', 166000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-201-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-201-2', m.`id`, '2026-07-20 10:53:00', 326000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-201-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-201-3', m.`id`, '2026-07-20 14:06:00', 321000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-201-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-201-4', m.`id`, '2026-07-20 18:19:00', 157000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-201-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-202-1', m.`id`, '2026-07-21 09:57:00', 149000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-202-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-202-2', m.`id`, '2026-07-21 13:10:00', 200000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-202-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-202-3', m.`id`, '2026-07-21 17:23:00', 250000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-202-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-202-4', m.`id`, '2026-07-21 21:36:00', 300000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-202-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-203-1', m.`id`, '2026-07-22 12:14:00', 293000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-203-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-203-2', m.`id`, '2026-07-22 16:27:00', 343000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-203-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-203-3', m.`id`, '2026-07-22 20:40:00', 124000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-203-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-203-4', m.`id`, '2026-07-22 10:53:00', 284000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-203-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-204-1', m.`id`, '2026-07-23 15:31:00', 234000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-204-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-204-2', m.`id`, '2026-07-23 19:44:00', 284000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-204-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-204-3', m.`id`, '2026-07-23 09:57:00', 175000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-204-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-204-4', m.`id`, '2026-07-23 13:10:00', 225000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-204-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-205-1', m.`id`, '2026-07-24 18:48:00', 107000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-205-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-205-2', m.`id`, '2026-07-24 08:01:00', 158000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-205-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-205-3', m.`id`, '2026-07-24 12:14:00', 318000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-205-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-205-4', m.`id`, '2026-07-24 16:27:00', 99000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-205-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-206-1', m.`id`, '2026-07-25 21:05:00', 251000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-206-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-206-2', m.`id`, '2026-07-25 11:18:00', 301000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-206-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-206-3', m.`id`, '2026-07-25 15:31:00', 192000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-206-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-206-4', m.`id`, '2026-07-25 19:44:00', 242000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-206-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-207-1', m.`id`, '2026-07-26 10:22:00', 124000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-207-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-207-2', m.`id`, '2026-07-26 14:35:00', 285000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-207-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-207-3', m.`id`, '2026-07-26 18:48:00', 335000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-207-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-207-4', m.`id`, '2026-07-26 08:01:00', 115000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-207-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-208-1', m.`id`, '2026-07-27 13:39:00', 268000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-208-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-208-2', m.`id`, '2026-07-27 17:52:00', 158000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-208-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-208-3', m.`id`, '2026-07-27 21:05:00', 208000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-208-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-208-4', m.`id`, '2026-07-27 11:18:00', 259000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-208-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-209-1', m.`id`, '2026-07-28 16:56:00', 251000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-209-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-209-2', m.`id`, '2026-07-28 20:09:00', 301000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-209-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-209-3', m.`id`, '2026-07-28 10:22:00', 352000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-209-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-209-4', m.`id`, '2026-07-28 14:35:00', 132000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-209-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-210-1', m.`id`, '2026-07-29 19:13:00', 124000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-210-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-210-2', m.`id`, '2026-07-29 09:26:00', 175000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-210-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-210-3', m.`id`, '2026-07-29 13:39:00', 225000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-210-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-210-4', m.`id`, '2026-07-29 17:52:00', 116000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-210-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-211-1', m.`id`, '2026-07-30 08:30:00', 336000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-211-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-211-2', m.`id`, '2026-07-30 12:43:00', 116000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-211-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-211-3', m.`id`, '2026-07-30 16:56:00', 498000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-211-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-211-4', m.`id`, '2026-07-30 20:09:00', 327000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-211-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-212-1', m.`id`, '2026-07-31 11:47:00', 209000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-212-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-212-2', m.`id`, '2026-07-31 15:00:00', 260000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-212-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-212-3', m.`id`, '2026-07-31 19:13:00', 150000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-212-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-212-4', m.`id`, '2026-07-31 09:26:00', 200000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-212-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-213-1', m.`id`, '2026-08-01 14:04:00', 352000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-213-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-213-2', m.`id`, '2026-08-01 18:17:00', 133000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-213-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-213-3', m.`id`, '2026-08-01 08:30:00', 293000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-213-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-213-4', m.`id`, '2026-08-01 12:43:00', 344000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-213-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-214-1', m.`id`, '2026-08-02 17:21:00', 226000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-214-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-214-2', m.`id`, '2026-08-02 21:34:00', 116000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-214-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-214-3', m.`id`, '2026-08-02 11:47:00', 167000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-214-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-214-4', m.`id`, '2026-08-02 15:00:00', 217000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-214-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-215-1', m.`id`, '2026-08-03 20:38:00', 99000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-215-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-215-2', m.`id`, '2026-08-03 10:51:00', 260000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-215-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-215-3', m.`id`, '2026-08-03 14:04:00', 310000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-215-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-215-4', m.`id`, '2026-08-03 18:17:00', 90000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-215-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-216-1', m.`id`, '2026-08-04 09:55:00', 353000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-216-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-216-2', m.`id`, '2026-08-04 13:08:00', 133000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-216-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-216-3', m.`id`, '2026-08-04 17:21:00', 184000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-216-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-216-4', m.`id`, '2026-08-04 21:34:00', 234000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-216-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-217-1', m.`id`, '2026-08-05 12:12:00', 226000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-217-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-217-2', m.`id`, '2026-08-05 16:25:00', 276000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-217-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-217-3', m.`id`, '2026-08-05 20:38:00', 327000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-217-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-217-4', m.`id`, '2026-08-05 10:51:00', 217000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-217-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-218-1', m.`id`, '2026-08-06 15:29:00', 167000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-218-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-218-2', m.`id`, '2026-08-06 19:42:00', 218000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-218-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-218-3', m.`id`, '2026-08-06 09:55:00', 268000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-218-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-218-4', m.`id`, '2026-08-06 13:08:00', 159000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-218-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-219-1', m.`id`, '2026-08-07 18:46:00', 311000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-219-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-219-2', m.`id`, '2026-08-07 08:59:00', 91000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-219-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-219-3', m.`id`, '2026-08-07 12:12:00', 252000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-219-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-219-4', m.`id`, '2026-08-07 16:25:00', 302000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-219-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-220-1', m.`id`, '2026-08-08 21:03:00', 184000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-220-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-220-2', m.`id`, '2026-08-08 11:16:00', 235000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-220-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-220-3', m.`id`, '2026-08-08 15:29:00', 125000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-220-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-220-4', m.`id`, '2026-08-08 19:42:00', 175000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-220-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-221-1', m.`id`, '2026-08-09 10:20:00', 328000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-221-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-221-2', m.`id`, '2026-08-09 14:33:00', 218000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-221-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-221-3', m.`id`, '2026-08-09 18:46:00', 804000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-221-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-221-4', m.`id`, '2026-08-09 08:59:00', 319000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-221-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-222-1', m.`id`, '2026-08-10 13:37:00', 201000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-222-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-222-2', m.`id`, '2026-08-10 17:50:00', 91000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-222-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-222-3', m.`id`, '2026-08-10 21:03:00', 142000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-222-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-222-4', m.`id`, '2026-08-10 11:16:00', 192000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-222-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-223-1', m.`id`, '2026-08-11 16:54:00', 184000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-223-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-223-2', m.`id`, '2026-08-11 20:07:00', 235000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-223-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-223-3', m.`id`, '2026-08-11 10:20:00', 285000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-223-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-223-4', m.`id`, '2026-08-11 14:33:00', 336000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-223-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-224-1', m.`id`, '2026-08-12 19:11:00', 328000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-224-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-224-2', m.`id`, '2026-08-12 09:24:00', 108000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-224-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-224-3', m.`id`, '2026-08-12 13:37:00', 159000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-224-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-224-4', m.`id`, '2026-08-12 17:50:00', 319000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-224-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-225-1', m.`id`, '2026-08-13 08:28:00', 269000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-225-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-225-2', m.`id`, '2026-08-13 12:41:00', 320000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-225-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-225-3', m.`id`, '2026-08-13 16:54:00', 100000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-225-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-225-4', m.`id`, '2026-08-13 20:07:00', 260000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-225-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-226-1', m.`id`, '2026-08-14 11:45:00', 142000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-226-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-226-2', m.`id`, '2026-08-14 15:58:00', 193000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-226-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-226-3', m.`id`, '2026-08-14 19:11:00', 353000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-226-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-226-4', m.`id`, '2026-08-14 09:24:00', 134000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-226-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-227-1', m.`id`, '2026-08-15 14:02:00', 286000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-227-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-227-2', m.`id`, '2026-08-15 18:15:00', 336000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-227-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-227-3', m.`id`, '2026-08-15 08:28:00', 227000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-227-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-227-4', m.`id`, '2026-08-15 12:41:00', 277000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-227-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-228-1', m.`id`, '2026-08-16 17:19:00', 159000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-228-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-228-2', m.`id`, '2026-08-16 21:32:00', 320000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-228-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-228-3', m.`id`, '2026-08-16 11:45:00', 100000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-228-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-228-4', m.`id`, '2026-08-16 15:58:00', 150000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-228-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-229-1', m.`id`, '2026-08-17 20:36:00', 303000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-229-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-229-2', m.`id`, '2026-08-17 10:49:00', 193000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-229-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-229-3', m.`id`, '2026-08-17 14:02:00', 244000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-229-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-229-4', m.`id`, '2026-08-17 18:15:00', 294000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-229-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-230-1', m.`id`, '2026-08-18 09:53:00', 286000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-230-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-230-2', m.`id`, '2026-08-18 13:06:00', 336000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-230-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-230-3', m.`id`, '2026-08-18 17:19:00', 117000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-230-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-230-4', m.`id`, '2026-08-18 21:32:00', 167000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-230-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-231-1', m.`id`, '2026-08-19 12:10:00', 160000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-231-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-231-2', m.`id`, '2026-08-19 16:23:00', 210000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-231-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-231-3', m.`id`, '2026-08-19 20:36:00', 780000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-231-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-231-4', m.`id`, '2026-08-19 10:49:00', 151000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-231-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-232-1', m.`id`, '2026-08-20 15:27:00', 101000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-232-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-232-2', m.`id`, '2026-08-20 19:40:00', 151000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-232-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-232-3', m.`id`, '2026-08-20 09:53:00', 202000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-232-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-232-4', m.`id`, '2026-08-20 13:06:00', 92000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-232-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-233-1', m.`id`, '2026-08-21 18:44:00', 244000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-233-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-233-2', m.`id`, '2026-08-21 08:57:00', 295000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-233-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-233-3', m.`id`, '2026-08-21 12:10:00', 185000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-233-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-233-4', m.`id`, '2026-08-21 16:23:00', 235000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-233-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-234-1', m.`id`, '2026-08-22 21:01:00', 118000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-234-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-234-2', m.`id`, '2026-08-22 11:14:00', 168000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-234-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-234-3', m.`id`, '2026-08-22 15:27:00', 328000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-234-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-234-4', m.`id`, '2026-08-22 19:40:00', 109000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-234-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-235-1', m.`id`, '2026-08-23 10:18:00', 261000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-235-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-235-2', m.`id`, '2026-08-23 14:31:00', 151000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-235-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-235-3', m.`id`, '2026-08-23 18:44:00', 202000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-235-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-235-4', m.`id`, '2026-08-23 08:57:00', 252000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-235-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-236-1', m.`id`, '2026-08-24 13:35:00', 134000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-236-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-236-2', m.`id`, '2026-08-24 17:48:00', 295000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-236-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-236-3', m.`id`, '2026-08-24 21:01:00', 345000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-236-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-236-4', m.`id`, '2026-08-24 11:14:00', 126000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-236-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-237-1', m.`id`, '2026-08-25 16:52:00', 278000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-237-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-237-2', m.`id`, '2026-08-25 20:05:00', 168000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-237-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-237-3', m.`id`, '2026-08-25 10:18:00', 219000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-237-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-237-4', m.`id`, '2026-08-25 14:31:00', 269000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-237-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-238-1', m.`id`, '2026-08-26 19:09:00', 261000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-238-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-238-2', m.`id`, '2026-08-26 09:22:00', 312000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-238-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-238-3', m.`id`, '2026-08-26 13:35:00', 92000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-238-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-238-4', m.`id`, '2026-08-26 17:48:00', 142000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-238-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-239-1', m.`id`, '2026-08-27 08:26:00', 202000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-239-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-239-2', m.`id`, '2026-08-27 12:39:00', 253000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-239-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-239-3', m.`id`, '2026-08-27 16:52:00', 303000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-239-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-239-4', m.`id`, '2026-08-27 20:05:00', 194000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-239-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-240-1', m.`id`, '2026-08-28 11:43:00', 346000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-240-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-240-2', m.`id`, '2026-08-28 15:56:00', 126000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-240-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-240-3', m.`id`, '2026-08-28 19:09:00', 287000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-240-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-240-4', m.`id`, '2026-08-28 09:22:00', 337000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-240-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-241-1', m.`id`, '2026-08-29 14:00:00', 219000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-241-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-241-2', m.`id`, '2026-08-29 18:13:00', 270000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-241-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-241-3', m.`id`, '2026-08-29 08:26:00', 480000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-241-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-241-4', m.`id`, '2026-08-29 12:39:00', 210000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-241-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-242-1', m.`id`, '2026-08-30 17:17:00', 93000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-242-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-242-2', m.`id`, '2026-08-30 21:30:00', 253000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-242-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-242-3', m.`id`, '2026-08-30 11:43:00', 304000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-242-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-242-4', m.`id`, '2026-08-30 15:56:00', 354000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-242-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-243-1', m.`id`, '2026-08-31 20:34:00', 236000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-243-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-243-2', m.`id`, '2026-08-31 10:47:00', 126000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-243-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-243-3', m.`id`, '2026-08-31 14:00:00', 177000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-243-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-243-4', m.`id`, '2026-08-31 18:13:00', 227000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-243-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-244-1', m.`id`, '2026-09-01 09:51:00', 110000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-244-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-244-2', m.`id`, '2026-09-01 13:04:00', 270000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-244-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-244-3', m.`id`, '2026-09-01 17:17:00', 320000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-244-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-244-4', m.`id`, '2026-09-01 21:30:00', 101000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-244-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-245-1', m.`id`, '2026-09-02 12:08:00', 93000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-245-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-245-2', m.`id`, '2026-09-02 16:21:00', 143000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-245-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-245-3', m.`id`, '2026-09-02 20:34:00', 194000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-245-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-245-4', m.`id`, '2026-09-02 10:47:00', 244000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-245-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-246-1', m.`id`, '2026-09-03 15:25:00', 304000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-246-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-246-2', m.`id`, '2026-09-03 19:38:00', 355000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-246-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-246-3', m.`id`, '2026-09-03 09:51:00', 135000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-246-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-246-4', m.`id`, '2026-09-03 13:04:00', 295000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-246-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-247-1', m.`id`, '2026-09-04 18:42:00', 178000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-247-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-247-2', m.`id`, '2026-09-04 08:55:00', 228000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-247-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-247-3', m.`id`, '2026-09-04 12:08:00', 118000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-247-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-247-4', m.`id`, '2026-09-04 16:21:00', 169000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-247-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-248-1', m.`id`, '2026-09-05 21:59:00', 321000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-248-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-248-2', m.`id`, '2026-09-05 11:12:00', 101000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-248-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-248-3', m.`id`, '2026-09-05 15:25:00', 262000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-248-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-248-4', m.`id`, '2026-09-05 19:38:00', 312000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-248-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-249-1', m.`id`, '2026-09-06 10:16:00', 194000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-249-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-249-2', m.`id`, '2026-09-06 14:29:00', 245000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-249-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-249-3', m.`id`, '2026-09-06 18:42:00', 135000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-249-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-249-4', m.`id`, '2026-09-06 08:55:00', 186000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-249-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-250-1', m.`id`, '2026-09-07 13:33:00', 338000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-250-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-250-2', m.`id`, '2026-09-07 17:46:00', 228000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-250-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-250-3', m.`id`, '2026-09-07 21:59:00', 279000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-250-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-250-4', m.`id`, '2026-09-07 11:12:00', 329000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-250-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-251-1', m.`id`, '2026-09-08 16:50:00', 211000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-251-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-251-2', m.`id`, '2026-09-08 20:03:00', 102000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-251-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-251-3', m.`id`, '2026-09-08 10:16:00', 456000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-251-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-251-4', m.`id`, '2026-09-08 14:29:00', 202000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-251-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-252-1', m.`id`, '2026-09-09 19:07:00', 195000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-252-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-252-2', m.`id`, '2026-09-09 09:20:00', 245000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-252-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-252-3', m.`id`, '2026-09-09 13:33:00', 295000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-252-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-252-4', m.`id`, '2026-09-09 17:46:00', 346000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-252-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-253-1', m.`id`, '2026-09-10 08:24:00', 136000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-253-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-253-2', m.`id`, '2026-09-10 12:37:00', 186000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-253-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-253-3', m.`id`, '2026-09-10 16:50:00', 237000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-253-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-253-4', m.`id`, '2026-09-10 20:03:00', 127000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-253-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-254-1', m.`id`, '2026-09-11 11:41:00', 279000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-254-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-254-2', m.`id`, '2026-09-11 15:54:00', 330000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-254-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-254-3', m.`id`, '2026-09-11 19:07:00', 110000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-254-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-254-4', m.`id`, '2026-09-11 09:20:00', 270000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-254-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-255-1', m.`id`, '2026-09-12 14:58:00', 153000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-255-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-255-2', m.`id`, '2026-09-12 18:11:00', 203000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-255-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-255-3', m.`id`, '2026-09-12 08:24:00', 94000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-255-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-255-4', m.`id`, '2026-09-12 12:37:00', 144000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-255-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-256-1', m.`id`, '2026-09-13 17:15:00', 296000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-256-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-256-2', m.`id`, '2026-09-13 21:28:00', 346000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-256-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-256-3', m.`id`, '2026-09-13 11:41:00', 237000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-256-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-256-4', m.`id`, '2026-09-13 15:54:00', 287000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-256-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-257-1', m.`id`, '2026-09-14 20:32:00', 170000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-257-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-257-2', m.`id`, '2026-09-14 10:45:00', 330000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-257-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-257-3', m.`id`, '2026-09-14 14:58:00', 110000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-257-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-257-4', m.`id`, '2026-09-14 18:11:00', 161000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-257-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-258-1', m.`id`, '2026-09-15 09:49:00', 313000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-258-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-258-2', m.`id`, '2026-09-15 13:02:00', 203000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-258-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-258-3', m.`id`, '2026-09-15 17:15:00', 254000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-258-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-258-4', m.`id`, '2026-09-15 21:28:00', 304000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-258-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-259-1', m.`id`, '2026-09-16 12:06:00', 296000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-259-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-259-2', m.`id`, '2026-09-16 16:19:00', 347000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-259-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-259-3', m.`id`, '2026-09-16 20:32:00', 127000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-259-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-259-4', m.`id`, '2026-09-16 10:45:00', 178000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-259-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-260-1', m.`id`, '2026-09-17 15:23:00', 238000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-260-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-260-2', m.`id`, '2026-09-17 19:36:00', 288000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-260-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-260-3', m.`id`, '2026-09-17 09:49:00', 338000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-260-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-260-4', m.`id`, '2026-09-17 13:02:00', 229000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-260-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-261-1', m.`id`, '2026-09-18 18:40:00', 111000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-261-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-261-2', m.`id`, '2026-09-18 08:53:00', 161000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-261-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-261-3', m.`id`, '2026-09-18 12:06:00', 636000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-261-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-261-4', m.`id`, '2026-09-18 16:19:00', 102000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-261-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-262-1', m.`id`, '2026-09-19 21:57:00', 254000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-262-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-262-2', m.`id`, '2026-09-19 11:10:00', 305000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-262-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-262-3', m.`id`, '2026-09-19 15:23:00', 195000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-262-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-262-4', m.`id`, '2026-09-19 19:36:00', 246000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-262-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-263-1', m.`id`, '2026-09-20 10:14:00', 128000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-263-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-263-2', m.`id`, '2026-09-20 14:27:00', 178000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-263-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-263-3', m.`id`, '2026-09-20 18:40:00', 339000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-263-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-263-4', m.`id`, '2026-09-20 08:53:00', 119000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-263-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-264-1', m.`id`, '2026-09-21 13:31:00', 271000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-264-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-264-2', m.`id`, '2026-09-21 17:44:00', 162000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-264-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-264-3', m.`id`, '2026-09-21 21:57:00', 212000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-264-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-264-4', m.`id`, '2026-09-21 11:10:00', 262000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-264-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-265-1', m.`id`, '2026-09-22 16:48:00', 145000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-265-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-265-2', m.`id`, '2026-09-22 20:01:00', 305000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-265-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-265-3', m.`id`, '2026-09-22 10:14:00', 85000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-265-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-265-4', m.`id`, '2026-09-22 14:27:00', 136000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-265-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-266-1', m.`id`, '2026-09-23 19:05:00', 128000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-266-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-266-2', m.`id`, '2026-09-23 09:18:00', 178000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-266-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-266-3', m.`id`, '2026-09-23 13:31:00', 229000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-266-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-266-4', m.`id`, '2026-09-23 17:44:00', 279000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-266-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-267-1', m.`id`, '2026-09-24 08:22:00', 339000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-267-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-267-2', m.`id`, '2026-09-24 12:35:00', 120000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-267-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-267-3', m.`id`, '2026-09-24 16:48:00', 170000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-267-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-267-4', m.`id`, '2026-09-24 20:01:00', 330000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-267-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-268-1', m.`id`, '2026-09-25 11:39:00', 213000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-268-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-268-2', m.`id`, '2026-09-25 15:52:00', 263000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-268-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-268-3', m.`id`, '2026-09-25 19:05:00', 314000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-268-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-268-4', m.`id`, '2026-09-25 09:18:00', 204000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-268-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-269-1', m.`id`, '2026-09-26 14:56:00', 86000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-269-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-269-2', m.`id`, '2026-09-26 18:09:00', 136000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-269-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-269-3', m.`id`, '2026-09-26 08:22:00', 297000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-269-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-269-4', m.`id`, '2026-09-26 12:35:00', 347000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-269-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-270-1', m.`id`, '2026-09-27 17:13:00', 230000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-270-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-270-2', m.`id`, '2026-09-27 21:26:00', 280000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-270-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-270-3', m.`id`, '2026-09-27 11:39:00', 170000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-270-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-270-4', m.`id`, '2026-09-27 15:52:00', 221000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-270-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-271-1', m.`id`, '2026-09-28 20:30:00', 103000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-271-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-271-2', m.`id`, '2026-09-28 10:43:00', 263000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-271-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-271-3', m.`id`, '2026-09-28 14:56:00', 942000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-271-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-271-4', m.`id`, '2026-09-28 18:09:00', 94000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-271-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-272-1', m.`id`, '2026-09-29 09:47:00', 246000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-272-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-272-2', m.`id`, '2026-09-29 13:00:00', 137000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-272-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-272-3', m.`id`, '2026-09-29 17:13:00', 187000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-272-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-272-4', m.`id`, '2026-09-29 21:26:00', 238000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-272-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-273-1', m.`id`, '2026-09-30 12:04:00', 230000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-273-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-273-2', m.`id`, '2026-09-30 16:17:00', 280000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-273-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-273-3', m.`id`, '2026-09-30 20:30:00', 330000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-273-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-273-4', m.`id`, '2026-09-30 10:43:00', 111000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-273-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-274-1', m.`id`, '2026-10-01 15:21:00', 171000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-274-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-274-2', m.`id`, '2026-10-01 19:34:00', 221000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-274-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-274-3', m.`id`, '2026-10-01 09:47:00', 272000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-274-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-274-4', m.`id`, '2026-10-01 13:00:00', 162000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-274-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-275-1', m.`id`, '2026-10-02 18:38:00', 314000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-275-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-275-2', m.`id`, '2026-10-02 08:51:00', 95000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-275-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-275-3', m.`id`, '2026-10-02 12:04:00', 145000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-275-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-275-4', m.`id`, '2026-10-02 16:17:00', 306000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-275-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-276-1', m.`id`, '2026-10-03 21:55:00', 188000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-276-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-276-2', m.`id`, '2026-10-03 11:08:00', 238000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-276-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-276-3', m.`id`, '2026-10-03 15:21:00', 129000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-276-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-276-4', m.`id`, '2026-10-03 19:34:00', 179000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-276-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-277-1', m.`id`, '2026-10-04 10:12:00', 331000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-277-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-277-2', m.`id`, '2026-10-04 14:25:00', 112000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-277-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-277-3', m.`id`, '2026-10-04 18:38:00', 272000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-277-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-277-4', m.`id`, '2026-10-04 08:51:00', 322000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-277-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-278-1', m.`id`, '2026-10-05 13:29:00', 205000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-278-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-278-2', m.`id`, '2026-10-05 17:42:00', 95000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-278-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-278-3', m.`id`, '2026-10-05 21:55:00', 145000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-278-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-278-4', m.`id`, '2026-10-05 11:08:00', 196000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-278-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-279-1', m.`id`, '2026-10-06 16:46:00', 348000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-279-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-279-2', m.`id`, '2026-10-06 20:59:00', 238000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-279-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-279-3', m.`id`, '2026-10-06 10:12:00', 289000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-279-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-279-4', m.`id`, '2026-10-06 14:25:00', 339000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-279-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-280-1', m.`id`, '2026-10-07 19:03:00', 331000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-280-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-280-2', m.`id`, '2026-10-07 09:16:00', 112000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-280-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-280-3', m.`id`, '2026-10-07 13:29:00', 162000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-280-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-280-4', m.`id`, '2026-10-07 17:42:00', 213000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-280-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-281-1', m.`id`, '2026-10-08 08:20:00', 273000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-281-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-281-2', m.`id`, '2026-10-08 12:33:00', 323000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-281-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-281-3', m.`id`, '2026-10-08 16:46:00', 312000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-281-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-281-4', m.`id`, '2026-10-08 20:59:00', 264000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-281-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-282-1', m.`id`, '2026-10-09 11:37:00', 146000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-282-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-282-2', m.`id`, '2026-10-09 15:50:00', 196000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-282-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-282-3', m.`id`, '2026-10-09 19:03:00', 247000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-282-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-282-4', m.`id`, '2026-10-09 09:16:00', 137000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-282-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-283-1', m.`id`, '2026-10-10 14:54:00', 290000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-283-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-283-2', m.`id`, '2026-10-10 18:07:00', 340000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-283-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-283-3', m.`id`, '2026-10-10 08:20:00', 230000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-283-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-283-4', m.`id`, '2026-10-10 12:33:00', 281000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-283-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-284-1', m.`id`, '2026-10-11 17:11:00', 163000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-284-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-284-2', m.`id`, '2026-10-11 21:24:00', 213000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-284-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-284-3', m.`id`, '2026-10-11 11:37:00', 104000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-284-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-284-4', m.`id`, '2026-10-11 15:50:00', 154000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-284-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-285-1', m.`id`, '2026-10-12 20:28:00', 306000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-285-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-285-2', m.`id`, '2026-10-12 10:41:00', 197000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-285-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-285-3', m.`id`, '2026-10-12 14:54:00', 247000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-285-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-285-4', m.`id`, '2026-10-12 18:07:00', 298000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-285-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-286-1', m.`id`, '2026-10-13 09:45:00', 180000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-286-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-286-2', m.`id`, '2026-10-13 13:58:00', 340000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-286-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-286-3', m.`id`, '2026-10-13 17:11:00', 120000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-286-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-286-4', m.`id`, '2026-10-13 21:24:00', 171000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-286-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-287-1', m.`id`, '2026-10-14 12:02:00', 323000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-287-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-287-2', m.`id`, '2026-10-14 16:15:00', 214000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-287-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-287-3', m.`id`, '2026-10-14 20:28:00', 264000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-287-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-287-4', m.`id`, '2026-10-14 10:41:00', 314000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-287-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-288-1', m.`id`, '2026-10-15 15:19:00', 104000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-288-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-288-2', m.`id`, '2026-10-15 19:32:00', 155000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-288-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-288-3', m.`id`, '2026-10-15 09:45:00', 205000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-288-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-288-4', m.`id`, '2026-10-15 13:58:00', 96000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-288-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-289-1', m.`id`, '2026-10-16 18:36:00', 248000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-289-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-289-2', m.`id`, '2026-10-16 08:49:00', 298000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-289-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-289-3', m.`id`, '2026-10-16 12:02:00', 349000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-289-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-289-4', m.`id`, '2026-10-16 16:15:00', 239000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-289-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-290-1', m.`id`, '2026-10-17 21:53:00', 121000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-290-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-290-2', m.`id`, '2026-10-17 11:06:00', 172000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-290-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-290-3', m.`id`, '2026-10-17 15:19:00', 332000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-290-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-290-4', m.`id`, '2026-10-17 19:32:00', 112000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-290-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-291-1', m.`id`, '2026-10-18 10:10:00', 265000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-291-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-291-2', m.`id`, '2026-10-18 14:23:00', 315000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-291-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-291-3', m.`id`, '2026-10-18 18:36:00', 615000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-291-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-291-4', m.`id`, '2026-10-18 08:49:00', 256000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-291-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-292-1', m.`id`, '2026-10-19 13:27:00', 138000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-292-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-292-2', m.`id`, '2026-10-19 17:40:00', 188000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-292-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-292-3', m.`id`, '2026-10-19 21:53:00', 349000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-292-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-292-4', m.`id`, '2026-10-19 11:06:00', 129000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-292-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-293-1', m.`id`, '2026-10-20 16:44:00', 281000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-293-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-293-2', m.`id`, '2026-10-20 20:57:00', 172000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-293-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-293-3', m.`id`, '2026-10-20 10:10:00', 222000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-293-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-293-4', m.`id`, '2026-10-20 14:23:00', 273000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-293-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-294-1', m.`id`, '2026-10-21 19:01:00', 155000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-294-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-294-2', m.`id`, '2026-10-21 09:14:00', 315000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-294-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-294-3', m.`id`, '2026-10-21 13:27:00', 96000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-294-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-294-4', m.`id`, '2026-10-21 17:40:00', 146000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-294-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-295-1', m.`id`, '2026-10-22 08:18:00', 206000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-295-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-295-2', m.`id`, '2026-10-22 12:31:00', 256000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-295-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-295-3', m.`id`, '2026-10-22 16:44:00', 307000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-295-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-295-4', m.`id`, '2026-10-22 20:57:00', 197000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-295-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-296-1', m.`id`, '2026-10-23 11:35:00', 350000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-296-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-296-2', m.`id`, '2026-10-23 15:48:00', 130000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-296-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-296-3', m.`id`, '2026-10-23 19:01:00', 180000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-296-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-296-4', m.`id`, '2026-10-23 09:14:00', 341000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-296-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-297-1', m.`id`, '2026-10-24 14:52:00', 223000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-297-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-297-2', m.`id`, '2026-10-24 18:05:00', 273000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-297-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-297-3', m.`id`, '2026-10-24 08:18:00', 164000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-297-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-297-4', m.`id`, '2026-10-24 12:31:00', 214000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-297-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-298-1', m.`id`, '2026-10-25 17:09:00', 96000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-298-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-298-2', m.`id`, '2026-10-25 21:22:00', 147000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-298-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-298-3', m.`id`, '2026-10-25 11:35:00', 307000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-298-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-298-4', m.`id`, '2026-10-25 15:48:00', 88000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-298-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-299-1', m.`id`, '2026-10-26 20:26:00', 240000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-299-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-299-2', m.`id`, '2026-10-26 10:39:00', 290000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-299-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-299-3', m.`id`, '2026-10-26 14:52:00', 180000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-299-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-299-4', m.`id`, '2026-10-26 18:05:00', 231000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-299-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-300-1', m.`id`, '2026-10-27 09:43:00', 113000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-300-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-300-2', m.`id`, '2026-10-27 13:56:00', 274000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-300-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-300-3', m.`id`, '2026-10-27 17:09:00', 324000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-300-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-300-4', m.`id`, '2026-10-27 21:22:00', 104000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-300-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-301-1', m.`id`, '2026-10-28 12:00:00', 256000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-301-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-301-2', m.`id`, '2026-10-28 16:13:00', 147000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-301-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-301-3', m.`id`, '2026-10-28 20:26:00', 591000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-301-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-301-4', m.`id`, '2026-10-28 10:39:00', 248000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-301-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-302-1', m.`id`, '2026-10-29 15:17:00', 308000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-302-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-302-2', m.`id`, '2026-10-29 19:30:00', 88000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-302-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-302-3', m.`id`, '2026-10-29 09:43:00', 139000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-302-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-302-4', m.`id`, '2026-10-29 13:56:00', 299000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-302-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-303-1', m.`id`, '2026-10-30 18:34:00', 181000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-303-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-303-2', m.`id`, '2026-10-30 08:47:00', 232000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-303-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-303-3', m.`id`, '2026-10-30 12:00:00', 282000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-303-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-303-4', m.`id`, '2026-10-30 16:13:00', 172000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-303-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-304-1', m.`id`, '2026-10-31 21:51:00', 325000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-304-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-304-2', m.`id`, '2026-10-31 11:04:00', 105000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-304-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-304-3', m.`id`, '2026-10-31 15:17:00', 155000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-304-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-304-4', m.`id`, '2026-10-31 19:30:00', 316000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-304-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-305-1', m.`id`, '2026-11-01 10:08:00', 198000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-305-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-305-2', m.`id`, '2026-11-01 14:21:00', 248000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-305-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-305-3', m.`id`, '2026-11-01 18:34:00', 139000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-305-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-305-4', m.`id`, '2026-11-01 08:47:00', 189000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-305-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-306-1', m.`id`, '2026-11-02 13:25:00', 341000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-306-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-306-2', m.`id`, '2026-11-02 17:38:00', 122000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-306-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-306-3', m.`id`, '2026-11-02 21:51:00', 282000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-306-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-306-4', m.`id`, '2026-11-02 11:04:00', 333000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-306-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-307-1', m.`id`, '2026-11-03 16:42:00', 215000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-307-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-307-2', m.`id`, '2026-11-03 20:55:00', 105000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-307-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-307-3', m.`id`, '2026-11-03 10:08:00', 156000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-307-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-307-4', m.`id`, '2026-11-03 14:21:00', 206000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-307-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-308-1', m.`id`, '2026-11-04 19:59:00', 88000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-308-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-308-2', m.`id`, '2026-11-04 09:12:00', 249000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-308-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-308-3', m.`id`, '2026-11-04 13:25:00', 299000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-308-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-308-4', m.`id`, '2026-11-04 17:38:00', 349000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-308-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-309-1', m.`id`, '2026-11-05 08:16:00', 140000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-309-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-309-2', m.`id`, '2026-11-05 12:29:00', 190000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-309-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-309-3', m.`id`, '2026-11-05 16:42:00', 240000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-309-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-309-4', m.`id`, '2026-11-05 20:55:00', 291000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-309-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-310-1', m.`id`, '2026-11-06 11:33:00', 283000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-310-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-310-2', m.`id`, '2026-11-06 15:46:00', 333000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-310-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-310-3', m.`id`, '2026-11-06 19:59:00', 114000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-310-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-310-4', m.`id`, '2026-11-06 09:12:00', 274000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-310-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-311-1', m.`id`, '2026-11-07 14:50:00', 156000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-311-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-311-2', m.`id`, '2026-11-07 18:03:00', 207000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-311-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-311-3', m.`id`, '2026-11-07 08:16:00', 771000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-311-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-311-4', m.`id`, '2026-11-07 12:29:00', 148000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-311-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-312-1', m.`id`, '2026-11-08 17:07:00', 300000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-312-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-312-2', m.`id`, '2026-11-08 21:20:00', 350000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-312-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-312-3', m.`id`, '2026-11-08 11:33:00', 240000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-312-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-312-4', m.`id`, '2026-11-08 15:46:00', 291000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-312-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-313-1', m.`id`, '2026-11-09 20:24:00', 173000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-313-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-313-2', m.`id`, '2026-11-09 10:37:00', 224000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-313-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-313-3', m.`id`, '2026-11-09 14:50:00', 114000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_023'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-313-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-313-4', m.`id`, '2026-11-09 18:03:00', 164000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_052'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-313-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-314-1', m.`id`, '2026-11-10 09:41:00', 316000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-314-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-314-2', m.`id`, '2026-11-10 13:54:00', 207000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-314-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-314-3', m.`id`, '2026-11-10 17:07:00', 257000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-314-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-314-4', m.`id`, '2026-11-10 21:20:00', 308000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-314-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-315-1', m.`id`, '2026-11-11 12:58:00', 190000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-315-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-315-2', m.`id`, '2026-11-11 16:11:00', 350000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-315-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-315-3', m.`id`, '2026-11-11 20:24:00', 131000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-315-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-315-4', m.`id`, '2026-11-11 10:37:00', 181000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-315-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-316-1', m.`id`, '2026-11-12 15:15:00', 241000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-316-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-316-2', m.`id`, '2026-11-12 19:28:00', 292000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-316-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-316-3', m.`id`, '2026-11-12 09:41:00', 342000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-316-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-316-4', m.`id`, '2026-11-12 13:54:00', 122000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-316-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-317-1', m.`id`, '2026-11-13 18:32:00', 115000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-317-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-317-2', m.`id`, '2026-11-13 08:45:00', 165000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-317-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-317-3', m.`id`, '2026-11-13 12:58:00', 215000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-317-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-317-4', m.`id`, '2026-11-13 16:11:00', 106000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-317-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-318-1', m.`id`, '2026-11-14 21:49:00', 258000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-318-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-318-2', m.`id`, '2026-11-14 11:02:00', 308000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-318-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-318-3', m.`id`, '2026-11-14 15:15:00', 89000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-318-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-318-4', m.`id`, '2026-11-14 19:28:00', 249000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-318-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-319-1', m.`id`, '2026-11-15 10:06:00', 131000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-319-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-319-2', m.`id`, '2026-11-15 14:19:00', 182000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-319-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-319-3', m.`id`, '2026-11-15 18:32:00', 342000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-319-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-319-4', m.`id`, '2026-11-15 08:45:00', 123000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-319-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-320-1', m.`id`, '2026-11-16 13:23:00', 275000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-320-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-320-2', m.`id`, '2026-11-16 17:36:00', 325000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-320-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-320-3', m.`id`, '2026-11-16 21:49:00', 216000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_021'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-320-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-320-4', m.`id`, '2026-11-16 11:02:00', 266000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_050'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-320-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-321-1', m.`id`, '2026-11-17 16:40:00', 148000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-321-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-321-2', m.`id`, '2026-11-17 20:53:00', 309000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-321-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-321-3', m.`id`, '2026-11-17 10:06:00', 267000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-321-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-321-4', m.`id`, '2026-11-17 14:19:00', 139000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-321-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-322-1', m.`id`, '2026-11-18 19:57:00', 292000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-322-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-322-2', m.`id`, '2026-11-18 09:10:00', 182000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-322-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-322-3', m.`id`, '2026-11-18 13:23:00', 232000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-322-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-322-4', m.`id`, '2026-11-18 17:36:00', 283000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-322-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-323-1', m.`id`, '2026-11-19 08:14:00', 343000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-323-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-323-2', m.`id`, '2026-11-19 12:27:00', 123000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-323-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-323-3', m.`id`, '2026-11-19 16:40:00', 174000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-323-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-323-4', m.`id`, '2026-11-19 20:53:00', 224000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-323-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-324-1', m.`id`, '2026-11-20 11:31:00', 216000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-324-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-324-2', m.`id`, '2026-11-20 15:44:00', 267000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-324-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-324-3', m.`id`, '2026-11-20 19:57:00', 317000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-324-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-324-4', m.`id`, '2026-11-20 09:10:00', 208000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-324-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-325-1', m.`id`, '2026-11-21 14:48:00', 90000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-325-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-325-2', m.`id`, '2026-11-21 18:01:00', 140000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-325-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-325-3', m.`id`, '2026-11-21 08:14:00', 190000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-325-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-325-4', m.`id`, '2026-11-21 12:27:00', 351000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-325-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-326-1', m.`id`, '2026-11-22 17:05:00', 233000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-326-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-326-2', m.`id`, '2026-11-22 21:18:00', 284000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-326-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-326-3', m.`id`, '2026-11-22 11:31:00', 174000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-326-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-326-4', m.`id`, '2026-11-22 15:44:00', 224000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-326-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-327-1', m.`id`, '2026-11-23 20:22:00', 106000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-327-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-327-2', m.`id`, '2026-11-23 10:35:00', 157000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-327-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-327-3', m.`id`, '2026-11-23 14:48:00', 317000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_019'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-327-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-327-4', m.`id`, '2026-11-23 18:01:00', 98000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_048'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-327-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-328-1', m.`id`, '2026-11-24 09:39:00', 250000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-328-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-328-2', m.`id`, '2026-11-24 13:52:00', 140000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-328-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-328-3', m.`id`, '2026-11-24 17:05:00', 191000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-328-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-328-4', m.`id`, '2026-11-24 21:18:00', 241000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-328-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-329-1', m.`id`, '2026-11-25 12:56:00', 123000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-329-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-329-2', m.`id`, '2026-11-25 16:09:00', 284000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-329-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-329-3', m.`id`, '2026-11-25 20:22:00', 334000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-329-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-329-4', m.`id`, '2026-11-25 10:35:00', 114000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-329-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-330-1', m.`id`, '2026-11-26 15:13:00', 175000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-330-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-330-2', m.`id`, '2026-11-26 19:26:00', 225000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_036'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-330-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-330-3', m.`id`, '2026-11-26 09:39:00', 275000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_065'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-330-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-330-4', m.`id`, '2026-11-26 13:52:00', 326000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_094'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-330-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-331-1', m.`id`, '2026-11-27 18:30:00', 318000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-331-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-331-2', m.`id`, '2026-11-27 08:43:00', 98000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_049'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-331-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-331-3', m.`id`, '2026-11-27 12:56:00', 447000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_078'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-331-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-331-4', m.`id`, '2026-11-27 16:09:00', 309000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_007'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-331-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-332-1', m.`id`, '2026-11-28 21:47:00', 191000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-332-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-332-2', m.`id`, '2026-11-28 11:00:00', 242000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_062'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-332-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-332-3', m.`id`, '2026-11-28 15:13:00', 292000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_091'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-332-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-332-4', m.`id`, '2026-11-28 19:26:00', 183000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_020'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-332-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-333-1', m.`id`, '2026-11-29 10:04:00', 335000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-333-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-333-2', m.`id`, '2026-11-29 14:17:00', 115000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_075'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-333-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-333-3', m.`id`, '2026-11-29 18:30:00', 276000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_004'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-333-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-333-4', m.`id`, '2026-11-29 08:43:00', 326000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_033'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-333-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-334-1', m.`id`, '2026-11-30 13:21:00', 208000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-334-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-334-2', m.`id`, '2026-11-30 17:34:00', 259000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-334-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-334-3', m.`id`, '2026-11-30 21:47:00', 149000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_017'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-334-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-334-4', m.`id`, '2026-11-30 11:00:00', 199000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_046'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-334-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-335-1', m.`id`, '2026-12-01 16:38:00', 352000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-335-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-335-2', m.`id`, '2026-12-01 20:51:00', 242000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-335-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-335-3', m.`id`, '2026-12-01 10:04:00', 292000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-335-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-335-4', m.`id`, '2026-12-01 14:17:00', 343000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-335-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-336-1', m.`id`, '2026-12-02 19:55:00', 225000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-336-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-336-2', m.`id`, '2026-12-02 09:08:00', 115000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-336-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-336-3', m.`id`, '2026-12-02 13:21:00', 166000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-336-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-336-4', m.`id`, '2026-12-02 17:34:00', 216000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-336-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-337-1', m.`id`, '2026-12-03 08:12:00', 276000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-337-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-337-2', m.`id`, '2026-12-03 12:25:00', 327000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_034'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-337-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-337-3', m.`id`, '2026-12-03 16:38:00', 107000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_063'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-337-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-337-4', m.`id`, '2026-12-03 20:51:00', 158000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_092'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-337-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-338-1', m.`id`, '2026-12-04 11:29:00', 150000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-338-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-338-2', m.`id`, '2026-12-04 15:42:00', 200000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_047'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-338-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-338-3', m.`id`, '2026-12-04 19:55:00', 250000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_076'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-338-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-338-4', m.`id`, '2026-12-04 09:08:00', 141000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_005'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-338-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-339-1', m.`id`, '2026-12-05 14:46:00', 293000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-339-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-339-2', m.`id`, '2026-12-05 18:59:00', 344000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_060'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-339-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-339-3', m.`id`, '2026-12-05 08:12:00', 124000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_089'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-339-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-339-4', m.`id`, '2026-12-05 12:25:00', 284000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_018'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-339-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-340-1', m.`id`, '2026-12-06 17:03:00', 166000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-340-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-340-2', m.`id`, '2026-12-06 21:16:00', 217000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_073'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-340-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-340-3', m.`id`, '2026-12-06 11:29:00', 107000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_002'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-340-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-340-4', m.`id`, '2026-12-06 15:42:00', 158000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_031'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-340-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-341-1', m.`id`, '2026-12-07 20:20:00', 310000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-341-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-341-2', m.`id`, '2026-12-07 10:33:00', 90000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-341-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-341-3', m.`id`, '2026-12-07 14:46:00', 753000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_015'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-341-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-341-4', m.`id`, '2026-12-07 18:59:00', 301000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_044'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-341-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-342-1', m.`id`, '2026-12-08 09:37:00', 183000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-342-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-342-2', m.`id`, '2026-12-08 13:50:00', 234000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-342-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-342-3', m.`id`, '2026-12-08 17:03:00', 124000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-342-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-342-4', m.`id`, '2026-12-08 21:16:00', 174000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-342-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-343-1', m.`id`, '2026-12-09 12:54:00', 327000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-343-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-343-2', m.`id`, '2026-12-09 16:07:00', 217000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-343-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-343-3', m.`id`, '2026-12-09 20:20:00', 268000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-343-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-343-4', m.`id`, '2026-12-09 10:33:00', 318000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-343-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-344-1', m.`id`, '2026-12-10 15:11:00', 108000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-344-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-344-2', m.`id`, '2026-12-10 19:24:00', 158000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_032'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-344-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-344-3', m.`id`, '2026-12-10 09:37:00', 209000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_061'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-344-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-344-4', m.`id`, '2026-12-10 13:50:00', 259000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_090'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-344-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-345-1', m.`id`, '2026-12-11 18:28:00', 251000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-345-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-345-2', m.`id`, '2026-12-11 08:41:00', 302000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_045'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-345-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-345-3', m.`id`, '2026-12-11 12:54:00', 352000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_074'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-345-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-345-4', m.`id`, '2026-12-11 16:07:00', 243000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_003'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-345-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-346-1', m.`id`, '2026-12-12 21:45:00', 125000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-346-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-346-2', m.`id`, '2026-12-12 11:58:00', 175000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_058'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-346-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-346-3', m.`id`, '2026-12-12 15:11:00', 226000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_087'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-346-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-346-4', m.`id`, '2026-12-12 19:24:00', 116000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_016'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-346-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-347-1', m.`id`, '2026-12-13 10:02:00', 268000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-347-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-347-2', m.`id`, '2026-12-13 14:15:00', 319000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_071'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-347-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-347-3', m.`id`, '2026-12-13 18:28:00', 99000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_100'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-347-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-347-4', m.`id`, '2026-12-13 08:41:00', 259000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_029'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-347-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-348-1', m.`id`, '2026-12-14 13:19:00', 142000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-348-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-348-2', m.`id`, '2026-12-14 17:32:00', 192000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-348-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-348-3', m.`id`, '2026-12-14 21:45:00', 352000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_013'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-348-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-348-4', m.`id`, '2026-12-14 11:58:00', 133000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_042'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-348-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-349-1', m.`id`, '2026-12-15 16:36:00', 285000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-349-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-349-2', m.`id`, '2026-12-15 20:49:00', 335000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-349-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-349-3', m.`id`, '2026-12-15 10:02:00', 226000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-349-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-349-4', m.`id`, '2026-12-15 14:15:00', 276000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-349-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-350-1', m.`id`, '2026-12-16 19:53:00', 158000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_081'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-350-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-350-2', m.`id`, '2026-12-16 09:06:00', 319000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_010'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-350-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-350-3', m.`id`, '2026-12-16 13:19:00', 99000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_039'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-350-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-350-4', m.`id`, '2026-12-16 17:32:00', 150000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_068'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-350-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-351-1', m.`id`, '2026-12-17 08:10:00', 210000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-351-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-351-2', m.`id`, '2026-12-17 12:23:00', 260000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_030'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-351-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-351-3', m.`id`, '2026-12-17 16:36:00', 930000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_059'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-351-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-351-4', m.`id`, '2026-12-17 20:49:00', 91000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_088'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-351-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-352-1', m.`id`, '2026-12-18 11:27:00', 353000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-352-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-352-2', m.`id`, '2026-12-18 15:40:00', 134000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_043'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-352-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-352-3', m.`id`, '2026-12-18 19:53:00', 184000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_072'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-352-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-352-4', m.`id`, '2026-12-18 09:06:00', 344000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_001'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-352-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-353-1', m.`id`, '2026-12-19 14:44:00', 226000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-353-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-353-2', m.`id`, '2026-12-19 18:57:00', 277000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_056'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-353-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-353-3', m.`id`, '2026-12-19 08:10:00', 327000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_085'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-353-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-353-4', m.`id`, '2026-12-19 12:23:00', 218000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_014'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-353-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-354-1', m.`id`, '2026-12-20 17:01:00', 100000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-354-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-354-2', m.`id`, '2026-12-20 21:14:00', 150000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_069'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-354-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-354-3', m.`id`, '2026-12-20 11:27:00', 201000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_098'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-354-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-354-4', m.`id`, '2026-12-20 15:40:00', 91000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_027'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-354-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-355-1', m.`id`, '2026-12-21 20:18:00', 243000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-355-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-355-2', m.`id`, '2026-12-21 10:31:00', 294000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_082'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-355-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-355-3', m.`id`, '2026-12-21 14:44:00', 184000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_011'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-355-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-355-4', m.`id`, '2026-12-21 18:57:00', 234000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_040'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-355-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-356-1', m.`id`, '2026-12-22 09:35:00', 117000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-356-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-356-2', m.`id`, '2026-12-22 13:48:00', 167000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_095'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-356-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-356-3', m.`id`, '2026-12-22 17:01:00', 328000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_024'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-356-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-356-4', m.`id`, '2026-12-22 21:14:00', 108000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_053'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-356-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-357-1', m.`id`, '2026-12-23 12:52:00', 260000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_079'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-357-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-357-2', m.`id`, '2026-12-23 16:05:00', 150000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_008'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-357-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-357-3', m.`id`, '2026-12-23 20:18:00', 201000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_037'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-357-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-357-4', m.`id`, '2026-12-23 10:31:00', 251000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_066'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-357-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-358-1', m.`id`, '2026-12-24 15:09:00', 201000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-358-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-358-2', m.`id`, '2026-12-24 19:22:00', 92000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_028'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-358-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-358-3', m.`id`, '2026-12-24 09:35:00', 142000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_057'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-358-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-358-4', m.`id`, '2026-12-24 13:48:00', 193000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_086'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-358-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-359-1', m.`id`, '2026-12-25 18:26:00', 185000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-359-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-359-2', m.`id`, '2026-12-25 08:39:00', 235000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_041'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-359-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-359-3', m.`id`, '2026-12-25 12:52:00', 286000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_070'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-359-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-359-4', m.`id`, '2026-12-25 16:05:00', 336000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_099'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-359-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-360-1', m.`id`, '2026-12-26 21:43:00', 328000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-360-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-360-2', m.`id`, '2026-12-26 11:56:00', 109000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_054'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-360-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-360-3', m.`id`, '2026-12-26 15:09:00', 159000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_083'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-360-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-360-4', m.`id`, '2026-12-26 19:22:00', 319000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_012'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-360-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-361-1', m.`id`, '2026-12-27 10:00:00', 202000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-361-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-361-2', m.`id`, '2026-12-27 14:13:00', 252000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_067'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-361-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-361-3', m.`id`, '2026-12-27 18:26:00', 906000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_096'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-361-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-361-4', m.`id`, '2026-12-27 08:39:00', 193000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_025'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-361-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-362-1', m.`id`, '2026-12-28 13:17:00', 345000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-362-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-362-2', m.`id`, '2026-12-28 17:30:00', 125000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_080'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-362-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-362-3', m.`id`, '2026-12-28 21:43:00', 286000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_009'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-362-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-362-4', m.`id`, '2026-12-28 11:56:00', 336000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_038'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-362-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-363-1', m.`id`, '2026-12-29 16:34:00', 218000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-363-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-363-2', m.`id`, '2026-12-29 20:47:00', 269000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_093'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-363-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-363-3', m.`id`, '2026-12-29 10:00:00', 159000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_022'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-363-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-363-4', m.`id`, '2026-12-29 14:13:00', 210000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_051'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-363-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-364-1', m.`id`, '2026-12-30 19:51:00', 92000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_077'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-364-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-364-2', m.`id`, '2026-12-30 09:04:00', 252000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_006'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-364-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-364-3', m.`id`, '2026-12-30 13:17:00', 303000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_035'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-364-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-364-4', m.`id`, '2026-12-30 17:30:00', 353000, 'PENDING', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_064'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-364-4');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-365-1', m.`id`, '2026-12-31 08:08:00', 303000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_097'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-365-1');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-365-2', m.`id`, '2026-12-31 12:21:00', 194000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_026'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-365-2');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-365-3', m.`id`, '2026-12-31 16:34:00', 244000, 'SUCCESS', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_055'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-365-3');
INSERT INTO `tblTransaction4` (`transactionCode`,`customerId`,`transactionTime`,`transactionValue`,`status`,`orderId`)
SELECT 'Y26-365-4', m.`id`, '2026-12-31 20:47:00', 294000, 'CANCELLED', NULL
FROM `tblMember4` m WHERE m.`userName`='demo_kh_084'
  AND NOT EXISTS (SELECT 1 FROM `tblTransaction4` t WHERE t.`transactionCode`='Y26-365-4');

-- CHECK COVERAGE: it must return 365 covered days, 1095 successful rows.
SELECT COUNT(DISTINCT DATE(transactionTime)) AS days_with_success,
       COUNT(*) AS successful_year_transactions,
       MIN(transactionTime) AS first_day,
       MAX(transactionTime) AS last_day
FROM tblTransaction4
WHERE transactionCode LIKE 'Y26-%' AND status='SUCCESS';

-- CHECK all transactions added by this file, excluding pre-existing non-demo data.
SELECT status, COUNT(*) AS transaction_count
FROM tblTransaction4 WHERE transactionCode LIKE 'Y26-%'
GROUP BY status;

-- CHECK daily coverage: should return ZERO rows.
SELECT days.day_value, COUNT(t.id) AS successes
FROM (SELECT DATE(transactionTime) AS day_value FROM tblTransaction4 WHERE transactionCode LIKE 'Y26-%' GROUP BY DATE(transactionTime)) days
LEFT JOIN tblTransaction4 t ON DATE(t.transactionTime)=days.day_value AND t.status='SUCCESS' AND t.transactionCode LIKE 'Y26-%'
GROUP BY days.day_value HAVING COUNT(t.id)<3;

COMMIT;

-- VALIDATION: expected 100 new demo customers, 400 new demo transactions.
SELECT COUNT(*) AS demo_customers FROM `tblMember4` WHERE `userName` LIKE 'demo\_kh\_%';
SELECT `status`, COUNT(*) AS demo_transactions, SUM(`transactionValue`) AS total_value
FROM `tblTransaction4` WHERE `transactionCode` LIKE 'DEMO-GD-%' GROUP BY `status`;
SELECT MIN(`transactionTime`) AS first_tx, MAX(`transactionTime`) AS last_tx
FROM `tblTransaction4` WHERE `transactionCode` LIKE 'DEMO-GD-%';

-- Demo: manager_demo / Demo@12345 -> View Customer Statistics -> 2026-06-01 to 2026-06-30

-- ADDITIONAL VALIDATION QUERIES
SELECT COUNT(*) AS test_accounts FROM tblMember4
 WHERE userName REGEXP '^customer_test_(0[1-9]|10)$';
SELECT COUNT(*) AS test_customer_profiles FROM tblCustomer4 c
 JOIN tblMember4 m ON m.id=c.tblMember4id
 WHERE m.userName REGEXP '^customer_test_(0[1-9]|10)$';
SELECT COUNT(*) AS original_transactions FROM tblTransaction4
 WHERE transactionCode IN ('GD0001','GD0002','GD0003');
