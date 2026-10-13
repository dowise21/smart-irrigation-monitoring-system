<%-- 
    Document   : schedule 
    Created on : Oct 8, 2026, 11:14:08 AM 
    Author     : VNJ - Refactored to Modern Eco-Tech SaaS Schedule Management 
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Irrigation Schedules - Smart Irrigation System</title>
    
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
            
            <!-- Page Header -->
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3 mb-4 pb-2 border-bottom border-light">
                <div>
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <h3 class="mb-0 fw-bold text-dark tracking-tight">
                            Automatic Irrigation Schedules
                        </h3>
                        <span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-1 rounded-pill small fw-bold">
                            <i class="bi bi-flower1 me-1"></i> Pot ID: ${potId}
                        </span>
                    </div>
                    <p class="text-secondary small mb-0 d-flex align-items-center gap-1">
                        <i class="bi bi-clock-history text-primary"></i> 
                        <span>Configure pump relay timing with a daily clock or Cron expression</span>
                    </p>
                </div>
                
                <div class="d-flex align-items-center gap-2">
                    <a href="${pageContext.request.contextPath}/pots" class="btn btn-sm btn-outline-secondary rounded-pill px-3 fw-medium">
                        <i class="bi bi-arrow-left me-1"></i> Pot List
                    </a>
                </div>
            </div>
            
            <!-- Layout 2 Cột: Thêm lịch & Danh sách lịch -->
            <div class="row g-4 align-items-stretch">
                
                <!-- Cột Trái: Khu vực Thêm lịch mới -->
                <div class="col-lg-4">
                    <div class="feature-box">
                        <div class="feature-box-header">
                            <span class="fw-bold text-dark small text-uppercase tracking-wider d-flex align-items-center gap-2">
                                <i class="bi bi-plus-circle-fill text-success fs-6"></i> Add New Schedule
                            </span>
                            <span class="badge bg-light text-muted border rounded-pill small">Auto-Sync</span>
                        </div>
                        
                        <div class="p-3 p-md-4">
                            <!-- Form POST thêm lịch tưới -->
                            <form action="${pageContext.request.contextPath}/schedules" method="POST">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="potId" value="${potId}">
                                
                                <!-- Trường 1: Time (Cron/Giờ) -->
                                <div class="mb-3">
                                    <label class="form-label-modern">
                                        <i class="bi bi-alarm text-primary"></i> 
                                        <span>Time (Cron / Clock) <span class="text-danger">*</span></span>
                                    </label>
                                    <div class="input-group-modern">
                                        <input type="text" name="cronExpression" class="form-control" placeholder="e.g. 07:30 Daily" required>
                                        <i class="bi bi-calendar2-week input-icon"></i>
                                    </div>
                                    <small class="text-muted d-block mt-1 text-hint">
                                        Enter a clock time (e.g. <code>06:30</code>) or a predefined cycle.
                                    </small>
                                </div>
                                
                                <!-- Trường 2: Pump Duration (sec) -->
                                <div class="mb-4">
                                    <label class="form-label-modern">
                                        <i class="bi bi-stopwatch text-info"></i> 
                                        <span>Pump Duration <span class="text-danger">*</span></span>
                                    </label>
                                    <div class="input-group-modern">
                                        <input type="number" name="durationSeconds" class="form-control" min="10" max="300" value="60" required placeholder="10 - 300">
                                        <i class="bi bi-droplet-half input-icon"></i>
                                        <span class="input-unit-badge">sec</span>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center mt-1">
                                        <small class="text-muted text-hint">Min: 10s</small>
                                        <small class="text-muted text-hint">Max: 300s (5 minutes)</small>
                                    </div>
                                </div>
                                
                                <!-- Nút Submit Lưu lịch -->
                                <button type="submit" class="btn-saas-primary">
                                    <i class="bi bi-check2-circle fs-5"></i> <span>Save schedule</span>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
                
                <!-- Cột Phải: Danh sách lịch đã thiết lập -->
                <div class="col-lg-8">
                    <div class="feature-box">
                        <div class="feature-box-header">
                            <span class="fw-bold text-dark small text-uppercase tracking-wider d-flex align-items-center gap-2">
                                <i class="bi bi-list-task text-primary fs-6"></i> Configured Schedules
                            </span>
                            <span class="badge bg-light text-dark border rounded-pill px-3 py-1 small fw-semibold">
                                <i class="bi bi-clock me-1"></i> Automatic cycle
                            </span>
                        </div>
                        
                        <div class="p-0">
                            <div class="table-responsive">
                                <table class="table saas-table">
                                    <thead>
                                        <tr>
                                            <th>Schedule Time</th>
                                            <th>Pump Duration</th>
                                            <th class="text-center">Status</th>
                                            <th class="text-center">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <!-- Vòng lặp in danh sách lịch tưới -->
                                        <c:forEach var="s" items="${listSchedules}">
                                            <tr>
                                                <!-- Time Cron -->
                                                <td>
                                                    <div class="cron-pill">
                                                        <i class="bi bi-alarm text-primary"></i> <span>${s.cronExpression}</span>
                                                    </div>
                                                </td>
                                                
                                                <!-- Pump Duration -->
                                                <td>
                                                    <span class="badge bg-light text-dark border px-3 py-2 rounded-pill small fw-semibold">
                                                        <i class="bi bi-stopwatch text-info me-1"></i> ${s.durationSeconds} sec
                                                    </span>
                                                </td>
                                                
                                                <!-- Status -->
                                                <td class="text-center">
                                                    <c:if test="${s.isActive}">
                                                        <span class="status-badge-active">
                                                            <span class="pulse-dot-green"></span> Enabled
                                                        </span>
                                                    </c:if>
                                                    <c:if test="${!s.isActive}">
                                                        <span class="status-badge-inactive">
                                                            <i class="bi bi-pause-circle text-muted"></i> Paused
                                                        </span>
                                                    </c:if>
                                                </td>
                                                
                                                <!-- Actions -->
                                                <td class="text-center">
                                                    <div class="d-inline-flex align-items-center gap-2">
                                                        <!-- Nút On/Off -->
                                                        <form action="${pageContext.request.contextPath}/schedules" method="POST" class="d-inline">
                                                            <input type="hidden" name="action" value="toggle">
                                                            <input type="hidden" name="potId" value="${potId}">
                                                            <input type="hidden" name="scheduleId" value="${s.scheduleId}">
                                                            <input type="hidden" name="isActive" value="${s.isActive}">
                                                            <button type="submit" class="btn-action-soft-toggle ${s.isActive ? 'active-mode' : 'inactive-mode'}" title="${s.isActive ? 'Pause this schedule' : 'Enable this schedule'}">
                                                                <i class="bi ${s.isActive ? 'bi-pause-fill' : 'bi-play-fill'}"></i>
                                                                <span>${s.isActive ? 'Off' : 'On'}</span>
                                                            </button>
                                                        </form>
                                                        
                                                        <!-- Nút Delete -->
                                                        <form action="${pageContext.request.contextPath}/schedules" method="POST" class="d-inline">
                                                            <input type="hidden" name="action" value="delete">
                                                            <input type="hidden" name="potId" value="${potId}">
                                                            <input type="hidden" name="scheduleId" value="${s.scheduleId}">
                                                            <button type="submit" class="btn-action-soft-delete" onclick="return confirm('Are you sure you want to delete this schedule?');" title="Delete schedule">
                                                                <i class="bi bi-trash3"></i> <span>Delete</span>
                                                            </button>
                                                        </form>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        
                                        <!-- Khi danh sách trống -->
                                        <c:if test="${empty listSchedules}">
                                            <tr>
                                                <td colspan="4" class="p-0">
                                                    <div class="empty-schedule-box">
                                                        <div class="empty-schedule-icon">
                                                            <i class="bi bi-calendar-x"></i>
                                                        </div>
                                                        <h6 class="fw-bold text-dark mb-1">No irrigation schedules configured</h6>
                                                        <p class="text-muted small mb-0">
                                                            Use the form on the left to create an automatic pump window for this pot.
                                                        </p>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
        </div>
    </main>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="footer.jsp" />
</body>
</html>