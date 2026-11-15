# ONLINE SUPERMARKET MANAGEMENT SYSTEM

**Hệ thống quản lý siêu thị trực tuyến**

Dự án bài tập lớn học phần **Phân tích và Thiết kế Hệ thống Thông tin**, xây dựng ứng dụng Java Web nhằm minh họa quá trình chuyển đổi từ đặc tả yêu cầu, phân tích, thiết kế sang lập trình và kiểm thử phần mềm.

Ứng dụng tập trung triển khai hai module nghiệp vụ:

- **Register Member 4** – Đăng ký thành viên.
- **View Customer Statistics 4** – Xem thống kê khách hàng.

## 1. Giới thiệu dự án

Online Supermarket Management System là hệ thống hỗ trợ các hoạt động quản lý siêu thị trực tuyến, bao gồm thông tin khách hàng, tài khoản thành viên, hàng hóa, giao dịch và thống kê.

Trong phạm vi bài tập lớn, dự án tập trung hiện thực hai chức năng chính: đăng ký thành viên cho khách hàng và thống kê doanh thu khách hàng theo khoảng thời gian.

Hệ thống sử dụng kiến trúc Java Web, kết hợp JSP, Servlet, DAO, Model và cơ sở dữ liệu MariaDB. Ứng dụng chạy cục bộ trên Apache Tomcat, chưa triển khai lên máy chủ công khai.

## 2. Các chức năng đã triển khai

### 2.1. Đăng nhập và phân quyền

- Đăng nhập bằng tài khoản đã tồn tại trong cơ sở dữ liệu.
- Xác thực thông tin đăng nhập.
- Phân quyền giao diện theo vai trò Customer hoặc Management Staff.
- Quản lý phiên đăng nhập.
- Đăng xuất khỏi hệ thống.

### 2.2. Module Register Member 4

**Tác nhân:** Customer – Khách hàng.

Chức năng cho phép khách hàng đã có tài khoản đăng ký trở thành thành viên của siêu thị.

Quy trình:

1. Khách hàng đăng nhập vào hệ thống.
2. Chọn chức năng **Đăng ký thành viên**.
3. Hệ thống hiển thị biểu mẫu đăng ký.
4. Khách hàng nhập họ tên, ngày sinh, địa chỉ, email và số điện thoại.
5. Hệ thống kiểm tra tính hợp lệ của thông tin và trạng thái đăng ký hiện tại.
6. Khách hàng xem lại thông tin và xác nhận đăng ký.
7. Hệ thống cập nhật thông tin khách hàng và trạng thái thành viên trong cơ sở dữ liệu.
8. Hiển thị kết quả đăng ký.

**Quy tắc nghiệp vụ:**

- Khách hàng phải đăng nhập trước khi đăng ký.
- Mỗi khách hàng chỉ được đăng ký thành viên một lần.
- Không tạo tài khoản Member4 mới khi đăng ký.
- Trạng thái `memberStatus` được cập nhật từ `0` sang `1` sau khi đăng ký thành công.
- `registrationDate` ghi nhận ngày đăng ký.
- Hệ thống từ chối đăng ký lại đối với khách hàng đã là thành viên.

### 2.3. Module View Customer Statistics 4

**Tác nhân:** Management Staff – Nhân viên quản lý.

Chức năng cho phép nhân viên quản lý theo dõi doanh thu phát sinh từ các khách hàng trong khoảng thời gian xác định.

Quy trình:

1. Nhân viên quản lý đăng nhập vào hệ thống.
2. Chọn chức năng **Xem thống kê**.
3. Chọn **Thống kê khách hàng theo doanh thu**.
4. Nhập ngày bắt đầu và ngày kết thúc.
5. Hệ thống truy vấn và tổng hợp doanh thu khách hàng.
6. Hiển thị danh sách thống kê theo doanh thu giảm dần.
7. Chọn một khách hàng để xem thông tin chi tiết.
8. Xem danh sách các giao dịch hợp lệ liên quan đến khách hàng đó trong kỳ thống kê.

**Nguyên tắc thống kê:**

- Chỉ tính giao dịch có trạng thái hợp lệ (`SUCCESS`).
- Thời gian thống kê bao gồm cả ngày bắt đầu và ngày kết thúc.
- Doanh thu khách hàng là tổng giá trị các giao dịch hợp lệ trong khoảng thời gian được chọn.
- Không lưu kết quả thống kê thành một bảng riêng.
- Có xử lý trường hợp khoảng thời gian không hợp lệ hoặc không có dữ liệu.

