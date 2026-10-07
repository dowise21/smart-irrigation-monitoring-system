package filter;

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

// Cấu hình URL /* nghĩa là Filter này sẽ chặn MỌI đường dẫn trên website
@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Khởi tạo Filter (không cần viết gì ở đây cho bài toán này)
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        // Ép kiểu request và response sang dạng HTTP để dùng các hàm của Web
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        
        // Lấy đường dẫn hiện tại mà người dùng đang muốn truy cập
        String path = req.getRequestURI();
        
        // 1. Cho phép các đường dẫn công khai (không cần đăng nhập) đi qua luôn
        // Bao gồm: trang đăng nhập, các file css, js, hình ảnh (để giao diện không bị vỡ)
        if (path.endsWith("/login") || path.contains("/css/") || path.contains("/js/")) {
            chain.doFilter(request, response); // Đi tiếp
            return;
        }
        
        // 2. Đối với các trang khác, kiểm tra Session xem đã đăng nhập chưa
        HttpSession session = req.getSession(false); // getSession(false) để không tự động tạo session mới
        boolean isLoggedIn = (session != null && session.getAttribute("LOGIN_USER") != null);
        
        if (isLoggedIn) {
            // Đã đăng nhập -> Cho phép đi tiếp vào Servlet tương ứng (như DashboardServlet)
            chain.doFilter(request, response);
        } else {
            // Chưa đăng nhập -> Chuyển hướng ép quay về trang đăng nhập
            res.sendRedirect(req.getContextPath() + "/login");
        }
    }

    @Override
    public void destroy() {
        // Hủy Filter
    }
}