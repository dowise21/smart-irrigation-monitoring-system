<%-- 
    Document   : plant-form
    Created on : Oct 7, 2026, 11:10:08 AM
    Author     : VNJ - Refactored to Modern Eco-Tech SaaS Form
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <!-- Tiêu đề tự động đổi chữ (Giữ nguyên biểu thức EL) -->
    <title>${plant != null ? 'Update' : 'Create'} Plant - Smart Irrigation</title>
    
    <!-- Google Fonts: Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Bootstrap 5 & Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- Tệp CSS tổng của dự án -->
    <link href="${pageContext.request.contextPath}/css/main-style.css" rel="stylesheet">
</head>
<body>
    <div class="form-page-wrapper">
        <div class="saas-form-card">
            
            <!-- Header biểu mẫu -->
            <div class="text-center mb-4">
                <div class="header-icon-box">
                    <i class="bi bi-flower1"></i>
                </div>
                <div>
                    <span class="mode-badge ${plant != null ? 'mode-badge-edit' : 'mode-badge-create'}">
                        <i class="bi ${plant != null ? 'bi-pencil-square' : 'bi-plus-circle'}"></i> 
                        ${plant != null ? 'Edit mode' : 'Create'}
                    </span>
                </div>
                <h3 class="fw-bold text-dark mb-1 tracking-tight">
                    ${plant != null ? 'UPDATE PLANT' : 'ADD NEW PLANT'}
                </h3>
                <p class="text-muted small mb-0">Configure ecological parameters and the optimal moisture range for each species</p>
            </div>
            
            <!-- Form nhập liệu -->
            <form action="${pageContext.request.contextPath}/plants" method="POST">
                
                <!-- Tham số ẩn để Controller biết là thực hiện Insert hay Update -->
                <input type="hidden" name="action" value="${plant != null ? 'update' : 'insert'}">
                
                <!-- ID bị ẩn đi, chỉ có giá trị khi Update -->
                <c:if test="${plant != null}">
                    <input type="hidden" name="plantId" value="${plant.plantId}">
                </c:if>
                
                <!-- Trường 1: Tên cây -->
                <div class="mb-3">
                    <label class="form-label-custom">
                        <span>Plant name <span class="text-danger">*</span></span>
                    </label>
                    <div class="input-group-modern">
                        <input type="text" name="plantName" class="form-control" placeholder="e.g. Cherry tomato, rosemary, strawberry..." required value="${plant.plantName}" autofocus>
                        <i class="bi bi-tag input-icon"></i>
                    </div>
                </div>
                
                <!-- Trường 2: Giống/Loài -->
                <div class="mb-3">
                    <label class="form-label-custom">
                        <span>Species (Species)</span>
                    </label>
                    <div class="input-group-modern">
                        <input type="text" name="species" class="form-control" placeholder="e.g. Solanum lycopersicum" value="${plant.species}">
                        <i class="bi bi-tree input-icon"></i>
                    </div>
                </div>
                
                <!-- Khối cấu hình độ ẩm lý tưởng Min - Max -->
                <div class="moisture-range-card">
                    <div class="range-section-title">
                        <i class="bi bi-moisture text-primary"></i> <span>Ideal Soil Moisture Range</span>
                    </div>
                    <div class="row">
                        <!-- Độ ẩm Tối thiểu -->
                        <div class="col-md-6 mb-3 mb-md-2">
                            <label class="form-label-custom">
                                <span>Minimum (%)</span>
                                <small class="text-muted fw-normal">Pump trigger</small>
                            </label>
                            <div class="input-group-modern">
                                <input type="number" step="0.1" name="idealMoistureMin" class="form-control" placeholder="e.g. 45.0" value="${plant.idealMoistureMin}">
                                <i class="bi bi-droplet input-icon"></i>
                            </div>
                        </div>
                        
                        <!-- Độ ẩm Tối đa -->
                        <div class="col-md-6 mb-2">
                            <label class="form-label-custom">
                                <span>Maximum (%)</span>
                                <small class="text-muted fw-normal">Safety cutoff</small>
                            </label>
                            <div class="input-group-modern">
                                <input type="number" step="0.1" name="idealMoistureMax" class="form-control" placeholder="e.g. 75.0" value="${plant.idealMoistureMax}">
                                <i class="bi bi-droplet-half input-icon"></i>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Trường 3: Description thêm -->
                <div class="mb-4">
                    <label class="form-label-custom">
                        <span>Description thêm & Đặc tính tưới tiêu</span>
                    </label>
                    <textarea name="description" class="form-control form-control-modern w-100" rows="3" placeholder="Notes on photoperiod, nutrient needs, or root depth...">${plant.description}</textarea>
                </div>
                
                <!-- Các nút hành động -->
                <div class="d-flex justify-content-between align-items-center pt-2 border-top border-light">
                    <a href="${pageContext.request.contextPath}/plants" class="btn-saas-back">
                        <i class="bi bi-arrow-left"></i> <span>Back to list</span>
                    </a>
                    <button type="submit" class="btn-saas-submit">
                        <i class="bi bi-check2-circle"></i> <span>Save</span>
                    </button>
                </div>
                
            </form>
        </div>
    </div>
    
    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="footer.jsp" />
</body>
</html>