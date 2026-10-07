<%-- 
    Document   : plants-list
    Created on : Oct 7, 2026, 11:09:13 AM
    Author     : VNJ
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!-- Khai báo thư viện JSTL để dùng các thẻ c:forEach, c:if -->
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Cây trồng - Smart Irrigation</title>
    <!-- Bootstrap & CSS dùng chung -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/app.css" rel="stylesheet">
</head>
<body>
    <!-- Navbar cơ bản -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-success mb-4">
        <div class="container">
            <a class="navbar-brand" href="#">Smart Irrigation</a>
            <div class="d-flex">
                <span class="navbar-text me-3 text-white">
                    Xin chào, <b>${sessionScope.LOGIN_USER.fullName}</b>
                </span>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-light btn-sm">Đăng xuất</a>
            </div>
        </div>
    </nav>

    <div class="container card py-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h2 class="page-title mb-0">Danh sách Cây trồng</h2>
            
            <!-- Nút Thêm mới gọi về Servlet với tham số action=new -->
            <a href="${pageContext.request.contextPath}/plants?action=new" class="btn btn-primary">
                + Thêm Cây Mới
            </a>
        </div>

        <!-- Form Tìm kiếm -->
        <form action="${pageContext.request.contextPath}/plants" method="GET" class="row g-2 mb-4">
            <div class="col-auto">
                <input type="text" name="keyword" class="form-control" placeholder="Tìm tên cây hoặc loài..." value="${keyword}">
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-secondary">Tìm kiếm</button>
            </div>
        </form>

        <!-- Bảng Dữ liệu -->
        <table class="table table-hover table-bordered">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Tên Cây</th>
                    <th>Giống/Loài</th>
                    <th>Độ ẩm (Min - Max)</th>
                    <th>Mô tả</th>
                    <th class="text-center">Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <!-- Vòng lặp in danh sách cây -->
                <c:forEach var="p" items="${listPlant}">
                    <tr>
                        <td>${p.plantId}</td>
                        <td><strong>${p.plantName}</strong></td>
                        <td>${p.species}</td>
                        <td>
                            <!-- Kiểm tra nếu null thì hiển thị N/A -->
                            <c:choose>
                                <c:when test="${not empty p.idealMoistureMin and not empty p.idealMoistureMax}">
                                    ${p.idealMoistureMin}% - ${p.idealMoistureMax}%
                                </c:when>
                                <c:otherwise><span class="text-muted">Chưa cài đặt</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>${p.description}</td>
                        <td class="text-center">
                            <!-- Nút Sửa -->
                            <a href="${pageContext.request.contextPath}/plants?action=edit&id=${p.plantId}" 
                               class="btn btn-warning btn-sm">Sửa</a>
                            
                            <!-- Nút Xóa (Kèm cảnh báo Javascript) -->
                            <a href="${pageContext.request.contextPath}/plants?action=delete&id=${p.plantId}" 
                               class="btn btn-danger btn-sm"
                               onclick="return confirm('Bạn có chắc chắn muốn xóa cây này không?');">Xóa</a>
                        </td>
                    </tr>
                </c:forEach>
                
                <!-- Báo lỗi nếu không có dữ liệu -->
                <c:if test="${empty listPlant}">
                    <tr>
                        <td colspan="6" class="text-center text-muted py-3">Không tìm thấy cây trồng nào.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>

        <!-- Khối Phân trang (Pagination) -->
        <c:if test="${totalPages > 1}">
            <nav>
                <ul class="pagination justify-content-center">
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

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
