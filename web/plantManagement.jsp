<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Plant Management</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="css/plantManagement.css">
    <link rel="stylesheet" href="css/navbarResponsive.css?v=20261013a">
</head>

<body class="pm-body">

<!-- Icon sprite -->
<svg width="0" height="0" style="position:absolute" aria-hidden="true">
    <symbol id="i-logo" viewBox="0 0 24 24"><path d="M12 21a9.004 9.004 0 008.716-6.747M12 21a9.004 9.004 0 01-8.716-6.747M12 21V12m0 0a4 4 0 014-4h.5a4.5 4.5 0 014.5 4.5c0 2.4-1.8 4.3-4.2 4.5M12 12a4 4 0 00-4-4h-.5a4.5 4.5 0 00-4.5 4.5c0 2.4 1.8 4.3 4.2 4.5"/></symbol>
    <symbol id="i-drop" viewBox="0 0 24 24"><path d="M12 2.69l5.66 5.66a8 8 0 11-11.31 0z"/></symbol>
    <symbol id="i-bell" viewBox="0 0 24 24"><path d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></symbol>
    <symbol id="i-logout" viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9"/></symbol>
    <symbol id="i-menu" viewBox="0 0 24 24"><path d="M4 6h16M4 12h16M4 18h16"/></symbol>
    <symbol id="i-search" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/></symbol>
    <symbol id="i-plus" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14M5 12h14"/></symbol>
    <symbol id="i-temp" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 14.8V4a2 2 0 0 0-4 0v10.8a4 4 0 1 0 4 0z"/></symbol>
    <symbol id="i-clock" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></symbol>
    <symbol id="i-edit" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4z"/></symbol>
    <symbol id="i-trash" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M8 6V4h8v2"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6M14 11v6"/></symbol>
    <symbol id="i-pin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 10c0 6-8 12-8 12S4 16 4 10a8 8 0 1 1 16 0z"/><circle cx="12" cy="10" r="3"/></symbol>
    <symbol id="i-leaf" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.5 19 2c1 2 2 4.2 2 8 0 5.5-4.8 10-10 10z"/><path d="M2 21c0-3 1.9-5.4 5.1-6.5C9.3 13.7 12 13 12 13"/></symbol>
    <symbol id="i-sync" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12a9 9 0 0 0-15-6.7L3 8"/><path d="M3 3v5h5"/><path d="M3 12a9 9 0 0 0 15 6.7L21 16"/><path d="M16 16h5v5"/></symbol>
</svg>

<%@include file="/WEB-INF/navbar.jspf"%>


<main class="plant-page">
    <div class="container">

        <!-- Tiêu đề trang -->
        <div class="page-header">
            <div class="page-title">
                <p class="section-label">AREA · POT · PLANT MANAGEMENT</p>
                <h1>Plants &amp; Pots</h1>
                <p class="page-sub">Manage areas, pots (1 pot = 1 plant), and flexible auto-watering moisture thresholds.</p>
            </div>

            <div class="page-tools">
                <span class="sync-pill"><svg class="ico"><use href="#i-sync"/></svg><span id="syncText">Auto-sync</span></span>
                <label class="search-box">
                    <svg class="ico"><use href="#i-search"/></svg>
                    <input type="search" id="plantSearch" placeholder="Search by area, pot, plant or node...">
                </label>
                <button class="btn btn-primary" id="addPlantButton" type="button">
                    <svg class="ico"><use href="#i-plus"/></svg>Add Plant
                </button>
            </div>
        </div>


        <!-- 4 ô tổng quan: số được JS điền vào các id bên dưới -->
        <section class="summary">
            <div class="summary-card">
                <span class="summary-icon tone-green"><svg class="ico"><use href="#i-leaf"/></svg></span>
                <div><p class="summary-label">Active Pots / Plants</p><p class="summary-value" id="statTotal">0</p></div>
            </div>
            <div class="summary-card">
                <span class="summary-icon tone-green"><svg class="ico"><use href="#i-drop"/></svg></span>
                <div><p class="summary-label">Healthy</p><p class="summary-value" id="statHealthy">0</p></div>
            </div>
            <div class="summary-card">
                <span class="summary-icon tone-amber"><svg class="ico"><use href="#i-drop"/></svg></span>
                <div><p class="summary-label">Need water</p><p class="summary-value" id="statNeedWater">0</p></div>
            </div>
            <div class="summary-card">
                <span class="summary-icon tone-blue"><svg class="ico"><use href="#i-clock"/></svg></span>
                <div><p class="summary-label">Water suggested</p><p class="summary-value"><span id="statWaterMl">0</span> <small>ml</small></p></div>
            </div>
        </section>


        <!-- Nút lọc: JS tự tạo theo loại cây có trong dữ liệu -->
        <div class="filters" id="plantFilters"></div>


        <!-- Danh sách thẻ cây: JS tự tạo từ <template> bên dưới -->
        <div class="plant-grid" id="plantGrid"></div>

        <p class="empty-state" id="emptyAll" hidden>No plants yet. Click “Add Plant” to register your first plant.</p>
        <p class="empty-state" id="emptyState" hidden>No plants match your search or filter.</p>

    </div>
