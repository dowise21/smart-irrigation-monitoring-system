<%-- 
    Document   : pot-form
    Created on : Oct 7, 2026, 11:27:43 AM
    Author     : VNJ
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>${pot != null ? 'Cập nhật' : 'Thêm mới'} Chậu - Smart Irrigation</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/app.css" rel="stylesheet">
</head>
<body>
    <div class="container d-flex justify-content-center mt-5">
        <div class="card p-4" style="width: 100%; max-width: 500px;">
            <h3 class="page-title text-center mb-4 text-success">
                ${pot != null ? 'CẬP NHẬT CHẬU CÂY' : 'THÊM CHẬU MỚI'}
            </h3>
            
            <form action="${pageContext.request.contextPath}/pots" method="POST">
                <input type="hidden" name="action" value="${pot != null ? 'update' : 'insert'}">
                
                <c:if test="${pot != null}">
                    <input type="hidden" name="potId" value="${pot.potId}">
                </c:if>

                <div class="mb-3">
                    <label class="form-label fw-bold">Tên Chậu / Khu vực <span class="text-danger">*</span></label>
                    <input type="text" name="potName" class="form-control" required value="${pot.potName}" 
                           placeholder="VD: Chậu Ban Công 1">
                </div>

                <div class="mb-3">
                    <label class="form-label fw-bold">Vị trí đặt</label>
                    <input type="text" name="location" class="form-control" value="${pot.location}" 
                           placeholder="VD: Tầng 2, góc trái">
                </div>

                <div class="mb-3">
                    <label class="form-label fw-bold">Chọn loại cây đang trồng <span class="text-danger">*</span></label>
                    <select name="plantId" class="form-select" required>
                        <option value="">-- Chọn một loại cây --</option>
                        <!-- Đổ danh sách cây từ Database vào Dropdown -->
                        <c:forEach var="pl" items="${listPlant}">
                            <option value="${pl.plantId}" ${pot.plantId == pl.plantId ? 'selected' : ''}>
                                ${pl.plantName}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="mb-4 form-check form-switch">
                    <!-- Nếu tạo mới (pot == null) thì mặc định check, nếu update thì tùy giá trị cũ -->
                    <input class="form-check-input" type="checkbox" id="statusSwitch" name="status" 
                           ${(pot == null || pot.status) ? 'checked' : ''}>
                    <label class="form-check-label fw-bold" for="statusSwitch">Kích hoạt tưới tự động</label>
                </div>

                <div class="d-flex justify-content-between">
                    <a href="${pageContext.request.contextPath}/pots" class="btn btn-secondary">Quay lại danh sách</a>
                    <button type="submit" class="btn btn-success">Lưu thông tin</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
