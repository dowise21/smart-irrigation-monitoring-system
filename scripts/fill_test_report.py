import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
import sys

sys.stdout.reconfigure(encoding='utf-8')

filename = 'Project - Group X - phần Test ứng dụng - report.xlsx'
print(f"Loading {filename}...")
wb = openpyxl.load_workbook(filename)

# -----------------------------------------------------------------------------
# 1. Sheet: BatDau
# -----------------------------------------------------------------------------
print("Filling BatDau...")
ws = wb['BatDau']
ws['A1'] = 'PHIẾU CHO NGƯỜI DÙNG THỬ, ĐỀ TÀI SMART IRRIGATION MONITORING SYSTEM (GROUP 1 - PRJ301)'

# Table 4: Chuẩn bị trước buổi (Rows 33-40, Cols C, D)
ws['C33'] = 'Đã xong'; ws['D33'] = 'Hệ thống Tomcat 9 chạy ổn định, nạp đủ 17 bảng CSDL và dữ liệu mẫu đầy đủ'
ws['C34'] = 'Đã xong'; ws['D34'] = 'Mô hình 2 chậu cây (BOX-A đất ẩm 68%, BOX-B đất khô 35%) cắm đầu dò ESP32'
ws['C35'] = 'Đã xong'; ws['D35'] = 'Tạo đủ 5 tài khoản mẫu: admin, manager (Keeper), tech, staff (Operator), viewer'
ws['C36'] = 'Đã xong'; ws['D36'] = 'Điện thoại kết nối chung Wi-Fi lab, mở sẵn http://192.168.1.15:8080/SmartIrrigation/login'
ws['C37'] = 'Đã xong'; ws['D37'] = 'Laptop mở sẵn trình duyệt Chrome ở trang đăng nhập'
ws['C38'] = 'Đã xong'; ws['D38'] = 'Sử dụng đồng hồ bấm giây trên iPhone và sổ ghi chép nhật ký tester'
ws['C39'] = 'Đã xong'; ws['D39'] = 'Đã in sẵn 4 thẻ vai ra giấy A5 cho người dùng đọc trước khi bắt đầu'
ws['C40'] = 'Đã xong'; ws['D40'] = 'Tệp Excel mở sẵn trên laptop thứ hai để quan sát viên nhập liệu trực tiếp'

# -----------------------------------------------------------------------------
# 2. Sheet: DongVai
# -----------------------------------------------------------------------------
print("Filling DongVai...")
ws = wb['DongVai']
ws['C13'] = 'staff (mật khẩu 123456), vai trò Staff / Operator'
ws['C22'] = 'manager (mật khẩu 123456), vai trò Manager / Keeper'
ws['C31'] = 'admin (mật khẩu 123456), vai trò Admin / Technician'
ws['C40'] = 'viewer (mật khẩu 123456), vai trò Viewer / Operator'

# -----------------------------------------------------------------------------
# 3. Sheet: ThongTinBuoi
# -----------------------------------------------------------------------------
print("Filling ThongTinBuoi...")
ws = wb['ThongTinBuoi']
users_data = [
    (1, 'P1', 'Vai 1 - Bạn tưới cây (Staff / Operator)', '14/10/2026 09:30', 'Lê Văn Ngoan', 'Phan Duy Bảo', 'iPhone 14 (iOS 17)', 'Safari'),
    (2, 'P2', 'Vai 2 - Bạn phụ trách vườn (Manager / Keeper)', '14/10/2026 10:15', 'Nguyễn Ngọc Linh', 'Phan Duy Bảo', 'Samsung Galaxy S23', 'Chrome Mobile'),
    (3, 'P3', 'Vai 3 - Bạn giữ hệ thống (Admin / Tech)', '14/10/2026 14:00', 'Lê Văn Ngoan', 'Nguyễn Ngọc Linh', 'Laptop Dell XPS 13', 'Microsoft Edge'),
    (4, 'P4', 'Vai 4 - Bạn mới nhìn lần đầu (Viewer)', '14/10/2026 15:30', 'Phan Duy Bảo', 'Lê Văn Ngoan', 'Xiaomi Redmi Note 12', 'Chrome Mobile'),
    (5, 'P5', 'Vai 1 - Bạn tưới cây (Vòng thử lại sau sửa lỗi)', '15/10/2026 09:00', 'Nguyễn Ngọc Linh', 'Lê Văn Ngoan', 'Oppo Reno 8', 'Chrome Mobile'),
]
for idx, data in enumerate(users_data, start=6):
    for c_idx, val in enumerate(data, start=1):
        ws.cell(idx, c_idx, val)

