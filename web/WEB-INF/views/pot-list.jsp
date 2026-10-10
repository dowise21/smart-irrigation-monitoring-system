
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pot / Irrigation Zone Management - Smart Irrigation System</title>

    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    

    <link href="${pageContext.request.contextPath}/css/app.css" rel="stylesheet">
    
    <style>
        :root {
            --primary-emerald: #10b981;
            --primary-dark: #059669;
            --primary-soft: #ecfdf5;
            --accent-teal: #0d9488;
            --water-blue: #0284c7;
            --water-blue-bg: #e0f2fe;
            --bg-canvas: #f6f8fa;
            --card-border: rgba(226, 232, 240, 0.85);
            --text-heading: #0f172a;
            --text-body: #475569;
            --text-muted: #94a3b8;
        }
        
        body {
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
            background-color: var(--bg-canvas);
            color: var(--text-body);
            -webkit-font-smoothing: antialiased;
            min-height: 100vh;
        }
        
        /* Container Card Styling */
        .saas-card {
            background: #ffffff;
            border-radius: 18px;
            border: 1px solid var(--card-border);
            box-shadow: 0 10px 30px -4px rgba(15, 23, 42, 0.04), 0 2px 6px -1px rgba(15, 23, 42, 0.02);
            padding: 1.75rem 2rem;
            margin-bottom: 2rem;
        }
        
        /* Header Badges */
        .page-badge-pots {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 0.75rem;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 9999px;
            background: #ecfdf5;
            color: #047857;
            border: 1px solid #a7f3d0;
            letter-spacing: 0.02em;
        }
        .pulse-green-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background-color: #10b981;
            box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7);
            animation: pulse-green 2s infinite;
        }
        @keyframes pulse-green {
            0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7); }
            70% { transform: scale(1); box-shadow: 0 0 0 6px rgba(16, 185, 129, 0); }
            100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
        }
        
        /* Create Button */
        .btn-create-pot {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 0.58rem 1.35rem;
            border-radius: 9999px;
            font-size: 0.88rem;
            font-weight: 600;
            color: #ffffff;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            border: none;
            box-shadow: 0 4px 14px rgba(16, 185, 129, 0.28);
            transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
            text-decoration: none;
        }
        .btn-create-pot:hover {
            background: linear-gradient(135deg, #059669 0%, #047857 100%);
            color: #ffffff;
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(16, 185, 129, 0.38);
        }
        .btn-create-pot:active { transform: translateY(0); }
        
        /* Modern SaaS Table */
        .table-saas-container {
            border-radius: 14px;
            overflow: hidden;
            border: 1px solid var(--card-border);
        }
        .table-saas {
            margin-bottom: 0;
            border-collapse: separate;
            border-spacing: 0;
            width: 100%;
        }
        .table-saas thead th {
            background-color: #f8fafc;
            color: #475569;
            font-size: 0.78rem;
            text-transform: uppercase;
            font-weight: 700;
            letter-spacing: 0.05em;
            padding: 1rem 1.15rem;
            border-bottom: 1px solid #e2e8f0;
            white-space: nowrap;
        }
        .table-saas tbody td {
            padding: 1.05rem 1.15rem;
            vertical-align: middle;
            border-bottom: 1px solid #f1f5f9;
            font-size: 0.9rem;
            color: var(--text-body);
            background-color: #ffffff;
            transition: background-color 0.15s ease;
        }
        .table-saas tbody tr:last-child td { border-bottom: none; }
        .table-saas tbody tr:hover td { background-color: #fbfcfe; }
        
        /* Pot Info Items */
        .pot-title-box {
            display: inline-flex;
            align-items: center;
            gap: 10px;
        }
        .pot-avatar-icon {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%);
            color: #10b981;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 1rem;
            flex-shrink: 0;
            border: 1px solid #a7f3d0;
        }
        .location-text {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            color: #64748b;
            font-size: 0.88rem;
        }
        .plant-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: 8px;
            background-color: #f0fdf4;
            color: #15803d;
            border: 1px solid #bbf7d0;
            font-weight: 600;
            font-size: 0.84rem;
        }
        
        /* Status Pills */
        .status-pill-active {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 12px;
            border-radius: 9999px;
            font-size: 0.8rem;
            font-weight: 700;
            background-color: #ecfdf5;
            color: #047857;
            border: 1px solid #a7f3d0;
        }
        .status-pill-inactive {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 12px;
            border-radius: 9999px;
            font-size: 0.8rem;
            font-weight: 700;
            background-color: #fef2f2;
            color: #b91c1c;
            border: 1px solid #fecaca;
        }
        
        /* Action Buttons */
        .action-group-wrapper {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            flex-wrap: wrap;
        }
        .btn-iot-monitor {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 5px 11px;
            border-radius: 7px;
            font-size: 0.78rem;
            font-weight: 600;
            background: #e0f2fe;
            color: #0369a1;
            border: 1px solid #bae6fd;
            text-decoration: none;
            transition: all 0.2s ease;
        }
        .btn-iot-monitor:hover { background: #0284c7; color: #ffffff; border-color: #0284c7; }
        
        .btn-iot-history {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 5px 11px;
            border-radius: 7px;
            font-size: 0.78rem;
            font-weight: 600;
            background: #eef2ff;
            color: #4338ca;
            border: 1px solid #c7d2fe;
            text-decoration: none;
            transition: all 0.2s ease;
        }
        .btn-iot-history:hover { background: #4f46e5; color: #ffffff; border-color: #4f46e5; }
        
        .btn-saas-edit {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
            border-radius: 7px;
            background: #fffbeb;
            color: #b45309;
            border: 1px solid #fde68a;
            font-size: 0.85rem;
            text-decoration: none;
            transition: all 0.2s ease;
        }
        .btn-saas-edit:hover { background: #f59e0b; color: #ffffff; border-color: #f59e0b; }
        
        .btn-saas-delete {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
            border-radius: 7px;
            background: #fff1f2;
            color: #e11d48;
            border: 1px solid #fecdd3;
            font-size: 0.85rem;
            text-decoration: none;
            transition: all 0.2s ease;
        }
        .btn-saas-delete:hover { background: #e11d48; color: #ffffff; border-color: #e11d48; }
        
        /* Empty State */
        .empty-state-card { padding: 3.5rem 2rem; text-align: center; }
        .empty-state-icon-box {
            width: 72px;
            height: 72px;
            border-radius: 50%;
            background: #ecfdf5;
            color: #10b981;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 2.2rem;
            margin-bottom: 1.25rem;
            box-shadow: 0 4px 16px rgba(16, 185, 129, 0.15);
        }
    </style>
</head>
<body>

    <jsp:include page="navbar.jsp" />
    
    <main class="container py-4">

        <div class="saas-card">
            

            <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3 mb-4 pb-2 border-bottom border-light">
                <div>
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <h3 class="mb-0 fw-bold text-dark tracking-tight" style="letter-spacing: -0.02em;">Pot / Irrigation Zone List</h3>
                        <span class="page-badge-pots">
                            <span class="pulse-green-dot"></span> Device Management
                        </span>
                    </div>
                    <p class="text-secondary small mb-0 d-flex align-items-center gap-1">
                        <i class="bi bi-geo-alt text-primary"></i> 
                        <span>Monitor irrigation valve status, physical location, and plant link on each smart pot</span>
                    </p>
                </div>
                

                <div>
                    <a href="${pageContext.request.contextPath}/pots?action=new" class="btn-create-pot">
                        <i class="bi bi-plus-lg"></i> <span>Add New Pot</span>
                    </a>
                </div>
            </div>
            

            <div class="table-saas-container">
                <table class="table-saas">
                    <thead>
                        <tr>
                            <th style="width: 8%;" class="text-center">ID</th>
                            <th style="width: 23%;">Pot Name / Zone</th>
                            <th style="width: 20%;">Location</th>
                            <th style="width: 17%;">Currently growing</th>
                            <th style="width: 12%;" class="text-center">Status</th>
                            <th style="width: 20%;" class="text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody>

                        <c:forEach var="p" items="${listPot}">
                            <tr>

                                <td class="text-center">
                                    <span class="badge bg-light text-secondary border px-2 py-1 rounded-pill fw-semibold small">
                                        #${p.potId}
                                    </span>
                                </td>
                                

                                <td>
                                    <div class="pot-title-box">
                                        <div class="pot-avatar-icon"><i class="bi bi-flower1"></i></div>
                                        <div>
                                            <div class="fw-bold text-dark">${p.potName}</div>
                                            <small class="text-muted" style="font-size: 0.76rem;">Zone ID: ${p.potId}</small>
                                        </div>
                                    </div>
                                </td>
                                

                                <td>
                                    <span class="location-text">
                                        <i class="bi bi-geo-alt-fill text-danger"></i> <span>${p.location}</span>
                                    </span>
                                </td>
                                

                                <td>
                                    <span class="plant-badge">
                                        <i class="bi bi-tree-fill"></i> <span>${p.plantName}</span>
                                    </span>
                                </td>
                                

                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${p.status}">
                                            <span class="status-pill-active" title="Automatic mode is on">
                                                <span class="pulse-green-dot"></span> Watering
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-pill-inactive" title="Automatic mode is off">
                                                <i class="bi bi-pause-circle-fill"></i> Paused
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                

                                <td class="text-center">
                                    <div class="action-group-wrapper">

                                        <a href="${pageContext.request.contextPath}/sensor-data?potId=${p.potId}" class="btn-iot-monitor" title="View real-time moisture and sensor parameters">
                                            <i class="bi bi-droplet-half"></i> <span>Monitor</span>
                                        </a>
                                        

                                        <a href="${pageContext.request.contextPath}/history?potId=${p.potId}" class="btn-iot-history" title="View pump activation history log">
                                            <i class="bi bi-clock-history"></i> <span>History</span>
                                        </a>
                                        

                                        <a href="${pageContext.request.contextPath}/pots?action=edit&id=${p.potId}" class="btn-saas-edit" title="Edit pot information">
                                            <i class="bi bi-pencil-square"></i>
                                        </a>
                                        

                                        <a href="${pageContext.request.contextPath}/pots?action=delete&id=${p.potId}" class="btn-saas-delete" title="Delete this pot" onclick="return confirm('Are you sure you want to delete this pot?');">
                                            <i class="bi bi-trash3-fill"></i>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        

                        <c:if test="${empty listPot}">
                            <tr>
                                <td colspan="6" class="p-0">
                                    <div class="empty-state-card">
                                        <div class="empty-state-icon-box"><i class="bi bi-flower1"></i></div>
                                        <h5 class="fw-bold text-dark mb-1">No plant pots have been created</h5>
                                        <p class="text-muted small mb-3 max-w-sm mx-auto">
                                            Start managing your smart garden by adding a new plant pot and assigning a moisture sensor.
                                        </p>
                                        <a href="${pageContext.request.contextPath}/pots?action=new" class="btn-create-pot d-inline-flex">
                                            <i class="bi bi-plus-lg"></i> <span>Add First Pot</span>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            

            <div class="d-flex flex-column flex-sm-row justify-content-between align-items-center gap-2 mt-3 pt-2 text-muted small">
                <span><i class="bi bi-cpu me-1"></i> NodeMCU/ESP32 microcontrollers will automatically recognize pot IDs when connected to the Mesh network.</span>
                <span>Smart Irrigation Zone Manager &bull; v2.4</span>
            </div>
            
        </div>
    </main>


    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>