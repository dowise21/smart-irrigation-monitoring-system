<%-- 
    Document   : alert-list 
    Created on : Oct 7, 2026, 11:45:40 PM 
    Author     : VNJ - Refactored to Modern Eco-Tech SaaS Dashboard 
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Cảnh báo - Smart Irrigation System</title>
    
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
            --bg-canvas: #f6f8fa;
            --card-border: rgba(226, 232, 240, 0.85);
            --text-heading: #0f172a;
            --text-body: #475569;
            --text-muted: #94a3b8;
            --danger-soft: #ffe4e6;
            --danger-text: #e11d48;
            --warning-soft: #fef3c7;
            --warning-text: #b45309;
            --success-soft: #dcfce7;
            --success-text: #15803d;
            --info-soft: #e0f2fe;
            --info-text: #0369a1;
        }
        
        body {
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
            background-color: var(--bg-canvas);
            color: var(--text-body);
            -webkit-font-smoothing: antialiased;
            min-height: 100vh;
        }
        
        /* Container Card Styling */
        .saas-card {
            background: #ffffff;
            border-radius: 18px;
            border: 1px solid var(--card-border);
            box-shadow: 0 10px 30px -4px rgba(15, 23, 42, 0.04), 0 2px 6px -1px rgba(15, 23, 42, 0.02);
            padding: 1.75rem 2rem;
            margin-bottom: 2rem;
        }
        
        /* Page Header Badges & Pulse */
        .page-badge-alert {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 0.75rem;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 9999px;
            background: var(--danger-soft);
            color: var(--danger-text);
            letter-spacing: 0.02em;
        }
        .pulse-danger-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background-color: #e11d48;
            box-shadow: 0 0 0 0 rgba(225, 29, 72, 0.7);
            animation: pulse-red 2s infinite;
        }
        @keyframes pulse-red {
            0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(225, 29, 72, 0.7); }
            70% { transform: scale(1); box-shadow: 0 0 0 6px rgba(225, 29, 72, 0); }
            100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(225, 29, 72, 0); }
        }
        
        /* Custom Filter Select */
        .select-filter-modern {
            border: 1.5px solid #e2e8f0;
            border-radius: 10px;
            padding: 0.55rem 2.25rem 0.55rem 1rem;
            font-size: 0.88rem;
            font-weight: 500;
            color: var(--text-heading);
            background-color: #f8fafc;
            transition: all 0.2s ease;
            cursor: pointer;
        }
        .select-filter-modern:focus {
            background-color: #ffffff;
            border-color: var(--primary-emerald);
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.12);
            outline: none;
        }
        
        /* Modern SaaS Table */
        .table-saas-container {
            border-radius: 14px;
            overflow: hidden;
            border: 1px solid var(--card-border);
        }
        .table-saas {
            margin-bottom: 0;
            border-collapse: separate;
            border-spacing: 0;
            width: 100%;
        }
        .table-saas thead th {
            background-color: #f8fafc;
            color: #475569;
            font-size: 0.78rem;
            text-transform: uppercase;
            font-weight: 700;
            letter-spacing: 0.05em;
            padding: 1rem 1.15rem;
            border-bottom: 1px solid #e2e8f0;
            white-space: nowrap;
        }
        .table-saas tbody td {
            padding: 1.1rem 1.15rem;
            vertical-align: middle;
            border-bottom: 1px solid #f1f5f9;
            font-size: 0.9rem;
            color: var(--text-body);
            background-color: #ffffff;
            transition: background-color 0.15s ease;
        }
        .table-saas tbody tr:last-child td { border-bottom: none; }
        .table-saas tbody tr:hover td { background-color: #fbfcfe; }
        
        /* Pot Badge Styling */
        .pot-name-pill {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            font-weight: 600;
            color: #0f172a;
        }
        .pot-icon-circle {
            width: 28px;
            height: 28px;
            border-radius: 8px;
            background: #ecfdf5;
            color: #10b981;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 0.85rem;
            flex-shrink: 0;
        }
        
        /* Incident Type Badges (Pastel Modern) */
        .badge-incident {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 5px 10px;
            border-radius: 8px;
            font-size: 0.76rem;
            font-weight: 700;
            letter-spacing: 0.03em;
            text-transform: uppercase;
        }
        .badge-incident-overwater { background-color: #ffe4e6; color: #be123c; border: 1px solid rgba(244, 63, 94, 0.2); }
        .badge-incident-dry { background-color: #fef3c7; color: #b45309; border: 1px solid rgba(245, 158, 11, 0.2); }
        .badge-incident-sensor { background-color: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; }
        .badge-incident-leak { background-color: #fee2e2; color: #b91c1c; border: 1px solid rgba(239, 68, 68, 0.25); }
        .badge-incident-default { background-color: #e0f2fe; color: #0369a1; border: 1px solid rgba(2, 132, 199, 0.2); }
        
        /* Status Pills */
        .status-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 0.8rem;
            font-weight: 600;
            padding: 4px 11px;
            border-radius: 9999px;
        }
        .status-pill-unresolved { background-color: #fff1f2; color: #e11d48; border: 1px solid #fecdd3; }
        .status-pill-resolved { background-color: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; }
        
        /* Resolve Action Button */
        .btn-resolve-action {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 0.8rem;
            font-weight: 600;
            padding: 5px 14px;
            border-radius: 9999px;
            background-color: #ffffff;
            color: #059669;
            border: 1.5px solid #10b981;
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            box-shadow: 0 1px 3px rgba(16, 185, 129, 0.1);
        }
        .btn-resolve-action:hover {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: #ffffff;
            border-color: transparent;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        }
        .btn-resolve-action:active { transform: translateY(0); }
        
        /* Empty State */
        .empty-state-card { padding: 3.5rem 2rem; text-align: center; }
        .empty-state-icon-box {
            width: 72px;
            height: 72px;
            border-radius: 50%;
            background: #ecfdf5;
            color: #10b981;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 2.2rem;
            margin-bottom: 1.25rem;
            box-shadow: 0 4px 16px rgba(16, 185, 129, 0.15);
        }
    </style>
</head>
<body>
    <!-- Navbar chung của hệ thống -->
    <jsp:include page="navbar.jsp" />
    
    <main class="container py-4">
        <!-- Main Card Wrapper -->
        <div class="saas-card">
            <!-- Header: Title & Quick Filter -->
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3 mb-4 pb-2 border-bottom border-light">
                <div>
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <h3 class="mb-0 fw-bold text-dark tracking-tight" style="letter-spacing: -0.02em;">Hệ thống Cảnh báo tự động</h3>
                        <span class="page-badge-alert">
                            <span class="pulse-danger-dot"></span> Realtime Watch
                        </span>
                    </div>
                    <p class="text-secondary small mb-0 d-flex align-items-center gap-1">
                        <i class="bi bi-shield-check text-success"></i> 
                        <span>Giám sát lưu lượng, độ ẩm chậu cây & phát hiện bất thường tức thì</span>
                    </p>
                </div>
                
                <!-- Bộ lọc trạng thái -->
                <form action="${pageContext.request.contextPath}/alerts" method="GET" class="d-flex align-items-center">
                    <div class="position-relative">
                        <select name="status" class="form-select select-filter-modern" onchange="this.form.submit()">
                            <option value="">-- Tất cả cảnh báo --</option>
                            <option value="0" ${currentStatus == '0' ? 'selected' : ''}>🚨 Cần xử lý ngay</option>
                            <option value="1" ${currentStatus == '1' ? 'selected' : ''}>✅ Đã khắc phục</option>
                        </select>
                    </div>
                </form>
            </div>
            
            <!-- Khối Bảng Dữ liệu SaaS -->
            <div class="table-saas-container">
                <table class="table-saas">
                    <thead>
                        <tr>
                            <th style="width: 15%;" class="text-center">Thời gian</th>
                            <th style="width: 17%;">Chậu cây</th>
                            <th style="width: 16%;" class="text-center">Loại sự cố</th>
                            <th style="width: 28%;">Chi tiết chẩn đoán</th>
                            <th style="width: 12%;" class="text-center">Trạng thái</th>
                            <th style="width: 12%;" class="text-center">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Vòng lặp JSTL duyệt danh sách cảnh báo -->
                        <c:forEach var="a" items="${listAlerts}">
                            <tr>
                                <!-- Cột 1: Thời gian -->
                                <td class="text-center text-muted small">
                                    <div class="d-inline-flex align-items-center gap-1">
                                        <i class="bi bi-clock text-secondary"></i> 
                                        <span><fmt:formatDate value="${a.createdAt}" pattern="dd/MM/yyyy HH:mm" /></span>
                                    </div>
                                </td>
                                
                                <!-- Cột 2: Chậu cây -->
                                <td>
                                    <div class="pot-name-pill">
                                        <div class="pot-icon-circle"><i class="bi bi-flower1"></i></div>
                                        <span>${a.potName}</span>
                                    </div>
                                </td>
                                
                                <!-- Cột 3: Loại sự cố -->
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${a.alertType == 'OVERWATER'}">
                                            <span class="badge-incident badge-incident-overwater">
                                                <i class="bi bi-droplet-half"></i> TƯỚI THỪA
                                            </span>
                                        </c:when>
                                        <c:when test="${a.alertType == 'DRY_STRESS'}">
                                            <span class="badge-incident badge-incident-dry">
                                                <i class="bi bi-sun-fill"></i> THIẾU NƯỚC
                                            </span>
                                        </c:when>
                                        <c:when test="${a.alertType == 'SENSOR_FAULT'}">
                                            <span class="badge-incident badge-incident-sensor">
                                                <i class="bi bi-cpu-fill"></i> LỖI CẢM BIẾN
                                            </span>
                                        </c:when>
                                        <c:when test="${a.alertType == 'LEAK'}">
                                            <span class="badge-incident badge-incident-leak">
                                                <i class="bi bi-exclamation-octagon-fill"></i> NGHI RÒ RỈ
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-incident badge-incident-default">
                                                <i class="bi bi-info-circle-fill"></i> ${a.alertType}
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                
                                <!-- Cột 4: Chi tiết chẩn đoán -->
                                <td>
                                    <div class="text-dark fw-medium" style="line-height: 1.4;">${a.message}</div>
                                </td>
                                
                                <!-- Cột 5: Trạng thái -->
                                <td class="text-center">
                                    <c:if test="${!a.isResolved}">
                                        <span class="status-pill status-pill-unresolved">
                                            <span class="pulse-danger-dot"></span> Chưa xử lý
                                        </span>
                                    </c:if>
                                    <c:if test="${a.isResolved}">
                                        <span class="status-pill status-pill-resolved">
                                            <i class="bi bi-check-circle-fill"></i> Đã khắc phục
                                        </span>
                                    </c:if>
                                </td>
                                
                                <!-- Cột 6: Thao tác -->
                                <td class="text-center">
                                    <c:if test="${!a.isResolved && sessionScope.LOGIN_USER.roleName != 'VIEWER'}">
                                        <form action="${pageContext.request.contextPath}/alerts" method="POST" class="d-inline">
                                            <input type="hidden" name="action" value="resolve">
                                            <input type="hidden" name="alertId" value="${a.alertId}">
                                            <button type="submit" class="btn-resolve-action" onclick="return confirm('Xác nhận đã khắc phục sự cố này?');">
                                                <i class="bi bi-check2"></i> <span>Xử lý xong</span>
                                            </button>
                                        </form>
                                    </c:if>
                                    <c:if test="${a.isResolved || sessionScope.LOGIN_USER.roleName == 'VIEWER'}">
                                        <span class="text-muted small"><i class="bi bi-dash-lg"></i></span>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        
                        <!-- Trạng thái trống -->
                        <c:if test="${empty listAlerts}">
                            <tr>
                                <td colspan="6" class="p-0">
                                    <div class="empty-state-card">
                                        <div class="empty-state-icon-box"><i class="bi bi-shield-fill-check"></i></div>
                                        <h5 class="fw-bold text-dark mb-1">Tuyệt vời! Không phát hiện sự cố</h5>
                                        <p class="text-muted small mb-0 max-w-sm mx-auto">
                                            Hệ thống tưới và các cảm biến đang hoạt động ổn định, độ ẩm đất đạt ngưỡng lý tưởng.
                                        </p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            
            <!-- Footer chú giải nhanh dưới bảng -->
            <div class="d-flex flex-column flex-sm-row justify-content-between align-items-center gap-2 mt-3 pt-2 text-muted small">
                <span><i class="bi bi-info-circle me-1"></i> Nhấn <strong>"Xử lý xong"</strong> sau khi kiểm tra van hoặc cảm biến tại vườn.</span>
                <span>Smart Irrigation Incident Center &bull; v2.4</span>
            </div>
        </div>
    </main>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="footer.jsp" />
</body>
</html>