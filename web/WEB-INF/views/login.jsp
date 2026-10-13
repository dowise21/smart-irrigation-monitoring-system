<%-- 
    Document   : login
    Created on : Oct 7, 2026, 9:22:14 AM
    Author     : VNJ - Refactored to Modern Eco-Tech SaaS Login
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign in - Smart Irrigation</title>
    
    <!-- Google Fonts: Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Bootstrap 5 & Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- Tệp CSS tổng của dự án -->
    <link href="${pageContext.request.contextPath}/css/main-style.css" rel="stylesheet">
</head>
<body>

    <div class="login-wrapper">
        <div class="login-card">
            <!-- Brand & Heading Header -->
            <div class="text-center mb-4">
                <div class="brand-icon-box">
                    <i class="bi bi-droplet-half"></i>
                </div>
                <div>
                    <span class="eco-badge">
                        <i class="bi bi-flower1"></i> AgriTech IoT Platform
                    </span>
                </div>
                <h3 class="fw-bold text-dark mb-1 tracking-tight">Smart Irrigation</h3>
                <p class="text-muted small mb-0">Sign in to the irrigation operations console</p>
            </div>
            
            <!-- Hiển thị thông báo lỗi nếu có -->
            <% 
                String error = (String) request.getAttribute("errorMessage");
                if (error != null && !error.isEmpty()) { 
            %>
                <div class="alert alert-error-custom" role="alert">
                    <i class="bi bi-exclamation-octagon-fill fs-5 flex-shrink-0"></i>
                    <div><%= error %></div>
                </div>
            <% } %>
            
            <!-- Gửi dữ liệu tới LoginServlet -->
            <form action="${pageContext.request.contextPath}/login" method="POST">
                <div class="mb-3">
                    <label for="username" class="form-label-custom">
                        <span>Username</span>
                    </label>
                    <div class="input-group-modern">
                        <input type="text" class="form-control" id="username" name="username" 
                               value="${param.username}" placeholder="Enter username" required autofocus autocomplete="username">
                        <i class="bi bi-person input-icon"></i>
                    </div>
                </div>
                
                <div class="mb-4">
                    <label for="password" class="form-label-custom">
                        <span>Password</span>
                    </label>
                    <div class="input-group-modern">
                        <input type="password" class="form-control" id="password" name="password" 
                               placeholder="Enter password" required autocomplete="current-password">
                        <i class="bi bi-shield-lock input-icon"></i>
                        <button type="button" class="toggle-password" id="togglePasswordBtn" title="Show or hide password">
                            <i class="bi bi-eye" id="togglePasswordIcon"></i>
                        </button>
                    </div>
                </div>
                
                <!-- Nút Submit -->
                <button type="submit" class="btn btn-saas-primary w-100">
                    <span>Sign in</span>
                    <i class="bi bi-arrow-right-short fs-5"></i>
                </button>
            </form>
        </div>
    </div>

    <!-- Toggle Password Visibility Script -->
    <script>
        const toggleBtn = document.getElementById('togglePasswordBtn');
        const passwordInput = document.getElementById('password');
        const toggleIcon = document.getElementById('togglePasswordIcon');
        
        if (toggleBtn && passwordInput) {
            toggleBtn.addEventListener('click', function () {
                const isPassword = passwordInput.getAttribute('type') === 'password';
                passwordInput.setAttribute('type', isPassword ? 'text' : 'password');
                toggleIcon.classList.toggle('bi-eye', !isPassword);
                toggleIcon.classList.toggle('bi-eye-slash', isPassword);
            });
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>