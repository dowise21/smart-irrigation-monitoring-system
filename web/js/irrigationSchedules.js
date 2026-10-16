(function (global) {
    var zones = global.IrrigationZones;
    var ctx = global.SI_CTX || "";
    var defaultZoneId = (zones && zones.list && zones.list[0]) ? String(zones.list[0].id) : "1";

    function normalizeOne(schedule, index) {
        var frequency = schedule.frequency;
        if (frequency !== "weekdays" && frequency !== "once") frequency = "daily";
        var minutes = Number(schedule.minutes === undefined ? schedule.min : schedule.minutes);
        var requestedZone = String(schedule.zoneId !== undefined ? schedule.zoneId : defaultZoneId);
        var zoneId = (zones && zones.get(requestedZone)) ? String(zones.get(requestedZone).id) : defaultZoneId;
        return {
            id: String(schedule.id === undefined ? "plan-" + Date.now() + "-" + index : schedule.id),
            dbId: schedule.dbId,
            zoneId: zoneId,
            time: /^([01]\d|2[0-3]):[0-5]\d$/.test(schedule.time) ? schedule.time : "07:00",
            minutes: Number.isFinite(minutes) && minutes > 0 ? minutes : 10,
            frequency: frequency,
            enabled: schedule.enabled === undefined ? schedule.on !== false : schedule.enabled !== false
        };
    }

    function normalize(list) {
        if (!Array.isArray(list)) return [];
        return list.map(normalizeOne);
    }

    var currentSchedules = normalize(
        (global.SI_DATA && Array.isArray(global.SI_DATA.schedules)) ? global.SI_DATA.schedules : []
    );

    function notify() {
        global.dispatchEvent(new CustomEvent("si:irrigation-schedules-updated"));
    }

    function postForm(params) {
        return fetch(ctx + "/api/schedules", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded",
                "X-Requested-With": "fetch"
            },
            body: params.toString()
        }).then(function (res) {
            return res.ok ? res.json() : null;
        }).catch(function () {
            return null;
        });
    }

    function syncDiff(prevList, nextList) {
        var prevById = {};
        prevList.forEach(function (item) { prevById[String(item.id)] = item; });
        var nextById = {};
        nextList.forEach(function (item) { nextById[String(item.id)] = item; });

        // 1. Added schedules
        nextList.forEach(function (item) {
            if (!prevById[String(item.id)]) {
                var params = new URLSearchParams();
                params.set("action", "add");
                params.set("potId", String(item.zoneId));
                params.set("time", String(item.time));
                params.set("minutes", String(item.minutes));
                params.set("frequency", String(item.frequency));
                postForm(params).then(function (data) {
                    if (data && data.schedule) {
                        item.id = String(data.schedule.id);
                        item.dbId = data.schedule.dbId;
                        notify();
                    }
                });
            } else {
                // 2. Toggled schedules
                var prev = prevById[String(item.id)];
                if (Boolean(prev.enabled) !== Boolean(item.enabled)) {
                    var scheduleId = item.dbId || item.id;
                    var toggleParams = new URLSearchParams();
                    toggleParams.set("action", "toggle");
                    toggleParams.set("scheduleId", String(scheduleId));
                    toggleParams.set("enabled", String(Boolean(item.enabled)));
                    postForm(toggleParams);
                }
            }
        });

        // 3. Deleted schedules
        prevList.forEach(function (prev) {
            if (!nextById[String(prev.id)]) {
                var scheduleId = prev.dbId || prev.id;
                var delParams = new URLSearchParams();
                delParams.set("action", "delete");
                delParams.set("scheduleId", String(scheduleId));
                postForm(delParams);
            }
        });
    }

    function canWriteSchedules() {
        var access = global.SI_ACCESS;
        if (!access || !Array.isArray(access.write)) return true;
        return access.write.indexOf("/api/schedules") !== -1;
    }

    function getAll() {
        return currentSchedules.map(function (item) {
            return Object.assign({}, item);
        });
    }

    function save(nextSchedules) {
        if (!canWriteSchedules()) {
            return getAll();
        }
        var normalized = normalize(nextSchedules);
        syncDiff(currentSchedules, normalized);
        currentSchedules = normalized;
        notify();
        return getAll();
    }

    function onChange(listener) {
        global.addEventListener("si:irrigation-schedules-updated", function () {
            listener(getAll());
        });
    }

    global.IrrigationSchedules = {
        getAll: getAll,
        save: save,
        canWrite: canWriteSchedules,
        onChange: onChange
    };
}(window));