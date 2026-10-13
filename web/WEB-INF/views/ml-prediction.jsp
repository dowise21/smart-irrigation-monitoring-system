<%-- 
    Document   : ml-prediction
    Created on : Oct 8, 2026, 11:17:43 AM
    Author     : VNJ - Refactored to Modern Eco-Tech SaaS AI Prediction
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Prediction - Smart Irrigation System</title>
    
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
            <!-- Header: Title & AI Status -->
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3 mb-4 pb-2 border-bottom border-light">
                <div>
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <h3 class="mb-0 fw-bold text-dark tracking-tight">AI Irrigation Prediction Model</h3>
                        <span class="page-badge-ai">
                            <span class="pulse-purple-dot"></span> ML Inference Engine
                        </span>
                    </div>
                    <p class="text-secondary small mb-0 d-flex align-items-center gap-1">
                        <i class="bi bi-cpu text-primary"></i> 
                        <span>The model uses moisture, flow, and light to estimate the next dry-down time</span>
                    </p>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <span class="badge bg-light text-secondary border px-3 py-2 rounded-pill small fw-medium">
                        <i class="bi bi-layers-half text-success me-1"></i> Random Forest Regressor v1.2
                    </span>
                </div>
            </div>
            
            <!-- Layout 2 Cột: Input Form & Kết quả Dự đoán -->
            <div class="row g-4 align-items-stretch">
                <!-- Cột Trái: Thông số đầu vào (Features) -->
                <div class="col-lg-5">
                    <div class="feature-card">
                        <div class="feature-card-header">
                            <span class="fw-bold text-dark small text-uppercase tracking-wider d-flex align-items-center gap-2">
                                <i class="bi bi-sliders2 text-primary fs-6"></i> Input Features
                            </span>
                            <span class="badge bg-primary-subtle text-primary rounded-pill small px-2">Pot #1</span>
                        </div>
                        <div class="p-3 p-md-4">
                            <!-- Form POST gọi Servlet /predict -->
                            <form action="${pageContext.request.contextPath}/predict" method="POST">
                                <input type="hidden" name="potId" value="1">
                                
                                <!-- Trường 1: Độ ẩm hiện tại (%) -->
                                <div class="mb-3">
                                    <label class="form-label-modern">
                                        <i class="bi bi-droplet-half text-info"></i> <span>Current Soil Moisture</span>
                                    </label>
                                    <div class="input-group-modern">
                                        <input type="number" step="0.1" name="moisture" class="form-control" value="${moisture != null ? moisture : 60.5}" required placeholder="e.g. 60.5">
                                        <i class="bi bi-speedometer2 input-icon"></i>
                                        <span class="input-unit-badge">% RH</span>
                                    </div>
                                    <small class="text-muted text-hint">Live soil moisture reading from the sensor</small>
                                </div>
                                
                                <!-- Trường 2: Last Irrigation Volume (ml) -->
                                <div class="mb-3">
                                    <label class="form-label-modern">
                                        <i class="bi bi-cup-straw text-primary"></i> <span>Last Irrigation Volume</span>
                                    </label>
                                    <div class="input-group-modern">
                                        <input type="number" name="water" class="form-control" value="${water != null ? water : 800}" required placeholder="e.g. 800">
                                        <i class="bi bi-droplet input-icon"></i>
                                        <span class="input-unit-badge">ml</span>
                                    </div>
                                    <small class="text-muted text-hint">Pump volume from the most recent cycle</small>
                                </div>
                                
                                <!-- Trường 3: Light Intensity (lux) -->
                                <div class="mb-4">
                                    <label class="form-label-modern">
                                        <i class="bi bi-sun-fill text-warning"></i> <span>Light Intensity</span>
                                    </label>
                                    <div class="input-group-modern">
                                        <input type="number" name="light" class="form-control" value="${light != null ? light : 5000}" required placeholder="e.g. 5000">
                                        <i class="bi bi-brightness-high input-icon"></i>
                                        <span class="input-unit-badge">lux</span>
                                    </div>
                                    <small class="text-muted text-hint">Directly affects evapotranspiration rate</small>
                                </div>
                                
                                <!-- Nút Submit Kích hoạt Mô hình -->
                                <button type="submit" class="btn-predict-action">
                                    <i class="bi bi-cpu-fill fs-5"></i> <span>Run Prediction</span> <i class="bi bi-arrow-right-short fs-5"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
                
                <!-- Cột Phải: Kết quả Dự đoán (Prediction Output) -->
                <div class="col-lg-7">
                    <!-- Nếu có kết quả dự đoán -->
                    <c:if test="${not empty predictionResult}">
                        <div class="result-card">
                            <div class="result-card-header">
                                <span class="fw-bold text-dark small text-uppercase tracking-wider d-flex align-items-center gap-2">
                                    <i class="bi bi-stars text-primary fs-6"></i> Prediction Result (ML Output)
                                </span>
                                <span class="badge bg-success text-white rounded-pill small px-3 py-1">
                                    <i class="bi bi-check-circle-fill me-1"></i> Complete
                                </span>
                            </div>
                            <div class="p-4 d-flex flex-column justify-content-between h-100 text-center">
                                <div>
                                    <p class="text-secondary small fw-medium mb-1">
                                        Based on the trained agri dataset, this pot will need water again at:
                                    </p>
                                    
                                    <!-- Giờ dự đoán khô hạn -->
                                    <div class="prediction-hero-box shadow-sm">
                                        <span class="badge bg-white text-primary border shadow-sm px-3 py-1 rounded-pill small fw-bold mb-2">
                                            <i class="bi bi-calendar-event me-1"></i> Next watering window
                                        </span>
                                        <div class="predicted-time-display my-2">
                                            <fmt:formatDate value="${predictionResult.predictedDryTime}" pattern="HH:mm - dd/MM/yyyy" />
                                        </div>
                                        <span class="text-muted small">
                                            <i class="bi bi-shield-check text-success me-1"></i> Weather evaporation coefficient applied
                                        </span>
                                    </div>
                                    
                                    <!-- Thanh đo Độ tin cậy (Confidence Score) -->
                                    <div class="text-start mt-4 mb-3">
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <span class="fw-bold text-dark small d-flex align-items-center gap-1">
                                                <i class="bi bi-shield-fill-check text-success"></i> <span>Model confidence:</span>
                                            </span>
                                            <span class="fw-bold text-success fs-6">
                                                <fmt:formatNumber value="${predictionResult.confidenceScore}" maxFractionDigits="1"/>%
                                            </span>
                                        </div>
                                        <div class="progress-modern">
                                            <div class="progress-bar-modern progress-bar-striped progress-bar-animated" role="progressbar" style="width: ${predictionResult.confidenceScore}%;">
                                                Confidence: <fmt:formatNumber value="${predictionResult.confidenceScore}" maxFractionDigits="1"/>%
                                            </span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- Khối dữ liệu phân tích / Features Used -->
                                <div class="mt-4 pt-3 border-top border-light text-start">
                                    <span class="text-muted small fw-semibold d-block mb-1">
                                        <i class="bi bi-terminal me-1"></i> Feature tensor:
                                    </span>
                                    <div class="features-console-box">
                                        <code>${predictionResult.featuresUsed}</code>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:if>
                    
                    <!-- Status chờ khi người dùng chưa nhấn dự đoán -->
                    <c:if test="${empty predictionResult}">
                        <div class="empty-prediction-box">
                            <div class="ai-pulse-ring">
                                <i class="bi bi-cpu"></i>
                            </div>
                            <h5 class="fw-bold text-dark mb-1">Model is ready</h5>
                            <p class="text-muted small max-w-sm mx-auto mb-3">
                                Hãy điền các thông số môi trường ở biểu mẫu bên trái và nhấn <strong>"Run Prediction"</strong> để hệ thống suy luận thời điểm tưới tối ưu.
                            </p>
                            <span class="badge bg-light text-secondary border px-3 py-1 rounded-pill small">
                                <i class="bi bi-info-circle me-1"></i> Automated forecasts can reduce water use by up to 35%
                            </span>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </main>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="footer.jsp" />
</body>
</html>