## 3. Công nghệ sử dụng

| Thành phần | Công nghệ |
|---|---|
| Ngôn ngữ lập trình | Java 21 |
| Giao diện | JSP, HTML5, CSS3 |
| Backend | Jakarta Servlet 6.0 |
| JSP/JSTL | JSP 3.1, JSTL 3.0 |
| Kiến trúc | JSP – Servlet – DAO – Model |
| Build Tool | Apache Maven |
| Application Server | Apache Tomcat 10.1 |
| Cơ sở dữ liệu | MariaDB / MySQL (XAMPP) |
| JDBC Driver | MariaDB Connector/J 3.5.11 |
| IDE | IntelliJ IDEA |
| Quản lý mã nguồn | Git và GitHub |

## 4. Cấu trúc dự án

```text
OnlineSupermarket/
│
├── database/
│   ├── 01_schema.sql
│   └── 02_demo_seed.sql
│
├── src/
│   └── main/
│       ├── java/
│       │   └── com/supermarket/
│       │       ├── config/
│       │       ├── dao/
│       │       ├── model/
│       │       └── web/
│       │
│       └── webapp/
│           ├── assets/
│           │   └── style.css
│           │
│           ├── WEB-INF/
│           │   └── views/
│           │       ├── login.jsp
│           │       ├── home.jsp
│           │       ├── register.jsp
│           │       ├── confirm.jsp
│           │       ├── result.jsp
│           │       ├── types.jsp
│           │       ├── period.jsp
│           │       ├── statistics.jsp
│           │       ├── detail.jsp
│           │       └── transactions.jsp
│           │
│           └── index.jsp
│
├── .gitignore
├── pom.xml
└── README.md
```

Các thành phần chính:

- `config`: Cấu hình kết nối cơ sở dữ liệu.
- `dao`: Các lớp truy xuất và xử lý dữ liệu từ MariaDB.
- `model`: Các lớp đối tượng và dữ liệu nghiệp vụ.
- `web`: Các Servlet xử lý HTTP request, response và điều hướng.
- `views`: Các trang JSP hiển thị giao diện.
- `assets`: CSS dùng chung.
- `database`: Các file SQL tạo bảng và dữ liệu demo.

## 5. Hướng dẫn cài đặt

### 5.1. Yêu cầu môi trường

Máy tính cần cài đặt:

- JDK 21 trở lên, tương thích với mã nguồn Java 21.
- Apache Maven.
- Apache Tomcat 10.1.
- XAMPP có MySQL/MariaDB.
- IntelliJ IDEA hoặc IDE hỗ trợ Java Web.
- Git (nếu clone từ GitHub).

### 5.2. Clone repository

Mở Terminal và chạy:

```bash
git clone https://github.com/T3xtur3/OnlineSupermarket.git
cd OnlineSupermarket
```

Mở thư mục dự án bằng IntelliJ IDEA, sau đó thực hiện Maven Reload để tải dependency.

### 5.3. Khởi tạo cơ sở dữ liệu

1. Khởi động MySQL trong XAMPP Control Panel.
2. Truy cập `http://localhost/phpmyadmin`.
3. Chọn chức năng Import.
4. Import các file SQL theo thứ tự:

```text
database/01_schema.sql
database/02_demo_seed.sql
```

Cơ sở dữ liệu của dự án gồm **15 bảng**, chứa thông tin thành viên, khách hàng, nhân viên, hàng hóa, đơn hàng và giao dịch.

Tên database sử dụng khi chạy trên môi trường Windows hiện tại:

```text
onlinesupermarketdb
```

Lưu ý: Tên database trong các file SQL có thể khác về chữ hoa và chữ thường. Khi triển khai trên hệ điều hành có phân biệt chữ hoa/chữ thường, cần sử dụng tên thống nhất.

### 5.4. Cấu hình tài khoản MariaDB

Trong phpMyAdmin, sử dụng tài khoản có quyền quản trị để chạy:

```sql
CREATE USER IF NOT EXISTS
'supermarket_app'@'localhost'
IDENTIFIED BY 'YOUR_STRONG_PASSWORD';

GRANT SELECT, INSERT, UPDATE, DELETE
ON onlinesupermarketdb.*
TO 'supermarket_app'@'localhost';
```

