package filter;

import model.AppUser; 

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        
        // Lấy đường dẫn chính xác (bỏ qua tên project ở đầu)
        String path = req.getRequestURI();
        String contextPath = req.getContextPath();
        String command = path.substring(contextPath.length()); 
        
        // 1. Cho phép các đường dẫn công khai (Public)
        if (command.startsWith("/login") || command.startsWith("/css/") || 
            command.startsWith("/js/") || command.startsWith("/images/")) {
            chain.doFilter(request, response);
            return;
        }
        
        // 2. Kiểm tra Authentication (Đã đăng nhập chưa?)
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("LOGIN_USER") == null) {
            res.sendRedirect(contextPath + "/login");
            return;
        }
        
        // 3. Lấy thông tin User để làm Authorization (Phân quyền RBAC)
        AppUser user = (AppUser) session.getAttribute("LOGIN_USER");
        int roleId = user.getRoleId(); // Tùy Database, có thể là 1, 2, 3, 4, 5 hoặc dùng getRoleName()
        
        // 4. Ma trận phân quyền theo URL
        boolean isAllowed = false;
        
        // Luật 0: Bất kỳ ai đã đăng nhập đều được xem Dashboard và được Đăng xuất
        if (command.equals("/dashboard") || command.startsWith("/logout")) {
            isAllowed = true;
        } 
        // Luật 1: ADMIN (Role 1) - Có toàn quyền truy cập hệ thống
        else if (roleId == 1) {
            isAllowed = true;
        }
        // Luật 2: MANAGER (Role 2) - Quản lý Cây, Chậu, Lịch tưới
        else if (roleId == 2 && (command.startsWith("/plants") || command.startsWith("/pots") || command.startsWith("/schedules"))) {
            isAllowed = true;
        }
        // Luật 3: TECHNICIAN (Role 3) - Cảm biến, Máy bơm
        else if (roleId == 3 && (command.startsWith("/sensors") || command.startsWith("/pumps"))) {
            isAllowed = true;
        }
        // Luật 4: STAFF (Role 4) - Tưới thủ công, Cảnh báo sự cố
        else if (roleId == 4 && (command.startsWith("/manual-water") || command.startsWith("/alerts"))) {
            isAllowed = true;
        }
        // Luật 5: VIEWER (Role 5) - Chỉ được xem, nếu cố gõ link khác sẽ rơi vào isAllowed = false

        // 5. Chốt chặn cuối cùng
        if (isAllowed) {
            chain.doFilter(request, response); // Hợp lệ -> Cho đi tiếp vào Servlet
        } else {
            // Cố tình truy cập trái phép -> Trả về Dashboard kèm thông báo lỗi mượt mà
            session.setAttribute("ERROR_MSG", "Access Denied: You don't have permission to view this page.");
            res.sendRedirect(contextPath + "/dashboard");
        }
    }

    @Override
    public void destroy() {
    }
}