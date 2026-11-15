
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Trang chính - OnlineSupermarket</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
</head>
<body>
<main class="panel home-panel">
    <h1 class="page-title">ONLINE SUPERMARKET</h1>

    <c:choose>
        <c:when test="${sessionScope.role eq 'CUSTOMER'}">
            <h2>GIAO DIỆN CHÍNH CỦA KHÁCH HÀNG</h2>

            <nav class="menu-list" aria-label="Chức năng khách hàng">
                <a class="menu-item is-primary"
                   href="${pageContext.request.contextPath}/member/register">
                    Đăng ký thành viên
                </a>

                <a class="menu-item"
                   href="${pageContext.request.contextPath}/logout">
                    Đăng xuất
                </a>
            </nav>
        </c:when>

        <c:when test="${sessionScope.role eq 'MANAGEMENT'}">
            <h2>GIAO DIỆN CHÍNH CỦA NHÂN VIÊN QUẢN LÝ</h2>

            <nav class="menu-list" aria-label="Chức năng quản lý">
                <a class="menu-item is-primary"
                   href="${pageContext.request.contextPath}/statistics/types">
                    Xem thống kê
                </a>

                <a class="menu-item"
                   href="${pageContext.request.contextPath}/logout">
                    Đăng xuất
                </a>
            </nav>
        </c:when>

        <c:otherwise>
            <p class="page-subtitle">
                Chức năng của vai trò này nằm ngoài hai module
                triển khai hiện tại.
            </p>

            <div class="menu-bottom">
                <a class="btn btn-secondary"
                   href="${pageContext.request.contextPath}/logout">
                    Đăng xuất
                </a>
            </div>
        </c:otherwise>
    </c:choose>
</main>
</body>
</html>
