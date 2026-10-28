<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Irrigation - Smart Irrigation</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/dashboard.css?v=20261013e">
    <link rel="stylesheet" href="css/wateringManagement.css?v=20261013e">
    <link rel="stylesheet" href="css/navbarResponsive.css?v=20261013a">

</head>

<body>
<svg width="0" height="0" style="position:absolute" aria-hidden="true">
    <defs>
        <symbol id="i-logo" viewBox="0 0 24 24"><path d="M12 21a9.004 9.004 0 008.716-6.747M12 21a9.004 9.004 0 01-8.716-6.747M12 21V12m0 0a4 4 0 014-4h.5a4.5 4.5 0 014.5 4.5c0 2.4-1.8 4.3-4.2 4.5M12 12a4 4 0 00-4-4h-.5a4.5 4.5 0 00-4.5 4.5c0 2.4 1.8 4.3 4.2 4.5"/></symbol>
        <symbol id="i-bell" viewBox="0 0 24 24"><path d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></symbol>
        <symbol id="i-logout" viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9"/></symbol>
        <symbol id="i-menu" viewBox="0 0 24 24"><path d="M4 6h16M4 12h16M4 18h16"/></symbol>
        <symbol id="i-drop" viewBox="0 0 24 24"><path d="M12 2.69l5.66 5.66a8 8 0 11-11.31 0z"/></symbol>
        <symbol id="i-clock" viewBox="0 0 24 24"><path d="M12 6v6l4 2M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></symbol>
        <symbol id="i-play" viewBox="0 0 24 24"><path d="M6 4l14 8-14 8V4z"/></symbol>
        <symbol id="i-stop" viewBox="0 0 24 24"><path d="M6 6h12v12H6z"/></symbol>
        <symbol id="i-plus" viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></symbol>
        <symbol id="i-trash" viewBox="0 0 24 24"><path d="M3 6h18M8 6V4h8v2m-9 0l1 14h8l1-14"/></symbol>
        <symbol id="i-sprout" viewBox="0 0 24 24"><path d="M12 19V6m0 0a6 6 0 00-6 6h6m0-6a6 6 0 016 6h-6"/></symbol>
        <symbol id="i-check" viewBox="0 0 24 24"><path d="M5 13l4 4L19 7"/></symbol>
        <symbol id="i-alert" viewBox="0 0 24 24"><path d="M12 9v4m0 4h.01M10.3 3.9 1.8 18.2A2 2 0 003.5 21h17a2 2 0 001.7-2.8L13.7 3.9a2 2 0 00-3.4 0z"/></symbol>
        <symbol id="i-signal" viewBox="0 0 24 24"><path d="M5 12.55a11 11 0 0114 0M8.5 16.1a6 6 0 017 0M12 20h.01"/></symbol>
    </defs>
</svg>

<%@include file="/WEB-INF/navbar.jspf"%>


