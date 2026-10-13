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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sensor Data - Smart Irrigation System</title>
    
    <!-- Google Fonts: Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Bootstrap 5 & Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- CSS dùng chung của hệ thống -->
    <link href="${pageContext.request.contextPath}/css/main-style.css" rel="stylesheet">
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
                        <h3 class="mb-0 fw-bold text-dark tracking-tight">Monitor Độ ẩm Đất</h3>
                        <span class="live-telemetry-badge">
                            <span class="pulse-beacon"></span> Live Telemetry
                        </span>
                    </div>
                    <p class="text-secondary small mb-0 d-flex align-items-center gap-1">
                        <i class="bi bi-broadcast text-success"></i> 
                        <span>Live moisture telemetry from sensor nodes</span>
                    </p>
                </div>
                
                <!-- Form POST Giả lập nhận tín hiệu -->
                <form action="${pageContext.request.contextPath}/sensor-data" method="POST" target="_blank" class="d-flex align-items-center m-0">
                    <input type="hidden" name="potId" value="${not empty listPot ? listPot[0].potId : 0}">
                    <input type="hidden" name="moisture" value="45.5">
                    <button type="submit" class="btn-simulator" title="Create a 45.5% mock reading to test the servlet">
                        <i class="bi bi-cpu"></i> <span>+ Simulate Signal (Test)</span>
                    </button>
                </form>
            </div>
            
            <!-- Thanh lọc theo Khu vực/Chậu -->
            <div class="filter-panel">
                <form action="${pageContext.request.contextPath}/sensor-data" method="GET" class="d-flex flex-wrap align-items-center gap-3 m-0">
                    <div class="filter-label">
                        <i class="bi bi-funnel text-success"></i> <span>Filter by zone / pot:</span>
                    </div>
                    <div class="flex-grow-1 flex-sm-grow-0">
                        <select name="potId" class="form-select select-modern" onchange="this.form.submit()">
                            <option value="0">-- All pots --</option>
                            <c:forEach var="pot" items="${listPot}">
                                <option value="${pot.potId}" ${selectedPotId == pot.potId ? 'selected' : ''}>
                                    ${pot.potName} (Crop: ${pot.plantName})
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <c:if test="${selectedPotId > 0}">
                        <a href="${pageContext.request.contextPath}/sensor-data" class="btn btn-sm btn-link text-decoration-none text-muted py-0">
                            <i class="bi bi-x-circle"></i> View all
                        </a>
                    </c:if>
                </form>
            </div>
            
            <!-- Bảng Dữ liệu IoT SaaS -->
            <div class="table-iot-wrapper mb-3">
                <table class="table-iot">
                    <thead>
                        <tr>
                            <th class="col-w-24 text-center"Recorded At</th>
                            <th class="col-w-26"Pot / Zone Name</th>
                            <th class="col-w-24"Planted Crop</th>
                            <th class="col-w-26 text-center"Measured Soil Moisture</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Vòng lặp in danh sách dữ liệu cảm biến -->
                        <c:forEach var="s" items="${listData}">
                            <tr>
                                <!-- Cột 1: Recorded At -->
                                <td class="text-center">
                                    <span class="time-badge">
                                        <i class="bi bi-clock-history text-muted"></i> 
                                        <fmt:formatDate value="${s.recordedAt}" pattern="dd/MM/yyyy HH:mm:ss" />
                                    </span>
                                </td>
                                
                                <!-- Cột 2: Pot Name -->
                                <td>
                                    <div class="pot-cell">
                                        <div class="pot-icon-avatar"><i class="bi bi-potted"></i></div>
                                        <div>
                                            <strong class="text-dark d-block">${s.potName}</strong>
                                            <small class="text-muted text-xs">Online sensing zone</small>
                                        </div>
                                    </div>
                                </td>
                                
                                <!-- Cột 3: Plant Type -->
                                <td>
                                    <span class="plant-pill">
                                        <i class="bi bi-tree-fill icon-xs"></i> 
                                        <span>${s.plantName}</span>
                                    </span>
                                </td>
                                
                                <!-- Cột 4: Measured Soil Moisture -->
                                <td class="text-center">
                                    <div class="moisture-status-box justify-content-center">
                                        <c:choose>
                                            <c:when test="${s.moistureLevel < 30}">
                                                <span class="moisture-pill status-dry" title="Moisture is below the required threshold">
                                                    <i class="bi bi-exclamation-triangle-fill"></i> 
                                                    <span>${s.moistureLevel}% (Too dry)</span>
                                                </span>
                                                <div class="mini-progress-track d-none d-md-inline-block" title="${s.moistureLevel}%">
                                                    <div class="mini-progress-fill-dry" style="width: ${s.moistureLevel}%;"></div>
                                                </div>
                                            </c:when>
                                            
                                            <c:when test="${s.moistureLevel > 80}">
                                                <span class="moisture-pill status-wet" title="Moisture is above the saturation threshold">
                                                    <i class="bi bi-droplet-half"></i> 
                                                    <span>${s.moistureLevel}% (Saturated)</span>
                                                </span>
                                                <div class="mini-progress-track d-none d-md-inline-block" title="${s.moistureLevel}%">
                                                    <div class="mini-progress-fill-wet" style="width: ${s.moistureLevel}%;"></div>
                                                </div>
                                            </c:when>
                                            
                                            <c:otherwise>
                                                <span class="moisture-pill status-optimal" title="Moisture is in the optimal range">
                                                    <i class="bi bi-check-circle-fill"></i> 
                                                    <span>${s.moistureLevel}% (Optimal)</span>
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
                                        <h5 class="fw-bold text-dark mb-1">No sensor data has been received</h5>
                                        <p class="text-muted small mb-3 max-w-sm mx-auto">
                                            No telemetry packets have arrived for the selected pot. Use the simulator above to verify connectivity.
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
                    <span><i class="bi bi-circle-fill text-danger me-1 icon-dot"></i> Below 30%: Drought</span>
                    <span><i class="bi bi-circle-fill text-success me-1 icon-dot"></i> 30% – 80%: Ideal</span>
                    <span><i class="bi bi-circle-fill text-warning me-1 icon-dot"></i> Above 80%: Overwatered</span>
                </div>
            </div>
        </div>
    </main>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="footer.jsp" />
</body>
</html>