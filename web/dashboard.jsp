<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Smart Irrigation</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="css/dashboard.css?v=20261028b">
    <link rel="stylesheet" href="css/navbarResponsive.css?v=20261013a">
</head>
<body>

<!-- ================= ICON SPRITE ================= -->
<svg width="0" height="0" style="position:absolute" aria-hidden="true">
    <defs>
        <symbol id="i-logo" viewBox="0 0 24 24"><path d="M12 21a9.004 9.004 0 008.716-6.747M12 21a9.004 9.004 0 01-8.716-6.747M12 21V12m0 0a4 4 0 014-4h.5a4.5 4.5 0 014.5 4.5c0 2.4-1.8 4.3-4.2 4.5M12 12a4 4 0 00-4-4h-.5a4.5 4.5 0 00-4.5 4.5c0 2.4 1.8 4.3 4.2 4.5"/></symbol>
        <symbol id="i-drop" viewBox="0 0 24 24"><path d="M12 2.69l5.66 5.66a8 8 0 11-11.31 0z"/></symbol>
        <symbol id="i-sprout" viewBox="0 0 24 24"><path d="M12 19V6m0 0a6 6 0 00-6 6h6m0-6a6 6 0 016 6h-6"/></symbol>
        <symbol id="i-thermo" viewBox="0 0 24 24"><path d="M12 9v3m0 0a3 3 0 103 3V6a3 3 0 10-6 0v9a3 3 0 003-3z"/></symbol>
        <symbol id="i-shower" viewBox="0 0 24 24"><path d="M4 12h16M6 12a6 6 0 0112 0M8 17v2m4-2v3m4-3v2"/></symbol>
        <symbol id="i-bolt" viewBox="0 0 24 24"><path d="M13 10V3L4 14h7v7l9-11h-7z"/></symbol>
        <symbol id="i-bell" viewBox="0 0 24 24"><path d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></symbol>
        <symbol id="i-chart" viewBox="0 0 24 24"><path d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/></symbol>
        <symbol id="i-report" viewBox="0 0 24 24"><path d="M7 12l3-3 3 3 4-4M8 21l4-4 4 4M3 4h18M4 4h16v12a2 2 0 01-2 2H6a2 2 0 01-2-2V4z"/></symbol>
        <symbol id="i-chip" viewBox="0 0 24 24"><path d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z"/></symbol>
        <symbol id="i-check" viewBox="0 0 24 24"><path d="M5 13l4 4L19 7"/></symbol>
        <symbol id="i-arrow" viewBox="0 0 24 24"><path d="M5 12h14m-7-7l7 7-7 7"/></symbol>
        <symbol id="i-play" viewBox="0 0 24 24"><path d="M6 4l14 8-14 8V4z"/></symbol>
        <symbol id="i-stop" viewBox="0 0 24 24"><path d="M6 6h12v12H6z"/></symbol>
        <symbol id="i-download" viewBox="0 0 24 24"><path d="M4 16v2a2 2 0 002 2h12a2 2 0 002-2v-2M7 10l5 5 5-5M12 15V3"/></symbol>
        <symbol id="i-clock" viewBox="0 0 24 24"><path d="M12 6v6l4 2M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></symbol>
        <symbol id="i-menu" viewBox="0 0 24 24"><path d="M4 6h16M4 12h16M4 18h16"/></symbol>
        <symbol id="i-trash" viewBox="0 0 24 24"><path d="M3 6h18M8 6V4h8v2m-9 0l1 14h8l1-14"/></symbol>
        <symbol id="i-plus" viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></symbol>
        <symbol id="i-sparkle" viewBox="0 0 24 24"><path d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"/></symbol>
        <symbol id="i-signal" viewBox="0 0 24 24"><path d="M5 12.55a11 11 0 0114 0M8.5 16.1a6 6 0 017 0M12 20h.01"/></symbol>
        <symbol id="i-logout" viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9"/></symbol>
        <symbol id="i-history" viewBox="0 0 24 24"><path d="M3 12a9 9 0 109-9 9.75 9.75 0 00-6.74 2.74L3 8M3 3v5h5M12 7v5l4 2"/></symbol>
        <symbol id="i-nodes" viewBox="0 0 24 24"><path d="M12 8a2 2 0 100-4 2 2 0 000 4zM5 20a2 2 0 100-4 2 2 0 000 4zM19 20a2 2 0 100-4 2 2 0 000 4zM12 8v4m0 0l-6 4m6-4l6 4"/></symbol>
    </defs>
