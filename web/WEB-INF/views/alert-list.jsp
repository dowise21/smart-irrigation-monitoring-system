<%-- 
    Document   : alert-list 
    Created on : Oct 7, 2026, 11:45:40 PM 
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
    <title>Alert Management - Smart Irrigation System</title>
    
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
            <!-- Header: Title & Quick Filter -->
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3 mb-4 pb-2 border-bottom border-light">
                <div>
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <h3 class="mb-0 fw-bold text-dark tracking-tight">Automated Alert Center</h3>
                        <span class="page-badge-alert">
                            <span class="pulse-danger-dot"></span> Realtime Watch
                        </span>
                    </div>
                    <p class="text-secondary small mb-0 d-flex align-items-center gap-1">
                        <i class="bi bi-shield-check text-success"></i> 
                        <span>Monitor lưu lượng, độ ẩm chậu cây & phát hiện bất thường tức thì</span>
                    </p>
                </div>
                
                <!-- Bộ lọc trạng thái -->
                <form action="${pageContext.request.contextPath}/alerts" method="GET" class="d-flex align-items-center">
                    <div class="position-relative">
                        <select name="status" class="form-select select-filter-modern" onchange="this.form.submit()">
                            <option value="">-- All alerts --</option>
                            <option value="0" ${currentStatus == '0' ? 'selected' : ''}>🚨 Needs action</option>
                            <option value="1" ${currentStatus == '1' ? 'selected' : ''}>✅ Resolved</option>
                        </select>
                    </div>
                </form>
            </div>
            
            <!-- Khối Bảng Dữ liệu SaaS -->
            <div class="table-saas-container">
                <table class="table-saas">
                    <thead>
                        <tr>
                            <th class="col-w-15 text-center"Time</th>
                            <th class="col-w-17"Pot</th>
                            <th class="col-w-16 text-center"Incident Type</th>
                            <th class="col-w-28"Diagnostic Details</th>
                            <th class="col-w-12 text-center"Status</th>
                            <th class="col-w-12 text-center"Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Vòng lặp JSTL duyệt danh sách cảnh báo -->
                        <c:forEach var="a" items="${listAlerts}">
                            <tr>
                                <!-- Cột 1: Time -->
                                <td class="text-center text-muted small">
                                    <div class="d-inline-flex align-items-center gap-1">
                                        <i class="bi bi-clock text-secondary"></i> 
                                        <span><fmt:formatDate value="${a.createdAt}" pattern="dd/MM/yyyy HH:mm" /></span>
                                    </div>
                                </td>
                                
                                <!-- Cột 2: Pot -->
                                <td>
                                    <div class="pot-name-pill">
                                        <div class="pot-icon-circle"><i class="bi bi-flower1"></i></div>
                                        <span>${a.potName}</span>
                                    </div>
                                </td>
                                
                                <!-- Cột 3: Incident Type -->
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${a.alertType == 'OVERWATER'}">
                                            <span class="badge-incident badge-incident-overwater">
                                                <i class="bi bi-droplet-half"></i> OVERWATER
                                            </span>
                                        </c:when>
                                        <c:when test="${a.alertType == 'DRY_STRESS'}">
                                            <span class="badge-incident badge-incident-dry">
                                                <i class="bi bi-sun-fill"></i> DRY STRESS
                                            </span>
                                        </c:when>
                                        <c:when test="${a.alertType == 'SENSOR_FAULT'}">
                                            <span class="badge-incident badge-incident-sensor">
                                                <i class="bi bi-cpu-fill"></i> SENSOR FAULT
                                            </span>
                                        </c:when>
                                        <c:when test="${a.alertType == 'LEAK'}">
                                            <span class="badge-incident badge-incident-leak">
                                                <i class="bi bi-exclamation-octagon-fill"></i> LEAK SUSPECTED
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-incident badge-incident-default">
                                                <i class="bi bi-info-circle-fill"></i> ${a.alertType}
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                
                                <!-- Cột 4: Diagnostic Details -->
                                <td>
                                    <div class="text-dark fw-medium diagnosis-text">${a.message}</div>
                                </td>
                                
                                <!-- Cột 5: Status -->
                                <td class="text-center">
                                    <c:if test="${!a.isResolved}">
                                        <span class="status-pill status-pill-unresolved">
                                            <span class="pulse-danger-dot"></span> Open
                                        </span>
                                    </c:if>
                                    <c:if test="${a.isResolved}">
                                        <span class="status-pill status-pill-resolved">
                                            <i class="bi bi-check-circle-fill"></i> Resolved
                                        </span>
                                    </c:if>
                                </td>
                                
                                <!-- Cột 6: Actions -->
                                <td class="text-center">
                                    <c:if test="${!a.isResolved && sessionScope.LOGIN_USER.roleName != 'VIEWER'}">
                                        <form action="${pageContext.request.contextPath}/alerts" method="POST" class="d-inline">
                                            <input type="hidden" name="action" value="resolve">
                                            <input type="hidden" name="alertId" value="${a.alertId}">
                                            <button type="submit" class="btn-resolve-action" onclick="return confirm('Confirm that this incident has been resolved?');">
                                                <i class="bi bi-check2"></i> <span>Mark resolved</span>
                                            </button>
                                        </form>
                                    </c:if>
                                    <c:if test="${a.isResolved || sessionScope.LOGIN_USER.roleName == 'VIEWER'}">
                                        <span class="text-muted small"><i class="bi bi-dash-lg"></i></span>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        
                        <!-- Status trống -->
                        <c:if test="${empty listAlerts}">
                            <tr>
                                <td colspan="6" class="p-0">
                                    <div class="empty-state-card">
                                        <div class="empty-state-icon-box"><i class="bi bi-shield-fill-check"></i></div>
                                        <h5 class="fw-bold text-dark mb-1">All clear — no incidents detected</h5>
                                        <p class="text-muted small mb-0 max-w-sm mx-auto">
                                            Irrigation hardware and sensors are stable, and soil moisture is in range.
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
                <span><i class="bi bi-info-circle me-1"></i> Nhấn <strong>"Mark resolved"</strong> sau khi kiểm tra van hoặc cảm biến tại vườn.</span>
                <span>Smart Irrigation Incident Center &bull; v2.4</span>
            </div>
        </div>
    </main>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="footer.jsp" />
</body>
</html>