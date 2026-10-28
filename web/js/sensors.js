/* Connected to /api/sensors for live soil moisture readings and dynamic Area · Pot · Plant thresholds. */
(function () {
    var ctx = window.SI_CTX || "";
    var access = window.SI_ACCESS || {};
    var canExport = !Array.isArray(access.read) || access.read.indexOf("/export-history") !== -1;
    var canOpenPlants = !Array.isArray(access.read) || access.read.indexOf("/plants") !== -1;
    var sensorConfig = {
        temperature: { value: 27.4, min: 15, max: 40, low: 24, high: 32, unit: "°C", decimals: 1, label: "Temperature", target: "24–32 °C", good: "Normal" },
        humidity: { value: 69, min: 0, max: 100, low: 50, high: 80, unit: "%", decimals: 0, label: "Air humidity", target: "50–80%", good: "Balanced" },
        soil: { value: window.IrrigationZones.averageSoil(), min: 0, max: 100, low: 35, high: 75, unit: "%", decimals: 0, label: "Soil moisture", target: "35–75%", good: "Healthy" },
        light: { value: 72, min: 0, max: 100, low: 40, high: 90, unit: "%", decimals: 0, label: "Light intensity", target: "40–90%", good: "Suitable" }
    };
    var zoneNames = { all: "All gardens (All Areas · Pots · Plants)" };
    var zoneOffsets = { all: { temperature: 0, humidity: 0, soil: 0, light: 0 } };

    function rebuildZoneMeta() {
        window.IrrigationZones.list.forEach(function (zone) {
            zoneNames[zone.id] = (zone.areaName ? zone.areaName + " · " : "") + zone.name + " · " + zone.crop;
            zoneOffsets[zone.id] = {
                temperature: 0,
                humidity: 0,
                soil: window.IrrigationZones.getSoilMoisture(zone.id) - window.IrrigationZones.averageSoil(),
                light: 0
            };
        });
    }
    rebuildZoneMeta();

    var metric = "soil";
    var rangeHours = 1;
    var requestedZone = new URLSearchParams(window.location.search).get("zone");
    var matchedZone = window.IrrigationZones.get(requestedZone);
    var selectedZone = matchedZone ? String(matchedZone.id) : "all";
    var history = {};
    var toastTimer;
    var rangeSteps = { 1: 12, 6: 18, 24: 24 };
    var rangeLabels = {
        1: ["60 min ago", "45 min", "30 min", "15 min", "Now"],
        6: ["6 hours ago", "4.5 h", "3 h", "1.5 h", "Now"],
        24: ["24 hours ago", "18 h", "12 h", "6 h", "Now"]
    };

    Object.keys(sensorConfig).forEach(function (key) {
        var config = sensorConfig[key];
        history[key] = [];
        for (var index = 0; index < 24; index += 1) {
            var drift = Math.sin(index * 0.65) * (key === "temperature" ? 1.1 : 4);
            history[key].push(config.value + drift + (Math.random() - 0.5) * (key === "temperature" ? 0.6 : 2));
        }
    });

    function byId(id) {
        return document.getElementById(id);
    }

    function syncSoilThresholdForZone() {
        var zone = selectedZone === "all" ? null : window.IrrigationZones.get(selectedZone);
        if (zone) {
            var minT = Number.isFinite(Number(zone.targetMin)) ? Math.round(Number(zone.targetMin)) : 35;
            var maxT = Number.isFinite(Number(zone.targetMax)) ? Math.round(Number(zone.targetMax)) : 75;
            sensorConfig.soil.low = minT;
            sensorConfig.soil.high = maxT;
            sensorConfig.soil.target = minT + "–" + maxT + "% (" + zone.crop + ")";
        } else {
            var list = window.IrrigationZones.list;
            var avgMin = list.length ? Math.round(list.reduce(function (s, z) { return s + (Number(z.targetMin) || 35); }, 0) / list.length) : 35;
            var avgMax = list.length ? Math.round(list.reduce(function (s, z) { return s + (Number(z.targetMax) || 75); }, 0) / list.length) : 75;
            sensorConfig.soil.low = avgMin;
            sensorConfig.soil.high = avgMax;
            sensorConfig.soil.target = avgMin + "–" + avgMax + "%";
        }
    }

    function populateZoneFilter() {
        var filter = byId("zoneFilter");
        if (!filter) return;
        var html = '<option value="all">All zones (All Areas · Pots · Plants)</option>';
        window.IrrigationZones.list.forEach(function (zone) {
            var label = (zone.areaName ? zone.areaName + " · " : "") + zone.name + " · " + zone.crop + " (" + Math.round(zone.targetMin || 35) + "–" + Math.round(zone.targetMax || 75) + "%)";
            html += '<option value="' + zone.id + '">' + label + '</option>';
        });
        filter.innerHTML = html;
        filter.value = selectedZone;
    }

    function currentValue(key) {
        var config = sensorConfig[key];
        var offsetObj = zoneOffsets[selectedZone] || zoneOffsets.all;
        var offset = offsetObj[key] || 0;
        var value = config.value + offset;
        return Math.max(config.min, Math.min(config.max, value));
    }

    function formatValue(key, value) {
        return value.toFixed(sensorConfig[key].decimals);
    }

    function stateFor(key, value) {
        var config = sensorConfig[key];
        if (value < config.low) return { label: key === "soil" ? "Needs water" : "Low", className: "warning" };
        if (value > config.high) return { label: key === "soil" ? "Too wet" : "High", className: "warning" };
        return { label: config.good, className: "good" };
    }

    function updateBadge(element, state) {
        if (!element) return;
        element.textContent = state.label;
        element.className = "badge " + state.className;
    }

    function drawSparkline(key) {
        var svg = byId("spark" + key.charAt(0).toUpperCase() + key.slice(1));
        if (!svg) return;
        var values = history[key].slice(-14);
        var min = Math.min.apply(null, values);
        var max = Math.max.apply(null, values);
        var spread = max - min || 1;
        var points = values.map(function (value, index) {
            var x = (index / (values.length - 1)) * 100;
            var y = 27 - ((value - min) / spread) * 21;
            return x.toFixed(1) + "," + y.toFixed(1);
        }).join(" ");
        svg.innerHTML = '<polyline points="' + points + '" fill="none" stroke="#059669" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"></polyline>';
    }

    function drawChart() {
        syncSoilThresholdForZone();
        var svg = byId("sensorChart");
        var config = sensorConfig[metric];
        var values = history[metric].slice(-rangeSteps[rangeHours]);
        var left = 42;
        var top = 16;
        var width = 662;
        var height = 204;
        var yFor = function (value) {
            return top + height - ((value - config.min) / (config.max - config.min)) * height;
        };
        var xFor = function (index) {
            return left + (index / Math.max(1, values.length - 1)) * width;
        };
        var path = values.map(function (value, index) {
            return (index === 0 ? "M" : "L") + xFor(index).toFixed(1) + " " + yFor(value).toFixed(1);
        }).join(" ");
        var area = path + " L " + xFor(values.length - 1).toFixed(1) + " " + (top + height) + " L " + left + " " + (top + height) + " Z";
        var targetTop = yFor(config.high);
        var targetBottom = yFor(config.low);
        var current = currentValue(metric);
        var yLabels = [config.max, (config.max + config.min) / 2, config.min];
        var grid = yLabels.map(function (value) {
            var y = yFor(value).toFixed(1);
            return '<line class="chart-gridline" x1="' + left + '" y1="' + y + '" x2="704" y2="' + y + '"></line>' +
                '<text class="chart-grid-label" x="4" y="' + (Number(y) + 4) + '">' + Math.round(value) + (config.unit === "%" ? "%" : "°") + '</text>';
        }).join("");
        var points = '<circle class="chart-reading-point" cx="' + xFor(values.length - 1).toFixed(1) + '" cy="' + yFor(current).toFixed(1) + '" r="5"></circle>';

        svg.innerHTML = '<defs><linearGradient id="sensorAreaFill" x1="0" x2="0" y1="0" y2="1"><stop offset="0%" stop-color="#10b981" stop-opacity=".22"></stop><stop offset="100%" stop-color="#10b981" stop-opacity="0"></stop></linearGradient></defs>' +
            grid +
            '<rect class="chart-target-band" x="' + left + '" y="' + targetTop.toFixed(1) + '" width="' + width + '" height="' + Math.max(0, targetBottom - targetTop).toFixed(1) + '"></rect>' +
            '<path class="chart-reading-area" d="' + area + '"></path>' +
            '<path class="chart-reading-line" d="' + path + '"></path>' + points;
        byId("chartCurrent").textContent = formatValue(metric, current) + " " + config.unit;
        byId("chartTarget").textContent = config.target;
        byId("telemetryTitle").textContent = config.label + " trend";
        byId("chartAxisLabels").innerHTML = rangeLabels[rangeHours].map(function (label) {
            return "<span>" + label + "</span>";
        }).join("");
    }

    function updatePage() {
        syncSoilThresholdForZone();
        if (byId("soilTargetFoot")) {
            byId("soilTargetFoot").textContent = "Target range " + sensorConfig.soil.target;
        }
        Object.keys(sensorConfig).forEach(function (key) {
            var config = sensorConfig[key];
            var value = currentValue(key);
            var state = stateFor(key, value);
            var valueElement = byId(key);
            if (valueElement) valueElement.textContent = formatValue(key, value);
            updateBadge(byId(key + "Status"), state);

            var row = document.querySelector('[data-row="' + key + '"]');
            if (row) {
                var zoneLink = row.querySelector("[data-zone-link]");
                zoneLink.textContent = selectedZone === "all" ? "All gardens" : (zoneNames[selectedZone] || "All gardens");
                if (canOpenPlants) {
                    zoneLink.href = selectedZone === "all" ? ctx + "/plants" : ctx + "/plants?zone=" + encodeURIComponent(selectedZone);
                } else {
                    zoneLink.removeAttribute("href");
                    zoneLink.style.pointerEvents = "none";
                    zoneLink.style.textDecoration = "none";
                }
                row.querySelector("[data-reading]").textContent = formatValue(key, value) + " " + config.unit;
                var targetCell = row.querySelector("[data-target-range]");
                if (targetCell) {
                    targetCell.textContent = config.target;
                }
            }
            drawSparkline(key);
        });

        var soil = currentValue("soil");
        byId("soilBar").style.width = Math.max(0, Math.min(100, soil)) + "%";
        byId("activeZoneLabel").textContent = zoneNames[selectedZone] || "All gardens";
        byId("lastUpdate").textContent = new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", second: "2-digit" });
        drawChart();
    }

    function addSample() {
        var hasLiveTemp = false;
        var hasLiveHum = false;
        var hasLiveLight = false;
        fetch(ctx + "/api/sensors", {
            cache: "no-store",
            headers: { "X-Requested-With": "fetch" }
        })
            .then(function (res) { return res.ok ? res.json() : []; })
            .then(function (readings) {
                if (Array.isArray(readings) && readings.length) {
                    if (window.IrrigationZones.syncFromReadings) {
                        window.IrrigationZones.syncFromReadings(readings);
                    }
                    readings.forEach(function (reading) {
                        var id = String(reading.id || reading.potId);
                        var m = Number(reading.moisture !== undefined ? reading.moisture : reading.soilMoisture);
                        if (Number.isFinite(m)) {
                            window.IrrigationZones.setSoilMoisture(id, m);
                        }
                        if (reading.temperature !== null && reading.temperature !== undefined && Number.isFinite(Number(reading.temperature))) {
                            sensorConfig.temperature.value = Number(reading.temperature);
                            hasLiveTemp = true;
                        }
                        if (reading.humidity !== null && reading.humidity !== undefined && Number.isFinite(Number(reading.humidity))) {
                            sensorConfig.humidity.value = Number(reading.humidity);
                            hasLiveHum = true;
                        }
                        if (reading.lightLux !== null && reading.lightLux !== undefined && Number.isFinite(Number(reading.lightLux))) {
                            var lux = Number(reading.lightLux);
                            sensorConfig.light.value = lux <= 100 ? lux : Math.max(0, Math.min(100, Math.round(lux / 10)));
                            hasLiveLight = true;
                        }
                    });
                    sensorConfig.soil.value = window.IrrigationZones.averageSoil();
                    rebuildZoneMeta();
                    populateZoneFilter();
                }
            })
            .catch(function () {
                // Keep current soil reading on network error
            })
            .then(function () {
                Object.keys(sensorConfig).forEach(function (key) {
                    var config = sensorConfig[key];
                    var isLive = (key === "soil")
                        || (key === "temperature" && hasLiveTemp)
                        || (key === "humidity" && hasLiveHum)
                        || (key === "light" && hasLiveLight);
                    if (!isLive) {
                        var step = key === "temperature" ? 0.45 : 1.8;
                        config.value = Math.max(config.min, Math.min(config.max, config.value + (Math.random() - 0.5) * step));
                    }
                    var offsetObj = zoneOffsets[selectedZone] || zoneOffsets.all;
                    history[key].push(config.value + (offsetObj[key] || 0));
                    if (history[key].length > 48) history[key].shift();
                });
                updatePage();
            });
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
        }, 2800);
    }

    function exportCsv() {
        if (!canExport) {
            showToast("Access denied: your role does not include report export permission.");
            return;
        }
        var rows = [["Sensor", "Zone", "Reading", "Unit", "Recommended range", "Status", "Recorded at"]];
        Object.keys(sensorConfig).forEach(function (key) {
            var config = sensorConfig[key];
            var value = currentValue(key);
            rows.push([config.label, zoneNames[selectedZone] || "All gardens", formatValue(key, value), config.unit, config.target, stateFor(key, value).label, new Date().toISOString()]);
        });
        var csv = rows.map(function (row) {
            return row.map(function (cell) {
                return '"' + String(cell).replace(/"/g, '""') + '"';
            }).join(",");
        }).join("\r\n");
        var link = document.createElement("a");
        link.href = URL.createObjectURL(new Blob([csv], { type: "text/csv;charset=utf-8" }));
        link.download = "sensor-readings.csv";
        link.click();
        URL.revokeObjectURL(link.href);
        showToast("Sensor readings exported.");
    }

    function setupControls() {
        if (!canExport && byId("exportBtn")) {
            byId("exportBtn").hidden = true;
            byId("exportBtn").style.display = "none";
        }
        document.querySelectorAll("#metricTabs [data-metric]").forEach(function (button) {
            button.addEventListener("click", function () {
                metric = button.getAttribute("data-metric");
                document.querySelectorAll("#metricTabs [data-metric]").forEach(function (tab) {
                    var active = tab === button;
                    tab.classList.toggle("active", active);
                    tab.setAttribute("aria-selected", String(active));
                });
                drawChart();
            });
        });

        document.querySelectorAll("#rangeTabs [data-range]").forEach(function (button) {
            button.addEventListener("click", function () {
                rangeHours = Number(button.getAttribute("data-range"));
                document.querySelectorAll("#rangeTabs [data-range]").forEach(function (tab) {
                    var active = tab === button;
                    tab.classList.toggle("active", active);
                    tab.setAttribute("aria-pressed", String(active));
                });
                drawChart();
            });
        });

        byId("zoneFilter").addEventListener("change", function (event) {
            selectedZone = event.target.value;
            updatePage();
        });
        byId("refreshBtn").addEventListener("click", function () {
            addSample();
            showToast("Sensor readings refreshed.");
        });
        byId("exportBtn").addEventListener("click", exportCsv);
    }

    populateZoneFilter();
    setupControls();
    updatePage();
    window.setInterval(addSample, 5000);
    window.addEventListener("resize", drawChart);
}());
