-- ONLY FOR LOCAL DEVELOPMENT: demo password Demo@12345 for both accounts.
-- Safe for repeat import by checking username. Do not import in production.
USE OnlineSupermarketDB;
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