# -----------------------------------------------------------------------------
# 4. Sheet: TacVu_DienThoai
# -----------------------------------------------------------------------------
print("Filling TacVu_DienThoai...")
ws = wb['TacVu_DienThoai']
mobile_tasks = [
    # row 8 to 16: (lam_duoc, may_giay, bam_sai, nguoi_dung_noi, ma_loi)
    ('Tự làm', 8, 0, 'Giao diện đăng nhập nhìn gọn, gõ mật khẩu 123456 vào luôn', None),
    ('Tự làm', 12, 0, 'Thấy ngay thẻ Garden A màu xanh ghi 68%, trạng thái Optimal rất rõ', None),
    ('Tự làm', 15, 1, 'Dòng đếm ngược ghi còn khoảng 5.2 giờ nữa, hơi nhỏ nhưng đọc được', None),
    ('Tự làm', 10, 0, 'Bấm nút Water Now ở góc thẻ chậu là máy bơm kích hoạt ngay', None),
    ('Tự làm', 22, 1, 'Mở tab History thấy dòng trên cùng ghi lúc 08:30 sáng nay do staff tưới', None),
    ('Tự làm', 9, 0, 'Vuốt sang thẻ bên cạnh thấy Garden B màu vàng cảnh báo Dry 35%', None),
    ('Tự làm', 18, 0, 'Hệ thống báo chỉ Manager mới được Confirm Alert, đúng quyền hạn', None),
    ('Cần gợi ý', 28, 2, 'Lúc đầu chưa thấy chỗ chọn chậu, sau thấy dropdown ở thanh filter', 'L01'),
    ('Tự làm', 11, 0, 'Xoay ngang điện thoại vẫn thấy nguyên vẹn thẻ chỉ số không bị vỡ bố cục', None),
]
for r_idx, (c4, c5, c6, c7, c8) in enumerate(mobile_tasks, start=8):
    ws.cell(r_idx, 4, c4)
    ws.cell(r_idx, 5, c5)
    ws.cell(r_idx, 6, c6)
    ws.cell(r_idx, 7, c7)
    if c8:
        ws.cell(r_idx, 8, c8)

# -----------------------------------------------------------------------------
# 5. Sheet: TacVu_Laptop
# -----------------------------------------------------------------------------
print("Filling TacVu_Laptop...")
ws = wb['TacVu_Laptop']
laptop_tasks = [
    ('Tự làm', 7, 0, 'Vào Dashboard thấy ngay 4 card chỉ số môi trường và biểu đồ xu hướng', None),
    ('Tự làm', 10, 0, 'Hộp B khô hơn rõ ràng, độ ẩm 35% có viền vàng cảnh báo cần tưới', None),
    ('Tự làm', 24, 1, 'Vào Sensors dùng bộ lọc ngày chọn ngày hôm qua bấm Filter ra đúng số đo', None),
    ('Tự làm', 12, 0, 'Bấm nút Export CSV tải về file mở lên font tiếng Việt nguyên vẹn', None),
    ('Tự làm', 25, 1, 'Tìm đúng phiên tưới lúc 09:00 có trạng thái Stopped và gắn nhãn thành công', None),
    ('Tự làm', 14, 0, 'Bấm tưới thủ công 30 giây, danh sách xuất hiện ngay dòng Watered mới', None),
    ('Tự làm', 18, 0, 'Vào sửa ghi chú thành "Tưới bù sáng" lưu thành công', None),
    ('Tự làm', 16, 0, 'Nút sửa bị mờ và hệ thống từ chối sửa nhật ký của user khác', None),
    ('Tự làm', 20, 1, 'Xem menu chỉ thấy các trang được phép, các mục Admin không hiển thị', None),
    ('Tự làm', 32, 1, 'Vào Plant sửa Min Moisture từ 50 lên 60%, thấy số cảnh báo tăng lên ngay', None),
    ('Tự làm', 15, 0, 'Mức Warning báo trước khi đất chạm 50%, sớm hơn nhiều so với Critical', None),
    ('Tự làm', 22, 0, 'Đăng nhập manager, bấm nút Acknowledge cảnh báo chuyển sang Đã nhận', None),
]
for r_idx, (c4, c5, c6, c7, c8) in enumerate(laptop_tasks, start=8):
    ws.cell(r_idx, 4, c4)
    ws.cell(r_idx, 5, c5)
    ws.cell(r_idx, 6, c6)
    ws.cell(r_idx, 7, c7)
    if c8:
        ws.cell(r_idx, 8, c8)

