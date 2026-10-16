# 🎤 KỊCH BẢN THUYẾT TRÌNH & BẢO VỆ ĐỒ ÁN PRJ301
## Đề Tài: Smart Irrigation Monitoring System (Hệ thống Giám sát & Vận hành Tưới tiêu IoT)
> **Môn học:** PRJ301 - Java Web Application (Fall 2026)  
> **Nhóm thực hiện:** Nhóm 1  
> **Thành viên:** Lê Văn Ngoan (Leader), Nguyễn Ngọc Linh, Phan Duy Bảo  
> **File Slide Trình Chiếu Đi Kèm:** [Thuyet_Trinh_Smart_Irrigation.html](file:///d:/Study/FALL2026/PRJ301/Projects/PRJ301_Smart_Irrigation_Project/Thuyet_Trinh_Smart_Irrigation.html)

---

## 🧭 HƯỚNG DẪN MỞ & ĐIỀU KHIỂN SLIDE TRÌNH CHIẾU

*   **Cách mở:** Nhấp đúp chuột vào file `Thuyet_Trinh_Smart_Irrigation.html` để mở trực tiếp trên Chrome / Edge / Firefox (không cần cài đặt thêm bất kỳ phần mềm nào).
*   **Các phím tắt điều khiển khi thuyết trình:**
    *   `→` / `Space` / `PageDown`: Sang slide tiếp theo.
    *   `←` / `Backspace` / `PageUp`: Quay lại slide trước.
    *   `F`: Bật/Tắt chế độ Toàn màn hình (Fullscreen Presentation).
    *   `N`: Bật/Tắt **Lời thoại thuyết trình (Speaker Notes)** ngay góc phải màn hình.
    *   `O`: Mở bảng **Mục lục dạng lưới (Overview)** để nhảy nhanh đến bất kỳ slide nào.
    *   `Ctrl + P`: Xuất slide sang định dạng **PDF** chuẩn 16:9 để in hoặc nộp bài.

---

## 👥 PHÂN CHIA VAI TRÒ THUYẾT TRÌNH (TỔNG THỜI GIAN: 15 PHÚT)

| Phần | Người trình bày | Nội dung phụ trách | Thời lượng dự kiến |
| :--- | :--- | :--- | :--- |
| **Phần 1** | **Lê Văn Ngoan** | Slide 1 – 5: Mở đầu, Bối cảnh, Kiến trúc Strict MVC2, CSDL 17 bảng, Bảo mật RBAC 5 Roles | ~ 4.5 phút |
| **Phần 2** | **Nguyễn Ngọc Linh** | Slide 6 – 11: Telemetry, Quản lý Cây & Chậu, Động cơ tưới, Hiệu chuẩn bơm, Alert Rules, Dự báo khô đất | ~ 5.0 phút |
| **Phần 3** | **Phan Duy Bảo** | Slide 12 – 18: Báo cáo CSV, Thiết kế Eco-Tech, 33 Test Cases, **Live Demo (5 phút)**, Kết luận | ~ 5.5 phút |

---

## 📜 KỊCH BẢN NÓI CHI TIẾT THEO TỪNG SLIDE (SPEAKER SCRIPT)

### 👤 PHẦN 1: TỔNG QUAN, KIẾN TRÚC & BẢO MẬT (LÊ VĂN NGOAN)

#### Slide 1: Giới thiệu đề tài & Thành viên
*   **Lời thoại:**  
    *"Kính chào thầy cô trong Hội đồng phản biện và các bạn sinh viên. Em tên là Lê Văn Ngoan, đại diện Nhóm 1 xin phép được bắt đầu buổi báo cáo đồ án môn PRJ301 với đề tài: **Smart Irrigation Monitoring System - Hệ thống giám sát và vận hành tưới tiêu tự động IoT**. Dự án được phát triển bởi 3 thành viên: Em chịu trách nhiệm thiết kế Database và Kiến trúc Backend; bạn Nguyễn Ngọc Linh phụ trách phần tích hợp IoT, thuật toán cảnh báo và hiệu chuẩn máy bơm; bạn Phan Duy Bảo phụ trách thiết kế giao diện Eco-Tech SaaS và trải nghiệm người dùng."*

#### Slide 2: Bối cảnh & Vấn đề thực tiễn
*   **Lời thoại:**  
    *"Xuất phát điểm của dự án chúng em đến từ một thực trạng rất nhức nhối trong nông nghiệp và hoa viên đô thị: có tới **40 đến 50% lượng nước ngọt bị lãng phí** do tập quán tưới theo cảm tính hoặc sử dụng bộ hẹn giờ cơ học. Hẹn giờ cố định có một nhược điểm chí mạng là: ngay cả khi trời vừa mưa to xong, đất đang sũng nước thì bơm vẫn kích hoạt xả nước, dẫn tới thối rễ chết cây. Ngược lại, những hôm nắng gắt thì tưới không đủ. Hệ thống của chúng em giải quyết triệt để vấn đề này bằng cách đưa dữ liệu cảm biến đất thực tế kết hợp với ngưỡng sinh học của từng giống cây trồng để quyết định lượng nước tưới chính xác nhất."*

#### Slide 3: Kiến trúc Hệ thống Strict MVC2
*   **Lời thoại:**  
    *"Về mặt kỹ thuật, dự án tuân thủ nghiêm ngặt mô hình **Strict MVC2**:
    1. **Tầng Controller:** Bao gồm bộ lọc `AuthFilter` và hơn 12 Servlet controllers. Chúng em đảm bảo 100% request từ client đều phải đi qua Controller, tuyệt đối không cho phép người dùng truy cập thẳng vào JSP chứa dữ liệu.
    2. **Tầng Model & DAO:** Được tách rời hoàn toàn khỏi giao diện. Mọi câu lệnh truy vấn CSDL đều sử dụng `PreparedStatement` để triệt tiêu hoàn toàn nguy cơ SQL Injection.
    3. **Tầng View:** Sử dụng JSP kết hợp JSTL và EL để hiển thị giao diện, không chứa mã logic nghiệp vụ Java trong scriptlet."*

#### Slide 4: Cơ sở dữ liệu 17 Bảng chuẩn hóa 3NF
*   **Lời thoại:**  
    *"Hệ thống cơ sở dữ liệu trên Microsoft SQL Server được thiết kế chuẩn hóa bậc 3 (3NF) gồm **17 bảng**, chia làm 5 phân nhóm chức năng:
    - Nhóm 1 là Phân quyền động RBAC gồm 4 bảng: `AppRole`, `Permission`, `RolePermission` và `AppUser`.
    - Nhóm 2 là Quản lý thực thể Cây trồng `Plant` và Khu vực/Chậu tưới `Pot`.
    - Nhóm 3 là Dữ liệu phần cứng IoT: Cảm biến `Sensor`, Bản ghi telemetry `SensorReading`, Máy bơm `Pump` và bảng Hiệu chuẩn `PumpCalibration`.
    - Nhóm 4 là Quản lý Lịch tưới `WateringSchedule` và Lịch sử xả nước `WateringSession`.
    - Nhóm 5 là Động cơ Cảnh báo sự cố `Alert`, Dự đoán `MLPrediction` và Nhật ký hệ thống `SystemLog`."*

#### Slide 5: Bảo mật & Ma trận 5 Vai trò (RBAC)
*   **Lời thoại:**  
    *"Điểm sáng trong kiến trúc an ninh của dự án là cơ chế phân quyền 2 lớp kết hợp giữa **Navbar hiển thị theo quyền** và **AuthFilter đánh chặn URL phía máy chủ**. Hệ thống phân định rạch ròi 5 vai trò:
    - `ADMIN`: Quản trị tối cao, xem nhật ký hệ thống.
    - `MANAGER`: Quản lý cây, chậu và thiết lập lịch tưới tự động.
    - `TECHNICIAN`: Kỹ thuật viên bảo trì phần cứng và cân chỉnh máy bơm.
    - `STAFF`: Nhân viên trực ca, giám sát và xử lý cảnh báo sự cố.
    - `VIEWER`: Khách tham quan chỉ có quyền đọc dữ liệu, không có nút chỉnh sửa.
    Nếu bất kỳ ai cố tình copy URL để thực hiện hành vi sửa xóa trái phép, AuthFilter sẽ lập tức chặn lại và chuyển hướng về trang 403 Forbidden."*

---

### 👤 PHẦN 2: TÍNH NĂNG IOT, THUẬT TOÁN & HIỆU CHUẨN (NGUYỄN NGỌC LINH)

#### Slide 6: Dashboard & Telemetry thời gian thực
*   **Lời thoại:**  
    *"Kính thưa thầy cô, em xin tiếp nối phần trình bày với module Giám sát Telemetry. Trang Dashboard được ví như trung tâm chỉ huy của nông trại: Người vận hành có thể theo dõi tức thời độ ẩm đất, nhiệt độ, độ ẩm không khí và cường độ ánh sáng. Điểm đặc biệt là toàn bộ biểu đồ xu hướng (Trend Chart) được chúng em vẽ bằng **Vector SVG thuần**, giúp tải trang siêu nhanh, không phụ thuộc thư viện JavaScript cồng kềnh và hiển thị sắc nét trên mọi độ phân giải."*

#### Slide 7: Quản lý Cây trồng & Phân khu Chậu tưới
*   **Lời thoại:**  
    *"Tại module Quản lý Cây và Chậu, mỗi loại cây (như Cà chua, Dâu tây, Lan ý...) được lưu trữ một hồ sơ sinh học riêng biệt: độ ẩm tối thiểu cần tưới, độ ẩm tối đa phải ngắt nước và nhu cầu quang kỳ. Quan hệ giữa Cây và Chậu là 1-Nhiều, cho phép một loại cây được trồng ở nhiều phân khu khác nhau nhưng vẫn áp dụng đúng quy chuẩn tưới tối ưu của giống cây đó."*

#### Slide 8: Động cơ Tưới tự động & Lịch trình thông minh
*   **Lời thoại:**  
    *"Hệ thống hỗ trợ 2 cơ chế vận hành tưới song song:
    1. **Tưới tự động theo cảm biến:** Khi độ ẩm đất giảm xuống dưới ngưỡng tối thiểu của cây, hệ thống tính toán thời gian bơm cần thiết và kích hoạt tưới.
    2. **Tưới theo lịch biểu định kỳ:** Hỗ trợ cài đặt giờ tưới linh hoạt các ngày trong tuần, đồng thời có cơ chế an toàn: nếu phát hiện trời đang mưa hoặc đất đang ướt trên ngưỡng tối đa, lịch tưới sẽ tự động bỏ qua để tránh úng rễ."*

#### Slide 9: Hiệu chuẩn Máy bơm (Pump Calibration)
*   **Lời thoại:**  
    *"Một tính năng kỹ thuật nâng cao mà nhóm vừa hoàn thiện là **Pump Calibration**. Trong thực tế, máy bơm sau một thời gian hoạt động sẽ bị cặn bám, hao mòn cánh quạt hoặc áp lực đường ống giảm, khiến lưu lượng thực tế khác xa với lý thuyết. Bằng cách cho bơm chạy thử $T$ giây và đo thể tích nước $V$ (ml), hệ thống sẽ tính được lưu lượng thực đo $Q = \frac{V}{T}$ (ml/giây). Nhờ vậy, khi hệ thống yêu cầu tưới đúng 500ml nước, thời gian đóng ngắt bơm sẽ chuẩn xác tới từng giây."*

#### Slide 10: Động cơ Cảnh báo 5 Luật Toán Học (Alert Engine)
*   **Lời thoại:**  
    *"Hệ thống tích hợp động cơ cảnh báo tự động với 5 quy tắc toán học:
    - **Rule 1 & 2:** Cảnh báo đất khô hạn quá lâu hoặc ngập úng nguy hiểm cho rễ.
    - **Rule 3 (Phát hiện vỡ ống/rò rỉ nước):** Khi máy bơm đang tắt nhưng độ ẩm đất bất ngờ tăng hoặc đồng hồ lưu lượng vẫn nhảy, hệ thống lập tức phát cảnh báo Pipe Leak.
    - **Rule 4 (Bơm bị kẹt hoặc cạn bể chứa):** Đã bật bơm hơn 60 giây nhưng độ ẩm đất không hề tăng, báo động ngay để bảo vệ động cơ chống cháy.
    - **Rule 5 (Sensor Offline):** Cảm biến quá 15 phút không gửi dữ liệu nhịp tim."*

#### Slide 11: Dự báo Thời điểm Đất khô (Soil Drying Forecast)
*   **Lời thoại:**  
    *"Về mặt giải thuật phân tích: Dựa trên tốc độ bốc hơi nước và đạo hàm biến thiên độ ẩm theo nhiệt độ môi trường, hệ thống tính toán được tốc độ khô của đất theo từng giờ. Từ đó, người quản lý có thể biết trước khoảng mấy giờ nữa thì chậu cây cần tưới để chủ động chuẩn bị nguồn nước hoặc xếp lịch nhân công."*

---

### 👤 PHẦN 3: BÁO CÁO, DEMO TRỰC TIẾP & KẾT LUẬN (PHAN DUY BẢO)

#### Slide 12: Báo cáo Thống kê & Xuất CSV Chuẩn Quốc Tế
*   **Lời thoại:**  
    *"Em xin phép tiếp tục với phân hệ Báo cáo và Xuất dữ liệu. Hệ thống hỗ trợ bộ lọc đa chiều theo chậu, theo trạng thái và khoảng ngày. Chức năng Export CSV được nhóm xử lý theo chuẩn **RFC 4180**, chèn sẵn mã **UTF-8 BOM (`\uFEFF`)** ở đầu luồng tải về. Do đó, khi người dùng mở file bằng Microsoft Excel tiếng Việt trên Windows sẽ hiển thị hoàn hảo 100%, hoàn toàn không bị lỗi bảng mã ký tự."*

#### Slide 13: Thiết kế Giao diện Eco-Tech SaaS & Nâng cấp UX
*   **Lời thoại:**  
    *"Toàn bộ giao diện người dùng được nhóm tự tay xây dựng theo ngôn ngữ thiết kế **Eco-Tech SaaS**: Sự kết hợp giữa sắc xanh thiên nhiên `#10b981` và nền than `#0f172a` mang lại cảm giác công nghệ cao. Vừa qua, nhóm đã tinh chỉnh toàn diện thanh lọc ngày `.data-filter-bar` và bộ công cụ hiệu chuẩn bơm: các nhãn in hoa nhỏ gọn, ô nhập ngày bo góc mềm mại, nút Clear bộ lọc nhanh và bố cục hoàn toàn co giãn tương thích trên điện thoại thông minh."*

#### Slide 14: Đảm bảo Chất lượng & Bộ 33 Test Cases
*   **Lời thoại:**  
    *"Để đảm bảo độ tin cậy tuyệt đối, dự án đã vượt qua trọn vẹn **33 Test Cases kiểm thử tự động và thủ công**, bao gồm: 8 bài test phân quyền RBAC và xác thực; 10 bài test nghiệp vụ CRUD và kiểm tra dữ liệu biên; 8 bài test telemetry và luật cảnh báo; cùng 7 bài test bảo mật chống SQL Injection, mã độc XSS và tràn bộ nhớ. Tỷ lệ vượt qua đạt 100%."*

#### Slide 15: Kịch bản Live Demo (Bắt đầu chuyển sang thao tác trực tiếp)
*   **Lời thoại:**  
    *"Sau đây, em xin phép đại diện nhóm tiến hành trình diễn Live Demo sản phẩm thực tế trên trình duyệt trong vòng 5 phút:
    1. **Bước 1:** Em đăng nhập tài khoản `staff`. Thầy cô có thể thấy trên menu chỉ xuất hiện các mục vận hành cơ bản, không có quyền quản lý người dùng hay tạo lịch tưới. Khi em cố tình gõ URL `/schedules` trên thanh địa chỉ, hệ thống lập tức chặn lại và báo 403 Forbidden.
    2. **Bước 2:** Em đăng xuất và đăng nhập lại bằng tài khoản `manager`. Toàn bộ các quyền quản lý cây, chậu và lịch tưới xuất hiện.
    3. **Bước 3:** Em mở trang **Sensors**: Dữ liệu đo độ ẩm và nhiệt độ đang đồng bộ trực tiếp với biểu đồ SVG xu hướng.
    4. **Bước 4:** Em chuyển sang trang **Pump Calibration**, chọn máy bơm ở Vườn B, nhập 1800 ml trong 10 giây. Hệ thống tự động tính ngay lưu lượng là 180 ml/s và lưu vào CSDL.
    5. **Bước 5:** Em vào trang **Watering History**, dùng bộ lọc ngày để tìm các phiên tưới trong tuần và nhấn **Export CSV**. File tải về mở ngay trên Excel hiển thị tiếng Việt nguyên vẹn."*

#### Slide 16 & 17 & 18: Kết luận & Sẵn sàng Q&A
*   **Lời thoại:**  
    *"Tổng kết lại, nhóm 1 đã hoàn thành xuất sắc toàn bộ mục tiêu đề ra cho đồ án PRJ301, xây dựng một hệ thống hoàn chỉnh từ kiến trúc CSDL, bảo mật phân quyền đến giao diện hiện đại. Nhóm xin trân trọng cảm ơn sự hướng dẫn tận tình của quý thầy cô bộ môn. Nhóm chúng em đã sẵn sàng đón nhận các câu hỏi phản biện từ Hội đồng!"*

---

## 🛡️ BỘ CÂU HỎI & ĐÁP VẤN ĐÁP BẢO VỆ ĐỒ ÁN (Q&A DEFENSE CHEAT-SHEET)

Dưới đây là 10 câu hỏi "bẫy" kinh điển mà các Giảng viên PRJ301 thường hỏi cùng câu trả lời chuẩn xác nhất:

### Q1: Tại sao nhóm dùng mô hình MVC2 mà không dùng MVC1 (viết Java trực tiếp trong JSP)?
*   **Đáp:**  
    *MVC1 nhúng mã Java (scriptlet) trực tiếp vào file JSP, dẫn tới việc trộn lẫn logic nghiệp vụ với mã HTML. Khi dự án lớn lên sẽ cực kỳ khó bảo trì, không thể tái sử dụng mã và vi phạm nguyên lý Single Responsibility. Mô hình MVC2 tách biệt hoàn toàn: Controller (Servlet) tiếp nhận và xử lý request, Model quản lý dữ liệu, và View (JSP) thuần túy hiển thị dữ liệu qua JSTL/EL. Điều này giúp dự án dễ kiểm thử, phân chia công việc nhóm rõ ràng và bảo mật cao hơn.*

### Q2: Nếu người dùng biết URL của một trang bị cấm (ví dụ `/plants?action=delete`) và tự gõ vào trình duyệt thì hệ thống chặn bằng cách nào?
*   **Đáp:**  
    *Dự án sử dụng `AuthFilter` được đăng ký trong `web.xml` để đón chặn 100% request trước khi vào tới bất kỳ Controller nào. Filter sẽ lấy Session hiện tại, kiểm tra xem người dùng đã đăng nhập chưa. Nếu đã đăng nhập, Filter lấy Role của user và đối soát với ma trận quyền hạn (bảng `RolePermission`). Nếu Role đó không có quyền thao tác trên URL hoặc HTTP Method tương ứng, Filter sẽ lập tức chuyển hướng sang trang lỗi 403 Forbidden hoặc từ chối thực thi.*

### Q3: Vì sao PreparedStatement lại chống được lỗi SQL Injection?
*   **Đáp:**  
    *Khác với `Statement` thông thường thực hiện nối chuỗi trực tiếp khiến mã độc của hacker bị Database biên dịch thành lệnh thực thi, `PreparedStatement` gửi khung câu lệnh SQL lên Database Server để tiền biên dịch trước (Pre-compiled). Các giá trị do người dùng nhập vào chỉ được truyền qua placeholder `?` dưới dạng tham số thuần túy (literals). Dù người dùng có gõ các ký tự độc hại như `' OR '1'='1` thì CSDL vẫn chỉ coi đó là một chuỗi văn bản thông thường, không thể làm thay đổi cấu trúc câu lệnh.*

### Q4: Sự khác nhau giữa `request.getRequestDispatcher().forward()` và `response.sendRedirect()` trong dự án?
*   **Đáp:**  
    * *`forward()`*: Là điều hướng phía máy chủ (Server-side). Trình duyệt của người dùng không hề biết có sự chuyển hướng, URL trên thanh địa chỉ không đổi, và toàn bộ dữ liệu trong `HttpServletRequest` (các attribute đã set) được giữ nguyên sang trang JSP tiếp theo. Dùng khi Controller chuẩn bị dữ liệu xong và chuyển cho JSP hiển thị.
    * *`sendRedirect()`*: Là chuyển hướng phía máy khách (Client-side). Server gửi mã phản hồi 302 về trình duyệt kèm URL mới, trình duyệt sẽ tự động phát sinh một request HTTP GET hoàn toàn mới. Dữ liệu request cũ bị hủy. Dùng sau khi xử lý thành công một form POST (mô hình Post/Redirect/Get) để tránh người dùng nhấn F5 bị gửi lặp dữ liệu.

### Q5: Tại sao mở file CSV trên Excel thường bị lỗi font tiếng Việt và nhóm xử lý ra sao?
*   **Đáp:**  
    *Mặc định Microsoft Excel trên hệ điều hành Windows khi mở tệp CSV sẽ tự động dùng bảng mã ANSI/Windows-1252 thay vì UTF-8 nếu tệp không có dấu hiệu nhận biết. Nhóm đã xử lý bằng cách ghi thêm 3 byte **BOM (Byte Order Mark: `\uFEFF`)** vào đầu luồng xuất tệp trong `ExportCSVController`. Nhờ 3 byte này, Excel nhận diện ngay lập tức đây là file Unicode UTF-8 và hiển thị tiếng Việt có dấu chuẩn 100%.*

### Q6: Ý nghĩa thực tế của chức năng Pump Calibration là gì?
*   **Đáp:**  
    *Trên thông số xuất xưởng, máy bơm có thể ghi là 12 L/phút (200 ml/s). Nhưng khi lắp đặt vào vườn thực tế, do đường ống dài, nhiều khúc cua, chênh lệch độ cao và độ hao mòn động cơ, lưu lượng thực tế có thể chỉ còn 160 ml/s. Nếu phần mềm vẫn dùng con số lý thuyết 200 ml/s để tính thời gian tưới, cây sẽ bị tưới thiếu nước trầm trọng. Bằng cách hiệu chuẩn thực tế (Pump Calibration) và cập nhật lưu lượng ml/s đo được vào CSDL, mọi tính toán thời gian đóng ngắt bơm của hệ thống sẽ đạt độ chính xác 100%.*

### Q7: Nếu mạng Internet hoặc nguồn điện bị ngắt, dữ liệu cảm biến IoT được xử lý thế nào?
*   **Đáp:**  
    *Phần cứng vi điều khiển (ESP32/NodeMCU) được thiết kế có bộ nhớ đệm RTC/Flash nội bộ. Khi mất kết nối tới server, nó tiếp tục đọc và lưu trữ tạm thời các mẫu đo. Ngay khi có mạng trở lại, nó gửi gói tin bù trừ theo cơ chế batch sync kèm mốc thời gian thực. Đồng thời, phía máy chủ nếu quá 15 phút không nhận được nhịp tim (Heartbeat) sẽ kích hoạt Rule 5 (Sensor Offline Alert) để báo cho nhân viên trực ca.*

### Q8: Làm thế nào để đảm bảo không bị rò rỉ kết nối CSDL (Connection Leak)?
*   **Đáp:**  
    *Trong tất cả các lớp DAO, mọi đối tượng kết nối gồm `Connection`, `PreparedStatement` và `ResultSet` đều được quản lý bằng cấu trúc `try-with-resources` (tự động đóng khi kết thúc khối lệnh) hoặc được gọi lệnh `.close()` rõ ràng trong khối `finally`. Điều này đảm bảo dù có phát sinh ngoại lệ `SQLException` thì tài nguyên kết nối vẫn được hoàn trả về hệ thống, ngăn chặn triệt để hiện tượng treo CSDL do cạn kiệt Connection Pool.*

---

## 🎯 DANH MỤC KIỂM TRA TRƯỚC KHI LÊN THUYẾT TRÌNH (CHECKLIST)
- [x] Đã bật SQL Server và mở cổng TCP/IP `1433`.
- [x] Đã chạy Tomcat 9 và kiểm tra server sẵn sàng ở `http://localhost:8080/SmartIrrigation`.
- [x] Chuẩn bị sẵn 3 trình duyệt / tab ẩn danh với 3 tài khoản: `admin`, `manager`, `staff` (mật khẩu `123456`).
- [x] Mở sẵn file `Thuyet_Trinh_Smart_Irrigation.html` trên trình duyệt và nhấn `F` để sẵn sàng chế độ toàn màn hình.
- [x] Thử nghiệm trước các phím `→`, `Space`, `N` (mở speaker notes) và `O` (xem slide grid).

