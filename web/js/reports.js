(function () {
    var periodSelect = document.getElementById("period");
    var reportMessage = document.getElementById("reportMessage");
    var zones = window.IrrigationZones;
    var brandLogo = document.querySelector(".brand-logo");
    var currentReport = null;

    if (brandLogo) brandLogo.innerHTML = '<svg class="icon icon-md"><use href="#i-logo"></use></svg>';

    function loadRuns() {
        return window.IrrigationHistory.getAll();
    }

    function startOfWeek(date) {
        var start = new Date(date.getFullYear(), date.getMonth(), date.getDate());
        start.setDate(start.getDate() - ((start.getDay() + 6) % 7));
        return start;
    }

    function periodBounds(period, now) {
        if (period === "month") return new Date(now.getFullYear(), now.getMonth(), 1);
        if (period === "year") return new Date(now.getFullYear(), 0, 1);
        return startOfWeek(now);
    }

    function previousPeriodStart(period, start) {
        if (period === "month") return new Date(start.getFullYear(), start.getMonth() - 1, 1);
        if (period === "year") return new Date(start.getFullYear() - 1, 0, 1);
        return new Date(start.getFullYear(), start.getMonth(), start.getDate() - 7);
    }

    function runsBetween(runs, from, to) {
        return runs.filter(function (run) {
            var timestamp = new Date(run.startedAt).getTime();
            return Number.isFinite(timestamp) && timestamp >= from && timestamp < to && Number(run.liters) > 0;
        });
    }

    function totalLiters(runs) {
        return runs.reduce(function (sum, run) { return sum + Math.max(0, Number(run.liters) || 0); }, 0);
    }

    function excessLiters(run) {
        var liters = Math.max(0, Number(run.liters) || 0);
        var recorded = Number(run.excessLiters);
        if (Number.isFinite(recorded)) return Math.max(0, Math.min(liters, recorded));
        var initial = Number(run.initialSoil);
        var final = Number(run.finalSoil);
        var gain = final - initial;
        if (!Number.isFinite(gain) || gain <= 0) return 0;
        return liters * Math.max(0, final - Math.max(initial, 80)) / gain;
    }

    function hasWasteEstimate(run) {
        var recorded = run.excessLiters !== undefined && run.excessLiters !== null && Number.isFinite(Number(run.excessLiters));
        return recorded || (Number.isFinite(Number(run.initialSoil)) && Number.isFinite(Number(run.finalSoil)));
    }

    function totalExcess(runs) {
        return runs.reduce(function (sum, run) { return sum + excessLiters(run); }, 0);
    }

    function estimatedWithinTarget(runs) {
        return runs.reduce(function (sum, run) {
            if (!hasWasteEstimate(run)) return sum;
            return sum + Math.max(0, Number(run.liters) - excessLiters(run));
        }, 0);
    }

    function unclassifiedWater(runs) {
        return runs.reduce(function (sum, run) {
            return sum + (hasWasteEstimate(run) ? 0 : Math.max(0, Number(run.liters) || 0));
        }, 0);
    }

    function formatLiters(value) {
        return (Math.round(value * 10) / 10).toLocaleString(undefined, { maximumFractionDigits: 1 }) + " L";
    }

    function comparisonText(current, previous) {
        if (previous <= 0) return current > 0 ? "No previous-period records" : "No change from previous period";
        var change = ((current - previous) / previous) * 100;
        var rounded = Math.round(Math.abs(change));
        return (change > 0 ? "+" : change < 0 ? "−" : "") + rounded + "% vs previous comparable period";
    }

    function bucketsFor(period, start) {
        var buckets = [];
        if (period === "year") {
            for (var month = 0; month < 12; month += 1) {
                buckets.push({ start: new Date(start.getFullYear(), month, 1), end: new Date(start.getFullYear(), month + 1, 1), label: new Date(start.getFullYear(), month, 1).toLocaleDateString(undefined, { month: "short" }) });
            }
        } else if (period === "month") {
            var days = new Date(start.getFullYear(), start.getMonth() + 1, 0).getDate();
            for (var day = 1; day <= days; day += 7) {
                var bucketStart = new Date(start.getFullYear(), start.getMonth(), day);
                var bucketEnd = new Date(start.getFullYear(), start.getMonth(), Math.min(day + 7, days + 1));
                buckets.push({ start: bucketStart, end: bucketEnd, label: day + "–" + Math.min(day + 6, days) });
            }
        } else {
            for (var offset = 0; offset < 7; offset += 1) {
                var date = new Date(start.getFullYear(), start.getMonth(), start.getDate() + offset);
                buckets.push({ start: date, end: new Date(date.getFullYear(), date.getMonth(), date.getDate() + 1), label: date.toLocaleDateString(undefined, { weekday: "short" }) });
            }
        }
        return buckets;
    }

    function renderChart(runs, period, start) {
        var buckets = bucketsFor(period, start).map(function (bucket) {
            var value = runsBetween(runs, bucket.start.getTime(), bucket.end.getTime()).reduce(function (sum, run) { return sum + Number(run.liters || 0); }, 0);
            return { label: bucket.label, value: value };
        });
        var maximum = Math.max.apply(null, buckets.map(function (bucket) { return bucket.value; })) || 1;
        document.getElementById("waterChart").innerHTML = buckets.map(function (bucket) {
            var height = bucket.value ? Math.max(4, bucket.value / maximum * 100) : 0;
            return '<div class="report-bar-column"><span class="report-bar-value">' + (bucket.value ? formatLiters(bucket.value) : "") + '</span><div class="report-bar-track"><span style="height:' + height + '%"></span></div><span class="report-bar-label">' + bucket.label + '</span></div>';
        }).join("");
        document.getElementById("chartTotal").textContent = formatLiters(totalLiters(runs)) + " total";
        document.getElementById("usageTitle").textContent = "Water used this " + period;
        document.getElementById("waterChart").setAttribute("aria-label", "Water use by " + (period === "year" ? "month" : period === "month" ? "week" : "day"));
    }

    function renderZones(runs) {
        var body = document.getElementById("zoneBreakdown");
        if (!runs.length) {
            body.innerHTML = '<tr><td colspan="4" class="report-empty-cell">No irrigation records in this period.</td></tr>';
            return;
        }
        body.innerHTML = zones.list.map(function (zone) {
            var zoneRuns = runs.filter(function (run) { return run.zoneId === zone.id; });
            var used = totalLiters(zoneRuns);
            var excess = totalExcess(zoneRuns);
            return '<tr><td><strong>' + zone.name + '</strong></td><td>' + zoneRuns.length + '</td><td>' + formatLiters(used) + '</td><td>' + formatLiters(excess) + '</td></tr>';
        }).join("");
    }

    function renderWaterWaste(runs, used, excess, period) {
        var share = used ? Math.min(100, excess / used * 100) : 0;
        var withinTarget = estimatedWithinTarget(runs);
        var unclassified = unclassifiedWater(runs);
        document.getElementById("waterWasteAmount").textContent = formatLiters(excess);
        document.getElementById("waterWasteShare").textContent = share.toFixed(1) + "% of water used";
        document.getElementById("waterWithinTarget").textContent = formatLiters(withinTarget);
        document.getElementById("waterWithinTargetDetail").textContent = unclassified
            ? formatLiters(unclassified) + " not estimated (no soil readings)"
            : "Estimated delivery below the 80% upper target";
        document.getElementById("waterWastePeriod").textContent = "This " + period;
        document.getElementById("waterWasteMeter").style.width = share + "%";
        document.querySelector(".water-waste-meter").setAttribute("aria-valuenow", share.toFixed(1));

        var gardenTotals = zones.list.map(function (zone) {
            var zoneRuns = runs.filter(function (run) { return run.zoneId === zone.id; });
            return { name: zone.name, waste: totalExcess(zoneRuns) };
        }).sort(function (first, second) { return second.waste - first.waste; });
        var maximum = Math.max.apply(null, gardenTotals.map(function (garden) { return garden.waste; })) || 1;
        document.getElementById("waterWasteGardens").innerHTML = gardenTotals.map(function (garden) {
            var width = garden.waste ? Math.max(3, garden.waste / maximum * 100) : 0;
            return '<div class="water-waste-garden"><span>' + garden.name + '</span><div class="water-waste-garden-track"><i style="width:' + width + '%"></i></div><strong>' + formatLiters(garden.waste) + '</strong></div>';
        }).join("");
        document.getElementById("waterWasteMethod").textContent = used
            ? "Estimate based on the recorded moisture increase and irrigation volume; it is not a direct flow-meter measurement."
            : "No irrigation records are available to estimate water waste for this period.";
    }

    function renderSummary(runs, used, excess, previousExcess) {
        var unclassified = unclassifiedWater(runs);
        var share = used ? (excess / used * 100).toFixed(1) : "0.0";
        var gardenWaste = zones.list.map(function (zone) {
            var zoneRuns = runs.filter(function (run) { return run.zoneId === zone.id; });
            return { name: zone.name, waste: totalExcess(zoneRuns) };
        }).sort(function (first, second) { return second.waste - first.waste; });
        var topGarden = gardenWaste[0];

        if (!runs.length) {
            document.getElementById("summaryHeadline").textContent = "No irrigation records";
            reportMessage.textContent = "Completed pump runs will appear here automatically.";
            document.getElementById("summaryTopGarden").textContent = "No data";
        } else if (excess > 0) {
            document.getElementById("summaryHeadline").textContent = share + "% of water use is estimated excess";
            reportMessage.textContent = "About " + formatLiters(excess) + " of " + formatLiters(used) + " was delivered above the 80% soil-moisture target. " + topGarden.name + " has the largest estimated excess at " + formatLiters(topGarden.waste) + ".";
            document.getElementById("summaryTopGarden").textContent = topGarden.name + " · " + formatLiters(topGarden.waste);
        } else {
            document.getElementById("summaryHeadline").textContent = unclassified ? "Waste estimate is incomplete" : "No excess estimated in measured runs";
            reportMessage.textContent = unclassified
                ? formatLiters(unclassified) + " of water use has no soil readings, so it cannot be classified as waste or within-target."
                : "No excess water was estimated for the available soil readings in this period.";
            document.getElementById("summaryTopGarden").textContent = "None detected";
        }
        if (runs.length && excess > 0 && unclassified > 0) {
            reportMessage.textContent += " Another " + formatLiters(unclassified) + " has no soil readings and was excluded from the estimate.";
        }
        document.getElementById("summaryWasteChange").textContent = comparisonText(excess, previousExcess);
    }

    function csvCell(value) {
        return '"' + String(value == null ? "" : value).replace(/"/g, '""') + '"';
    }

    function exportReport() {
        if (!currentReport) return;
        var runs = currentReport.runs;
        var used = totalLiters(runs);
        var excess = totalExcess(runs);
        var rows = [
            ["Irrigation report"],
            ["Period", currentReport.periodLabel],
            ["Start date", currentReport.start.toLocaleDateString()],
            ["Generated at", new Date().toLocaleString()],
            [],
            ["Summary metric", "Value"],
            ["Total water used (L)", used.toFixed(1)],
            ["Estimated water waste (L)", excess.toFixed(1)],
            ["Estimated within target (L)", estimatedWithinTarget(runs).toFixed(1)],
            ["Not estimated, missing soil readings (L)", unclassifiedWater(runs).toFixed(1)],
            ["Estimated waste share (%)", used ? (excess / used * 100).toFixed(1) : "0.0"],
            ["Estimated water efficiency (%)", used ? Math.max(0, (1 - excess / used) * 100).toFixed(1) : ""],
            ["Irrigation sessions", runs.length],
            ["Waste vs previous period", comparisonText(excess, totalExcess(currentReport.previousRuns))],
            [],
            ["Garden", "Sessions", "Water used (L)", "Estimated waste (L)", "Within target (L)", "Not estimated (L)"]
        ];
        zones.list.forEach(function (zone) {
            var zoneRuns = runs.filter(function (run) { return run.zoneId === zone.id; });
            rows.push([
                zone.name,
                zoneRuns.length,
                totalLiters(zoneRuns).toFixed(1),
                totalExcess(zoneRuns).toFixed(1),
                estimatedWithinTarget(zoneRuns).toFixed(1),
                unclassifiedWater(zoneRuns).toFixed(1)
            ]);
        });

        var csv = "\uFEFF" + rows.map(function (row) {
            return row.map(csvCell).join(",");
        }).join("\r\n");
        var link = document.createElement("a");
        var date = new Date().toISOString().slice(0, 10);
        link.href = URL.createObjectURL(new Blob([csv], { type: "text/csv;charset=utf-8" }));
        link.download = "irrigation-report-" + currentReport.period + "-" + date + ".csv";
        document.body.appendChild(link);
        link.click();
        link.remove();
        window.setTimeout(function () { URL.revokeObjectURL(link.href); }, 1000);
    }

    function render() {
        var now = new Date();
        var period = periodSelect.value;
        var start = periodBounds(period, now);
        var currentEnd = now.getTime() + 1;
        var previousStart = previousPeriodStart(period, start);
        var allRuns = loadRuns();
        var currentRuns = runsBetween(allRuns, start.getTime(), currentEnd);
        var previousRuns = runsBetween(allRuns, previousStart.getTime(), start.getTime());
        var used = totalLiters(currentRuns);
        var excess = totalExcess(currentRuns);
        var previousUsed = totalLiters(previousRuns);
        var previousExcess = totalExcess(previousRuns);
        var previousSessions = previousRuns.length;
        currentReport = {
            period: period,
            periodLabel: period === "week" ? "This week" : period === "month" ? "This month" : "This year",
            start: start,
            runs: currentRuns,
            previousRuns: previousRuns
        };

        document.getElementById("totalWater").textContent = formatLiters(used);
        document.getElementById("waterChange").textContent = comparisonText(used, previousUsed);
        document.getElementById("excessWater").textContent = formatLiters(excess);
        document.getElementById("excessDetail").textContent = used ? (excess / used * 100).toFixed(1) + "% of water used" : "Above the 80% soil target";
        document.getElementById("sessionCount").textContent = currentRuns.length.toLocaleString();
        document.getElementById("sessionChange").textContent = comparisonText(currentRuns.length, previousSessions);
        document.getElementById("efficiency").textContent = used ? Math.max(0, (1 - excess / used) * 100).toFixed(1) + "%" : "--%";
        document.getElementById("efficiencyDetail").textContent = used ? "Estimated water below the excess threshold" : "No water-use data for this period";
        document.getElementById("reportUpdated").textContent = "Updated " + now.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
        renderWaterWaste(currentRuns, used, excess, period);
        renderSummary(currentRuns, used, excess, previousExcess);
        renderChart(currentRuns, period, start);
        renderZones(currentRuns);
    }

    document.getElementById("generateButton").addEventListener("click", render);
    document.getElementById("exportReportBtn").addEventListener("click", exportReport);
    periodSelect.addEventListener("change", render);
    window.addEventListener("storage", function (event) {
        if (event.key === "si.irrigation.history") render();
    });
    window.addEventListener("si:irrigation-history-updated", render);
    render();
}());