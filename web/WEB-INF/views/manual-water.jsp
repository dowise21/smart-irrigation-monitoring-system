<%-- 
    Document   : manual-water
    Created on : Oct 10, 2026
    Author     : VNJ - Smart Irrigation System
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tưới Thủ Công | Smart Irrigation</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <style>
        body { background-color: #f8fafc; font-family: 'Segoe UI', system-ui, -apple-system, sans-serif; }
        
        .saas-card {
            background: #ffffff;
            border-radius: 16px;
            border: 1px solid rgba(226, 232, 240, 0.8);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
            padding: 2rem;
        }
        
        .page-title { color: #0f172a; font-weight: 700; font-size: 1.5rem; letter-spacing: -0.02em; }
        .page-subtitle { color: #64748b; font-size: 0.95rem; margin-bottom: 2rem; }
        
        .form-label { font-weight: 600; color: #334155; font-size: 0.9rem; margin-bottom: 0.5rem; }
        .form-control, .form-select {
            border-radius: 10px; border: 1px solid #cbd5e1;
            padding: 0.6rem 1rem; color: #0f172a; transition: all 0.2s;
        }
        .form-control:focus, .form-select:focus {
            border-color: #10b981; box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.1);
        }
        
        /* Nút Tưới nổi bật */
        .btn-water-action {
            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
            color: white; border: none; border-radius: 12px;
            padding: 1rem; font-weight: 600; font-size: 1.1rem;
            width: 100%; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex; align-items: center; justify-content: center; gap: 10px;
            box-shadow: 0 4px 14px 0 rgba(37, 99, 235, 0.39);
        }
        .btn-water-action:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(37, 99, 235, 0.23);
            color: white;
        }
        .btn-water-action:active { transform: translateY(1px); }
        
        /* Hoạt ảnh giọt nước (tùy chọn) */
        .water-drop-icon { animation: float 2s ease-in-out infinite; }
        @keyframes float {
            0% { transform: translateY(0px); }
            50% { transform: translateY(-4px); }
            100% { transform: translateY(0px); }
        }
    </style>
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
                            <i class="bi bi-droplet-fill text-primary" style="font-size: 3rem;"></i>
                        </div>
                        <h2 class="page-title">Bảng Điều Khiển Bơm Nước</h2>
                        <p class="page-subtitle">Kích hoạt tưới nước thủ công ngay lập tức cho các chậu cây đang bị thiếu ẩm.</p>
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
                            <label for="potId" class="form-label">Chọn Chậu Cần Tưới <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-box-seam text-secondary"></i></span>
                                <select class="form-select border-start-0 ps-0" id="potId" name="potId" required>
                                    <option value="" disabled selected>-- Chọn chậu đang cảnh báo khô --</option>
                                    
                                    <!-- Dữ liệu mẫu (Thay bằng JSTL khi ráp với DB) -->
                                    <!-- 
                                    <c:forEach var="pot" items="${requestScope.pots}">
                                        <option value="${pot.potId}">${pot.potName} (Độ ẩm hiện tại: ${pot.currentMoisture}%)</option>
                                    </c:forEach> 
                                    -->
                                    <option value="1">Chậu P-01 (Hoa Hồng) - Ẩm: 35%</option>
                                    <option value="2">Chậu P-02 (Lan Hồ Điệp) - Ẩm: 40%</option>
                                    <option value="3">Chậu P-03 (Cây Trầu Bà) - Ẩm: 55%</option>
                                </select>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label for="volume" class="form-label">Lượng Nước (ml) <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-moisture text-secondary"></i></span>
                                <input type="number" class="form-control border-start-0 ps-0" id="volume" name="volume" 
                                       placeholder="Ví dụ: 500" min="50" max="2000" step="50" required>
                                <span class="input-group-text bg-light text-secondary">ml</span>
                            </div>
                            <div class="form-text mt-2"><i class="bi bi-info-circle"></i> Khuyến nghị: 250ml - 500ml mỗi lần tưới.</div>
                        </div>

                        <input type="hidden" name="source" value="MANUAL">
                        <input type="hidden" name="triggerBy" value="${sessionScope.LOGIN_USER.userId}">

                        <button type="submit" class="btn btn-water-action mt-2" id="btnWater">
                            <i class="bi bi-cloud-rain-fill water-drop-icon"></i> KÍCH HOẠT BƠM NƯỚC
                        </button>
                    </form>
                    
                </div>
                
                <!-- Lưu ý an toàn -->
                <div class="text-center mt-4 text-muted" style="font-size: 0.85rem;">
                    <i class="bi bi-shield-check text-success"></i> Thao tác này sẽ được ghi nhận vào Nhật ký hệ thống dưới tên tài khoản của bạn.
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
            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span> Đang gửi lệnh bơm...';
            btn.classList.add('disabled');
            // Form vẫn sẽ submit bình thường sau khi đổi giao diện nút
        });
    </script>
    <jsp:include page="footer.jsp" />
</body>
</html>