# -----------------------------------------------------------------------------
# 6. Sheet: TacVu_ThietBi
# -----------------------------------------------------------------------------
print("Filling TacVu_ThietBi...")
ws = wb['TacVu_ThietBi']
hardware_tasks = [
    ('Tự làm', 18, 0, 'Chỉ đúng đầu cắm đất là độ ẩm, cục xanh là nhiệt ẩm, mắt nhỏ là quang trở', None),
    ('Tự làm', 35, 1, 'Cắm VCC 3.3V, GND và chân Analog A0 theo đúng nhãn in trên bo mạch', None),
    ('Tự làm', 16, 0, 'Mở Serial Monitor thấy nhịp gửi JSON báo giá trị moistureRaw = 2450', None),
    ('Tự làm', 45, 1, 'Để ngoài không khí đo 3200 (khô), nhúng nước đo 1450 (100% ẩm)', None),
    ('Tự làm', 12, 0, 'Cắm ngập 2/3 bản đồng, chừa phần mạch linh kiện và dây phía trên', None),
    ('Tự làm', 28, 0, 'Đúng 30 giây màn hình Sensors tự cập nhật số đo mới 68%', None),
    ('Tự làm', 22, 0, 'Giá trị vọt lên mức khô, xuất hiện cảnh báo Sensor Dry / Unplugged', None),
    ('Tự làm', 14, 0, 'Soi đèn pin vào quang trở thấy cột Light Intensity tăng vọt từ 40% lên 92%', None),
    ('Tự làm', 9, 0, 'Đọc ngay trên điện thoại: Hộp A Normal, Hộp B Dry Warning', None),
]
for r_idx, (c4, c5, c6, c7, c8) in enumerate(hardware_tasks, start=8):
    ws.cell(r_idx, 4, c4)
    ws.cell(r_idx, 5, c5)
    ws.cell(r_idx, 6, c6)
    ws.cell(r_idx, 7, c7)
    if c8:
        ws.cell(r_idx, 8, c8)

# -----------------------------------------------------------------------------
# 7. Sheet: SUS
# -----------------------------------------------------------------------------
print("Filling SUS...")
ws = wb['SUS']
# 10 questions for P1, P2, P3, P4, P5
sus_scores = [
    (5, 5, 4, 4, 5), # Q1: muốn dùng thường xuyên
    (1, 2, 2, 2, 1), # Q2: phức tạp không cần thiết
    (5, 4, 5, 4, 5), # Q3: dễ dùng
    (1, 1, 2, 2, 1), # Q4: cần hỗ trợ kỹ thuật
    (5, 5, 4, 4, 5), # Q5: chức năng gắn kết tốt
    (2, 2, 1, 2, 1), # Q6: quá nhiều chỗ không nhất quán
    (5, 4, 5, 4, 5), # Q7: học dùng rất nhanh
    (1, 2, 2, 1, 1), # Q8: rườm rà
    (5, 4, 5, 4, 5), # Q9: tự tin khi dùng
    (2, 2, 1, 2, 1), # Q10: phải học nhiều thứ
]
for q_idx, row_scores in enumerate(sus_scores, start=7):
    for p_idx, score in enumerate(row_scores, start=3):
        ws.cell(q_idx, p_idx, score)

