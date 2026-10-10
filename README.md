# 🌿 Smart Irrigation Monitoring System

![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=java&logoColor=white)
![JSP/Servlet](https://img.shields.io/badge/JSP_/_Servlet-007396?style=for-the-badge&logo=java&logoColor=white)
![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Bootstrap](https://img.shields.io/badge/Bootstrap_5-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white)
![IoT](https://img.shields.io/badge/IoT-NodeMCU_/_ESP32-10b981?style=for-the-badge)

**Smart Irrigation Monitoring System** là hệ thống phần mềm quản lý, giám sát và vận hành tưới tiêu tự động ứng dụng công nghệ IoT. Dự án cung cấp giải pháp SaaS (Software as a Service) giúp tối ưu hóa lượng nước tưới, theo dõi độ ẩm/ánh sáng thời gian thực và quản lý các thiết bị trạm bơm từ xa.

---

## 👥 Đội ngũ phát triển (Group 1 - PRJ301 - Fall 2026)
*   **Lê Văn Ngoan** (Backend & Database Architecture)
*   **Nguyễn Ngọc Linh** (IoT Integration & Backend Logic)
*   **Phan Duy Bảo** (Frontend UI/UX & Web Integration)

---

## 🛠 Nền tảng Công nghệ (Tech Stack)
*   **Kiến trúc:** Strict MVC2 (Model - View - Controller).
*   **Backend:** Java EE (Servlets, JSP, JSTL, EL), JDBC (PreparedStatement).
*   **Frontend:** HTML5, CSS3, JavaScript, Bootstrap 5 (Eco-Tech SaaS Design).
*   **Database:** Microsoft SQL Server (17 Tables).
*   **Hardware/IoT:** ESP32 / NodeMCU (Mô phỏng & Thực tế), Giao thức HTTP/MQTT.

---

## 🔐 Phân quyền & Tính năng (RBAC - Role Based Access Control)

Hệ thống được bảo mật thông qua `AuthorizationFilter` với 5 cấp độ phân quyền chuyên sâu:

1.  **👑 ADMIN (Quản trị hệ thống):**
    *   Có toàn quyền truy cập (Full Access). Quản lý và phân quyền tài khoản người dùng, xem nhật ký hệ thống (System Logs).
2.  **👨‍🌾 MANAGER (Quản lý vườn):**
    *   Quản lý danh mục Cây trồng (Plants), định nghĩa các ngưỡng sinh học.
    *   Quản lý Chậu/Khu vực tưới (Pots) và cấu hình Lịch tưới tự động (Cron Schedules).
3.  **🔧 TECHNICIAN (Kỹ thuật viên):**
    *   Lắp đặt và giám sát các Node Cảm biến (Sensors), hiệu chuẩn máy bơm (Pump Calibration).
4.  **👷 STAFF (Nhân viên vận hành):**
    *   Giám sát dữ liệu Telemetry thời gian thực.
    *   Kích hoạt Tưới thủ công (Manual Watering) khẩn cấp, xử lý Cảnh báo sự cố (Alerts).
5.  **👀 VIEWER (Khách tham quan):**
    *   Chỉ xem thông số trên Dashboard tổng quan. Không có quyền thêm/sửa/xóa.

---

## 💾 Cấu trúc Cơ sở dữ liệu (Database Schema)
Hệ thống sử dụng cơ sở dữ liệu chuẩn hóa gồm **17 bảng**, được chia thành 5 nhóm cốt lõi:
*   **Nhóm Phân quyền:** `AppRole`, `Permission`, `RolePermission`, `AppUser`.
*   **Nhóm Thực thể:** `Plant`, `Pot`.
*   **Nhóm IoT:** `Sensor`, `SensorReading`, `Pump`, `PumpCalibration`.
*   **Nhóm Tưới tiêu:** `WateringSchedule`, `WateringSession`, `WaterAnalysis`.
*   **Nhóm AI & Cảnh báo:** `Alert`, `AlertConfirmation`, `MLPrediction`, `SystemLog`.

> **Lưu ý:** Lược đồ E-R chi tiết và từ điển dữ liệu được lưu tại thư mục `/docs`.

---

## 🚀 Hướng dẫn Cài đặt & Khởi chạy (Installation Guide)

### 1. Yêu cầu môi trường (Prerequisites)
*   **JDK 1.8** hoặc mới hơn.
*   **Apache Tomcat 9.0**.
*   **Microsoft SQL Server** (2019 trở lên).
*   **IDE:** NetBeans 13+ (hoặc VS Code, IntelliJ IDEA, Eclipse).

### 2. Thiết lập Cơ sở dữ liệu
1.  Mở SQL Server Management Studio (SSMS).
2.  Đảm bảo **TCP/IP** đã được bật (Enable) và Port `1433` đang mở trong *SQL Server Configuration Manager*.
3.  Mở tệp `sql/PRJ_Project_17TB.sql`.
4.  Bôi đen toàn bộ và nhấn **Execute (F5)** để hệ thống tự động tạo DB `SmartIrrigationDB`, khởi tạo 17 bảng và chèn Dữ liệu mẫu (Dummy Data).

### 3. Cấu hình & Chạy dự án Web
1.  Clone repository này về máy:
    ```bash
    git clone [https://github.com/YourUsername/smart-irrigation-monitoring-system.git](https://github.com/YourUsername/smart-irrigation-monitoring-system.git)
    ```
2.  Mở Project trong NetBeans / IDE của bạn.
3.  Điều hướng đến tệp `src/java/utils/DBContext.java` và cấu hình lại chuỗi kết nối (Connection String) cho đúng với mật khẩu sa của SQL Server trên máy bạn.
    ```java
    String url = "jdbc:sqlserver://localhost:1433;databaseName=SmartIrrigationDB";
    String user = "sa";
    String pass = "your_sql_password";
    ```
4.  Click chuột phải vào Project -> Chọn **Clean and Build** -> Chọn **Run**.
5.  Truy cập trình duyệt tại: `http://localhost:8080/SmartIrrigation/login`.

### 4. Tài khoản Demo (Mật khẩu chung: `123456`)
*   Admin: `admin1`
*   Manager: `manager`
*   Technician: `tech`
*   Staff: `staff`
*   Viewer: `viewer`

---

## 📂 Cấu trúc Thư mục (Project Structure)
```text
SmartIrrigation/
├── build/                 # Thư mục build ứng dụng
├── src/java/              # Mã nguồn Java Backend
│   ├── controller/        # Các Servlet xử lý HTTP Requests
│   ├── dao/               # Data Access Objects (Tương tác DB)
│   ├── filter/            # Authorization Filter (RBAC Security)
│   ├── model/             # Models / DTOs (Java Beans)
│   └── utils/             # DBContext
├── web/                   # Mã nguồn Frontend (Views & Assets)
│   ├── css/               # Thư mục chứa app.css (SaaS Style)
│   ├── views/             # Các tệp giao diện .jsp (Plants, Pots, Sensors...)
│   └── login.jsp          # Trang đăng nhập
├── sql/                   # Chứa script khởi tạo Database
└── docs/                  # Báo cáo, Kịch bản chạy thử, Lược đồ DB
