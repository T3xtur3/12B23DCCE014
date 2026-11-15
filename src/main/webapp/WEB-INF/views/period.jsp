
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chọn kỳ thống kê - OnlineSupermarket</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
</head>
<body>
<main class="panel form-panel">
    <h1 class="page-title">
        THỐNG KÊ KHÁCH HÀNG THEO DOANH THU
    </h1>

    <p class="page-subtitle">
        Chọn khoảng thời gian cần thống kê.
    </p>

    <c:if test="${not empty error}">
        <p class="message error" role="alert">
            <c:out value="${error}"/>
        </p>
    </c:if>

    <form class="form-grid" method="get"
          action="${pageContext.request.contextPath}/statistics/customers">

        <div class="form-field">
            <label for="startDate">Ngày bắt đầu</label>
            <input id="startDate" type="date" name="startDate"
                   required value="<c:out value='${param.startDate}'/>">
        </div>

        <div class="form-field">
            <label for="endDate">Ngày kết thúc</label>
            <input id="endDate" type="date" name="endDate"
                   required value="<c:out value='${param.endDate}'/>">
        </div>

        <div class="form-actions">
            <a class="btn btn-secondary"
               href="${pageContext.request.contextPath}/statistics/types">
                Quay lại
            </a>

            <button class="primary" type="submit">
                Xem thống kê
            </button>
        </div>
    </form>
</main>
</body>
</html>
