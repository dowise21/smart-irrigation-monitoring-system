<%-- 
    Document   : plants-list
    Created on : Oct 7, 2026, 11:09:13 AM
    Author     : VNJ - Refactored to Modern Eco-Tech SaaS Dashboard
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!-- Khai báo thư viện JSTL để dùng các thẻ c:forEach, c:if -->
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Cây trồng - Smart Irrigation System</title>
    
    <!-- Google Fonts: Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Bootstrap 5 & Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- CSS dùng chung của hệ thống -->
    <link href="${pageContext.request.contextPath}/css/app.css" rel="stylesheet">
    
    <style>
        :root {
            --primary-emerald: #10b981;
            --primary-dark: #059669;
            --primary-soft: #ecfdf5;
            --bg-canvas: #f6f8fa;
            --card-border: rgba(226, 232, 240, 0.85);
            --text-heading: #0f172a;
            --text-body: #475569;
            --text-muted: #94a3b8;
            --moisture-blue: #0284c7;
            --moisture-bg: #e0f2fe;
        }
        
        body {
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
            background-color: var(--bg-canvas);
            color: var(--text-body);
            -webkit-font-smoothing: antialiased;
            min-height: 100vh;
        }
        
        /* Container Card Styling */
        .saas-card {
            background: #ffffff;
            border-radius: 18px;
            border: 1px solid var(--card-border);
            box-shadow: 0 10px 30px -4px rgba(15, 23, 42, 0.04), 0 2px 6px -1px rgba(15, 23, 42, 0.02);
            padding: 1.75rem 2rem;
            margin-bottom: 2rem;
        }
        
        /* Page Badge & Counter */
        .page-badge-plants {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 0.75rem;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 9999px;
            background: #ecfdf5;
            color: #047857;
            letter-spacing: 0.02em;
        }
        .pulse-green-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background-color: #10b981;
            box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7);
            animation: pulse-emerald 2s infinite;
        }
        @keyframes pulse-emerald {
            0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7); }
            70% { transform: scale(1); box-shadow: 0 0 0 6px rgba(16, 185, 129, 0); }
            100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
        }
        
        /* Primary Action Button (Thêm mới) */
        .btn-add-plant {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 0.88rem;
            font-weight: 600;
            padding: 0.58rem 1.25rem;
            border-radius: 10px;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: #ffffff;
            border: none;
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            text-decoration: none;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.25);
        }
        .btn-add-plant:hover {
            color: #ffffff;
            transform: translateY(-1px);
            box-shadow: 0 6px 16px rgba(16, 185, 129, 0.35);
        }
        .btn-add-plant:active { transform: translateY(0); }
        
        /* Filter & Search Bar */
        .search-input-group { position: relative; max-width: 360px; }
        .search-icon-inside {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            pointer-events: none;
        }
        .search-control-modern {
            padding-left: 2.5rem;
            border-radius: 10px;
            border: 1.5px solid #e2e8f0;
            background-color: #f8fafc;
            font-size: 0.88rem;
            font-weight: 500;
            transition: all 0.2s ease;
        }
        .search-control-modern:focus {
            background-color: #ffffff;
            border-color: var(--primary-emerald);
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.12);
            outline: none;
        }
        .btn-search-action {
            border-radius: 10px;
            padding: 0.5rem 1.15rem;
            font-weight: 600;
            font-size: 0.88rem;
            background-color: #f1f5f9;
            border: 1px solid #cbd5e1;
            color: #334155;
            transition: all 0.15s ease;
        }
        .btn-search-action:hover { background-color: #e2e8f0; color: #0f172a; }
        
        /* Modern SaaS Table */
        .table-saas-container {
            border-radius: 14px;
            overflow: hidden;
            border: 1px solid var(--card-border);
        }
        .table-saas {
            margin-bottom: 0;
            border-collapse: separate;
            border-spacing: 0;
            width: 100%;
        }
        .table-saas thead th {
            background-color: #f8fafc;
            color: #475569;
            font-size: 0.78rem;
            text-transform: uppercase;
            font-weight: 700;
            letter-spacing: 0.05em;
            padding: 1rem 1.15rem;
            border-bottom: 1px solid #e2e8f0;
            white-space: nowrap;
        }
        .table-saas tbody td {
            padding: 1.05rem 1.15rem;
            vertical-align: middle;
            border-bottom: 1px solid #f1f5f9;
            font-size: 0.9rem;
            color: var(--text-body);
            background-color: #ffffff;
            transition: background-color 0.15s ease;
        }
        .table-saas tbody tr:last-child td { border-bottom: none; }
        .table-saas tbody tr:hover td { background-color: #fbfcfe; }
        
        /* Plant Item Cell */
        .plant-brand-cell { display: inline-flex; align-items: center; gap: 10px; }
        .plant-avatar-icon {
            width: 34px;
            height: 34px;
            border-radius: 10px;
            background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%);
            color: #059669;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.05rem;
            flex-shrink: 0;
            box-shadow: 0 2px 6px rgba(16, 185, 129, 0.15);
        }
        .plant-name-title { font-weight: 700; color: #0f172a; font-size: 0.92rem; line-height: 1.2; }
        .species-pill {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 10px;
            border-radius: 6px;
            background: #f1f5f9;
            color: #475569;
            font-size: 0.8rem;
            font-weight: 500;
        }
        
        /* Moisture Range Pill */
        .moisture-range-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 12px;
            border-radius: 9999px;
            background-color: #e0f2fe;
            color: #0369a1;
            font-weight: 700;
            font-size: 0.82rem;
            border: 1px solid #bae6fd;
        }
        .moisture-not-set {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            color: #94a3b8;
            font-size: 0.82rem;
            font-style: italic;
        }
        
        /* Table Action Buttons */
        .btn-table-edit {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 0.8rem;
            font-weight: 600;
            padding: 4px 11px;
            border-radius: 8px;
            background-color: #fffbeb;
            color: #b45309;
            border: 1px solid #fde68a;
            text-decoration: none;
            transition: all 0.15s ease;
        }
        .btn-table-edit:hover { background-color: #fef3c7; color: #92400e; transform: translateY(-1px); }
        .btn-table-delete {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 0.8rem;
            font-weight: 600;
            padding: 4px 11px;
            border-radius: 8px;
            background-color: #fff1f2;
            color: #e11d48;
            border: 1px solid #fecdd3;
            text-decoration: none;
            transition: all 0.15s ease;
        }
        .btn-table-delete:hover { background-color: #ffe4e6; color: #be123c; transform: translateY(-1px); }
        
        /* Pagination SaaS */
        .pagination-saas .page-link {
            border-radius: 8px !important;
            margin: 0 3px;
            border: 1px solid #e2e8f0;
            color: #475569;
            font-weight: 600;
            font-size: 0.86rem;
            padding: 0.45rem 0.9rem;
            transition: all 0.2s ease;
        }
        .pagination-saas .page-link:hover { background-color: #f1f5f9; color: #0f172a; }
        .pagination-saas .page-item.active .page-link {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            border-color: transparent;
            color: #ffffff;
            box-shadow: 0 3px 8px rgba(16, 185, 129, 0.25);
        }
        
        /* Empty State */
        .empty-state-card { padding: 3.5rem 2rem; text-align: center; }
        .empty-state-icon-box {
            width: 72px;
            height: 72px;
            border-radius: 50%;
            background: #ecfdf5;
            color: #10b981;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 2.2rem;
            margin-bottom: 1.25rem;
            box-shadow: 0 4px 16px rgba(16, 185, 129, 0.15);
        }
    </style>
</head>
<body>
    <!-- Navbar chung của hệ thống (Giữ nguyên) -->
    <jsp:include page="navbar.jsp" />
    
    <main class="container py-4">
        <!-- Main Card Wrapper -->
        <div class="saas-card">
            <!-- Header: Tiêu đề trang & Nút Thêm Mới -->
            <div class="d-flex flex-column flex-sm-row justify-content-between align-items-start align-items-sm-center gap-3 mb-4 pb-2 border-bottom border-light">
                <div>
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <h3 class="mb-0 fw-bold text-dark tracking-tight" style="letter-spacing: -0.02em;">Danh mục Cây trồng</h3>
                        <span class="page-badge-plants">
                            <span class="pulse-green-dot"></span> Catalog Active
                        </span>
                    </div>
                    <p class="text-secondary small mb-0 d-flex align-items-center gap-1">
                        <i class="bi bi-flower2 text-success"></i> 
                        <span>Quản lý thông số độ ẩm lý tưởng, giống loài và chỉ dẫn chăm sóc tự động</span>
                    </p>
                </div>
                
                <!-- Nút Thêm mới gọi về Servlet với tham số action=new (Giữ nguyên) -->
                <a href="${pageContext.request.contextPath}/plants?action=new" class="btn-add-plant">
                    <i class="bi bi-plus-lg fs-6"></i> <span>Thêm Cây Mới</span>
                </a>
            </div>
            
            <!-- Form Tìm kiếm -->
            <form action="${pageContext.request.contextPath}/plants" method="GET" class="d-flex flex-wrap align-items-center gap-2 mb-4">
                <div class="search-input-group flex-grow-1 flex-sm-grow-0">
                    <i class="bi bi-search search-icon-inside"></i>
                    <input type="text" name="keyword" class="form-control search-control-modern" placeholder="Tìm tên cây hoặc loài..." value="${keyword}">
                </div>
                <button type="submit" class="btn btn-search-action">
                    <i class="bi bi-funnel me-1"></i> Tìm kiếm
                </button>
                <c:if test="${not empty keyword}">
                    <a href="${pageContext.request.contextPath}/plants" class="btn btn-sm btn-link text-decoration-none text-muted">
                        <i class="bi bi-x-circle"></i> Xóa lọc
                    </a>
                </c:if>
            </form>
            
            <!-- Bảng Dữ liệu SaaS -->
            <div class="table-saas-container mb-4">
                <table class="table-saas">
                    <thead>
                        <tr>
                            <th style="width: 8%;" class="text-center">ID</th>
                            <th style="width: 25%;">Tên Cây</th>
                            <th style="width: 18%;">Giống / Loài</th>
                            <th style="width: 18%;" class="text-center">Độ ẩm lý tưởng</th>
                            <th style="width: 20%;">Mô tả</th>
                            <th style="width: 11%;" class="text-center">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Vòng lặp in danh sách cây -->
                        <c:forEach var="p" items="${listPlant}">
                            <tr>
                                <!-- Cột 1: ID -->
                                <td class="text-center text-muted fw-semibold small">#${p.plantId}</td>
                                
                                <!-- Cột 2: Tên Cây -->
                                <td>
                                    <div class="plant-brand-cell">
                                        <div class="plant-avatar-icon"><i class="bi bi-tree-fill"></i></div>
                                        <div>
                                            <div class="plant-name-title">${p.plantName}</div>
                                            <small class="text-muted" style="font-size: 0.76rem;">Mã cây: P-${p.plantId}</small>
                                        </div>
                                    </div>
                                </td>
                                
                                <!-- Cột 3: Giống / Loài -->
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty p.species}">
                                            <span class="species-pill">
                                                <i class="bi bi-tag-fill text-muted" style="font-size: 0.72rem;"></i> <span>${p.species}</span>
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted small">&mdash;</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                
                                <!-- Cột 4: Độ ẩm (Min - Max) -->
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${not empty p.idealMoistureMin and not empty p.idealMoistureMax}">
                                            <span class="moisture-range-badge" title="Khoảng độ ẩm lý tưởng của cảm biến">
                                                <i class="bi bi-moisture"></i> <span>${p.idealMoistureMin}% &ndash; ${p.idealMoistureMax}%</span>
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="moisture-not-set">
                                                <i class="bi bi-dash-circle"></i> Chưa cài đặt
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                
                                <!-- Cột 5: Mô tả -->
                                <td>
                                    <span class="text-secondary small d-inline-block text-truncate" style="max-width: 220px;" title="${p.description}">
                                        ${not empty p.description ? p.description : '&mdash;'}
                                    </span>
                                </td>
                                
                                <!-- Cột 6: Thao tác -->
                                <td class="text-center">
                                    <div class="d-inline-flex align-items-center gap-1">
                                        <!-- Nút Sửa -->
                                        <a href="${pageContext.request.contextPath}/plants?action=edit&id=${p.plantId}" class="btn-table-edit" title="Chỉnh sửa thông tin">
                                            <i class="bi bi-pencil-square"></i> <span>Sửa</span>
                                        </a>
                                        
                                        <!-- Nút Xóa (Kèm cảnh báo Javascript) -->
                                        <a href="${pageContext.request.contextPath}/plants?action=delete&id=${p.plantId}" class="btn-table-delete" onclick="return confirm('Bạn có chắc chắn muốn xóa cây này không?');" title="Xóa cây trồng này">
                                            <i class="bi bi-trash"></i> <span>Xóa</span>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        
                        <!-- Báo lỗi / Trạng thái trống nếu không có dữ liệu -->
                        <c:if test="${empty listPlant}">
                            <tr>
                                <td colspan="6" class="p-0">
                                    <div class="empty-state-card">
                                        <div class="empty-state-icon-box"><i class="bi bi-flower3"></i></div>
                                        <h5 class="fw-bold text-dark mb-1">Không tìm thấy cây trồng nào</h5>
                                        <p class="text-muted small mb-3 max-w-sm mx-auto">
                                            Danh sách thực vật đang trống hoặc từ khóa tìm kiếm không khớp với dữ liệu nào.
                                        </p>
                                        <a href="${pageContext.request.contextPath}/plants?action=new" class="btn btn-sm btn-outline-success rounded-pill px-3">
                                            <i class="bi bi-plus-lg me-1"></i> Tạo cây mới ngay
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            
            <!-- Khối Phân trang (Pagination) -->
            <c:if test="${totalPages > 1}">
                <nav aria-label="Page navigation" class="pt-2">
                    <ul class="pagination pagination-saas justify-content-center mb-0">
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/plants?keyword=${keyword}&page=${i}">
                                    ${i}
                                </a>
                            </li>
                        </c:forEach>
                    </ul>
                </nav>
            </c:if>
            
            <!-- Footer chú thích phụ -->
            <div class="d-flex flex-column flex-sm-row justify-content-between align-items-center gap-2 mt-3 pt-2 text-muted small">
                <span><i class="bi bi-info-circle me-1"></i> Độ ẩm lý tưởng giúp hệ thống tự động kích hoạt van tưới tiêu chuẩn xác.</span>
                <span>Smart Irrigation Botanical Registry &bull; v2.4</span>
            </div>
        </div>
    </main>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>