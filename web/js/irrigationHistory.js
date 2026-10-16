(function (global) {
    var ctx = global.SI_CTX || "";
    var runs = (global.SI_DATA && Array.isArray(global.SI_DATA.history))
        ? global.SI_DATA.history.slice()
        : [];
    var persistedIds = {};
    runs.forEach(function (run) {
        persistedIds[String(run.id)] = true;
    });

    function notify() {
        global.dispatchEvent(new CustomEvent("si:irrigation-history-updated"));
    }

    function postRun(run) {
        if (!run || persistedIds[String(run.id)]) return Promise.resolve();
        persistedIds[String(run.id)] = true;
        var params = new URLSearchParams();
        params.set("potId", String(run.zoneId || "1"));
        params.set("minutes", String(run.minutes || 0));
        params.set("liters", String(run.liters || 0));
        params.set("source", String(run.source || "Manual"));
        params.set("status", String(run.status || "Completed"));
        if (run.excessLiters !== undefined && run.excessLiters !== null) {
            params.set("excessLiters", String(run.excessLiters));
        }
        return fetch(ctx + "/api/history", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded",
                "X-Requested-With": "fetch"
            },
            body: params.toString()
        }).then(function (res) {
            return res.ok ? res.json() : null;
        }).then(function (data) {
            if (data && data.id) {
                persistedIds[String(data.id)] = true;
                run.id = data.id;
                run.dbId = data.dbId;
            }
            notify();
        }).catch(function () {
            // Keep in-memory entry if offline
        });
    }

    function save(nextRuns) {
        if (Array.isArray(nextRuns)) {
            nextRuns.forEach(function (run) {
                if (!persistedIds[String(run.id)]) {
                    postRun(run);
                }
            });
            runs = nextRuns.slice();
        }
        notify();
    }

    function record(run) {
        runs.unshift(run);
        notify();
        return postRun(run);
    }

    function getAll() {
        return runs.slice();
    }

    global.IrrigationHistory = {
        getAll: getAll,
        save: save,
        record: record
    };
}(window));