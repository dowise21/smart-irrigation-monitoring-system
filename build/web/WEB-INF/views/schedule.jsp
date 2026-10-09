<%-- 
    Document   : schedule 
    Created on : Oct 8, 2026, 11:14:08 AM 
    Author     : VNJ - Refactored to Modern Eco-Tech SaaS Schedule Management 
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch tưới tự động - Smart Irrigation System</title>
    
    <!-- Google Fonts: Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Bootstrap 5 & Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- CSS tổng của dự án -->
    <link href="${pageContext.request.contextPath}/css/app.css" rel="stylesheet">
    
    <style>
        :root {
            --primary-emerald: #10b981;
            --primary-dark: #059669;
            --primary-soft: #ecfdf5;
            --accent-teal: #0d9488;
            --water-blue: #0284c7;
            --water-blue-soft: #e0f2fe;
            --bg-canvas: #f6f8fa;
            --card-border: rgba(226, 232, 240, 0.85);
            --text-heading: #0f172a;
            --text-body: #475569;
            --text-muted: #94a3b8;
        }
        
        body {
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
            background-color: var(--bg-canvas);
            color: var(--text-body);
            -webkit-font-smoothing: antialiased;
            min-height: 100vh;
        }
        
        /* Container Card */
        .saas-card {
            background: #ffffff;
            border-radius: 18px;
            border: 1px solid var(--card-border);
            box-shadow: 0 10px 30px -4px rgba(15, 23, 42, 0.04), 0 2px 6px -1px rgba(15, 23, 42, 0.02);
            padding: 1.75rem 2rem;
            margin-bottom: 2rem;
        }
        
        /* Feature Card (Cột Thêm mới) */
        .feature-box {
            background: #ffffff;
            border-radius: 16px;
            border: 1px solid var(--card-border);
            box-shadow: 0 4px 20px -2px rgba(15, 23, 42, 0.03);
            overflow: hidden;
            height: 100%;
        }
        .feature-box-header {
            padding: 1.15rem 1.35rem;
            background: #f8fafc;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        /* Input Controls */
        .form-label-modern {
            font-size: 0.84rem;
            font-weight: 600;
            color: #334155;
            margin-bottom: 6px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .input-group-modern {
            position: relative;
            display: flex;
            align-items: center;
        }
        .input-group-modern .input-icon {
            position: absolute;
            left: 14px;
            color: #94a3b8;
            font-size: 1.05rem;
            pointer-events: none;
            z-index: 4;
            transition: color 0.2s ease;
        }
        .input-group-modern .form-control {
            height: 46px;
            border-radius: 10px !important;
            padding-left: 42px;
            border: 1.5px solid #e2e8f0;
            font-size: 0.94rem;
            color: var(--text-heading);
            background-color: #f8fafc;
            transition: all 0.2s ease;
        }
        .input-group-modern .form-control:focus {
            background-color: #ffffff;
            border-color: var(--primary-emerald);
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.12);
        }
        .input-group-modern .form-control:focus ~ .input-icon { color: var(--primary-emerald); }
        
        .input-unit-badge {
            position: absolute;
            right: 12px;
            background: #f1f5f9;
            color: #64748b;
            font-size: 0.75rem;
            font-weight: 700;
            padding: 3px 8px;
            border-radius: 6px;
            pointer-events: none;
            z-index: 4;
        }
        
        /* Submit Button */
        .btn-saas-primary {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: #ffffff;
            border: none;
            height: 46px;
            border-radius: 9999px;
            font-weight: 700;
            font-size: 0.94rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            width: 100%;
            box-shadow: 0 4px 14px rgba(16, 185, 129, 0.25);
            transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
        }
        .btn-saas-primary:hover {
            background: linear-gradient(135deg, #059669 0%, #047857 100%);
            color: #ffffff;
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(16, 185, 129, 0.35);
        }
        .btn-saas-primary:active { transform: translateY(0); }
        
        /* Modern Table */
        .saas-table { margin-bottom: 0; vertical-align: middle; }
        .saas-table thead th {
            background-color: #f8fafc;
            color: #64748b;
            font-size: 0.78rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            padding: 0.95rem 1.25rem;
            border-bottom: 1px solid #e2e8f0;
            white-space: nowrap;
        }
        .saas-table tbody td {
            padding: 1.05rem 1.25rem;
            border-bottom: 1px solid #f1f5f9;
            font-size: 0.92rem;
        }
        .saas-table tbody tr:last-child td { border-bottom: none; }
        .saas-table tbody tr { transition: background-color 0.15s ease; }
        .saas-table tbody tr:hover { background-color: #f8fafc; }
        
        /* Schedule Cron Pill */
        .cron-pill {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            font-weight: 600;
            color: #0f172a;
            background: #f1f5f9;
            padding: 5px 12px;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
            font-size: 0.88rem;
        }
        
        /* Status Badges */
        .status-badge-active {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background-color: #ecfdf5;
            color: #047857;
            border: 1px solid rgba(16, 185, 129, 0.3);
            padding: 4px 11px;
            border-radius: 9999px;
            font-size: 0.78rem;
            font-weight: 700;
            letter-spacing: 0.02em;
        }
        .status-badge-inactive {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background-color: #f1f5f9;
            color: #64748b;
            border: 1px solid #e2e8f0;
            padding: 4px 11px;
            border-radius: 9999px;
            font-size: 0.78rem;
            font-weight: 700;
            letter-spacing: 0.02em;
        }
        .pulse-dot-green {
            width: 7px; height: 7px; border-radius: 50%;
            background-color: #10b981;
            box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7);
            animation: pulse-green 2s infinite;
        }
        @keyframes pulse-green {
            0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7); }
            70% { transform: scale(1); box-shadow: 0 0 0 5px rgba(16, 185, 129, 0); }
            100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
        }
        
        /* Action Buttons */
        .btn-action-soft-toggle {
            padding: 5px 12px;
            border-radius: 8px;
            font-size: 0.82rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            transition: all 0.2s ease;
            border: 1px solid transparent;
        }
        .btn-action-soft-toggle.active-mode { background-color: #fffbeb; color: #b45309; border-color: #fde68a; }
        .btn-action-soft-toggle.active-mode:hover { background-color: #fef3c7; color: #92400e; }
        
        .btn-action-soft-toggle.inactive-mode { background-color: #ecfdf5; color: #047857; border-color: #a7f3d0; }
        .btn-action-soft-toggle.inactive-mode:hover { background-color: #d1fae5; color: #065f46; }
        
        .btn-action-soft-delete {
            padding: 5px 11px;
            border-radius: 8px;
            font-size: 0.82rem;
            font-weight: 600;
            background-color: #fef2f2;
            color: #dc2626;
            border: 1px solid #fecaca;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            transition: all 0.2s ease;
        }
        .btn-action-soft-delete:hover { background-color: #fee2e2; color: #b91c1c; }
        
        /* Empty State */
        .empty-schedule-box { padding: 3.5rem 1.5rem; text-align: center; }
        .empty-schedule-icon {
            width: 64px; height: 64px; border-radius: 50%;
            background: #f1f5f9; color: #94a3b8;
            display: inline-flex; align-items: center; justify-content: center;
            font-size: 1.8rem; margin-bottom: 1rem;
        }
    </style>
</head>
<body>
    <!-- Navbar chung của hệ thống -->
    <jsp:include page="navbar.jsp" />
    
    <main class="container py-4">
        <!-- Main Card Wrapper -->
        <div class="saas-card">
            
            <!-- Page Header -->
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3 mb-4 pb-2 border-bottom border-light">
                <div>
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <h3 class="mb-0 fw-bold text-dark tracking-tight" style="letter-spacing: -0.02em;">
                            Quản lý Lịch tưới tự động
                        </h3>
                        <span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-1 rounded-pill small fw-bold">
                            <i class="bi bi-flower1 me-1"></i> Chậu ID: ${potId}
                        </span>
                    </div>
                    <p class="text-secondary small mb-0 d-flex align-items-center gap-1">
                        <i class="bi bi-clock-history text-primary"></i> 
                        <span>Cấu hình thời gian kích hoạt rơ-le máy bơm theo lịch định kỳ hoặc biểu thức Cron</span>
                    </p>
                </div>
                
                <div class="d-flex align-items-center gap-2">
                    <a href="${pageContext.request.contextPath}/pots" class="btn btn-sm btn-outline-secondary rounded-pill px-3 fw-medium">
                        <i class="bi bi-arrow-left me-1"></i> Danh sách Chậu
                    </a>
                </div>
            </div>
            
            <!-- Layout 2 Cột: Thêm lịch & Danh sách lịch -->
            <div class="row g-4 align-items-stretch">
                
                <!-- Cột Trái: Khu vực Thêm lịch mới -->
                <div class="col-lg-4">
                    <div class="feature-box">
                        <div class="feature-box-header">
                            <span class="fw-bold text-dark small text-uppercase tracking-wider d-flex align-items-center gap-2">
                                <i class="bi bi-plus-circle-fill text-success fs-6"></i> Thêm Lịch Tưới Mới
                            </span>
                            <span class="badge bg-light text-muted border rounded-pill small">Auto-Sync</span>
                        </div>
                        
                        <div class="p-3 p-md-4">
                            <!-- Form POST thêm lịch tưới -->
                            <form action="${pageContext.request.contextPath}/schedules" method="POST">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="potId" value="${potId}">
                                
                                <!-- Trường 1: Thời gian (Cron/Giờ) -->
                                <div class="mb-3">
                                    <label class="form-label-modern">
                                        <i class="bi bi-alarm text-primary"></i> 
                                        <span>Thời gian (Cron / Giờ) <span class="text-danger">*</span></span>
                                    </label>
                                    <div class="input-group-modern">
                                        <input type="text" name="cronExpression" class="form-control" placeholder="VD: 07:30 Hàng ngày" required>
                                        <i class="bi bi-calendar2-week input-icon"></i>
                                    </div>
                                    <small class="text-muted d-block mt-1" style="font-size: 0.76rem;">
                                        Nhập giờ chạy (vd: <code>06:30</code>) hoặc chu kỳ định sẵn.
                                    </small>
                                </div>
                                
                                <!-- Trường 2: Thời lượng bơm (Giây) -->
                                <div class="mb-4">
                                    <label class="form-label-modern">
                                        <i class="bi bi-stopwatch text-info"></i> 
                                        <span>Thời lượng bơm <span class="text-danger">*</span></span>
                                    </label>
                                    <div class="input-group-modern">
                                        <input type="number" name="durationSeconds" class="form-control" min="10" max="300" value="60" required placeholder="10 - 300">
                                        <i class="bi bi-droplet-half input-icon"></i>
                                        <span class="input-unit-badge">Giây</span>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center mt-1">
                                        <small class="text-muted" style="font-size: 0.76rem;">Tối thiểu: 10s</small>
                                        <small class="text-muted" style="font-size: 0.76rem;">Tối đa: 300s (5 phút)</small>
                                    </div>
                                </div>
                                
                                <!-- Nút Submit Lưu lịch -->
                                <button type="submit" class="btn-saas-primary">
                                    <i class="bi bi-check2-circle fs-5"></i> <span>Lưu lịch tưới</span>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
                
                <!-- Cột Phải: Danh sách lịch đã thiết lập -->
                <div class="col-lg-8">
                    <div class="feature-box">
                        <div class="feature-box-header">
                            <span class="fw-bold text-dark small text-uppercase tracking-wider d-flex align-items-center gap-2">
                                <i class="bi bi-list-task text-primary fs-6"></i> Lịch trình đã thiết lập
                            </span>
                            <span class="badge bg-light text-dark border rounded-pill px-3 py-1 small fw-semibold">
                                <i class="bi bi-clock me-1"></i> Chu kỳ tự động
                            </span>
                        </div>
                        
                        <div class="p-0">
                            <div class="table-responsive">
                                <table class="table saas-table">
                                    <thead>
                                        <tr>
                                            <th>Thời gian thiết lập</th>
                                            <th>Thời lượng bơm</th>
                                            <th class="text-center">Trạng thái</th>
                                            <th class="text-center">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <!-- Vòng lặp in danh sách lịch tưới -->
                                        <c:forEach var="s" items="${listSchedules}">
                                            <tr>
                                                <!-- Thời gian Cron -->
                                                <td>
                                                    <div class="cron-pill">
                                                        <i class="bi bi-alarm text-primary"></i> <span>${s.cronExpression}</span>
                                                    </div>
                                                </td>
                                                
                                                <!-- Thời lượng bơm -->
                                                <td>
                                                    <span class="badge bg-light text-dark border px-3 py-2 rounded-pill small fw-semibold">
                                                        <i class="bi bi-stopwatch text-info me-1"></i> ${s.durationSeconds} giây
                                                    </span>
                                                </td>
                                                
                                                <!-- Trạng thái -->
                                                <td class="text-center">
                                                    <c:if test="${s.isActive}">
                                                        <span class="status-badge-active">
                                                            <span class="pulse-dot-green"></span> Đang Bật
                                                        </span>
                                                    </c:if>
                                                    <c:if test="${!s.isActive}">
                                                        <span class="status-badge-inactive">
                                                            <i class="bi bi-pause-circle text-muted"></i> Tạm Tắt
                                                        </span>
                                                    </c:if>
                                                </td>
                                                
                                                <!-- Thao tác -->
                                                <td class="text-center">
                                                    <div class="d-inline-flex align-items-center gap-2">
                                                        <!-- Nút Bật/Tắt -->
                                                        <form action="${pageContext.request.contextPath}/schedules" method="POST" class="d-inline">
                                                            <input type="hidden" name="action" value="toggle">
                                                            <input type="hidden" name="potId" value="${potId}">
                                                            <input type="hidden" name="scheduleId" value="${s.scheduleId}">
                                                            <input type="hidden" name="isActive" value="${s.isActive}">
                                                            <button type="submit" class="btn-action-soft-toggle ${s.isActive ? 'active-mode' : 'inactive-mode'}" title="${s.isActive ? 'Tạm dừng lịch tưới' : 'Kích hoạt lịch tưới'}">
                                                                <i class="bi ${s.isActive ? 'bi-pause-fill' : 'bi-play-fill'}"></i>
                                                                <span>${s.isActive ? 'Tắt' : 'Bật'}</span>
                                                            </button>
                                                        </form>
                                                        
                                                        <!-- Nút Xóa -->
                                                        <form action="${pageContext.request.contextPath}/schedules" method="POST" class="d-inline">
                                                            <input type="hidden" name="action" value="delete">
                                                            <input type="hidden" name="potId" value="${potId}">
                                                            <input type="hidden" name="scheduleId" value="${s.scheduleId}">
                                                            <button type="submit" class="btn-action-soft-delete" onclick="return confirm('Bạn có chắc muốn xóa lịch này?');" title="Xóa lịch tưới">
                                                                <i class="bi bi-trash3"></i> <span>Xóa</span>
                                                            </button>
                                                        </form>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        
                                        <!-- Khi danh sách trống -->
                                        <c:if test="${empty listSchedules}">
                                            <tr>
                                                <td colspan="4" class="p-0">
                                                    <div class="empty-schedule-box">
                                                        <div class="empty-schedule-icon">
                                                            <i class="bi bi-calendar-x"></i>
                                                        </div>
                                                        <h6 class="fw-bold text-dark mb-1">Chưa có lịch tưới nào được thiết lập</h6>
                                                        <p class="text-muted small mb-0">
                                                            Sử dụng biểu mẫu bên trái để tạo khung giờ bơm tự động cho chậu này.
                                                        </p>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Footer ghi chú kỹ thuật -->
            <div class="d-flex flex-column flex-sm-row justify-content-between align-items-center gap-2 mt-4 pt-3 text-muted small border-top border-light">
                <span>
                    <i class="bi bi-info-circle text-primary me-1"></i> 
                    Lịch tưới sẽ tự động đồng bộ xuống bo mạch vi điều khiển (ESP32 / NodeMCU) qua giao thức MQTT.
                </span>
                <span>Smart Irrigation Scheduler &bull; Zone #${potId}</span>
            </div>
            
        </div>
    </main>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>