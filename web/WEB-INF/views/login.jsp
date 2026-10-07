<%-- 
    Document   : login
    Created on : Oct 7, 2026, 9:22:14 AM
    Author     : VNJ
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - Smart Irrigation</title>
    
    <!-- Thư viện Bootstrap 5 (Dành cho Layout và Form) -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Tệp CSS tổng của dự án, nằm ở: Web Pages/css/app.css -->
    <link href="${pageContext.request.contextPath}/css/app.css" rel="stylesheet">
</head>
<body>

    <!-- Class login-wrapper căn giữa màn hình 100vh được cấu hình trong app.css -->
    <div class="login-wrapper">
        <div class="login-card">
            <h2>Smart Irrigation</h2>
            
            <!-- Hiển thị thông báo lỗi nếu có -->
            <% 
                String error = (String) request.getAttribute("errorMessage");
                if (error != null && !error.isEmpty()) { 
            %>
                <div class="alert alert-danger" role="alert">
                    <%= error %>
                </div>
            <% } %>

            <!-- Gửi dữ liệu tới LoginServlet bằng POST -->
            <form action="${pageContext.request.contextPath}/login" method="POST">
                <div class="mb-3">
                    <label for="username" class="form-label">Tên đăng nhập</label>
                    <!-- Giữ lại thông tin username nếu người dùng nhập sai mk -->
                    <input type="text" class="form-control" id="username" name="username" 
                           value="${param.username}" required autofocus>
                </div>
                
                <div class="mb-4">
                    <label for="password" class="form-label">Mật khẩu</label>
                    <input type="password" class="form-control" id="password" name="password" required>
                </div>
                
                <!-- Sử dụng class btn-primary đã được ghi đè thành màu xanh lá trong app.css -->
                <button type="submit" class="btn btn-primary w-100">Đăng nhập</button>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>