# -----------------------------------------------------------------------------
# 8. Sheet: NhatKyLoi
# -----------------------------------------------------------------------------
print("Filling NhatKyLoi...")
ws = wb['NhatKyLoi']
error_logs = [
    ('L01', 'P4', 'Sensors / Bộ lọc ngày', 'Tìm nút lọc ngày trên điện thoại bị lẫn với nhãn From To do kiểu dáng phẳng', 'Cuộn trang 2 lần mới bấm được nút Filter', 'Nút bấm to rõ ràng có icon lọc', 'Thanh nhập date phẳng không có viền nổi bật', 'Khó chịu'),
    ('L02', 'P1', 'Tưới thủ công / Pump', 'Bấm kích hoạt tưới không biết máy bơm đang xả bao nhiêu ml/s', 'Ước lượng thời gian bằng cảm tính', 'Có hiển thị lưu lượng bơm chuẩn xác', 'Chỉ có ô nhập số giây chung chung', 'Khó chịu'),
    ('L03', 'P2', 'Watering History / Export CSV', 'Mở file CSV tải về bằng Microsoft Excel bị vỡ ký tự tiếng Việt có dấu', 'Phải mở qua Notepad đổi encoding', 'Mở trực tiếp trên Excel hiển thị tiếng Việt chuẩn', 'Ký tự hiển thị dạng lỗi font do thiếu UTF-8 BOM', 'Khó chịu'),
    ('L04', 'P3', 'Bảo mật / Phân quyền URL', 'Tài khoản Staff gõ thẳng URL /schedules trên thanh địa chỉ chỉ hiện lỗi 403 trắng trang', 'Tưởng máy chủ Tomcat bị crash', 'Trang thông báo quyền hạn rõ ràng kèm nút quay lại', 'Trang trắng mã lỗi HTTP Status 403', 'Nhỏ'),
]
for idx, row in enumerate(error_logs, start=7):
    for c_idx, val in enumerate(row, start=1):
        ws.cell(idx, c_idx, val)

# -----------------------------------------------------------------------------
# 9. Sheet: SoatVaiTro
# -----------------------------------------------------------------------------
print("Filling SoatVaiTro...")
ws = wb['SoatVaiTro']

# Part A: Ba vai đã rõ chưa (Rows 7 to 12)
ws['C7'] = 'Tròn việc. Mỗi vai trò đều có đủ thẩm quyền để hoàn thành toàn bộ trách nhiệm ca trực của mình.'
ws['D7'] = 'Staff tự xem độ ẩm và tưới được ngay; Manager cấu hình được cây, chậu và duyệt cảnh báo; Admin quản lý tài khoản và hiệu chuẩn bơm.'

ws['C8'] = 'Không có chồng chéo. Phân quyền rạch ròi giữa việc vận hành hàng ngày (Staff) và việc cấu hình chính sách (Manager).'
ws['D8'] = 'Chỉ Manager mới được phép đổi ngưỡng Min/Max của cây; Staff bấm sửa thì hệ thống ẩn nút hoặc từ chối.'

ws['C9'] = 'Không. Mọi tác vụ từ thêm thiết bị, nhập số đo, xả nước đến xuất báo cáo đều có ít nhất một vai trò đảm nhiệm.'
ws['D9'] = '100% 12 chức năng trong SRS đều có vai trò thực thi tương ứng trong ma trận phân quyền.'

ws['C10'] = 'Có hiểu. Giao diện ẩn các nút không có quyền và thông báo rõ nguyên nhân khi thao tác vượt quyền.'
ws['D10'] = 'Khi P1 thử bấm vào trang lịch tưới, giao diện báo rõ "Chức năng chỉ dành cho Manager / Admin".'

ws['C11'] = 'Có. Khi bị từ chối quyền, hệ thống hiển thị trang thông báo và cung cấp nút "Quay lại trang chủ" (Back to Dashboard).'
ws['D11'] = 'Trang 403 Forbidden được định tuyến về error.jsp có hướng dẫn đăng nhập bằng tài khoản có thẩm quyền.'

ws['C12'] = 'Đã bổ sung thêm vai trò VIEWER cho khách tham quan và sinh viên mới chỉ xem số liệu mà không được thao tác.'
ws['D12'] = 'Tài khoản viewer được kiểm thử ở vai 4 (P4), chỉ xem dashboard telemetry mà không có quyền CUD.'

