<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Create Account - Smart Irrigation</title>
	<link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
	<link rel="stylesheet" href="css/login.css">
	<link rel="stylesheet" href="css/register.css">
	<link rel="stylesheet" href="css/navbarResponsive.css?v=20261013a">
</head>
<body>
<header class="navbar">
	<div class="container">
		<a href="<%= request.getContextPath() %>/index.jsp" class="brand">
			<div class="brand-logo">
				<svg class="icon icon-md" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 21a9.004 9.004 0 008.716-6.747M12 21a9.004 9.004 0 01-8.716-6.747M12 21V12m0 0a4 4 0 014-4h.5a4.5 4.5 0 014.5 4.5c0 2.4-1.8 4.3-4.2 4.5M12 12a4 4 0 00-4-4h-.5A4.5 4.5 0 003 12.5c0 2.4 1.8 4.3 4.2 4.5"/></svg>
			</div>
			<span class="brand-name">Smart Irrigation System</span>
		</a>
		<div class="nav-actions">
			<span class="nav-hint">Already have an account?</span>
			<a href="<%= request.getContextPath() %>/login" class="btn-login">Sign in</a>
		</div>
	</div>
</header>

<main class="login-page register-page">
	<div class="login-wrapper">
		<aside class="login-visual">
			<div class="visual-top">
				<span class="visual-badge">Smart Agriculture Technology</span>
				<h2 class="visual-title">Grow smarter,<span>water less.</span></h2>
				<p class="visual-text">Create an account to manage gardens, monitor sensors and plan efficient irrigation.</p>
				<ul class="visual-list">
					<li>Track garden conditions</li>
					<li>Manage watering schedules</li>
					<li>Review water usage</li>
				</ul>
			</div>
			<div class="visual-stat"><strong>24/7</strong><span>Garden monitoring and irrigation insights</span></div>
		</aside>

		<section class="login-box register-box" aria-labelledby="registerTitle">
			<div class="login-header">
				<div class="login-icon" aria-hidden="true">
					<svg class="icon icon-lg" viewBox="0 0 24 24"><path d="M16 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2m6-10a4 4 0 100-8 4 4 0 000 8zm10 2v6m3-3h-6"/></svg>
				</div>
				<h1 id="registerTitle">Create your account</h1>
				<p>Enter your details to get started.</p>
			</div>

			<form id="registerForm" action="<%= request.getContextPath() %>/register" method="post" novalidate>
				<div class="form-group">
					<label for="fullName">Full name</label>
					<input id="fullName" name="fullName" type="text" autocomplete="name" maxlength="80" placeholder="Your name" required>
				</div>
				<div class="form-group">
					<label for="registerEmail">Email address</label>
					<input id="registerEmail" name="email" type="email" autocomplete="email" maxlength="254" placeholder="you@example.com" required>
				</div>
				<div class="form-group">
					<label for="registerPassword">Password</label>
					<div class="input-wrap">
						<input id="registerPassword" name="password" type="password" autocomplete="new-password" minlength="8" placeholder="At least 8 characters" required>
						<button type="button" class="toggle-password" data-toggle-password="registerPassword" aria-label="Show password">
							<svg class="icon icon-md" viewBox="0 0 24 24" aria-hidden="true"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
						</button>
					</div>
				</div>
				<div class="form-group">
					<label for="confirmPassword">Confirm password</label>
					<div class="input-wrap">
						<input id="confirmPassword" name="confirmPassword" type="password" autocomplete="new-password" minlength="8" placeholder="Re-enter your password" required>
						<button type="button" class="toggle-password" data-toggle-password="confirmPassword" aria-label="Show password">
							<svg class="icon icon-md" viewBox="0 0 24 24" aria-hidden="true"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
						</button>
					</div>
				</div>
				<label class="register-terms" for="acceptTerms">
					<input id="acceptTerms" name="terms" type="checkbox" required>
					<span>I agree to the terms of service and privacy policy.</span>
				</label>
				<p class="register-message" id="registerMessage" role="status" aria-live="polite" hidden></p>
				<button type="submit" class="btn btn-primary login-button">Create account</button>
			</form>

			<div class="login-footer">
				<p>Already registered? <a href="<%= request.getContextPath() %>/login">Sign in</a></p>
				<a href="<%= request.getContextPath() %>/index.jsp" class="back-home">Back to home</a>
			</div>
		</section>
	</div>
</main>

<footer class="footer">
	<div class="container"><p>© 2026 Smart Irrigation System</p></div>
</footer>

<script src="js/register.js?v=20261016a"></script>
</body>
</html>
