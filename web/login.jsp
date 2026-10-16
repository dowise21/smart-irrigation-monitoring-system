<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Smart Irrigation</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="css/login.css">
    <link rel="stylesheet" href="css/navbarResponsive.css?v=20261013a">
</head>
<body>

<!-- ================= NAVBAR ================= -->
<header class="navbar">
    <div class="container">

        <a href="<%= request.getContextPath() %>/index.jsp" class="brand">
            <div class="brand-logo">
                <svg class="icon icon-md" viewBox="0 0 24 24">
                    <path d="M12 21a9.004 9.004 0 008.716-6.747M12 21a9.004 9.004 0 01-8.716-6.747M12 21V12m0 0a4 4 0 014-4h.5a4.5 4.5 0 014.5 4.5c0 2.4-1.8 4.3-4.2 4.5M12 12a4 4 0 00-4-4h-.5a4.5 4.5 0 00-4.5 4.5c0 2.4 1.8 4.3 4.2 4.5"/>
                </svg>
            </div>
            <span class="brand-name">Smart Irrigation System</span>
        </a>

        <div class="nav-actions">
            <span class="nav-hint">New here?</span>
            <a href="<%= request.getContextPath() %>/register" class="btn-signup">Sign Up</a>
        </div>

    </div>
</header>


<!-- ================= LOGIN ================= -->
<section class="login-page">

    <div class="login-wrapper">

        <!-- Cột ảnh bên trái -->
        <aside class="login-visual">

            <div class="visual-top">
                <span class="visual-badge">Smart Agriculture Technology</span>

                <h2 class="visual-title">
                    Grow smarter,
                    <span>water less.</span>
                </h2>

                <p class="visual-text">
                    Monitor your plants, automate irrigation and make
                    data-driven decisions from one dashboard.
                </p>

                <ul class="visual-list">
                    <li>Real-time sensor monitoring</li>
                    <li>Automated irrigation scheduling</li>
                    <li>Machine learning predictions</li>
                </ul>
            </div>

            <div class="visual-stat">
                <strong>40%</strong>
                <span>Potential water saving with smart irrigation</span>
            </div>

        </aside>


        <!-- Form bên phải -->
        <div class="login-box">

            <div class="login-header">

                <div class="login-icon">
                    <svg class="icon icon-lg" viewBox="0 0 24 24">
                        <path d="M12 21a9.004 9.004 0 008.716-6.747M12 21a9.004 9.004 0 01-8.716-6.747M12 21V12m0 0a4 4 0 014-4h.5a4.5 4.5 0 014.5 4.5c0 2.4-1.8 4.3-4.2 4.5M12 12a4 4 0 00-4-4h-.5a4.5 4.5 0 00-4.5 4.5c0 2.4 1.8 4.3 4.2 4.5"/>
                    </svg>
                </div>

                <h1>Smart Irrigation System</h1>

                <p>Please enter your details.</p>

            </div>

            <% if (request.getAttribute("errorMessage") != null) { %>
                <p class="form-error" role="alert"><%= request.getAttribute("errorMessage") %></p>
            <% } %>

            <form id="loginForm" action="<%= request.getContextPath() %>/login" method="post">

                <div class="form-group">
                    <label for="username">Username or Email</label>
                    <input
                        type="text"
                        id="username"
                        name="username"
                        placeholder="Enter your username or email"
                        autocomplete="username"
                        required>
                </div>


                <div class="form-group">
                    <label for="password">Password</label>

                    <div class="input-wrap">
                        <input
                            type="password"
                            id="password"
                            name="password"
                            placeholder="Enter your password"
                            autocomplete="current-password"
                            required>

                        <button type="button"
                                class="toggle-password"
                                aria-label="Show password">
                            <svg class="icon icon-md" viewBox="0 0 24 24">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                                <circle cx="12" cy="12" r="3"/>
                            </svg>
                        </button>
                    </div>
                </div>


                <div class="form-options">
                    <label class="remember">
                        <input type="checkbox" name="remember">
                        Remember me
                    </label>

                    <a href="#">Forgot password?</a>
                </div>


                <button type="submit" class="btn btn-primary login-button">
                    Sign in
                </button>

            </form>


            <div class="divider"><span>or</span></div>


            <button type="button" id="googleLogin" class="btn-google">
                <svg viewBox="0 0 48 48" aria-hidden="true">
                    <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
                    <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
                    <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
                    <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
                </svg>
                Sign in with Google
            </button>


            <div class="login-footer">

                <p>
                    Don't have an account?
                    <a href="<%= request.getContextPath() %>/register">Sign Up</a>
                </p>

                <a href="<%= request.getContextPath() %>/index.jsp" class="back-home">
                    <svg class="icon icon-sm" viewBox="0 0 24 24">
                        <path d="M10 19l-7-7m0 0l7-7m-7 7h18"/>
                    </svg>
                    Back to home
                </a>

            </div>

        </div>

    </div>

</section>


<!-- ================= FOOTER ================= -->
<footer class="footer">
    <div class="container">
        <p>© 2026 Smart Irrigation System</p>
    </div>
</footer>


<script src="js/login.js"></script>

<script>
    // Ẩn / hiện mật khẩu
    document.querySelector('.toggle-password').addEventListener('click', function () {
        var input = document.getElementById('password');
        var show = input.type === 'password';
        input.type = show ? 'text' : 'password';
        this.setAttribute('aria-label', show ? 'Hide password' : 'Show password');
    });
</script>

</body>
</html>
