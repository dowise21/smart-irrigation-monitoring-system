/* =====================================================================
   Trang Plants
   Cách hoạt động:  loadPlants()  ->  danh sách cây  ->  vẽ giao diện

   Khi nối database, bạn CHỈ cần sửa 3 hàm ở mục 2:
       loadPlants()   lấy danh sách cây
       waterPlant()   tưới cây
       deletePlant()  xoá cây
   Phần còn lại (tính trạng thái, thống kê, vẽ thẻ, lọc...) không cần đụng tới.
   ===================================================================== */


/* ---------- 1. CẤU HÌNH ---------- */
var ctx = window.SI_CTX || '';
var CONFIG = {
    useSampleData: false,       // true = dùng dữ liệu mẫu bên dưới; false = gọi server thật
    apiUrl: ctx + '/api/plants',// địa chỉ servlet trả về JSON danh sách cây
    refreshMs: 15000            // tự làm mới số liệu mỗi 15 giây (chỉ khi dùng server thật)
};

var canManagePlants = !window.SI_ACCESS || !Array.isArray(window.SI_ACCESS.write) || window.SI_ACCESS.write.indexOf('/plants') !== -1;
var canWaterPlants = !window.SI_ACCESS || !Array.isArray(window.SI_ACCESS.write) || window.SI_ACCESS.write.indexOf('/manual-water') !== -1;

/*
   Mỗi cây là 1 object. Tên trường nên khớp với cột trong database:
     id             mã cây
     name           tên cây
     category       loại: Vegetable, Flower, Herb...
     garden         tên khu vườn
     nodeId         số node cảm biến
     soilMoisture   độ ẩm đất hiện tại (%), để null nếu chưa có số đo
     temperature    nhiệt độ (°C), để null nếu chưa có số đo
     targetMin/Max  khoảng độ ẩm mục tiêu (%)
     waterAmountMl  lượng nước mỗi lần tưới (ml)
     lastWateredAt  thời điểm tưới gần nhất (chuỗi ngày giờ, null nếu chưa tưới)
     emoji          (không bắt buộc) icon cây; bỏ trống thì tự chọn theo loại
*/
function hoursAgo(h) { return new Date(Date.now() - h * 3600 * 1000).toISOString(); }
var zoneRegistry = window.IrrigationZones;
var firstZoneId = (zoneRegistry.list[0] && zoneRegistry.list[0].id) || '1';

var samplePlants = (window.SI_DATA && Array.isArray(window.SI_DATA.plants)) ? window.SI_DATA.plants : [
        { id: 1, name: 'Tomato', category: 'Vegetable', garden: zoneRegistry.name(firstZoneId), zoneId: firstZoneId, nodeId: 1, soilMoisture: zoneRegistry.getSoilMoisture(firstZoneId), temperature: 27.4,
            targetMin: 60, targetMax: 80, waterAmountMl: 300, lastWateredAt: hoursAgo(2), emoji: '🍅' }
];


/* ---------- 2. CHỖ NỐI DATABASE (sửa ở đây) ---------- */

// Lấy danh sách cây. Phải trả về Promise của một mảng cây (cùng dạng với samplePlants).
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
    });
}

// Tưới cây có mã id. Xong thì trả Promise.
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

// Xoá cây có mã id. Xong thì trả Promise.
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
    });
}


/* ---------- 3. HÀM PHỤ ---------- */
var allPlants = [];          // danh sách cây hiện tại
var currentFilter = 'all';   // nút lọc đang chọn

var grid = document.getElementById('plantGrid');
var filtersBox = document.getElementById('plantFilters');
var searchInput = document.getElementById('plantSearch');
var toast = document.getElementById('toast');
var toastTimer;
var requestedZone = new URLSearchParams(window.location.search).get('zone');
if (zoneRegistry.get(requestedZone)) searchInput.value = zoneRegistry.name(requestedZone);

function findPlant(id) {
    return allPlants.concat(samplePlants).filter(function (p) { return p.id === id; })[0];
}

function showToast(message) {
    toast.textContent = message;
    toast.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { toast.classList.remove('show'); }, 2400);
}

// Điền chữ vào phần tử có data-field="tên" bên trong 1 thẻ
function setText(root, field, value) {
    var el = root.querySelector('[data-field="' + field + '"]');
    if (el) el.textContent = value;
}

function pad2(n) { return (n < 10 ? '0' : '') + n; }

// Trạng thái cây: so độ ẩm với khoảng mục tiêu
function getStatus(p) {
    if (p.soilMoisture === null || p.soilMoisture === undefined) return 'nodata';
    if (p.soilMoisture < p.targetMin) return 'low';
    if (p.soilMoisture > p.targetMax) return 'high';
    return 'ok';
}

