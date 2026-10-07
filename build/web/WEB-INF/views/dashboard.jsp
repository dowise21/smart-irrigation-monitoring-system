<%-- 
    Document   : dashboard
    Created on : Oct 7, 2026, 11:30:46 AM
    Author     : VNJ
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Dashboard - Smart Irrigation</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/app.css" rel="stylesheet">
    <style>
        .dashboard-card {
            transition: transform 0.2s;
            cursor: pointer;
            text-decoration: none;
        }
        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 15px rgba(0,0,0,0.1);
        }
        .icon-large {
            font-size: 3rem;
            color: #2E7D32;
        }
    </style>
</head>
<body>
    <!-- Thanh điều hướng chung (Navbar) -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-success mb-4">
        <div class="container">
            <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/dashboard">Smart Irrigation</a>
            
            <div class="collapse navbar-collapse">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/dashboard">Tổng quan</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/plants">Cây trồng</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/pots">Chậu cây</a>
                    </li>
                </ul>
                <div class="d-flex">
                    <span class="navbar-text me-3 text-white">
                        Xin chào, <b>${sessionScope.LOGIN_USER.fullName}</b> 
                        <span class="badge bg-warning text-dark ms-1">${sessionScope.LOGIN_USER.roleName}</span>
                    </span>
                    <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-light btn-sm">Đăng xuất</a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Nội dung chính -->
    <div class="container">
        <h2 class="page-title mb-4">Tổng quan hệ thống</h2>
        
        <div class="row">
            <!-- Card Cây Trồng -->
            <div class="col-md-6 mb-4">
                <a href="${pageContext.request.contextPath}/plants" class="card dashboard-card h-100 text-center p-4">
                    <div class="card-body">
                        <div class="icon-large mb-3">🌱</div>
                        <h4 class="card-title fw-bold text-success">QUẢN LÝ CÂY TRỒNG</h4>
                        <p class="card-text text-muted">Thêm, sửa, xóa danh mục các loại cây và độ ẩm tiêu chuẩn.</p>
                        <h2 class="display-4 fw-bold text-dark mt-3">${totalPlants}</h2>
                        <span class="text-muted">Loại cây trong CSDL</span>
                    </div>
                </a>
            </div>

            <!-- Card Chậu Cây -->
            <div class="col-md-6 mb-4">
                <a href="${pageContext.request.contextPath}/pots" class="card dashboard-card h-100 text-center p-4">
                    <div class="card-body">
                        <div class="icon-large mb-3">🪴</div>
                        <h4 class="card-title fw-bold text-success">KHU VỰC & CHẬU TƯỚI</h4>
                        <p class="card-text text-muted">Quản lý các vị trí trồng, ghép nối cây vào chậu và bật/tắt tưới.</p>
                        <h2 class="display-4 fw-bold text-dark mt-3">${totalPots}</h2>
                        <span class="text-muted">Chậu đang theo dõi</span>
                    </div>
                </a>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
