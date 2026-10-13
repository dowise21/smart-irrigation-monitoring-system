<%-- 
    Document   : pots-list 
    Created on : Oct 7, 2026, 11:27:43 AM 
    Author     : VNJ - Refactored to Modern Eco-Tech SaaS Dashboard 
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Irrigation Zones / Pots - Smart Irrigation System</title>
    
    <!-- Google Fonts: Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Bootstrap 5 & Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- CSS tổng thể của dự án -->
    <link href="${pageContext.request.contextPath}/css/main-style.css" rel="stylesheet">
</head>
<body>
    <!-- Navbar chung của hệ thống -->
    <jsp:include page="navbar.jsp" />
    
    <main class="container py-4">
        <!-- Main SaaS Card -->
        <div class="saas-card">
            
            <!-- Header Section: Title & Actions -->
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3 mb-4 pb-2 border-bottom border-light">
                <div>
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <h3 class="mb-0 fw-bold text-dark tracking-tight">Pot List / Irrigation Zones</h3>
                        <span class="page-badge-pots">
                            <span class="pulse-green-dot"></span> Device management
                        </span>
                    </div>
                    <p class="text-secondary small mb-0 d-flex align-items-center gap-1">
                        <i class="bi bi-geo-alt text-primary"></i> 
                        <span>Monitor valve status, physical location, and plant assignment per smart pot</span>
                    </p>
                </div>
                
                <!-- Nút Thêm mới gọi về Servlet -->
                <div>
                    <a href="${pageContext.request.contextPath}/pots?action=new" class="btn-create-pot">
                        <i class="bi bi-plus-lg"></i> <span>Add Pot</span>
                    </a>
                </div>
            </div>
            
            <!-- Bảng Dữ liệu Hiện đại -->
            <div class="table-saas-container">
                <table class="table-saas">
                    <thead>
                        <tr>
                            <th class="col-w-8 text-center"ID</th>
                            <th class="col-w-23"Pot / Zone Name</th>
                            <th class="col-w-20"Location</th>
                            <th class="col-w-17"Planted Crop</th>
                            <th class="col-w-12 text-center"Status</th>
                            <th class="col-w-20 text-center"Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Vòng lặp in danh sách chậu cây -->
                        <c:forEach var="p" items="${listPot}">
                            <tr>
                                <!-- ID -->
                                <td class="text-center">
                                    <span class="badge bg-light text-secondary border px-2 py-1 rounded-pill fw-semibold small">
                                        #${p.potId}
                                    </span>
                                </td>
                                
                                <!-- Pot Name -->
                                <td>
                                    <div class="pot-title-box">
                                        <div class="pot-avatar-icon"><i class="bi bi-flower1"></i></div>
                                        <div>
                                            <div class="fw-bold text-dark">${p.potName}</div>
                                            <small class="text-muted text-hint">Zone ID: ${p.potId}</small>
                                        </div>
                                    </div>
                                </td>
                                
                                <!-- Vị trí -->
                                <td>
                                    <span class="location-text">
                                        <i class="bi bi-geo-alt-fill text-danger"></i> <span>${p.location}</span>
                                    </span>
                                </td>
                                
                                <!-- Cây trồng liên kết -->
                                <td>
                                    <span class="plant-badge">
                                        <i class="bi bi-tree-fill"></i> <span>${p.plantName}</span>
                                    </span>
                                </td>
                                
                                <!-- Status -->
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${p.status}">
                                            <span class="status-pill-active" title="Automatic mode is on">
                                                <span class="pulse-green-dot"></span> Irrigating
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-pill-inactive" title="Automatic mode is off">
                                                <i class="bi bi-pause-circle-fill"></i> Paused
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                
                                <!-- Nhóm thao tác -->
                                <td class="text-center">
                                    <div class="action-group-wrapper">
                                        <!-- Liên kết dữ liệu IoT: Monitor -->
                                        <a href="${pageContext.request.contextPath}/sensor-data?potId=${p.potId}" class="btn-iot-monitor" title="View live moisture and sensor metrics">
                                            <i class="bi bi-droplet-half"></i> <span>Monitor</span>
                                        </a>
                                        
                                        <!-- Liên kết dữ liệu IoT: History -->
                                        <a href="${pageContext.request.contextPath}/history?potId=${p.potId}" class="btn-iot-history" title="View pump activation history">
                                            <i class="bi bi-clock-history"></i> <span>History</span>
                                        </a>
                                        
                                        <!-- Nút Edit -->
                                        <a href="${pageContext.request.contextPath}/pots?action=edit&id=${p.potId}" class="btn-saas-edit" title="Edit details chậu">
                                            <i class="bi bi-pencil-square"></i>
                                        </a>
                                        
                                        <!-- Nút Delete -->
                                        <a href="${pageContext.request.contextPath}/pots?action=delete&id=${p.potId}" class="btn-saas-delete" title="Delete this pot" onclick="return confirm('Are you sure you want to delete this pot?');">
                                            <i class="bi bi-trash3-fill"></i>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        
                        <!-- Status trống nếu chưa có chậu nào -->
                        <c:if test="${empty listPot}">
                            <tr>
                                <td colspan="6" class="p-0">
                                    <div class="empty-state-card">
                                        <div class="empty-state-icon-box"><i class="bi bi-flower1"></i></div>
                                        <h5 class="fw-bold text-dark mb-1">No pots have been created yet</h5>
                                        <p class="text-muted small mb-3 max-w-sm mx-auto">
                                            Start managing your smart garden by adding a pot and assigning a moisture sensor.
                                        </p>
                                        <a href="${pageContext.request.contextPath}/pots?action=new" class="btn-create-pot d-inline-flex">
                                            <i class="bi bi-plus-lg"></i> <span>Add First Pot</span>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            
        </div>
    </main>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="footer.jsp" />
</body>
</html>