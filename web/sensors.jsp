<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sensors - Smart Irrigation</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/dashboard.css?v=20261013e">
    <link rel="stylesheet" href="css/sensors.css?v=20261013d">
    <link rel="stylesheet" href="css/navbarResponsive.css?v=20261013a">
</head>

<body>
    <svg width="0" height="0" style="position:absolute" aria-hidden="true">
    <defs>
        <symbol id="i-logo" viewBox="0 0 24 24"><path d="M12 21a9.004 9.004 0 008.716-6.747M12 21a9.004 9.004 0 01-8.716-6.747M12 21V12m0 0a4 4 0 014-4h.5a4.5 4.5 0 014.5 4.5c0 2.4-1.8 4.3-4.2 4.5M12 12a4 4 0 00-4-4h-.5a4.5 4.5 0 00-4.5 4.5c0 2.4 1.8 4.3 4.2 4.5"/></symbol>
        <symbol id="i-drop" viewBox="0 0 24 24"><path d="M12 2.69l5.66 5.66a8 8 0 11-11.31 0z"/></symbol>
        <symbol id="i-bell" viewBox="0 0 24 24"><path d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></symbol>
        <symbol id="i-logout" viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9"/></symbol>
        <symbol id="i-menu" viewBox="0 0 24 24"><path d="M4 6h16M4 12h16M4 18h16"/></symbol>
        <symbol id="i-thermo" viewBox="0 0 24 24"><path d="M12 9v3m0 0a3 3 0 103 3V6a3 3 0 10-6 0v9a3 3 0 003-3z"/></symbol>
        <symbol id="i-humidity" viewBox="0 0 24 24"><path d="M12 2.69l5.66 5.66a8 8 0 11-11.31 0z"/></symbol>
        <symbol id="i-sprout" viewBox="0 0 24 24"><path d="M12 19V6m0 0a6 6 0 00-6 6h6m0-6a6 6 0 016 6h-6"/></symbol>
        <symbol id="i-sun" viewBox="0 0 24 24"><circle cx="12" cy="12" r="4"/><path d="M12 2v2m0 16v2M4.93 4.93l1.42 1.42m11.3 11.3 1.42 1.42M2 12h2m16 0h2M4.93 19.07l1.42-1.42m11.3-11.3 1.42-1.42"/></symbol>
        <symbol id="i-signal" viewBox="0 0 24 24"><path d="M5 12.55a11 11 0 0114 0M8.5 16.1a6 6 0 017 0M12 20h.01"/></symbol>
        <symbol id="i-clock" viewBox="0 0 24 24"><path d="M12 6v6l4 2M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></symbol>
        <symbol id="i-download" viewBox="0 0 24 24"><path d="M4 16v2a2 2 0 002 2h12a2 2 0 002-2v-2M7 10l5 5 5-5M12 15V3"/></symbol>
        <symbol id="i-refresh" viewBox="0 0 24 24"><path d="M20 7v5h-5M4 17v-5h5m10.5-2A7.5 7.5 0 006.7 6.7L4 9m16 6-2.7 2.3A7.5 7.5 0 013.5 14"/></symbol>
        <symbol id="i-check" viewBox="0 0 24 24"><path d="M5 13l4 4L19 7"/></symbol>
        <symbol id="i-warning" viewBox="0 0 24 24"><path d="M12 9v4m0 4h.01M10.3 3.9 1.8 18.2A2 2 0 003.5 21h17a2 2 0 001.7-2.8L13.7 3.9a2 2 0 00-3.4 0z"/></symbol>
        <symbol id="i-arrow" viewBox="0 0 24 24"><path d="M5 12h14m-7-7 7 7-7 7"/></symbol>
    </defs>
</svg>


<!-- ================= NAVBAR ================= -->
<%@include file="/WEB-INF/navbar.jspf"%>


