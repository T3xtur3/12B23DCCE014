
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Xác nhận đăng ký - OnlineSupermarket</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
</head>
<body>
<main class="panel form-panel">
    <h1 class="page-title">XÁC NHẬN ĐĂNG KÝ THÀNH VIÊN</h1>

    <p class="page-subtitle">
        Vui lòng kiểm tra thông tin trước khi xác nhận.
    </p>

    <dl class="details">
        <dt>Họ tên</dt>
        <dd><c:out value="${sessionScope.pendingRegistration.name}"/></dd>

        <dt>Ngày sinh</dt>
        <dd><c:out value="${sessionScope.pendingRegistration.dob}"/></dd>

        <dt>Địa chỉ</dt>
        <dd><c:out value="${sessionScope.pendingRegistration.address}"/></dd>

        <dt>Email</dt>
        <dd><c:out value="${sessionScope.pendingRegistration.email}"/></dd>

        <dt>Số điện thoại</dt>
        <dd><c:out value="${sessionScope.pendingRegistration.phone}"/></dd>
    </dl>

    <div class="form-actions">
        <a class="btn btn-secondary"
           href="${pageContext.request.contextPath}/member/register">
            Quay lại
        </a>

        <form method="post"
              action="${pageContext.request.contextPath}/member/confirm">

            <input type="hidden" name="csrfToken" value="${csrfToken}">

            <button class="primary" type="submit">
                Xác nhận
            </button>
        </form>
    </div>
</main>
</body>
</html>
