<%-- 
    Document   : plant-form
    Created on : Oct 7, 2026, 11:10:08 AM
    Author     : VNJ - Refactored to Modern Eco-Tech SaaS Form
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <!-- Tiêu đề tự động đổi chữ (Giữ nguyên biểu thức EL) -->
    <title>${plant != null ? 'Cập nhật' : 'Thêm mới'} Cây trồng - Smart Irrigation</title>
    
    <!-- Google Fonts: Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Bootstrap 5 & Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- Tệp CSS tổng của dự án -->
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
        }
        
        body {
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
            background-color: var(--bg-canvas);
            color: var(--text-body);
            -webkit-font-smoothing: antialiased;
            min-height: 100vh;
        }
        
        /* Container & Card Wrapper */
        .form-page-wrapper {
            padding: 2.5rem 1rem 3.5rem;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        .saas-form-card {
            width: 100%;
            max-width: 640px;
            background: #ffffff;
            border-radius: 20px;
            border: 1px solid var(--card-border);
            box-shadow: 0 20px 40px -15px rgba(15, 23, 42, 0.05), 0 1px 3px rgba(0, 0, 0, 0.03);
            position: relative;
            overflow: hidden;
            padding: 2.5rem 2.25rem;
        }
        
        /* Top Accent Gradient Bar */
        .saas-form-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 4px;
            background: linear-gradient(90deg, #10b981, #06b6d4);
        }
        
        /* Brand / Category Icon Header */
        .header-icon-box {
            width: 52px;
            height: 52px;
            border-radius: 14px;
            background: linear-gradient(135deg, var(--primary-soft) 0%, #d1fae5 100%);
            color: var(--primary-emerald);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 1.65rem;
            margin-bottom: 0.85rem;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.15);
        }
        
        /* Badges */
        .mode-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            font-size: 0.75rem;
            font-weight: 700;
            padding: 3px 10px;
            border-radius: 9999px;
            letter-spacing: 0.03em;
            text-transform: uppercase;
            margin-bottom: 0.5rem;
        }
        .mode-badge-edit { background-color: #fef3c7; color: #b45309; border: 1px solid rgba(245, 158, 11, 0.2); }
        .mode-badge-create { background-color: #ecfdf5; color: #047857; border: 1px solid rgba(16, 185, 129, 0.25); }
        
        /* Input Controls & Groups */
        .form-label-custom {
            font-size: 0.86rem;
            font-weight: 600;
            color: var(--text-heading);
            margin-bottom: 6px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        .input-group-modern {
            position: relative;
            display: flex;
            align-items: center;
        }
        .input-group-modern .input-icon {
            position: absolute;
            left: 14px;
            color: #94a3b8;
            font-size: 1.05rem;
            pointer-events: none;
            transition: color 0.2s ease;
            z-index: 4;
        }
        .input-group-modern .form-control {
            border-radius: 10px !important;
            padding-left: 42px;
            border: 1.5px solid #e2e8f0;
            font-size: 0.94rem;
            color: var(--text-heading);
            background-color: #f8fafc;
            transition: all 0.2s ease;
            min-height: 46px;
        }
        .input-group-modern .form-control:focus {
            background-color: #ffffff;
            border-color: var(--primary-emerald);
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.12);
        }
        .input-group-modern .form-control:focus ~ .input-icon {
            color: var(--primary-emerald);
        }
        
        /* Range Section Card */
        .moisture-range-card {
            background-color: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            padding: 1.15rem 1.25rem 0.65rem;
            margin-bottom: 1.25rem;
        }
        .range-section-title {
            font-size: 0.82rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: #64748b;
            margin-bottom: 0.85rem;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        
        /* Textarea */
        textarea.form-control-modern {
            border-radius: 10px;
            border: 1.5px solid #e2e8f0;
            padding: 12px 14px;
            font-size: 0.94rem;
            color: var(--text-heading);
            background-color: #f8fafc;
            transition: all 0.2s ease;
            resize: vertical;
        }
        textarea.form-control-modern:focus {
            background-color: #ffffff;
            border-color: var(--primary-emerald);
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.12);
            outline: none;
        }
        
        /* Action Buttons */
        .btn-saas-back {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 0.65rem 1.4rem;
            border-radius: 9999px;
            font-size: 0.9rem;
            font-weight: 600;
            color: #475569;
            background-color: #f1f5f9;
            border: 1px solid #e2e8f0;
            text-decoration: none;
            transition: all 0.2s ease;
        }
        .btn-saas-back:hover {
            background-color: #e2e8f0;
            color: #1e293b;
        }
        
        .btn-saas-submit {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 0.65rem 1.75rem;
            border-radius: 9999px;
            font-size: 0.92rem;
            font-weight: 600;
            color: #ffffff;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            border: none;
            box-shadow: 0 4px 14px rgba(16, 185, 129, 0.28);
            transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
        }
        .btn-saas-submit:hover {
            background: linear-gradient(135deg, #059669 0%, #047857 100%);
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(16, 185, 129, 0.38);
            color: #ffffff;
        }
        .btn-saas-submit:active { transform: translateY(0); }
    </style>
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
                        ${plant != null ? 'Chế độ Chỉnh sửa' : 'Thêm mới'}
                    </span>
                </div>
                <h3 class="fw-bold text-dark mb-1" style="letter-spacing: -0.02em;">
                    ${plant != null ? 'CẬP NHẬT CÂY TRỒNG' : 'THÊM CÂY MỚI'}
                </h3>
                <p class="text-muted small mb-0">Cấu hình thông số sinh thái và khoảng độ ẩm tối ưu cho từng giống cây</p>
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
                        <span>Tên cây trồng <span class="text-danger">*</span></span>
                    </label>
                    <div class="input-group-modern">
                        <input type="text" name="plantName" class="form-control" placeholder="Ví dụ: Cà chua bi, Hương thảo, Dâu tây..." required value="${plant.plantName}" autofocus>
                        <i class="bi bi-tag input-icon"></i>
                    </div>
                </div>
                
                <!-- Trường 2: Giống/Loài -->
                <div class="mb-3">
                    <label class="form-label-custom">
                        <span>Giống / Loài (Species)</span>
                    </label>
                    <div class="input-group-modern">
                        <input type="text" name="species" class="form-control" placeholder="Ví dụ: Solanum lycopersicum" value="${plant.species}">
                        <i class="bi bi-tree input-icon"></i>
                    </div>
                </div>
                
                <!-- Khối cấu hình độ ẩm lý tưởng Min - Max -->
                <div class="moisture-range-card">
                    <div class="range-section-title">
                        <i class="bi bi-moisture text-primary"></i> <span>Ngưỡng Độ ẩm Đất Lý tưởng</span>
                    </div>
                    <div class="row">
                        <!-- Độ ẩm Tối thiểu -->
                        <div class="col-md-6 mb-3 mb-md-2">
                            <label class="form-label-custom">
                                <span>Tối thiểu (%)</span>
                                <small class="text-muted fw-normal">Kích hoạt bơm</small>
                            </label>
                            <div class="input-group-modern">
                                <input type="number" step="0.1" name="idealMoistureMin" class="form-control" placeholder="Ví dụ: 45.0" value="${plant.idealMoistureMin}">
                                <i class="bi bi-droplet input-icon"></i>
                            </div>
                        </div>
                        
                        <!-- Độ ẩm Tối đa -->
                        <div class="col-md-6 mb-2">
                            <label class="form-label-custom">
                                <span>Tối đa (%)</span>
                                <small class="text-muted fw-normal">Ngắt bơm an toàn</small>
                            </label>
                            <div class="input-group-modern">
                                <input type="number" step="0.1" name="idealMoistureMax" class="form-control" placeholder="Ví dụ: 75.0" value="${plant.idealMoistureMax}">
                                <i class="bi bi-droplet-half input-icon"></i>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Trường 3: Mô tả thêm -->
                <div class="mb-4">
                    <label class="form-label-custom">
                        <span>Mô tả thêm & Đặc tính tưới tiêu</span>
                    </label>
                    <textarea name="description" class="form-control form-control-modern w-100" rows="3" placeholder="Nhập ghi chú về chu kỳ quang hợp, nhu cầu dinh dưỡng hoặc độ sâu của rễ...">${plant.description}</textarea>
                </div>
                
                <!-- Các nút hành động -->
                <div class="d-flex justify-content-between align-items-center pt-2 border-top border-light">
                    <a href="${pageContext.request.contextPath}/plants" class="btn-saas-back">
                        <i class="bi bi-arrow-left"></i> <span>Quay lại danh sách</span>
                    </a>
                    <button type="submit" class="btn-saas-submit">
                        <i class="bi bi-check2-circle"></i> <span>Lưu thông tin</span>
                    </button>
                </div>
                
            </form>
        </div>
    </div>
    
    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>