// Chữ + màu hiển thị cho từng trạng thái
var STATUS_INFO = {
    ok:     { label: 'Healthy',     badge: 'success', card: '',           tone: 'tone-green' },
    low:    { label: 'Needs water', badge: 'warning', card: 'is-warning', tone: 'tone-amber' },
    high:   { label: 'Too wet',     badge: 'info',    card: 'is-wet',     tone: 'tone-blue'  },
    nodata: { label: 'No data',     badge: 'muted',   card: '',           tone: 'tone-green' }
};

// "2h ago", "Yesterday 17:30"...
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

// Icon cây: dùng emoji trong dữ liệu, nếu không có thì chọn theo loại
function getEmoji(p) {
    if (p.emoji) return p.emoji;
    var byCategory = { vegetable: '🥬', flower: '🌸', fruit: '🍓', herb: '🌿' };
    return byCategory[String(p.category).toLowerCase()] || '🌱';
}


/* ---------- 4. VẼ GIAO DIỆN ---------- */

// 4a. Bốn ô tổng quan
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

// 4b. Nút lọc (All, từng loại cây, Attention needed)
function renderFilters(plants, needWater) {
    var counts = {};                         // { vegetable: 2, flower: 1 }
    plants.forEach(function (p) {
        var key = String(p.category).toLowerCase();
        counts[key] = (counts[key] || 0) + 1;
    });

    // loại cây đang lọc mà không còn nữa thì quay về All
    if (currentFilter !== 'all' && currentFilter !== 'attention' && !counts[currentFilter]) {
        currentFilter = 'all';
    }

    var html = chip('all', 'All', plants.length, '');
    Object.keys(counts).forEach(function (key) {
        var label = key.charAt(0).toUpperCase() + key.slice(1) + 's';
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

// 4c. Một thẻ cây (nhân bản từ <template>)
function createCard(p) {
    var template = document.getElementById('plantCardTemplate');
    var card = template.content.firstElementChild.cloneNode(true);
    var status = getStatus(p);
    var info = STATUS_INFO[status];
    var hasMoisture = status !== 'nodata';

    // thông tin để lọc / tìm kiếm / bấm nút
    card.dataset.id = p.id;
    card.dataset.category = String(p.category).toLowerCase();
    card.dataset.status = status;
    card.dataset.search = (p.name + ' ' + p.garden + ' node ' + pad2(p.nodeId)).toLowerCase();
    if (info.card) card.classList.add(info.card);

    // chữ
    setText(card, 'location', p.garden + ' · Node #' + pad2(p.nodeId));
    setText(card, 'name', p.name);
    setText(card, 'category', p.category);
    setText(card, 'emoji', getEmoji(p));
    setText(card, 'moisture', hasMoisture ? Math.round(p.soilMoisture) : '--');
    setText(card, 'moistureUnit', hasMoisture ? '%' : '');
    setText(card, 'temperature', (p.temperature === null || p.temperature === undefined) ? '--' : Number(p.temperature).toFixed(1) + '°C');
    setText(card, 'lastWatered', timeAgo(p.lastWateredAt));
    card.querySelector('[data-field="sensorLink"]').href = ctx + '/sensor-data?zone=' + encodeURIComponent(p.zoneId);

    // nhãn trạng thái
    var badge = card.querySelector('[data-field="statusLabel"]');
    badge.textContent = info.label;
    badge.classList.add(info.badge);

    // màu ô icon cây
    card.querySelector('[data-field="emoji"]').classList.add(info.tone);

    // thanh độ ẩm + vùng mục tiêu
    var fill = card.querySelector('[data-field="moistureBar"]');
    var target = card.querySelector('[data-field="targetBar"]');
    fill.style.width = hasMoisture ? Math.max(0, Math.min(100, p.soilMoisture)) + '%' : '0%';
    target.style.left = p.targetMin + '%';
    target.style.width = (p.targetMax - p.targetMin) + '%';

    // ghi chú dưới thanh
    var note = 'Target range ' + Math.round(p.targetMin) + '–' + Math.round(p.targetMax) + '%';
    if (status === 'low')  note += ' · ' + Math.round(p.targetMin - p.soilMoisture) + '% below';
    if (status === 'high') note += ' · ' + Math.round(p.soilMoisture - p.targetMax) + '% above';
    setText(card, 'note', note);

    // nút tưới
    var waterBtn = card.querySelector('[data-action="water"]');
    setText(card, 'waterLabel', canWaterPlants
        ? ((status === 'low' ? 'Water now' : 'Water') + ' (' + p.waterAmountMl + 'ml)')
        : 'Watering restricted');
    if (status === 'low' && canWaterPlants) waterBtn.classList.add('urgent');
    if (!canWaterPlants) {
        waterBtn.disabled = true;
        waterBtn.title = 'Only Admin and Staff accounts can execute manual watering.';
    }

    // gắn id + tên cho các nút để biết đang bấm cây nào
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

// 4d. Vẽ lại toàn bộ trang
function renderAll() {
    var needWater = renderStats(allPlants);
    renderFilters(allPlants, needWater);

    grid.innerHTML = '';
    allPlants.forEach(function (p) { grid.appendChild(createCard(p)); });

    document.getElementById('emptyAll').hidden = allPlants.length > 0;
    document.getElementById('syncText').textContent = 'Auto-sync: ' + new Date().toLocaleTimeString('en-GB');
    applyFilter();
}

// 4e. Ẩn/hiện thẻ theo nút lọc + ô tìm kiếm
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
        .then(function (plants) { allPlants = plants; renderAll(); })
        .catch(function () { showToast('Cannot load plants. Please try again.'); });
}


/* ---------- 6. SỰ KIỆN ---------- */

// Bấm nút lọc
filtersBox.addEventListener('click', function (event) {
    var btn = event.target.closest('.chip');
    if (!btn) return;
    currentFilter = btn.dataset.filter;
    applyFilter();
});

// Gõ vào ô tìm kiếm
searchInput.addEventListener('input', applyFilter);

// Bấm Water / Edit / Delete trên thẻ cây
grid.addEventListener('click', function (event) {
    var btn = event.target.closest('[data-action]');
    if (!btn) return;
    var id = Number(btn.dataset.id);
    var name = btn.dataset.name;

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
var zoneSelect = document.getElementById('newPlantZone');
var categorySelect = document.getElementById('newPlantCategory');
var customCategoryField = document.getElementById('customCategoryField');
var customCategoryInput = document.getElementById('newPlantCustomCategory');
var editingPlantId = null;
var builtInCategories = ['Vegetable', 'Herb', 'Flower', 'Fruit'];
var customCategories = [];

try {
    var storedCategories = JSON.parse(localStorage.getItem('si.plant.categories.v1') || '[]');
    if (Array.isArray(storedCategories)) customCategories = storedCategories;
} catch (error) {
    customCategories = [];
}

zoneSelect.innerHTML = zoneRegistry.list.map(function (zone) {
    return '<option value="' + zone.id + '">' + zone.name + ' · ' + zone.crop + '</option>';
}).join('');

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
    customOption.textContent = 'Add custom category...';
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
    document.getElementById('plantModalTitle').textContent = plant ? 'Edit plant' : 'Add a plant';
    document.getElementById('savePlantButton').textContent = plant ? 'Save changes' : 'Add plant';
    if (plant) {
        document.getElementById('newPlantName').value = plant.name || '';
        categorySelect.value = plant.category || builtInCategories[0];
        zoneSelect.value = plant.zoneId || '';
        document.getElementById('newPlantWater').value = plant.waterAmountMl || 250;
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
    var zone = zoneRegistry.get(zoneSelect.value);
    var waterAmountMl = Number(document.getElementById('newPlantWater').value);
    if (!name || !category || !zone || !Number.isFinite(waterAmountMl) || waterAmountMl < 50 || waterAmountMl > 5000) {
        plantFormError.textContent = 'Enter a plant name and category, choose a garden, and set water between 50 and 5,000 ml.';
        plantFormError.hidden = false;
        return;
    }

    if (!builtInCategories.some(function (item) { return item.toLowerCase() === category.toLowerCase(); }) &&
        !customCategories.some(function (item) { return item.toLowerCase() === category.toLowerCase(); })) {
        customCategories.push(category);
        try { localStorage.setItem('si.plant.categories.v1', JSON.stringify(customCategories)); } catch (error) { /* Category remains available for this session. */ }
    }

    var nextId = allPlants.concat(samplePlants).reduce(function (maximum, plant) {
        return Math.max(maximum, Number(plant.id) || 0);
    }, 0) + 1;
    var existingPlant = editingPlantId === null ? null : findPlant(editingPlantId);
    var plant = Object.assign({}, existingPlant || {}, {
        id: editingPlantId === null ? nextId : editingPlantId,
        name: name,
        category: category,
        garden: zone.name,
        zoneId: zone.id,
        nodeId: zone.nodeId,
        waterAmountMl: waterAmountMl
    });
    if (!existingPlant) {
        plant.soilMoisture = zoneRegistry.getSoilMoisture(zone.id);
        plant.temperature = null;
        plant.targetMin = 60;
        plant.targetMax = 80;
        plant.lastWateredAt = null;
    }

    var saveRequest = editingPlantId === null ? addPlant(plant) : updatePlant(plant);
    saveRequest.then(function () {
        closePlantModal();
        reload();
        showToast(name + (editingPlantId === null ? ' added to ' : ' updated in ') + zone.name + '.');
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

