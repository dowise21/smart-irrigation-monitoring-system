# 🌿 Smart Irrigation Monitoring & IoT Control System

![Java](https://img.shields.io/badge/Java_EE-ED8B00?style=for-the-badge&logo=java&logoColor=white)
![JSP/Servlet](https://img.shields.io/badge/JSP_/_Servlet-007396?style=for-the-badge&logo=java&logoColor=white)
![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![ESP8266](https://img.shields.io/badge/IoT-ESP8266_NodeMCU-10b981?style=for-the-badge&logo=espressif&logoColor=white)
![Google Apps Script](https://img.shields.io/badge/Alert_Email-Google_Apps_Script-4285F4?style=for-the-badge&logo=google&logoColor=white)

**Smart Irrigation Monitoring & IoT Control System** là hệ thống phần mềm quản lý, giám sát và điều khiển tưới cây thông minh thời gian thực kết hợp giữa **Java Web Backend (JSP/Servlet + SQL Server)** và phần cứng **Vi điều khiển ESP8266 NodeMCU**. Hệ thống quản lý minh bạch theo phân cấp **Khu vực (`Area`) $\rightarrow$ Chậu cây (`Pot`) $\rightarrow$ Loại cây trồng (`Plant`)**, tự động hóa tưới tiêu theo ngưỡng độ ẩm linh hoạt của từng loài cây, hỗ trợ chuyển đổi linh hoạt máy bơm vật lý giữa nhiều chậu khi demo, và cảnh báo sự cố toàn diện qua Web + Email.

---

## 👥 Đội ngũ phát triển (Group 1 - PRJ301 - Fall 2026)
*   **Lê Văn Ngoan** — Backend & Database Architecture
*   **Nguyễn Ngọc Linh** — IoT Firmware, Hardware Integration & Alert Logic
*   **Phan Duy Bảo** — Frontend UI/UX (Executive Data-First Design) & Web Integration

---

## ✨ Điểm Nổi Bật Của Hệ Thống (Key Highlights)

### 1. Minh bạch thực thể 3 tầng: `Area` $\rightarrow$ `Pot` $\rightarrow$ `Plant` (Quy tắc 1 Chậu = 1 Loại Cây)
*   **`Area` (Khu vực):** Quản lý vị trí không gian vật lý (VD: *Khu A - Ban công Tầng 2*, *Khu B - Sân thượng Tầng 3*, *Khu C - Hiên nhà & Nội thất*).
*   **`Pot` (Chậu cây / Trạm Node IoT):** Mỗi chậu thuộc về 1 khu vực (`area_id`) và gắn với **duy nhất 1 loại cây trồng** (`plant_id`).
*   **`Plant` (Cây trồng):** Lưu thông tin sinh học, lượng nước tưới tiêu chuẩn (`water_requirement`) và bộ ngưỡng độ ẩm riêng biệt (`min_moisture_threshold`, `max_moisture_threshold`).

### 2. Ngưỡng Tưới Tự Động Động (Flexible Auto-Watering Thresholds)
*   Loại bỏ hoàn toàn việc hardcode độ ẩm trên vi điều khiển.
*   Mỗi loại cây có ngưỡng kích hoạt tưới (`min_moisture_threshold`) và ngưỡng cảnh báo ngập úng (`max_moisture_threshold`) riêng (VD: *Nha Đam 30–60%*, *Cúc Họa Mi 45–75%*, *Lan Hồ Điệp 50–70%*, *Trầu Bà Vàng 55–80%*).
*   Khi người dùng chỉnh sửa ngưỡng trên trang **Plants & Pots (`/plants`)** hoặc kéo thanh trượt trên **Dashboard (`/dashboard`)**, giá trị mới được lưu xuống SQL Server và đồng bộ tức thì xuống mạch **ESP8266** trong chu kỳ 1 giây tiếp theo.

### 3. Gán Mạch ESP8266 & Máy Bơm Vật Lý Động (Dynamic Hardware Binding)
Giải quyết bài toán thực tế khi thuyết trình: **Chỉ có 1 bộ mạch ESP8266 + 1 bộ cảm biến + 1 máy bơm thật nhưng muốn demo cho nhiều chậu cây khác nhau mà không cần nạp lại code Arduino**:
*   **Cách 1 (1-Click trên Web UI):** Bấm nút **`🔌 Gán Bơm`** trên bất kỳ thẻ chậu nào tại `/plants`, `/dashboard` hoặc `/manual-water`. Toàn bộ dữ liệu cảm biến từ ESP8266 và lệnh bật/tắt bơm lập tức ánh xạ sang chậu đó.
*   **Cách 2 (Tự động bám theo lệnh Tưới):** Bấm nút **`Water` / `Start Pump`** ở bất kỳ chậu nào trên Web, máy bơm vật lý duy nhất sẽ tự động chạy và ghi nhận lịch sử cho đúng chậu đó.
*   **Cách 3 (Đổi nhanh qua Serial Monitor):** Gõ số thứ tự chậu (`1`, `2`, `3`, `4`...) trực tiếp vào cửa sổ Serial Monitor (115200 baud) của Arduino IDE rồi nhấn Enter.

### 4. Hệ Thống 4 Cảnh Báo Sự Cố Toàn Diện (Web Alert Center + Gmail)
Kết hợp xử lý tại biên (ESP8266) và phân tích lịch sử trên Backend (`AlertService.java`), tự động gửi Email qua **Google Apps Script**:
1.  **Cảnh báo Khô hạn (`DRY_STRESS`):** Khi `moisture < min_moisture_threshold` $\rightarrow$ Tạo cảnh báo đỏ, gửi Email và **tự động xếp lệnh `START` bật máy bơm (`AUTO`)**.
2.  **Cảnh báo Lỗi cảm biến (`SENSOR_FAULT`):** Khi đứt dây hoặc mất tín hiệu từ **DHT11** (`NaN`) hoặc **Loadcell HX711** (`< -500` qua cơ chế chống treo `wait_ready_timeout`) $\rightarrow$ Cảnh báo kiểm tra phần cứng tức thì.
3.  **Cảnh báo Ngập úng (`OVERWATER`):** Khi `moisture > max_moisture_threshold` $\rightarrow$ Cảnh báo ngập úng và **tự động ngắt/khóa máy bơm khẩn cấp** để bảo vệ rễ cây.
4.  **Cảnh báo Rò rỉ nước (`LEAK`):** `AlertService.java` trên Backend đối chiếu lịch sử bảng `SensorReading`, phát hiện độ ẩm đất tụt giảm bất thường ($\Delta \ge 15\%$ trong vòng $\le 10\text{ phút}$) hoặc sụt giảm khối lượng chậu bất thường $\rightarrow$ Phát cảnh báo `LEAK` và phản hồi JSON để ESP8266 bắn Email.

### 5. Giao Diện Dashboard Tinh Giản, Tập Trung Vào Dữ Liệu (Data-First Executive UI)
*   **4 Hero KPI Cards:** Nổi bật hóa số liệu thời gian thực (*Avg Soil Moisture*, *Air Temperature*, *Air Humidity*, *Water Delivered*) với font số học `tabular-nums`.
*   **Bảng Trạng Thái `Live Soil Moisture by Pot`:** Hiển thị trực quan hệ cấp `Area · Pot · Plant`, chỉ thị màu sắc tự động theo trạng thái sinh học (*Healthy* / *Needs water* / *Too wet*).
*   **Biểu Đồ Phân Tích Xu Hướng (`Sensor Trend Analysis`):** Đối chiếu trực tiếp đường dữ liệu thực với dải ngưỡng an toàn (`Safe Threshold Band`).

---

## 🛠 Nền tảng Công nghệ (Tech Stack)
*   **Kiến trúc:** Strict MVC2 (Model - View - Controller) + Service Layer.
*   **Backend:** Java EE (Servlets, JSP), JDBC (`PreparedStatement`), RESTful JSON APIs cho IoT.
*   **Frontend:** HTML5, CSS3, Vanilla JavaScript (ES6+), SVG Interactive Charts (Data-First SaaS UI).
*   **Database:** Microsoft SQL Server (`SmartIrrigationDB` — 18 bảng chuẩn hóa).
*   **Hardware / IoT:**
    *   Vi điều khiển **NodeMCU ESP8266 (ESP-12E)**.
    *   Cảm biến độ ẩm đất Analog (`A0`), Cảm biến nhiệt ẩm **DHT11** (`D2 / GPIO4`), Cảm biến ánh sáng **LM393 LDR** (`D1 / GPIO5`), Cân điện tử **Loadcell + HX711** (`DT=D5/GPIO14`, `SCK=D6/GPIO12`).
    *   Module **Relay 5V + Máy bơm mini** (`D7 / GPIO13` — điều khiển Non-blocking bằng `millis()`).

---

## 🔌 Sơ Đồ Đấu Dây Phần Cứng ESP8266 (Hardware Pinout)

| Thiết bị / Module | Chân Thiết bị | Chân NodeMCU ESP8266 | Mã GPIO trong Code | Ghi chú Kỹ thuật |
| :--- | :--- | :--- | :--- | :--- |
| **1. Độ ẩm đất (Soil Moisture)** | `AO` (Analog) | **`A0`** | `A0` | Map từ `1023` (Khô 0%) $\rightarrow$ `400` (Ướt 100%) |
| **2. Ánh sáng (LM393 LDR)** | `DO` (Digital) | **`D1`** | `GPIO 5` | `0 (LOW)` = Có nắng (~680 lux), `1 (HIGH)` = Tối (~120 lux) |
| **3. Nhiệt độ & Độ ẩm (DHT11)** | `DATA / OUT` | **`D2`** | `GPIO 4` | Đọc nhiệt độ (°C) & độ ẩm không khí (%) |
| **4. Cân nặng (HX711 Loadcell)** | `DT` & `SCK` | **`D5`** & **`D6`** | `GPIO 14` & `12` | Có `wait_ready_timeout(200)` chống treo khi tuột dây |
| **5. Relay Máy bơm nước** | `IN / SIGNAL` | **`D7`** | `GPIO 13` | `HIGH` = Bật bơm, `LOW` = Tắt bơm (hẹn giờ non-blocking) |

---

## 💾 Cấu trúc Cơ sở dữ liệu (18 Bảng Chuẩn Hóa)
*   **Nhóm Phân quyền (4 bảng):** `AppRole`, `Permission`, `RolePermission`, `AppUser`.
*   **Nhóm Thực thể 3 tầng (3 bảng):** `Area` (Khu vực), `Plant` (Loại cây & Ngưỡng độ ẩm), `Pot` (Chậu cây — FK `area_id`, FK `plant_id`).
*   **Nhóm Thiết bị IoT (4 bảng):** `Sensor`, `SensorReading`, `Pump`, `PumpCalibration`.
*   **Nhóm Tưới tiêu (3 bảng):** `WateringSchedule`, `WateringSession`, `WaterAnalysis`.
*   **Nhóm Cảnh báo & Nhật ký (4 bảng):** `Alert`, `AlertConfirmation`, `MLPrediction`, `SystemLog`.

---

## 🚀 Hướng dẫn Cài đặt & Khởi chạy (Setup & Run Guide)

### 1. Yêu cầu môi trường
*   **JDK 1.8+**, **Apache Tomcat 9.0**, **Microsoft SQL Server** (bật TCP/IP port `1433`).
*   **Arduino IDE** (cài đặt board `ESP8266 Community` và các thư viện: `ArduinoJson`, `DHT sensor library`, `HX711 Arduino Library`).

### 2. Khởi tạo Cơ sở dữ liệu (`SmartIrrigationDB`)
Chạy lần lượt các file SQL trong thư mục [`sql/`](file:///d:/Study/FALL2026/PRJ301/Projects/PRJ301_Smart_Irrigation_Project/sql) trên SSMS (hoặc qua `sqlcmd`):
1.  [`sql/01_SmartIrrigation_Schema_17Tables.sql`](file:///d:/Study/FALL2026/PRJ301/Projects/PRJ301_Smart_Irrigation_Project/sql/01_SmartIrrigation_Schema_17Tables.sql) — Tạo schema gốc.
2.  [`sql/02_SmartIrrigation_SampleData.sql`](file:///d:/Study/FALL2026/PRJ301/Projects/PRJ301_Smart_Irrigation_Project/sql/02_SmartIrrigation_SampleData.sql) — Nạp dữ liệu mẫu.
3.  [`sql/04_SmartIrrigation_Refactor_Area_Pot_Plant.sql`](file:///d:/Study/FALL2026/PRJ301/Projects/PRJ301_Smart_Irrigation_Project/sql/04_SmartIrrigation_Refactor_Area_Pot_Plant.sql) — Nâng cấp cấu trúc 3 tầng `Area – Pot – Plant` và ngưỡng tưới động.

### 3. Cấu hình & Chạy Web Server
1.  Kiểm tra thông tin kết nối SQL Server tại [`src/java/util/DBContext.java`](file:///d:/Study/FALL2026/PRJ301/Projects/PRJ301_Smart_Irrigation_Project/src/java/util/DBContext.java):
    ```java
    private static final String URL = "jdbc:sqlserver://localhost:1433;databaseName=SmartIrrigationDB";
    private static final String USER = "sa";
    private static final String PASSWORD = "12345";
    ```
2.  Build & Deploy dự án lên **Apache Tomcat 9.0**.
3.  Truy cập hệ thống tại: `http://localhost:8080/PRJ301_Smart_Irrigation_System/login`

### 4. Tài khoản Đăng nhập Demo (Mật khẩu chung: `123456`)
| Vai trò (Role) | Username | Email đăng nhập | Mật khẩu | Quyền hạn chính |
| :--- | :--- | :--- | :--- | :--- |
| **👑 ADMIN** | `admin` | `admin1@demo.com` | `123456` | Toàn quyền hệ thống, quản lý cây/chậu, điều khiển bơm, xuất báo cáo |
| **👨‍🌾 MANAGER** | `manager` | `manager@demo.com` | `123456` | Quản lý Khu vực, Chậu, Cây trồng, Ngưỡng độ ẩm & Lịch tưới |
| **🔧 TECHNICIAN** | `tech` | `tech@demo.com` | `123456` | Giám sát Node cảm biến, hiệu chuẩn bơm & kiểm tra phần cứng |
| **👷 STAFF** | `staff` | `staff@demo.com` | `123456` | Vận hành tưới thủ công, theo dõi Telemetry & xử lý Cảnh báo |
| **👀 VIEWER** | `viewer` | `viewer@demo.com` | `123456` | Chỉ xem Dashboard & thông số thời gian thực |

### 5. Kiểm tra & Nạp Code Mạch ESP8266
1.  **Bước 1 (Test phần cứng độc lập):** Mở và nạp file [`Test_Thiet_Bi_Cam_Bien/Test_Thiet_Bi_Cam_Bien.ino`](file:///d:/Study/FALL2026/PRJ301/Projects/PRJ301_Smart_Irrigation_Project/Test_Thiet_Bi_Cam_Bien/Test_Thiet_Bi_Cam_Bien.ino) để kiểm tra từng cảm biến và Relay máy bơm qua Serial Monitor (`115200 baud`).
2.  **Bước 2 (Chạy chính thức):** Mở file [`Smart_Irrigation_Projec_IoT/Smart_Irrigation_Projec_IoT.ino`](file:///d:/Study/FALL2026/PRJ301/Projects/PRJ301_Smart_Irrigation_Project/Smart_Irrigation_Projec_IoT/Smart_Irrigation_Projec_IoT.ino), cập nhật `ssid`, `password` WiFi và địa chỉ IPv4 LAN của máy tính chạy Tomcat, sau đó nạp xuống mạch.
3.  **Tài liệu Review & Kịch bản Demo 4 Cảnh báo:** Mở trực tiếp file [`project_review.html`](file:///d:/Study/FALL2026/PRJ301/Projects/PRJ301_Smart_Irrigation_Project/project_review.html) (hoặc [`Kich_Ban_Demo_IoT_Thiet_Bi.html`](file:///d:/Study/FALL2026/PRJ301/Projects/PRJ301_Smart_Irrigation_Project/Kich_Ban_Demo_IoT_Thiet_Bi.html)) trên trình duyệt để xem sơ đồ kiến trúc, hướng dẫn đấu dây và công cụ **Live Simulator** test trực tiếp 4 kịch bản cảnh báo.

---

## 📂 Cấu trúc Thư mục Dự án (Project Structure)
```text
PRJ301_Smart_Irrigation_Project/
├── src/java/                                     # Mã nguồn Java Backend (Strict MVC2)
│   ├── controller/                               # Servlets & IoT REST APIs (/api/sensor/readings, /api/watering/command, /api/plants...)
│   ├── dao/                                      # Data Access Objects (AreaDAO, PotDAO, PlantDAO, SensorDataDAO, AlertDAO...)
│   ├── filter/                                   # AuthFilter kiểm soát phân quyền RBAC 5 vai trò
│   ├── model/                                    # Entity Models (Area, Pot, Plant, SensorData, Alert...)
│   ├── service/                                  # AlertService (4 quy tắc cảnh báo + Auto-watering) & AppDataService
│   └── util/                                     # DBContext, AppConfig, Json, ScheduleFormat
├── web/                                          # Giao diện Frontend (JSP, CSS, JS)
│   ├── css/                                      # Stylesheets (dashboard.css, plantManagement.css, wateringManagement.css...)
│   ├── js/                                       # Client-side sync & charts (zone-data.js, dashboard.js, plantManagement.js...)
│   ├── WEB-INF/                                  # navbar.jspf & web.xml
│   └── *.jsp                                     # Các trang chức năng (dashboard.jsp, plantManagement.jsp, wateringManagement.jsp...)
├── Smart_Irrigation_Projec_IoT/                  # Code Arduino ESP8266 chính thức (Non-blocking, Dynamic Pot Binding & 4 Alerts)
│   └── Smart_Irrigation_Projec_IoT.ino
├── Test_Thiet_Bi_Cam_Bien/                       # Code Arduino chẩn đoán phần cứng 5 thiết bị trước khi demo
│   └── Test_Thiet_Bi_Cam_Bien.ino
├── sql/                                          # Bộ kịch bản SQL Server khởi tạo & nâng cấp CSDL
│   ├── 01_SmartIrrigation_Schema_17Tables.sql
│   ├── 02_SmartIrrigation_SampleData.sql
│   ├── 03_SmartIrrigation_VerificationQueries.sql
│   └── 04_SmartIrrigation_Refactor_Area_Pot_Plant.sql
├── project_review.html                           # Tài liệu Review Kiến trúc, Đấu dây & Kịch bản Demo 4 Cảnh báo (kèm Live Simulator)
└── Kich_Ban_Demo_IoT_Thiet_Bi.html               # Bản sao hướng dẫn kịch bản thuyết trình thiết bị IoT
```
