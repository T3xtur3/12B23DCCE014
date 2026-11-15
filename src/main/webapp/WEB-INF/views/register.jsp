
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đăng ký thành viên - OnlineSupermarket</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
</head>
<body>
<main class="panel form-panel">
    <h1 class="page-title">ĐĂNG KÝ THÀNH VIÊN</h1>

    <c:if test="${customer.memberStatus}">
        <p class="message error" role="alert">
            Khách hàng đã đăng ký thành viên trước đó.
            Không thể đăng ký thêm.
        </p>
    </c:if>

    <c:if test="${not empty error}">
        <p class="message error" role="alert">
            <c:out value="${error}"/>
        </p>
    </c:if>

    <form id="registrationForm" class="form-grid"
          action="${pageContext.request.contextPath}/member/register"
          method="post" autocomplete="off">

        <input type="hidden" name="csrfToken" value="${csrfToken}">

        <div class="form-field">
            <label for="fullName">Họ tên</label>
            <input id="fullName" name="fullName" type="text"
                   required maxlength="150"
                   autocomplete="off"
                   placeholder="Nhập họ và tên"
                   value="<c:if test='${pageContext.request.method eq "POST"}'><c:out value='${fullName}'/></c:if>">
        </div>

        <div class="form-field">
            <label for="dateOfBirth">Ngày sinh</label>
            <input id="dateOfBirth" name="dateOfBirth" type="date"
                   required autocomplete="off"
                   value="<c:if test='${pageContext.request.method eq "POST"}'><c:out value='${dateOfBirth}'/></c:if>">
        </div>

        <div class="form-field">
            <label for="address">Địa chỉ</label>
            <input id="address" name="address" type="text"
                   required maxlength="255" autocomplete="off"
                   placeholder="Nhập địa chỉ"
                   value="<c:if test='${pageContext.request.method eq "POST"}'><c:out value='${address}'/></c:if>">
        </div>

        <div class="form-field">
            <label for="email">Email</label>
            <input id="email" name="email" type="email"
                   required maxlength="255" autocomplete="off"
                   placeholder="example@gmail.com"
                   value="<c:if test='${pageContext.request.method eq "POST"}'><c:out value='${email}'/></c:if>">
        </div>

        <div class="form-field">
            <label for="phoneNumber">Số điện thoại</label>
            <input id="phoneNumber" name="phoneNumber" type="tel"
                   required pattern="0[0-9]{9}" maxlength="10"
                   autocomplete="off" placeholder="0xxxxxxxxx"
                   value="<c:if test='${pageContext.request.method eq "POST"}'><c:out value='${phoneNumber}'/></c:if>">
        </div>

        <div class="form-actions">
            <a class="btn btn-secondary"
               href="${pageContext.request.contextPath}/home">
                Quay lại
            </a>

            <button class="primary" type="submit"
                    ${customer.memberStatus ? 'disabled' : ''}>
                Tiếp tục
            </button>
        </div>
    </form>
</main>

<script>
    window.addEventListener('pageshow', function () {
        if ('${pageContext.request.method}' !== 'GET') return;

        const form = document.getElementById('registrationForm');
        if (!form) return;

        ['fullName', 'dateOfBirth', 'address', 'email', 'phoneNumber']
            .forEach(function (name) {
                const field = form.elements.namedItem(name);
                if (field) field.value = '';
            });
    });
</script>
</body>
</html>
