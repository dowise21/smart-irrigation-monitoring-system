

<%-- 
    Document   : dashboard
    Created on : Oct 7, 2026, 11:30:46 AM
    Author     : VNJ - Refactored to Modern Eco-Tech SaaS Dashboard
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Smart Irrigation System</title>
    
    <!-- Google Fonts: Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Bootstrap 5 & Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="${pageContext.request.contextPath}/css/main-style.css" rel="stylesheet">
    
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <jsp:include page="navbar.jsp" />

    <main class="container py-4">
        <!-- Tiêu đề & Nút Xuất Báo cáo -->
        <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3 mb-4">
            <div>
                <div class="d-flex align-items-center gap-2 mb-1">
                    <h2 class="mb-0 fw-bold text-dark tracking-tighter">System Overview</h2>
                    <span class="page-badge">
                        <span class="pulse-dot"></span> Online
                    </span>
                </div>
                <p class="text-secondary small mb-0 d-flex align-items-center gap-1">
                    <i class="bi bi-broadcast text-success"></i> 
                    <span>Automated irrigation &bull; Real-time telemetry updates</span>
                </p>
            </div>
            
            <a href="${pageContext.request.contextPath}/export-history" class="btn btn-saas-primary rounded-pill px-4 py-2 fw-semibold d-inline-flex align-items-center text-decoration-none">
                <i class="bi bi-file-earmark-spreadsheet me-2 fs-6"></i>
                <span>Export CSV Report</span>
            </a>
        </div>
        
        <!-- Dải 4 KPI Cards -->
        <div class="row g-3 g-xl-4 mb-4">
            <!-- Thẻ 1: Water Delivered -->
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="kpi-card-v2 border-water h-100 d-flex flex-column justify-content-between">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <span class="kpi-title">Water Delivered</span>
                            <div class="kpi-value mt-2">${waterUsed}<span class="kpi-unit">L</span></div>
                        </div>
                        <div class="metric-icon-box icon-water shadow-sm">
                            <i class="bi bi-droplet-half"></i>
                        </div>
                    </div>
                    <div class="mt-3 pt-2 border-top border-light d-flex align-items-center justify-content-between small text-muted">
                        <span>Primary supply flow</span>
                        <span class="text-info fw-semibold"><i class="bi bi-activity me-1"></i>Active</span>
                    </div>
                </div>
            </div>
            
            <!-- Thẻ 2: Water Retained -->
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="kpi-card-v2 border-retained h-100 d-flex flex-column justify-content-between">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <span class="kpi-title">Water Retained</span>
                            <div class="kpi-value mt-2 text-success">${waterRetained}<span class="kpi-unit">L</span></div>
                        </div>
                        <div class="metric-icon-box icon-retained shadow-sm">
                            <i class="bi bi-tree-fill"></i>
                        </div>
                    </div>
                    <div class="mt-3 pt-2 border-top border-light d-flex align-items-center justify-content-between small text-muted">
                        <span>Optimal plant uptake</span>
                        <span class="text-success fw-semibold"><i class="bi bi-check-circle-fill me-1"></i>Efficient</span>
                    </div>
                </div>
            </div>
            
            <!-- Thẻ 3: Water Waste -->
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="kpi-card-v2 border-waste h-100 d-flex flex-column justify-content-between">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <span class="kpi-title">Water Waste</span>
                            <div class="kpi-value mt-2 text-dark">${waterWaste}<span class="kpi-unit">L</span></div>
                        </div>
                        <div class="metric-icon-box icon-waste shadow-sm">
                            <i class="bi bi-moisture"></i>
                        </div>
                    </div>
                    <div class="mt-3 pt-2 border-top border-light d-flex align-items-center justify-content-between small text-muted">
                        <span class="text-truncate pe-2">System runoff</span>
                        <span class="text-secondary fw-semibold text-nowrap"><i class="bi bi-eye-fill me-1"></i>Monitor</span>
                    </div>
                </div>
            </div>
            
            <!-- Thẻ 4: Cảnh báo -->
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="kpi-card-v2 border-alert h-100 d-flex flex-column justify-content-between">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <span class="kpi-title">System Alerts</span>
                            <div class="kpi-value mt-2 text-danger">${alertCount}<span class="kpi-unit text-danger">Issues</span></div>
                        </div>
                        <div class="metric-icon-box icon-alert shadow-sm">
                            <i class="bi bi-exclamation-triangle-fill"></i>
                        </div>
                    </div>
                    <div class="mt-3 pt-2 border-top border-light d-flex align-items-center justify-content-between small text-muted">
                        <span>Sensor / valve status</span>
                        <span class="badge bg-danger-subtle text-danger fw-semibold px-2 py-1 rounded">Needs attention</span>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Khu vực Biểu đồ & Widget Cảnh báo -->
        <div class="row g-4">
            <!-- Cột Biểu đồ phân tích lượng nước -->
            <div class="col-lg-8">
                <div class="content-card-v2 h-100">
                    <div class="card-header-clean d-flex flex-wrap justify-content-between align-items-center gap-2">
                        <div>
                            <h6 class="mb-1 fw-bold text-dark d-flex align-items-center gap-2">
                                <i class="bi bi-bar-chart-fill text-success"></i> Water Consumption Analysis
                            </h6>
                            <p class="text-muted small mb-0">Delivered vs absorbed vs wasted water</p>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <span class="chart-legend-badge"><i class="bi bi-circle-fill text-primary me-1 icon-legend"></i>Delivered</span>
                            <span class="chart-legend-badge"><i class="bi bi-circle-fill text-success me-1 icon-legend"></i>Absorbed</span>
                            <span class="chart-legend-badge"><i class="bi bi-circle-fill text-danger me-1 icon-legend"></i>Waste</span>
                        </div>
                    </div>
                    <div class="p-3 p-md-4">
                        <div class="chart-canvas-wrap">
                            <canvas id="waterChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Cột Widget Cảnh báo Đỏ -->
            <div class="col-lg-4">
                <div class="card alert-widget-v2 h-100 p-4 d-flex flex-column justify-content-between">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-3">
                            <span class="badge bg-white bg-opacity-25 text-white px-3 py-1 rounded-pill small fw-medium">
                                <i class="bi bi-shield-fill-exclamation me-1"></i> Incident Center
                            </span>
                            <small class="text-white-50">Live</small>
                        </div>
                        
                        <div class="d-flex flex-column align-items-center text-center my-3">
                            <div class="alert-icon-ring mb-3">
                                <i class="bi bi-bell-fill"></i>
                            </div>
                            <h1 class="display-3 fw-bolder mb-0 text-white tracking-tight">${alertCount}</h1>
                            <p class="text-white-50 fw-medium mt-1 mb-0 fs-6">Incidents requiring review</p>
                        </div>
                    </div>
                    
                    <div class="pt-3">
                        <a href="${pageContext.request.contextPath}/alerts" class="btn-white-action w-100 shadow">
                            <span>Resolve alerts now</span> <i class="bi bi-arrow-right-short fs-5 ms-1"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </main>