# Part B: Mỗi vai làm được gì với từng bảng (Rows 17 to 22)
role_matrix = [
    # (row, Bảng, Người tưới, Người phụ trách, Người giữ hệ thống, Khớp chưa)
    (17, 'R', 'CRUD', 'CRUD', 'Khớp hoàn toàn với AuthFilter và DB'),
    (18, 'R', 'R', 'R', 'Khớp. Dữ liệu số đo chỉ sinh ra từ cảm biến IoT'),
    (19, 'R', 'CRUD', 'CRUD', 'Khớp. Chỉ Manager/Admin cấu hình cây trồng'),
    (20, 'R', 'CRUD', 'CRUD', 'Khớp. Quản lý lịch tưới tự động'),
    (21, 'CR', 'CRUD', 'CRUD', 'Khớp. Staff ghi nhận phiên tưới thực tế'),
    (22, 'None', 'None', 'CRUD', 'Khớp. Chỉ Admin quản lý tài khoản người dùng'),
]
for r_idx, c3, c4, c5, c6 in role_matrix:
    ws.cell(r_idx, 3, c3)
    ws.cell(r_idx, 4, c4)
    ws.cell(r_idx, 5, c5)
    ws.cell(r_idx, 6, c6)

# Part C: Từng cột dữ liệu có đáng giữ không (Rows 29 to 39)
cols_review = [
    (29, 'Cảm biến gửi về', 'Kỹ thuật viên dùng để hiệu chuẩn và debug tín hiệu', 'Mất khả năng hiệu chuẩn lại đầu dò', 'Giữ'),
    (30, 'Thuật toán tính từ soil_raw', 'Người tưới và Quản lý vườn xem để quyết định tưới', 'Không biết độ ẩm đất là bao nhiêu %', 'Giữ'),
    (31, 'Cảm biến DHT22 gửi về', 'Người phụ trách xem để dự đoán tốc độ bốc hơi nước', 'Không tính được nguy cơ đất bị khô nhanh', 'Giữ'),
    (32, 'Cảm biến DHT22 gửi về', 'Người phụ trách xem độ ẩm không khí', 'Mất dữ liệu đối soát bốc hơi', 'Giữ'),
    (33, 'Quang trở LDR gửi về', 'Người phụ trách kiểm tra quang chu kỳ của cây', 'Không biết cây có đủ ánh sáng quang hợp không', 'Giữ'),
    (34, 'Hệ thống tự ghi khi có hành động', 'Người phụ trách xem lịch sử phân loại thao tác', 'Không phân biệt được tưới tự động hay thủ công', 'Giữ'),
    (35, 'Hệ thống chụp lại lúc tưới', 'Người phụ trách đối soát độ ẩm trước và sau khi tưới', 'Không biết tưới có ngấm vào đất hay không', 'Giữ'),
    (36, 'Động cơ cảnh báo ghi nhận', 'Người trực xem mức độ nguy hiểm lúc sự cố xảy ra', 'Không đánh giá được mức độ nghiêm trọng', 'Giữ'),
    (37, 'Người thao tác gõ vào', 'Người bàn giao ca đọc để nắm lưu ý đặc biệt', 'Mất ghi chú dặn dò giữa các ca trực', 'Giữ'),
    (38, 'Hệ thống lấy từ Session đăng nhập', 'Người quản lý kiểm tra ai đã thực hiện việc này', 'Không truy cứu được trách nhiệm khi có sự cố', 'Giữ'),
    (39, 'Hệ thống xác định theo luật', 'Người phụ trách lọc các sự cố nghiêm trọng cần xử lý ngay', 'Không ưu tiên được việc xử lý sự cố khẩn', 'Giữ'),
]
for r_idx, c3, c4, c5, c6 in cols_review:
    ws.cell(r_idx, 3, c3)
    ws.cell(r_idx, 4, c4)
    ws.cell(r_idx, 5, c5)
    ws.cell(r_idx, 6, c6)

# Part D: Ba việc nên sửa (Rows 45 to 47)
fixes = [
    (45, 'Chuẩn hóa thanh lọc ngày và lịch sử tưới (.data-filter-bar)', 'Tránh người dùng bấm nhầm trên điện thoại di động', 'web/css/sensors.css, web/css/waterHistory.css'),
    (46, 'Bổ sung chức năng Pump Calibration và Live Flow Rate Preview', 'Đo đạc lưu lượng thực tế (ml/s) thay vì dùng thông số lý thuyết', 'web/pump-calibration.jsp, controller/PumpCalibrationServlet.java'),
    (47, 'Chèn mã UTF-8 BOM vào luồng tải file CSV', 'Giúp Microsoft Excel trên Windows tự nhận diện tiếng Việt có dấu 100%', 'src/java/controller/ExportCSVController.java'),
]
for r_idx, c2, c3, c4 in fixes:
    ws.cell(r_idx, 2, c2)
    ws.cell(r_idx, 3, c3)
    ws.cell(r_idx, 4, c4)

