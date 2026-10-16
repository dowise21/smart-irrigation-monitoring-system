(function (global) {
    var readStorageKey = "si.alerts.read.v1";
    var zones = global.IrrigationZones;
    var ctx = global.SI_CTX || "";

    function readMap() {
        try {
            var raw = global.localStorage.getItem(readStorageKey);
            return raw ? JSON.parse(raw) : {};
        } catch (error) {
            return {};
        }
    }

    function saveReadMap(map) {
        try {
            global.localStorage.setItem(readStorageKey, JSON.stringify(map));
        } catch (error) {
            // Ignore storage quota errors
        }
    }

    var readById = readMap();

    var alerts = (global.SI_DATA && Array.isArray(global.SI_DATA.alerts))
        ? global.SI_DATA.alerts.map(function (alert) {
            var id = String(alert.id);
            return {
                id: id,
                dbId: alert.dbId,
                severity: alert.severity || "warning",
                title: alert.title || "System alert",
                description: alert.description || "",
                zoneId: String(alert.zoneId || "1"),
                node: alert.node || zones.nodeLabel(alert.zoneId || "1"),
                createdAt: Number(alert.createdAt) || Date.now(),
                unread: readById[id] === undefined ? true : !readById[id],
                icon: alert.icon || "i-warning"
            };
        })
        : [];

    function notify() {
        global.dispatchEvent(new CustomEvent("si:alerts-updated"));
    }

    function getAll() {
        return alerts.map(function (alert) {
            alert.minutesAgo = Math.max(0, Math.floor((Date.now() - alert.createdAt) / 60000));
            return alert;
        }).sort(function (first, second) { return second.createdAt - first.createdAt; });
    }

    function write(nextAlerts) {
        if (Array.isArray(nextAlerts)) {
            alerts = nextAlerts;
            alerts.forEach(function (alert) {
                readById[String(alert.id)] = !alert.unread;
            });
            saveReadMap(readById);
        }
        notify();
    }

    function dismiss(alertId) {
        alerts = alerts.filter(function (item) { return String(item.id) !== String(alertId); });
        notify();
        return fetch(ctx + "/alerts", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded",
                "X-Requested-With": "fetch"
            },
            body: "action=dismiss&alertId=" + encodeURIComponent(alertId)
        });
    }

    function resolveAll() {
        alerts.forEach(function (alert) {
            alert.unread = false;
            readById[String(alert.id)] = true;
        });
        saveReadMap(readById);
        notify();
        return fetch(ctx + "/alerts", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded",
                "X-Requested-With": "fetch"
            },
            body: "action=resolveAll"
        });
    }

    global.IrrigationAlertCenter = {
        getAll: getAll,
        save: write,
        dismiss: dismiss,
        resolveAll: resolveAll,
        unreadCount: function () {
            return alerts.filter(function (alert) { return alert.unread; }).length;
        }
    };
}(window));