<!-- Script Chart.js cấu hình lại Palette hiện đại -->
<script>
    // Xử lý an toàn: Nếu biến EL rỗng, gán giá trị mặc định là 0
    const valUsed = Number('${waterUsed}' || 0);
    const valRetained = Number('${waterRetained}' || 0);
    const valWaste = Number('${waterWaste}' || 0);

    const ctx = document.getElementById('waterChart').getContext('2d');
    const waterChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: ['Water Used', 'Water Retained', 'Water Waste'],
            datasets: [{
                label: ' Volume (Liters)',
                // Sử dụng các hằng số đã được xử lý an toàn
                data: [valUsed, valRetained, valWaste], 
                backgroundColor: [
                    '#0284c7', // Water Blue
                    '#10b981', // Nature Green
                    '#f43f5e'  // Alert Coral
                ],
                hoverBackgroundColor: [
                    '#0369a1',
                    '#059669',
                    '#e11d48'
                ],
                borderRadius: 10,
                borderSkipped: false,
                barPercentage: 0.55,
                categoryPercentage: 0.7
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: {
                    backgroundColor: '#0f172a',
                    titleFont: { family: 'Inter', size: 13, weight: '600' },
                    bodyFont: { family: 'Inter', size: 13 },
                    padding: 12,
                    cornerRadius: 8,
                    displayColors: false,
                    callbacks: {
                        label: function(context) {
                            return ' Volume: ' + context.parsed.y + ' L';
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { font: { family: 'Inter', size: 12 }, color: '#94a3b8', padding: 8 },
                    grid: { borderDash: [4, 4], color: '#f1f5f9', drawBorder: false }
                },
                x: {
                    ticks: { font: { family: 'Inter', size: 12, weight: '500' }, color: '#475569' },
                    grid: { display: false, drawBorder: false }
                }
            }
        }
    });
</script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="footer.jsp" />
</body>
</html>