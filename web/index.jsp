<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Smart Irrigation System</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="css/index.css">
</head>
<body>

<!-- ================= NAVBAR ================= -->
<header class="navbar">
    <div class="container navbar-inner">

        <a href="<%= request.getContextPath() %>/index.jsp" class="brand">
            <div class="brand-logo">
                <svg class="icon icon-md" viewBox="0 0 24 24">
                    <path d="M12 21a9.004 9.004 0 008.716-6.747M12 21a9.004 9.004 0 01-8.716-6.747M12 21V12m0 0a4 4 0 014-4h.5a4.5 4.5 0 014.5 4.5c0 2.4-1.8 4.3-4.2 4.5M12 12a4 4 0 00-4-4h-.5a4.5 4.5 0 00-4.5 4.5c0 2.4 1.8 4.3 4.2 4.5"/>
                </svg>
            </div>
            <span class="brand-name">Smart Irrigation System</span>
        </a>

        <nav class="nav" id="mainNav" aria-label="Main navigation">
            <a href="<%= request.getContextPath() %>/index.jsp" class="active">Home</a>
            <a href="#features">Features</a>
            <a href="#about">About</a>
        </nav>
        <div class="nav-actions">
            <% if (session.getAttribute("LOGIN_USER") != null) { %>
                <a href="<%= request.getContextPath() %>/dashboard" class="btn-signup">Dashboard</a>
                <a href="<%= request.getContextPath() %>/logout" class="btn-login">Logout</a>
            <% } else { %>
                <a href="<%= request.getContextPath() %>/login" class="btn-login">Login</a>
                <a href="<%= request.getContextPath() %>/register" class="btn-signup">Sign Up</a>
            <% } %>
        </div>
    </div>
</header>


<!-- ================= HERO ================= -->
<section class="hero">
    <div class="hero-glow hero-glow-1"></div>
    <div class="hero-glow hero-glow-2"></div>

    <div class="container">
        <div class="hero-grid">

            <div class="hero-copy">

                <div class="hero-badge">
                    <svg class="icon icon-sm" viewBox="0 0 24 24">
                        <path d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"/>
                    </svg>
                    <span>Smart Agriculture Technology</span>
                </div>

                <h1 class="hero-title">
                    Smart Irrigation
                    <span class="text-gradient">For Better Plants</span>
                </h1>

                <p class="hero-description">
                    Monitor your plants, manage irrigation,
                    save water and make smarter decisions
                    with our Smart Irrigation System.
                </p>

                <div class="hero-buttons">
                    <a href="#features" class="btn btn-primary">
                        Explore Features
                        <svg class="icon icon-sm" viewBox="0 0 24 24">
                            <path d="M14 5l7 7m0 0l-7 7m7-7H3"/>
                        </svg>
                    </a>

                    <% if (session.getAttribute("LOGIN_USER") != null) { %>
                        <a href="<%= request.getContextPath() %>/dashboard" class="btn btn-light">Open Dashboard</a>
                    <% } else { %>
                        <a href="<%= request.getContextPath() %>/login" class="btn btn-light">Login</a>
                    <% } %>
                </div>

            </div>


            <!-- Dashboard preview -->
            <div class="hero-dashboard">
                <div class="dashboard-preview">

                    <div class="preview-header">
                        <div class="preview-title">
                            <div class="icon-box icon-box-36 tone-emerald">
                                <svg class="icon icon-md" viewBox="0 0 24 24">
                                    <path d="M12 19V6m0 0a6 6 0 00-6 6h6m0-6a6 6 0 016 6h-6"/>
                                </svg>
                            </div>
                            <h3>Smart Garden</h3>
                        </div>

                        <span class="online">
                            <span class="live-dot">
                                <span class="live-dot-ping"></span>
                                <span class="live-dot-core"></span>
                            </span>
                            Online
                        </span>
                    </div>

                    <div class="preview-data">

                        <div class="preview-item">
                            <div class="icon-box tone-red">
                                <svg class="icon icon-sm" viewBox="0 0 24 24">
                                    <path d="M12 9v3m0 0a3 3 0 103 3V6a3 3 0 10-6 0v9a3 3 0 003-3z"/>
                                </svg>
                            </div>
                            <p>Temperature</p>
                            <strong>
                                <span id="temperature">28</span>
                                <span class="unit">°C</span>
                            </strong>
                        </div>

                        <div class="preview-item blue">
                            <div class="icon-box tone-blue">
                                <svg class="icon icon-sm" viewBox="0 0 24 24">
                                    <path d="M12 2.69l5.66 5.66a8 8 0 11-11.31 0z"/>
                                </svg>
                            </div>
                            <p>Humidity</p>
                            <strong>
                                <span id="humidity">67</span>
                                <span class="unit">%</span>
                            </strong>
                        </div>

                        <div class="preview-item">
                            <div class="icon-box tone-emerald">
                                <svg class="icon icon-sm" viewBox="0 0 24 24">
                                    <path d="M12 18v-5m0 0a3 3 0 003-3 3 3 0 00-3-3 3 3 0 00-3 3 3 3 0 003 3z"/>
                                </svg>
                            </div>
                            <p>Soil Moisture</p>
                            <strong>
                                <span id="moisture">73</span>
                                <span class="unit">%</span>
                            </strong>
                        </div>

                    </div>

                    <div class="pump-status">
                        <div class="pump-info">
                            <div class="icon-box tone-sky">
                                <svg class="icon icon-sm" viewBox="0 0 24 24">
                                    <path d="M13 10V3L4 14h7v7l9-11h-7z"/>
                                </svg>
                            </div>
                            <span class="pump-name">Irrigation Pump</span>
                        </div>

                        <span class="status success">Ready</span>
                    </div>

                </div>
            </div>

        </div>
    </div>
