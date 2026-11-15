
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Giao dịch liên quan - OnlineSupermarket</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
</head>
<body>
<main class="panel wide">
    <h1 class="page-title">DANH SÁCH GIAO DỊCH LIÊN QUAN</h1>

    <div class="info-strip">
        <span>
            Khách hàng:
            <strong>
                <c:out value="${customer.customerCode}"/>
                —
                <c:out value="${customer.fullName}"/>
            </strong>
        </span>

        <span>
            Từ ngày
            <strong><c:out value="${startDate}"/></strong>
            đến
            <strong><c:out value="${endDate}"/></strong>
        </span>
    </div>

    <h2 class="section-title">
        Các giao dịch trong khoảng thời gian đã chọn
    </h2>

    <div class="table-wrap">
        <table class="data-table">
            <thead>
            <tr>
                <th class="index">STT</th>
                <th>Mã giao dịch</th>
                <th>Thời gian</th>
                <th class="amount">Giá trị giao dịch</th>
            </tr>
            </thead>

            <tbody>
            <c:forEach var="t" items="${transactions}" varStatus="i">
                <tr>
                    <td class="index">${i.index + 1}</td>

                    <td>
                        <c:out value="${t.transactionCode}"/>
                    </td>

                    <td>
                        <c:out value="${t.transactionTime}"/>
                    </td>

                    <td class="amount">
                        <fmt:formatNumber
                                value="${t.transactionValue}"
                                type="number"
                                maxFractionDigits="0"/> ₫
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>

    <c:if test="${empty transactions}">
        <p class="empty-state">
            Không có giao dịch liên quan trong kỳ.
        </p>
    </c:if>

    <c:url var="backLink" value="/statistics/customer">
        <c:param name="customerId" value="${customer.id}"/>
        <c:param name="startDate" value="${startDate}"/>
        <c:param name="endDate" value="${endDate}"/>
    </c:url>

    <div class="form-actions">
        <a class="btn btn-secondary"
           href="<c:out value='${backLink}'/>">
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
