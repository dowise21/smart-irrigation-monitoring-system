<%@page contentType="text/html" pageEncoding="UTF-8" isErrorPage="true"%>
<%
    Object _statusObj = request.getAttribute("javax.servlet.error.status_code");
    int _status = _statusObj instanceof Integer ? (Integer) _statusObj : 500;
    String _ctx = request.getContextPath();
    String _title;
    String _message;
    switch (_status) {
        case 401:
            _title = "Sign in required";
            _message = "Please sign in to continue.";
            break;
        case 403:
            _title = "Access denied";
            _message = "Your role does not have permission to open this page.";
            break;
        case 404:
            _title = "Page not found";
            _message = "We could not find the page you are looking for.";
            break;
        default:
            _title = "Something went wrong";
            _message = "An unexpected error occurred. Please try again; the technical details were logged for the administrator.";
    }
    if (!response.isCommitted()) {
        response.setStatus(_status);
    }
    // NOTE: the exception / stack trace is intentionally never rendered to the user.
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error <%= _status %> - Smart Irrigation</title>
    <link rel="stylesheet" href="<%= _ctx %>/css/common.css">
    <link rel="stylesheet" href="<%= _ctx %>/css/error.css">
    <link rel="stylesheet" href="<%= _ctx %>/css/navbarResponsive.css?v=20261013a">
</head>
<body>

<header class="navbar">
    <div class="container">
        <a href="<%= _ctx %>/dashboard" class="logo">Smart Irrigation</a>
    </div>
</header>

<main class="error-page">
    <div>
        <div class="error-icon">🌱</div>
        <p style="font-weight:700;opacity:.6;margin:0;">Error <%= _status %></p>
        <h1><%= _title %></h1>
        <p><%= _message %></p>
        <a href="<%= _ctx %>/dashboard" class="btn btn-primary">Back to Dashboard</a>
    </div>
</main>

<footer class="footer">
    <div class="container">
        <p>© 2026 Smart Irrigation System</p>
    </div>
</footer>

</body>
</html>