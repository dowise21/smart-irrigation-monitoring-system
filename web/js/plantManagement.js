/* =====================================================================
   Trang Plants & Pots (Đồng bộ hệ cấp Area -> Pot -> Plant & Ngưỡng tưới)
   ===================================================================== */

/* ---------- 1. CẤU HÌNH ---------- */
var ctx = window.SI_CTX || '';
var CONFIG = {
    useSampleData: false,
    apiUrl: ctx + '/api/plants',
    refreshMs: 5000
};

var canManagePlants = !window.SI_ACCESS || !Array.isArray(window.SI_ACCESS.write) || window.SI_ACCESS.write.indexOf('/plants') !== -1;
var canWaterPlants = !window.SI_ACCESS || !Array.isArray(window.SI_ACCESS.write) || window.SI_ACCESS.write.indexOf('/manual-water') !== -1;

function hoursAgo(h) { return new Date(Date.now() - h * 3600 * 1000).toISOString(); }
var zoneRegistry = window.IrrigationZones;
var firstZoneId = (zoneRegistry.list[0] && zoneRegistry.list[0].id) || '1';

var samplePlants = (window.SI_DATA && Array.isArray(window.SI_DATA.plants)) ? window.SI_DATA.plants : [
    { id: 1, name: 'Cây Nha Đam', category: 'Aloe vera', areaId: 1, areaName: 'Khu A - Ban công Tầng 2', garden: zoneRegistry.name(firstZoneId), zoneId: firstZoneId, nodeId: 1, soilMoisture: zoneRegistry.getSoilMoisture(firstZoneId), temperature: 27.4,
      targetMin: 30, targetMax: 60, waterAmountMl: 200, lastWateredAt: hoursAgo(2), emoji: '🪴' }
];


/* ---------- 2. CHỖ NỐI DATABASE ---------- */

function loadPlants() {
    if (CONFIG.useSampleData) {
        return Promise.resolve(samplePlants);
    }
    return fetch(CONFIG.apiUrl, {
        cache: 'no-store',
        headers: { 'X-Requested-With': 'fetch' }
    }).then(function (res) {
        if (!res.ok) throw new Error('Cannot load plants');
        return res.json();
    }).then(function (plants) {
        if (Array.isArray(plants) && zoneRegistry.syncFromReadings) {
            zoneRegistry.syncFromReadings(plants.map(function (p) {
                return {
                    id: String(p.zoneId || p.potId || p.nodeId || 1),
                    potId: Number(p.potId || p.zoneId || p.nodeId || 1),
                    name: p.garden || p.potName,
                    potName: p.garden || p.potName,
                    areaId: p.areaId,
                    areaName: p.areaName,
                    plantId: p.plantId || p.id,
                    crop: p.name,
                    plantName: p.name,
                    category: p.category,
                    hardwareBound: p.hardwareBound,
                    soilMoisture: p.soilMoisture,
                    targetMin: p.targetMin,
                    targetMax: p.targetMax,
                    waterAmountMl: p.waterAmountMl
                };
            }));
        }
        return plants;
    });
}

function bindHardwareToPot(potId) {
    if (zoneRegistry.bindHardware) {
        zoneRegistry.bindHardware(potId);
    }
    return fetch(CONFIG.apiUrl, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Requested-With': 'fetch'
        },
        body: 'action=bindHardware&potId=' + encodeURIComponent(potId)
    }).then(function (res) {
        if (!res.ok) throw new Error('Bind failed');
        return res.json();
    });
}

function waterPlant(id) {
    if (CONFIG.useSampleData) {
        var p = findPlant(id);
        if (p) {
            p.lastWateredAt = new Date().toISOString();
            saveSamplePlants();
        }
        return Promise.resolve();
    }
    return fetch(CONFIG.apiUrl, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Requested-With': 'fetch'
        },
        body: 'action=water&id=' + encodeURIComponent(id)
    }).then(function (res) { if (!res.ok) throw new Error('Water failed'); });
}

function deletePlant(id) {
    if (CONFIG.useSampleData) {
        samplePlants = samplePlants.filter(function (p) { return p.id !== id; });
        saveSamplePlants();
        return Promise.resolve();
    }
    return fetch(CONFIG.apiUrl, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Requested-With': 'fetch'
        },
        body: 'action=delete&id=' + encodeURIComponent(id)
    }).then(function (res) { if (!res.ok) throw new Error('Delete failed'); });
}

