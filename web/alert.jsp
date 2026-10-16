<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alerts - Smart Irrigation</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/dashboard.css?v=20261013e">
    <link rel="stylesheet" href="css/alert.css?v=20261013c">
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
        <symbol id="i-warning" viewBox="0 0 24 24"><path d="M12 9v4m0 4h.01M10.3 3.9 1.8 18.2A2 2 0 003.5 21h17a2 2 0 001.7-2.8L13.7 3.9a2 2 0 00-3.4 0z"/></symbol>
        <symbol id="i-drop" viewBox="0 0 24 24"><path d="M12 2.69l5.66 5.66a8 8 0 11-11.31 0z"/></symbol>
        <symbol id="i-thermo" viewBox="0 0 24 24"><path d="M12 9v3m0 0a3 3 0 103 3V6a3 3 0 10-6 0v9a3 3 0 003-3z"/></symbol>
        <symbol id="i-signal" viewBox="0 0 24 24"><path d="M5 12.55a11 11 0 0114 0M8.5 16.1a6 6 0 017 0M12 20h.01"/></symbol>
        <symbol id="i-check" viewBox="0 0 24 24"><path d="M5 13l4 4L19 7"/></symbol>
        <symbol id="i-close" viewBox="0 0 24 24"><path d="M18 6 6 18M6 6l12 12"/></symbol>
        <symbol id="i-clock" viewBox="0 0 24 24"><path d="M12 6v6l4 2M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></symbol>
        <symbol id="i-filter" viewBox="0 0 24 24"><path d="M4 7h16M7 12h10m-7 5h4"/></symbol>
    </defs>
</svg>

<%@include file="/WEB-INF/navbar.jspf"%>