<main class="dashboard-page irrigation-page">
    <div class="container">
        <div class="page-header">
            <div class="page-header-left">
                <p class="section-label">Water control</p>
                <h1>Irrigation</h1>
                <p class="page-sub">Plan efficient watering by Area, Pot, Plant thresholds and time of day.</p>
            </div>
            <div class="page-actions">
                <span class="system-online" id="systemStatus">Pump ready</span>
                <div class="segmented" id="modeToggle" role="group" aria-label="Irrigation mode">
                    <button type="button" class="seg-btn" data-mode="auto" aria-pressed="true">Auto</button>
                    <button type="button" class="seg-btn" data-mode="manual" aria-pressed="false">Manual</button>
                </div>
            </div>
        </div>

        <div class="status-strip irrigation-status-strip">
            <div class="strip-left">
                <span class="strip-item"><strong id="activeGardenName">Chậu Ban Công 1</strong></span>
                <span class="strip-item live"><span class="live-dot"></span><span id="pumpState">PUMP READY</span></span>
                <span class="strip-item muted">Soil: <b id="activeSoil">42%</b></span>
            </div>
            <div class="strip-right">
                <span class="strip-item"><svg class="icon icon-sm"><use href="#i-clock"></use></svg><span id="nextSchedule">Next run: --</span></span>
                <span class="strip-item sample-feed"><span class="sample-dot"></span>LIVE IOT CONTROL</span>
            </div>
        </div>

        <section class="kpi-grid irrigation-kpi-grid" aria-label="Water management summary">
            <article class="kpi-card">
                <div class="kpi-top"><div class="icon-box kpi-icon tone-sky"><svg class="icon icon-md"><use href="#i-drop"></use></svg></div><span class="kpi-label">Water used today</span></div>
                <h2 class="kpi-value"><span id="waterToday">0</span> <small>L</small></h2>
                <div class="kpi-foot"><span>Daily allowance 160 L</span><span class="quota-value" id="quotaPercent">0%</span></div>
                <div class="kpi-bar sky"><span id="quotaBar"></span></div>
            </article>
            <article class="kpi-card">
                <div class="kpi-top"><div class="icon-box kpi-icon tone-emerald"><svg class="icon icon-md"><use href="#i-check"></use></svg></div><span class="kpi-label">Completed runs</span></div>
                <h2 class="kpi-value"><span id="runsToday">0</span></h2>
                <div class="kpi-foot"><span>Across all gardens</span></div>
            </article>
            <article class="kpi-card">
                <div class="kpi-top"><div class="icon-box kpi-icon tone-amber"><svg class="icon icon-md"><use href="#i-clock"></use></svg></div><span class="kpi-label">Scheduled</span></div>
                <h2 class="kpi-value"><span id="activeSchedules">0</span></h2>
                <div class="kpi-foot"><span>Active watering plans</span></div>
            </article>
            <article class="kpi-card">
                <div class="kpi-top"><div class="icon-box kpi-icon tone-teal"><svg class="icon icon-md"><use href="#i-signal"></use></svg></div><span class="kpi-label">Estimated per run</span></div>
                <h2 class="kpi-value"><span id="estimatedWater">20</span> <small>L</small></h2>
                <div class="kpi-foot"><span id="estimateDetail">10 min · 2 L/min</span></div>
            </article>
        </section>

        <div class="irrigation-main-grid">
            <section class="card pump-card" aria-labelledby="pumpTitle">
                <div class="card-head">
                    <div><p class="card-eyebrow">Manual control</p><h2 class="card-title" id="pumpTitle">Pump control</h2></div>
                    <span class="pump-state-badge" id="pumpBadge">Standby</span>
                </div>

                <div class="pump-readout" id="pumpReadout">
                    <div class="pump-symbol"><svg class="icon icon-lg"><use href="#i-drop"></use></svg></div>
                    <div class="pump-readout-copy"><strong id="pumpHeadline">Ready to irrigate</strong><span id="pumpDetail">Choose a pot and watering duration.</span></div>
                    <strong class="pump-timer" id="pumpTimer">--:--</strong>
                </div>
                <div class="run-progress"><span id="runProgress"></span></div>

                <div class="pump-fields">
                    <div class="field">
                        <label for="zoneSelect">Area · Pot · Plant</label>
                        <select id="zoneSelect"></select>
                    </div>
                    <div class="field">
                        <label for="durationSelect">Duration</label>
                        <select id="durationSelect">
                            <option value="5">5 minutes</option>
                            <option value="10" selected>10 minutes</option>
                            <option value="15">15 minutes</option>
                            <option value="20">20 minutes</option>
                        </select>
                    </div>
                </div>

                <div class="soil-context">
                    <div class="soil-context-head"><span><svg class="icon icon-sm"><use href="#i-sprout"></use></svg>Current soil moisture</span><strong id="soilContextValue">42%</strong></div>
                    <div class="soil-track"><span id="soilContextBar"></span><i></i></div>
                    <div class="soil-context-foot"><span id="soilTargetRange">Target 30–60%</span><a id="sensorLink" href="sensors.jsp?zone=1">View sensor</a></div>
                </div>

                <button type="button" class="btn btn-primary btn-block pump-button" id="pumpButton">
                    <svg class="icon icon-sm"><use href="#i-play"></use></svg>Start irrigation
                </button>
                <p class="pump-note" id="pumpNote">Manual runs use the selected duration. Auto mode prioritizes pots below their plant's min moisture threshold.</p>
            </section>

            <section class="card schedule-card" aria-labelledby="scheduleTitle">
                <div class="card-head">
                    <div><p class="card-eyebrow">Watering plan</p><h2 class="card-title" id="scheduleTitle">Schedule irrigation</h2></div>
                </div>
                <form class="schedule-form" id="scheduleForm">
                    <div class="field"><label for="scheduleZone">Area · Pot · Plant</label><select id="scheduleZone"></select></div>
                    <div class="schedule-form-row">
                        <div class="field"><label for="scheduleTime">Start time</label><input type="time" id="scheduleTime" value="07:00" required></div>
                        <div class="field"><label for="scheduleDuration">Duration</label><select id="scheduleDuration"><option value="5">5 min</option><option value="10" selected>10 min</option><option value="15">15 min</option><option value="20">20 min</option></select></div>
                    </div>
                    <div class="field"><label for="scheduleFrequency">Repeat</label><select id="scheduleFrequency"><option value="daily">Every day</option><option value="weekdays">Weekdays</option><option value="once">One time</option></select></div>
                    <button type="submit" class="btn btn-soft btn-block"><svg class="icon icon-sm"><use href="#i-plus"></use></svg>Add schedule</button>
                </form>
                <div class="schedule-divider"></div>
                <div class="schedule-list-head"><strong>Active schedules</strong><span id="scheduleCount">0 plans</span></div>
                <div class="schedule-list" id="scheduleList"></div>
            </section>
        </div>

        <section class="card gardens-card" aria-labelledby="gardensTitle">
            <div class="card-head gardens-head">
                <div><p class="card-eyebrow">Area · Pot · Plant overview</p><h2 class="card-title" id="gardensTitle">Soil readiness</h2></div>
                <a class="btn-ghost" href="<%= request.getContextPath() %>/sensor-data">All sensors <svg class="icon icon-sm"><use href="#i-arrow"></use></svg></a>
            </div>
            <div class="garden-grid" id="gardenGrid"></div>
        </section>

        <section class="card runs-card" aria-labelledby="runsTitle">
            <div class="card-head">
                <div><p class="card-eyebrow">Water log</p><h2 class="card-title" id="runsTitle">Recent irrigation runs</h2></div>
                <a class="btn-ghost" href="<%= request.getContextPath() %>/history">Usage reports <svg class="icon icon-sm"><use href="#i-arrow"></use></svg></a>
            </div>
            <div class="table-scroll">
                <table class="runs-table">
                    <thead><tr><th>Garden</th><th>Started</th><th>Duration</th><th>Water used</th><th>Run type</th><th>Status</th></tr></thead>
                    <tbody id="runHistory"></tbody>
                </table>
            </div>
            <p class="empty-runs" id="emptyRuns" hidden>No irrigation runs recorded yet.</p>
        </section>
    </div>
</main>


<footer class="footer">
    <div class="container footer-inner"><p class="footer-copy">© 2026 Smart Irrigation System</p></div>
</footer>

<div class="toast-box" id="toastBox" aria-live="polite"></div>
<script src="<%= request.getContextPath() %>/app-data.js"></script>
<script src="js/zone-data.js?v=20261028a"></script>
<script src="js/alertCenter.js?v=20261016a"></script>
<script src="js/siteNavigation.js?v=20261016a"></script>
<script src="js/irrigationSchedules.js?v=20261016a"></script>
<script src="js/irrigationHistory.js?v=20261016a"></script>
<script src="js/wateringManagement.js?v=20261028a"></script>

</body>
</html>
