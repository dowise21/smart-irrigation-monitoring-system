package controller;

import dao.UserDAO;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.AppUser;
import util.PasswordUtil;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LoginServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        try {
            String user = request.getParameter("username");
            if (user == null || user.trim().isEmpty()) {
                user = request.getParameter("email");
            }
            String pass = request.getParameter("password");

            if (user == null || user.trim().isEmpty() || pass == null || pass.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Please enter both username/email and password.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            UserDAO dao = new UserDAO();
            AppUser appUser = dao.findByUsername(user.trim());

            if (appUser != null) {
                if (!appUser.isStatus()) {
                    request.setAttribute("errorMessage", "Your account has been locked. Please contact an administrator.");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                    return;
                }

                String storedHash = appUser.getPasswordHash();
                if (PasswordUtil.verify(pass, storedHash)) {
                    HttpSession session = request.getSession();
                    session.setAttribute("LOGIN_USER", appUser);
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                } else {
                    request.setAttribute("errorMessage", "Invalid username/email or password.");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("errorMessage", "Invalid username/email or password.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            }

        } catch (IOException | ServletException e) {
            LOGGER.log(Level.SEVERE, "Login error: {0}", e.getMessage());
            request.setAttribute("errorMessage", "A system error occurred. Please try again later.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}