function saveSamplePlants() {
    try {
        localStorage.setItem('si.plants.v1', JSON.stringify(samplePlants));
    } catch (error) {
        showToast('Plant changes could not be saved in this browser.');
    }
}

function addPlant(plant) {
    if (CONFIG.useSampleData) {
        samplePlants.push(plant);
        saveSamplePlants();
        return Promise.resolve();
    }
    return fetch(CONFIG.apiUrl, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Requested-With': 'fetch'
        },
        body: new URLSearchParams(Object.assign({ action: 'add' }, plant))
    }).then(function (res) {
        if (!res.ok) throw new Error('Plant could not be added');
        return res.json();
    });
}

function updatePlant(plant) {
    if (CONFIG.useSampleData) {
        var index = samplePlants.findIndex(function (item) { return String(item.id) === String(plant.id); });
        if (index === -1) return Promise.reject(new Error('Plant not found'));
        samplePlants[index] = plant;
        saveSamplePlants();
        return Promise.resolve();
    }
    return fetch(CONFIG.apiUrl, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Requested-With': 'fetch'
        },
        body: new URLSearchParams(Object.assign({ action: 'update' }, plant))
    }).then(function (res) {
        if (!res.ok) throw new Error('Plant could not be updated');
        return res.json();
    });
}


/* ---------- 3. HÀM PHỤ ---------- */
var allPlants = [];
var currentFilter = 'all';

var grid = document.getElementById('plantGrid');
var filtersBox = document.getElementById('plantFilters');
var searchInput = document.getElementById('plantSearch');
var toast = document.getElementById('toast');
var toastTimer;
var requestedZone = new URLSearchParams(window.location.search).get('zone');
if (zoneRegistry.get(requestedZone)) searchInput.value = zoneRegistry.name(requestedZone);

function findPlant(id) {
    return allPlants.concat(samplePlants).filter(function (p) { return Number(p.id) === Number(id); })[0];
}

function showToast(message) {
    toast.textContent = message;
    toast.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { toast.classList.remove('show'); }, 2600);
}

function setText(root, field, value) {
    var el = root.querySelector('[data-field="' + field + '"]');
    if (el) el.textContent = value;
}

function pad2(n) { return (n < 10 ? '0' : '') + n; }

function getStatus(p) {
    if (p.soilMoisture === null || p.soilMoisture === undefined) return 'nodata';
    var min = Number.isFinite(Number(p.targetMin)) ? Number(p.targetMin) : 35;
    var max = Number.isFinite(Number(p.targetMax)) ? Number(p.targetMax) : 75;
    if (p.soilMoisture < min) return 'low';
    if (p.soilMoisture > max) return 'high';
    return 'ok';
}

var STATUS_INFO = {
    ok:     { label: 'Healthy',     badge: 'success', card: '',           tone: 'tone-green' },
    low:    { label: 'Needs water', badge: 'warning', card: 'is-warning', tone: 'tone-amber' },
    high:   { label: 'Too wet',     badge: 'info',    card: 'is-wet',     tone: 'tone-blue'  },
    nodata: { label: 'No data',     badge: 'muted',   card: '',           tone: 'tone-green' }
};

function timeAgo(dateString) {
    if (!dateString) return 'Never';
    var t = new Date(dateString);
    var minutes = Math.floor((Date.now() - t.getTime()) / 60000);
    if (minutes < 1) return 'Just now';
    if (minutes < 60) return minutes + 'm ago';
    if (minutes < 24 * 60) return Math.floor(minutes / 60) + 'h ago';
    var time = pad2(t.getHours()) + ':' + pad2(t.getMinutes());
    if (minutes < 48 * 60) return 'Yesterday ' + time;
    return pad2(t.getDate()) + '/' + pad2(t.getMonth() + 1) + ' ' + time;
}

