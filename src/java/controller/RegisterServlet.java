package controller;

import dao.UserDAO;
import java.io.IOException;
import java.util.Locale;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.AppUser;
import util.PasswordUtil;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private static final String FLASH_OK = "REGISTER_FLASH_OK";
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Flash message from a previous successful POST (Post-Redirect-Get)
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute(FLASH_OK) != null) {
            request.setAttribute("successMessage", session.getAttribute(FLASH_OK));
            session.removeAttribute(FLASH_OK);
        }
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email")).toLowerCase(Locale.ROOT);
        String password = request.getParameter("password");
        String confirm = request.getParameter("confirmPassword");

        if (fullName.isEmpty() || email.isEmpty() || password == null || confirm == null) {
            respond(request, response, false, "Please fill in all required fields.");
            return;
        }
        if (fullName.length() > 100 || email.length() > 100) {
            respond(request, response, false, "Name and email must be at most 100 characters.");
            return;
        }
        if (!email.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            respond(request, response, false, "Please enter a valid email address.");
            return;
        }
        if (password.length() < 8) {
            respond(request, response, false, "Use a password with at least 8 characters.");
            return;
        }
        if (!password.equals(confirm)) {
            respond(request, response, false, "The passwords do not match.");
            return;
        }
        if (userDAO.checkEmailExists(email, 0)) {
            respond(request, response, false, "An account with this email address already exists.");
            return;
        }

        String baseUsername = email.contains("@") ? email.substring(0, email.indexOf('@')) : email;
        baseUsername = baseUsername.replaceAll("[^a-zA-Z0-9._-]", "");
        if (baseUsername.isEmpty()) {
            baseUsername = "user";
        }
        String username = baseUsername;
        int suffix = 1;
        while (userDAO.checkUsernameExists(username, 0)) {
            suffix++;
            username = baseUsername + suffix;
        }

        AppUser newUser = new AppUser();
        newUser.setUsername(username);
        newUser.setPasswordHash(PasswordUtil.hash(password));
        newUser.setFullName(fullName);
        newUser.setEmail(email);
        newUser.setRoleId(5); // Default least-privilege role (VIEWER) for self-registered accounts
        newUser.setStatus(true);

        int id = userDAO.insert(newUser);
        if (id <= 0) {
            respond(request, response, false, "Could not create account. Please try again.");
            return;
        }

        respond(request, response, true, "Account created! You can now sign in with " + email + " (or username: " + username + ").");
    }

    private void respond(HttpServletRequest request, HttpServletResponse response, boolean ok, String message)
            throws ServletException, IOException {
        if (ApiSupport.isAjax(request)) {
            if (ok) {
                ApiSupport.ok(response, message);
            } else {
                ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, message);
            }
            return;
        }
        if (ok) {
            // PRG: never render a success page directly from POST
            request.getSession().setAttribute(FLASH_OK, message);
            response.sendRedirect(request.getContextPath() + "/register");
            return;
        }
        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    private static String trim(String s) {
        return s == null ? "" : s.trim();
    }
}

