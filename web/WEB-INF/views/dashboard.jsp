


<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Smart Irrigation System</title>
    

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
    <style>
        :root {
            --primary-emerald: #10b981;
            --primary-dark: #047857;
            --primary-light: #ecfdf5;
            --water-blue: #0284c7;
            --water-blue-bg: #e0f2fe;
            --eco-teal: #0d9488;
            --eco-teal-bg: #ccfbf1;
            --waste-coral: #f43f5e;
            --waste-coral-bg: #ffe4e6;
            --alert-amber: #e11d48;
            --alert-amber-bg: #ffe4e6;
            --bg-canvas: #f6f8fa;
            --card-border: rgba(226, 232, 240, 0.8);
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
        
        /* Top Header Styling */
        .page-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 0.75rem;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 9999px;
            background: #dcfce7;
            color: #15803d;
            letter-spacing: 0.02em;
        }
        .pulse-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background-color: #16a34a;
            box-shadow: 0 0 0 0 rgba(22, 163, 74, 0.7);
            animation: pulse-green 2s infinite;
        }
        @keyframes pulse-green {
            0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(22, 163, 74, 0.7); }
            70% { transform: scale(1); box-shadow: 0 0 0 6px rgba(22, 163, 74, 0); }
            100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(22, 163, 74, 0); }
        }
        
        /* Action Buttons */
        .btn-saas-primary {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: #ffffff;
            border: none;
            box-shadow: 0 4px 14px rgba(16, 185, 129, 0.35);
            transition: all 0.25s ease;
        }
        .btn-saas-primary:hover {
            background: linear-gradient(135deg, #059669 0%, #047857 100%);
            color: #ffffff;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(16, 185, 129, 0.45);
        }
        
        /* KPI Card Styling */
        .kpi-card-v2 {
            position: relative;
            background: #ffffff;
            border-radius: 16px;
            border: 1px solid var(--card-border);
            padding: 1.35rem;
            box-shadow: 0 4px 20px -2px rgba(15, 23, 42, 0.04);
            transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
            overflow: hidden;
        }
        .kpi-card-v2::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            opacity: 0.9;
        }
        .kpi-card-v2.border-water::before { background: linear-gradient(90deg, #0284c7, #38bdf8); }
        .kpi-card-v2.border-retained::before { background: linear-gradient(90deg, #10b981, #34d399); }
        .kpi-card-v2.border-waste::before { background: linear-gradient(90deg, #f43f5e, #fb7185); }
        .kpi-card-v2.border-alert::before { background: linear-gradient(90deg, #e11d48, #f43f5e); }
        .kpi-card-v2:hover {
            transform: translateY(-4px);
            box-shadow: 0 16px 32px -4px rgba(15, 23, 42, 0.08);
            border-color: rgba(203, 213, 225, 0.8);
        }
        
        .metric-icon-box {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.35rem;
            flex-shrink: 0;
        }
        
        /* Modern Box Colors */
        .icon-water { background-color: var(--water-blue-bg); color: var(--water-blue); }
        .icon-retained { background-color: var(--primary-light); color: var(--primary-emerald); }
        .icon-waste { background-color: var(--waste-coral-bg); color: var(--waste-coral); }
        .icon-alert { background-color: var(--alert-amber-bg); color: var(--alert-amber); }
        
        .kpi-title {
            font-size: 0.8rem;
            text-transform: uppercase;
            font-weight: 700;
            letter-spacing: 0.04em;
            color: var(--text-muted);
        }
        .kpi-value {
            font-size: 1.85rem;
            font-weight: 800;
            line-height: 1.2;
            color: var(--text-heading);
            letter-spacing: -0.02em;
        }
        .kpi-unit {
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--text-muted);
            margin-left: 2px;
        }
        
        /* Content Card */
        .content-card-v2 {
            background: #ffffff;
            border-radius: 16px;
            border: 1px solid var(--card-border);
            box-shadow: 0 4px 20px -2px rgba(15, 23, 42, 0.04);
            overflow: hidden;
        }
        .content-card-v2 .card-header-clean {
            background: transparent;
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid #f1f5f9;
        }
        
        /* Alert SaaS Widget */
        .alert-widget-v2 {
            background: radial-gradient(circle at top right, #fb7185 0%, #e11d48 60%, #be123c 100%);
            border-radius: 16px;
            color: #ffffff;
            border: none;
            position: relative;
            overflow: hidden;
            box-shadow: 0 10px 25px rgba(225, 29, 72, 0.25);
        }
        .alert-widget-v2::after {
            content: '';
            position: absolute;
            top: -60px;
            right: -60px;
            width: 180px;
            height: 180px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.08);
            pointer-events: none;
        }
        
        .alert-icon-ring {
            width: 76px;
            height: 76px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.18);
            backdrop-filter: blur(8px);
            border: 2px solid rgba(255, 255, 255, 0.35);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.25rem;
            color: #ffffff;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
        }
        
        .btn-white-action {
            background-color: #ffffff;
            color: #be123c;
            border: none;
            font-weight: 700;
            border-radius: 9999px;
            padding: 0.65rem 1.25rem;
            transition: all 0.2s ease;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }
        .btn-white-action:hover {
            background-color: #f8fafc;
            color: #9f1239;
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(0, 0, 0, 0.15);
        }
        
        /* Subtle Chart Legend Pill */
        .chart-legend-badge {
            font-size: 0.75rem;
            padding: 4px 10px;
            border-radius: 6px;
            font-weight: 500;
            background: #f8fafc;
            color: #64748b;
            border: 1px solid #e2e8f0;
        }
    </style>
</head>
<body>
    <jsp:include page="navbar.jsp" />

    <main class="container py-4">

        <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3 mb-4">
            <div>
                <div class="d-flex align-items-center gap-2 mb-1">
                    <h2 class="mb-0 fw-bold text-dark tracking-tight" style="letter-spacing: -0.03em;">Dashboard System</h2>
                    <span class="page-badge">
                        <span class="pulse-dot"></span> Online
                    </span>
                </div>
                <p class="text-secondary small mb-0 d-flex align-items-center gap-1">
                    <i class="bi bi-broadcast text-success"></i> 
                    <span>Auto irrigation system &bull; Update real-time measurement data</span>
                </p>
            </div>
            
            <a href="${pageContext.request.contextPath}/export-history" class="btn btn-saas-primary rounded-pill px-4 py-2 fw-semibold d-inline-flex align-items-center text-decoration-none">
                <i class="bi bi-file-earmark-spreadsheet me-2 fs-6"></i>
                <span>Export CSV Report</span>
            </a>
        </div>
        

        <div class="row g-3 g-xl-4 mb-4">

            <div class="col-12 col-sm-6 col-xl-3">
                <div class="kpi-card-v2 border-water h-100 d-flex flex-column justify-content-between">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <span class="kpi-title">Water Used</span>
                            <div class="kpi-value mt-2">${waterUsed}<span class="kpi-unit">L</span></div>
                        </div>
                        <div class="metric-icon-box icon-water shadow-sm">
                            <i class="bi bi-droplet-half"></i>
                        </div>
                    </div>
                    <div class="mt-3 pt-2 border-top border-light d-flex align-items-center justify-content-between small text-muted">
                        <span>Main Supply Flow</span>
                        <span class="text-info fw-semibold"><i class="bi bi-activity me-1"></i>Active</span>
                    </div>
                </div>
            </div>
            

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
                        <span>Optimal Plant Absorption</span>
                        <span class="text-success fw-semibold"><i class="bi bi-check-circle-fill me-1"></i>Efficient</span>
                    </div>
                </div>
            </div>
            

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
                        <span>Leakage & Soil Evaporation</span>
                        <span class="text-secondary fw-medium">Moisture Monitoring</span>
                    </div>
                </div>
            </div>
            

            <div class="col-12 col-sm-6 col-xl-3">
                <div class="kpi-card-v2 border-alert h-100 d-flex flex-column justify-content-between">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <span class="kpi-title">System Alerts</span>
                            <div class="kpi-value mt-2 text-danger">${alertCount}<span class="kpi-unit text-danger">Errors</span></div>
                        </div>
                        <div class="metric-icon-box icon-alert shadow-sm">
                            <i class="bi bi-exclamation-triangle-fill"></i>
                        </div>
                    </div>
                    <div class="mt-3 pt-2 border-top border-light d-flex align-items-center justify-content-between small text-muted">
                        <span>Sensor/Valve Status</span>
                        <span class="badge bg-danger-subtle text-danger fw-semibold px-2 py-1 rounded">Needs Attention</span>
                    </div>
                </div>
            </div>
        </div>
        

        <div class="row g-4">

            <div class="col-lg-8">
                <div class="content-card-v2 h-100">
                    <div class="card-header-clean d-flex flex-wrap justify-content-between align-items-center gap-2">
                        <div>
                            <h6 class="mb-1 fw-bold text-dark d-flex align-items-center gap-2">
                                <i class="bi bi-bar-chart-fill text-success"></i> Water Consumption Analysis
                            </h6>
                            <p class="text-muted small mb-0">Comparison of supply, actual absorption, and waste</p>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <span class="chart-legend-badge"><i class="bi bi-circle-fill text-primary me-1" style="font-size: 8px;"></i>Total Supply</span>
                            <span class="chart-legend-badge"><i class="bi bi-circle-fill text-success me-1" style="font-size: 8px;"></i>Absorbed</span>
                            <span class="chart-legend-badge"><i class="bi bi-circle-fill text-danger me-1" style="font-size: 8px;"></i>Wasted</span>
                        </div>
                    </div>
                    <div class="p-3 p-md-4">
                        <div style="position: relative; height: 320px; width: 100%;">
                            <canvas id="waterChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            

            <div class="col-lg-4">
                <div class="card alert-widget-v2 h-100 p-4 d-flex flex-column justify-content-between">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-3">
                            <span class="badge bg-white bg-opacity-25 text-white px-3 py-1 rounded-pill small fw-medium">
                                <i class="bi bi-shield-fill-exclamation me-1"></i> Incident Center
                            </span>
                            <small class="text-white-50">Instant</small>
                        </div>
                        
                        <div class="d-flex flex-column align-items-center text-center my-3">
                            <div class="alert-icon-ring mb-3">
                                <i class="bi bi-bell-fill"></i>
                            </div>
                            <h1 class="display-3 fw-bolder mb-0 text-white tracking-tight">${alertCount}</h1>
                            <p class="text-white-50 fw-medium mt-1 mb-0 fs-6">Incidents require immediate check</p>
                        </div>
                    </div>
                    
                    <div class="pt-3">
                        <a href="${pageContext.request.contextPath}/alerts" class="btn-white-action w-100 shadow">
                            <span>Handle alerts now</span> <i class="bi bi-arrow-right-short fs-5 ms-1"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </main>


    <script>
        const ctx = document.getElementById('waterChart').getContext('2d');
        const waterChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['Water Used', 'Water Retained (Absorbed)', 'Water Waste (Leaked)'],
                datasets: [{
                    label: ' Volume (Liters)',
                    data: [${waterUsed}, ${waterRetained}, ${waterWaste}],
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
                                return ' Volume: ' + context.parsed.y + ' Liters';
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
</body>
</html>