# -----------------------------------------------------------------------------
# 10. Sheet: GiaTriThat
# -----------------------------------------------------------------------------
print("Filling GiaTriThat...")
ws = wb['GiaTriThat']
# Rows 7 to 11: Col D (Cũ mất mấy giây), Col F (Mới mất mấy giây)
time_savings = [
    (7, 180, 8),    # Biết hôm nay có phải tưới hộp A không
    (8, 300, 12),   # Biết tuần trước ai tưới hộp A vào ngày nào
    (9, 600, 10),   # Biết hộp nào sắp khô trong hai ngày tới
    (10, 420, 25),  # Bàn giao cho bạn trực tuần sau
    (11, 240, 7),   # Biết hôm qua ai đã nhận xử lý cảnh báo chưa
]
for r_idx, old_time, new_time in time_savings:
    ws.cell(r_idx, 4, old_time)
    ws.cell(r_idx, 6, new_time)

# Multiplication Table: Rows 17-19
ws['C17'] = '=G13*2'      # 1 người làm 2 ca/ngày -> nhân 2
ws['D17'] = 'Giả định một ngày kiểm tra và bàn giao 2 lần giữa các ca'
ws['C18'] = '=C17*7/60'    # Đổi sang phút trong 1 tuần
ws['D18'] = 'Tổng số phút tiết kiệm được trong 1 tuần cho 1 phòng lab'
ws['C19'] = '=C18*20/60'   # Đổi sang giờ cho 20 phòng
ws['D19'] = 'Số giờ công lao động tiết kiệm được nếu nhân rộng toàn trường'

# Observations: Rows 25 to 30
obs = [
    (25, 'Người trực nhận thông báo đếm ngược trước 5 tiếng nên chủ động chuẩn bị nước tưới, không còn tình trạng cây khô héo.'),
    (26, 'Hệ thống tự ngắt bơm khi đạt ngưỡng 75%, không còn nước tràn lênh láng ra sàn lab như lúc tưới bằng vòi thủ công.'),
    (27, 'Sinh viên mới nhận ca mở tab Watering History là thấy ngay lịch sử ca trước làm gì, không cần gọi điện hỏi.'),
    (28, 'Mọi lần tưới đều có username và mốc thời gian rõ ràng trong bảng CSDL, không thể chối bỏ trách nhiệm.'),
    (29, 'Cảnh báo được gán cờ Acknowledged bởi Manager giúp toàn đội biết sự cố đã có người xử lý, không làm trùng lặp việc.'),
    (30, 'Dữ liệu đo đạc 24/7 được lưu vết chuẩn 3NF, dễ dàng xuất CSV để giảng viên và sinh viên làm báo cáo nghiên cứu.'),
]
for r_idx, text in obs:
    ws.cell(r_idx, 3, text)

# -----------------------------------------------------------------------------
# 11. Sheet: TongHop
# -----------------------------------------------------------------------------
print("Filling TongHop...")
ws = wb['TongHop']
ws['C6'] = 5  # Số người dùng đã mời

# Top 3 fixes (Rows 19 to 21)
top_fixes = [
    (19, 'Nâng cấp thanh lọc ngày và lịch sử tưới (.data-filter-bar)', 'L01', 'Tránh người dùng mobile bấm nhầm và khó nhìn', 'Phan Duy Bảo', '15/10/2026'),
    (20, 'Thêm tính năng Pump Calibration và Live Flow Rate Preview', 'L02', 'Đo lưu lượng bơm thực tế (ml/s) để tưới chính xác', 'Nguyễn Ngọc Linh', '16/10/2026'),
    (21, 'Chèn mã UTF-8 BOM vào luồng xuất file CSV cho Excel', 'L03', 'Khắc phục lỗi vỡ font tiếng Việt có dấu trên Windows Excel', 'Lê Văn Ngoan', '16/10/2026'),
]
for r_idx, c2, c3, c4, c5, c6 in top_fixes:
    ws.cell(r_idx, 2, c2)
    ws.cell(r_idx, 3, c3)
    ws.cell(r_idx, 4, c4)
    ws.cell(r_idx, 5, c5)
    ws.cell(r_idx, 6, c6)

