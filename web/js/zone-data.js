(function (global) {
    var defaultZones = [
        { id: "1", potId: 1, dbPotId: 1, name: "Garden A", crop: "Tomato", nodeId: 1, soilMoisture: 82 },
        { id: "2", potId: 2, dbPotId: 2, name: "Garden B", crop: "Basil", nodeId: 2, soilMoisture: 76 },
        { id: "3", potId: 3, dbPotId: 3, name: "Garden C", crop: "Lettuce", nodeId: 3, soilMoisture: 72 },
        { id: "4", potId: 4, dbPotId: 4, name: "Garden D", crop: "Pepper", nodeId: 4, soilMoisture: 66 }
    ];

    var serverZones = global.SI_DATA && Array.isArray(global.SI_DATA.zones) && global.SI_DATA.zones.length
        ? global.SI_DATA.zones.map(function (z) {
            return {
                id: String(z.id !== undefined ? z.id : z.potId),
                potId: Number(z.potId || z.id || z.nodeId || 1),
                dbPotId: Number(z.potId || z.id || z.nodeId || 1),
                name: z.name || z.potName || ("Garden " + z.potId),
                crop: z.crop || z.plantName || "Plant",
                location: z.location || "",
                nodeId: Number(z.nodeId || z.potId || z.id || 1),
                soilMoisture: Number.isFinite(Number(z.soilMoisture)) ? Number(z.soilMoisture) : 65,
                targetMin: Number.isFinite(Number(z.targetMin)) ? Number(z.targetMin) : 60,
                targetMax: Number.isFinite(Number(z.targetMax)) ? Number(z.targetMax) : 80
            };
        })
        : defaultZones;

    var zones = serverZones;

    function get(id) {
        if (id === null || id === undefined) return null;
        var key = String(id);
        return zones.filter(function (zone) {
            return String(zone.id) === key || String(zone.potId) === key;
        })[0] || null;
    }

    function name(id) {
        var zone = get(id);
        return zone ? zone.name : "Garden #" + id;
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

    function averageSoil() {
        if (!zones.length) return 0;
        var total = zones.reduce(function (sum, zone) { return sum + getSoilMoisture(zone.id); }, 0);
        return total / zones.length;
    }

    global.IrrigationZones = {
        list: zones,
        get: get,
        name: name,
        nodeLabel: nodeLabel,
        getSoilMoisture: getSoilMoisture,
        setSoilMoisture: setSoilMoisture,
        averageSoil: averageSoil
    };
}(window));