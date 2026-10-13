<%-- 
    Document   : manual-water
    Created on : Oct 10, 2026
    Author     : VNJ - Smart Irrigation System
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manual Watering | Smart Irrigation</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="${pageContext.request.contextPath}/css/main-style.css" rel="stylesheet">
</head>
<body>

    <!-- Nhúng Navbar chung của hệ thống -->
    <jsp:include page="navbar.jsp" />

    <div class="container py-4">
        <div class="row justify-content-center">
            <div class="col-lg-6 col-md-8">
                
                <div class="saas-card">
                    <div class="text-center mb-4">
                        <div class="mb-3">
                            <i class="bi bi-droplet-fill text-primary icon-hero"></i>
                        </div>
                        <h2 class="page-title">Pump Control Console</h2>
                        <p class="page-subtitle">Trigger an immediate manual irrigation cycle for moisture-stressed pots.</p>
                    </div>

                    <!-- Hiển thị thông báo (Thành công / Thất bại) -->
                    <c:if test="${not empty sessionScope.SUCCESS_MSG}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="bi bi-check-circle-fill me-2"></i> ${sessionScope.SUCCESS_MSG}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                        <c:remove var="SUCCESS_MSG" scope="session"/>
                    </c:if>
                    <c:if test="${not empty sessionScope.ERROR_MSG}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="bi bi-exclamation-triangle-fill me-2"></i> ${sessionScope.ERROR_MSG}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                        <c:remove var="ERROR_MSG" scope="session"/>
                    </c:if>

                    <!-- Form Gửi Tín Hiệu Tưới -->
                    <form action="${pageContext.request.contextPath}/manual-water" method="POST" id="waterForm">
                        
                        <div class="mb-4">
                            <label for="potId" class="form-label">Select Pot to Water <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-box-seam text-secondary"></i></span>
                                <select class="form-select border-start-0 ps-0" id="potId" name="potId" required>
                                    <option value="" disabled selected>-- Select a pot with a dry-soil alert --</option>
                                    
                                    <!-- Dữ liệu mẫu (Thay bằng JSTL khi ráp với DB) -->
                                    <!-- 
                                    <c:forEach var="pot" items="${requestScope.pots}">
                                        <option value="${pot.potId}">${pot.potName} (Độ ẩm hiện tại: ${pot.currentMoisture}%)</option>
                                    </c:forEach> 
                                    -->
                                    <option value="1">Pot P-01 (Rose) - Moisture: 35%</option>
                                    <option value="2">Pot P-02 (Orchid) - Moisture: 40%</option>
                                    <option value="3">Pot P-03 (Pothos) - Moisture: 55%</option>
                                </select>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label for="volume" class="form-label">Water Volume (ml) <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-moisture text-secondary"></i></span>
                                <input type="number" class="form-control border-start-0 ps-0" id="volume" name="volume" 
                                       placeholder="e.g. 500" min="50" max="2000" step="50" required>
                                <span class="input-group-text bg-light text-secondary">ml</span>
                            </div>
                            <div class="form-text mt-2"><i class="bi bi-info-circle"></i> Recommended: 250ml – 500ml per cycle.</div>
                        </div>

                        <input type="hidden" name="source" value="MANUAL">
                        <input type="hidden" name="triggerBy" value="${sessionScope.LOGIN_USER.userId}">

                        <button type="submit" class="btn btn-water-action mt-2" id="btnWater">
                            <i class="bi bi-cloud-rain-fill water-drop-icon"></i> ACTIVATE PUMP
                        </button>
                    </form>
                    
                </div>
                
                <!-- Lưu ý an toàn -->
                <div class="text-center mt-4 text-muted helper-note">
                    <i class="bi bi-shield-check text-success"></i> This action is recorded in the system audit log under your account.
                </div>
                
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Script xử lý hiệu ứng khi nhấn nút -->
    <script>
        document.getElementById('waterForm').addEventListener('submit', function(e) {
            const btn = document.getElementById('btnWater');
            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span> Sending pump command...';
            btn.classList.add('disabled');
            // Form vẫn sẽ submit bình thường sau khi đổi giao diện nút
        });
    </script>
    <jsp:include page="footer.jsp" />
</body>
</html>