# OnlineSupermarket – Đề 12 (Java Web / XAMPP)

Project Java 21 / Maven WAR, Tomcat 10.1, Jakarta Servlet 6.0, JSP 3.1, MariaDB Connector/J 3.5.11.

## Phạm vi đã có mã nguồn
- Login / Logout, phân quyền CUSTOMER / MANAGEMENT.
- Register Member 4: getCustomerById → validateCustomerInformation → isRegisteredMember → Confirm → registerMember. Không tạo Member4 mới; giao dịch CSDL dùng transaction.
- View Customer Statistics 4: chọn loại thống kê → chọn kỳ → danh sách doanh thu → chi tiết khách hàng → giao dịch hợp lệ cùng kỳ.
- Database 15 bảng theo Hình 11, seed minh họa 2 tài khoản và 3 giao dịch (trong đó giao dịch CANCELLED không tính doanh thu).

Các chức năng CRUD kho, bán hàng, đặt hàng, giao hàng, tìm kiếm mặt hàng chưa được code ở phiên bản đầu.

## 1. Chuẩn bị trên Windows
- JDK 21, Maven 3.9+, Apache Tomcat 10.1, IntelliJ IDEA, XAMPP (bật MySQL/MariaDB).
- Mở phpMyAdmin tại http://localhost/phpmyadmin (nếu Apache XAMPP chạy), chọn Import để nhập lần lượt:
  1. `database/01_schema.sql`
  2. `database/02_demo_seed.sql` (chỉ dùng demo)
- Nếu phpMyAdmin đang ở DB khác, các file có `USE OnlineSupermarketDB` và schema tạo DB.

## 2. Tạo user MariaDB để ứng dụng truy cập
Trong phpMyAdmin tab SQL, chạy (đổi `YOUR_STRONG_PASSWORD` thành mật khẩu riêng):
```sql
CREATE USER IF NOT EXISTS 'supermarket_app'@'localhost' IDENTIFIED BY 'YOUR_STRONG_PASSWORD';
GRANT SELECT, INSERT, UPDATE, DELETE ON OnlineSupermarketDB.* TO 'supermarket_app'@'localhost';
FLUSH PRIVILEGES;
```
Nếu kết nối bằng địa chỉ 127.0.0.1 khác host, tạo quyền host tương ứng, hoặc đổi DB_URL cho khớp host.

## 3. Cấu hình biến môi trường (PowerShell)
```powershell
$env:DB_URL = 'jdbc:mariadb://localhost:3306/OnlineSupermarketDB'
$env:DB_USER = 'supermarket_app'
$env:DB_PASSWORD = 'YOUR_STRONG_PASSWORD'
```
Lưu ý: nếu IntelliJ/Tomcat được chạy từ ứng dụng khác, cần đặt các biến này trong **Run Configuration** của Tomcat; đặt trong PowerShell không tự truyền vào ứng dụng IntelliJ đang mở.

## 4. Đóng gói và chạy
```powershell
cd OnlineSupermarket
mvn clean package
```
File WAR: `target/OnlineSupermarket.war`. Sao chép WAR vào `<TOMCAT_HOME>\webapps\` rồi chạy Tomcat bằng `bin\startup.bat` (hoặc cấu hình Tomcat Local trong IntelliJ Ultimate). Trang đăng nhập:

`http://localhost:8080/OnlineSupermarket/login`

**Tài khoản demo (chỉ dùng local):**
- Customer: `customer_demo` / `Demo@12345`
- Management: `manager_demo` / `Demo@12345`

**Kiểm thử Module 1**: Đăng nhập customer → Đăng ký thành viên → form có sẵn hồ sơ → Tiếp tục → Xác nhận → trạng thái `tblCustomer4.memberStatus=1` và `registrationDate` được cập nhật. Đăng ký lại phải bị chặn.

**Kiểm thử Module 2**: Đăng nhập manager → Xem thống kê → Thống kê khách hàng → chọn 2026-06-01 tới 2026-06-30 → KH001 tổng doanh thu 12,500,000 (GD0001 + GD0002), không tính GD0003 CANCELLED → nhấn KH001 → xem chi tiết → xem giao dịch liên quan.

## Một số lưu ý
- Trên Tomcat 10.1 phải import `jakarta.servlet.*`, không dùng `javax.servlet.*`.
- Nếu XAMPP dùng port khác 3306, sửa DB_URL.
- Hai module chỉ dùng dữ liệu mẫu phục vụ demo, không tự khởi tạo dữ liệu sản xuất.
- Kết nối demo local TCP không mã hóa; trước khi deploy thật phải cấu hình TLS và quản lý bí mật bằng môi trường / secret manager.
- Chưa có JUnit/integration test, chưa xác minh toàn bộ trên máy Windows của bạn; cần build và chạy để kiểm thử thực tế.