</section>


<!-- ================= ABOUT ================= -->
<section class="section about" id="about">
    <div class="container">

        <div class="section-title">
            <p class="section-label">About the system</p>
            <h2>Smarter Watering, Healthier Plants</h2>
            <p>
                Our Smart Irrigation System uses sensors and automation
                to monitor environmental conditions and help optimize irrigation.
            </p>
        </div>

        <div class="about-grid">

            <div class="about-card tone-emerald">
                <div class="icon-box about-icon">
                    <svg class="icon icon-xl" viewBox="0 0 24 24">
                        <path d="M12 19V6m0 0a6 6 0 00-6 6h6m0-6a6 6 0 016 6h-6"/>
                    </svg>
                </div>
                <h3>Plant Management</h3>
                <p>Monitor important environmental conditions affecting plant growth.</p>
            </div>

            <div class="about-card tone-sky">
                <div class="icon-box about-icon">
                    <svg class="icon icon-xl" viewBox="0 0 24 24">
                        <path d="M12 2.69l5.66 5.66a8 8 0 11-11.31 0z"/>
                    </svg>
                </div>
                <h3>Water Management</h3>
                <p>Manage irrigation activities and reduce unnecessary water usage.</p>
            </div>

            <div class="about-card tone-purple">
                <div class="icon-box about-icon">
                    <svg class="icon icon-xl" viewBox="0 0 24 24">
                        <path d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                    </svg>
                </div>
                <h3>Smart Prediction</h3>
                <p>Use data and machine learning to support irrigation decisions.</p>
            </div>

        </div>
    </div>
</section>


