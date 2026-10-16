<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pump Calibration - Smart Irrigation</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="css/dashboard.css?v=20261017a">
    <link rel="stylesheet" href="css/pumpCalibration.css?v=20261017a">
    <link rel="stylesheet" href="css/navbarResponsive.css?v=20261017a">
</head>

<body>

<%@include file="/WEB-INF/navbar.jspf"%>

<main class="dashboard-page calibration-page">

    <div class="container">

        <!-- ================= PAGE HEADER ================= -->
        <div class="page-header">
            <div class="page-header-left">
                <p class="section-label">DEVICE CONFIGURATION &amp; CALIBRATION</p>
                <h1>Pump Calibration</h1>
                <p class="page-sub">Calibrate pump flow rates (ml/s) to ensure accurate watering volumes and timely leak detection.</p>
            </div>
        </div>

        <%
            java.util.List<java.util.Map<String, Object>> _pumps = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("pumps");
            java.util.List<java.util.Map<String, Object>> _hist = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("history");
            if (_pumps == null) { _pumps = new java.util.ArrayList<>(); }
            if (_hist == null) { _hist = new java.util.ArrayList<>(); }
            int _calPage = request.getAttribute("currentPage") instanceof Integer ? (Integer) request.getAttribute("currentPage") : 1;
            boolean _calNext = Boolean.TRUE.equals(request.getAttribute("hasNext"));
            java.text.SimpleDateFormat _calFmt = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
            boolean _canCalibrate = _navWrite.contains("/pump-calibration");

            int _totalPumps = _pumps.size();
            int _calibratedPumps = 0;
            for (java.util.Map<String, Object> _pm : _pumps) {
                if (_pm.get("flowRateMlPerSec") != null) { _calibratedPumps++; }
            }
            int _uncalibratedPumps = _totalPumps - _calibratedPumps;
        %>

        <!-- ================= CALIBRATION KPIS ================= -->
        <div class="calibration-kpis">
            <div class="calib-kpi">
                <div class="calib-kpi-icon tone-emerald">
                    <svg class="icon icon-md" viewBox="0 0 24 24" style="width:22px;height:22px;fill:none;stroke:currentColor;stroke-width:2;"><path d="M12 21a9.004 9.004 0 008.716-6.747M12 21a9.004 9.004 0 01-8.716-6.747M12 21V12m0 0a4 4 0 014-4h.5a4.5 4.5 0 014.5 4.5c0 2.4-1.8 4.3-4.2 4.5M12 12a4 4 0 00-4-4h-.5a4.5 4.5 0 00-4.5 4.5c0 2.4 1.8 4.3 4.2 4.5"/></svg>
                </div>
                <div class="calib-kpi-body">
                    <p>Total Pumps</p>
                    <h3><%= _totalPumps %></h3>
                </div>
            </div>

            <div class="calib-kpi">
                <div class="calib-kpi-icon <%= _uncalibratedPumps > 0 ? "tone-amber" : "tone-emerald" %>">
                    <svg class="icon icon-md" viewBox="0 0 24 24" style="width:22px;height:22px;fill:none;stroke:currentColor;stroke-width:2;"><path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                </div>
                <div class="calib-kpi-body">
                    <p>Calibration Status</p>
                    <h3><%= _calibratedPumps %> <span style="font-size:14px;font-weight:600;color:<%= _uncalibratedPumps > 0 ? "#d97706" : "#059669" %>;">/ <%= _totalPumps %> calibrated</span></h3>
                </div>
            </div>

            <div class="calib-kpi">
                <div class="calib-kpi-icon tone-blue">
                    <svg class="icon icon-md" viewBox="0 0 24 24" style="width:22px;height:22px;fill:none;stroke:currentColor;stroke-width:2;"><path d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>
                </div>
                <div class="calib-kpi-body">
                    <p>Nominal Flow Target</p>
                    <h3><%= String.format("%.0f", util.AppConfig.PUMP_FLOW_LITERS_PER_MINUTE) %> <span style="font-size:14px;font-weight:600;color:#64748b;">L/min (~200 ml/s)</span></h3>
                </div>
            </div>
        </div>

        <!-- ================= MAIN 2-COLUMN GRID ================= -->
        <div class="calibration-grid">

            <!-- Card 1: Registered Pumps & Status -->
            <div class="card">
                <div class="card-header-flex">
                    <div>
                        <h2>
                            <svg class="icon icon-sm" viewBox="0 0 24 24" style="width:20px;height:20px;fill:none;stroke:#059669;stroke-width:2;"><path d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/></svg>
                            Current Pumps &amp; Flow Rates
                        </h2>
                        <p>Real-time calibrated output for each registered irrigation pump.</p>
                    </div>
                </div>

                <% if (_pumps.isEmpty()) { %>
                    <div style="padding:32px 16px;text-align:center;color:#64748b;">
                        <svg class="icon icon-lg" viewBox="0 0 24 24" style="width:36px;height:36px;margin-bottom:8px;fill:none;stroke:#94a3b8;stroke-width:1.5;"><path d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
                        <p style="margin:0;font-weight:600;">No pumps registered yet.</p>
                    </div>
                <% } %>

                <div class="pump-item-list">
                    <% for (java.util.Map<String, Object> p : _pumps) {
                           Object flow = p.get("flowRateMlPerSec");
                           Object at = p.get("calibratedAt");
                           boolean isCalibrated = flow != null;
                    %>
                    <div class="pump-card-box">
                        <div class="pump-card-header">
                            <div class="pump-title-wrap">
                                <div class="pump-avatar-icon">
                                    <svg class="icon icon-sm" viewBox="0 0 24 24" style="width:18px;height:18px;fill:none;stroke:currentColor;stroke-width:2;"><path d="M12 21a9.004 9.004 0 008.716-6.747M12 21a9.004 9.004 0 01-8.716-6.747M12 21V12m0 0a4 4 0 014-4h.5a4.5 4.5 0 014.5 4.5c0 2.4-1.8 4.3-4.2 4.5M12 12a4 4 0 00-4-4h-.5a4.5 4.5 0 00-4.5 4.5c0 2.4 1.8 4.3 4.2 4.5"/></svg>
                                </div>
                                <div>
                                    <div class="pump-name-text"><%= p.get("pumpName") %></div>
                                    <div class="pump-zone-text"><%= p.get("potName") %></div>
                                </div>
                            </div>
                            <span class="flow-rate-badge <%= isCalibrated ? "calibrated" : "uncalibrated" %>">
                                <%= isCalibrated ? String.format("%.2f ml/s", ((Double) flow)) : "Needs Calibration" %>
                            </span>
                        </div>

                        <div class="pump-card-stats">
                            <div class="pump-stat-col">
                                <span>Flow Rate</span>
                                <strong><%= isCalibrated ? String.format("%.2f ml/s", ((Double) flow)) : "Unset" %></strong>
                            </div>
                            <div class="pump-stat-col">
                                <span>Last Calibrated</span>
                                <strong><%= at == null ? "&mdash;" : _calFmt.format((java.util.Date) at) %></strong>
                            </div>
                            <div class="pump-stat-col">
                                <span>Technician</span>
                                <strong><%= p.get("calibratedByName") == null ? "&mdash;" : p.get("calibratedByName") %></strong>
                            </div>
                        </div>

                        <% if (_canCalibrate) { %>
                        <button type="button" class="btn-select-pump" onclick="selectPump(<%= p.get("pumpId") %>)">
                            Calibrate this pump &rarr;
                        </button>
                        <% } %>
                    </div>
                    <% } %>
                </div>
            </div>

            <!-- Card 2: New Calibration Form -->
            <div class="card">
                <div class="card-header-flex">
                    <div>
                        <h2>
                            <svg class="icon icon-sm" viewBox="0 0 24 24" style="width:20px;height:20px;fill:none;stroke:#059669;stroke-width:2;"><path d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"/></svg>
                            New Calibration Test
                        </h2>
                        <p>Measure and record water volume to calibrate pump flow rate.</p>
                    </div>
                </div>

                <div class="calib-instructions" style="margin-bottom:16px;">
                    <strong>Calibration Steps:</strong>
                    1. Direct emitter output into a measuring beaker.
                    2. Run pump for a timed interval.
                    3. Record the volume (ml) and duration (s) below.
                </div>

                <% if (_canCalibrate && !_pumps.isEmpty()) { %>
                <form method="post" action="<%= request.getContextPath() %>/pump-calibration" class="calibration-form" id="calibrationForm">
                    <div class="calib-field">
                        <label for="pumpId">Target Pump</label>
                        <div class="calib-input-group">
                            <select id="pumpId" name="pumpId" required>
                                <% for (java.util.Map<String, Object> p : _pumps) { %>
                                    <option value="<%= p.get("pumpId") %>"><%= p.get("pumpName") %> &mdash; <%= p.get("potName") %></option>
                                <% } %>
                            </select>
                        </div>
                    </div>

                    <div class="calib-row-2">
                        <div class="calib-field">
                            <label for="measuredMl">Measured Volume</label>
                            <div class="calib-input-group">
                                <input id="measuredMl" name="measuredMl" type="number" min="1" step="0.1" placeholder="e.g. 150" required>
                                <span class="calib-addon">ml</span>
                            </div>
                        </div>

                        <div class="calib-field">
                            <label for="durationSec">Run Time</label>
                            <div class="calib-input-group">
                                <input id="durationSec" name="durationSec" type="number" min="1" step="0.1" placeholder="e.g. 10" required>
                                <span class="calib-addon">sec</span>
                            </div>
                        </div>
                    </div>

                    <!-- Live Flow Rate Calculator Preview -->
                    <div class="flow-calc-preview">
                        <div class="flow-calc-preview-label">
                            <span>Computed Flow Rate</span>
                            <small>Flow = Measured Volume / Duration</small>
                        </div>
                        <div class="flow-calc-preview-val" id="liveFlowRate">-- ml/s</div>
                    </div>

                    <button class="btn-save-calib" id="calibrateButton" type="submit">
                        <svg class="icon icon-sm" viewBox="0 0 24 24" style="width:18px;height:18px;fill:none;stroke:currentColor;stroke-width:2;"><path d="M5 13l4 4L19 7"/></svg>
                        Save Pump Calibration
                    </button>
                </form>
                <% } else if (_pumps.isEmpty()) { %>
                    <div class="calib-readonly-notice">
                        <p>No pumps are registered in the database yet.</p>
                    </div>
                <% } else { %>
                    <div class="calib-readonly-notice">
                        <svg class="icon icon-md" viewBox="0 0 24 24" style="width:20px;height:20px;fill:none;stroke:#d97706;stroke-width:2;"><path d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
                        <span>Your role has read-only access to pump calibration. Only <strong>ADMIN</strong> and <strong>TECHNICIAN</strong> accounts can record calibration tests.</span>
                    </div>
                <% } %>
            </div>

        </div>

        <!-- ================= CALIBRATION HISTORY TABLE ================= -->
        <div class="card calibration-history">
            <div class="card-header-flex">
                <div>
                    <h2>
                        <svg class="icon icon-sm" viewBox="0 0 24 24" style="width:20px;height:20px;fill:none;stroke:#059669;stroke-width:2;"><path d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        Calibration History
                    </h2>
                    <p>Complete audit log of all pump calibration tests performed.</p>
                </div>
                <span class="badge" style="background:#f1f5f9;color:#475569;font-weight:700;">Page <%= _calPage %></span>
            </div>

            <div class="table-scroll">
                <table class="calib-table">
                    <thead>
                        <tr>
                            <th>Calibrated At</th>
                            <th>Pump &amp; Irrigation Zone</th>
                            <th>Flow Rate</th>
                            <th>Technician</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (_hist.isEmpty()) { %>
                        <tr>
                            <td colspan="4" style="text-align:center;padding:32px 16px;color:#64748b;">
                                No calibration history records found.
                            </td>
                        </tr>
                        <% } %>
                        <% for (java.util.Map<String, Object> h : _hist) { %>
                        <tr>
                            <td>
                                <div style="display:flex;align-items:center;gap:6px;">
                                    <svg class="icon icon-sm" viewBox="0 0 24 24" style="width:14px;height:14px;fill:none;stroke:#94a3b8;stroke-width:2;"><path d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
                                    <strong><%= h.get("calibratedAt") == null ? "&mdash;" : _calFmt.format((java.util.Date) h.get("calibratedAt")) %></strong>
                                </div>
                            </td>
                            <td><%= h.get("pumpName") %> &middot; <span style="color:#64748b;"><%= h.get("potName") %></span></td>
                            <td>
                                <span class="flow-rate-badge calibrated">
                                    <%= String.format("%.2f ml/s", ((Double) h.get("flowRateMlPerSec"))) %>
                                </span>
                            </td>
                            <td>
                                <span style="display:inline-flex;align-items:center;gap:6px;">
                                    <span style="display:inline-block;width:22px;height:22px;border-radius:50%;background:#e0f2fe;color:#0369a1;font-size:10px;font-weight:700;line-height:22px;text-align:center;">
                                        <%= String.valueOf(h.get("calibratedByName") == null ? "U" : h.get("calibratedByName")).substring(0, 1).toUpperCase() %>
                                    </span>
                                    <%= h.get("calibratedByName") == null ? "&mdash;" : h.get("calibratedByName") %>
                                </span>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <div class="calib-pagination">
                <% if (_calPage > 1) { %>
                    <a class="btn-ghost" href="?page=<%= _calPage - 1 %>">&laquo; Previous</a>
                <% } %>
                <span class="page-info">Page <%= _calPage %></span>
                <% if (_calNext) { %>
                    <a class="btn-ghost" href="?page=<%= _calPage + 1 %>">Next &raquo;</a>
                <% } %>
            </div>
        </div>

    </div>

</main>

<footer class="footer">
    <div class="container footer-inner">
        <p class="footer-copy">© 2026 Smart Irrigation System</p>
    </div>
</footer>

<script src="<%= request.getContextPath() %>/app-data.js"></script>
<script src="js/zone-data.js?v=20261016a"></script>
<script src="js/alertCenter.js?v=20261016a"></script>
<script src="js/siteNavigation.js?v=20261016b"></script>

<script>
    function updateLiveFlow() {
        var mlEl = document.getElementById('measuredMl');
        var secEl = document.getElementById('durationSec');
        var previewEl = document.getElementById('liveFlowRate');
        if (!mlEl || !secEl || !previewEl) return;
        var ml = parseFloat(mlEl.value);
        var sec = parseFloat(secEl.value);
        if (!isNaN(ml) && !isNaN(sec) && ml > 0 && sec > 0) {
            var rate = (ml / sec).toFixed(2);
            previewEl.textContent = rate + " ml/s";
        } else {
            previewEl.textContent = "-- ml/s";
        }
    }

    var measuredInput = document.getElementById('measuredMl');
    var durationInput = document.getElementById('durationSec');
    if (measuredInput) measuredInput.addEventListener('input', updateLiveFlow);
    if (durationInput) durationInput.addEventListener('input', updateLiveFlow);

    function selectPump(pumpId) {
        var pumpSelect = document.getElementById('pumpId');
        if (pumpSelect) {
            pumpSelect.value = pumpId;
            var formEl = document.getElementById('calibrationForm');
            if (formEl) {
                formEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
            if (measuredInput) {
                measuredInput.focus();
            }
        }
    }
</script>

</body>
</html>