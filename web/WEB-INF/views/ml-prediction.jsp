
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Prediction - Smart Irrigation System</title>
    

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
            --ai-purple: #8b5cf6;
            --ai-purple-dark: #6d28d9;
            --ai-purple-soft: #f5f3ff;
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
        .page-badge-ai {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 0.75rem;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 9999px;
            background: linear-gradient(135deg, #f5f3ff 0%, #ede9fe 100%);
            color: #7c3aed;
            border: 1px solid #ddd6fe;
            letter-spacing: 0.02em;
        }
        .pulse-purple-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background-color: #8b5cf6;
            box-shadow: 0 0 0 0 rgba(139, 92, 246, 0.7);
            animation: pulse-purple 2s infinite;
        }
        @keyframes pulse-purple {
            0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(139, 92, 246, 0.7); }
            70% { transform: scale(1); box-shadow: 0 0 0 6px rgba(139, 92, 246, 0); }
            100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(139, 92, 246, 0); }
        }
        
        /* Feature Card */
        .feature-card {
            background: #ffffff;
            border-radius: 16px;
            border: 1px solid var(--card-border);
            box-shadow: 0 4px 20px -2px rgba(15, 23, 42, 0.04);
            overflow: hidden;
            height: 100%;
        }
        .feature-card-header {
            padding: 1.15rem 1.35rem;
            background: #f8fafc;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        /* Modern Input Group with Unit Badges */
        .form-label-modern {
            font-size: 0.85rem;
            font-weight: 600;
            color: #334155;
            margin-bottom: 6px;
            display: flex;
            align-items: center;
            gap: 6px;
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
        .input-group-modern .form-control {
            height: 48px;
            border-radius: 10px !important;
            padding-left: 42px;
            padding-right: 64px;
            border: 1.5px solid #e2e8f0;
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--text-heading);
            background-color: #f8fafc;
            transition: all 0.2s ease;
        }
        .input-group-modern .form-control:focus {
            background-color: #ffffff;
            border-color: #8b5cf6;
            box-shadow: 0 0 0 4px rgba(139, 92, 246, 0.12);
        }
        .input-group-modern .form-control:focus ~ .input-icon {
            color: #8b5cf6;
        }
        .input-unit-badge {
            position: absolute;
            right: 12px;
            background: #f1f5f9;
            color: #64748b;
            font-size: 0.75rem;
            font-weight: 700;
            padding: 3px 8px;
            border-radius: 6px;
            pointer-events: none;
            z-index: 4;
            letter-spacing: 0.02em;
        }
        
        /* Run Prediction Button */
        .btn-predict-action {
            background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);
            color: #ffffff;
            border: none;
            height: 48px;
            border-radius: 9999px;
            font-weight: 700;
            font-size: 0.96rem;
            letter-spacing: 0.01em;
            box-shadow: 0 6px 18px rgba(109, 40, 217, 0.25);
            transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            width: 100%;
        }
        .btn-predict-action:hover {
            background: linear-gradient(135deg, #7c3aed 0%, #5b21b6 100%);
            color: #ffffff;
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(109, 40, 217, 0.35);
        }
        .btn-predict-action:active { transform: translateY(0); }
        
        /* Prediction Result Box */
        .result-card {
            background: #ffffff;
            border-radius: 16px;
            border: 1px solid #ddd6fe;
            box-shadow: 0 8px 30px -4px rgba(139, 92, 246, 0.08);
            overflow: hidden;
            height: 100%;
            display: flex;
            flex-direction: column;
        }
        .result-card-header {
            padding: 1.15rem 1.35rem;
            background: linear-gradient(135deg, #f5f3ff 0%, #ede9fe 100%);
            border-bottom: 1px solid #ddd6fe;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .prediction-hero-box {
            background: radial-gradient(circle at center, #f5f3ff 0%, #faf5ff 100%);
            border: 1.5px dashed #c4b5fd;
            border-radius: 16px;
            padding: 1.75rem 1.25rem;
            margin: 1.25rem 0;
            position: relative;
        }
        .predicted-time-display {
            font-size: 2rem;
            font-weight: 800;
            color: #6d28d9;
            letter-spacing: -0.02em;
            line-height: 1.2;
        }
        
        /* Modern Progress Bar */
        .progress-modern {
            height: 28px;
            border-radius: 9999px;
            background-color: #f1f5f9;
            border: 1px solid #e2e8f0;
            overflow: hidden;
            padding: 3px;
            box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.04);
        }
        .progress-bar-modern {
            background: linear-gradient(90deg, #10b981 0%, #059669 100%);
            border-radius: 9999px;
            font-weight: 700;
            font-size: 0.85rem;
            letter-spacing: 0.02em;
            box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
        }
        
        /* Features Tensor Box */
        .features-console-box {
            background-color: #0f172a;
            border-radius: 10px;
            padding: 0.75rem 1rem;
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            font-size: 0.82rem;
            color: #38bdf8;
            border: 1px solid #1e293b;
            text-align: left;
            word-break: break-all;
        }
        
        /* Empty Prediction Placeholder */
        .empty-prediction-box {
            border: 2px dashed #cbd5e1;
            border-radius: 16px;
            padding: 3.5rem 2rem;
            text-align: center;
            background-color: #f8fafc;
            height: 100%;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }
        .ai-pulse-ring {
            width: 72px;
            height: 72px;
            border-radius: 50%;
            background: #ede9fe;
            color: #8b5cf6;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 2.2rem;
            margin-bottom: 1.25rem;
            box-shadow: 0 4px 16px rgba(139, 92, 246, 0.15);
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
                        <h3 class="mb-0 fw-bold text-dark tracking-tight" style="letter-spacing: -0.02em;">AI Prediction Model for Irrigation</h3>
                        <span class="page-badge-ai">
                            <span class="pulse-purple-dot"></span> ML Inference Engine
                        </span>
                    </div>
                    <p class="text-secondary small mb-0 d-flex align-items-center gap-1">
                        <i class="bi bi-cpu text-primary"></i> 
                        <span>Machine learning algorithm analyzes moisture, flow, and light to estimate drought timing</span>
                    </p>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <span class="badge bg-light text-secondary border px-3 py-2 rounded-pill small fw-medium">
                        <i class="bi bi-layers-half text-success me-1"></i> Random Forest Regressor v1.2
                    </span>
                </div>
            </div>
            

            <div class="row g-4 align-items-stretch">

                <div class="col-lg-5">
                    <div class="feature-card">
                        <div class="feature-card-header">
                            <span class="fw-bold text-dark small text-uppercase tracking-wider d-flex align-items-center gap-2">
                                <i class="bi bi-sliders2 text-primary fs-6"></i> Input Parameters (Features)
                            </span>
                            <span class="badge bg-primary-subtle text-primary rounded-pill small px-2">Pot #1</span>
                        </div>
                        <div class="p-3 p-md-4">

                            <form action="${pageContext.request.contextPath}/predict" method="POST">
                                <input type="hidden" name="potId" value="1">
                                

                                <div class="mb-3">
                                    <label class="form-label-modern">
                                        <i class="bi bi-droplet-half text-info"></i> <span>Current soil moisture</span>
                                    </label>
                                    <div class="input-group-modern">
                                        <input type="number" step="0.1" name="moisture" class="form-control" value="${moisture != null ? moisture : 60.5}" required placeholder="VD: 60.5">
                                        <i class="bi bi-speedometer2 input-icon"></i>
                                        <span class="input-unit-badge">% RH</span>
                                    </div>
                                    <small class="text-muted" style="font-size: 0.76rem;">Actual soil moisture threshold from sensor</small>
                                </div>
                                

                                <div class="mb-3">
                                    <label class="form-label-modern">
                                        <i class="bi bi-cup-straw text-primary"></i> <span>Amount of water just watered</span>
                                    </label>
                                    <div class="input-group-modern">
                                        <input type="number" name="water" class="form-control" value="${water != null ? water : 800}" required placeholder="VD: 800">
                                        <i class="bi bi-droplet input-icon"></i>
                                        <span class="input-unit-badge">ml</span>
                                    </div>
                                    <small class="text-muted" style="font-size: 0.76rem;">Water pump capacity in the latest cycle</small>
                                </div>
                                

                                <div class="mb-4">
                                    <label class="form-label-modern">
                                        <i class="bi bi-sun-fill text-warning"></i> <span>Light intensity</span>
                                    </label>
                                    <div class="input-group-modern">
                                        <input type="number" name="light" class="form-control" value="${light != null ? light : 5000}" required placeholder="VD: 5000">
                                        <i class="bi bi-brightness-high input-icon"></i>
                                        <span class="input-unit-badge">lux</span>
                                    </div>
                                    <small class="text-muted" style="font-size: 0.76rem;">Directly affects the rate of transpiration</small>
                                </div>
                                

                                <button type="submit" class="btn-predict-action">
                                    <i class="bi bi-cpu-fill fs-5"></i> <span>Run Prediction Model</span> <i class="bi bi-arrow-right-short fs-5"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
                

                <div class="col-lg-7">

                    <c:if test="${not empty predictionResult}">
                        <div class="result-card">
                            <div class="result-card-header">
                                <span class="fw-bold text-dark small text-uppercase tracking-wider d-flex align-items-center gap-2">
                                    <i class="bi bi-stars text-primary fs-6"></i> Result Prediction (ML Output)
                                </span>
                                <span class="badge bg-success text-white rounded-pill small px-3 py-1">
                                    <i class="bi bi-check-circle-fill me-1"></i> Complete
                                </span>
                            </div>
                            <div class="p-4 d-flex flex-column justify-content-between h-100 text-center">
                                <div>
                                    <p class="text-secondary small fw-medium mb-1">
                                        Based on smart agriculture training data, the plant pot will need to be watered again at:
                                    </p>
                                    

                                    <div class="prediction-hero-box shadow-sm">
                                        <span class="badge bg-white text-primary border shadow-sm px-3 py-1 rounded-pill small fw-bold mb-2">
                                            <i class="bi bi-calendar-event me-1"></i> Next time water is needed
                                        </span>
                                        <div class="predicted-time-display my-2">
                                            <fmt:formatDate value="${predictionResult.predictedDryTime}" pattern="HH:mm - dd/MM/yyyy" />
                                        </div>
                                        <span class="text-muted small">
                                            <i class="bi bi-shield-check text-success me-1"></i> Automatically compensated for weather evaporation coefficient
                                        </span>
                                    </div>
                                    

                                    <div class="text-start mt-4 mb-3">
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <span class="fw-bold text-dark small d-flex align-items-center gap-1">
                                                <i class="bi bi-shield-fill-check text-success"></i> <span>Algorithm reliability:</span>
                                            </span>
                                            <span class="fw-bold text-success fs-6">
                                                <fmt:formatNumber value="${predictionResult.confidenceScore}" maxFractionDigits="1"/>%
                                            </span>
                                        </div>
                                        <div class="progress-modern">
                                            <div class="progress-bar-modern progress-bar-striped progress-bar-animated" role="progressbar" style="width: ${predictionResult.confidenceScore}%;">
                                                Reliability: <fmt:formatNumber value="${predictionResult.confidenceScore}" maxFractionDigits="1"/>%
                                            </span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                

                                <div class="mt-4 pt-3 border-top border-light text-start">
                                    <span class="text-muted small fw-semibold d-block mb-1">
                                        <i class="bi bi-terminal me-1"></i> Feature vector data (Features Tensor):
                                    </span>
                                    <div class="features-console-box">
                                        <code>${predictionResult.featuresUsed}</code>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:if>
                    

                    <c:if test="${empty predictionResult}">
                        <div class="empty-prediction-box">
                            <div class="ai-pulse-ring">
                                <i class="bi bi-cpu"></i>
                            </div>
                            <h5 class="fw-bold text-dark mb-1">The model is ready</h5>
                            <p class="text-muted small max-w-sm mx-auto mb-3">
                                Please fill in the environmental parameters in the form on the left and click <strong>"Run Prediction Model"</strong> for the system to infer the optimal watering time.
                            </p>
                            <span class="badge bg-light text-secondary border px-3 py-1 rounded-pill small">
                                <i class="bi bi-info-circle me-1"></i> Automatic forecast helps save up to 35% of water
                            </span>
                        </div>
                    </c:if>
                </div>
            </div>
            

            <div class="d-flex flex-column flex-sm-row justify-content-between align-items-center gap-2 mt-4 pt-2 text-muted small border-top border-light">
                <span><i class="bi bi-lightning-charge text-warning me-1"></i> Algorithm automatically retrains when there is new sensor data from the garden.</span>
                <span>Smart Irrigation AI Engine &bull; v2.4</span>
            </div>
        </div>
    </main>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>