function getEmoji(p) {
    if (p.emoji) return p.emoji;
    var cat = String(p.category || '').toLowerCase();
    var name = String(p.name || '').toLowerCase();
    if (cat.indexOf('aloe') !== -1 || cat.indexOf('succulent') !== -1 || name.indexOf('nha đam') !== -1 || name.indexOf('xương rồng') !== -1) return '🌵';
    if (cat.indexOf('chrysanthemum') !== -1 || cat.indexOf('flower') !== -1 || name.indexOf('cúc') !== -1) return '🌼';
    if (cat.indexOf('phalaenopsis') !== -1 || cat.indexOf('orchid') !== -1 || name.indexOf('lan') !== -1) return '🌸';
    if (cat.indexOf('epipremnum') !== -1 || cat.indexOf('herb') !== -1 || name.indexOf('trầu bà') !== -1) return '🌿';
    var byCategory = { vegetable: '🥬', flower: '🌸', fruit: '🍓', herb: '🌿' };
    return byCategory[cat] || '🌱';
}


/* ---------- 4. VẼ GIAO DIỆN ---------- */

function renderStats(plants) {
    var healthy = 0, needWater = 0, waterMl = 0;
    plants.forEach(function (p) {
        var status = getStatus(p);
        if (status === 'ok') healthy++;
        if (status === 'low') { needWater++; waterMl += Number(p.waterAmountMl) || 0; }
    });
    document.getElementById('statTotal').textContent = plants.length;
    document.getElementById('statHealthy').textContent = healthy;
    document.getElementById('statNeedWater').textContent = needWater;
    document.getElementById('statWaterMl').textContent = waterMl.toLocaleString('en-US');
    return needWater;
}

function renderFilters(plants, needWater) {
    var counts = {};
    plants.forEach(function (p) {
        var key = String(p.category).toLowerCase();
        counts[key] = (counts[key] || 0) + 1;
    });

    if (currentFilter !== 'all' && currentFilter !== 'attention' && !counts[currentFilter]) {
        currentFilter = 'all';
    }

    var html = chip('all', 'All', plants.length, '');
    Object.keys(counts).forEach(function (key) {
        var label = key.charAt(0).toUpperCase() + key.slice(1);
        html += chip(key, label, counts[key], '');
    });
    html += chip('attention', '<i class="dot"></i>Attention needed', needWater, 'chip-warn');
    filtersBox.innerHTML = html;
}

function chip(filter, label, count, extraClass) {
    var active = (filter === currentFilter) ? ' active' : '';
    return '<button class="chip ' + extraClass + active + '" data-filter="' + filter + '" type="button">' +
           label + ' <b>' + count + '</b></button>';
}

