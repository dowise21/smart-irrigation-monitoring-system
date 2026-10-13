<%-- 
    Document   : navbar 
    Created on : Oct 8, 2026, 11:20:42 AM 
    Author     : VNJ - Grouped & Clean Eco-Tech SaaS Navbar (RBAC - Tiếng Việt)
--%>
<%@page pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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
                
                <!-- 1. Overview (Ai đăng nhập cũng thấy) -->
                <li class="nav-item">
                    <a class="nav-link saas-nav-link" href="${pageContext.request.contextPath}/dashboard">
                        <i class="bi bi-grid-1x2-fill"></i> <span>Overview</span>
                    </a>
                </li>
                
                <c:choose>
                    <%-- ADMIN: Thấy toàn bộ chức năng --%>
                    <c:when test="${sessionScope.LOGIN_USER.roleName == 'ADMIN'}">
                        <!-- Nhóm Canh tác: Cây trồng & Chậu -->
                        <li class="nav-item dropdown">
                            <a class="nav-link saas-nav-link dropdown-toggle" href="#" id="farmDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="bi bi-tree-fill"></i> <span>Garden</span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-saas" aria-labelledby="farmDropdown">
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/plants">
                                        <i class="bi bi-flower1 text-success"></i> <span>Plant Management</span>
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/pots">
                                        <i class="bi bi-box-seam text-primary"></i> <span>Pots & Irrigation Zones</span>
                                    </a>
                                </li>
                            </ul>
                        </li>

                        <!-- Nhóm IoT Operations: Cảm biến, Lịch tưới & Nhật ký -->
                        <li class="nav-item dropdown">
                            <a class="nav-link saas-nav-link dropdown-toggle" href="#" id="iotDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="bi bi-cpu-fill"></i> <span>IoT Operations</span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-saas" aria-labelledby="iotDropdown">
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/sensor-data">
                                        <i class="bi bi-moisture text-info"></i> <span>Sensor Data</span>
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/schedules">
                                        <i class="bi bi-calendar-check text-warning"></i> <span>Auto Schedules</span>
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/manual-water">
                                        <i class="bi bi-cloud-rain text-primary"></i> <span>Manual Watering</span>
                                    </a>
                                </li>
                                <li><hr class="dropdown-divider my-1"></li>
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/history">
                                        <i class="bi bi-clock-history text-secondary"></i> <span>Pump Logs</span>
                                    </a>
                                </li>
                            </ul>
                        </li>
                    </c:when>

                    <%-- MANAGER: Thấy Garden và Lịch tưới --%>
                    <c:when test="${sessionScope.LOGIN_USER.roleName == 'MANAGER'}">
                        <li class="nav-item dropdown">
                            <a class="nav-link saas-nav-link dropdown-toggle" href="#" id="farmDropdownManager" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="bi bi-tree-fill"></i> <span>Garden</span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-saas" aria-labelledby="farmDropdownManager">
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/plants">
                                        <i class="bi bi-flower1 text-success"></i> <span>Plant Management</span>
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/pots">
                                        <i class="bi bi-box-seam text-primary"></i> <span>Pots & Irrigation Zones</span>
                                    </a>
                                </li>
                            </ul>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link saas-nav-link" href="${pageContext.request.contextPath}/schedules">
                                <i class="bi bi-calendar-check"></i> <span>Auto Schedules</span>
                            </a>
                        </li>
                    </c:when>

                    <%-- TECHNICIAN: Thấy Cảm biến và Nhật ký --%>
                    <c:when test="${sessionScope.LOGIN_USER.roleName == 'TECHNICIAN'}">
                        <li class="nav-item dropdown">
                            <a class="nav-link saas-nav-link dropdown-toggle" href="#" id="techDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="bi bi-cpu-fill"></i> <span>Device Management</span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-saas" aria-labelledby="techDropdown">
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/sensor-data">
                                        <i class="bi bi-moisture text-info"></i> <span>Sensor Data</span>
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item dropdown-item-saas" href="${pageContext.request.contextPath}/history">
                                        <i class="bi bi-clock-history text-secondary"></i> <span>Pump Logs</span>
                                    </a>
                                </li>
                            </ul>
                        </li>
                    </c:when>

                    <%-- STAFF: Chỉ thấy Manual Watering --%>
                    <c:when test="${sessionScope.LOGIN_USER.roleName == 'STAFF'}">
                        <li class="nav-item">
                            <a class="nav-link saas-nav-link" href="${pageContext.request.contextPath}/manual-water">
                                <i class="bi bi-cloud-rain"></i> <span>Manual Watering</span>
                            </a>
                        </li>
                    </c:when>
                </c:choose>

                <!-- AI Phân tích & Dự đoán (Chỉ Admin và Manager thấy) -->
                <c:if test="${sessionScope.LOGIN_USER.roleName == 'ADMIN' || sessionScope.LOGIN_USER.roleName == 'MANAGER'}">
                    <li class="nav-item">
                        <a class="nav-link saas-nav-link" href="${pageContext.request.contextPath}/predict">
                            <i class="bi bi-stars text-primary"></i> <span>AI Forecast</span> <span class="badge-ai ms-1">PRO</span>
                        </a>
                    </li>
                </c:if>
                
            </ul>
            
            <!-- TOOLBAR GÓC PHẢI: Chuông Cảnh báo & Profile Người dùng -->
            <ul class="navbar-nav align-items-lg-center gap-2 mt-2 mt-lg-0">
                
                <!-- Nút Chuông cảnh báo (Ẩn với Viewer) -->
                <c:if test="${sessionScope.LOGIN_USER.roleName != 'VIEWER'}">
                    <li class="nav-item">
                        <a class="btn-nav-icon position-relative" href="${pageContext.request.contextPath}/alerts" title="System Alerts">
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
                            <div class="dropdown-header dropdown-header-label text-uppercase text-muted fw-bold">Account</div>
                        </li>
                        
                        <li>
                            <a class="dropdown-item dropdown-item-saas dropdown-item-danger" href="${pageContext.request.contextPath}/logout">
                                <i class="bi bi-box-arrow-right fs-6"></i> <span>Sign out</span>
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