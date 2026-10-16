/* =====================================================================
   Smart Irrigation - Dashboard
   - Dashboard lấy KPI từ JSP và telemetry từ /api/sensors.
   - Các thao tác ghi dữ liệu vẫn đi qua các Servlet backend tương ứng.
   ===================================================================== */
(function () {
    'use strict';

    /* ===== CẤU HÌNH ===== */
    var CONFIG = {
        DEMO_SPEED: 10,       // 1 giây thật = 10 giây mô phỏng khi bơm chạy (đặt 1 để chạy đúng thời gian thực)
        TICK_MS: 3000,        // chu kỳ cập nhật cảm biến (ms)
        FLOW_L_PER_MIN: 2,    // lưu lượng bơm (lít / phút)
        GAIN_PER_MIN: 0.9,    // độ ẩm đất tăng (%) cho mỗi phút tưới
        QUOTA_L: 160          // hạn mức nước mỗi ngày (lít)
    };

    var N = 288;                  // số điểm lịch sử (24h, mỗi 5 phút)
    var STEP = 5 * 60 * 1000;
    var CIRC = 2 * Math.PI * 70;  // chu vi vòng tròn bơm

    var METRICS = {
        soil:        { label: 'Soil Moisture', unit: '%',  min: 30, max: 100, target: [60, 80], color: '#10b981', dec: 0 },
        temperature: { label: 'Temperature',   unit: '°C', min: 15, max: 40,  target: [20, 30], color: '#ef4444', dec: 1 },
        humidity:    { label: 'Humidity',      unit: '%',  min: 30, max: 100, target: [50, 80], color: '#3b82f6', dec: 0 }
    };

    var ACT = {
        water:  { icon: 'i-drop',    tone: 'tone-sky' },
        sensor: { icon: 'i-sprout',  tone: 'tone-emerald' },
        check:  { icon: 'i-check',   tone: 'tone-teal' },
        pump:   { icon: 'i-bolt',    tone: 'tone-amber' },
        mode:   { icon: 'i-sparkle', tone: 'tone-purple' },
        alert:  { icon: 'i-bell',    tone: 'tone-rose' }
    };

    /* ===== HÀM TIỆN ÍCH ===== */
    function $(s, r) { return (r || document).querySelector(s); }
    function $$(s, r) { return Array.prototype.slice.call((r || document).querySelectorAll(s)); }
    function clamp(v, a, b) { return Math.max(a, Math.min(b, v)); }
    function rand(a, b) { return a + Math.random() * (b - a); }
    function pad(n) { return (n < 10 ? '0' : '') + n; }
    function hhmm(d) { return pad(d.getHours()) + ':' + pad(d.getMinutes()); }
    function mmss(sec) { sec = Math.max(0, Math.ceil(sec)); return pad(Math.floor(sec / 60)) + ':' + pad(sec % 60); }
    function esc(s) { return String(s).replace(/[&<>"']/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]; }); }
    function icon(id, cls) { return '<svg class="icon ' + (cls || '') + '" viewBox="0 0 24 24"><use href="#' + id + '"></use></svg>'; }

    function load(k, def) {
        try { var v = localStorage.getItem('si.' + k); return v === null ? def : JSON.parse(v); } catch (e) { return def; }
    }
    function save(k, v) {
        try { localStorage.setItem('si.' + k, JSON.stringify(v)); } catch (e) { /* bỏ qua */ }
    }

    function timeAgo(ts) {
        var s = Math.floor((Date.now() - ts) / 1000);
        if (s < 60) { return 'just now'; }
        if (s < 3600) { return Math.floor(s / 60) + ' min ago'; }
        if (s < 86400) { return Math.floor(s / 3600) + 'h ago'; }
        return Math.floor(s / 86400) + 'd ago';
    }

    /* ===== TRẠNG THÁI ===== */
    var ctx = window.SI_CTX || (window.location.pathname.split('/').slice(0, 2).join('/') || '');
    var access = window.SI_ACCESS || {};
    var canWater = !Array.isArray(access.write) || access.write.indexOf('/manual-water') !== -1;
    var canSchedule = !Array.isArray(access.write) || access.write.indexOf('/api/schedules') !== -1;
    var canExport = !Array.isArray(access.read) || access.read.indexOf('/export-history') !== -1;
    var canReadSensors = !Array.isArray(access.read) || access.read.indexOf('/sensor-data') !== -1;
    var defaultZoneId = (window.IrrigationZones.list[0] && window.IrrigationZones.list[0].id) || '1';
    var state = {
        mode: load('mode', 'auto'),
        threshold: load('threshold', 60),
        metric: 'soil',
        rangeHours: 24,
        temp: 27.4,
        hum: 69,
        water: Number($('#water') ? $('#water').textContent : 0) || 0,
        zones: window.IrrigationZones.list.map(function (zone) {
            return {
                id: String(zone.id),
                dbPotId: zone.dbPotId || zone.potId || Number(zone.id) || 1,
                name: zone.name,
                crop: zone.crop,
                moisture: window.IrrigationZones.getSoilMoisture(zone.id)
            };
        }),
        series: { soil: [], temperature: [], humidity: [] },
        stamp: Date.now(),
        events: [],
        weekly: [],
        activity: [],
        schedules: window.IrrigationSchedules.getAll(),
        pump: { on: false, zone: defaultZoneId, minutes: load('duration', 10), simLeft: 0, simTotal: 0, liters: 0, timer: null },
        rec: null,
        lastAuto: 0,
        lastSchedKey: '',
        hoverIdx: null
    };

    var requestedZone = new URLSearchParams(window.location.search).get('zone');
    if (window.IrrigationZones.get(requestedZone)) { state.pump.zone = String(window.IrrigationZones.get(requestedZone).id); }

    var chartGeo = null;
    var drawQueued = false;

    /* ===== DỮ LIỆU MÔ PHỎNG ===== */
    function zoneById(id) {
        for (var i = 0; i < state.zones.length; i++) { if (String(state.zones[i].id) === String(id)) { return state.zones[i]; } }
        return state.zones[0];
    }
    function avgSoil() {
        var sum = 0;
        state.zones.forEach(function (z) { sum += z.moisture; });
        return sum / state.zones.length;
    }
    function driestZone() {
        return state.zones.slice().sort(function (a, b) { return a.moisture - b.moisture; })[0];
    }
    function recMinutes(z) {
        return clamp(Math.round((75 - z.moisture) / CONFIG.GAIN_PER_MIN / 5) * 5, 5, 20);
    }
    function lastAt(hour) {
        var d = new Date();
        d.setMinutes(0, 0, 0);
        d.setHours(hour);
        if (d.getTime() > Date.now()) { d.setDate(d.getDate() - 1); }
        return d.getTime();
    }

    function buildSeries() {
        var now = Date.now();
        var evs = state.events.map(function (e) { return e.ts; }).sort(function (a, b) { return a - b; });
        var ptr = 0, boost = 0, soil = 77;
        var out = { soil: [], temperature: [], humidity: [] };

        for (var i = N - 1; i >= 0; i--) {
            var t = now - i * STEP;
            var d = new Date(t);
            var h = d.getHours() + d.getMinutes() / 60;
            var wave = Math.sin((h - 9) / 24 * 2 * Math.PI);

            if (ptr < evs.length && t >= evs[ptr]) { boost = 2; ptr++; }
            soil -= rand(0.03, 0.09);
            if (boost > 0) { soil += 3.6; boost--; }
            soil = clamp(soil, 40, 95);

            out.soil.push({ t: t, v: soil });
            out.temperature.push({ t: t, v: 26 + 4.5 * wave + rand(-0.25, 0.25) });
            out.humidity.push({ t: t, v: clamp(68 - 11 * wave + rand(-0.8, 0.8), 35, 95) });
        }
        return out;
    }

    function buildWeekly() {
        var names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        var fallbackVals = [142, 118, 156, 131, 149, 97];
        var runs = (window.SI_DATA && Array.isArray(window.SI_DATA.history)) ? window.SI_DATA.history : [];
        var out = [];
        for (var i = 6; i >= 1; i--) {
            var d = new Date();
            d.setHours(0, 0, 0, 0);
            d.setDate(d.getDate() - i);
            var nextDay = new Date(d.getTime() + 86400000);
            var dayLiters = runs.reduce(function (sum, r) {
                var ts = new Date(r.startedAt).getTime();
                return (ts >= d.getTime() && ts < nextDay.getTime()) ? sum + (Number(r.liters) || 0) : sum;
            }, 0);
            out.push({ label: names[d.getDay()], v: dayLiters > 0 ? Math.round(dayLiters * 10) / 10 : fallbackVals[6 - i] });
        }
        out.push({ label: 'Today', v: state.water });
        return out;
    }

    /* ===== TOAST ===== */
    function toast(msg, type) {
        var box = $('#toastBox');
        if (!box) { return; }
        var el = document.createElement('div');
        el.className = 'toast ' + (type || '');
        el.textContent = msg;
        box.appendChild(el);
        setTimeout(function () {
            el.classList.add('hide');
            setTimeout(function () { if (el.parentNode) { el.parentNode.removeChild(el); } }, 300);
        }, 3200);
    }

    /* ===== KPI + SPARKLINE ===== */
    function setBadge(id, text, cls) {
        var el = $(id);
        if (!el) { return; }
        el.textContent = text;
        el.className = 'badge ' + cls;
    }

    function sparkline(id, values, color) {
        var el = $(id);
        if (!el || !values.length) { return; }
        var w = 100, h = 32;
        var min = Math.min.apply(null, values), max = Math.max.apply(null, values);
        if (max === min) { max += 1; min -= 1; }
        var pts = values.map(function (v, i) {
            var x = (i / (values.length - 1)) * w;
            var y = h - 3 - ((v - min) / (max - min)) * (h - 6);
            return x.toFixed(1) + ',' + y.toFixed(1);
        });
        el.innerHTML = '<polyline fill="none" stroke="' + color + '" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" points="' + pts.join(' ') + '"/>';
    }

    function renderKpis() {
        var soil = avgSoil();
        var pct = state.water / CONFIG.QUOTA_L * 100;

        $('#temperature').textContent = state.temp.toFixed(1);
        $('#humidity').textContent = Math.round(state.hum);
        $('#soil').textContent = Math.round(soil);
        $('#water').textContent = Math.round(state.water);

        if (state.temp < 15) { setBadge('#tempBadge', 'Cold', 'info'); }
        else if (state.temp > 32) { setBadge('#tempBadge', 'Hot', 'danger'); }
        else if (state.temp > 30) { setBadge('#tempBadge', 'Warm', 'warn'); }
        else { setBadge('#tempBadge', 'Nominal', 'good'); }

        if (state.hum < 40) { setBadge('#humBadge', 'Dry air', 'warn'); }
        else if (state.hum > 85) { setBadge('#humBadge', 'Humid', 'warn'); }
        else { setBadge('#humBadge', 'Balanced', 'good'); }

        if (soil < 45) { setBadge('#soilBadge', 'Dry', 'danger'); }
        else if (soil < 60) { setBadge('#soilBadge', 'Low', 'warn'); }
        else if (soil > 80) { setBadge('#soilBadge', 'Wet', 'info'); }
        else { setBadge('#soilBadge', 'Optimal', 'good'); }

        if (pct >= 100) { setBadge('#waterBadge', 'Over quota', 'danger'); }
        else if (pct >= 90) { setBadge('#waterBadge', 'Near cap', 'warn'); }
        else { setBadge('#waterBadge', 'On track', 'good'); }

        $('#soilBar').style.width = clamp(soil, 0, 100) + '%';
        $('#waterBar').style.width = clamp(pct, 0, 100) + '%';
        $('#waterQuotaText').textContent = pct.toFixed(1) + '% of ' + CONFIG.QUOTA_L + ' L quota';

        var tail = function (arr) { return arr.slice(arr.length - 48).map(function (p) { return p.v; }); };
        sparkline('#spkTemp', tail(state.series.temperature), METRICS.temperature.color);
        sparkline('#spkHum', tail(state.series.humidity), METRICS.humidity.color);

        var now = new Date();
        $('#lastUpdate').textContent = pad(now.getHours()) + ':' + pad(now.getMinutes()) + ':' + pad(now.getSeconds());
        $('#nodesActive').textContent = state.zones.length;
    }

    /* ===== BIỂU ĐỒ TELEMETRY (SVG) ===== */
    function drawTelemetry() {
        var box = $('#telemetryChart');
        if (!box) { return; }

        var cfg = METRICS[state.metric];
        var all = state.series[state.metric];
        var count = Math.min(all.length, Math.round(state.rangeHours * 12));
        var pts = all.slice(all.length - count);

        var W = Math.max(300, box.clientWidth), H = 280;
        var m = { l: 44, r: 14, t: 20, b: 28 };
        var iw = W - m.l - m.r, ih = H - m.t - m.b;

        function X(i) { return m.l + (count <= 1 ? 0 : i / (count - 1)) * iw; }
        function Y(v) { return clamp(m.t + (1 - (v - cfg.min) / (cfg.max - cfg.min)) * ih, m.t, m.t + ih); }

        var s = [];
        s.push('<svg viewBox="0 0 ' + W + ' ' + H + '" width="' + W + '" height="' + H + '" role="img" aria-label="' + cfg.label + ' chart">');
        s.push('<defs><linearGradient id="tgrad" x1="0" y1="0" x2="0" y2="1">' +
               '<stop offset="0" stop-color="' + cfg.color + '" stop-opacity="0.28"/>' +
               '<stop offset="1" stop-color="' + cfg.color + '" stop-opacity="0"/></linearGradient></defs>');

        // lưới + nhãn trục Y
        for (var g = 0; g <= 4; g++) {
            var gv = cfg.min + (cfg.max - cfg.min) * g / 4;
            var gy = Y(gv);
            s.push('<line class="grid" x1="' + m.l + '" x2="' + (W - m.r) + '" y1="' + gy.toFixed(1) + '" y2="' + gy.toFixed(1) + '"/>');
            s.push('<text class="axis" x="' + (m.l - 8) + '" y="' + (gy + 4).toFixed(1) + '" text-anchor="end">' + Math.round(gv) + '</text>');
        }

        // vùng mục tiêu
        var by1 = Y(cfg.target[1]), by2 = Y(cfg.target[0]);
        s.push('<rect class="band" x="' + m.l + '" y="' + by1.toFixed(1) + '" width="' + iw + '" height="' + (by2 - by1).toFixed(1) + '"/>');
        s.push('<line class="band-line" x1="' + m.l + '" x2="' + (W - m.r) + '" y1="' + by1.toFixed(1) + '" y2="' + by1.toFixed(1) + '"/>');
        s.push('<line class="band-line" x1="' + m.l + '" x2="' + (W - m.r) + '" y1="' + by2.toFixed(1) + '" y2="' + by2.toFixed(1) + '"/>');

        // đường + vùng tô
        var d = '';
        for (var i = 0; i < count; i++) {
            d += (i ? 'L' : 'M') + X(i).toFixed(1) + ',' + Y(pts[i].v).toFixed(1);
        }
        var area = d + 'L' + X(count - 1).toFixed(1) + ',' + (m.t + ih) + 'L' + X(0).toFixed(1) + ',' + (m.t + ih) + 'Z';
        s.push('<path d="' + area + '" fill="url(#tgrad)"/>');
        s.push('<path d="' + d + '" fill="none" stroke="' + cfg.color + '" stroke-width="2.5" stroke-linejoin="round" stroke-linecap="round"/>');

        // nhãn trục X
        for (var k = 0; k <= 4; k++) {
            var idx = Math.round((count - 1) * k / 4);
            var label = k === 4 ? 'Now' : hhmm(new Date(pts[idx].t));
            var anchor = k === 0 ? 'start' : (k === 4 ? 'end' : 'middle');
            s.push('<text class="axis" x="' + X(idx).toFixed(1) + '" y="' + (H - 8) + '" text-anchor="' + anchor + '">' + label + '</text>');
        }

        // các lần tưới (pulse)
        var t0 = pts[0].t, t1 = pts[count - 1].t;
        state.events.forEach(function (ev) {
            if (ev.ts < t0 || ev.ts > t1) { return; }
            var ix = 0;
            while (ix < count - 1 && pts[ix].t < ev.ts) { ix++; }
            var x = X(ix);
            var anchorEv = x > W - 110 ? 'end' : (x < m.l + 60 ? 'start' : 'middle');
            s.push('<line class="pulse-line" x1="' + x.toFixed(1) + '" x2="' + x.toFixed(1) + '" y1="' + m.t + '" y2="' + (m.t + ih) + '"/>');
            s.push('<circle class="pulse-dot" cx="' + x.toFixed(1) + '" cy="' + m.t + '" r="4.5"><title>' + hhmm(new Date(ev.ts)) + ' - ' + ev.liters + ' L</title></circle>');
            s.push('<text class="ev-label" x="' + x.toFixed(1) + '" y="' + (m.t + 18) + '" text-anchor="' + anchorEv + '">' + hhmm(new Date(ev.ts)) + ' · ' + Math.round(ev.liters) + ' L</text>');
        });

        // điểm hiện tại
        var lx = X(count - 1), ly = Y(pts[count - 1].v);
        s.push('<circle class="last-ring" cx="' + lx.toFixed(1) + '" cy="' + ly.toFixed(1) + '" r="9" fill="' + cfg.color + '"/>');
        s.push('<circle cx="' + lx.toFixed(1) + '" cy="' + ly.toFixed(1) + '" r="4.5" fill="#fff" stroke="' + cfg.color + '" stroke-width="2.5"/>');

        // phần tử hover
        s.push('<line class="hover-line" id="hoverLine" x1="0" x2="0" y1="0" y2="0" style="display:none"/>');
        s.push('<circle id="hoverDot" r="5" fill="#fff" stroke="' + cfg.color + '" stroke-width="2.5" style="display:none"/>');
        s.push('</svg>');

        box.innerHTML = s.join('');
        chartGeo = { W: W, H: H, m: m, iw: iw, ih: ih, count: count, pts: pts, cfg: cfg, X: X, Y: Y };

        var cur = pts[count - 1].v;
        $('#chartTitle').textContent = cfg.label;
        $('#chartNow').textContent = cur.toFixed(cfg.dec) + cfg.unit;
        $('#chartTarget').textContent = cfg.target[0] + '–' + cfg.target[1] + cfg.unit;

        if (state.hoverIdx !== null) { showHover(state.hoverIdx); }
    }

    function showHover(idx) {
        var g = chartGeo;
        if (!g) { return; }
        idx = clamp(idx, 0, g.count - 1);
        state.hoverIdx = idx;

        var p = g.pts[idx], x = g.X(idx), y = g.Y(p.v);
        var hl = $('#hoverLine'), hd = $('#hoverDot'), tip = $('#telemetryTooltip');

        if (hl) {
            hl.setAttribute('x1', x); hl.setAttribute('x2', x);
            hl.setAttribute('y1', g.m.t); hl.setAttribute('y2', g.m.t + g.ih);
            hl.style.display = '';
        }
        if (hd) {
            hd.setAttribute('cx', x); hd.setAttribute('cy', y);
            hd.style.display = '';
        }
        tip.innerHTML = '<strong>' + p.v.toFixed(g.cfg.dec) + ' ' + g.cfg.unit + '</strong><span>' + hhmm(new Date(p.t)) + '</span>';
        tip.hidden = false;
        var wrapW = tip.parentNode.clientWidth;
        tip.style.left = clamp(x, 56, wrapW - 56) + 'px';
        tip.style.top = (y - 12) + 'px';
    }

    function hideHover() {
        state.hoverIdx = null;
        var hl = $('#hoverLine'), hd = $('#hoverDot'), tip = $('#telemetryTooltip');
        if (hl) { hl.style.display = 'none'; }
        if (hd) { hd.style.display = 'none'; }
        if (tip) { tip.hidden = true; }
    }

    /* ===== BIỂU ĐỒ CỘT 7 NGÀY ===== */
    function drawWeekly() {
        var box = $('#weeklyChart');
        if (!box) { return; }

        state.weekly[6].v = state.water;
        var data = state.weekly;
        var W = Math.max(260, box.clientWidth), H = 220;
        var m = { l: 36, r: 6, t: 22, b: 26 };
        var iw = W - m.l - m.r, ih = H - m.t - m.b;

        var peak = Math.max.apply(null, data.map(function (x) { return x.v; }));
        var maxV = Math.max(CONFIG.QUOTA_L * 1.2, peak * 1.12);
        var step = Math.ceil(maxV / 4 / 10) * 10;
        maxV = step * 4;

        function Y(v) { return m.t + (1 - v / maxV) * ih; }
        var slot = iw / data.length;
        var bw = Math.min(30, slot * 0.58);

        var s = [];
        s.push('<svg viewBox="0 0 ' + W + ' ' + H + '" width="' + W + '" height="' + H + '" role="img" aria-label="Water usage in the last 7 days">');

        for (var v = 0; v <= maxV; v += step) {
            s.push('<line class="grid" x1="' + m.l + '" x2="' + (W - m.r) + '" y1="' + Y(v).toFixed(1) + '" y2="' + Y(v).toFixed(1) + '"/>');
            s.push('<text class="axis" x="' + (m.l - 8) + '" y="' + (Y(v) + 4).toFixed(1) + '" text-anchor="end">' + v + '</text>');
        }

        var total = 0;
        data.forEach(function (row, i) {
            total += row.v;
            var cx = m.l + slot * i + slot / 2;
            var y = Y(row.v);
            var cls = 'bar' + (i === data.length - 1 ? ' today' : '') + (row.v > CONFIG.QUOTA_L ? ' over' : '');
            s.push('<rect class="' + cls + '" x="' + (cx - bw / 2).toFixed(1) + '" y="' + y.toFixed(1) + '" width="' + bw.toFixed(1) + '" height="' + Math.max(0, m.t + ih - y).toFixed(1) + '" rx="6"><title>' + row.label + ': ' + Math.round(row.v) + ' L</title></rect>');
            s.push('<text class="bar-val" x="' + cx.toFixed(1) + '" y="' + (y - 6).toFixed(1) + '" text-anchor="middle">' + Math.round(row.v) + '</text>');
            s.push('<text class="axis" x="' + cx.toFixed(1) + '" y="' + (H - 8) + '" text-anchor="middle">' + row.label + '</text>');
        });

        var qy = Y(CONFIG.QUOTA_L);
        s.push('<line class="quota-line" x1="' + m.l + '" x2="' + (W - m.r) + '" y1="' + qy.toFixed(1) + '" y2="' + qy.toFixed(1) + '"/>');
        s.push('<text class="quota-label" x="' + (W - m.r) + '" y="' + (qy - 5).toFixed(1) + '" text-anchor="end">Quota ' + CONFIG.QUOTA_L + ' L</text>');
        s.push('</svg>');

        box.innerHTML = s.join('');
        $('#weeklyTotal').textContent = 'Total ' + Math.round(total) + ' L';
    }

    function queueDraw() {
        if (drawQueued) { return; }
        drawQueued = true;
        requestAnimationFrame(function () {
            drawQueued = false;
            drawTelemetry();
            drawWeekly();
        });
    }

    /* ===== VÙNG TƯỚI ===== */
    function zoneStatus(v) {
        if (v < 45) { return { text: 'Dry', cls: 'danger' }; }
        if (v < 60) { return { text: 'Low', cls: 'warn' }; }
        if (v > 80) { return { text: 'Wet', cls: 'info' }; }
        return { text: 'Optimal', cls: 'good' };
    }

    function buildZones() {
        $('#zoneList').innerHTML = state.zones.map(function (z) {
            var titleHtml = canReadSensors
                ? '<a class="zone-detail-link" href="' + ctx + '/sensor-data?zone=' + encodeURIComponent(z.id) + '"><strong>' + esc(z.name) + '</strong></a>'
                : '<strong>' + esc(z.name) + '</strong>';
            var waterBtnHtml = canWater
                ? '<button type="button" class="zone-water" data-zone="' + z.id + '">' + icon('i-drop', 'icon-sm') + 'Water</button>'
                : '';
            return '<div class="zone" data-id="' + z.id + '">' +
                '<div class="zone-head"><div>' + titleHtml + '<span>' + esc(z.crop) + '</span></div>' +
                '<span class="badge good" data-role="badge">Optimal</span></div>' +
                '<div class="zone-bar"><span data-role="bar"></span></div>' +
                '<div class="zone-foot"><b data-role="val">0%</b>' + waterBtnHtml + '</div>' +
                '</div>';
        }).join('');

        $('#zoneSelect').innerHTML = state.zones.map(function (z) {
            return '<option value="' + z.id + '">' + esc(z.name) + ' · ' + esc(z.crop) + '</option>';
        }).join('');
    }

    function updateZones() {
        state.zones.forEach(function (z) {
            var el = $('.zone[data-id="' + z.id + '"]');
            if (!el) { return; }
            var st = zoneStatus(z.moisture);
            var watering = state.pump.on && state.pump.zone === z.id;

            var badge = $('[data-role="badge"]', el);
            badge.textContent = watering ? 'Watering' : st.text;
            badge.className = 'badge ' + (watering ? 'info' : st.cls);

            var bar = $('[data-role="bar"]', el);
            bar.style.width = clamp(z.moisture, 0, 100) + '%';
            bar.className = watering ? 'info' : st.cls;

            $('[data-role="val"]', el).textContent = Math.round(z.moisture) + '%';
            var zw = $('.zone-water', el);
            if (zw) { zw.disabled = state.pump.on || !canWater; }
            el.classList.toggle('watering', watering);
        });
    }

    /* ===== BƠM ===== */
    function renderPump() {
        var p = state.pump;
        var on = p.on;
        var prog = on && p.simTotal > 0 ? 1 - p.simLeft / p.simTotal : 0;

        var ring = $('#ringProgress');
        ring.style.strokeDasharray = CIRC;
        ring.style.strokeDashoffset = CIRC * (1 - prog);
        ring.classList.toggle('running', on);

        $('#pumpCircle').classList.toggle('running', on);
        $('#pumpTimer').textContent = on ? mmss(p.simLeft) : 'STANDBY';
        $('#pumpPressure').textContent = on ? '3.4 bar' : '3.2 bar norm';

        var st = $('#pumpStatus');
        st.textContent = on ? 'Running' : (canWater ? 'Ready' : 'View Only');
        st.className = 'status ' + (on ? 'running' : 'success');

        $('#pumpText').textContent = on ? 'Pump is Running' : (canWater ? 'Pump is Ready' : 'Pump Control Locked');
        $('#pumpSub').textContent = on
            ? 'Watering ' + zoneById(p.zone).name + ' · ' + p.liters.toFixed(1) + ' L so far'
            : (canWater ? 'Control your irrigation system manually.' : 'Your role does not include manual pump execution permission.');

        var btn = $('#pumpButton');
        btn.classList.toggle('btn-danger', on);
        btn.classList.toggle('btn-primary', !on);
        btn.disabled = !canWater;
        btn.innerHTML = !canWater
            ? 'View Only (No Watering Permission)'
            : (on
                ? icon('i-stop', 'icon-sm') + ' Stop Pump'
                : icon('i-play', 'icon-sm') + ' Start Pump · ' + p.minutes + ' min');

        $('#zoneSelect').disabled = on || !canWater;
        $$('#durationChips .chip').forEach(function (c) {
            c.disabled = on || !canWater;
            var active = Number(c.getAttribute('data-min')) === p.minutes;
            c.classList.toggle('active', active);
            c.setAttribute('aria-pressed', active ? 'true' : 'false');
        });
        if ($('#aiApply')) {
            $('#aiApply').disabled = !canWater;
            if (!canWater) { $('#aiApply').hidden = true; }
        }
    }

    function persistManualWatering(zoneId, minutes) {
        if (!canWater) { return; }
        var zone = zoneById(zoneId);
        var potId = (zone && zone.dbPotId) || Number(zoneId) || 1;
        var body = 'potId=' + encodeURIComponent(potId)
            + '&volume=' + encodeURIComponent(minutes * CONFIG.FLOW_L_PER_MIN * 1000);
        fetch(ctx + '/manual-water', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'fetch'
            },
            body: body
        }).catch(function () {
            toast('Could not save watering command', 'warn');
        });
    }

    function startPump(zoneId, minutes, reason) {
        if (!canWater) {
            toast('Access denied: your role cannot execute pump watering.', 'warn');
            return;
        }
        var p = state.pump;
        if (p.on) { return; }

        var z = zoneById(zoneId);
        persistManualWatering(zoneId, minutes);
        p.on = true;
        p.zone = z.id;
        p.minutes = minutes;
        p.simTotal = minutes * 60;
        p.simLeft = p.simTotal;
        p.liters = 0;
        $('#zoneSelect').value = z.id;
        hideHover();

        p.timer = setInterval(pumpTick, 1000);
        addActivity('pump', 'Irrigation started', reason + ' · ' + z.name + ' · ' + minutes + ' min');
        toast('Pump started · ' + z.name, 'good');
        renderPump();
        renderAll();
    }

    function pumpTick() {
        var p = state.pump;
        if (!p.on) { return; }

        var dt = Math.min(CONFIG.DEMO_SPEED, p.simLeft);
        var mins = dt / 60;
        p.simLeft -= dt;

        var z = zoneById(p.zone);
        z.moisture = clamp(z.moisture + CONFIG.GAIN_PER_MIN * mins, 0, 100);
        window.IrrigationZones.setSoilMoisture(z.id, z.moisture);

        var liters = CONFIG.FLOW_L_PER_MIN * mins;
        p.liters += liters;
        state.water += liters;

        pushLive();
        renderPump();
        renderAll();

        if (p.simLeft <= 0.001) { stopPump(true); }
    }

    function stopPump(completed) {
        var p = state.pump;
        if (!p.on) { return; }

        clearInterval(p.timer);
        p.timer = null;
        p.on = false;

        var z = zoneById(p.zone);
        var elapsed = Math.round((p.simTotal - p.simLeft) / 60 * 10) / 10;
        var used = Math.round(p.liters * 10) / 10;

        if (used > 0.05) {
            state.events.push({ ts: Date.now(), liters: used, min: elapsed });
            addActivity('water', completed ? 'Irrigation completed' : 'Irrigation stopped', used + ' liters of water used · ' + z.name);
        }
        toast(completed ? 'Irrigation completed · ' + used + ' L' : 'Pump stopped', completed ? 'good' : 'warn');

        p.simLeft = 0;
        p.simTotal = 0;
        p.liters = 0;
        renderPump();
        renderAll();
    }

    /* ===== CHẾ ĐỘ AUTO / MANUAL ===== */
    function setMode(mode, silent) {
        if (!canWater && !silent) {
            toast('Access denied: your role cannot change pump mode.', 'warn');
            return;
        }
        state.mode = mode;
        save('mode', mode);

        $$('#modeToggle .seg-btn').forEach(function (b) {
            var active = b.getAttribute('data-mode') === mode;
            b.classList.toggle('active', active);
            b.setAttribute('aria-pressed', active ? 'true' : 'false');
            b.disabled = !canWater;
        });

        $('#stripMode').textContent = mode === 'auto' ? 'Eco-AI Cycle Armed' : 'Manual control';
        $('#thresholdRange').disabled = mode !== 'auto' || !canWater;
        $('#thresholdRange').parentNode.classList.toggle('disabled', mode !== 'auto' || !canWater);

        if (!silent) {
            addActivity('mode', 'Control mode changed', mode === 'auto' ? 'Automatic irrigation enabled' : 'Manual control enabled');
            toast(mode === 'auto' ? 'Auto mode enabled' : 'Manual mode enabled');
        }
    }

    function autoCheck() {
        if (!canWater || state.mode !== 'auto' || state.pump.on) { return; }
        if (Date.now() - state.lastAuto < 20000) { return; }

        var z = driestZone();
        if (z.moisture < state.threshold) {
            state.lastAuto = Date.now();
            startPump(z.id, recMinutes(z), 'Auto: soil ' + Math.round(z.moisture) + '% < ' + state.threshold + '%');
        }
    }

    /* ===== GỢI Ý AI ===== */
    function renderAI() {
        var z = driestZone();
        var mins = recMinutes(z);
        var water = mins * CONFIG.FLOW_L_PER_MIN;
        var after = Math.min(100, z.moisture + CONFIG.GAIN_PER_MIN * mins);
        var conf = Math.round(clamp(94 - Math.abs(75 - avgSoil()) * 0.4, 70, 96));

        $('#aiText').textContent = z.moisture >= 70
            ? 'All zones look healthy. A short top-up keeps ' + z.name + ' in the optimal range.'
            : z.name + ' is the driest zone (' + Math.round(z.moisture) + '%). Irrigating now brings it back to the target band.';
        $('#aiDuration').textContent = mins + ' min';
        $('#aiWater').textContent = water + ' L';
        $('#aiSoilAfter').textContent = Math.round(after) + '%';
        $('#aiConfidence').textContent = conf + '%';
        $('#aiBar').style.width = conf + '%';

        state.rec = { zone: z.id, min: mins };
    }

    /* ===== LỊCH TƯỚI ===== */
    function nextOccurrence(schedule) {
        var p = schedule.time.split(':');
        var d = new Date();
        d.setHours(Number(p[0]), Number(p[1]), 0, 0);
        if (d.getTime() <= Date.now()) {
            if (schedule.frequency === 'once') { return null; }
            d.setDate(d.getDate() + 1);
        }
        if (schedule.frequency === 'weekdays') {
            while (d.getDay() === 0 || d.getDay() === 6) { d.setDate(d.getDate() + 1); }
        }
        return d;
    }

    function renderNext() {
        var el = $('#nextSchedule');
        var best = null;
        state.schedules.forEach(function (s) {
            if (!s.enabled) { return; }
            var d = nextOccurrence(s);
            if (!d) { return; }
            if (!best || d < best.d) { best = { d: d, s: s }; }
        });
        if (!best) { el.textContent = 'No active schedule'; return; }

        var mins = Math.round((best.d.getTime() - Date.now()) / 60000);
        var h = Math.floor(mins / 60), mm = mins % 60;
        el.textContent = 'Next at ' + best.s.time + ' · in ' + (h ? h + 'h ' : '') + mm + 'm';
    }

    function renderSchedules() {
        var list = $('#scheduleList');
        if (!canSchedule && $('.sched-form')) {
            $('.sched-form').hidden = true;
            $('.sched-form').style.display = 'none';
        }
        if (!state.schedules.length) {
            list.innerHTML = '<p class="empty">No schedules yet.</p>';
        } else {
            list.innerHTML = state.schedules.slice().sort(function (a, b) { return a.time < b.time ? -1 : 1; }).map(function (s) {
                var frequency = s.frequency === 'weekdays' ? 'Weekdays' : (s.frequency === 'once' ? 'One time' : 'Every day');
                var delBtn = canSchedule
                    ? '<button type="button" class="icon-link" data-del="' + esc(s.id) + '" aria-label="Delete schedule ' + s.time + '">' + icon('i-trash', 'icon-sm') + '</button>'
                    : '';
                return '<div class="schedule-item">' +
                    '<div class="sch-time">' + s.time + '</div>' +
                    '<div class="sch-meta"><strong>' + esc(window.IrrigationZones.name(s.zoneId)) + ' · ' + s.minutes + ' min</strong><span>' + frequency + '</span></div>' +
                    '<label class="switch"><input type="checkbox" data-id="' + esc(s.id) + '" ' + (s.enabled ? 'checked' : '') + (canSchedule ? '' : ' disabled') + ' aria-label="Enable schedule ' + s.time + '"><span class="slider"></span></label>' +
                    delBtn +
                    '</div>';
            }).join('');
        }
        renderNext();
    }

    function checkSchedules() {
        if (!canWater) { return; }
        var now = new Date();
        var hit = state.schedules.filter(function (s) {
            return s.enabled && s.time === hhmm(now) &&
                (s.frequency !== 'weekdays' || (now.getDay() !== 0 && now.getDay() !== 6));
        })[0];
        if (!hit) { return; }
        var key = now.toDateString() + ' ' + hit.id;
        if (key === state.lastSchedKey) { return; }
        state.lastSchedKey = key;

        if (state.pump.on) { toast('Scheduled run skipped: pump is busy', 'warn'); return; }
        startPump(hit.zoneId, hit.minutes, 'Scheduled run ' + hit.time);
        if (hit.frequency === 'once' && canSchedule) {
            state.schedules = state.schedules.filter(function (schedule) { return schedule.id !== hit.id; });
            persistSchedules();
            renderSchedules();
        }
    }

    function persistSchedules() {
        if (!canSchedule) { return; }
        state.schedules = window.IrrigationSchedules.save(state.schedules);
    }

    /* ===== HOẠT ĐỘNG GẦN ĐÂY ===== */
    function addActivity(type, title, text) {
        state.activity.unshift({ type: type, title: title, text: text, ts: Date.now() });
        state.activity = state.activity.slice(0, 8);
        renderActivity();
    }

    function renderActivity() {
        $('#activityList').innerHTML = state.activity.map(function (a) {
            var meta = ACT[a.type] || ACT.check;
            return '<div class="activity">' +
                '<div class="icon-box activity-icon ' + meta.tone + '">' + icon(meta.icon, 'icon-md') + '</div>' +
                '<div class="activity-body"><strong>' + esc(a.title) + '</strong><p>' + esc(a.text) + '</p></div>' +
                '<small>' + timeAgo(a.ts) + '</small>' +
                '</div>';
        }).join('');
    }

    /* ===== CẬP NHẬT CẢM BIẾN ===== */
    function setLast(key, v) {
        var a = state.series[key];
        a[a.length - 1] = { t: Date.now(), v: v };
    }

    function pushLive() {
        var now = Date.now();
        if (now - state.stamp >= STEP) {
            ['soil', 'temperature', 'humidity'].forEach(function (k) {
                state.series[k].push({ t: now, v: 0 });
                state.series[k].shift();
            });
            state.stamp = now;
        }
        setLast('soil', avgSoil());
        setLast('temperature', state.temp);
        setLast('humidity', state.hum);
    }

    function renderAll() {
        state.weekly[6].v = state.water;
        renderKpis();
        updateZones();
        renderAI();
        queueDraw();
    }

    function sensorTick() {
        fetch(ctx + '/api/sensors', {
            cache: 'no-store',
            headers: { 'X-Requested-With': 'fetch' }
        })
            .then(function (response) {
                if (!response.ok) { throw new Error('Telemetry request failed'); }
                return response.json();
            })
            .then(function (readings) {
                if (readings.length) {
                    state.zones = readings.map(function (reading) {
                        var id = String(reading.id || reading.potId);
                        var m = Number(reading.moisture !== undefined ? reading.moisture : reading.soilMoisture);
                        window.IrrigationZones.setSoilMoisture(id, m);
                        return {
                            id: id,
                            dbPotId: reading.potId || Number(id),
                            name: reading.name || reading.potName || ('Pot #' + id),
                            crop: reading.crop || reading.plantName || '',
                            moisture: m
                        };
                    });
                }
                pushLive();
                renderAll();
            })
            .catch(function () {
                pushLive();
                renderAll();
            });
    }

    /* ===== XUẤT CSV ===== */
    function exportCsv() {
        if (!canExport) {
            toast('Access denied: your role does not include report export permission.', 'warn');
            return;
        }
        var rows = ['time,soil_moisture_percent,temperature_c,humidity_percent'];
        for (var i = 0; i < state.series.soil.length; i++) {
            rows.push([
                new Date(state.series.soil[i].t).toISOString(),
                state.series.soil[i].v.toFixed(1),
                state.series.temperature[i].v.toFixed(1),
                state.series.humidity[i].v.toFixed(1)
            ].join(','));
        }
        var blob = new Blob([rows.join('\n')], { type: 'text/csv;charset=utf-8;' });
        var url = URL.createObjectURL(blob);
        var d = new Date();
        var a = document.createElement('a');
        a.href = url;
        a.download = 'telemetry-' + d.getFullYear() + pad(d.getMonth() + 1) + pad(d.getDate()) + '.csv';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
        toast('Telemetry exported (' + state.series.soil.length + ' rows)', 'good');
    }

    /* ===== GẮN SỰ KIỆN ===== */
    function bind() {
        if (!canExport && $('#exportBtn')) {
            $('#exportBtn').hidden = true;
            $('#exportBtn').style.display = 'none';
        }
        if (!canSchedule && $('#schedAdd')) {
            $('#schedAdd').disabled = true;
            $('#schedAdd').hidden = true;
            if ($('#schedTime')) { $('#schedTime').disabled = true; }
            if ($('#schedZone')) { $('#schedZone').disabled = true; }
            if ($('#schedMin')) { $('#schedMin').disabled = true; }
            if ($('#schedFrequency')) { $('#schedFrequency').disabled = true; }
        }

        // chế độ
        $('#modeToggle').addEventListener('click', function (e) {
            if (!canWater) { return; }
            var b = e.target.closest('.seg-btn');
            if (b && b.getAttribute('data-mode') !== state.mode) { setMode(b.getAttribute('data-mode')); }
        });

        // đổi chỉ số / khoảng thời gian của biểu đồ
        $('#metricTabs').addEventListener('click', function (e) {
            var b = e.target.closest('.tab');
            if (!b) { return; }
            state.metric = b.getAttribute('data-metric');
            $$('#metricTabs .tab').forEach(function (t) { t.classList.toggle('active', t === b); });
            hideHover();
            queueDraw();
        });
        $('#rangeTabs').addEventListener('click', function (e) {
            var b = e.target.closest('.tab');
            if (!b) { return; }
            state.rangeHours = Number(b.getAttribute('data-range'));
            $$('#rangeTabs .tab').forEach(function (t) { t.classList.toggle('active', t === b); });
            hideHover();
            queueDraw();
        });

        // tooltip biểu đồ
        var box = $('#telemetryChart');
        box.addEventListener('pointermove', function (e) {
            if (!chartGeo) { return; }
            var r = box.getBoundingClientRect();
            var idx = Math.round((e.clientX - r.left - chartGeo.m.l) / chartGeo.iw * (chartGeo.count - 1));
            showHover(idx);
        });
        box.addEventListener('pointerleave', hideHover);

        // thời lượng tưới
        $('#durationChips').addEventListener('click', function (e) {
            if (!canWater) { return; }
            var c = e.target.closest('.chip');
            if (!c || state.pump.on) { return; }
            state.pump.minutes = Number(c.getAttribute('data-min'));
            save('duration', state.pump.minutes);
            renderPump();
        });

        // ngưỡng tự động
        $('#thresholdRange').addEventListener('input', function () {
            if (!canWater) { return; }
            state.threshold = Number(this.value);
            save('threshold', state.threshold);
            $('#thresholdValue').textContent = state.threshold + '%';
        });

        // nút bơm
        $('#pumpButton').addEventListener('click', function () {
            if (!canWater) { return; }
            if (state.pump.on) {
                stopPump(false);
            } else {
                startPump($('#zoneSelect').value, state.pump.minutes, state.mode === 'auto' ? 'Manual override' : 'Manual start');
            }
        });

        // tưới theo vùng
        $('#zoneList').addEventListener('click', function (e) {
            if (!canWater) { return; }
            var b = e.target.closest('.zone-water');
            if (b && !state.pump.on) { startPump(b.getAttribute('data-zone'), state.pump.minutes, 'Zone quick-water'); }
        });

        // gợi ý AI
        $('#aiApply').addEventListener('click', function () {
            if (!canWater) { return; }
            if (state.pump.on) { toast('Stop the pump before applying a recommendation', 'warn'); return; }
            if (!state.rec) { return; }
            $('#zoneSelect').value = state.rec.zone;
            state.pump.zone = state.rec.zone;
            state.pump.minutes = state.rec.min;
            save('duration', state.rec.min);
            renderPump();
            toast('Applied: ' + zoneById(state.rec.zone).name + ' · ' + state.rec.min + ' min. Press Start Pump to run.', 'good');
        });

        // lịch tưới
        $('#scheduleList').addEventListener('change', function (e) {
            if (!canSchedule) {
                e.target.checked = !e.target.checked;
                toast('Access denied: only Admin and Manager can modify schedules.', 'warn');
                return;
            }
            var id = e.target.getAttribute('data-id');
            state.schedules.forEach(function (s) { if (s.id === id) { s.enabled = e.target.checked; } });
            persistSchedules();
            renderSchedules();
        });
        $('#scheduleList').addEventListener('click', function (e) {
            if (!canSchedule) { return; }
            var b = e.target.closest('[data-del]');
            if (!b) { return; }
            var id = b.getAttribute('data-del');
            state.schedules = state.schedules.filter(function (s) { return s.id !== id; });
            persistSchedules();
            renderSchedules();
        });
        $('#schedAdd').addEventListener('click', function () {
            if (!canSchedule) {
                toast('Access denied: only Admin and Manager can add schedules.', 'warn');
                return;
            }
            var t = $('#schedTime').value;
            if (!t) { toast('Please choose a start time', 'warn'); return; }
            var zoneId = $('#schedZone').value;
            var dup = state.schedules.some(function (s) { return s.time === t && s.zoneId === zoneId; });
            if (dup) { toast('A schedule for this garden at that time already exists', 'warn'); return; }
            state.schedules.push({
                id: 'plan-' + Date.now(),
                zoneId: zoneId,
                time: t,
                minutes: Number($('#schedMin').value),
                frequency: $('#schedFrequency').value,
                enabled: true
            });
            persistSchedules();
            renderSchedules();
            toast('Schedule added: ' + t, 'good');
        });

        // xuất CSV
        $('#exportBtn').addEventListener('click', exportCsv);

        // vẽ lại biểu đồ khi đổi kích thước
        if (window.ResizeObserver) {
            var ro = new ResizeObserver(queueDraw);
            ro.observe($('#telemetryChart'));
            ro.observe($('#weeklyChart'));
        } else {
            window.addEventListener('resize', queueDraw);
        }
    }

    /* ===== KHỞI TẠO ===== */
    function init() {
        state.events = [
            { ts: lastAt(8),  liters: 15, min: 8 },
            { ts: lastAt(16), liters: 20, min: 10 }
        ];
        state.series = buildSeries();
        state.weekly = buildWeekly();

        var now = Date.now();
        state.activity = [
            { type: 'water',  title: 'Irrigation completed',  text: '20 liters of water used',      ts: now - 10 * 60000 },
            { type: 'sensor', title: 'Soil moisture updated', text: 'Moisture level: 74%',          ts: now - 25 * 60000 },
            { type: 'check',  title: 'System check',          text: 'All sensors are working',      ts: now - 60 * 60000 }
        ];

        buildZones();
        $('#schedZone').innerHTML = window.IrrigationZones.list.map(function (zone) {
            return '<option value="' + zone.id + '">' + esc(zone.name + ' · ' + zone.crop) + '</option>';
        }).join('');
        bind();
        window.IrrigationSchedules.onChange(function (schedules) {
            state.schedules = schedules;
            renderSchedules();
        });

        $('#thresholdRange').value = state.threshold;
        $('#thresholdValue').textContent = state.threshold + '%';
        $('#zoneSelect').value = state.pump.zone;

        $$('#metricTabs .tab').forEach(function (t) { t.classList.toggle('active', t.getAttribute('data-metric') === state.metric); });
        $$('#rangeTabs .tab').forEach(function (t) { t.classList.toggle('active', Number(t.getAttribute('data-range')) === state.rangeHours); });

        setMode(state.mode, true);
        renderSchedules();
        renderActivity();
        renderPump();
        pushLive();
        renderAll();

        setInterval(sensorTick, CONFIG.TICK_MS);
        setInterval(checkSchedules, 10000);
        setInterval(function () { renderActivity(); renderNext(); }, 30000);
    }

    init();
})();