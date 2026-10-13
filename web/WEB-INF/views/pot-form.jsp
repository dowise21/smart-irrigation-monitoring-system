<%-- 
    Document   : pot-form 
    Created on : Oct 7, 2026, 11:27:43 AM 
    Author     : VNJ - Refactored to Modern Eco-Tech SaaS Form 
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <!-- Tiêu đề tự động đổi chữ (Giữ nguyên EL) -->
    <title>${pot != null ? 'Update' : 'Create'} Pot - Smart Irrigation System</title>
    
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

    <div class="container d-flex justify-content-center align-items-center py-5 min-vh-100">
        <!-- Main Form Card -->
        <div class="saas-form-card">
            
            <!-- Header Section -->
            <div class="text-center mb-4 pb-2 border-bottom border-light">
                <div class="header-icon-box">
                    <i class="bi bi-flower1"></i>
                </div>
                <div class="d-flex justify-content-center mb-1">
                    <span class="page-badge-state">
                        <i class="bi ${pot != null ? 'bi-pencil-square' : 'bi-plus-circle-fill'}"></i> 
                        <span>${pot != null ? 'Update' : 'Create'}</span>
                    </span>
                </div>
                <h3 class="fw-bold text-dark mb-1 tracking-tight">
                    ${pot != null ? 'UPDATE POT' : 'ADD NEW POT'}
                </h3>
                <p class="text-secondary small mb-0">
                    Configure pot details, garden location, and automatic irrigation
                </p>
            </div>
            
            <!-- Form POST gọi Servlet (Giữ nguyên action, method, hidden action & potId) -->
            <form action="${pageContext.request.contextPath}/pots" method="POST">
                
                <!-- Tham số ẩn để Controller biết là thực hiện Insert hay Update (Giữ nguyên) -->
                <input type="hidden" name="action" value="${pot != null ? 'update' : 'insert'}">
                
                <!-- ID bị ẩn đi, chỉ có giá trị khi Update (Giữ nguyên c:if) -->
                <c:if test="${pot != null}">
                    <input type="hidden" name="potId" value="${pot.potId}">
                </c:if>
                
                <!-- Trường 1: Pot / Zone Name -->
                <div class="mb-3">
                    <label class="form-label-modern">
                        <span>Pot / Zone Name <span class="text-danger">*</span></span>
                        <small class="text-muted fw-normal text-micro">Required</small>
                    </label>
                    <div class="input-group-modern">
                        <input type="text" name="potName" class="form-control" required value="${pot.potName}" placeholder="e.g. Balcony Pot 1">
                        <i class="bi bi-tag-fill input-icon"></i>
                    </div>
                </div>
                
                <!-- Trường 2: Location -->
                <div class="mb-3">
                    <label class="form-label-modern">
                        <span>Location</span>
                        <small class="text-muted fw-normal text-micro">Optional</small>
                    </label>
                    <div class="input-group-modern">
                        <input type="text" name="location" class="form-control" value="${pot.location}" placeholder="e.g. Floor 2, left balcony corner">
                        <i class="bi bi-geo-alt-fill input-icon"></i>
                    </div>
                </div>
                
                <!-- Trường 3: Select planted crop -->
                <div class="mb-4">
                    <label class="form-label-modern">
                        <span>Select planted crop <span class="text-danger">*</span></span>
                        <small class="text-muted fw-normal text-micro">From catalog</small>
                    </label>
                    <div class="input-group-modern">
                        <select name="plantId" class="form-select" required>
                            <option value="">-- Select a plant --</option>
                            <!-- Đổ danh sách cây từ Database vào Dropdown (Giữ nguyên c:forEach và EL) -->
                            <c:forEach var="pl" items="${listPlant}">
                                <option value="${pl.plantId}" ${pot.plantId == pl.plantId ? 'selected' : ''}>
                                    ${pl.plantName}
                                </option>
                            </c:forEach>
                        </select>
                        <i class="bi bi-tree-fill input-icon"></i>
                    </div>
                </div>
                
                <!-- Trường 4: Switch Enable automatic irrigation (Giữ nguyên logic check) -->
                <div class="mb-4">
                    <div class="smart-toggle-box">
                        <div class="d-flex align-items-center gap-2">
                            <div class="rounded-circle p-2 bg-white border d-flex align-items-center justify-content-center text-primary toggle-icon-circle">
                                <i class="bi bi-water"></i>
                            </div>
                            <div>
                                <label class="form-check-label fw-bold text-dark d-block mb-0 toggle-title" for="statusSwitch">
                                    Enable automatic irrigation
                                </label>
                                <small class="text-muted text-micro">
                                    Pump automatically when soil moisture falls below the minimum
                                </small>
                            </div>
                        </div>
                        <div class="form-check form-switch m-0 p-0">
                            <!-- Nếu tạo mới (pot == null) thì mặc định check, nếu update thì tùy giá trị cũ (Giữ nguyên) -->
                            <input class="form-check-input m-0" type="checkbox" id="statusSwitch" name="status" ${(pot == null || pot.status) ? 'checked' : ''}>
                        </div>
                    </div>
                </div>
                
                <!-- Khối Nút Điều Hướng Thao Tác (Giữ nguyên link và submit) -->
                <div class="d-flex justify-content-between align-items-center pt-2 border-top border-light">
                    <a href="${pageContext.request.contextPath}/pots" class="btn-cancel-action">
                        <i class="bi bi-arrow-left"></i> <span>Back to list</span>
                    </a>
                    <button type="submit" class="btn-save-action">
                        <i class="bi bi-check2-circle"></i> <span>Save</span>
                    </button>
                </div>
                
            </form>
        </div>
    </div>

    <!-- Bootstrap 5 Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="footer.jsp" />
</body>
</html>