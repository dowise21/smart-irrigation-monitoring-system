<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Khu vực tưới/Chậu - Smart Irrigation</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/app.css" rel="stylesheet">
</head>
<body>
    <!-- Navbar -->
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
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="page-title mb-0">Danh sách Chậu / Khu vực tưới</h2>
            <a href="${pageContext.request.contextPath}/pots?action=new" class="btn btn-primary">
                + Thêm Chậu Mới
            </a>
        </div>

        <!-- Bảng Dữ liệu -->
        <table class="table table-hover table-bordered">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Tên Chậu</th>
                    <th>Vị trí</th>
                    <th>Đang trồng cây</th>
                    <th class="text-center">Trạng thái</th>
                    <th class="text-center">Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="p" items="${listPot}">
                    <tr>
                        <td>${p.potId}</td>
                        <td><strong>${p.potName}</strong></td>
                        <td>${p.location}</td>
                        <td><span class="text-success fw-bold">${p.plantName}</span></td>
                        <td class="text-center">
                            <!-- Hiển thị huy hiệu Trạng thái -->
                            <c:choose>
                                <c:when test="${p.status}">
                                    <span class="badge bg-success">Đang tưới</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-danger">Tạm ngưng</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center">
                            <a href="${pageContext.request.contextPath}/pots?action=edit&id=${p.potId}" 
                               class="btn btn-warning btn-sm">Sửa</a>
                            
                            <a href="${pageContext.request.contextPath}/pots?action=delete&id=${p.potId}" 
                               class="btn btn-danger btn-sm"
                               onclick="return confirm('Bạn có chắc chắn muốn xóa chậu này không?');">Xóa</a>
                        </td>
                    </tr>
                </c:forEach>
                
                <c:if test="${empty listPot}">
                    <tr>
                        <td colspan="6" class="text-center text-muted py-3">Chưa có chậu cây nào được tạo.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</body>
</html>