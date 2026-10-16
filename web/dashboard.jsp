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

    <link rel="stylesheet" href="css/dashboard.css?v=20261013e">
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

        <!-- ================= PAGE HEADER ================= -->
        <div class="page-header">

            <div class="page-header-left">
                <p class="section-label">Smart control center</p>
                <h1>Dashboard</h1>
                <p class="page-sub">Monitor your irrigation system in real time.</p>
            </div>

            <div class="page-actions">

                <span class="system-online">System Online</span>

                <div class="segmented" id="modeToggle" role="group" aria-label="Control mode">
                    <button type="button" class="seg-btn" data-mode="auto">
                        <svg class="icon icon-sm"><use href="#i-sparkle"></use></svg>
                        Auto
                    </button>
                    <button type="button" class="seg-btn" data-mode="manual">Manual</button>
                </div>

                <button type="button" class="btn-ghost" id="exportBtn">
                    <svg class="icon icon-sm"><use href="#i-download"></use></svg>
                    Export CSV
                </button>

            </div>

        </div>


        <!-- ================= STATUS STRIP ================= -->
        <div class="status-strip">

            <div class="strip-left">
                <span class="strip-item"><strong>Garden Node #01</strong></span>
                <span class="strip-item live"><span class="live-dot"></span>LIVE SYNC</span>
                <span class="strip-item muted">Last update: <b id="lastUpdate">--:--:--</b></span>
            </div>

            <div class="strip-right">
                <span class="strip-item">
                    <svg class="icon icon-sm"><use href="#i-nodes"></use></svg>
                    <b id="nodesActive">4</b> Nodes Active
                </span>
                <span class="strip-item">
                    <svg class="icon icon-sm"><use href="#i-sparkle"></use></svg>
                    <span id="stripMode">Eco-AI Cycle Armed</span>
                </span>
            </div>

        </div>


        <!-- ================= KPI CARDS ================= -->
        <div class="kpi-grid">

            <div class="kpi-card">
                <div class="kpi-top">
                    <div class="icon-box kpi-icon tone-red">
                        <svg class="icon icon-md"><use href="#i-thermo"></use></svg>
                    </div>
                    <span class="kpi-label">Temperature</span>
                    <span class="badge good" id="tempBadge">Nominal</span>
                </div>
                <h2 class="kpi-value"><span id="temperature">28</span> <small>°C</small></h2>
                <div class="kpi-foot">
                    <span>Baseline 24–28°C</span>
                    <svg class="spark" id="spkTemp" viewBox="0 0 100 32" preserveAspectRatio="none"></svg>
                </div>
            </div>

            <div class="kpi-card">
                <div class="kpi-top">
                    <div class="icon-box kpi-icon tone-blue">
                        <svg class="icon icon-md"><use href="#i-drop"></use></svg>
                    </div>
                    <span class="kpi-label">Humidity</span>
                    <span class="badge good" id="humBadge">Balanced</span>
                </div>
                <h2 class="kpi-value"><span id="humidity">68</span> <small>%</small></h2>
                <div class="kpi-foot">
                    <span>VPD 1.1 kPa</span>
                    <svg class="spark" id="spkHum" viewBox="0 0 100 32" preserveAspectRatio="none"></svg>
                </div>
            </div>

            <div class="kpi-card">
                <div class="kpi-top">
                    <div class="icon-box kpi-icon tone-emerald">
                        <svg class="icon icon-md"><use href="#i-sprout"></use></svg>
                    </div>
                    <span class="kpi-label">Soil Moisture</span>
                    <span class="badge good" id="soilBadge">Optimal</span>
                </div>
                <h2 class="kpi-value"><span id="soil">74</span> <small>%</small></h2>
                <div class="kpi-foot column">
                    <div class="kpi-bar"><span id="soilBar"></span></div>
                    <span>Target range 60–80%</span>
                </div>
            </div>

            <div class="kpi-card">
                <div class="kpi-top">
                    <div class="icon-box kpi-icon tone-sky">
                        <svg class="icon icon-md"><use href="#i-shower"></use></svg>
                    </div>
                    <span class="kpi-label">Water Usage</span>
                    <span class="badge good" id="waterBadge">On track</span>
                </div>
                <h2 class="kpi-value"><span id="water">${waterUsed}</span> <small>L</small></h2>
                <div class="kpi-foot column">
                    <div class="kpi-bar sky"><span id="waterBar"></span></div>
                    <span id="waterQuotaText">Database total · ${waterQuota} L daily reference</span>
                </div>
            </div>

        </div>


        <!-- ================= MAIN GRID ================= -->
        <div class="dash-main">

            <!-- ---------- Cột trái ---------- -->
            <div class="col">

                <!-- Realtime telemetry -->
                <section class="card telemetry-card">

                    <div class="card-head">
                        <div>
                            <p class="card-eyebrow">Realtime telemetry</p>
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
                        <span>Now: <b id="chartNow">74%</b></span>
                        <span>Target: <b id="chartTarget">60–80%</b></span>
                        <span class="legend"><i class="legend-line"></i>Reading</span>
                        <span class="legend"><i class="legend-band"></i>Target band</span>
                        <span class="legend"><i class="legend-pulse"></i>Irrigation pulse</span>
                    </div>

                    <div class="chart-wrap">
                        <div class="chart" id="telemetryChart"></div>
                        <div class="chart-tooltip" id="telemetryTooltip" hidden></div>
                    </div>

                </section>


                <div class="dual-grid">

                    <!-- Water usage 7 ngày -->
                    <section class="card">
                        <div class="card-head">
                            <div>
                                <p class="card-eyebrow">Water usage</p>
                                <h2 class="card-title">Last 7 days</h2>
                            </div>
                            <span class="pill" id="weeklyTotal">0 L</span>
                        </div>
                        <div class="chart" id="weeklyChart"></div>
                    </section>

                    <!-- Vùng tưới -->
                    <section class="card">
                        <div class="card-head">
                            <div>
                                <p class="card-eyebrow">Zone overview</p>
                                <h2 class="card-title">Soil by zone</h2>
                            </div>
                        </div>
                        <div class="zone-grid" id="zoneList"></div>
                    </section>

                </div>

            </div>


            <!-- ---------- Cột phải ---------- -->
            <div class="col">

                <!-- Irrigation system -->
                <section class="card system-card">

                    <div class="card-head">
                        <div>
                            <p class="card-eyebrow">Actuator node</p>
                            <h2 class="card-title">Irrigation System</h2>
                        </div>

                        <span id="pumpStatus" class="status success">Ready</span>
                    </div>


                    <div class="pump-display">

                        <div class="pump-ring">
                            <svg viewBox="0 0 160 160" aria-hidden="true">
                                <circle class="ring-bg" cx="80" cy="80" r="70"></circle>
                                <circle class="ring-progress" id="ringProgress" cx="80" cy="80" r="70"></circle>
                            </svg>

                            <div class="pump-circle" id="pumpCircle">
                                <svg class="icon icon-lg"><use href="#i-drop"></use></svg>
                                <strong id="pumpTimer">STANDBY</strong>
                                <small id="pumpPressure">3.2 bar</small>
                            </div>
                        </div>

                        <h3 id="pumpText">Pump is Ready</h3>
                        <p id="pumpSub">Control your irrigation system manually.</p>

                    </div>


                    <div class="pump-controls">

                        <div class="field">
                            <label for="zoneSelect">Zone</label>
                            <select id="zoneSelect"></select>
                        </div>

                        <div class="field">
                            <label>Duration</label>
                            <div class="chips" id="durationChips">
                                <button type="button" class="chip" data-min="5">5 min</button>
                                <button type="button" class="chip" data-min="10">10 min</button>
                                <button type="button" class="chip" data-min="15">15 min</button>
                                <button type="button" class="chip" data-min="20">20 min</button>
                            </div>
                        </div>

                        <div class="field">
                            <label for="thresholdRange">
                                Auto-irrigate below
                                <b id="thresholdValue">60%</b>
                            </label>
                            <input type="range" id="thresholdRange" min="30" max="90" step="1" value="60">
                        </div>

                    </div>


                    <button type="button" class="btn btn-primary btn-block" id="pumpButton">
                        Start Pump
                    </button>

                </section>


                <!-- AI recommendation -->
                <section class="card ai-card">

                    <div class="card-head">
                        <div>
                            <p class="card-eyebrow">ML prediction</p>
                            <h2 class="card-title">AI Recommendation</h2>
                        </div>
                        <div class="icon-box ai-icon tone-teal">
                            <svg class="icon icon-md"><use href="#i-chip"></use></svg>
                        </div>
                    </div>

                    <p class="ai-text" id="aiText">Waiting for sensor data…</p>

                    <div class="ai-grid">
                        <div class="ai-stat">
                            <span>Duration</span>
                            <strong id="aiDuration">10 min</strong>
                        </div>
                        <div class="ai-stat">
                            <span>Water</span>
                            <strong id="aiWater">20 L</strong>
                        </div>
                        <div class="ai-stat">
                            <span>Soil after</span>
                            <strong id="aiSoilAfter">80%</strong>
                        </div>
                    </div>

                    <div class="ai-confidence">
                        <div class="ai-confidence-row">
                            <span>Model confidence</span>
                            <b id="aiConfidence">90%</b>
                        </div>
                        <div class="ai-bar"><span id="aiBar"></span></div>
                    </div>

                    <button type="button" class="btn btn-soft btn-block" id="aiApply">
                        Apply recommendation
                    </button>

                </section>




            </div>

        </div>


        <!-- ================= SHORTCUTS + SCHEDULE ================= -->
        <div class="dash-bottom">

            <section class="card quick-card">

                <div class="card-head">
                    <div>
                        <p class="card-eyebrow">Shortcuts</p>
                        <h2 class="card-title">Quick Actions</h2>
                    </div>
                </div>

                <div class="quick-grid">

                    <a href="<%= request.getContextPath() %>/sensor-data" class="quick-tile">
                        <div class="icon-box tone-amber"><svg class="icon icon-md"><use href="#i-chart"></use></svg></div>
                        <div><strong>View Sensors</strong><span>Live metrics</span></div>
                        <svg class="icon icon-sm tile-arrow"><use href="#i-arrow"></use></svg>
                    </a>

                    <a href="<%= request.getContextPath() %>/manual-water" class="quick-tile">
                        <div class="icon-box tone-sky"><svg class="icon icon-md"><use href="#i-drop"></use></svg></div>
                        <div><strong>Manage Irrigation</strong><span>Timers &amp; rules</span></div>
                        <svg class="icon icon-sm tile-arrow"><use href="#i-arrow"></use></svg>
                    </a>

                    <a href="<%= request.getContextPath() %>/plants" class="quick-tile">
                        <div class="icon-box tone-emerald"><svg class="icon icon-md"><use href="#i-sprout"></use></svg></div>
                        <div><strong>Manage Plants</strong><span>Crop library</span></div>
                        <svg class="icon icon-sm tile-arrow"><use href="#i-arrow"></use></svg>
                    </a>

                    <a href="<%= request.getContextPath() %>/reports" class="quick-tile">
                        <div class="icon-box tone-rose"><svg class="icon icon-md"><use href="#i-report"></use></svg></div>
                        <div><strong>View Reports</strong><span>Usage analytics</span></div>
                        <svg class="icon icon-sm tile-arrow"><use href="#i-arrow"></use></svg>
                    </a>

                    <a href="<%= request.getContextPath() %>/alerts" class="quick-tile">
                        <div class="icon-box tone-amber"><svg class="icon icon-md"><use href="#i-bell"></use></svg></div>
                        <div><strong>View Alerts</strong><span>Garden notifications</span></div>
                        <svg class="icon icon-sm tile-arrow"><use href="#i-arrow"></use></svg>
                    </a>

                    <a href="<%= request.getContextPath() %>/history" class="quick-tile">
                        <div class="icon-box tone-purple"><svg class="icon icon-md"><use href="#i-history"></use></svg></div>
                        <div><strong>Water History</strong><span>Past cycles</span></div>
                        <svg class="icon icon-sm tile-arrow"><use href="#i-arrow"></use></svg>
                    </a>

                </div>

            </section>

                <!-- Lịch tưới -->
                <section class="card schedule-card">

                    <div class="card-head">
                        <div>
                            <p class="card-eyebrow">Water timers</p>
                            <h2 class="card-title">Schedule</h2>
                        </div>
                    </div>

                    <div class="next-schedule">
                        <svg class="icon icon-md"><use href="#i-clock"></use></svg>
                        <span id="nextSchedule">Next: --</span>
                    </div>

                    <div class="schedule-list" id="scheduleList"></div>

                    <div class="schedule-form">
                        <input type="time" id="schedTime" value="07:00" aria-label="Start time">
                        <select id="schedMin" aria-label="Duration">
                            <option value="5">5 min</option>
                            <option value="10" selected>10 min</option>
                            <option value="15">15 min</option>
                            <option value="20">20 min</option>
                        </select>
                        <select id="schedZone" aria-label="Garden"></select>
                        <select id="schedFrequency" aria-label="Repeat">
                            <option value="daily">Every day</option>
                            <option value="weekdays">Weekdays</option>
                            <option value="once">One time</option>
                        </select>
                        <button type="button" class="btn-add" id="schedAdd">
                            <svg class="icon icon-sm"><use href="#i-plus"></use></svg>
                            Add
                        </button>
                    </div>

                </section>

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
<script src="js/zone-data.js?v=20261016a"></script>
<script src="js/alertCenter.js?v=20261016a"></script>
<script src="js/siteNavigation.js?v=20261016a"></script>
<script src="js/irrigationSchedules.js?v=20261016a"></script>
<script src="js/dashboard.js?v=20261016a"></script>

</body>
</html>