function createCard(p) {
    var template = document.getElementById('plantCardTemplate');
    var card = template.content.firstElementChild.cloneNode(true);
    var status = getStatus(p);
    var info = STATUS_INFO[status];
    var hasMoisture = status !== 'nodata';
    var areaName = p.areaName || zoneRegistry.areaName(p.zoneId) || 'Khu A - Ban công Tầng 2';
    var potName = p.garden || p.potName || zoneRegistry.name(p.zoneId);
    var nodeNum = p.nodeId || p.potId || p.zoneId || 1;
    var minT = Number.isFinite(Number(p.targetMin)) ? Number(p.targetMin) : 35;
    var maxT = Number.isFinite(Number(p.targetMax)) ? Number(p.targetMax) : 75;
    var waterReq = p.waterRequirement || ((p.waterAmountMl || 250) + ' ml/lần');

    card.dataset.id = p.id;
    card.dataset.category = String(p.category).toLowerCase();
    card.dataset.status = status;
    card.dataset.search = (areaName + ' ' + potName + ' ' + p.name + ' ' + p.category + ' node ' + pad2(nodeNum)).toLowerCase();
    if (info.card) card.classList.add(info.card);

    // Hiển thị rõ hệ cấp 3 tầng: [Area] · [Pot] · Node #01
    setText(card, 'location', areaName + ' · ' + potName + ' · Node #' + pad2(nodeNum));
    setText(card, 'name', p.name);
    setText(card, 'category', p.category + ' · ' + waterReq);
    setText(card, 'emoji', getEmoji(p));
    setText(card, 'moisture', hasMoisture ? Math.round(p.soilMoisture) : '--');
    setText(card, 'moistureUnit', hasMoisture ? '%' : '');
    setText(card, 'temperature', (p.temperature === null || p.temperature === undefined) ? '--' : Number(p.temperature).toFixed(1) + '°C');
    setText(card, 'lastWatered', timeAgo(p.lastWateredAt));
    card.querySelector('[data-field="sensorLink"]').href = ctx + '/sensor-data?zone=' + encodeURIComponent(p.zoneId);

    var badge = card.querySelector('[data-field="statusLabel"]');
    badge.textContent = info.label;
    badge.classList.add(info.badge);

    card.querySelector('[data-field="emoji"]').classList.add(info.tone);

    var fill = card.querySelector('[data-field="moistureBar"]');
    var target = card.querySelector('[data-field="targetBar"]');
    fill.style.width = hasMoisture ? Math.max(0, Math.min(100, p.soilMoisture)) + '%' : '0%';
    target.style.left = minT + '%';
    target.style.width = Math.max(2, maxT - minT) + '%';

    var note = 'Target range ' + Math.round(minT) + '–' + Math.round(maxT) + '%';
    if (status === 'low')  note += ' · ' + Math.round(minT - p.soilMoisture) + '% below min (' + Math.round(minT) + '%)';
    if (status === 'high') note += ' · ' + Math.round(p.soilMoisture - maxT) + '% above max (' + Math.round(maxT) + '%)';
    setText(card, 'note', note);

    var waterBtn = card.querySelector('[data-action="water"]');
    setText(card, 'waterLabel', canWaterPlants
        ? ((status === 'low' ? 'Water now' : 'Water') + ' (' + p.waterAmountMl + 'ml)')
        : 'Watering restricted');
    if (status === 'low' && canWaterPlants) waterBtn.classList.add('urgent');
    if (!canWaterPlants) {
        waterBtn.disabled = true;
        waterBtn.title = 'Only Admin and Staff accounts can execute manual watering.';
    }

    var bindHwBtn = card.querySelector('[data-action="bind-hw"]');
    if (bindHwBtn) {
        bindHwBtn.dataset.potId = p.potId || p.zoneId || nodeNum;
        bindHwBtn.dataset.potName = potName;
        setText(card, 'bindHwLabel', p.hardwareBound ? '🔌 Đang gắn Bơm' : '🔌 Gán Bơm');
        if (p.hardwareBound) {
            bindHwBtn.style.background = '#d1fae5';
            bindHwBtn.style.color = '#065f46';
            bindHwBtn.style.borderColor = '#10b981';
            bindHwBtn.style.fontWeight = '700';
        }
    }

    card.querySelectorAll('[data-action]').forEach(function (btn) {
        btn.dataset.id = p.id;
        btn.dataset.name = p.name;
        if (!canManagePlants && (btn.dataset.action === 'edit' || btn.dataset.action === 'delete')) {
            btn.hidden = true;
            btn.style.display = 'none';
        }
    });

    return card;
}

function renderAll() {
    var needWater = renderStats(allPlants);
    renderFilters(allPlants, needWater);

    grid.innerHTML = '';
    allPlants.forEach(function (p) { grid.appendChild(createCard(p)); });

    document.getElementById('emptyAll').hidden = allPlants.length > 0;
    document.getElementById('syncText').textContent = 'Auto-sync: ' + new Date().toLocaleTimeString('en-GB');
    applyFilter();
}

function applyFilter() {
    var keyword = searchInput.value.trim().toLowerCase();
    var cards = grid.querySelectorAll('.plant-card');
    var shown = 0;

    cards.forEach(function (card) {
        var okFilter =
            currentFilter === 'all' ? true :
            currentFilter === 'attention' ? card.dataset.status === 'low' :
            card.dataset.category === currentFilter;
        var okSearch = keyword === '' || card.dataset.search.indexOf(keyword) !== -1;

        card.hidden = !(okFilter && okSearch);
        if (!card.hidden) shown++;
    });

    document.getElementById('emptyState').hidden = !(cards.length > 0 && shown === 0);

    filtersBox.querySelectorAll('.chip').forEach(function (c) {
        c.classList.toggle('active', c.dataset.filter === currentFilter);
    });
}


