<%-- 
    Document   : sensor-list 
    Created on : Oct 7, 2026, 10:06:12 PM 
    Author     : VNJ - Refactored to Modern Eco-Tech IoT Telemetry Dashboard 
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!-- Thư viện format (fmt) để hiển thị ngày giờ chuẩn xác -->
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dữ liệu Cảm biến - Smart Irrigation System</title>
    
    <!-- Google Fonts: Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Bootstrap 5 & Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- CSS dùng chung của hệ thống -->
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
            --sensor-blue: #0284c7;
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
        
        /* Realtime Status Badge */
        .live-telemetry-badge {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            font-size: 0.75rem;
            font-weight: 600;
            padding: 4px 11px;
            border-radius: 9999px;
            background: #ecfdf5;
            color: #047857;
            border: 1px solid rgba(16, 185, 129, 0.2);
            letter-spacing: 0.02em;
        }
        .pulse-beacon {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background-color: #10b981;
            box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7);
            animation: beacon-pulse 2s infinite cubic-bezier(0.4, 0, 0.6, 1);
        }
        @keyframes beacon-pulse {
            0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7); }
            70% { transform: scale(1); box-shadow: 0 0 0 6px rgba(16, 185, 129, 0); }
            100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
        }
        
        /* Simulator Test Button */
        .btn-simulator {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            font-size: 0.84rem;
            font-weight: 600;
            padding: 0.52rem 1.15rem;
            border-radius: 10px;
            background-color: #f0fdf4;
            color: #059669;
            border: 1.5px dashed #86efac;
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        }
        .btn-simulator:hover {
            background-color: #dcfce7;
            color: #047857;
            border-color: #4ade80;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.15);
        }
        .btn-simulator:active { transform: translateY(0); }
        
        /* Filter Controls */
        .filter-panel {
            background-color: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 0.85rem 1.15rem;
            margin-bottom: 1.5rem;
        }
        .filter-label {
            font-size: 0.84rem;
            font-weight: 700;
            color: #334155;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .select-modern {
            border-radius: 9px;
            border: 1.5px solid #cbd5e1;
            padding: 0.45rem 1.85rem 0.45rem 0.85rem;
            font-size: 0.88rem;
            font-weight: 500;
            color: #1e293b;
            background-color: #ffffff;
            transition: all 0.2s ease;
            min-width: 260px;
        }
        .select-modern:focus {
            border-color: var(--primary-emerald);
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15);
            outline: none;
        }
        
        /* Table Design */
        .table-iot-wrapper {
            border-radius: 14px;
            overflow: hidden;
            border: 1px solid var(--card-border);
        }
        .table-iot {
            margin-bottom: 0;
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
        }
        .table-iot thead th {
            background-color: #0f172a;
            color: #f8fafc;
            font-size: 0.78rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            padding: 0.95rem 1.15rem;
            border: none;
            white-space: nowrap;
        }
        .table-iot tbody td {
            padding: 1rem 1.15rem;
            vertical-align: middle;
            border-bottom: 1px solid #f1f5f9;
            background-color: #ffffff;
            font-size: 0.9rem;
            transition: background-color 0.15s ease;
        }
        .table-iot tbody tr:last-child td { border-bottom: none; }
        .table-iot tbody tr:hover td { background-color: #fbfcfe; }
        
        /* Timestamp Badge */
        .time-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-family: 'Inter', monospace;
            font-size: 0.82rem;
            font-weight: 600;
            color: #475569;
            background-color: #f1f5f9;
            padding: 4px 10px;
            border-radius: 6px;
            border: 1px solid #e2e8f0;
        }
        
        /* Pot & Plant Item Cell */
        .pot-cell {
            display: inline-flex;
            align-items: center;
            gap: 9px;
        }
        .pot-icon-avatar {
            width: 32px;
            height: 32px;
            border-radius: 9px;
            background: #e0f2fe;
            color: #0284c7;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.95rem;
            flex-shrink: 0;
        }
        .plant-pill {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            font-size: 0.84rem;
            font-weight: 600;
            color: #047857;
            background-color: #ecfdf5;
            padding: 3px 9px;
            border-radius: 6px;
            border: 1px solid rgba(16, 185, 129, 0.2);
        }
        
        /* Moisture Status Gauges */
        .moisture-status-box {
            display: inline-flex;
            align-items: center;
            gap: 10px;
        }
        .moisture-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 0.82rem;
            font-weight: 700;
            padding: 5px 12px;
            border-radius: 9999px;
            letter-spacing: 0.02em;
        }
        
        /* Quá khô (< 30%) */
        .status-dry { background-color: #fef2f2; color: #dc2626; border: 1px solid #fecaca; }
        
        /* Ướt / Bão hòa (> 80%) */
        .status-wet { background-color: #fffbeb; color: #b45309; border: 1px solid #fde68a; }
        
        /* Tốt / Tối ưu (30% - 80%) */
        .status-optimal { background-color: #ecfdf5; color: #059669; border: 1px solid #a7f3d0; }
        
        /* Mini Metric Progress Bar */
        .mini-progress-track {
            width: 75px;
            height: 6px;
            border-radius: 9999px;
            background-color: #e2e8f0;
            overflow: hidden;
            display: inline-block;
        }
        .mini-progress-fill-dry { height: 100%; background-color: #ef4444; }
        .mini-progress-fill-wet { height: 100%; background-color: #f59e0b; }
        .mini-progress-fill-optimal { height: 100%; background: linear-gradient(90deg, #10b981, #06b6d4); }
        
        /* Empty State */
        .empty-telemetry-box { padding: 3.5rem 2rem; text-align: center; }
        .empty-telemetry-icon {
            width: 72px;
            height: 72px;
            border-radius: 50%;
            background-color: #f1f5f9;
            color: #64748b;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            margin-bottom: 1.25rem;
            border: 1px dashed #cbd5e1;
        }
    </style>
</head>
<body>
    <!-- Navbar chung của hệ thống -->
    <jsp:include page="navbar.jsp" />
    
    <main class="container py-4">
        <!-- Main Card Wrapper -->
        <div class="saas-card">
            
            <!-- Header: Tiêu đề trang & Nút Giả lập cảm biến -->
            <div class="d-flex flex-column flex-sm-row justify-content-between align-items-start align-items-sm-center gap-3 mb-4 pb-2 border-bottom border-light">
                <div>
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <h3 class="mb-0 fw-bold text-dark" style="letter-spacing: -0.02em;">Giám sát Độ ẩm Đất</h3>
                        <span class="live-telemetry-badge">
                            <span class="pulse-beacon"></span> Live Telemetry
                        </span>
                    </div>
                    <p class="text-secondary small mb-0 d-flex align-items-center gap-1">
                        <i class="bi bi-broadcast text-success"></i> 
                        <span>Thu nhận trực tiếp dữ liệu đo đạc thời gian thực từ các node cảm biến độ ẩm</span>
                    </p>
                </div>
                
                <!-- Form POST Giả lập nhận tín hiệu -->
                <form action="${pageContext.request.contextPath}/sensor-data" method="POST" target="_blank" class="d-flex align-items-center m-0">
                    <input type="hidden" name="potId" value="${not empty listPot ? listPot[0].potId : 0}">
                    <input type="hidden" name="moisture" value="45.5">
                    <button type="submit" class="btn-simulator" title="Tạo 1 bản ghi ảo 45.5% để Test kết nối Servlet">
                        <i class="bi bi-cpu"></i> <span>+ Giả lập tín hiệu (Test)</span>
                    </button>
                </form>
            </div>
            
            <!-- Thanh lọc theo Khu vực/Chậu -->
            <div class="filter-panel">
                <form action="${pageContext.request.contextPath}/sensor-data" method="GET" class="d-flex flex-wrap align-items-center gap-3 m-0">
                    <div class="filter-label">
                        <i class="bi bi-funnel text-success"></i> <span>Lọc theo Khu vực / Chậu:</span>
                    </div>
                    <div class="flex-grow-1 flex-sm-grow-0">
                        <select name="potId" class="form-select select-modern" onchange="this.form.submit()">
                            <option value="0">-- Tất cả các chậu --</option>
                            <c:forEach var="pot" items="${listPot}">
                                <option value="${pot.potId}" ${selectedPotId == pot.potId ? 'selected' : ''}>
                                    ${pot.potName} (Trồng: ${pot.plantName})
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <c:if test="${selectedPotId > 0}">
                        <a href="${pageContext.request.contextPath}/sensor-data" class="btn btn-sm btn-link text-decoration-none text-muted py-0">
                            <i class="bi bi-x-circle"></i> Xem tất cả
                        </a>
                    </c:if>
                </form>
            </div>
            
            <!-- Bảng Dữ liệu IoT SaaS -->
            <div class="table-iot-wrapper mb-3">
                <table class="table-iot">
                    <thead>
                        <tr>
                            <th style="width: 24%;" class="text-center">Thời gian ghi nhận</th>
                            <th style="width: 26%;">Tên Chậu / Khu vực</th>
                            <th style="width: 24%;">Loại Cây Đang Trồng</th>
                            <th style="width: 26%;" class="text-center">Độ ẩm đất đo được</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Vòng lặp in danh sách dữ liệu cảm biến -->
                        <c:forEach var="s" items="${listData}">
                            <tr>
                                <!-- Cột 1: Thời gian ghi nhận -->
                                <td class="text-center">
                                    <span class="time-badge">
                                        <i class="bi bi-clock-history text-muted"></i> 
                                        <fmt:formatDate value="${s.recordedAt}" pattern="dd/MM/yyyy HH:mm:ss" />
                                    </span>
                                </td>
                                
                                <!-- Cột 2: Tên Chậu -->
                                <td>
                                    <div class="pot-cell">
                                        <div class="pot-icon-avatar"><i class="bi bi-potted"></i></div>
                                        <div>
                                            <strong class="text-dark d-block">${s.potName}</strong>
                                            <small class="text-muted" style="font-size: 0.74rem;">Khu vực đo trực tuyến</small>
                                        </div>
                                    </div>
                                </td>
                                
                                <!-- Cột 3: Loại Cây -->
                                <td>
                                    <span class="plant-pill">
                                        <i class="bi bi-tree-fill" style="font-size: 0.72rem;"></i> 
                                        <span>${s.plantName}</span>
                                    </span>
                                </td>
                                
                                <!-- Cột 4: Độ ẩm đất đo được -->
                                <td class="text-center">
                                    <div class="moisture-status-box justify-content-center">
                                        <c:choose>
                                            <c:when test="${s.moistureLevel < 30}">
                                                <span class="moisture-pill status-dry" title="Độ ẩm thấp hơn ngưỡng yêu cầu">
                                                    <i class="bi bi-exclamation-triangle-fill"></i> 
                                                    <span>${s.moistureLevel}% (Quá khô)</span>
                                                </span>
                                                <div class="mini-progress-track d-none d-md-inline-block" title="${s.moistureLevel}%">
                                                    <div class="mini-progress-fill-dry" style="width: ${s.moistureLevel}%;"></div>
                                                </div>
                                            </c:when>
                                            
                                            <c:when test="${s.moistureLevel > 80}">
                                                <span class="moisture-pill status-wet" title="Độ ẩm bão hòa vượt ngưỡng">
                                                    <i class="bi bi-droplet-half"></i> 
                                                    <span>${s.moistureLevel}% (Ướt)</span>
                                                </span>
                                                <div class="mini-progress-track d-none d-md-inline-block" title="${s.moistureLevel}%">
                                                    <div class="mini-progress-fill-wet" style="width: ${s.moistureLevel}%;"></div>
                                                </div>
                                            </c:when>
                                            
                                            <c:otherwise>
                                                <span class="moisture-pill status-optimal" title="Độ ẩm tối ưu cho cây">
                                                    <i class="bi bi-check-circle-fill"></i> 
                                                    <span>${s.moistureLevel}% (Tốt)</span>
                                                </span>
                                                <div class="mini-progress-track d-none d-md-inline-block" title="${s.moistureLevel}%">
                                                    <div class="mini-progress-fill-optimal" style="width: ${s.moistureLevel}%;"></div>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        
                        <!-- Trường hợp chưa có dữ liệu -->
                        <c:if test="${empty listData}">
                            <tr>
                                <td colspan="4" class="p-0">
                                    <div class="empty-telemetry-box">
                                        <div class="empty-telemetry-icon">
                                            <i class="bi bi-wifi-off"></i>
                                        </div>
                                        <h5 class="fw-bold text-dark mb-1">Chưa có dữ liệu cảm biến nào được gửi về</h5>
                                        <p class="text-muted small mb-3 max-w-sm mx-auto">
                                            Hệ thống chưa nhận được gói tin telemetry từ cảm biến nào của chậu đã chọn. Bạn có thể nhấn nút giả lập bên trên để kiểm tra đường truyền.
                                        </p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            
            <!-- Footer chú thích ngưỡng an toàn -->
            <div class="d-flex flex-column flex-sm-row justify-content-between align-items-center gap-2 pt-2 text-muted small border-top border-light">
                <div class="d-flex align-items-center gap-3">
                    <span><i class="bi bi-circle-fill text-danger me-1" style="font-size: 0.6rem;"></i> Dưới 30%: Khô hạn</span>
                    <span><i class="bi bi-circle-fill text-success me-1" style="font-size: 0.6rem;"></i> 30% - 80%: Lý tưởng</span>
                    <span><i class="bi bi-circle-fill text-warning me-1" style="font-size: 0.6rem;"></i> Trên 80%: Thừa nước</span>
                </div>
                <span>IoT Sensor Node Firmware &bull; v2.4</span>
            </div>
        </div>
    </main>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>