</main>

<div class="plant-modal" id="plantModal" hidden aria-hidden="true">
    <section class="plant-modal-panel" role="dialog" aria-modal="true" aria-labelledby="plantModalTitle">
        <div class="plant-modal-head">
            <div>
                <p class="plant-modal-eyebrow">AREA · POT · PLANT HIERARCHY</p>
                <h2 id="plantModalTitle">Add a plant</h2>
            </div>
            <button type="button" class="plant-modal-close" id="closePlantModal" aria-label="Close plant form">&times;</button>
        </div>
        <p class="plant-modal-copy">Configure Area (Khu vực), Pot (Chậu cây - 1 Pot = 1 Plant), Plant details, and flexible auto-watering moisture thresholds.</p>
        <div class="plant-form-error" id="plantFormError" role="alert" hidden></div>
        <form id="plantForm">
            <div class="plant-modal-fields">
                <label class="plant-modal-field" for="newPlantArea">
                    <span>Area (Khu vực)</span>
                    <select id="newPlantArea" name="areaId" required></select>
                </label>
                <label class="plant-modal-field" for="newPlantZone">
                    <span>Pot / Node (Chậu cây)</span>
                    <select id="newPlantZone" name="zoneId" required></select>
                </label>
                <label class="plant-modal-field custom-category-field" id="newPotNameField" for="newPotNameInput" hidden>
                    <span>New Pot Name (Tên chậu cây mới)</span>
                    <input id="newPotNameInput" name="newPotName" type="text" maxlength="60" autocomplete="off" placeholder="e.g. Chậu Ban Công 2">
                </label>
                <label class="plant-modal-field" for="newPlantName">
                    <span>Plant name (Tên loại cây)</span>
                    <input id="newPlantName" name="name" type="text" maxlength="60" autocomplete="off" required>
                </label>
                <label class="plant-modal-field" for="newPlantCategory">
                    <span>Species / Category (Phân loại)</span>
                    <select id="newPlantCategory" name="category" required>
                        <option value="Aloe vera">Aloe vera (Succulent)</option>
                        <option value="Chrysanthemum">Chrysanthemum (Flower)</option>
                        <option value="Phalaenopsis">Phalaenopsis (Orchid)</option>
                        <option value="Epipremnum aureum">Epipremnum aureum (Herb/Indoor)</option>
                        <option value="Vegetable">Vegetable</option>
                        <option value="Herb">Herb</option>
                        <option value="Flower">Flower</option>
                        <option value="Fruit">Fruit</option>
                        <option value="__custom__">Add custom species/category...</option>
                    </select>
                </label>
                <label class="plant-modal-field custom-category-field" id="customCategoryField" for="newPlantCustomCategory" hidden>
                    <span>Custom species / category</span>
                    <input id="newPlantCustomCategory" type="text" maxlength="40" autocomplete="off" placeholder="e.g. Succulent">
                </label>
                <label class="plant-modal-field" for="newPlantTargetMin">
                    <span>Min moisture % (Ngưỡng tưới tự động / Khô hạn)</span>
                    <input id="newPlantTargetMin" name="targetMin" type="number" min="5" max="95" step="1" value="35" required>
                </label>
                <label class="plant-modal-field" for="newPlantTargetMax">
                    <span>Max moisture % (Ngưỡng cảnh báo ngập úng)</span>
                    <input id="newPlantTargetMax" name="targetMax" type="number" min="10" max="100" step="1" value="75" required>
                </label>
                <label class="plant-modal-field" for="newPlantWater">
                    <span>Water per run (ml) (Lượng nước mỗi lần tưới)</span>
                    <input id="newPlantWater" name="waterAmountMl" type="number" min="50" max="5000" step="50" value="250" required>
                </label>
            </div>
            <p class="plant-modal-note">Rule: 1 Pot has 1 Plant. Saving updates the Database, Web Dashboard, and ESP8266 auto-watering thresholds immediately.</p>
            <div class="plant-modal-actions">
                <button type="button" class="plant-modal-button secondary" id="cancelPlantModal">Cancel</button>
                <button type="submit" class="plant-modal-button primary" id="savePlantButton">Add plant</button>
            </div>
        </form>
    </section>