<main class="dashboard-page sensor-page">
    <div class="container">
        <div class="page-header">
            <div class="page-header-left">
                <p class="section-label">Sensor monitoring</p>
                <h1>Sensors</h1>
                <p class="page-sub">Live environmental readings across your irrigation zones.</p>
            </div>
            <div class="page-actions">
                <span class="system-online" id="systemStatus">System Online</span>
                <button type="button" class="btn-ghost" id="exportBtn">
                    <svg class="icon icon-sm"><use href="#i-download"></use></svg>
                    Export CSV
                </button>
            </div>
        </div>

        <div class="status-strip sensor-status-strip">
            <div class="strip-left">
                <span class="strip-item"><strong id="activeZoneLabel">All garden zones</strong></span>
                <span class="strip-item live"><span class="live-dot"></span>LIVE SYNC</span>
                <span class="strip-item muted">Last update: <b id="lastUpdate">--:--:--</b></span>
            </div>
            <div class="strip-right">
                <label class="zone-filter-label" for="zoneFilter">View zone</label>
                <select id="zoneFilter" class="zone-filter">
                    <option value="all">All zones</option>
                    <option value="alpha">Garden A</option>
                    <option value="beta">Garden B</option>
                    <option value="gamma">Garden C</option>
                    <option value="delta">Garden D</option>
                </select>
                <span class="strip-item sensor-demo"><span class="demo-dot"></span>SIMULATED FEED</span>
            </div>
        </div>

        <section class="kpi-grid sensor-kpi-grid" aria-label="Current sensor readings">
            <article class="kpi-card sensor-kpi" data-sensor-card="temperature">
                <div class="kpi-top">
                    <div class="icon-box kpi-icon tone-red"><svg class="icon icon-md"><use href="#i-thermo"></use></svg></div>
                    <span class="kpi-label">Temperature</span>
                    <span class="badge good" id="temperatureStatus">Normal</span>
                </div>
                <h2 class="kpi-value"><span id="temperature">28.0</span> <small>°C</small></h2>
                <div class="kpi-foot"><span>Range 24–32 °C</span><svg class="spark" id="sparkTemperature" viewBox="0 0 100 32" preserveAspectRatio="none" aria-hidden="true"></svg></div>
            </article>

            <article class="kpi-card sensor-kpi" data-sensor-card="humidity">
                <div class="kpi-top">
                    <div class="icon-box kpi-icon tone-blue"><svg class="icon icon-md"><use href="#i-humidity"></use></svg></div>
                    <span class="kpi-label">Air humidity</span>
                    <span class="badge good" id="humidityStatus">Balanced</span>
                </div>
                <h2 class="kpi-value"><span id="humidity">68</span> <small>%</small></h2>
                <div class="kpi-foot"><span>Range 50–80%</span><svg class="spark" id="sparkHumidity" viewBox="0 0 100 32" preserveAspectRatio="none" aria-hidden="true"></svg></div>
            </article>

            <article class="kpi-card sensor-kpi" data-sensor-card="soil">
                <div class="kpi-top">
                    <div class="icon-box kpi-icon tone-emerald"><svg class="icon icon-md"><use href="#i-sprout"></use></svg></div>
                    <span class="kpi-label">Soil moisture</span>
                    <span class="badge good" id="soilStatus">Optimal</span>
                </div>
                <h2 class="kpi-value"><span id="soil">74</span> <small>%</small></h2>
                <div class="kpi-foot sensor-bar-foot"><div class="kpi-bar"><span id="soilBar"></span></div><span id="soilTargetFoot">Target range 30–80%</span></div>
            </article>

            <article class="kpi-card sensor-kpi" data-sensor-card="light">
                <div class="kpi-top">
                    <div class="icon-box kpi-icon tone-amber"><svg class="icon icon-md"><use href="#i-sun"></use></svg></div>
                    <span class="kpi-label">Light intensity</span>
                    <span class="badge good" id="lightStatus">Suitable</span>
                </div>
                <h2 class="kpi-value"><span id="light">72</span> <small>%</small></h2>
                <div class="kpi-foot"><span>Relative daylight</span><svg class="spark" id="sparkLight" viewBox="0 0 100 32" preserveAspectRatio="none" aria-hidden="true"></svg></div>
            </article>
        </section>

        <div class="sensor-main-grid">
            <section class="card telemetry-card" aria-labelledby="telemetryTitle">
                <div class="card-head sensor-card-head">
                    <div>
                        <p class="card-eyebrow">Realtime telemetry</p>
                        <h2 class="card-title" id="telemetryTitle">Soil moisture trend</h2>
                    </div>
                    <div class="sensor-chart-controls">
                        <div class="tabs" id="metricTabs" role="tablist" aria-label="Sensor metric">
                            <button type="button" class="tab active" data-metric="soil" role="tab" aria-selected="true">Soil</button>
                            <button type="button" class="tab" data-metric="temperature" role="tab" aria-selected="false">Temp</button>
                            <button type="button" class="tab" data-metric="humidity" role="tab" aria-selected="false">Humidity</button>
                            <button type="button" class="tab" data-metric="light" role="tab" aria-selected="false">Light</button>
                        </div>
                        <div class="tabs range-tabs" id="rangeTabs" role="group" aria-label="Chart time range">
                            <button type="button" class="tab active" data-range="1" aria-pressed="true">1H</button>
                            <button type="button" class="tab" data-range="6" aria-pressed="false">6H</button>
                            <button type="button" class="tab" data-range="24" aria-pressed="false">24H</button>
                        </div>
                    </div>
                </div>
                <div class="chart-meta">
                    <span>Current: <b id="chartCurrent">74%</b></span>
                    <span>Recommended: <b id="chartTarget">60–80%</b></span>
                    <span class="legend"><i class="legend-line"></i>Reading</span>
                    <span class="legend"><i class="legend-band"></i>Target range</span>
                </div>
                <div class="sensor-chart-wrap">
                    <svg class="sensor-chart" id="sensorChart" viewBox="0 0 720 250" role="img" aria-label="Sensor readings over time">
                        <line class="chart-gridline" x1="42" y1="16" x2="704" y2="16"></line>
                        <line class="chart-gridline" x1="42" y1="118" x2="704" y2="118"></line>
                        <line class="chart-gridline" x1="42" y1="220" x2="704" y2="220"></line>
                        <rect class="chart-target-band" x="42" y="57" width="662" height="41"></rect>
                        <path class="chart-reading-line" d="M 42 76 L 102 71 L 162 80 L 222 64 L 282 70 L 342 58 L 402 68 L 462 75 L 522 63 L 582 70 L 642 66 L 704 68"></path>
                        <circle class="chart-reading-point" cx="704" cy="68" r="5"></circle>
                    </svg>
                    <div class="chart-axis-labels" id="chartAxisLabels" aria-hidden="true"><span>60 min ago</span><span>45 min</span><span>30 min</span><span>15 min</span><span>Now</span></div>
                </div>
            </section>
        </div>

        <section class="card inventory-card" aria-labelledby="inventoryTitle">
            <div class="card-head inventory-head">
                <div>
                    <p class="card-eyebrow">Device inventory</p>
                    <h2 class="card-title" id="inventoryTitle">Sensor status</h2>
                </div>
                <button type="button" class="icon-btn refresh-btn" id="refreshBtn" aria-label="Refresh sensor readings" title="Refresh now">
                    <svg class="icon icon-md"><use href="#i-refresh"></use></svg>
                </button>
            </div>
            <div class="table-scroll">
                <table class="sensor-table">
                    <thead>
                        <tr><th>Sensor</th><th>Zone</th><th>Current reading</th><th>Recommended range</th><th>Signal</th><th>Updated</th></tr>
                    </thead>
                    <tbody>
                        <tr data-row="temperature"><td><span class="table-sensor-icon tone-red"><svg class="icon icon-sm"><use href="#i-thermo"></use></svg></span><strong>Temperature</strong></td><td><a data-zone-link href="plantManagement.jsp?zone=1">All gardens</a></td><td data-reading>28.0 °C</td><td data-target-range>24–32 °C</td><td><span class="table-signal"><i></i>Strong</span></td><td data-updated>Just now</td></tr>
                        <tr data-row="humidity"><td><span class="table-sensor-icon tone-blue"><svg class="icon icon-sm"><use href="#i-humidity"></use></svg></span><strong>Air humidity</strong></td><td><a data-zone-link href="plantManagement.jsp?zone=1">All gardens</a></td><td data-reading>68 %</td><td data-target-range>50–80 %</td><td><span class="table-signal"><i></i>Strong</span></td><td data-updated>Just now</td></tr>
                        <tr data-row="soil"><td><span class="table-sensor-icon tone-emerald"><svg class="icon icon-sm"><use href="#i-sprout"></use></svg></span><strong>Soil moisture</strong></td><td><a data-zone-link href="plantManagement.jsp?zone=1">All gardens</a></td><td data-reading>74 %</td><td data-target-range>30–80 %</td><td><span class="table-signal"><i></i>Strong</span></td><td data-updated>Just now</td></tr>
                        <tr data-row="light"><td><span class="table-sensor-icon tone-amber"><svg class="icon icon-sm"><use href="#i-sun"></use></svg></span><strong>Light intensity</strong></td><td><a data-zone-link href="plantManagement.jsp?zone=1">All gardens</a></td><td data-reading>72 %</td><td data-target-range>40–90 %</td><td><span class="table-signal"><i></i>Strong</span></td><td data-updated>Just now</td></tr>
                    </tbody>
                </table>
            </div>
        </section>

        <%!
            static String h(Object o) {
                return o == null ? "" : String.valueOf(o).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
            }
        %>
        <%
            java.util.List<model.SensorData> _rows = (java.util.List<model.SensorData>) request.getAttribute("listData");
            java.util.List<model.Pot> _pots = (java.util.List<model.Pot>) request.getAttribute("listPot");
            int _sp = request.getAttribute("currentPage") instanceof Integer ? (Integer) request.getAttribute("currentPage") : 1;
            int _st = request.getAttribute("totalPages") instanceof Integer ? (Integer) request.getAttribute("totalPages") : 1;
            int _sel = request.getAttribute("selectedPotId") instanceof Integer ? (Integer) request.getAttribute("selectedPotId") : 0;
            String _from = request.getAttribute("fromDate") == null ? "" : String.valueOf(request.getAttribute("fromDate"));
            String _to = request.getAttribute("toDate") == null ? "" : String.valueOf(request.getAttribute("toDate"));
            String _q = "potId=" + _sel + "&fromDate=" + h(_from) + "&toDate=" + h(_to) + "&page=";
            java.text.SimpleDateFormat _sf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
        %>
        <section class="card inventory-card" aria-labelledby="readingsTitle">
            <div class="card-head inventory-head">
                <div>
                    <p class="card-eyebrow">SensorReading</p>
                    <h2 class="card-title" id="readingsTitle">Reading log</h2>
                </div>
            </div>
            <%
                boolean _hasSensFilter = _sel > 0 || (_from != null && !_from.trim().isEmpty()) || (_to != null && !_to.trim().isEmpty());
            %>
            <form method="get" action="<%= request.getContextPath() %>/sensor-data" class="data-filter-bar">
                <div class="filter-field filter-field-grow">
                    <label class="filter-label" for="sensorZone">Area · Pot · Plant</label>
                    <div class="filter-control-wrap">
                        <select id="sensorZone" name="potId" class="filter-control">
                            <option value="0">All zones</option>
                            <% if (_pots != null) { for (model.Pot p : _pots) { %>
                            <option value="<%= p.getPotId() %>"<%= p.getPotId() == _sel ? " selected" : "" %>><%= h((p.getAreaName() != null ? p.getAreaName() + " · " : "") + p.getPotName() + (p.getPlantName() != null ? " · " + p.getPlantName() : "")) %></option>
                            <% } } %>
                        </select>
                    </div>
                </div>
                <div class="filter-field">
                    <label class="filter-label" for="sensorFrom">From date</label>
                    <div class="filter-control-wrap">
                        <input type="date" id="sensorFrom" name="fromDate" value="<%= h(_from) %>" class="filter-control">
                    </div>
                </div>
                <div class="filter-field">
                    <label class="filter-label" for="sensorTo">To date</label>
                    <div class="filter-control-wrap">
                        <input type="date" id="sensorTo" name="toDate" value="<%= h(_to) %>" class="filter-control">
                    </div>
                </div>
                <div class="filter-actions">
                    <button type="submit" class="btn-filter">
                        <svg class="icon icon-sm" viewBox="0 0 24 24" style="width:16px;height:16px;fill:none;stroke:currentColor;stroke-width:2;"><path d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"/></svg>
                        Filter
                    </button>
                    <% if (_hasSensFilter) { %>
                    <a href="<%= request.getContextPath() %>/sensor-data" class="btn-reset">Reset</a>
                    <% } %>
                </div>
            </form>
            <div class="table-scroll">
                <table class="sensor-table">
                    <thead><tr><th>Time</th><th>Zone</th><th>Moisture</th><th>Weight (kg)</th><th>Light (lux)</th><th>Source</th></tr></thead>
                    <tbody>
                        <% if (_rows == null || _rows.isEmpty()) { %>
                        <tr><td colspan="6">No readings found for the selected filters.</td></tr>
                        <% } else { for (model.SensorData d : _rows) { %>
                        <tr>
                            <td><%= d.getRecordedAt() == null ? "" : _sf.format(d.getRecordedAt()) %></td>
                            <td><%= h(d.getPotName()) %></td>
                            <td><%= String.format("%.1f %%", d.getMoistureLevel()) %></td>
                            <td><%= d.getWeightKg() == null ? "&mdash;" : String.format("%.2f", d.getWeightKg()) %></td>
                            <td><%= d.getLightLux() == null ? "&mdash;" : d.getLightLux() %></td>
                            <td><%= h(d.getSource()) %></td>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
            <nav style="display:flex;gap:8px;align-items:center;justify-content:flex-end;margin-top:12px;" aria-label="Reading pages">
                <% if (_sp > 1) { %><a class="btn-ghost" href="?<%= _q + (_sp - 1) %>">&laquo; Prev</a><% } %>
                <span class="results-count">Page <%= _sp %> / <%= _st %> &middot; <%= request.getAttribute("totalItems") == null ? 0 : request.getAttribute("totalItems") %> readings</span>
                <% if (_sp < _st) { %><a class="btn-ghost" href="?<%= _q + (_sp + 1) %>">Next &raquo;</a><% } %>
            </nav>
        </section>
    </div>
</main>


<footer class="footer">
    <div class="container footer-inner">
        <p class="footer-copy">© 2026 Smart Irrigation System</p>
    </div>
</footer>

<div class="toast-box" id="toastBox" aria-live="polite"></div>

<script src="<%= request.getContextPath() %>/app-data.js"></script>
<script src="js/zone-data.js?v=20261028a"></script>
<script src="js/alertCenter.js?v=20261016a"></script>
<script src="js/siteNavigation.js?v=20261016a"></script>
<script src="js/sensors.js?v=20261028a"></script>

</body>
</html>