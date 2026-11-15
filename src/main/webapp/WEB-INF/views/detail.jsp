
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chi tiết khách hàng - OnlineSupermarket</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
</head>
<body>
<main class="panel form-panel">
    <h1 class="page-title">CHI TIẾT KHÁCH HÀNG</h1>

    <dl class="details">
        <dt>Mã khách hàng</dt>
        <dd><c:out value="${customer.customerCode}"/></dd>

        <dt>Họ tên</dt>
        <dd><c:out value="${customer.fullName}"/></dd>

        <dt>Địa chỉ</dt>
        <dd><c:out value="${customer.address}"/></dd>

        <dt>Email</dt>
        <dd><c:out value="${customer.email}"/></dd>

        <dt>Số điện thoại</dt>
        <dd><c:out value="${customer.phoneNumber}"/></dd>

        <dt>Doanh thu trong kỳ</dt>
        <dd class="money">
            <fmt:formatNumber
                    value="${selectedStatistics.totalRevenue}"
                    type="number"
                    maxFractionDigits="0"/> ₫
        </dd>
    </dl>

    <c:url var="transLink" value="/statistics/transactions">
        <c:param name="customerId" value="${customer.id}"/>
        <c:param name="startDate" value="${startDate}"/>
        <c:param name="endDate" value="${endDate}"/>
    </c:url>

    <c:url var="backLink" value="/statistics/customers">
        <c:param name="startDate" value="${startDate}"/>
        <c:param name="endDate" value="${endDate}"/>
    </c:url>

    <div class="form-actions">
        <a class="btn btn-secondary"
           href="<c:out value='${backLink}'/>">
            Quay lại
        </a>

        <a class="btn"
           href="<c:out value='${transLink}'/>">
            Xem giao dịch liên quan
        </a>

        <a class="btn btn-secondary"
           href="${pageContext.request.contextPath}/home">
            Về giao diện chính
        </a>
    </div>
</main>
</body>
</html>
