CREATE DATABASE IF NOT EXISTS OnlineSupermarketDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE OnlineSupermarketDB;

CREATE TABLE IF NOT EXISTS tblMember4 (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  userName VARCHAR(100) NOT NULL UNIQUE,
  passwordHash VARCHAR(255) NOT NULL,
  fullName VARCHAR(150) NOT NULL,
  dateOfBirth DATE NOT NULL,
  address VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phoneNumber VARCHAR(20) NOT NULL,
  role VARCHAR(30) NOT NULL
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS tblCustomer4 (
  tblMember4id BIGINT PRIMARY KEY,
  customerCode VARCHAR(30) NOT NULL UNIQUE,
  memberStatus BOOLEAN NOT NULL DEFAULT FALSE,
  registrationDate DATE NULL,
  CONSTRAINT fk_customer_member FOREIGN KEY(tblMember4id) REFERENCES tblMember4(id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS tblStaff4 (
  tblMember4id BIGINT PRIMARY KEY,staffCode VARCHAR(30) NOT NULL UNIQUE,
  CONSTRAINT fk_staff_member FOREIGN KEY(tblMember4id) REFERENCES tblMember4(id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS tblManagementStaff4 (
  tblStaff4id BIGINT PRIMARY KEY,
  CONSTRAINT fk_management_staff FOREIGN KEY(tblStaff4id) REFERENCES tblStaff4(tblMember4id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS tblWarehouseStaff4 (
  tblStaff4id BIGINT PRIMARY KEY,
  CONSTRAINT fk_warehouse_staff FOREIGN KEY(tblStaff4id) REFERENCES tblStaff4(tblMember4id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS tblSalesStaff4 (
  tblStaff4id BIGINT PRIMARY KEY,
  CONSTRAINT fk_sales_staff FOREIGN KEY(tblStaff4id) REFERENCES tblStaff4(tblMember4id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS tblDeliveryStaff4 (
  tblStaff4id BIGINT PRIMARY KEY,
  CONSTRAINT fk_delivery_staff FOREIGN KEY(tblStaff4id) REFERENCES tblStaff4(tblMember4id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS tblSupplier4 (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,supplierCode VARCHAR(30) NOT NULL UNIQUE,
  supplierName VARCHAR(150) NOT NULL,address VARCHAR(255) NOT NULL,
  email VARCHAR(255) NULL,phoneNumber VARCHAR(20) NOT NULL
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS tblItem4 (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,itemCode VARCHAR(30) NOT NULL UNIQUE,
  itemName VARCHAR(150) NOT NULL,description TEXT NULL,
  unitPrice DECIMAL(18,2) NOT NULL,stockQuantity INT NOT NULL DEFAULT 0,
  CONSTRAINT chk_item_price CHECK(unitPrice>=0),CONSTRAINT chk_item_stock CHECK(stockQuantity>=0)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS tblImportBatch4 (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,supplierId BIGINT NOT NULL,
  warehouseStaffId BIGINT NOT NULL,itemId BIGINT NOT NULL,
  importDate DATE NOT NULL,quantity INT NOT NULL,unitPrice DECIMAL(18,2) NOT NULL,
  FOREIGN KEY(supplierId) REFERENCES tblSupplier4(id),
  FOREIGN KEY(warehouseStaffId) REFERENCES tblWarehouseStaff4(tblStaff4id),
  FOREIGN KEY(itemId) REFERENCES tblItem4(id),
  CONSTRAINT chk_import_quantity CHECK(quantity>0),CONSTRAINT chk_import_price CHECK(unitPrice>=0)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS tblOrder4 (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,orderCode VARCHAR(30) NOT NULL UNIQUE,
  customerId BIGINT NOT NULL,orderDate DATETIME NOT NULL,orderStatus VARCHAR(30) NOT NULL,
  FOREIGN KEY(customerId) REFERENCES tblCustomer4(tblMember4id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS tblOnlineOrder4 (
  orderId BIGINT PRIMARY KEY,processingStatus VARCHAR(30) NOT NULL,
  deliveryStaffId BIGINT NULL,
  FOREIGN KEY(orderId) REFERENCES tblOrder4(id),
  FOREIGN KEY(deliveryStaffId) REFERENCES tblDeliveryStaff4(tblStaff4id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS tblOrderDetail4 (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,orderId BIGINT NOT NULL,itemId BIGINT NOT NULL,
  quantity INT NOT NULL,unitPrice DECIMAL(18,2) NOT NULL,
  FOREIGN KEY(orderId) REFERENCES tblOrder4(id),FOREIGN KEY(itemId) REFERENCES tblItem4(id),
  CONSTRAINT chk_order_detail_quantity CHECK(quantity>0),CONSTRAINT chk_order_detail_price CHECK(unitPrice>=0)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS tblTransaction4 (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,transactionCode VARCHAR(30) NOT NULL UNIQUE,
  customerId BIGINT NOT NULL,transactionTime DATETIME NOT NULL,
  transactionValue DECIMAL(18,2) NOT NULL,status VARCHAR(30) NOT NULL,
  orderId BIGINT NULL,
  FOREIGN KEY(customerId) REFERENCES tblCustomer4(tblMember4id),
  FOREIGN KEY(orderId) REFERENCES tblOrder4(id),
  CONSTRAINT chk_transaction_value CHECK(transactionValue>=0),
  INDEX idx_tx_customer_period_status(customerId,transactionTime,status),
  INDEX idx_tx_period_status(transactionTime,status)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS tblTransactionDetail4 (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,transactionId BIGINT NOT NULL,itemId BIGINT NOT NULL,
  quantity INT NOT NULL,unitPrice DECIMAL(18,2) NOT NULL,
  FOREIGN KEY(transactionId) REFERENCES tblTransaction4(id),
  FOREIGN KEY(itemId) REFERENCES tblItem4(id),
  CONSTRAINT chk_tx_detail_quantity CHECK(quantity>0),CONSTRAINT chk_tx_detail_price CHECK(unitPrice>=0)
) ENGINE=InnoDB;