/* ---------- 5. TẢI DỮ LIỆU ---------- */
function reload() {
    return loadPlants()
        .then(function (plants) {
            allPlants = plants;
            populateAreaAndZoneSelects();
            renderAll();
        })
        .catch(function () { showToast('Cannot load plants. Please try again.'); });
}


/* ---------- 6. SỰ KIỆN ---------- */

filtersBox.addEventListener('click', function (event) {
    var btn = event.target.closest('.chip');
    if (!btn) return;
    currentFilter = btn.dataset.filter;
    applyFilter();
});

searchInput.addEventListener('input', applyFilter);

grid.addEventListener('click', function (event) {
    var btn = event.target.closest('[data-action]');
    if (!btn) return;
    var id = Number(btn.dataset.id);
    var name = btn.dataset.name;

    if (btn.dataset.action === 'bind-hw') {
        var potId = Number(btn.dataset.potId || id);
        var potName = btn.dataset.potName || ('Chậu #' + potId);
        btn.disabled = true;
        bindHardwareToPot(potId)
            .then(function () {
                showToast('🔌 Đã gán Mạch ESP8266 & Máy bơm vật lý vào: ' + potName + ' (' + name + ')');
            })
            .catch(function () {
                showToast('Không thể gán máy bơm vào ' + potName);
            })
            .then(reload);
        return;
    }

    if (btn.dataset.action === 'water') {
        if (!canWaterPlants) {
            showToast('Access denied: only Admin and Staff can water plants.');
            return;
        }
        btn.disabled = true;
        waterPlant(id)
            .then(function () { showToast('Started watering ' + name); })
            .catch(function () { showToast('Could not water ' + name); })
            .then(reload);
    }

    if (btn.dataset.action === 'delete') {
        if (!canManagePlants) {
            showToast('Access denied: only Admin and Manager can delete plants.');
            return;
        }
        if (!confirm('Delete ' + name + '?')) return;
        deletePlant(id)
            .then(function () { showToast(name + ' deleted'); })
            .catch(function () { showToast('Could not delete ' + name); })
            .then(reload);
    }

    if (btn.dataset.action === 'edit') {
        if (!canManagePlants) {
            showToast('Access denied: only Admin and Manager can edit plants.');
            return;
        }
        var plant = findPlant(id);
        if (plant) openPlantModal(plant);
    }
});

var plantModal = document.getElementById('plantModal');
var plantForm = document.getElementById('plantForm');
var plantFormError = document.getElementById('plantFormError');
var areaSelect = document.getElementById('newPlantArea');
var zoneSelect = document.getElementById('newPlantZone');
var newPotNameField = document.getElementById('newPotNameField');
var newPotNameInput = document.getElementById('newPotNameInput');
var categorySelect = document.getElementById('newPlantCategory');
var customCategoryField = document.getElementById('customCategoryField');
var customCategoryInput = document.getElementById('newPlantCustomCategory');
var targetMinInput = document.getElementById('newPlantTargetMin');
var targetMaxInput = document.getElementById('newPlantTargetMax');
var editingPlantId = null;
var builtInCategories = ['Aloe vera', 'Chrysanthemum', 'Phalaenopsis', 'Epipremnum aureum', 'Vegetable', 'Herb', 'Flower', 'Fruit'];
var customCategories = [];

try {
    var storedCategories = JSON.parse(localStorage.getItem('si.plant.categories.v1') || '[]');
    if (Array.isArray(storedCategories)) customCategories = storedCategories;
} catch (error) {
    customCategories = [];
}

function populateAreaAndZoneSelects(selectedAreaId, selectedZoneId) {
    var areas = (zoneRegistry.areas && zoneRegistry.areas.length) ? zoneRegistry.areas : [
        { id: 1, name: 'Khu A - Ban công Tầng 2' },
        { id: 2, name: 'Khu B - Sân thượng Tầng 3' },
        { id: 3, name: 'Khu C - Hiên nhà & Nội thất' }
    ];
    areaSelect.innerHTML = areas.map(function (a) {
        return '<option value="' + a.id + '">' + a.name + '</option>';
    }).join('');
    if (selectedAreaId) areaSelect.value = String(selectedAreaId);

    var currentZoneVal = selectedZoneId || zoneSelect.value;
    zoneSelect.innerHTML = zoneRegistry.list.map(function (zone) {
        return '<option value="' + zone.id + '" data-area-id="' + (zone.areaId || 1) + '">'
            + (zone.areaName ? zone.areaName + ' · ' : '')
            + zone.name + ' (Node #' + pad2(zone.nodeId) + ' · ' + zone.crop + ')'
            + '</option>';
    }).concat([
        '<option value="__new_pot__">+ Thêm chậu cây mới vào Khu vực đã chọn...</option>'
    ]).join('');
    if (currentZoneVal) zoneSelect.value = String(currentZoneVal);
}

