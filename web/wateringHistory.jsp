<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Water History - Smart Irrigation</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/dashboard.css?v=20261013e">
    <link rel="stylesheet" href="css/waterHistory.css?v=20261013b">
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
        <symbol id="i-check" viewBox="0 0 24 24"><path d="M5 13l4 4L19 7"/></symbol>
        <symbol id="i-chart" viewBox="0 0 24 24"><path d="M3 3v18h18M18 17V9m-5 8V5m-5 12v-5"/></symbol>
    </defs>
</svg>

<%@include file="/WEB-INF/navbar.jspf"%>

<main class="dashboard-page history-page">
    <div class="container">
        <div class="page-header">
            <div class="page-header-left">
                <p class="section-label">IRRIGATION RECORDS</p>
                <h1>Water history</h1>
                <p class="page-sub">Review completed and stopped watering sessions across your gardens.</p>
            </div>
            <div class="page-actions">
                <a href="<%= request.getContextPath() %>/export-history" class="btn-ghost">Export CSV</a>
                <a href="<%= request.getContextPath() %>/reports" class="btn-ghost">Usage reports</a>
                <a href="<%= request.getContextPath() %>/manual-water" class="btn-ghost">Manage irrigation</a>
            </div>
        </div>

        <section class="history-kpis" aria-label="Watering history summary">
            <article class="kpi-card">
                <div class="kpi-top">
                    <div class="icon-box kpi-icon tone-sky"><svg class="icon icon-md"><use href="#i-drop"></use></svg></div>
                    <span class="kpi-label">Total water used</span>
                </div>
                <h2 class="kpi-value" id="historyWater">0 L</h2>
                <div class="kpi-foot"><span>Across recorded sessions</span></div>
            </article>
            <article class="kpi-card">
                <div class="kpi-top">
                    <div class="icon-box kpi-icon tone-emerald"><svg class="icon icon-md"><use href="#i-check"></use></svg></div>
                    <span class="kpi-label">Total sessions</span>
                </div>
                <h2 class="kpi-value" id="historySessions">0</h2>
                <div class="kpi-foot"><span>Completed and stopped runs</span></div>
            </article>
            <article class="kpi-card">
                <div class="kpi-top">
                    <div class="icon-box kpi-icon tone-amber"><svg class="icon icon-md"><use href="#i-chart"></use></svg></div>
                    <span class="kpi-label">Average usage</span>
                </div>
                <h2 class="kpi-value" id="historyAverage">0 L</h2>
                <div class="kpi-foot"><span>Water per session</span></div>
            </article>
        </section>

        <section class="card history-card" aria-labelledby="historyTitle">
            <div class="card-head history-card-head">
                <div>
                    <p class="card-eyebrow">Water log</p>
                    <h2 class="card-title" id="historyTitle">All watering sessions</h2>
                </div>
                <span class="pill">Newest first</span>
            </div>
            <div class="history-filter-bar">
                <label class="history-field history-search" for="searchInput">
                    <span>Search records</span>
                    <input type="search" id="searchInput" placeholder="Garden, date, status...">
                </label>
                <label class="history-field" for="statusFilter">
                    <span>Status</span>
                    <select id="statusFilter">
                        <option value="all">All statuses</option>
                        <option value="completed">Completed</option>
                        <option value="stopped">Stopped</option>
                    </select>
                </label>
            </div>
            <div class="table-scroll history-table-scroll">
                <table class="history-table">
                    <thead>
                        <tr>
                            <th scope="col">Date</th>
                            <th scope="col">Time</th>
                            <th scope="col">Duration</th>
                            <th scope="col">Water used</th>
                            <th scope="col">Status</th>
                            <th scope="col">Garden</th>
                        </tr>
                    </thead>
                    <tbody id="historyTable"></tbody>
                </table>
            </div>
        </section>

        <%!
            static String h(Object o) {
                return o == null ? "" : String.valueOf(o).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
            }
        %>
        <%
            java.util.List<model.IrrigationHistory> _hr = (java.util.List<model.IrrigationHistory>) request.getAttribute("listHistory");
            java.util.List<model.Pot> _hp = (java.util.List<model.Pot>) request.getAttribute("listPot");
            int _hpg = request.getAttribute("currentPage") instanceof Integer ? (Integer) request.getAttribute("currentPage") : 1;
            int _htp = request.getAttribute("totalPages") instanceof Integer ? (Integer) request.getAttribute("totalPages") : 1;
            int _hsel = request.getAttribute("selectedPotId") instanceof Integer ? (Integer) request.getAttribute("selectedPotId") : 0;
            String _hst = request.getAttribute("status") == null ? "" : String.valueOf(request.getAttribute("status"));
            String _hfrom = request.getAttribute("fromDate") == null ? "" : String.valueOf(request.getAttribute("fromDate"));
            String _hto = request.getAttribute("toDate") == null ? "" : String.valueOf(request.getAttribute("toDate"));
            String _hq = "potId=" + _hsel + "&status=" + h(_hst) + "&fromDate=" + h(_hfrom) + "&toDate=" + h(_hto) + "&page=";
            java.text.SimpleDateFormat _hf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
        %>
        <section class="card history-card" aria-labelledby="sessionLogTitle">
            <div class="card-head history-card-head">
                <div>
                    <p class="card-eyebrow">WateringSession</p>
                    <h2 class="card-title" id="sessionLogTitle">Session log (server-side paging)</h2>
                </div>
            </div>
            <%
                boolean _hasHistFilter = _hsel > 0 || (_hst != null && !_hst.trim().isEmpty()) || (_hfrom != null && !_hfrom.trim().isEmpty()) || (_hto != null && !_hto.trim().isEmpty());
            %>
            <form method="get" action="<%= request.getContextPath() %>/history" class="data-filter-bar">
                <div class="filter-field filter-field-grow">
                    <label class="filter-label" for="histZone">Zone</label>
                    <div class="filter-control-wrap">
                        <select id="histZone" name="potId" class="filter-control">
                            <option value="0">All zones</option>
                            <% if (_hp != null) { for (model.Pot p : _hp) { %>
                            <option value="<%= p.getPotId() %>"<%= p.getPotId() == _hsel ? " selected" : "" %>><%= h(p.getPotName()) %></option>
                            <% } } %>
                        </select>
                    </div>
                </div>
                <div class="filter-field">
                    <label class="filter-label" for="histStatus">Status</label>
                    <div class="filter-control-wrap">
                        <select id="histStatus" name="status" class="filter-control">
                            <option value="">All statuses</option>
                            <option value="COMPLETED"<%= "COMPLETED".equals(_hst) ? " selected" : "" %>>Completed</option>
                            <option value="STOPPED"<%= "STOPPED".equals(_hst) ? " selected" : "" %>>Stopped</option>
                            <option value="RUNNING"<%= "RUNNING".equals(_hst) ? " selected" : "" %>>Running</option>
                        </select>
                    </div>
                </div>
                <div class="filter-field">
                    <label class="filter-label" for="histFrom">From date</label>
                    <div class="filter-control-wrap">
                        <input type="date" id="histFrom" name="fromDate" value="<%= h(_hfrom) %>" class="filter-control">
                    </div>
                </div>
                <div class="filter-field">
                    <label class="filter-label" for="histTo">To date</label>
                    <div class="filter-control-wrap">
                        <input type="date" id="histTo" name="toDate" value="<%= h(_hto) %>" class="filter-control">
                    </div>
                </div>
                <div class="filter-actions">
                    <button type="submit" class="btn-filter">
                        <svg class="icon icon-sm" viewBox="0 0 24 24" style="width:16px;height:16px;fill:none;stroke:currentColor;stroke-width:2;"><path d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"/></svg>
                        Filter
                    </button>
                    <% if (_hasHistFilter) { %>
                    <a href="<%= request.getContextPath() %>/history" class="btn-reset">Reset</a>
                    <% } %>
                </div>
            </form>
            <div class="table-scroll history-table-scroll">
                <table class="history-table">
                    <thead>
                        <tr><th>Time</th><th>Zone</th><th>Duration</th><th>Water (L)</th><th>Retain ratio</th><th>Status</th><th>Source</th></tr>
                    </thead>
                    <tbody>
                        <% if (_hr == null || _hr.isEmpty()) { %>
                        <tr><td colspan="7">No watering sessions found for the selected filters.</td></tr>
                        <% } else { for (model.IrrigationHistory s : _hr) { %>
                        <tr>
                            <td><%= s.getIrrigationTime() == null ? "" : _hf.format(s.getIrrigationTime()) %></td>
                            <td><%= h(s.getPotName()) %></td>
                            <td><%= s.getDurationSeconds() == null ? "&mdash;" : s.getDurationSeconds() + " s" %></td>
                            <td><%= s.getWaterAmount() == null ? "&mdash;" : String.format("%.2f", s.getWaterAmount()) %></td>
                            <td><%= s.getRetainRatio() == null ? "&mdash;" : String.format("%.0f%%", s.getRetainRatio() * 100) %></td>
                            <td><%= h(s.getStatus()) %></td>
                            <td><%= h(s.getSource()) %></td>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
            <nav style="display:flex;gap:8px;align-items:center;justify-content:flex-end;margin-top:12px;" aria-label="Session pages">
                <% if (_hpg > 1) { %><a class="btn-ghost" href="?<%= _hq + (_hpg - 1) %>">&laquo; Prev</a><% } %>
                <span class="results-count">Page <%= _hpg %> / <%= _htp %> &middot; <%= request.getAttribute("totalItems") == null ? 0 : request.getAttribute("totalItems") %> sessions</span>
                <% if (_hpg < _htp) { %><a class="btn-ghost" href="?<%= _hq + (_hpg + 1) %>">Next &raquo;</a><% } %>
            </nav>
        </section>
    </div>
</main>

<footer class="footer">
    <div class="container footer-inner"><p class="footer-copy">© 2026 Smart Irrigation System</p></div>
</footer>

<script src="<%= request.getContextPath() %>/app-data.js"></script>
<script src="js/zone-data.js?v=20261016a"></script>
<script src="js/alertCenter.js?v=20261016a"></script>
<script src="js/siteNavigation.js?v=20261016a"></script>
<script src="js/irrigationHistory.js?v=20261016a"></script>
<script src="js/waterHistory.js?v=20261016a"></script>
</body>
</html>