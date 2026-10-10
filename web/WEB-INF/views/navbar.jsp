<%-- 
    Document   : navbar 
    Created on : Oct 8, 2026, 11:20:42 AM 
    Author     : VNJ - Grouped & Clean Eco-Tech SaaS Navbar (RBAC - Tiếng Việt)
--%>
<%@page pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!-- Custom Navbar Styles nhúng trực tiếp -->
<style>
    .saas-navbar {
        background: #ffffff;
        border-bottom: 1px solid rgba(226, 232, 240, 0.8);
        box-shadow: 0 4px 20px -2px rgba(15, 23, 42, 0.04);
        padding-top: 0.65rem; padding-bottom: 0.65rem;
        position: sticky; top: 0; z-index: 1030;
    }
    
    /* Brand Logo & Title */
    .saas-brand {
        display: inline-flex; align-items: center; gap: 10px;
        text-decoration: none; color: #0f172a;
        font-weight: 800; font-size: 1.15rem;
        letter-spacing: -0.02em; transition: opacity 0.2s;
    }
    .saas-brand:hover { opacity: 0.9; color: #0f172a; }
    .brand-symbol-box {
        width: 38px; height: 38px; border-radius: 10px;
        background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%);
        color: #10b981; display: flex; align-items: center;
        justify-content: center; font-size: 1.25rem;
        box-shadow: 0 2px 8px rgba(16, 185, 129, 0.15);
    }
    
    /* Navigation Links */
    .saas-nav-link {
        color: #475569 !important; font-weight: 500; font-size: 0.88rem;
        padding: 0.5rem 0.85rem !important; border-radius: 8px;
        display: inline-flex; align-items: center; gap: 7px;
        transition: all 0.2s ease; margin: 0 2px;
    }
    .saas-nav-link i { font-size: 1.05rem; color: #94a3b8; transition: color 0.2s ease; }
    .saas-nav-link:hover, .saas-nav-link:focus { color: #10b981 !important; background-color: #f0fdf4; }
    .saas-nav-link:hover i { color: #10b981; }
    .saas-nav-link.active { color: #047857 !important; background-color: #ecfdf5; font-weight: 600; }
    .saas-nav-link.active i { color: #10b981; }
    
    /* Micro-tag AI Feature */
    .badge-ai {
        font-size: 0.65rem; font-weight: 700; padding: 2px 6px;
        border-radius: 6px; background: linear-gradient(135deg, #8b5cf6, #6366f1);
        color: #ffffff; letter-spacing: 0.03em; line-height: 1;
    }
    
    /* User & Action Toolbar */
    .btn-nav-icon {
        width: 38px; height: 38px; border-radius: 50%;
        background: #f8fafc; border: 1px solid #e2e8f0; color: #64748b;
        display: inline-flex; align-items: center; justify-content: center;
        transition: all 0.2s ease; text-decoration: none;
    }
    .btn-nav-icon:hover { background: #f1f5f9; color: #0f172a; border-color: #cbd5e1; }
    
    .user-pill-btn {
        display: inline-flex; align-items: center; gap: 10px;
        padding: 4px 12px 4px 5px; border-radius: 9999px;
        background: #f8fafc; border: 1px solid #e2e8f0;
        text-decoration: none; transition: all 0.2s ease;
    }
    .user-pill-btn:hover { background: #f1f5f9; border-color: #cbd5e1; }
    
    .user-avatar-circle {
        width: 32px; height: 32px; border-radius: 50%;
        background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        color: #ffffff; display: flex; align-items: center;
        justify-content: center; font-size: 0.95rem; position: relative;
    }
    .online-indicator {
        position: absolute; bottom: 0; right: 0;
        width: 9px; height: 9px; border-radius: 50%;
        background-color: #22c55e; border: 2px solid #ffffff;
    }
    .user-name-display { font-size: 0.85rem; font-weight: 600; color: #0f172a; line-height: 1.2; }
    .user-role-badge { font-size: 0.72rem; color: #64748b; font-weight: 500; }
    
    /* Modern Dropdown */
    .dropdown-menu-saas {
        border-radius: 14px; border: 1px solid rgba(226, 232, 240, 0.95);
        box-shadow: 0 12px 30px -4px rgba(15, 23, 42, 0.08), 0 4px 10px -2px rgba(15, 23, 42, 0.04);
        padding: 0.5rem; min-width: 220px;
    }
    .dropdown-item-saas {
        border-radius: 8px; padding: 0.55rem 0.85rem;
        font-size: 0.86rem; font-weight: 500;
        display: flex; align-items: center; gap: 9px;
        color: #475569; transition: all 0.15s ease;
    }
    .dropdown-item-saas:hover { background-color: #f8fafc; color: #0f172a; }
    .dropdown-item-danger { color: #e11d48 !important; font-weight: 600; }
    .dropdown-item-danger:hover { background-color: #fff1f2 !important; color: #be123c !important; }
</style>

<nav class="navbar navbar-expand-lg saas-navbar mb-4">
    <div class="container">
        
        <!-- Logo & Thương hiệu -->
        <a class="saas-brand" href="${pageContext.request.contextPath}/dashboard">
            <div class="brand-symbol-box">
                <i class="bi bi-droplet-half"></i>
            </div>
            <span>Smart Irrigation</span>
        </a>
        
        <!-- Nút Toggler trên màn hình nhỏ -->
        <button class="navbar-toggler border-0 shadow-none p-2" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
            <i class="bi bi-list fs-3 text-dark"></i>
        </button>
        
        <div class="collapse navbar-collapse" id="navbarNav">
            
            <!-- MENU ĐIỀU HƯỚNG GOM CỤM CHÍNH (ĐÃ PHÂN QUYỀN) -->
            <ul class="navbar-nav me-auto ms-lg-4 mt-3 mt-lg-0 align-items-lg-center">
                
                <!-- 1. Tổng quan (Ai đăng nhập cũng thấy) -->
                <li class="nav-item">
                    <a class="nav-link saas-nav-link" href="${pageContext.request.contextPath}/dashboard">
                        <i class="bi bi-grid-1x2-fill"></i> <span>Tổng quan</span>
                    </a>
                </li>
                
                <c:choose>
                    <%-- ADMIN: Thấy toàn bộ chức năng --%>
                    <c:when test="${sessionScope.LOGIN_USER.roleName == 'ADMIN'}">
                        <!-- Nhóm Canh tác: Cây trồng & Chậu -->
                        <li class="nav-item dropdown">
                            <a class="nav-link saas-nav-link dropdown-toggle" href="#" id="farmDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="bi bi-tree-fill"></i> <span>Khu vườn</span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-saas" aria-labelledby="farmDropdown">
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/plants">
                                        <i class="bi bi-flower1 text-success"></i> <span>Quản lý Cây trồng</span>
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/pots">
                                        <i class="bi bi-box-seam text-primary"></i> <span>Chậu & Khu vực tưới</span>
                                    </a>
                                </li>
                            </ul>
                        </li>

                        <!-- Nhóm Vận hành IoT: Cảm biến, Lịch tưới & Nhật ký -->
                        <li class="nav-item dropdown">
                            <a class="nav-link saas-nav-link dropdown-toggle" href="#" id="iotDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="bi bi-cpu-fill"></i> <span>Vận hành IoT</span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-saas" aria-labelledby="iotDropdown">
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/sensor-data">
                                        <i class="bi bi-moisture text-info"></i> <span>Dữ liệu Cảm biến</span>
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/schedules">
                                        <i class="bi bi-calendar-check text-warning"></i> <span>Lịch tưới tự động</span>
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/manual-water">
                                        <i class="bi bi-cloud-rain text-primary"></i> <span>Tưới thủ công</span>
                                    </a>
                                </li>
                                <li><hr class="dropdown-divider my-1"></li>
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/history">
                                        <i class="bi bi-clock-history text-secondary"></i> <span>Nhật ký bơm nước</span>
                                    </a>
                                </li>
                            </ul>
                        </li>
                    </c:when>

                    <%-- MANAGER: Thấy Khu vườn và Lịch tưới --%>
                    <c:when test="${sessionScope.LOGIN_USER.roleName == 'MANAGER'}">
                        <li class="nav-item dropdown">
                            <a class="nav-link saas-nav-link dropdown-toggle" href="#" id="farmDropdownManager" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="bi bi-tree-fill"></i> <span>Khu vườn</span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-saas" aria-labelledby="farmDropdownManager">
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/plants">
                                        <i class="bi bi-flower1 text-success"></i> <span>Quản lý Cây trồng</span>
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/pots">
                                        <i class="bi bi-box-seam text-primary"></i> <span>Chậu & Khu vực tưới</span>
                                    </a>
                                </li>
                            </ul>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link saas-nav-link" href="${pageContext.request.contextPath}/schedules">
                                <i class="bi bi-calendar-check"></i> <span>Lịch tưới tự động</span>
                            </a>
                        </li>
                    </c:when>

                    <%-- TECHNICIAN: Thấy Cảm biến và Nhật ký --%>
                    <c:when test="${sessionScope.LOGIN_USER.roleName == 'TECHNICIAN'}">
                        <li class="nav-item dropdown">
                            <a class="nav-link saas-nav-link dropdown-toggle" href="#" id="techDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="bi bi-cpu-fill"></i> <span>Quản lý Thiết bị</span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-saas" aria-labelledby="techDropdown">
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/sensor-data">
                                        <i class="bi bi-moisture text-info"></i> <span>Dữ liệu Cảm biến</span>
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/history">
                                        <i class="bi bi-clock-history text-secondary"></i> <span>Nhật ký bơm nước</span>
                                    </a>
                                </li>
                            </ul>
                        </li>
                    </c:when>

                    <%-- STAFF: Chỉ thấy Tưới thủ công --%>
                    <c:when test="${sessionScope.LOGIN_USER.roleName == 'STAFF'}">
                        <li class="nav-item">
                            <a class="nav-link saas-nav-link" href="${pageContext.request.contextPath}/manual-water">
                                <i class="bi bi-cloud-rain"></i> <span>Tưới thủ công</span>
                            </a>
                        </li>
                    </c:when>
                </c:choose>

                <!-- AI Phân tích & Dự đoán (Chỉ Admin và Manager thấy) -->
                <c:if test="${sessionScope.LOGIN_USER.roleName == 'ADMIN' || sessionScope.LOGIN_USER.roleName == 'MANAGER'}">
                    <li class="nav-item">
                        <a class="nav-link saas-nav-link" href="${pageContext.request.contextPath}/predict">
                            <i class="bi bi-stars text-primary"></i> <span>AI Dự đoán</span> <span class="badge-ai ms-1">PRO</span>
                        </a>
                    </li>
                </c:if>
                
            </ul>
            
            <!-- TOOLBAR GÓC PHẢI: Chuông Cảnh báo & Profile Người dùng -->
            <ul class="navbar-nav align-items-lg-center gap-2 mt-2 mt-lg-0">
                
                <!-- Nút Chuông cảnh báo (Ẩn với Viewer) -->
                <c:if test="${sessionScope.LOGIN_USER.roleName != 'VIEWER'}">
                    <li class="nav-item">
                        <a class="btn-nav-icon position-relative" href="${pageContext.request.contextPath}/alerts" title="Cảnh báo hệ thống">
                            <i class="bi bi-bell-fill"></i>
                            <span class="position-absolute top-0 start-100 translate-middle p-1 bg-danger border border-light rounded-circle">
                                <span class="visually-hidden">New alerts</span>
                            </span>
                        </a>
                    </li>
                </c:if>
                
                <!-- Dropdown Thông tin tài khoản -->
                <li class="nav-item dropdown">
                    <a class="user-pill-btn dropdown-toggle" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <div class="user-avatar-circle">
                            <i class="bi bi-person-fill"></i>
                            <span class="online-indicator"></span>
                        </div>
                        <div class="d-none d-sm-inline-block text-start">
                            <div class="user-name-display">${sessionScope.LOGIN_USER.fullName}</div>
                            <div class="user-role-badge">${sessionScope.LOGIN_USER.roleName}</div>
                        </div>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end dropdown-menu-saas mt-2" aria-labelledby="userDropdown">
                        
                        <li class="d-sm-none px-3 py-2 border-bottom mb-1">
                            <div class="fw-bold text-dark">${sessionScope.LOGIN_USER.fullName}</div>
                            <small class="text-muted">${sessionScope.LOGIN_USER.roleName}</small>
                        </li>
                        
                        <li>
                            <div class="dropdown-header text-uppercase text-muted fw-bold" style="font-size: 0.7rem; letter-spacing: 0.05em;">Tài khoản</div>
                        </li>
                        
                        <li>
                            <a class="dropdown-item dropdown-item-saas dropdown-item-danger" href="${pageContext.request.contextPath}/logout">
                                <i class="bi bi-box-arrow-right fs-6"></i> <span>Đăng xuất</span>
                            </a>
                        </li>
                    </ul>
                </li>
                
            </ul>
        </div>
    </div>
</nav>

<!-- Tự động Active menu đang xem -->
<script>
    document.addEventListener("DOMContentLoaded", function () {
        const currentPath = window.location.pathname;
        const navLinks = document.querySelectorAll('.saas-nav-link, .dropdown-item-saas');
        
        navLinks.forEach(link => {
            const href = link.getAttribute('href');
            if (href && href !== '#' && currentPath.endsWith(href.split('/').pop())) {
                link.classList.add('active');
                
                const parentDropdown = link.closest('.dropdown');
                if (parentDropdown) {
                    const toggle = parentDropdown.querySelector('.dropdown-toggle');
                    if (toggle) toggle.classList.add('active');
                }
            }
        });
    });
</script>