populateAreaAndZoneSelects();

zoneSelect.addEventListener('change', function () {
    var isNewPot = zoneSelect.value === '__new_pot__';
    newPotNameField.hidden = !isNewPot;
    newPotNameInput.required = isNewPot;
    if (!isNewPot) {
        var z = zoneRegistry.get(zoneSelect.value);
        if (z && z.areaId) {
            areaSelect.value = String(z.areaId);
        }
    } else {
        newPotNameInput.focus();
    }
});

function closePlantModal() {
    plantModal.hidden = true;
    plantModal.setAttribute('aria-hidden', 'true');
    document.body.classList.remove('plant-modal-open');
}

function refreshPlantCategories(selectedCategory) {
    var categories = builtInCategories.concat(customCategories);
    allPlants.forEach(function (plant) {
        if (plant.category && !categories.some(function (category) {
            return category.toLowerCase() === String(plant.category).toLowerCase();
        })) categories.push(String(plant.category));
    });
    if (selectedCategory && !categories.some(function (category) {
        return category.toLowerCase() === String(selectedCategory).toLowerCase();
    })) categories.push(String(selectedCategory));

    categorySelect.innerHTML = '';
    categories.forEach(function (category) {
        var option = document.createElement('option');
        option.value = category;
        option.textContent = category;
        categorySelect.appendChild(option);
    });
    var customOption = document.createElement('option');
    customOption.value = '__custom__';
    customOption.textContent = 'Add custom species/category...';
    categorySelect.appendChild(customOption);
    categorySelect.value = selectedCategory || builtInCategories[0];
}

function setCustomCategoryVisibility(visible) {
    customCategoryField.hidden = !visible;
    customCategoryInput.required = visible;
}

function openPlantModal(plant) {
    if (!canManagePlants) {
        showToast('Access denied: only Admin and Manager can add or edit plants.');
        return;
    }
    plantForm.reset();
    plantFormError.hidden = true;
    plantFormError.textContent = '';
    editingPlantId = plant ? plant.id : null;
    refreshPlantCategories(plant && plant.category);
    setCustomCategoryVisibility(false);
    customCategoryInput.value = '';
    newPotNameField.hidden = true;
    newPotNameInput.required = false;
    newPotNameInput.value = '';

    var defaultZone = zoneRegistry.list[0];
    populateAreaAndZoneSelects(
        plant ? plant.areaId : (defaultZone ? defaultZone.areaId : 1),
        plant ? plant.zoneId : (defaultZone ? defaultZone.id : '1')
    );

    document.getElementById('plantModalTitle').textContent = plant ? 'Edit Pot & Plant Thresholds' : 'Add Plant & Assign Pot';
    document.getElementById('savePlantButton').textContent = plant ? 'Save changes' : 'Add plant';
    if (plant) {
        document.getElementById('newPlantName').value = plant.name || '';
        categorySelect.value = plant.category || builtInCategories[0];
        areaSelect.value = String(plant.areaId || 1);
        zoneSelect.value = String(plant.zoneId || '1');
        targetMinInput.value = Number.isFinite(Number(plant.targetMin)) ? Math.round(Number(plant.targetMin)) : 35;
        targetMaxInput.value = Number.isFinite(Number(plant.targetMax)) ? Math.round(Number(plant.targetMax)) : 75;
        document.getElementById('newPlantWater').value = plant.waterAmountMl || 250;
    } else {
        targetMinInput.value = 35;
        targetMaxInput.value = 75;
        document.getElementById('newPlantWater').value = 250;
    }
    plantModal.hidden = false;
    plantModal.setAttribute('aria-hidden', 'false');
    document.body.classList.add('plant-modal-open');
    document.getElementById('newPlantName').focus();
}

