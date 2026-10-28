(function () {
    var zones = window.IrrigationZones;
    var ctx = window.SI_CTX || "";
    var access = window.SI_ACCESS || {};
    var canWater = !Array.isArray(access.write) || access.write.indexOf("/manual-water") !== -1;
    var canSchedule = !Array.isArray(access.write) || access.write.indexOf("/api/schedules") !== -1;
    var cfg = (window.SI_DATA && window.SI_DATA.config) || {};
    var flowLitersPerMinute = Number(cfg.flowLitersPerMinute) || 2;
    var soilGainPerMinute = 0.9;
    var demoSecondsPerTick = 60;
    var dailyQuotaLiters = Number(cfg.dailyQuotaLiters) || 160;
    var mode = readValue("si.irrigation.mode", "auto");
    var requestedZone = new URLSearchParams(window.location.search).get("zone");
    var defaultZoneId = (zones.list[0] && zones.list[0].id) || "1";
    var selectedZone = zones.get(requestedZone) ? String(zones.get(requestedZone).id) : defaultZoneId;
    var schedules = window.IrrigationSchedules.getAll();
    var history = window.IrrigationHistory.getAll();
    var pump = null;
    var pumpTimer = null;
    var lastScheduleKey = "";
    var toastTimer;

    function byId(id) {
        return document.getElementById(id);
    }

    function readValue(key, fallback) {
        try {
            var value = localStorage.getItem(key);
            return value === null ? fallback : JSON.parse(value);
        } catch (error) {
            return fallback;
        }
    }

    function saveValue(key, value) {
        try {
            localStorage.setItem(key, JSON.stringify(value));
        } catch (error) {
            return;
        }
    }

    function pad(value) {
        return value < 10 ? "0" + value : String(value);
    }

    function localDateKey(date) {
        return date.getFullYear() + "-" + pad(date.getMonth() + 1) + "-" + pad(date.getDate());
    }

    function timeLabel(dateValue) {
        return new Date(dateValue).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
    }

    function escapeHtml(value) {
        return String(value).replace(/[&<>"']/g, function (character) {
            return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[character];
        });
    }

    function zoneMin(zone) {
        return zone && Number.isFinite(Number(zone.targetMin)) ? Number(zone.targetMin) : 35;
    }

    function zoneMax(zone) {
        return zone && Number.isFinite(Number(zone.targetMax)) ? Number(zone.targetMax) : 75;
    }

    function populateGardenSelect(select) {
        if (!select) return;
        var prev = select.value;
        select.innerHTML = zones.list.map(function (zone) {
            var label = (zone.areaName ? zone.areaName + " · " : "") + zone.name + " · " + zone.crop + " (" + Math.round(zoneMin(zone)) + "–" + Math.round(zoneMax(zone)) + "%)";
            return '<option value="' + zone.id + '">' + escapeHtml(label) + '</option>';
        }).join("");
        if (prev && zones.get(prev)) select.value = prev;
    }

    function currentSoil(zoneId) {
        return zones.getSoilMoisture(zoneId);
    }

    function formatTimer(seconds) {
        var rounded = Math.max(0, Math.ceil(seconds));
        return pad(Math.floor(rounded / 60)) + ":" + pad(rounded % 60);
    }

    function todayRuns() {
        var today = localDateKey(new Date());
        return history.filter(function (run) { return localDateKey(new Date(run.startedAt)) === today; });
    }

    function activeSchedules() {
        return schedules.filter(function (schedule) { return schedule.enabled; });
    }

    function updateKpis() {
        var runs = todayRuns();
        var liters = runs.reduce(function (sum, run) { return sum + Number(run.liters || 0); }, 0);
        if (pump) liters += pump.liters;
        var used = Math.round(liters * 10) / 10;
        var quota = Math.min(100, used / dailyQuotaLiters * 100);
        var minutes = Number(byId("durationSelect").value);
        byId("waterToday").textContent = used.toFixed(used % 1 ? 1 : 0);
        byId("runsToday").textContent = runs.length + (pump ? 1 : 0);
        byId("activeSchedules").textContent = activeSchedules().length;
        byId("quotaPercent").textContent = Math.round(quota) + "%";
        byId("quotaBar").style.width = quota + "%";
        byId("estimatedWater").textContent = minutes * flowLitersPerMinute;
        byId("estimateDetail").textContent = minutes + " min · " + flowLitersPerMinute + " L/min";
    }

    function updateGardenContext() {
        var zone = zones.get(selectedZone) || zones.list[0];
        var moisture = currentSoil(selectedZone);
        var minT = zoneMin(zone);
        var maxT = zoneMax(zone);
        byId("activeGardenName").textContent = zone
            ? ((zone.areaName ? zone.areaName + " · " : "") + zone.name + " · " + zone.crop)
            : "Garden";
        byId("activeSoil").textContent = Math.round(moisture) + "%";
        byId("soilContextValue").textContent = Math.round(moisture) + "%";
        byId("soilContextBar").style.width = Math.max(0, Math.min(100, moisture)) + "%";
        if (byId("soilTargetRange")) {
            byId("soilTargetRange").textContent = "Target " + Math.round(minT) + "–" + Math.round(maxT) + "% (" + (zone ? zone.crop : "Plant") + ")";
        }
        byId("sensorLink").href = ctx + "/sensor-data?zone=" + encodeURIComponent(selectedZone);
        byId("zoneSelect").value = selectedZone;
    }

    function renderPump() {
        var running = Boolean(pump);
        var zone = zones.get(running ? pump.zoneId : selectedZone) || zones.list[0];
        var moisture = currentSoil(zone.id);
        var minT = zoneMin(zone);
        var maxT = zoneMax(zone);
        byId("systemStatus").textContent = running ? "Pump running" : (canWater ? "Pump ready" : "Schedule view");
        byId("pumpState").textContent = running ? "PUMP RUNNING" : (canWater ? "PUMP READY" : "PUMP LOCKED");
        byId("pumpBadge").textContent = running ? "Running" : (canWater ? "Standby" : "View only");
        byId("pumpBadge").classList.toggle("is-running", running);
        byId("pumpReadout").classList.toggle("is-running", running);
        byId("pumpHeadline").textContent = running ? "Irrigating " + zone.name : (canWater ? "Ready to irrigate" : "Manual pump locked");
        byId("pumpDetail").textContent = running
            ? (Math.round(moisture) + "% soil · " + pump.liters.toFixed(1) + " L delivered")
            : (canWater ? ((zone.areaName ? zone.areaName + " · " : "") + zone.crop + " · " + Math.round(moisture) + "% (Target " + Math.round(minT) + "–" + Math.round(maxT) + "%)") : "Your role manages schedules only (no manual pump execution).");
        byId("pumpTimer").textContent = running ? formatTimer(pump.remaining) : "--:--";
        byId("runProgress").style.width = running ? ((pump.total - pump.remaining) / pump.total * 100) + "%" : "0%";
        byId("pumpButton").disabled = !canWater;
        byId("pumpButton").innerHTML = !canWater
            ? "Manual watering restricted"
            : (running
                ? '<svg class="icon icon-sm"><use href="#i-stop"></use></svg>Stop irrigation'
                : '<svg class="icon icon-sm"><use href="#i-play"></use></svg>Start irrigation · ' + Number(byId("durationSelect").value) + " min");
        byId("pumpButton").classList.toggle("is-stop", running);
        byId("zoneSelect").disabled = running || !canWater;
        byId("durationSelect").disabled = running || !canWater;
        updateGardenContext();
        updateKpis();
    }

    function renderGardens() {
        var hwZone = zones.getActiveHardwareZone ? zones.getActiveHardwareZone() : null;
        var hwId = hwZone ? String(hwZone.id) : String(selectedZone);
        byId("gardenGrid").innerHTML = zones.list.map(function (zone) {
            var moisture = currentSoil(zone.id);
            var minT = zoneMin(zone);
            var maxT = zoneMax(zone);
            var dry = moisture < minT;
            var wet = moisture > maxT;
            var isHwBound = String(zone.id) === hwId;
            var status = dry
                ? "Needs water (<" + Math.round(minT) + "%)"
                : (wet ? "Too wet (>" + Math.round(maxT) + "%)" : "Healthy (" + Math.round(minT) + "–" + Math.round(maxT) + "%)");
            var areaText = zone.areaName ? escapeHtml(zone.areaName) + " · " : "";
            var nodeBadge = isHwBound
                ? '<span class="garden-node" style="background:#d1fae5;color:#065f46;font-weight:700">🔌 ESP8266 &amp; Bơm</span>'
                : '<span class="garden-node">' + zones.nodeLabel(zone.id) + '</span>';
            var btnLabel = isHwBound ? "🔌 Đang gắn Bơm" : "🔌 Gán Bơm & Chọn";
            return '<article class="garden-tile' + (zone.id === selectedZone ? " is-selected" : "") + (dry ? " is-dry" : "") + (wet ? " is-wet" : "") + '" data-garden="' + zone.id + '">' +
                '<div class="garden-tile-head"><a href="' + ctx + '/plants?zone=' + encodeURIComponent(zone.id) + '">' + escapeHtml(zone.name) + '</a>' + nodeBadge + '</div>' +
                '<p class="garden-crop">' + areaText + escapeHtml(zone.crop) + '</p>' +
                '<div class="garden-moisture">' + Math.round(moisture) + '<small>%</small></div>' +
                '<div class="garden-bar"><span style="width:' + Math.max(0, Math.min(100, moisture)) + '%"></span></div>' +
                '<div class="garden-tile-foot"><span>' + status + '</span><button type="button" class="garden-select" data-select-zone="' + zone.id + '">' + btnLabel + '</button></div>' +
                '</article>';
        }).join("");
    }

    function frequencyText(frequency) {
        if (frequency === "weekdays") return "Weekdays";
        if (frequency === "once") return "One time";
        return "Every day";
    }

    function renderSchedules() {
        if (!canSchedule && byId("scheduleForm")) {
            byId("scheduleForm").hidden = true;
            byId("scheduleForm").style.display = "none";
        }
        var enabledCount = activeSchedules().length;
        byId("scheduleCount").textContent = enabledCount + (enabledCount === 1 ? " active plan" : " active plans");
        if (!schedules.length) {
            byId("scheduleList").innerHTML = '<p class="schedule-empty">No schedules yet. Add a watering plan above.</p>';
            byId("nextSchedule").textContent = "Next run: none planned";
            return;
        }
        byId("scheduleList").innerHTML = schedules.slice().sort(function (a, b) { return a.time.localeCompare(b.time); }).map(function (schedule) {
            var deleteBtn = canSchedule
                ? '<button type="button" class="schedule-delete" data-delete-schedule aria-label="Delete schedule" title="Delete schedule"><svg class="icon icon-sm"><use href="#i-trash"></use></svg></button>'
                : '';
            return '<div class="irrigation-schedule" data-schedule-id="' + escapeHtml(schedule.id) + '">' +
                '<strong class="schedule-time">' + escapeHtml(schedule.time) + '</strong>' +
                '<div class="schedule-details"><strong>' + escapeHtml(zones.name(schedule.zoneId)) + ' · ' + Number(schedule.minutes) + ' min</strong><span>' + frequencyText(schedule.frequency) + ' · ' + (Number(schedule.minutes) * flowLitersPerMinute) + ' L est.</span></div>' +
                '<label class="schedule-switch"><input type="checkbox" data-toggle-schedule ' + (schedule.enabled ? "checked" : "") + (canSchedule ? "" : " disabled") + ' aria-label="Enable schedule ' + escapeHtml(schedule.time) + '"><span></span></label>' +
                deleteBtn +
                '</div>';
        }).join("");
        renderNextSchedule();
    }

    function nextRunDate(schedule) {
        var now = new Date();
        var parts = schedule.time.split(":");
        var next = new Date();
        next.setHours(Number(parts[0]), Number(parts[1]), 0, 0);
        if (next <= now) next.setDate(next.getDate() + 1);
        if (schedule.frequency === "weekdays") {
            while (next.getDay() === 0 || next.getDay() === 6) next.setDate(next.getDate() + 1);
        }
        return next;
    }

    function renderNextSchedule() {
        var next = activeSchedules().map(function (schedule) {
            return { schedule: schedule, date: nextRunDate(schedule) };
        }).sort(function (a, b) { return a.date - b.date; })[0];
        if (!next) {
            byId("nextSchedule").textContent = "Next run: none planned";
            return;
        }
        byId("nextSchedule").textContent = "Next run: " + zones.name(next.schedule.zoneId) + " at " + next.schedule.time;
    }

    function renderHistory() {
        var rows = history.slice().sort(function (a, b) { return new Date(b.startedAt) - new Date(a.startedAt); }).slice(0, 8);
        byId("emptyRuns").hidden = rows.length > 0;
        byId("runHistory").innerHTML = rows.map(function (run) {
            return '<tr><td>' + escapeHtml(zones.name(run.zoneId)) + '</td><td>' + timeLabel(run.startedAt) + '</td><td>' + Number(run.minutes).toFixed(run.minutes % 1 ? 1 : 0) + ' min</td><td>' + Number(run.liters).toFixed(run.liters % 1 ? 1 : 0) + ' L</td><td>' + escapeHtml(run.source) + '</td><td><span class="run-status">' + escapeHtml(run.status) + '</span></td></tr>';
        }).join("");
    }

    function saveSchedules() {
        if (!canSchedule) return;
        schedules = window.IrrigationSchedules.save(schedules);
        renderSchedules();
        updateKpis();
    }

    function saveHistory() {
        if (!canWater) return;
        history = history.slice(-40);
        window.IrrigationHistory.save(history);
        renderHistory();
        updateKpis();
    }

    function startPump(zoneId, minutes, source) {
        if (!canWater) {
            toast("Access denied: your role cannot execute manual watering.");
            return;
        }
        if (pump) return;
        var initialSoil = currentSoil(zoneId);
        var hwSeconds = Math.max(1, Math.round(Number(minutes)));
        pump = {
            zoneId: zoneId,
            source: source,
            startedAt: new Date().toISOString(),
            startedMs: Date.now(),
            total: Number(minutes) * 60,
            remaining: Number(minutes) * 60,
            liters: 0,
            initialSoil: initialSoil
        };
        selectedZone = zoneId;
        pumpTimer = window.setInterval(tickPump, 1000);
        byId("zoneSelect").value = zoneId;
        renderPump();
        renderGardens();
        toast("Irrigation started · " + zones.name(zoneId));
        fetch(ctx + "/api/watering/command", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded",
                "X-Requested-With": "fetch"
            },
            body: "potId=" + encodeURIComponent(zoneId) + "&command=START&duration=" + encodeURIComponent(hwSeconds) + "&minutes=" + encodeURIComponent(minutes)
        }).catch(function () {});
    }

    function tickPump() {
        if (!pump) return;
        var simulatedSeconds = Math.min(demoSecondsPerTick, pump.remaining);
        pump.remaining -= simulatedSeconds;
        pump.liters += flowLitersPerMinute * simulatedSeconds / 60;
        var moisture = zones.getSoilMoisture(pump.zoneId) + soilGainPerMinute * simulatedSeconds / 60;
        zones.setSoilMoisture(pump.zoneId, moisture);
        renderPump();
        renderGardens();
        if (pump.remaining <= 0) stopPump(true, false);
    }

    function stopPump(completed, fromDevice) {
        if (!pump) return;
        window.clearInterval(pumpTimer);
        pumpTimer = null;
        var stoppedZoneId = pump.zoneId;
        if (!completed && !fromDevice) {
            fetch(ctx + "/api/watering/command", {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded",
                    "X-Requested-With": "fetch"
                },
                body: "potId=" + encodeURIComponent(stoppedZoneId) + "&command=STOP"
            }).catch(function () {});
        }
        var elapsedMinutes = (pump.total - pump.remaining) / 60;
        if (pump.liters > 0.05) {
            var z = zones.get(pump.zoneId);
            var maxT = zoneMax(z);
            var finalSoil = currentSoil(pump.zoneId);
            var moistureGain = Math.max(0, finalSoil - pump.initialSoil);
            var gainAboveTarget = Math.max(0, finalSoil - Math.max(pump.initialSoil, maxT));
            var excessLiters = moistureGain > 0 ? pump.liters * gainAboveTarget / moistureGain : 0;
            history.push({
                id: "run-" + Date.now(),
                zoneId: pump.zoneId,
                minutes: Math.round(elapsedMinutes * 10) / 10,
                liters: Math.round(pump.liters * 10) / 10,
                initialSoil: Math.round(pump.initialSoil * 10) / 10,
                finalSoil: Math.round(finalSoil * 10) / 10,
                excessLiters: Math.round(excessLiters * 10) / 10,
                source: pump.source,
                status: completed ? "Completed" : "Stopped",
                startedAt: pump.startedAt
            });
            saveHistory();
        }
        var zoneName = zones.name(pump.zoneId);
        pump = null;
        renderPump();
        renderGardens();
        toast(completed ? "Run completed · " + zoneName : "Pump stopped · " + zoneName);
    }

    function syncSensorsAndPump() {
        fetch(ctx + "/api/sensors", {
            cache: "no-store",
            headers: { "X-Requested-With": "fetch" }
        })
            .then(function (res) { return res.ok ? res.json() : []; })
            .then(function (readings) {
                if (!Array.isArray(readings) || !readings.length) return;
                if (zones.syncFromReadings) {
                    zones.syncFromReadings(readings);
                }
                readings.forEach(function (reading) {
                    var id = String(reading.id || reading.potId);
                    var m = Number(reading.moisture !== undefined ? reading.moisture : reading.soilMoisture);
                    if (Number.isFinite(m) && (!pump || String(pump.zoneId) !== id)) {
                        zones.setSoilMoisture(id, m);
                    }
                    if (pump && String(pump.zoneId) === id && (Date.now() - pump.startedMs > 2000) && reading.pumpRunning === false) {
                        stopPump(true, true);
                    }
                });
                populateGardenSelect(byId("zoneSelect"));
                populateGardenSelect(byId("scheduleZone"));
                renderPump();
                renderGardens();
            })
            .catch(function () {});
    }

    function toast(message) {
        var box = byId("toastBox");
        var element = document.createElement("div");
        element.className = "toast";
        element.textContent = message;
        box.appendChild(element);
        window.clearTimeout(toastTimer);
        toastTimer = window.setTimeout(function () { element.remove(); }, 2800);
    }

    function updateMode(nextMode) {
        mode = nextMode;
        saveValue("si.irrigation.mode", mode);
        document.querySelectorAll("#modeToggle [data-mode]").forEach(function (button) {
            var active = button.getAttribute("data-mode") === mode;
            button.classList.toggle("active", active);
            button.setAttribute("aria-pressed", String(active));
            button.disabled = !canWater;
        });
        byId("pumpNote").textContent = !canWater
            ? "Your role can manage watering schedules, while Staff and Admin accounts execute manual pump runs."
            : (mode === "auto"
                ? "Auto mode starts a short run when any pot falls below its Plant's min moisture threshold. Manual runs use your selected duration."
                : "Manual mode runs only when you start the pump. Garden moisture still updates across the other pages.");
        if (mode === "auto" && canWater) autoCheck();
    }

    function autoCheck() {
        if (!canWater || mode !== "auto" || pump) return;
        var driest = zones.list.slice().sort(function (first, second) {
            return (currentSoil(first.id) - zoneMin(first)) - (currentSoil(second.id) - zoneMin(second));
        })[0];
        if (driest && currentSoil(driest.id) < zoneMin(driest)) {
            startPump(driest.id, 5, "Auto");
        }
    }

    function isScheduleDue(schedule, now) {
        if (!schedule.enabled || schedule.time !== pad(now.getHours()) + ":" + pad(now.getMinutes())) return false;
        if (schedule.frequency === "weekdays" && (now.getDay() === 0 || now.getDay() === 6)) return false;
        var key = localDateKey(now) + " " + schedule.id;
        if (key === lastScheduleKey) return false;
        lastScheduleKey = key;
        return true;
    }

    function checkSchedules() {
        if (!canWater) return;
        var now = new Date();
        var due = schedules.filter(function (schedule) { return isScheduleDue(schedule, now); })[0];
        if (!due) return;
        if (pump) {
            toast("Scheduled run skipped because the pump is busy.");
            return;
        }
        startPump(due.zoneId, due.minutes, "Scheduled");
        if (due.frequency === "once" && canSchedule) {
            schedules = schedules.filter(function (schedule) { return schedule.id !== due.id; });
            saveSchedules();
        }
    }

    function setupControls() {
        byId("zoneSelect").addEventListener("change", function (event) {
            selectedZone = event.target.value;
            if (zones.bindHardware) {
                zones.bindHardware(selectedZone);
            }
            renderPump();
            renderGardens();
            toast("🔌 Đã gán Mạch ESP8266 & Máy bơm vật lý vào: " + zones.name(selectedZone));
        });
        byId("durationSelect").addEventListener("change", updateKpis);
        byId("pumpButton").addEventListener("click", function () {
            if (!canWater) {
                toast("Access denied: your role cannot execute manual watering.");
                return;
            }
            if (pump) {
                stopPump(false);
                return;
            }
            startPump(selectedZone, Number(byId("durationSelect").value), "Manual");
        });
        document.querySelectorAll("#modeToggle [data-mode]").forEach(function (button) {
            button.addEventListener("click", function () {
                if (!canWater) return;
                updateMode(button.getAttribute("data-mode"));
            });
        });
        byId("scheduleForm").addEventListener("submit", function (event) {
            event.preventDefault();
            if (!canSchedule) {
                toast("Access denied: only Admin and Manager accounts can manage schedules.");
                return;
            }
            var time = byId("scheduleTime").value;
            if (!time) return;
            schedules.push({
                id: "plan-" + Date.now(),
                zoneId: byId("scheduleZone").value,
                time: time,
                minutes: Number(byId("scheduleDuration").value),
                frequency: byId("scheduleFrequency").value,
                enabled: true
            });
            saveSchedules();
            toast("Watering plan added.");
        });
        byId("scheduleList").addEventListener("change", function (event) {
            if (!event.target.hasAttribute("data-toggle-schedule")) return;
            if (!canSchedule) {
                event.target.checked = !event.target.checked;
                toast("Access denied: only Admin and Manager accounts can modify schedules.");
                return;
            }
            var item = event.target.closest("[data-schedule-id]");
            var schedule = schedules.filter(function (entry) { return entry.id === item.getAttribute("data-schedule-id"); })[0];
            if (!schedule) return;
            schedule.enabled = event.target.checked;
            saveSchedules();
        });
        byId("scheduleList").addEventListener("click", function (event) {
            var button = event.target.closest("[data-delete-schedule]");
            if (!button) return;
            if (!canSchedule) {
                toast("Access denied: only Admin and Manager accounts can delete schedules.");
                return;
            }
            var item = button.closest("[data-schedule-id]");
            schedules = schedules.filter(function (schedule) { return schedule.id !== item.getAttribute("data-schedule-id"); });
            saveSchedules();
            toast("Watering plan removed.");
        });
        byId("gardenGrid").addEventListener("click", function (event) {
            var button = event.target.closest("[data-select-zone]");
            if (!button) return;
            selectedZone = button.getAttribute("data-select-zone");
            if (zones.bindHardware) {
                zones.bindHardware(selectedZone);
            }
            renderPump();
            renderGardens();
            toast("🔌 Đã gán Mạch ESP8266 & Máy bơm vật lý vào: " + zones.name(selectedZone));
            byId("pumpTitle").scrollIntoView({ behavior: "smooth", block: "center" });
        });
    }

    populateGardenSelect(byId("zoneSelect"));
    populateGardenSelect(byId("scheduleZone"));
    byId("zoneSelect").value = selectedZone;
    byId("scheduleZone").value = selectedZone;
    byId("durationSelect").value = String(readValue("si.irrigation.duration", 10));
    byId("durationSelect").addEventListener("change", function (event) {
        saveValue("si.irrigation.duration", Number(event.target.value));
    });
    setupControls();
    updateMode(mode);
    renderPump();
    renderSchedules();
    renderHistory();
    renderGardens();
    window.IrrigationSchedules.onChange(function (updatedSchedules) {
        schedules = updatedSchedules;
        renderSchedules();
        updateKpis();
    });
    window.setInterval(syncSensorsAndPump, 2000);
    window.setInterval(checkSchedules, 15000);
    window.setInterval(autoCheck, 30000);
}());
