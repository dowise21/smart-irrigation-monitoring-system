<%-- 
    Document   : footer
    Created on : Oct 10, 2026, 11:00:27 AM
    Author     : VNJ
--%>

<%@ page pageEncoding="UTF-8" %>
<style>
/* Đảm bảo toàn bộ thẻ html và body chiếm trọn màn hình */
html, body {
  height: 100%;
  margin: 0;
}

/* Áp dụng flexbox cho body để tự động căn chỉnh */
body {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

/* Các nội dung chính (ví dụ the main content container) cần kéo dãn không gian trống */
main, .main-content {
  flex: 1 0 auto;
}

/* Thiết kế cho footer */
.app-footer {
  margin-top: auto; /* Quan trọng: Đẩy footer xuống đáy màn hình */
  background: #ffffff;
  border-top: 1px solid rgba(226, 232, 240, 0.85);
  box-shadow: 0 -4px 20px -2px rgba(15, 23, 42, 0.03);
  padding: 1.5rem 0;
  color: #475569;
  font-family: 'Inter', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

.footer-container {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
}

/* Cột bên trái: Logo và tên đồ án */
.footer-left {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.5rem;
}

.footer-brand {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-weight: 700;
  font-size: 0.95rem;
  color: #0f172a;
  text-decoration: none;
}

.footer-brand:hover {
  color: #059669;
}

.brand-mini-icon {
  width: 28px;
  height: 28px;
  border-radius: 8px;
  background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%);
  color: #10b981;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 0.9rem;
  box-shadow: 0 2px 6px rgba(16, 185, 129, 0.15);
}

.footer-badge-project {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  font-size: 0.75rem;
  font-weight: 600;
  padding: 3px 9px;
  border-radius: 6px;
  background-color: #f1f5f9;
  color: #475569;
  border: 1px solid #e2e8f0;
}

/* Cột bên phải: Nút GitHub */
.footer-right {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.footer-meta-text {
  font-size: 0.8rem;
  color: #94a3b8;
}

.footer-github-link {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 6px 14px;
  border-radius: 9999px;
  background: #0f172a;
  color: #f8fafc;
  font-size: 0.82rem;
  font-weight: 600;
  text-decoration: none;
  box-shadow: 0 2px 8px rgba(15, 23, 42, 0.15);
}

.footer-github-link:hover {
  background: #1e293b;
  color: #ffffff;
}

/* Reponsive cho màn hình nhỏ */
@media (max-width: 768px) {
  .footer-container {
    flex-direction: column;
    justify-content: center;
    text-align: center;
  }
}
</style>

<footer class="app-footer">
  <div class="footer-container">
    <div class="footer-left">
      <a href="${pageContext.request.contextPath}/dashboard" class="footer-brand">
        <span class="brand-mini-icon">
          <!-- Icon giọt nước giả lập, bạn có thể thay bằng font-awesome -->
          💧
        </span>
        <span>Smart Irrigation System</span>
      </a>
      <span style="color: #94a3b8;">&bull;</span>
      <span class="footer-badge-project">
        Final Project PRJ301
      </span>
    </div>
    
    <div class="footer-right">
      <span class="footer-meta-text">
        &copy; 2026 Developed with Java Web
      </span>
      <a href="https://github.com/dowise21/smart-irrigation-monitoring-system" target="_blank" rel="noopener noreferrer" class="footer-github-link">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="currentColor" viewBox="0 0 16 16">
          <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.012 8.012 0 0 0 16 8c0-4.42-3.58-8-8-8z"/>
        </svg>
        <span>dowise21 / Repository</span>
      </a>
    </div>
  </div>
</footer>