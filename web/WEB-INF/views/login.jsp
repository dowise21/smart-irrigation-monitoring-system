<%-- 
    Document   : login
    Created on : Oct 7, 2026, 9:22:14 AM
    Author     : VNJ - Refactored to Modern Eco-Tech SaaS Login
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - Smart Irrigation</title>
    
    <!-- Google Fonts: Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Bootstrap 5 & Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- Tệp CSS tổng của dự án -->
    <link href="${pageContext.request.contextPath}/css/app.css" rel="stylesheet">
    
    <style>
        :root {
            --primary-emerald: #10b981;
            --primary-dark: #059669;
            --primary-soft: #ecfdf5;
            --accent-teal: #0d9488;
            --bg-canvas: #f4f7f6;
            --text-heading: #0f172a;
            --text-body: #475569;
            --text-muted: #94a3b8;
            --card-border: rgba(226, 232, 240, 0.8);
        }
        
        body {
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
            background-color: var(--bg-canvas);
            background-image: radial-gradient(at 0% 0%, rgba(16, 185, 129, 0.08) 0px, transparent 50%), 
                              radial-gradient(at 100% 100%, rgba(14, 165, 233, 0.06) 0px, transparent 50%);
            color: var(--text-body);
            -webkit-font-smoothing: antialiased;
            min-height: 100vh;
            margin: 0;
        }
        
        .login-wrapper {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1.5rem;
        }
        
        .login-card {
            width: 100%;
            max-width: 440px;
            background: #ffffff;
            border-radius: 20px;
            border: 1px solid var(--card-border);
            padding: 2.75rem 2.25rem;
            box-shadow: 0 20px 40px -15px rgba(16, 185, 129, 0.12), 0 1px 3px rgba(0, 0, 0, 0.05);
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
        }
        
        .login-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 4px;
            background: linear-gradient(90deg, #10b981, #0ea5e9);
        }
        
        /* Brand Logo Box */
        .brand-icon-box {
            width: 58px;
            height: 58px;
            border-radius: 16px;
            background: linear-gradient(135deg, var(--primary-soft) 0%, #d1fae5 100%);
            color: var(--primary-emerald);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 1.85rem;
            margin-bottom: 1.25rem;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.15);
        }
        
        /* Modern Inputs with Icons */
        .input-group-modern {
            position: relative;
            display: flex;
            align-items: center;
        }
        .input-group-modern .input-icon {
            position: absolute;
            left: 14px;
            color: #94a3b8;
            font-size: 1.1rem;
            pointer-events: none;
            transition: color 0.2s ease;
            z-index: 4;
        }
        .input-group-modern .form-control {
            height: 48px;
            border-radius: 10px !important;
            padding-left: 42px;
            padding-right: 42px;
            border: 1.5px solid #e2e8f0;
            font-size: 0.95rem;
            color: var(--text-heading);
            background-color: #f8fafc;
            transition: all 0.2s ease;
        }
        .input-group-modern .form-control:focus {
            background-color: #ffffff;
            border-color: var(--primary-emerald);
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.12);
        }
        .input-group-modern .form-control:focus ~ .input-icon {
            color: var(--primary-emerald);
        }
        
        .toggle-password {
            position: absolute;
            right: 14px;
            background: none;
            border: none;
            color: #94a3b8;
            cursor: pointer;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1rem;
            z-index: 4;
            transition: color 0.2s;
        }
        .toggle-password:hover { color: var(--text-heading); }
        
        /* Form Labels */
        .form-label-custom {
            font-size: 0.85rem;
            font-weight: 600;
            color: #334155;
            margin-bottom: 6px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        /* Primary Button */
        .btn-saas-primary {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: #ffffff;
            border: none;
            height: 48px;
            border-radius: 9999px;
            font-weight: 600;
            font-size: 0.98rem;
            letter-spacing: 0.01em;
            box-shadow: 0 6px 18px rgba(16, 185, 129, 0.3);
            transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        .btn-saas-primary:hover {
            background: linear-gradient(135deg, #059669 0%, #047857 100%);
            color: #ffffff;
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(16, 185, 129, 0.4);
        }
        .btn-saas-primary:active { transform: translateY(0); }
        
        /* Custom Alert Styling */
        .alert-error-custom {
            background-color: #fff1f2;
            border: 1px solid #fecdd3;
            color: #be123c;
            border-radius: 12px;
            padding: 0.85rem 1rem;
            font-size: 0.88rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 10px;
            box-shadow: 0 2px 6px rgba(225, 29, 72, 0.06);
            margin-bottom: 1.5rem;
        }
        
        /* Eco Badge */
        .eco-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 0.75rem;
            font-weight: 600;
            padding: 3px 10px;
            border-radius: 9999px;
            background: #ecfdf5;
            color: #047857;
            margin-bottom: 0.5rem;
        }
    </style>
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
                        <i class="bi bi-flower1"></i> Hệ thống IoT Nông nghiệp
                    </span>
                </div>
                <h3 class="fw-bold text-dark mb-1" style="letter-spacing: -0.02em;">Smart Irrigation</h3>
                <p class="text-muted small mb-0">Đăng nhập cổng quản trị & giám sát tưới tự động</p>
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
                        <span>Tên đăng nhập</span>
                    </label>
                    <div class="input-group-modern">
                        <input type="text" class="form-control" id="username" name="username" 
                               value="${param.username}" placeholder="Nhập tài khoản" required autofocus autocomplete="username">
                        <i class="bi bi-person input-icon"></i>
                    </div>
                </div>
                
                <div class="mb-4">
                    <label for="password" class="form-label-custom">
                        <span>Mật khẩu</span>
                    </label>
                    <div class="input-group-modern">
                        <input type="password" class="form-control" id="password" name="password" 
                               placeholder="Nhập mật khẩu" required autocomplete="current-password">
                        <i class="bi bi-shield-lock input-icon"></i>
                        <button type="button" class="toggle-password" id="togglePasswordBtn" title="Hiện/ẩn mật khẩu">
                            <i class="bi bi-eye" id="togglePasswordIcon"></i>
                        </button>
                    </div>
                </div>
                
                <!-- Nút Submit -->
                <button type="submit" class="btn btn-saas-primary w-100">
                    <span>Đăng nhập hệ thống</span>
                    <i class="bi bi-arrow-right-short fs-5"></i>
                </button>
            </form>
            
            <!-- Footer ghi chú phụ -->
            <div class="text-center mt-4 pt-2 border-top border-light">
                <small class="text-muted" style="font-size: 0.78rem;">
                    <i class="bi bi-shield-check text-success me-1"></i> Hệ thống xác thực mã hóa an toàn &bull; Phiên bản 2.4
                </small>
            </div>
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
    <jsp:include page="footer.jsp" />
</body>
</html>