</div>

<!--
    MẪU 1 THẺ CÂY (AREA · POT · PLANT).
-->
<template id="plantCardTemplate">
    <article class="plant-card">

        <div class="card-top">
            <a class="node-tag" data-field="sensorLink" href="<%= request.getContextPath() %>/sensor-data"><svg class="ico"><use href="#i-pin"/></svg><span data-field="location"></span></a>
            <span class="status" data-field="statusLabel"></span>
        </div>

        <div class="card-title">
            <span class="plant-image" data-field="emoji"></span>
            <div>
                <h2 data-field="name"></h2>
                <span class="category" data-field="category"></span>
            </div>
        </div>

        <div class="moisture">
            <div class="moisture-head">
                <span class="moisture-label"><svg class="ico"><use href="#i-drop"/></svg>Soil moisture</span>
                <span class="moisture-value"><span data-field="moisture"></span><small data-field="moistureUnit">%</small></span>
            </div>
            <div class="bar">
                <span class="bar-target" data-field="targetBar"></span>
                <span class="bar-fill" data-field="moistureBar"></span>
            </div>
            <p class="bar-note" data-field="note"></p>
        </div>

        <div class="meta">
            <div><svg class="ico"><use href="#i-temp"/></svg><span><em>Temp</em><b data-field="temperature"></b></span></div>
            <div><svg class="ico"><use href="#i-clock"/></svg><span><em>Last watered</em><b data-field="lastWatered"></b></span></div>
        </div>

        <div class="plant-actions">
            <button class="water-btn" type="button" data-action="water"><svg class="ico"><use href="#i-drop"/></svg><span data-field="waterLabel"></span></button>
            <button class="act-btn" type="button" data-action="bind-hw" title="Attach physical ESP8266 &amp; Water Pump to this pot"><span data-field="bindHwLabel">🔌 Gán Bơm</span></button>
            <button class="act-btn" type="button" data-action="edit"><svg class="ico"><use href="#i-edit"/></svg>Edit</button>
            <button class="act-btn danger" type="button" data-action="delete"><svg class="ico"><use href="#i-trash"/></svg>Delete</button>
        </div>

    </article>
</template>


<footer class="footer">
    <div class="container footer-inner">

        <p class="footer-copy">© 2026 Smart Irrigation System</p>

    </div>
</footer>

<div class="toast" id="toast" role="status" aria-live="polite"></div>

<script src="<%= request.getContextPath() %>/app-data.js"></script>
<script src="js/zone-data.js?v=20261028a"></script>
<script src="js/alertCenter.js?v=20261016a"></script>
<script src="js/siteNavigation.js?v=20261016a"></script>
<script src="js/plantManagement.js?v=20261028a"></script>
</body>
</html>
