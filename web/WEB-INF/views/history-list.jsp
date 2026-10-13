<%-- 
    Document   : history-list 
    Created on : Oct 7, 2026, 10:37:27 PM 
    Author     : VNJ - Refactored to Modern Eco-Tech SaaS Dashboard 
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>History Tưới - Smart Irrigation System</title>
    
    <!-- Google Fonts: Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Bootstrap 5 & Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- CSS tổng của dự án -->
    <link href="${pageContext.request.contextPath}/css/main-style.css" rel="stylesheet">
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
                        <h3 class="mb-0 fw-bold text-dark tracking-tight">Automatic Irrigation Logs</h3>
                        <span class="page-badge-history">
                            <span class="pulse-blue-dot"></span> Live Logs
                        </span>
                    </div>
                    <p class="text-secondary small mb-0 d-flex align-items-center gap-1">
                        <i class="bi bi-clock-history text-primary"></i> 
                        <span>Live log of pump valve activations and delivered water volume</span>
                    </p>
                </div>
                
                <!-- Nút Giả lập gọi API tạo dữ liệu ảo -->
                <form action="${pageContext.request.contextPath}/history" method="POST" target="_blank" class="d-flex align-items-center m-0">
                    <input type="hidden" name="potId" value="${not empty listPot ? listPot[0].potId : 0}">
                    <input type="hidden" name="duration" value="60">
                    <input type="hidden" name="waterAmount" value="1.5">
                    <button type="submit" class="btn-test-action" title="Simulate a 60-second pump cycle">
                        <i class="bi bi-play-circle-fill"></i> <span>+ Simulate Pump (Test)</span>
                    </button>
                </form>
            </div>
            
            <!-- Thanh lọc dữ liệu -->
            <div class="filter-panel">
                <form action="${pageContext.request.contextPath}/history" method="GET" class="row g-2 align-items-center">
                    <div class="col-auto">
                        <label class="fw-semibold text-dark small d-flex align-items-center gap-1">
                            <i class="bi bi-funnel-fill text-secondary"></i> <span>Filter by zone / pot:</span>
                        </label>
                    </div>
                    <div class="col-auto">
                        <select name="potId" class="form-select select-filter-modern" onchange="this.form.submit()">
                            <option value="0">-- All pots --</option>
                            <c:forEach var="pot" items="${listPot}">
                                <option value="${pot.potId}" ${selectedPotId == pot.potId ? 'selected' : ''}>
                                    ${pot.potName} (Crop: ${pot.plantName})
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
                            <th class="col-w-24 text-center"Irrigation Time</th>
                            <th class="col-w-24"Pot Name</th>
                            <th class="col-w-22"Plant Type</th>
                            <th class="col-w-15 text-center"Pump Duration</th>
                            <th class="col-w-15 text-center"Water Volume</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Vòng lặp JSTL duyệt danh sách lịch sử bơm -->
                        <c:forEach var="h" items="${listHistory}">
                            <tr>
                                <!-- Cột 1: Irrigation Time -->
                                <td class="text-center text-muted small">
                                    <div class="d-inline-flex align-items-center gap-1">
                                        <i class="bi bi-calendar3 text-secondary"></i> 
                                        <span class="fw-medium text-dark"><fmt:formatDate value="${h.irrigationTime}" pattern="dd/MM/yyyy HH:mm:ss" /></span>
                                    </div>
                                </td>
                                
                                <!-- Cột 2: Pot Name -->
                                <td>
                                    <div class="pot-name-pill">
                                        <div class="pot-icon-circle"><i class="bi bi-flower1"></i></div>
                                        <span>${h.potName}</span>
                                    </div>
                                </td>
                                
                                <!-- Cột 3: Plant Type -->
                                <td>
                                    <span class="plant-tag">
                                        <i class="bi bi-tree-fill text-success"></i> <span>${h.plantName}</span>
                                    </span>
                                </td>
                                
                                <!-- Cột 4: Pump Duration (sec) -->
                                <td class="text-center">
                                    <span class="badge-duration">
                                        <i class="bi bi-stopwatch"></i> <span>${h.durationSeconds} sec</span>
                                    </span>
                                </td>
                                
                                <!-- Cột 5: Water Volume (Lít) -->
                                <td class="text-center">
                                    <span class="badge-water-amount">
                                        <i class="bi bi-droplet-fill"></i> <span>${h.waterAmount} L</span>
                                    </span>
                                </td>
                            </tr>
                        </c:forEach>
                        
                        <!-- Status trống -->
                        <c:if test="${empty listHistory}">
                            <tr>
                                <td colspan="5" class="p-0">
                                    <div class="empty-state-card">
                                        <div class="empty-state-icon-box"><i class="bi bi-droplet-slash"></i></div>
                                        <h5 class="fw-bold text-dark mb-1">No irrigation logs yet</h5>
                                        <p class="text-muted small mb-0 max-w-sm mx-auto">
                                            No pump cycles match this filter. Click <strong>"Simulate Pump"</strong> above to create a test record.
                                        </p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="footer.jsp" />
</body>
</html>