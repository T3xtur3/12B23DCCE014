
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chọn loại thống kê - OnlineSupermarket</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
</head>
<body>
<main class="panel home-panel">
    <h1 class="page-title">CHỌN LOẠI THỐNG KÊ</h1>

    <nav class="menu-list" aria-label="Các loại thống kê">
        <a class="menu-item is-primary"
           href="${pageContext.request.contextPath}/statistics/period">
            Thống kê khách hàng theo doanh thu
        </a>

        <div class="menu-item is-disabled">
            Thống kê hàng hóa (chưa triển khai)
        </div>

        <div class="menu-item is-disabled">
            Thống kê nhà cung cấp (chưa triển khai)
        </div>

        <div class="menu-item is-disabled">
            Thống kê doanh thu (chưa triển khai)
        </div>
    </nav>

    <div class="menu-bottom">
        <a class="btn btn-secondary"
           href="${pageContext.request.contextPath}/home">
            Quay lại
        </a>
    </div>
</main>
</body>
</html>
