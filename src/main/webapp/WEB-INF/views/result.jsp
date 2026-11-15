
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Kết quả đăng ký - OnlineSupermarket</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
</head>
<body>
<main class="panel narrow">
    <h1 class="page-title">KẾT QUẢ ĐĂNG KÝ</h1>

    <div class="result-area">
        <c:choose>
            <c:when test="${success}">
                <p class="message success" role="status">
                    Đăng ký thành viên thành công!
                </p>
            </c:when>

            <c:otherwise>
                <p class="message error" role="alert">
                    Đăng ký không thành công.
                    Vui lòng kiểm tra lại hoặc thử sau.
                </p>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="form-actions">
        <a class="btn"
           href="${pageContext.request.contextPath}/home">
            Về giao diện chính
        </a>
    </div>
</main>
</body>
</html>
