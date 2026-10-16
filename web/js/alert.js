(function () {
    var zoneRegistry = window.IrrigationZones;
    var alerts = window.IrrigationAlertCenter.getAll();
    var activeFilter = "all";
    var searchQuery = "";
    var toastTimer;
    var iconBySeverity = {
        critical: "i-warning",
        warning: "i-drop",
        info: "i-check"
    };

    function byId(id) {
        return document.getElementById(id);
    }

    function escapeHtml(value) {
        return String(value).replace(/[&<>"']/g, function (character) {
            return {
                "&": "&amp;",
                "<": "&lt;",
                ">": "&gt;",
                '"': "&quot;",
                "'": "&#39;"
            }[character];
        });
    }

    function timeAgo(minutes) {
        if (minutes < 60) return minutes + (minutes === 1 ? " minute ago" : " minutes ago");
        var hours = Math.floor(minutes / 60);
        if (hours < 24) return hours + (hours === 1 ? " hour ago" : " hours ago");
        var days = Math.floor(hours / 24);
        return days + (days === 1 ? " day ago" : " days ago");
    }

    function filteredAlerts() {
        var query = searchQuery.trim().toLowerCase();
        return alerts.filter(function (alert) {
            var matchesSeverity = activeFilter === "all" || alert.severity === activeFilter;
            var searchable = [alert.title, alert.description, zoneRegistry.name(alert.zoneId), alert.node, alert.id].join(" ").toLowerCase();
            return matchesSeverity && (!query || searchable.indexOf(query) !== -1);
        });
    }

    var ctx = window.SI_CTX || "";
    var access = window.SI_ACCESS || {};
    var canResolve = !Array.isArray(access.write) || access.write.indexOf("/alerts") !== -1;
    var canOpenIrrigation = !Array.isArray(access.read) || access.read.indexOf("/manual-water") !== -1;
    var canOpenPlants = !Array.isArray(access.read) || access.read.indexOf("/plants") !== -1;

    function renderAlert(alert) {
        var readLabel = alert.unread ? "Mark read" : "Mark unread";
        var readAction = alert.unread ? "read" : "unread";
        var dismissBtn = canResolve
            ? '<button type="button" class="record-action dismiss" data-action="dismiss" aria-label="Dismiss ' + escapeHtml(alert.title) + '" title="Dismiss alert"><svg class="icon"><use href="#i-close"></use></svg></button>'
            : '';
        var irrigationBtn = canOpenIrrigation
            ? '<a class="record-action" href="' + ctx + '/manual-water?zone=' + encodeURIComponent(alert.zoneId) + '">Irrigation</a>'
            : '';
        var nodeHtml = canOpenPlants
            ? '<a href="' + ctx + '/plants?zone=' + encodeURIComponent(alert.zoneId) + '">' + escapeHtml(alert.node) + '</a>'
            : '<span>' + escapeHtml(alert.node) + '</span>';
        return '<article class="alert-record severity-' + alert.severity + (alert.unread ? " is-unread" : " is-read") + '" data-alert-id="' + escapeHtml(alert.id) + '">' +
            '<div class="record-icon"><svg class="icon icon-md"><use href="#' + escapeHtml(alert.icon || iconBySeverity[alert.severity]) + '"></use></svg></div>' +
            '<div class="record-main"><div class="record-title-line"><h3 class="record-title">' + escapeHtml(alert.title) + '</h3><span class="severity-label">' + escapeHtml(alert.severity) + '</span></div>' +
            '<p class="record-description">' + escapeHtml(alert.description) + '</p>' +
            '<div class="record-meta"><span><svg class="icon"><use href="#i-clock"></use></svg>' + timeAgo(alert.minutesAgo) + '</span><a href="' + ctx + '/sensor-data?zone=' + encodeURIComponent(alert.zoneId) + '">' + escapeHtml(zoneRegistry.name(alert.zoneId)) + '</a>' + nodeHtml + '<span>' + escapeHtml(alert.id) + '</span></div></div>' +
            '<div class="record-actions"><button type="button" class="record-action" data-action="' + readAction + '"><svg class="icon"><use href="#i-check"></use></svg>' + readLabel + '</button>' +
            irrigationBtn +
            dismissBtn + '</div></article>';
    }

    function updateCounts() {
        var openAlerts = alerts.length;
        var unread = alerts.filter(function (alert) { return alert.unread; }).length;
        var critical = alerts.filter(function (alert) { return alert.severity === "critical"; }).length;
        var warning = alerts.filter(function (alert) { return alert.severity === "warning"; }).length;
        var information = alerts.filter(function (alert) { return alert.severity === "info"; }).length;
        byId("unreadCount").textContent = unread;
        byId("criticalCount").textContent = critical;
        byId("warningCount").textContent = warning;
        byId("infoCount").textContent = information;
        byId("openAlertCount").textContent = openAlerts;
        byId("allFilterCount").textContent = openAlerts;
        byId("criticalFilterCount").textContent = critical;
        byId("warningFilterCount").textContent = warning;
        byId("infoFilterCount").textContent = information;
        byId("bellBadge").textContent = unread;
        byId("bellBadge").hidden = unread === 0;
        byId("markAllReadBtn").disabled = unread === 0;
        byId("latestEvent").textContent = alerts.length ? timeAgo(alerts[0].minutesAgo) : "No recent events";
    }

    function renderNotifications() {
        var recent = alerts.filter(function (alert) { return alert.unread; }).slice(0, 4);
        if (!recent.length) {
            byId("alertList").innerHTML = '<div class="alert-item"><span class="alert-dot"></span><div><strong>You are all caught up</strong><p>No unread alerts.</p></div></div>';
            return;
        }
        byId("alertList").innerHTML = recent.map(function (alert) {
            return '<div class="alert-item ' + (alert.severity === "critical" ? "warn" : "") + '"><span class="alert-dot"></span><div><strong>' + escapeHtml(alert.title) + '</strong><p>' + escapeHtml(timeAgo(alert.minutesAgo)) + " · " + escapeHtml(zoneRegistry.name(alert.zoneId)) + '</p></div></div>';
        }).join("");
    }

    function render() {
        var visible = filteredAlerts();
        byId("alertFeed").innerHTML = visible.map(renderAlert).join("");
        byId("alertEmpty").hidden = visible.length !== 0;
        byId("resultsCount").textContent = visible.length + (visible.length === 1 ? " alert" : " alerts");
        updateCounts();
        renderNotifications();
    }

    function showToast(message) {
        var box = byId("toastBox");
        var toast = document.createElement("div");
        toast.className = "toast";
        toast.textContent = message;
        box.appendChild(toast);
        window.clearTimeout(toastTimer);
        toastTimer = window.setTimeout(function () {
            toast.remove();
        }, 2600);
    }

    function setFilter(button) {
        activeFilter = button.getAttribute("data-filter");
        document.querySelectorAll("#alertFilters [data-filter]").forEach(function (filterButton) {
            var selected = filterButton === button;
            filterButton.classList.toggle("active", selected);
            filterButton.setAttribute("aria-selected", String(selected));
        });
        render();
    }

    function setupInteractions() {
        document.querySelectorAll("#alertFilters [data-filter]").forEach(function (button) {
            button.addEventListener("click", function () { setFilter(button); });
        });
        byId("alertSearch").addEventListener("input", function (event) {
            searchQuery = event.target.value;
            render();
        });
        byId("markAllReadBtn").addEventListener("click", function () {
            alerts.forEach(function (alert) { alert.unread = false; });
            window.IrrigationAlertCenter.save(alerts);
            render();
            showToast("All alerts marked as read.");
        });
        byId("alertFeed").addEventListener("click", function (event) {
            var button = event.target.closest("[data-action]");
            if (!button) return;
            var record = button.closest("[data-alert-id]");
            var alert = alerts.find(function (item) { return item.id === record.getAttribute("data-alert-id"); });
            if (!alert) return;
            var action = button.getAttribute("data-action");
            if (action === "read" || action === "unread") {
                alert.unread = action === "unread";
                window.IrrigationAlertCenter.save(alerts);
                render();
                showToast(alert.unread ? "Alert marked unread." : "Alert marked as read.");
            } else if (action === "dismiss") {
                if (!canResolve) {
                    showToast("Access denied: only Admin and Staff accounts can resolve alerts.");
                    return;
                }
                window.IrrigationAlertCenter.dismiss(alert.id).then(function () {
                    alerts = window.IrrigationAlertCenter.getAll();
                    render();
                    showToast("Alert resolved in database.");
                }).catch(function () {
                    alerts = window.IrrigationAlertCenter.getAll();
                    render();
                    showToast("Alert dismissed.");
                });
            }
        });
    }

    window.addEventListener("storage", function (event) {
        if (event.key === "si.alerts.read.v1") {
            alerts = window.IrrigationAlertCenter.getAll();
            render();
        }
    });
    window.addEventListener("si:alerts-updated", function () {
        alerts = window.IrrigationAlertCenter.getAll();
        render();
    });
    setupInteractions();
    render();
}());