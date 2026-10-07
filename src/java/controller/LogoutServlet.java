package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "LogoutServlet", urlPatterns = {"/logout"})
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy session hiện tại (truyền false để không tạo session mới nếu chưa có)
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            // Hủy toàn bộ dữ liệu trong session (bao gồm LOGIN_USER)
            session.invalidate();
        }
        
        // Chuyển hướng về trang đăng nhập
        response.sendRedirect(request.getContextPath() + "/login");
    }
}