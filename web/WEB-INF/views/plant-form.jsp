<%-- 
    Document   : plant-form
    Created on : Oct 7, 2026, 11:10:08 AM
    Author     : VNJ
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <!-- Tiêu đề tự động đổi chữ -->
    <title>${plant != null ? 'Cập nhật' : 'Thêm mới'} Cây trồng - Smart Irrigation</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/app.css" rel="stylesheet">
</head>
<body>
    <div class="container d-flex justify-content-center mt-5">
        <div class="card p-4" style="width: 100%; max-width: 600px;">
            <h3 class="page-title text-center mb-4 text-success">
                ${plant != null ? 'CẬP NHẬT CÂY TRỒNG' : 'THÊM CÂY MỚI'}
            </h3>
            
            <form action="${pageContext.request.contextPath}/plants" method="POST">
                <!-- Tham số ẩn để Controller biết là thực hiện Insert hay Update -->
                <input type="hidden" name="action" value="${plant != null ? 'update' : 'insert'}">
                
                <!-- ID bị ẩn đi, chỉ có giá trị khi Update -->
                <c:if test="${plant != null}">
                    <input type="hidden" name="plantId" value="${plant.plantId}">
                </c:if>

                <div class="mb-3">
                    <label class="form-label fw-bold">Tên cây <span class="text-danger">*</span></label>
                    <input type="text" name="plantName" class="form-control" required value="${plant.plantName}">
                </div>

                <div class="mb-3">
                    <label class="form-label fw-bold">Giống/Loài</label>
                    <input type="text" name="species" class="form-control" value="${plant.species}">
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Độ ẩm lý tưởng Tối thiểu (%)</label>
                        <!-- type="number" step="0.1" cho phép nhập số thập phân -->
                        <input type="number" step="0.1" name="idealMoistureMin" class="form-control" value="${plant.idealMoistureMin}">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Độ ẩm lý tưởng Tối đa (%)</label>
                        <input type="number" step="0.1" name="idealMoistureMax" class="form-control" value="${plant.idealMoistureMax}">
                    </div>
                </div>

                <div class="mb-4">
                    <label class="form-label fw-bold">Mô tả thêm</label>
                    <textarea name="description" class="form-control" rows="3">${plant.description}</textarea>
                </div>

                <div class="d-flex justify-content-between">
                    <a href="${pageContext.request.contextPath}/plants" class="btn btn-secondary">Quay lại danh sách</a>
                    <button type="submit" class="btn btn-success">Lưu thông tin</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
