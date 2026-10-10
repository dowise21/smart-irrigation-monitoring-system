<%-- 
    Document   : history-list 
    Created on : Oct 7, 2026, 10:37:27 PM 
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
    <title>Lịch sử Tưới - Smart Irrigation System</title>
    
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
            --water-blue: #0284c7;
            --water-blue-bg: #e0f2fe;
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
        
        /* Container Card Styling */
        .saas-card {
            background: #ffffff;
            border-radius: 18px;
            border: 1px solid var(--card-border);
            box-shadow: 0 10px 30px -4px rgba(15, 23, 42, 0.04), 0 2px 6px -1px rgba(15, 23, 42, 0.02);
            padding: 1.75rem 2rem;
            margin-bottom: 2rem;
        }
        
        /* Page Badge & Pulse */
        .page-badge-history {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 0.75rem;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 9999px;
            background: #e0f2fe;
            color: #0369a1;
            letter-spacing: 0.02em;
        }
        .pulse-blue-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background-color: #0284c7;
            box-shadow: 0 0 0 0 rgba(2, 132, 199, 0.7);
            animation: pulse-blue 2s infinite;
        }
        @keyframes pulse-blue {
            0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(2, 132, 199, 0.7); }
            70% { transform: scale(1); box-shadow: 0 0 0 6px rgba(2, 132, 199, 0); }
            100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(2, 132, 199, 0); }
        }
        
        /* Test Action Button */
        .btn-test-action {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 0.82rem;
            font-weight: 600;
            padding: 6px 16px;
            border-radius: 9999px;
            background: #f0fdfa;
            color: #0d9488;
            border: 1.5px solid #99f6e4;
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            text-decoration: none;
            box-shadow: 0 1px 3px rgba(13, 148, 136, 0.08);
        }
        .btn-test-action:hover {
            background: linear-gradient(135deg, #0d9488 0%, #0f766e 100%);
            color: #ffffff;
            border-color: transparent;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(13, 148, 136, 0.25);
        }
        .btn-test-action:active { transform: translateY(0); }
        
        /* Modern Filter Controls */
        .filter-panel {
            background-color: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 0.85rem 1.25rem;
            margin-bottom: 1.5rem;
        }
        .select-filter-modern {
            border: 1.5px solid #cbd5e1;
            border-radius: 9px;
            padding: 0.5rem 2.25rem 0.5rem 1rem;
            font-size: 0.88rem;
            font-weight: 500;
            color: var(--text-heading);
            background-color: #ffffff;
            transition: all 0.2s ease;
            cursor: pointer;
        }
        .select-filter-modern:focus {
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
            padding: 1.05rem 1.15rem;
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
            gap: 8px;
            font-weight: 600;
            color: #0f172a;
        }
        .pot-icon-circle {
            width: 30px;
            height: 30px;
            border-radius: 8px;
            background: #ecfdf5;
            color: #10b981;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 0.88rem;
            flex-shrink: 0;
        }
        .plant-tag {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            color: #475569;
            font-weight: 500;
            font-size: 0.88rem;
        }
        
        /* Badges for Metrics */
        .badge-duration {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 5px 11px;
            border-radius: 9999px;
            font-size: 0.82rem;
            font-weight: 600;
            background-color: #f1f5f9;
            color: #475569;
            border: 1px solid #cbd5e1;
        }
        .badge-water-amount {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 5px 12px;
            border-radius: 9999px;
            font-size: 0.82rem;
            font-weight: 700;
            background-color: #e0f2fe;
            color: #0284c7;
            border: 1px solid #bae6fd;
        }
        
        /* Empty State */
        .empty-state-card { padding: 3.5rem 2rem; text-align: center; }
        .empty-state-icon-box {
            width: 72px;
            height: 72px;
            border-radius: 50%;
            background: #e0f2fe;
            color: #0284c7;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 2.2rem;
            margin-bottom: 1.25rem;
            box-shadow: 0 4px 16px rgba(2, 132, 199, 0.15);
        }
    </style>
</head>
<body>
    <!-- Navbar chung của hệ thống -->
    <jsp:include page="navbar.jsp" />
    
    <main class="container py-4">
        <!-- Main Card Wrapper -->
        <div class="saas-card">
            <!-- Header: Title & Test Trigger Form -->
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3 mb-4 pb-2 border-bottom border-light">
                <div>
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <h3 class="mb-0 fw-bold text-dark tracking-tight" style="letter-spacing: -0.02em;">Nhật ký Tưới tự động</h3>
                        <span class="page-badge-history">
                            <span class="pulse-blue-dot"></span> Live Logs
                        </span>
                    </div>
                    <p class="text-secondary small mb-0 d-flex align-items-center gap-1">
                        <i class="bi bi-clock-history text-primary"></i> 
                        <span>Ghi nhận thời gian kích hoạt van bơm và lượng nước tưới tiêu theo thời gian thực</span>
                    </p>
                </div>
                
                <!-- Nút Giả lập gọi API tạo dữ liệu ảo -->
                <form action="${pageContext.request.contextPath}/history" method="POST" target="_blank" class="d-flex align-items-center m-0">
                    <input type="hidden" name="potId" value="${not empty listPot ? listPot[0].potId : 0}">
                    <input type="hidden" name="duration" value="60">
                    <input type="hidden" name="waterAmount" value="1.5">
                    <button type="submit" class="btn-test-action" title="Giả lập hệ thống vừa bơm nước 60s">
                        <i class="bi bi-play-circle-fill"></i> <span>+ Giả lập Bơm nước (Test)</span>
                    </button>
                </form>
            </div>
            
            <!-- Thanh lọc dữ liệu -->
            <div class="filter-panel">
                <form action="${pageContext.request.contextPath}/history" method="GET" class="row g-2 align-items-center">
                    <div class="col-auto">
                        <label class="fw-semibold text-dark small d-flex align-items-center gap-1">
                            <i class="bi bi-funnel-fill text-secondary"></i> <span>Lọc theo Khu vực / Chậu:</span>
                        </label>
                    </div>
                    <div class="col-auto">
                        <select name="potId" class="form-select select-filter-modern" onchange="this.form.submit()">
                            <option value="0">-- Tất cả các chậu cây --</option>
                            <c:forEach var="pot" items="${listPot}">
                                <option value="${pot.potId}" ${selectedPotId == pot.potId ? 'selected' : ''}>
                                    ${pot.potName} (Trồng: ${pot.plantName})
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </form>
            </div>
            
            <!-- Bảng Dữ liệu SaaS -->
            <div class="table-saas-container">
                <table class="table-saas">
                    <thead>
                        <tr>
                            <th style="width: 24%;" class="text-center">Thời gian tưới</th>
                            <th style="width: 24%;">Tên Chậu</th>
                            <th style="width: 22%;">Loại Cây</th>
                            <th style="width: 15%;" class="text-center">Thời gian bơm</th>
                            <th style="width: 15%;" class="text-center">Lượng nước</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Vòng lặp JSTL duyệt danh sách lịch sử bơm -->
                        <c:forEach var="h" items="${listHistory}">
                            <tr>
                                <!-- Cột 1: Thời gian tưới -->
                                <td class="text-center text-muted small">
                                    <div class="d-inline-flex align-items-center gap-1">
                                        <i class="bi bi-calendar3 text-secondary"></i> 
                                        <span class="fw-medium text-dark"><fmt:formatDate value="${h.irrigationTime}" pattern="dd/MM/yyyy HH:mm:ss" /></span>
                                    </div>
                                </td>
                                
                                <!-- Cột 2: Tên Chậu -->
                                <td>
                                    <div class="pot-name-pill">
                                        <div class="pot-icon-circle"><i class="bi bi-flower1"></i></div>
                                        <span>${h.potName}</span>
                                    </div>
                                </td>
                                
                                <!-- Cột 3: Loại Cây -->
                                <td>
                                    <span class="plant-tag">
                                        <i class="bi bi-tree-fill text-success"></i> <span>${h.plantName}</span>
                                    </span>
                                </td>
                                
                                <!-- Cột 4: Thời gian bơm (Giây) -->
                                <td class="text-center">
                                    <span class="badge-duration">
                                        <i class="bi bi-stopwatch"></i> <span>${h.durationSeconds} giây</span>
                                    </span>
                                </td>
                                
                                <!-- Cột 5: Lượng nước (Lít) -->
                                <td class="text-center">
                                    <span class="badge-water-amount">
                                        <i class="bi bi-droplet-fill"></i> <span>${h.waterAmount} Lít</span>
                                    </span>
                                </td>
                            </tr>
                        </c:forEach>
                        
                        <!-- Trạng thái trống -->
                        <c:if test="${empty listHistory}">
                            <tr>
                                <td colspan="5" class="p-0">
                                    <div class="empty-state-card">
                                        <div class="empty-state-icon-box"><i class="bi bi-droplet-slash"></i></div>
                                        <h5 class="fw-bold text-dark mb-1">Chưa có nhật ký tưới</h5>
                                        <p class="text-muted small mb-0 max-w-sm mx-auto">
                                            Chưa ghi nhận lần bơm nước nào cho bộ lọc này. Bạn có thể nhấn <strong>"Giả lập Bơm nước"</strong> phía trên để tạo bản ghi thử nghiệm.
                                        </p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            
            <!-- Footer ghi chú phụ -->
            <div class="d-flex flex-column flex-sm-row justify-content-between align-items-center gap-2 mt-3 pt-2 text-muted small">
                <span><i class="bi bi-info-circle me-1"></i> Dữ liệu được đồng bộ hóa tự động từ các vi điều khiển van xả thông minh.</span>
                <span>Smart Irrigation Data Logging &bull; v2.4</span>
            </div>
        </div>
    </main>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>