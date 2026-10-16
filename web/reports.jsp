<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Reports - Smart Irrigation</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/dashboard.css?v=20261013e">
    <link rel="stylesheet" href="css/reports.css?v=20261013l">
    <link rel="stylesheet" href="css/navbarResponsive.css?v=20261013a">

</head>

<body>

<svg width="0" height="0" style="position:absolute" aria-hidden="true">
    <defs>
        <symbol id="i-logo" viewBox="0 0 24 24"><path d="M12 21a9.004 9.004 0 008.716-6.747M12 21a9.004 9.004 0 01-8.716-6.747M12 21V12m0 0a4 4 0 014-4h.5a4.5 4.5 0 014.5 4.5c0 2.4-1.8 4.3-4.2 4.5M12 12a4 4 0 00-4-4h-.5a4.5 4.5 0 00-4.5 4.5c0 2.4 1.8 4.3 4.2 4.5"/></symbol>
        <symbol id="i-bell" viewBox="0 0 24 24"><path d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></symbol>
        <symbol id="i-logout" viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9"/></symbol>
        <symbol id="i-menu" viewBox="0 0 24 24"><path d="M4 6h16M4 12h16M4 18h16"/></symbol>
        <symbol id="i-download" viewBox="0 0 24 24"><path d="M4 16v2a2 2 0 002 2h12a2 2 0 002-2v-2M7 10l5 5 5-5M12 15V3"/></symbol>
    </defs>
</svg>

<%@include file="/WEB-INF/navbar.jspf"%>


<main class="dashboard-page reports-page">

    <div class="container">

        <div class="page-header">
            <div class="page-header-left">
                <p class="section-label">SYSTEM ANALYTICS</p>
                <h1>Reports</h1>
                <p class="page-sub">Water use, irrigation activity, and estimated excess by period.</p>
            </div>
        </div>


        <div class="report-toolbar">
            <div class="report-period-control">
                <label for="period">Report period</label>
                <select id="period">
                    <option value="week">This week</option>
                    <option value="month">This month</option>
                    <option value="year">This year</option>
                </select>
            </div>
            <div class="report-toolbar-end">
                <div class="report-toolbar-actions">
                    <button type="button" class="btn btn-primary" id="generateButton">Update report</button>
                    <button type="button" class="btn-ghost" id="exportReportBtn"><svg class="icon icon-sm"><use href="#i-download"></use></svg>Export CSV</button>
                </div>
                <span class="report-updated" id="reportUpdated"></span>
            </div>
        </div>


        <section class="report-kpis" aria-label="Irrigation summary">
            <article class="card report-kpi"><p>Total water used</p><h2 id="totalWater">0 L</h2><span id="waterChange">No irrigation records</span></article>
            <article class="card report-kpi report-kpi-excess"><p>Water waste</p><h2 id="excessWater">0 L</h2><span id="excessDetail">Estimated above the 80% soil target</span></article>
            <article class="card report-kpi"><p>Irrigation sessions</p><h2 id="sessionCount">0</h2><span id="sessionChange">No irrigation records</span></article>
            <article class="card report-kpi report-kpi-efficiency"><p>Estimated water efficiency</p><h2 id="efficiency">--%</h2><span id="efficiencyDetail">Delivered water minus estimated excess</span></article>
        </section>

        <section class="card water-waste-card" aria-labelledby="waterWasteTitle">
            <div class="water-waste-heading">
                <div>
                    <p class="card-eyebrow">IRRIGATION EFFICIENCY</p>
                    <h2 class="card-title" id="waterWasteTitle">Water Waste</h2>
                </div>
                <span class="water-waste-period" id="waterWastePeriod">This week</span>
            </div>
            <div class="water-waste-content">
                <div class="water-waste-metrics">
                    <div class="water-waste-total">
                        <span>Estimated water waste</span>
                        <strong id="waterWasteAmount">0 L</strong>
                        <span id="waterWasteShare">0% of water used</span>
                    </div>
                    <div class="water-within-target">
                        <span>Estimated within target</span>
                        <strong id="waterWithinTarget">0 L</strong>
                        <span id="waterWithinTargetDetail">Based on records with soil readings</span>
                    </div>
                </div>
                <div class="water-waste-details">
                    <div class="water-waste-meter" role="progressbar" aria-label="Estimated water waste share" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0"><span id="waterWasteMeter"></span></div>
                    <p class="water-waste-method" id="waterWasteMethod">Estimated from water delivered after soil moisture reaches the 80% upper target.</p>
                    <div class="water-waste-gardens" id="waterWasteGardens"></div>
                </div>
            </div>
        </section>


        <section class="card report-chart-card" aria-labelledby="usageTitle">
            <div class="report-section-heading"><div><p class="card-eyebrow">Consumption trend</p><h2 class="card-title" id="usageTitle">Water used this week</h2></div><span id="chartTotal" class="report-chart-total">0 L total</span></div>
            <div class="report-chart" id="waterChart" aria-label="Water use by day"></div>
        </section>

        <section class="card report-breakdown-card" aria-labelledby="zoneBreakdownTitle">
            <div class="report-section-heading"><div><p class="card-eyebrow">Where water went</p><h2 class="card-title" id="zoneBreakdownTitle">Garden breakdown</h2></div></div>
            <div class="table-scroll"><table class="report-table"><thead><tr><th>Garden</th><th>Sessions</th><th>Water used</th><th>Estimated excess</th></tr></thead><tbody id="zoneBreakdown"></tbody></table></div>
        </section>


        <section class="card report-summary" aria-labelledby="reportSummaryTitle">
            <div class="report-summary-main">
                <p class="card-eyebrow">PERIOD REVIEW</p>
                <h2 class="card-title" id="reportSummaryTitle">Report Summary</h2>
                <h3 class="report-summary-headline" id="summaryHeadline">No irrigation records</h3>
                <p class="report-message" id="reportMessage">Completed pump runs will appear here automatically.</p>
            </div>
            <dl class="report-summary-facts">
                <div><dt>Largest waste source</dt><dd id="summaryTopGarden">No data</dd></div>
                <div><dt>Waste vs previous period</dt><dd id="summaryWasteChange">No previous-period records</dd></div>
            </dl>
        </section>

    </div>

</main>


<footer class="footer"><div class="container footer-inner"><p class="footer-copy">© 2026 Smart Irrigation System</p></div></footer>


<script src="<%= request.getContextPath() %>/app-data.js"></script>
<script src="js/zone-data.js?v=20261016a"></script>
<script src="js/alertCenter.js?v=20261016a"></script>
<script src="js/siteNavigation.js?v=20261016a"></script>
<script src="js/irrigationHistory.js?v=20261016a"></script>
<script src="js/reports.js?v=20261016a"></script>

</body>
</html>