Nếu tài khoản đã tồn tại, cần đảm bảo mật khẩu và quyền truy cập khớp với cấu hình ứng dụng.

Không đưa mật khẩu MariaDB thực tế vào repository.

### 5.5. Cấu hình kết nối JDBC

Ứng dụng đọc cấu hình từ các biến môi trường:

```text
DB_URL
DB_USER
DB_PASSWORD
```

Ví dụ trên PowerShell:

```powershell
$env:DB_URL = "jdbc:mariadb://127.0.0.1:3306/onlinesupermarketdb"
$env:DB_USER = "supermarket_app"
$env:DB_PASSWORD = "YOUR_STRONG_PASSWORD"
```

Thay `YOUR_STRONG_PASSWORD` bằng mật khẩu đã thiết lập trong MariaDB.

Các biến này phải được khai báo trong môi trường khởi động Tomcat.

## 6. Build và chạy ứng dụng

### 6.1. Build Maven

Tại thư mục gốc dự án, chạy:

```powershell
mvn clean package
```

Hoặc trong IntelliJ IDEA, chọn:

```text
Maven → Lifecycle → clean → package
```

Sau khi build thành công, file WAR nằm tại:

```text
target/OnlineSupermarket.war
```

### 6.2. Triển khai trên Tomcat

Copy file WAR vào thư mục:

```text
<TOMCAT_HOME>/webapps/
```

Ví dụ đường dẫn cài đặt cục bộ:

```text
D:\PTTK\apache-tomcat-10.1.61\webapps\
```

### 6.3. Khởi động Tomcat

Trên máy đã cấu hình Tomcat sử dụng cổng 8081, mở PowerShell:

```powershell
cd "D:\PTTK\apache-tomcat-10.1.61\bin"

$env:JAVA_HOME = "C:\Program Files\Java\jdk-24"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

$env:DB_URL = "jdbc:mariadb://127.0.0.1:3306/onlinesupermarketdb"
$env:DB_USER = "supermarket_app"
$env:DB_PASSWORD = "YOUR_STRONG_PASSWORD"

.\catalina.bat run
```

Đường dẫn Java và Tomcat cần thay đổi tương ứng với máy cài đặt.

Sau khi Tomcat khởi động thành công, truy cập:

```text
http://localhost:8081/OnlineSupermarket/login
```

Nếu sử dụng cấu hình Tomcat mặc định, cổng có thể là `8080`.

## 7. Tài khoản demo

Dữ liệu mẫu ban đầu cung cấp hai tài khoản để kiểm thử:

| Vai trò | Username | Password |
|---|---|---|
| Customer | `customer_demo` | `Demo@12345` |
| Management Staff | `manager_demo` | `Demo@12345` |

Các tài khoản này chỉ dành cho môi trường demo cục bộ, không sử dụng trong môi trường production.

Trạng thái đăng ký thành viên của `customer_demo` có thể thay đổi sau khi thực hiện kiểm thử.

## 8. Hướng dẫn kiểm thử hai module

### 8.1. Kiểm thử Register Member 4

**Trường hợp đăng ký thành công:**

1. Đăng nhập bằng tài khoản khách hàng chưa đăng ký thành viên.
2. Chọn chức năng Đăng ký thành viên.
3. Nhập đầy đủ thông tin hợp lệ.
4. Nhấn Tiếp tục.
5. Kiểm tra thông tin trên giao diện xác nhận.
6. Nhấn Xác nhận.
7. Kiểm tra thông báo thành công.

**Trường hợp đăng ký trùng:**

1. Đăng nhập bằng tài khoản đã đăng ký.
2. Mở chức năng Đăng ký thành viên.
3. Kiểm tra thông báo đã đăng ký.
4. Xác nhận hệ thống không cho phép tiếp tục đăng ký lần thứ hai.

Có thể kiểm tra trạng thái thành viên bằng câu SQL:

```sql
SELECT
    m.userName,
    c.memberStatus,
    c.registrationDate
FROM tblmember4 m
JOIN tblcustomer4 c
    ON c.tblMember4id = m.id
WHERE m.userName = 'customer_demo';
```

Để đặt lại trạng thái tài khoản demo trong môi trường kiểm thử:

```sql
UPDATE tblcustomer4 c
JOIN tblmember4 m
    ON c.tblMember4id = m.id
SET
    c.memberStatus = 0,
    c.registrationDate = NULL
WHERE m.userName = 'customer_demo';
```

Không sử dụng thao tác đặt lại này trên dữ liệu khách hàng thực tế.

