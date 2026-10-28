(function (global) {
    var defaultAreas = [
        { id: 1, areaId: 1, name: "Khu A - Ban công Tầng 2", areaName: "Khu A - Ban công Tầng 2", description: "Khu vực đón nắng sáng trực tiếp, thoáng gió" },
        { id: 2, areaId: 2, name: "Khu B - Sân thượng Tầng 3", areaName: "Khu B - Sân thượng Tầng 3", description: "Khu vực nắng toàn phần, trồng hoa và cây cảnh" },
        { id: 3, areaId: 3, name: "Khu C - Hiên nhà & Nội thất", areaName: "Khu C - Hiên nhà & Nội thất", description: "Khu vực bán râm, hiên nhà và cửa sổ văn phòng" }
    ];

    var defaultZones = [
        { id: "1", potId: 1, dbPotId: 1, name: "Chậu Ban Công 1", potName: "Chậu Ban Công 1", areaId: 1, areaName: "Khu A - Ban công Tầng 2", location: "Khu A - Ban công Tầng 2", plantId: 1, crop: "Cây Nha Đam", plantName: "Cây Nha Đam", category: "Aloe vera", waterAmountMl: 200, nodeId: 1, soilMoisture: 42, targetMin: 30, targetMax: 60 },
        { id: "2", potId: 2, dbPotId: 2, name: "Chậu Sân Thượng", potName: "Chậu Sân Thượng", areaId: 2, areaName: "Khu B - Sân thượng Tầng 3", location: "Khu B - Sân thượng Tầng 3", plantId: 2, crop: "Cúc Họa Mi", plantName: "Cúc Họa Mi", category: "Chrysanthemum", waterAmountMl: 300, nodeId: 2, soilMoisture: 52, targetMin: 45, targetMax: 75 },
        { id: "3", potId: 3, dbPotId: 3, name: "Giàn Lan Hiên Nhà", potName: "Giàn Lan Hiên Nhà", areaId: 3, areaName: "Khu C - Hiên nhà & Nội thất", location: "Khu C - Hiên nhà & Nội thất", plantId: 3, crop: "Lan Hồ Điệp", plantName: "Lan Hồ Điệp", category: "Phalaenopsis", waterAmountMl: 250, nodeId: 3, soilMoisture: 27, targetMin: 50, targetMax: 70 },
        { id: "4", potId: 4, dbPotId: 4, name: "Chậu Trầu Bà Cửa Sổ", potName: "Chậu Trầu Bà Cửa Sổ", areaId: 3, areaName: "Khu C - Hiên nhà & Nội thất", location: "Khu C - Hiên nhà & Nội thất", plantId: 4, crop: "Trầu Bà Vàng", plantName: "Trầu Bà Vàng", category: "Epipremnum aureum", waterAmountMl: 350, nodeId: 4, soilMoisture: 62, targetMin: 55, targetMax: 80 }
    ];

    var areas = global.SI_DATA && Array.isArray(global.SI_DATA.areas) && global.SI_DATA.areas.length
        ? global.SI_DATA.areas.map(function (a) {
            return {
                id: Number(a.areaId || a.id || 1),
                areaId: Number(a.areaId || a.id || 1),
                name: a.areaName || a.name || ("Khu vực #" + (a.areaId || a.id || 1)),
                areaName: a.areaName || a.name || ("Khu vực #" + (a.areaId || a.id || 1)),
                description: a.description || ""
            };
        })
        : defaultAreas;

    function mapZone(z) {
        var potId = Number(z.potId || z.id || z.nodeId || 1);
        var areaId = Number(z.areaId || (potId === 1 ? 1 : (potId === 2 ? 2 : 3)));
        var areaName = z.areaName || z.location || "Khu A - Ban công Tầng 2";
        var potName = z.name || z.potName || z.garden || ("Chậu #" + potId);
        var plantName = z.crop || z.plantName || z.name || "Cây trồng";
        var min = Number.isFinite(Number(z.targetMin)) ? Number(z.targetMin)
            : (Number.isFinite(Number(z.minMoistureThreshold)) ? Number(z.minMoistureThreshold) : 35);
        var max = Number.isFinite(Number(z.targetMax)) ? Number(z.targetMax)
            : (Number.isFinite(Number(z.maxMoistureThreshold)) ? Number(z.maxMoistureThreshold) : 75);
        return {
            id: String(z.id !== undefined ? z.id : potId),
            potId: potId,
            dbPotId: potId,
            name: potName,
            potName: potName,
            areaId: areaId,
            areaName: areaName,
            location: areaName,
            plantId: Number(z.plantId || potId),
            crop: plantName,
            plantName: plantName,
            category: z.category || "Vegetable",
            waterRequirement: z.waterRequirement || ((z.waterAmountMl || 250) + " ml/lần"),
            waterAmountMl: Number(z.waterAmountMl || 250),
            nodeId: Number(z.nodeId || potId),
            hardwareBound: Boolean(z.hardwareBound !== undefined ? z.hardwareBound : (potId === 1)),
            soilMoisture: Number.isFinite(Number(z.soilMoisture !== undefined ? z.soilMoisture : z.moisture))
                ? Number(z.soilMoisture !== undefined ? z.soilMoisture : z.moisture)
                : 65,
            targetMin: min,
            targetMax: max
        };
    }

    var zones = global.SI_DATA && Array.isArray(global.SI_DATA.zones) && global.SI_DATA.zones.length
        ? global.SI_DATA.zones.map(mapZone)
        : defaultZones;

    function get(id) {
        if (id === null || id === undefined) return null;
        var key = String(id);
        return zones.filter(function (zone) {
            return String(zone.id) === key || String(zone.potId) === key;
        })[0] || null;
    }

    function name(id) {
        var zone = get(id);
        return zone ? zone.name : "Chậu #" + id;
    }

    function areaName(id) {
        var zone = get(id);
        return zone ? (zone.areaName || zone.location || "Khu A") : "Khu A";
    }

    function hierarchyLabel(id) {
        var zone = get(id);
        if (!zone) return "Chậu #" + id;
        return (zone.areaName ? zone.areaName + " · " : "") + zone.name + " · " + zone.crop;
    }

    function nodeLabel(id) {
        var zone = get(id);
        var num = zone ? zone.nodeId : Number(id) || 1;
        return "NODE-" + String(num).padStart(2, "0");
    }

    function getSoilMoisture(id) {
        var zone = get(id);
        return zone ? Number(zone.soilMoisture) || 0 : 0;
    }

    function setSoilMoisture(id, value) {
        var zone = get(id);
        if (!zone) return 0;
        var moisture = Math.max(0, Math.min(100, Number(value) || 0));
        zone.soilMoisture = moisture;
        return moisture;
    }

    function getThresholds(id) {
        var zone = get(id);
        return {
            min: zone && Number.isFinite(Number(zone.targetMin)) ? Number(zone.targetMin) : 35,
            max: zone && Number.isFinite(Number(zone.targetMax)) ? Number(zone.targetMax) : 75
        };
    }

    function setThresholds(id, min, max) {
        var zone = get(id);
        if (!zone) return;
        if (Number.isFinite(Number(min))) zone.targetMin = Number(min);
        if (Number.isFinite(Number(max))) zone.targetMax = Number(max);
    }

    function syncFromReadings(readings) {
        if (!Array.isArray(readings) || !readings.length) return;
        readings.forEach(function (r) {
            var id = String(r.id !== undefined ? r.id : r.potId);
            var existing = get(id);
            if (existing) {
                var m = Number(r.moisture !== undefined ? r.moisture : r.soilMoisture);
                if (Number.isFinite(m)) existing.soilMoisture = Math.max(0, Math.min(100, m));
                if (r.name || r.potName) {
                    existing.name = r.name || r.potName;
                    existing.potName = existing.name;
                }
                if (r.areaId) existing.areaId = Number(r.areaId);
                if (r.areaName || r.location) {
                    existing.areaName = r.areaName || r.location;
                    existing.location = existing.areaName;
                }
                if (r.crop || r.plantName) {
                    existing.crop = r.crop || r.plantName;
                    existing.plantName = existing.crop;
                }
                if (r.plantId) existing.plantId = Number(r.plantId);
                if (Number.isFinite(Number(r.targetMin))) existing.targetMin = Number(r.targetMin);
                if (Number.isFinite(Number(r.targetMax))) existing.targetMax = Number(r.targetMax);
                if (Number.isFinite(Number(r.waterAmountMl))) existing.waterAmountMl = Number(r.waterAmountMl);
                if (r.hardwareBound !== undefined) existing.hardwareBound = Boolean(r.hardwareBound);
            } else {
                zones.push(mapZone(r));
            }
        });
    }

    function getActiveHardwareZone() {
        return zones.filter(function (z) { return z.hardwareBound; })[0] || zones[0] || null;
    }

    function bindHardware(potId) {
        var targetKey = String(potId);
        zones.forEach(function (z) {
            z.hardwareBound = (String(z.id) === targetKey || String(z.potId) === targetKey);
        });
        var ctx = global.SI_CTX || "";
        return fetch(ctx + "/api/watering/command", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded",
                "X-Requested-With": "fetch"
            },
            body: "action=bindHardware&command=BIND&potId=" + encodeURIComponent(potId)
        }).then(function (res) {
            return res.ok ? res.json() : null;
        }).catch(function () {
            return null;
        });
    }

    function averageSoil() {
        if (!zones.length) return 0;
        var total = zones.reduce(function (sum, zone) { return sum + getSoilMoisture(zone.id); }, 0);
        return total / zones.length;
    }

    global.IrrigationZones = {
        areas: areas,
        list: zones,
        get: get,
        name: name,
        areaName: areaName,
        hierarchyLabel: hierarchyLabel,
        nodeLabel: nodeLabel,
        getSoilMoisture: getSoilMoisture,
        setSoilMoisture: setSoilMoisture,
        getThresholds: getThresholds,
        setThresholds: setThresholds,
        syncFromReadings: syncFromReadings,
        getActiveHardwareZone: getActiveHardwareZone,
        bindHardware: bindHardware,
        averageSoil: averageSoil
    };
}(window));