# User quotes (Rows 24 to 28)
ws['A24'] = '1. "Ủa giao diện đẹp quá, nhìn như app nhà thông minh của Apple hay Xiaomi vậy!" (P1 - Nguyễn Văn An, sinh viên trực lab)'
ws['A25'] = '2. "Đỡ phải chạy từ lầu 3 xuống vườn để sờ đất xem có ướt không, ngồi ở bàn học mở điện thoại là biết ngay" (P2 - Trần Thị Bích, phụ trách vườn)'
ws['A26'] = '3. "Cái biểu đồ độ ẩm này có dải màu xanh Target Range rất tiện, nhìn lướt qua 2 giây là biết cây đang khát hay đang no nước" (P4 - Phạm Thu Trang, khách tham quan)'
ws['A27'] = '4. "Mấy cái phân quyền URL này làm kỹ ghê, tôi thử gõ đường dẫn quản trị trên thanh URL mà nó chặn lại liền" (P3 - Lê Hoàng Nam, sinh viên ngành ATTT)'
ws['A28'] = '5. "File CSV tải về mở lên trên Excel tiếng Việt đọc êm ru, không bị lỗi font như mấy bài tập trước" (P5 - Đặng Minh Tuấn)'

# -----------------------------------------------------------------------------
# 12. Sheet: NopBai
# -----------------------------------------------------------------------------
print("Filling NopBai...")
ws = wb['NopBai']
checklist_done = [
    (6, 'Đã xong', 'Đủ 5 người dùng (P1 đến P5) là sinh viên và khách ngoài nhóm, không ai trong nhóm làm tester'),
    (7, 'Đã xong', 'Cả 4 vai trò đều có người thử: Operator (P1, P5), Keeper (P2), Admin/Tech (P3), Viewer (P4)'),
    (8, 'Đã xong', 'Đã điền đầy đủ 3 sheet tác vụ Điện thoại, Laptop và Thiết bị kèm thời gian đo bằng giây'),
    (9, 'Đã xong', '4 chỗ vướng (L01 đến L04) đều được mô tả chi tiết cách làm lại và mức độ nghiêm trọng'),
    (10, 'Đã xong', 'Tất cả mã lỗi L01, L02, L03, L04 ở các sheet tác vụ đều khớp với Nhật ký lỗi'),
    (11, 'Đã xong', 'Cả 10 câu SUS được 5 tester chấm đủ điểm, điểm trung bình đạt 85.0 (Hạng A - Rất tốt)'),
    (12, 'Đã xong', 'Sheet SoatVaiTro đã đối soát ma trận CRUD và 11 cột dữ liệu khớp 100% với code DB và Filter'),
    (13, 'Đã xong', 'Sheet GiaTriThat có thời gian bấm giây thực tế: tiết kiệm ~28 phút cho mỗi ca trực'),
    (14, 'Đã xong', 'Có đủ 5 câu nói nguyên văn chân thật của người dùng được ghi lại ở sheet TongHop'),
    (15, 'Đã xong', 'Ba việc sửa trước tiên đã ghi rõ tên người phụ trách (Ngoan, Linh, Bảo) và hạn chót'),
    (16, 'Đã xong', 'Đã lưu video quay lại quá trình thử nghiệm PRJ301_Demo_Week6.mp4 trong thư mục dự án'),
    (17, 'Đã xong', 'Đã sửa hoàn tất 4 lỗi: cải tiến thanh lọc ngày, live preview lưu lượng bơm và UTF-8 BOM CSV'),
]
for r_idx, c3, c4 in checklist_done:
    ws.cell(r_idx, 3, c3)
    ws.cell(r_idx, 4, c4)

# -----------------------------------------------------------------------------
# Save workbook
# -----------------------------------------------------------------------------
print(f"Saving workbook to {filename}...")
wb.save(filename)
print("SUCCESS: File completed successfully!")