<!-- ================= FEATURES ================= -->
<section class="section features" id="features">
    <div class="container">

        <div class="section-title">
            <p class="section-label">System features</p>
            <h2>Everything You Need</h2>
            <p>Manage your smart irrigation system from one place.</p>
        </div>

        <div class="feature-grid">

            <div class="feature-card">
                <div class="icon-box feature-icon tone-amber">
                    <svg class="icon icon-lg" viewBox="0 0 24 24">
                        <path d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                    </svg>
                </div>
                <h3>Sensor Monitoring</h3>
                <p>Monitor temperature, humidity, soil moisture and other sensor data.</p>
                <a href="<%= request.getContextPath() %>/sensor-data">View Sensors →</a>
            </div>

            <div class="feature-card">
                <div class="icon-box feature-icon tone-sky">
                    <svg class="icon icon-lg" viewBox="0 0 24 24">
                        <path d="M12 2.69l5.66 5.66a8 8 0 11-11.31 0z"/>
                    </svg>
                </div>
                <h3>Irrigation Management</h3>
                <p>Manage watering activities and irrigation schedules.</p>
                <a href="<%= request.getContextPath() %>/manual-water">Manage Irrigation →</a>
            </div>

            <div class="feature-card">
                <div class="icon-box feature-icon tone-emerald">
                    <svg class="icon icon-lg" viewBox="0 0 24 24">
                        <path d="M12 19V6m0 0a6 6 0 00-6 6h6m0-6a6 6 0 016 6h-6"/>
                    </svg>
                </div>
                <h3>Plant Management</h3>
                <p>Store information about plants, locations and watering requirements.</p>
                <a href="<%= request.getContextPath() %>/plants">Manage Plants →</a>
            </div>

            <div class="feature-card">
                <div class="icon-box feature-icon tone-rose">
                    <svg class="icon icon-lg" viewBox="0 0 24 24">
                        <path d="M7 12l3-3 3 3 4-4M8 21l4-4 4 4M3 4h18M4 4h16v12a2 2 0 01-2 2H6a2 2 0 01-2-2V4z"/>
                    </svg>
                </div>
                <h3>Reports</h3>
                <p>Analyze water usage and irrigation performance.</p>
                <a href="<%= request.getContextPath() %>/reports">View Reports →</a>
            </div>

            <div class="feature-card">
                <div class="icon-box feature-icon tone-amber">
                    <svg class="icon icon-lg" viewBox="0 0 24 24">
                        <path d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
                    </svg>
                </div>
                <h3>Alert Management</h3>
                <p>Review important notifications across your gardens.</p>
                <a href="<%= request.getContextPath() %>/alerts">View Alerts →</a>
            </div>

            <div class="feature-card">
                <div class="icon-box feature-icon tone-purple">
                    <svg class="icon icon-lg" viewBox="0 0 24 24">
                        <path d="M3 12a9 9 0 109-9 9.75 9.75 0 00-6.74 2.74L3 8M3 3v5h5M12 7v5l4 2"/>
                    </svg>
                </div>
                <h3>Water History</h3>
                <p>Review past watering sessions and water usage.</p>
                <a href="<%= request.getContextPath() %>/history">View History →</a>
            </div>

        </div>
    </div>
</section>


<!-- ================= STATISTICS ================= -->
<section class="statistics">
    <div class="container">
        <div class="statistics-grid">

            <div class="stat-item">
                <strong><span class="counter" data-target="95">0</span>%</strong>
                <p>Water Efficiency</p>
            </div>

            <div class="stat-item">
                <strong>24/7</strong>
                <p>System Monitoring</p>
            </div>

            <div class="stat-item">
                <strong><span class="counter" data-target="40">0</span>%</strong>
                <p>Potential Water Saving</p>
            </div>

            <div class="stat-item">
                <strong>100%</strong>
                <p>Smart Automation</p>
            </div>

        </div>
    </div>
</section>


<!-- ================= FOOTER ================= -->
<footer class="footer">
    <div class="container footer-inner">

        <div class="footer-brand">
            <div class="footer-brand-row">
                <div class="footer-logo">
                    <svg class="icon icon-sm" viewBox="0 0 24 24">
                        <path d="M12 21a9.004 9.004 0 008.716-6.747M12 21a9.004 9.004 0 01-8.716-6.747M12 21V12m0 0a4 4 0 014-4h.5a4.5 4.5 0 014.5 4.5c0 2.4-1.8 4.3-4.2 4.5M12 12a4 4 0 00-4-4h-.5a4.5 4.5 0 00-4.5 4.5c0 2.4 1.8 4.3 4.2 4.5"/>
                    </svg>
                </div>
                <span class="footer-name">Smart Irrigation System</span>
            </div>
            <p class="footer-description">
                Smart technology for better irrigation and healthier plants.
            </p>
        </div>

        <p class="footer-copyright">© 2026 Smart Irrigation System</p>

    </div>
</footer>

<script src="js/index.js"></script>

</body>
</html>
