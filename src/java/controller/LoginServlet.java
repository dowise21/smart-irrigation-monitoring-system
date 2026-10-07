package controller;

import dao.UserDAO;
import model.AppUser;
import util.PasswordUtil;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LoginServlet.class.getName());

    // Xử lý khi người dùng gõ URL truy cập trang đăng nhập (Method GET)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Chuyển hướng tới file giao diện JSP
        request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
    }

    // Xử lý khi người dùng bấm nút Submit form đăng nhập (Method POST)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // 1. Lấy dữ liệu từ form HTML
            String user = request.getParameter("username");
            String pass = request.getParameter("password");
            
            // Validate dữ liệu trống cơ bản
            if (user == null || user.trim().isEmpty() || pass == null || pass.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.");
                request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
                return;
            }

            // 2. Tìm tài khoản trong Database
            UserDAO dao = new UserDAO();
            AppUser appUser = dao.findByUsername(user.trim());
            
            // 3. Kiểm tra tài khoản có tồn tại không
            if (appUser != null) {
                
                // 4. Kiểm tra trạng thái khóa tài khoản
                if (!appUser.isStatus()) { 
                    request.setAttribute("errorMessage", "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ Admin.");
                    request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
                    return;
                }
                
                // 5. Kiểm tra mật khẩu bằng hàm verify của PasswordUtil chuẩn PBKDF2
                // Lưu ý: Đổi getPassHash() thành getPasswordHash() tùy theo getter trong Model AppUser của bạn
                String storedHash = appUser.getPasswordHash(); 
                
                if (PasswordUtil.verify(pass, storedHash)) {
                    // Mật khẩu đúng -> Khởi tạo Session
                    HttpSession session = request.getSession();
                    
                    // Lưu object User vào session để phân quyền ở các trang sau
                    session.setAttribute("LOGIN_USER", appUser);
                    
                    // Chuyển hướng người dùng vào trang Dashboard
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                } else {
                    // Sai mật khẩu
                    request.setAttribute("errorMessage", "Sai tên đăng nhập hoặc mật khẩu!");
                    request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
                }
            } else {
                // Không tìm thấy Username
                request.setAttribute("errorMessage", "Sai tên đăng nhập hoặc mật khẩu!");
                request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
            }
            
        } catch (IOException | ServletException e) {
            LOGGER.log(Level.SEVERE, "Loi trong qua trinh dang nhap: {0}", e.getMessage());
            request.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
        }
    }
}