</svg>


<!-- ================= NAVBAR ================= -->
<%@include file="/WEB-INF/navbar.jspf"%>


<main class="dashboard-page">
    <div class="container">

        <!-- ================= PAGE HEADER (CLEAN & EXECUTIVE) ================= -->
        <div class="page-header">

            <div class="page-header-left">
                <div class="header-meta-row">
                    <span class="section-label">IoT Telemetry &amp; Control</span>
                    <span class="strip-item live"><span class="live-dot"></span>LIVE SYNC</span>
                    <span class="strip-item muted">Updated <b id="lastUpdate">--:--:--</b></span>
                    <span class="strip-item muted">&middot; <b id="nodesActive">4</b> Active Pots</span>
                    <span class="strip-item muted" id="stripMode" hidden>Eco-AI Cycle Armed</span>
                </div>
                <h1>System Overview</h1>
            </div>

            <div class="page-actions">

                <div class="segmented" id="modeToggle" role="group" aria-label="Control mode">
                    <button type="button" class="seg-btn" data-mode="auto">
                        <svg class="icon icon-sm"><use href="#i-sparkle"></use></svg>
                        Auto Mode
                    </button>
                    <button type="button" class="seg-btn" data-mode="manual">Manual</button>
                </div>

                <button type="button" class="btn-ghost" id="exportBtn">
                    <svg class="icon icon-sm"><use href="#i-download"></use></svg>
                    Export CSV
                </button>

            </div>

        </div>


        <!-- ================= 4 HERO KPI CARDS (DATA-FIRST) ================= -->
        <div class="kpi-grid">

            <!-- 1. Soil Moisture (Primary Metric) -->
            <div class="kpi-card kpi-hero">
                <div class="kpi-top">
                    <div class="icon-box kpi-icon tone-emerald">
                        <svg class="icon icon-md"><use href="#i-sprout"></use></svg>
                    </div>
                    <span class="kpi-label">Avg Soil Moisture</span>
                    <span class="badge good" id="soilBadge">Optimal</span>
                </div>
                <h2 class="kpi-value"><span id="soil">74</span> <small>%</small></h2>
                <div class="kpi-foot column">
                    <div class="kpi-bar"><span id="soilBar"></span></div>
                    <span id="soilTargetFoot">Target range 30–60%</span>
                </div>
            </div>

            <!-- 2. Temperature -->
            <div class="kpi-card">
                <div class="kpi-top">
                    <div class="icon-box kpi-icon tone-red">
                        <svg class="icon icon-md"><use href="#i-thermo"></use></svg>
                    </div>
                    <span class="kpi-label">Air Temperature</span>
                    <span class="badge good" id="tempBadge">Nominal</span>
                </div>
                <h2 class="kpi-value"><span id="temperature">28</span> <small>°C</small></h2>
                <div class="kpi-foot">
                    <span>DHT11 &middot; Optimal 20–30°C</span>
                    <svg class="spark" id="spkTemp" viewBox="0 0 100 32" preserveAspectRatio="none"></svg>
                </div>
            </div>

            <!-- 3. Humidity -->
            <div class="kpi-card">
                <div class="kpi-top">
                    <div class="icon-box kpi-icon tone-blue">
                        <svg class="icon icon-md"><use href="#i-drop"></use></svg>
                    </div>
                    <span class="kpi-label">Air Humidity</span>
                    <span class="badge good" id="humBadge">Balanced</span>
                </div>
                <h2 class="kpi-value"><span id="humidity">68</span> <small>%</small></h2>
                <div class="kpi-foot">
                    <span>DHT11 &middot; Optimal 50–80%</span>
                    <svg class="spark" id="spkHum" viewBox="0 0 100 32" preserveAspectRatio="none"></svg>
                </div>
            </div>

            <!-- 4. Water Usage -->
            <div class="kpi-card">
                <div class="kpi-top">
                    <div class="icon-box kpi-icon tone-sky">
                        <svg class="icon icon-md"><use href="#i-shower"></use></svg>
                    </div>
                    <span class="kpi-label">Water Delivered</span>
                    <span class="badge good" id="waterBadge">On track</span>
                </div>
                <h2 class="kpi-value"><span id="water">${waterUsed}</span> <small>L</small></h2>
                <div class="kpi-foot column">
                    <div class="kpi-bar sky"><span id="waterBar"></span></div>
                    <span id="waterQuotaText">Daily quota ${waterQuota} L</span>
                </div>
            </div>

        </div>


        <!-- ================= MAIN WORKSPACE (2 CLEAN COLUMNS) ================= -->
        <div class="dash-main">

            <!-- ---------- Cột trái: Tập trung hiển thị DATA (Chậu cây & Biểu đồ Telemetry) ---------- -->
            <div class="col">

                <!-- 1. Bảng trạng thái từng Chậu cây (Area · Pot · Plant) rộng rãi, nổi bật Data -->
                <section class="card zones-card">
                    <div class="card-head">
                        <div>
                            <p class="card-eyebrow">Area &middot; Pot &middot; Plant Status</p>
                            <h2 class="card-title">Live Soil Moisture by Pot</h2>
                        </div>
                        <a href="<%= request.getContextPath() %>/plants" class="view-all">
                            Manage Pots &amp; Thresholds
                            <svg class="icon icon-sm"><use href="#i-arrow"></use></svg>
                        </a>
                    </div>
                    <div class="zone-grid" id="zoneList"></div>
                </section>

                <!-- 2. Biểu đồ Telemetry thời gian thực -->
                <section class="card telemetry-card">

                    <div class="card-head">
                        <div>
                            <p class="card-eyebrow">Sensor trend analysis</p>
                            <h2 class="card-title" id="chartTitle">Soil Moisture</h2>
                        </div>

                        <div class="head-tools">
                            <div class="tabs" id="metricTabs" role="tablist">
                                <button type="button" class="tab" data-metric="soil">Soil</button>
                                <button type="button" class="tab" data-metric="temperature">Temp</button>
                                <button type="button" class="tab" data-metric="humidity">Humidity</button>
                            </div>
                            <div class="tabs" id="rangeTabs" role="tablist">
                                <button type="button" class="tab" data-range="1">1H</button>
                                <button type="button" class="tab" data-range="6">6H</button>
                                <button type="button" class="tab" data-range="24">24H</button>
                            </div>
                        </div>
                    </div>

                    <div class="chart-meta">
                        <span class="chart-stat-pill">Current: <b id="chartNow">74%</b></span>
                        <span class="chart-stat-pill">Target Range: <b id="chartTarget">30–60%</b></span>
                        <span class="legend"><i class="legend-line"></i>Live Reading</span>
                        <span class="legend"><i class="legend-band"></i>Safe Threshold Band</span>
                        <span class="legend"><i class="legend-pulse"></i>Watering Event</span>
                    </div>

                    <div class="chart-wrap">
                        <div class="chart" id="telemetryChart"></div>
                        <div class="chart-tooltip" id="telemetryTooltip" hidden></div>
                    </div>

                </section>

            </div>


            <!-- ---------- Cột phải: Điều khiển Bơm/Ngưỡng & Lượng nước 7 ngày ---------- -->
            <div class="col">

                <!-- 1. Trạm điều khiển Máy bơm & Ngưỡng tưới tự động -->
                <section class="card system-card">

                    <div class="card-head">
                        <div>
                            <p class="card-eyebrow">Hardware Actuator &amp; Threshold</p>
                            <h2 class="card-title">Pump Control</h2>
                        </div>

                        <span id="pumpStatus" class="status success">Ready</span>
                    </div>

                    <div class="pump-display pump-display-compact">

                        <div class="pump-ring">
                            <svg viewBox="0 0 160 160" aria-hidden="true">
                                <circle class="ring-bg" cx="80" cy="80" r="70"></circle>
                                <circle class="ring-progress" id="ringProgress" cx="80" cy="80" r="70"></circle>
                            </svg>

                            <div class="pump-circle" id="pumpCircle">
                                <svg class="icon icon-md"><use href="#i-drop"></use></svg>
                                <strong id="pumpTimer">STANDBY</strong>
                                <small id="pumpPressure">3.2 bar</small>
                            </div>
                        </div>

                        <div class="pump-summary-text">
                            <h3 id="pumpText">Pump is Ready</h3>
                            <p id="pumpSub">Select a pot to bind ESP8266 pump &amp; adjust threshold.</p>
                        </div>

                    </div>

                    <div class="pump-controls">

                        <div class="field">
                            <label for="zoneSelect">Active Pot (Area &middot; Pot &middot; Plant)</label>
                            <select id="zoneSelect"></select>
                        </div>

                        <div class="field">
                            <label>Manual Run Duration</label>
                            <div class="chips" id="durationChips">
                                <button type="button" class="chip" data-min="5">5 min</button>
                                <button type="button" class="chip" data-min="10">10 min</button>
                                <button type="button" class="chip" data-min="15">15 min</button>
                                <button type="button" class="chip" data-min="20">20 min</button>
                            </div>
                        </div>

                        <div class="field">
                            <label for="thresholdRange">
                                Auto-irrigate below (Min threshold)
                                <b id="thresholdValue">30%</b>
                            </label>
                            <input type="range" id="thresholdRange" min="10" max="90" step="1" value="30">
                        </div>

                    </div>

                    <button type="button" class="btn btn-primary btn-block" id="pumpButton">
                        Start Pump
                    </button>

                    <div class="next-schedule pump-schedule-foot">
                        <svg class="icon icon-sm"><use href="#i-clock"></use></svg>
                        <span id="nextSchedule">Next: --</span>
                        <a href="<%= request.getContextPath() %>/manual-water" class="schedule-manage-link">Schedules &rarr;</a>
                    </div>

                </section>

                <!-- 2. Biểu đồ lượng nước 7 ngày -->
                <section class="card">
                    <div class="card-head">
                        <div>
                            <p class="card-eyebrow">Consumption analytics</p>
                            <h2 class="card-title">Water Usage (Last 7 Days)</h2>
                        </div>
                        <span class="pill" id="weeklyTotal">0 L</span>
                    </div>
                    <div class="chart" id="weeklyChart"></div>
                </section>

            </div>

        </div>

        <!-- Hidden compatibility hooks for legacy widgets -->
        <div hidden aria-hidden="true">
            <span id="aiText"></span>
            <strong id="aiDuration"></strong>
            <strong id="aiWater"></strong>
            <strong id="aiSoilAfter"></strong>
            <b id="aiConfidence"></b>
            <span id="aiBar"></span>
            <button type="button" id="aiApply"></button>
            <div id="scheduleList"></div>
            <div class="sched-form">
                <input type="time" id="schedTime" value="07:00">
                <select id="schedMin"><option value="10" selected>10</option></select>
                <select id="schedZone"></select>
                <select id="schedFrequency"><option value="daily" selected>daily</option></select>
                <button type="button" id="schedAdd"></button>
            </div>
        </div>

    </div>
</main>


<!-- ================= FOOTER ================= -->
<footer class="footer">
    <div class="container footer-inner">

        <p class="footer-copy">© 2026 Smart Irrigation System</p>

    </div>
</footer>


<div id="activityList" hidden></div>
<div class="toast-box" id="toastBox" aria-live="polite"></div>

<script src="<%= request.getContextPath() %>/app-data.js"></script>
<script src="js/zone-data.js?v=20261028a"></script>
<script src="js/alertCenter.js?v=20261016a"></script>
<script src="js/siteNavigation.js?v=20261016a"></script>
<script src="js/irrigationSchedules.js?v=20261016a"></script>
<script src="js/dashboard.js?v=20261028a"></script>

</body>
</html>
