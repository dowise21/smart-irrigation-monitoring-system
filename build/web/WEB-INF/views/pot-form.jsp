
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    
    <title>${pot != null ? 'Update' : 'Add new'} Pot - Smart Irrigation System</title>


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
        .saas-form-card {
            background: #ffffff;
            border-radius: 20px;
            border: 1px solid var(--card-border);
            box-shadow: 0 10px 32px -4px rgba(15, 23, 42, 0.05), 0 2px 8px -2px rgba(15, 23, 42, 0.03);
            padding: 2.25rem 2rem;
            width: 100%;
            max-width: 540px;
            transition: all 0.3s ease;
        }
        
        /* Form Header Badge */
        .header-icon-box {
            width: 52px;
            height: 52px;
            border-radius: 14px;
            background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%);
            color: var(--primary-dark);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 1.6rem;
            margin-bottom: 0.85rem;
            box-shadow: 0 4px 14px rgba(16, 185, 129, 0.15);
        }
        .page-badge-state {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            font-size: 0.75rem;
            font-weight: 700;
            padding: 3px 10px;
            border-radius: 9999px;
            background: #ecfdf5;
            color: #047857;
            letter-spacing: 0.02em;
            text-transform: uppercase;
        }
        
        /* Modern Labels & Inputs */
        .form-label-modern {
            font-size: 0.86rem;
            font-weight: 600;
            color: #334155;
            margin-bottom: 6px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .input-group-modern {
            position: relative;
            display: flex;
            align-items: center;
        }
        .input-group-modern .input-icon {
            position: absolute;
            left: 14px;
            color: #94a3b8;
            font-size: 1.05rem;
            pointer-events: none;
            z-index: 4;
            transition: color 0.2s ease;
        }
        .input-group-modern .form-control, 
        .input-group-modern .form-select {
            height: 48px;
            border-radius: 11px !important;
            padding-left: 42px;
            padding-right: 14px;
            border: 1.5px solid #e2e8f0;
            font-size: 0.92rem;
            font-weight: 500;
            color: var(--text-heading);
            background-color: #f8fafc;
            transition: all 0.2s ease;
        }
        .input-group-modern .form-control:focus, 
        .input-group-modern .form-select:focus {
            background-color: #ffffff;
            border-color: var(--primary-emerald);
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.12);
            outline: none;
        }
        .input-group-modern .form-control:focus ~ .input-icon, 
        .input-group-modern .form-select:focus ~ .input-icon {
            color: var(--primary-emerald);
        }
        
        /* Smart Switch Card */
        .smart-toggle-box {
            background-color: #f8fafc;
            border: 1.5px solid #e2e8f0;
            border-radius: 12px;
            padding: 1rem 1.15rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            transition: all 0.2s ease;
        }
        .smart-toggle-box:hover {
            border-color: #cbd5e1;
            background-color: #ffffff;
        }
        .form-switch .form-check-input {
            width: 2.85em;
            height: 1.5em;
            cursor: pointer;
            background-color: #cbd5e1;
            border-color: transparent;
            transition: background-color 0.25s ease, transform 0.25s ease;
        }
        .form-switch .form-check-input:checked {
            background-color: var(--primary-emerald);
            border-color: var(--primary-emerald);
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15);
        }
        
        /* Action Buttons */
        .btn-save-action {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: #ffffff;
            border: none;
            padding: 0.65rem 1.6rem;
            border-radius: 9999px;
            font-weight: 600;
            font-size: 0.92rem;
            letter-spacing: 0.01em;
            box-shadow: 0 4px 14px rgba(16, 185, 129, 0.25);
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            display: inline-flex;
            align-items: center;
            gap: 7px;
        }
        .btn-save-action:hover {
            background: linear-gradient(135deg, #059669 0%, #047857 100%);
            color: #ffffff;
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(16, 185, 129, 0.32);
        }
        .btn-save-action:active { transform: translateY(0); }
        
        .btn-cancel-action {
            background-color: #ffffff;
            color: #475569;
            border: 1.5px solid #cbd5e1;
            padding: 0.65rem 1.35rem;
            border-radius: 9999px;
            font-weight: 600;
            font-size: 0.92rem;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            text-decoration: none;
        }
        .btn-cancel-action:hover {
            background-color: #f1f5f9;
            color: #1e293b;
            border-color: #94a3b8;
        }
    </style>
</head>
<body>

    <div class="container d-flex justify-content-center align-items-center py-5 min-vh-100">

        <div class="saas-form-card">
            

            <div class="text-center mb-4 pb-2 border-bottom border-light">
                <div class="header-icon-box">
                    <i class="bi bi-flower1"></i>
                </div>
                <div class="d-flex justify-content-center mb-1">
                    <span class="page-badge-state">
                        <i class="bi ${pot != null ? 'bi-pencil-square' : 'bi-plus-circle-fill'}"></i> 
                        <span>${pot != null ? 'Update' : 'Create new'}</span>
                    </span>
                </div>
                <h3 class="fw-bold text-dark mb-1" style="letter-spacing: -0.02em;">
                    ${pot != null ? 'UPDATE PLANT POT' : 'ADD NEW POT'}
                </h3>
                <p class="text-secondary small mb-0">
                    Configure plant pot, garden location, and smart auto-irrigation mode
                </p>
            </div>
            

            <form action="${pageContext.request.contextPath}/pots" method="POST">
                

                <input type="hidden" name="action" value="${pot != null ? 'update' : 'insert'}">
                

                <c:if test="${pot != null}">
                    <input type="hidden" name="potId" value="${pot.potId}">
                </c:if>
                

                <div class="mb-3">
                    <label class="form-label-modern">
                        <span>Pot Name / Zone <span class="text-danger">*</span></span>
                        <small class="text-muted fw-normal" style="font-size: 0.75rem;">Required</small>
                    </label>
                    <div class="input-group-modern">
                        <input type="text" name="potName" class="form-control" required value="${pot.potName}" placeholder="Ex: Balcony Pot 1">
                        <i class="bi bi-tag-fill input-icon"></i>
                    </div>
                </div>
                

                <div class="mb-3">
                    <label class="form-label-modern">
                        <span>Location</span>
                        <small class="text-muted fw-normal" style="font-size: 0.75rem;">Optional</small>
                    </label>
                    <div class="input-group-modern">
                        <input type="text" name="location" class="form-control" value="${pot.location}" placeholder="Ex: 2nd floor, left corner of balcony">
                        <i class="bi bi-geo-alt-fill input-icon"></i>
                    </div>
                </div>
                

                <div class="mb-4">
                    <label class="form-label-modern">
                        <span>Select currently growing plant <span class="text-danger">*</span></span>
                        <small class="text-muted fw-normal" style="font-size: 0.75rem;">By category</small>
                    </label>
                    <div class="input-group-modern">
                        <select name="plantId" class="form-select" required>
                            <option value="">-- Select a plant --</option>

                            <c:forEach var="pl" items="${listPlant}">
                                <option value="${pl.plantId}" ${pot.plantId == pl.plantId ? 'selected' : ''}>
                                    ${pl.plantName}
                                </option>
                            </c:forEach>
                        </select>
                        <i class="bi bi-tree-fill input-icon"></i>
                    </div>
                </div>
                

                <div class="mb-4">
                    <div class="smart-toggle-box">
                        <div class="d-flex align-items-center gap-2">
                            <div class="rounded-circle p-2 bg-white border d-flex align-items-center justify-content-center text-primary" style="width: 36px; height: 36px;">
                                <i class="bi bi-water"></i>
                            </div>
                            <div>
                                <label class="form-check-label fw-bold text-dark d-block mb-0" for="statusSwitch" style="font-size: 0.88rem; cursor: pointer;">
                                    Activate auto-irrigation
                                </label>
                                <small class="text-muted" style="font-size: 0.75rem;">
                                    Auto pump when soil moisture is below minimum threshold
                                </small>
                            </div>
                        </div>
                        <div class="form-check form-switch m-0 p-0">

                            <input class="form-check-input m-0" type="checkbox" id="statusSwitch" name="status" ${(pot == null || pot.status) ? 'checked' : ''}>
                        </div>
                    </div>
                </div>
                

                <div class="d-flex justify-content-between align-items-center pt-2 border-top border-light">
                    <a href="${pageContext.request.contextPath}/pots" class="btn-cancel-action">
                        <i class="bi bi-arrow-left"></i> <span>Back to list</span>
                    </a>
                    <button type="submit" class="btn-save-action">
                        <i class="bi bi-check2-circle"></i> <span>Save information</span>
                    </button>
                </div>
                
            </form>
        </div>
    </div>


    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>