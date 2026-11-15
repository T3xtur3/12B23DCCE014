
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Danh sách thống kê khách hàng - OnlineSupermarket</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
</head>
<body>
<main class="panel wide">
    <h1 class="page-title">DANH SÁCH THỐNG KÊ KHÁCH HÀNG</h1>

    <div class="info-strip">
        <span>
            Ngày bắt đầu:
            <strong><c:out value="${startDate}"/></strong>
        </span>

        <span>
            Ngày kết thúc:
            <strong><c:out value="${endDate}"/></strong>
        </span>
    </div>

    <h2 class="section-title">
        Danh sách khách hàng theo doanh thu
    </h2>

    <c:choose>
        <c:when test="${empty statistics}">
            <p class="empty-state">
                Không có dữ liệu thống kê trong kỳ.
            </p>
        </c:when>

        <c:otherwise>
            <div class="table-wrap">
                <table class="data-table">
                    <thead>
                    <tr>
                        <th class="index">STT</th>
                        <th>Mã khách hàng</th>
                        <th>Họ tên</th>
                        <th>Số điện thoại</th>
                        <th class="amount">Tổng doanh thu</th>
                    </tr>
                    </thead>

                    <tbody>
                    <c:forEach var="s" items="${statistics}" varStatus="i">
                        <c:url var="detailLink" value="/statistics/customer">
                            <c:param name="customerId" value="${s.customer.id}"/>
                            <c:param name="startDate" value="${startDate}"/>
                            <c:param name="endDate" value="${endDate}"/>
                        </c:url>

                        <tr>
                            <td class="index">${i.index + 1}</td>

                            <td>
                                <a href="<c:out value='${detailLink}'/>">
                                    <c:out value="${s.customer.customerCode}"/>
                                </a>
                            </td>

                            <td>
                                <c:out value="${s.customer.fullName}"/>
                            </td>

                            <td>
                                <c:out value="${s.customer.phoneNumber}"/>
                            </td>

                            <td class="amount">
                                <fmt:formatNumber
                                        value="${s.totalRevenue}"
                                        type="number"
                                        maxFractionDigits="0"/> ₫
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:otherwise>
    </c:choose>

    <div class="form-actions">
        <a class="btn btn-secondary"
           href="${pageContext.request.contextPath}/statistics/period">
            Quay lại
        </a>

        <a class="btn"
           href="${pageContext.request.contextPath}/home">
            Về giao diện chính
        </a>
    </div>
</main>
</body>
</html>