### 8.2. Kiểm thử View Customer Statistics 4

1. Đăng nhập bằng tài khoản `manager_demo`.
2. Chọn Xem thống kê.
3. Chọn Thống kê khách hàng theo doanh thu.
4. Nhập khoảng thời gian.
5. Xem danh sách thống kê.
6. Chọn mã khách hàng.
7. Xem chi tiết khách hàng.
8. Xem các giao dịch liên quan.

Ví dụ kiểm thử bằng dữ liệu mẫu tháng 6:

```text
Ngày bắt đầu: 2026-06-01
Ngày kết thúc: 2026-06-30
```

Nếu đã import bộ dữ liệu demo mở rộng của năm 2026, có thể kiểm thử theo từng ngày, tháng hoặc toàn năm.

Các bộ dữ liệu SQL mở rộng cần được import riêng nếu chưa nằm trong repository.

Để kiểm tra khoảng thời gian có giao dịch:

```sql
SELECT
    MIN(transactionTime) AS firstTransaction,
    MAX(transactionTime) AS lastTransaction,
    COUNT(*) AS totalTransactions
FROM tbltransaction4;
```

Kiểm tra giao dịch thành công:

```sql
SELECT
    transactionCode,
    customerId,
    transactionTime,
    transactionValue,
    status
FROM tbltransaction4
WHERE status = 'SUCCESS'
ORDER BY transactionTime;
```

## 9. Một số lỗi thường gặp

| Lỗi | Nguyên nhân và hướng xử lý |
|---|---|
| `No suitable driver found` | Kiểm tra MariaDB JDBC Driver trong dependency Maven và file WAR |
| `Access denied for user` | Kiểm tra tài khoản, mật khẩu và quyền MariaDB |
| `Connection refused` | Kiểm tra MariaDB đang chạy và cổng 3306 |
| `Address already in use` | Cổng Tomcat đang bị ứng dụng khác sử dụng |
| HTTP 404 | Kiểm tra tên WAR, đường dẫn truy cập và trạng thái triển khai Tomcat |
| Không có kết quả thống kê | Kiểm tra khoảng thời gian, trạng thái giao dịch và dữ liệu trong bảng |
| Không thể đăng ký thành viên | Kiểm tra `memberStatus` của khách hàng đang đăng nhập |

## 10. Phạm vi và giới hạn

Dự án tập trung vào hai module đã lựa chọn trong bài tập lớn.

**Các chức năng đã triển khai:**

- Đăng nhập, đăng xuất và phân quyền.
- Đăng ký thành viên.
- Kiểm tra trạng thái đăng ký.
- Xem thống kê khách hàng theo doanh thu.
- Xem chi tiết khách hàng.
- Xem giao dịch liên quan.

**Các chức năng chưa triển khai đầy đủ:**

- Quản lý hàng hóa.
- Quản lý kho.
- Quản lý nhập hàng.
- Quản lý đơn hàng và bán hàng.
- Giao hàng.
- Các loại thống kê khác.

Ứng dụng hiện được xây dựng nhằm phục vụ học tập, kiểm thử và báo cáo học phần; chưa phải hệ thống thương mại điện tử hoàn chỉnh để sử dụng trong môi trường thực tế.

## 11. Tài liệu và phương pháp thực hiện

Quá trình thực hiện dự án gồm bốn giai đoạn:

1. **Đặc tả:** Xác định yêu cầu, đối tượng nghiệp vụ, các chức năng và kịch bản sử dụng.
2. **Phân tích:** Phân tích tĩnh, xây dựng sơ đồ lớp phân tích, kịch bản tương tác và biểu đồ giao tiếp.
3. **Thiết kế:** Thiết kế lớp, cơ sở dữ liệu, giao diện, biểu đồ hoạt động, tuần tự, gói và triển khai.
4. **Lập trình:** Xây dựng ứng dụng Java Web, tích hợp MariaDB, tạo dữ liệu mẫu và kiểm thử.

Phương pháp phân tích và thiết kế được thực hiện dựa trên giáo trình của học phần Phân tích và Thiết kế Hệ thống Thông tin.

## 12. Repository

**Source code:** https://github.com/T3xtur3/OnlineSupermarket

**Nhánh chính:** `main`

**Trạng thái:** Bản demo cục bộ phục vụ bài tập lớn.

---

**Online Supermarket Management System – Software Analysis and Design Project – 2026**
