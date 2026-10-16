(function () {
    var searchInput = document.getElementById("searchInput");
    var statusFilter = document.getElementById("statusFilter");
    var historyTable = document.getElementById("historyTable");
    var zones = window.IrrigationZones;
    var runs = window.IrrigationHistory.getAll();

    function escapeHtml(value) {
        return String(value).replace(/[&<>"']/g, function (character) {
            return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[character];
        });
    }

    function formatLiters(value) {
        return (Math.round((Number(value) || 0) * 10) / 10).toLocaleString(undefined, { maximumFractionDigits: 1 }) + " L";
    }

    function render() {
        var total = runs.reduce(function (sum, run) { return sum + (Number(run.liters) || 0); }, 0);
        document.getElementById("historyWater").textContent = formatLiters(total);
        document.getElementById("historySessions").textContent = String(runs.length);
        document.getElementById("historyAverage").textContent = formatLiters(runs.length ? total / runs.length : 0);

        var keyword = searchInput.value.trim().toLowerCase();
        var selectedStatus = statusFilter.value;
        var visible = runs.slice().sort(function (first, second) {
            return new Date(second.startedAt) - new Date(first.startedAt);
        }).filter(function (run) {
            var matchesStatus = selectedStatus === "all" || run.status.toLowerCase() === selectedStatus;
            var searchable = [run.startedAt, run.status, run.source, zones.name(run.zoneId), run.minutes, run.liters].join(" ").toLowerCase();
            return matchesStatus && (!keyword || searchable.indexOf(keyword) !== -1);
        });

        if (!visible.length) {
            historyTable.innerHTML = '<tr><td colspan="6" class="history-empty">No irrigation records match these filters.</td></tr>';
            return;
        }
        historyTable.innerHTML = visible.map(function (run) {
            var date = new Date(run.startedAt);
            var statusClass = run.status === "Completed" ? "success" : "warning";
            return '<tr><td>' + date.toLocaleDateString() + '</td><td>' + date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }) + '</td><td>' + Number(run.minutes || 0).toLocaleString(undefined, { maximumFractionDigits: 1 }) + ' min</td><td>' + formatLiters(run.liters) + '</td><td><span class="status ' + statusClass + '">' + escapeHtml(run.status) + '</span></td><td>' + escapeHtml(zones.name(run.zoneId)) + '</td></tr>';
        }).join("");
    }

    searchInput.addEventListener("input", render);
    statusFilter.addEventListener("change", render);
    window.addEventListener("storage", function (event) {
        if (event.key === "si.irrigation.history") {
            runs = window.IrrigationHistory.getAll();
            render();
        }
    });
    window.addEventListener("si:irrigation-history-updated", function () {
        runs = window.IrrigationHistory.getAll();
        render();
    });
    render();
}());