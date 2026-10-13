<%-- 
    Document   : plants-list
    Created on : Oct 7, 2026, 11:09:13 AM
    Author     : VNJ - Refactored to Modern Eco-Tech SaaS Dashboard
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!-- Khai báo thư viện JSTL để dùng các thẻ c:forEach, c:if -->
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Plant Management - Smart Irrigation System</title>
    
    <!-- Google Fonts: Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Bootstrap 5 & Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- CSS dùng chung của hệ thống -->
    <link href="${pageContext.request.contextPath}/css/main-style.css" rel="stylesheet">
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
                        <h3 class="mb-0 fw-bold text-dark tracking-tight">Plant Catalog</h3>
                        <span class="page-badge-plants">
                            <span class="pulse-green-dot"></span> Catalog Active
                        </span>
                    </div>
                    <p class="text-secondary small mb-0 d-flex align-items-center gap-1">
                        <i class="bi bi-flower2 text-success"></i> 
                        <span>Manage ideal moisture ranges, species, and automated care profiles</span>
                    </p>
                </div>
                
                <!-- Nút Thêm mới gọi về Servlet với tham số action=new (Giữ nguyên) -->
                <a href="${pageContext.request.contextPath}/plants?action=new" class="btn-add-plant">
                    <i class="bi bi-plus-lg fs-6"></i> <span>Add Plant</span>
                </a>
            </div>
            
            <!-- Form Search -->
            <form action="${pageContext.request.contextPath}/plants" method="GET" class="d-flex flex-wrap align-items-center gap-2 mb-4">
                <div class="search-input-group flex-grow-1 flex-sm-grow-0">
                    <i class="bi bi-search search-icon-inside"></i>
                    <input type="text" name="keyword" class="form-control search-control-modern" placeholder="Search by plant name or species..." value="${keyword}">
                </div>
                <button type="submit" class="btn btn-search-action">
                    <i class="bi bi-funnel me-1"></i> Search
                </button>
                <c:if test="${not empty keyword}">
                    <a href="${pageContext.request.contextPath}/plants" class="btn btn-sm btn-link text-decoration-none text-muted">
                        <i class="bi bi-x-circle"></i> Clear filter
                    </a>
                </c:if>
            </form>
            
            <!-- Bảng Dữ liệu SaaS -->
            <div class="table-saas-container mb-4">
                <table class="table-saas">
                    <thead>
                        <tr>
                            <th class="col-w-8 text-center"ID</th>
                            <th class="col-w-25"Plant Name</th>
                            <th class="col-w-18"Species</th>
                            <th class="col-w-18 text-center"Ideal Moisture</th>
                            <th class="col-w-20"Description</th>
                            <th class="col-w-11 text-center"Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Vòng lặp in danh sách cây -->
                        <c:forEach var="p" items="${listPlant}">
                            <tr>
                                <!-- Cột 1: ID -->
                                <td class="text-center text-muted fw-semibold small">#${p.plantId}</td>
                                
                                <!-- Cột 2: Plant Name -->
                                <td>
                                    <div class="plant-brand-cell">
                                        <div class="plant-avatar-icon"><i class="bi bi-tree-fill"></i></div>
                                        <div>
                                            <div class="plant-name-title">${p.plantName}</div>
                                            <small class="text-muted text-hint">Plant code: P-${p.plantId}</small>
                                        </div>
                                    </div>
                                </td>
                                
                                <!-- Cột 3: Species -->
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty p.species}">
                                            <span class="species-pill">
                                                <i class="bi bi-tag-fill text-muted icon-xs"></i> <span>${p.species}</span>
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
                                            <span class="moisture-range-badge" title="Ideal sensor moisture range">
                                                <i class="bi bi-moisture"></i> <span>${p.idealMoistureMin}% &ndash; ${p.idealMoistureMax}%</span>
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="moisture-not-set">
                                                <i class="bi bi-dash-circle"></i> Not configured
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                
                                <!-- Cột 5: Description -->
                                <td>
                                    <span class="text-secondary small d-inline-block text-truncate truncate-cell" title="${p.description}">
                                        ${not empty p.description ? p.description : '&mdash;'}
                                    </span>
                                </td>
                                
                                <!-- Cột 6: Actions -->
                                <td class="text-center">
                                    <div class="d-inline-flex align-items-center gap-1">
                                        <!-- Nút Edit -->
                                        <a href="${pageContext.request.contextPath}/plants?action=edit&id=${p.plantId}" class="btn-table-edit" title="Edit details">
                                            <i class="bi bi-pencil-square"></i> <span>Edit</span>
                                        </a>
                                        
                                        <!-- Nút Delete (Kèm cảnh báo Javascript) -->
                                        <a href="${pageContext.request.contextPath}/plants?action=delete&id=${p.plantId}" class="btn-table-delete" onclick="return confirm('Are you sure you want to delete this plant?');" title="Delete this plant">
                                            <i class="bi bi-trash"></i> <span>Delete</span>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        
                        <!-- Báo lỗi / Status trống nếu không có dữ liệu -->
                        <c:if test="${empty listPlant}">
                            <tr>
                                <td colspan="6" class="p-0">
                                    <div class="empty-state-card">
                                        <div class="empty-state-icon-box"><i class="bi bi-flower3"></i></div>
                                        <h5 class="fw-bold text-dark mb-1">No plants found</h5>
                                        <p class="text-muted small mb-3 max-w-sm mx-auto">
                                            The catalog is empty, or your search did not match any records.
                                        </p>
                                        <a href="${pageContext.request.contextPath}/plants?action=new" class="btn btn-sm btn-outline-success rounded-pill px-3">
                                            <i class="bi bi-plus-lg me-1"></i> Create a plant now
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
        </div>
    </main>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="footer.jsp" />
</body>
</html>