var addPlantBtn = document.getElementById('addPlantButton');
if (!canManagePlants && addPlantBtn) {
    addPlantBtn.hidden = true;
    addPlantBtn.style.display = 'none';
}
addPlantBtn.addEventListener('click', function () { openPlantModal(); });
document.getElementById('closePlantModal').addEventListener('click', closePlantModal);
document.getElementById('cancelPlantModal').addEventListener('click', closePlantModal);

plantModal.addEventListener('click', function (event) {
    if (event.target === plantModal) closePlantModal();
});

categorySelect.addEventListener('change', function () {
    var isCustom = categorySelect.value === '__custom__';
    setCustomCategoryVisibility(isCustom);
    if (isCustom) customCategoryInput.focus();
});

document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape' && !plantModal.hidden) closePlantModal();
});

plantForm.addEventListener('submit', function (event) {
    event.preventDefault();
    if (!canManagePlants) {
        showToast('Access denied: only Admin and Manager can save plants.');
        return;
    }
    plantFormError.hidden = true;

    var name = document.getElementById('newPlantName').value.trim();
    var category = categorySelect.value === '__custom__' ? customCategoryInput.value.trim() : categorySelect.value;
    var areaId = Number(areaSelect.value) || 1;
    var isNewPot = zoneSelect.value === '__new_pot__';
    var zone = isNewPot ? null : zoneRegistry.get(zoneSelect.value);
    var newPotName = isNewPot ? newPotNameInput.value.trim() : '';
    var targetMin = Number(targetMinInput.value);
    var targetMax = Number(targetMaxInput.value);
    var waterAmountMl = Number(document.getElementById('newPlantWater').value);

    if (!name || !category || (!isNewPot && !zone) || (isNewPot && !newPotName)
            || !Number.isFinite(waterAmountMl) || waterAmountMl < 50 || waterAmountMl > 5000
            || !Number.isFinite(targetMin) || !Number.isFinite(targetMax)
            || targetMin < 0 || targetMax > 100 || targetMin >= targetMax) {
        plantFormError.textContent = 'Please enter plant name, category, valid Pot, water amount (50–5000 ml), and moisture thresholds (0 <= Min < Max <= 100%).';
        plantFormError.hidden = false;
        return;
    }

    if (!builtInCategories.some(function (item) { return item.toLowerCase() === category.toLowerCase(); }) &&
        !customCategories.some(function (item) { return item.toLowerCase() === category.toLowerCase(); })) {
        customCategories.push(category);
        try { localStorage.setItem('si.plant.categories.v1', JSON.stringify(customCategories)); } catch (error) {}
    }

    var nextId = allPlants.concat(samplePlants).reduce(function (maximum, plant) {
        return Math.max(maximum, Number(plant.id) || 0);
    }, 0) + 1;
    var existingPlant = editingPlantId === null ? null : findPlant(editingPlantId);
    var payload = {
        id: editingPlantId === null ? nextId : editingPlantId,
        name: name,
        category: category,
        areaId: areaId,
        zoneId: isNewPot ? '__new_pot__' : zone.id,
        newPotName: newPotName,
        targetMin: targetMin,
        targetMax: targetMax,
        waterAmountMl: waterAmountMl
    };

    var saveRequest = editingPlantId === null ? addPlant(payload) : updatePlant(payload);
    saveRequest.then(function () {
        if (!isNewPot && zone) {
            zoneRegistry.setThresholds(zone.id, targetMin, targetMax);
        }
        closePlantModal();
        reload();
        var potLabel = isNewPot ? newPotName : (zone ? zone.name : 'Pot');
        showToast(name + ' (' + targetMin + '–' + targetMax + '%) synced to ' + potLabel + '!');
    }).catch(function () {
        plantFormError.textContent = 'The plant could not be saved. Please try again.';
        plantFormError.hidden = false;
    });
});


/* ---------- 7. CHẠY ---------- */
reload();

if (!CONFIG.useSampleData) {
    setInterval(function () { if (!document.hidden) reload(); }, CONFIG.refreshMs);
}