<main class="dashboard-page alert-page">
    <div class="container">
        <div class="page-header">
            <div class="page-header-left">
                <p class="section-label">System notifications</p>
                <h1>Alerts</h1>
                <p class="page-sub">Review irrigation, sensor and system events.</p>
            </div>
            <div class="page-actions">
                <span class="system-online" id="feedStatus">Alert feed active</span>
                <button type="button" class="btn-ghost" id="markAllReadBtn">
                    <svg class="icon icon-sm"><use href="#i-check"></use></svg>
                    Mark all read
                </button>
            </div>
        </div>

        <div class="status-strip alert-status-strip">
            <div class="strip-left">
                <span class="strip-item"><strong>Garden Node #01</strong></span>
                <span class="strip-item live"><span class="live-dot"></span>EVENT STREAM</span>
                <span class="strip-item muted">Latest event: <b id="latestEvent">--</b></span>
            </div>
            <div class="strip-right">
                <span class="strip-item sample-feed"><span class="sample-dot"></span>DATABASE FEED</span>
                <span class="strip-item"><b id="openAlertCount">0</b> open alerts</span>
            </div>
        </div>

        <section class="alert-summary-grid" aria-label="Alert summary">
            <article class="alert-summary-card">
                <div class="alert-summary-icon tone-rose"><svg class="icon icon-md"><use href="#i-bell"></use></svg></div>
                <div><span class="alert-summary-label">Unread</span><strong id="unreadCount">0</strong></div>
            </article>
            <article class="alert-summary-card">
                <div class="alert-summary-icon tone-red"><svg class="icon icon-md"><use href="#i-warning"></use></svg></div>
                <div><span class="alert-summary-label">Critical</span><strong id="criticalCount">0</strong></div>
            </article>
            <article class="alert-summary-card">
                <div class="alert-summary-icon tone-amber"><svg class="icon icon-md"><use href="#i-filter"></use></svg></div>
                <div><span class="alert-summary-label">Warnings</span><strong id="warningCount">0</strong></div>
            </article>
            <article class="alert-summary-card">
                <div class="alert-summary-icon tone-emerald"><svg class="icon icon-md"><use href="#i-check"></use></svg></div>
                <div><span class="alert-summary-label">Information</span><strong id="infoCount">0</strong></div>
            </article>
        </section>

        <section class="alert-center" aria-labelledby="alertCenterTitle">
            <div class="alert-center-head">
                <div>
                    <p class="card-eyebrow">Activity log</p>
                    <h2 class="card-title" id="alertCenterTitle">Recent alerts</h2>
                </div>
                <label class="alert-search" for="alertSearch">
                    <svg class="icon icon-sm"><use href="#i-filter"></use></svg>
                    <input id="alertSearch" type="search" placeholder="Search alerts..." autocomplete="off">
                </label>
            </div>

            <div class="alert-toolbar">
                <div class="tabs alert-tabs" id="alertFilters" role="tablist" aria-label="Filter alerts">
                    <button type="button" class="tab active" data-filter="all" role="tab" aria-selected="true">All <span id="allFilterCount">0</span></button>
                    <button type="button" class="tab" data-filter="critical" role="tab" aria-selected="false">Critical <span id="criticalFilterCount">0</span></button>
                    <button type="button" class="tab" data-filter="warning" role="tab" aria-selected="false">Warning <span id="warningFilterCount">0</span></button>
                    <button type="button" class="tab" data-filter="info" role="tab" aria-selected="false">Information <span id="infoFilterCount">0</span></button>
                </div>
                <span class="results-count" id="resultsCount" aria-live="polite">0 alerts</span>
            </div>

            <div class="alert-feed" id="alertFeed" aria-live="polite"></div>
            <div class="alert-empty" id="alertEmpty" hidden>
                <div class="empty-icon"><svg class="icon icon-lg"><use href="#i-check"></use></svg></div>
                <h3>No alerts found</h3>
                <p>Try another filter or search term.</p>
            </div>

            <%
                Object cpObj = request.getAttribute("currentPage");
                Object tpObj = request.getAttribute("totalPages");
                int curPage = cpObj instanceof Integer ? (Integer) cpObj : 1;
                int totPages = tpObj instanceof Integer ? (Integer) tpObj : 1;
                String curStatus = request.getAttribute("currentStatus") == null ? "0" : String.valueOf(request.getAttribute("currentStatus"));
                if (!"0".equals(curStatus) && !"1".equals(curStatus) && !"all".equals(curStatus)) {
                    curStatus = "0";
                }
                String base = request.getContextPath() + "/alerts?status=" + curStatus + "&page=";
            %>
            <nav class="server-pager" aria-label="Alert pages" style="display:flex;gap:8px;align-items:center;justify-content:space-between;flex-wrap:wrap;margin-top:16px;">
                <div style="display:flex;gap:8px;">
                    <a class="btn-ghost" href="<%= request.getContextPath() %>/alerts?status=0">Open</a>
                    <a class="btn-ghost" href="<%= request.getContextPath() %>/alerts?status=1">Resolved</a>
                    <a class="btn-ghost" href="<%= request.getContextPath() %>/alerts?status=all">All</a>
                </div>
                <div style="display:flex;gap:8px;align-items:center;">
                    <% if (curPage > 1) { %><a class="btn-ghost" href="<%= base + (curPage - 1) %>">&laquo; Prev</a><% } %>
                    <span class="results-count">Page <%= curPage %> / <%= totPages %> &middot; <%= request.getAttribute("totalItems") == null ? 0 : request.getAttribute("totalItems") %> alerts</span>
                    <% if (curPage < totPages) { %><a class="btn-ghost" href="<%= base + (curPage + 1) %>">Next &raquo;</a><% } %>
                </div>
            </nav>
        </section>
    </div>
</main>

<footer class="footer">
    <div class="container footer-inner"><p class="footer-copy">© 2026 Smart Irrigation System</p></div>
</footer>

<div class="toast-box" id="toastBox" aria-live="polite"></div>
<script src="<%= request.getContextPath() %>/app-data.js"></script>
<script>
    /* Server-side pagination: only the current page of alerts is delivered to the feed. */
    window.SI_DATA = window.SI_DATA || {};
    window.SI_DATA.alerts = <%= request.getAttribute("pagedAlertsJson") != null ? request.getAttribute("pagedAlertsJson") : "[]" %>;
</script>
<script src="js/zone-data.js?v=20261016a"></script>
<script src="js/alertCenter.js?v=20261016a"></script>
<script src="js/siteNavigation.js?v=20261016a"></script>
<script src="js/alert.js?v=20261016a"></script>
</body>
</html>