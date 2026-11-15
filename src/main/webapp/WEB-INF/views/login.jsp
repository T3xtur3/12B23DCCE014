
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đăng nhập - OnlineSupermarket</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
</head>
<body>
<main class="panel narrow" aria-labelledby="page-title">
    <h1 id="page-title" class="page-title">ĐĂNG NHẬP HỆ THỐNG</h1>

    <c:if test="${not empty error}">
        <p class="message error" role="alert">
            <c:out value="${error}"/>
        </p>
    </c:if>

    <form class="field-stack" method="post"
          action="${pageContext.request.contextPath}/login">

        <input type="hidden" name="csrfToken" value="${csrfToken}">

        <div class="form-field">
            <label for="username">Tên đăng nhập</label>
            <input id="username" type="text" name="username"
                   required maxlength="100" autocomplete="username">
        </div>

        <div class="form-field">
            <label for="password">Mật khẩu</label>
            <input id="password" type="password" name="password"
                   required autocomplete="current-password">
        </div>

        <div class="form-actions">
            <button class="primary" type="submit">Đăng nhập</button>
        </div>
    </form>
</main>
</body>
</html>
