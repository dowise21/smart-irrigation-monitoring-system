# -*- coding: utf-8 -*-
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VIEWS = ROOT / "web" / "WEB-INF" / "views"
CSS_LINK = '<link href="${pageContext.request.contextPath}/css/main-style.css" rel="stylesheet">'
APP_LINK = '<link href="${pageContext.request.contextPath}/css/app.css" rel="stylesheet">'

TRANSLATIONS = [
    ("Bạn có chắc chắn muốn xóa cây này không?", "Are you sure you want to delete this plant?"),
    ("Bạn có chắc chắn muốn xóa chậu này không?", "Are you sure you want to delete this pot?"),
    ("Bạn có chắc muốn xóa lịch này?", "Are you sure you want to delete this schedule?"),
    ("Xác nhận đã khắc phục sự cố này?", "Confirm that this incident has been resolved?"),
    ("Đăng nhập cổng quản trị & giám sát tưới tự động", "Sign in to the irrigation operations console"),
    ("Hệ thống xác thực mã hóa an toàn &bull; Phiên bản 2.4", "Encrypted authentication &bull; Version 2.4"),
    ("Hệ thống IoT Nông nghiệp", "AgriTech IoT Platform"),
    ("Đăng nhập hệ thống", "Sign in"),
    ("Đăng nhập - Smart Irrigation", "Sign in - Smart Irrigation"),
    ("Tên đăng nhập", "Username"),
    ("Nhập tài khoản", "Enter username"),
    ("Nhập mật khẩu", "Enter password"),
    ("Hiện/ẩn mật khẩu", "Show or hide password"),
    ("Mật khẩu", "Password"),
    ("Tổng quan Hệ thống", "System Overview"),
    ("Hệ thống tưới tự động &bull; Cập nhật dữ liệu đo lường thời gian thực", "Automated irrigation &bull; Real-time telemetry updates"),
    ("Xuất Báo cáo CSV", "Export CSV Report"),
    ("Nước đã tưới", "Water Delivered"),
    ("Lưu lượng cấp chính", "Primary supply flow"),
    ("Nước giữ lại", "Water Retained"),
    ("Cây hấp thụ tối ưu", "Optimal plant uptake"),
    ("Nước hao phí", "Water Waste"),
    ("Rò rỉ & bốc hơi đất", "Leakage & soil evaporation"),
    ("Giám sát ẩm", "Moisture watch"),
    ("Cảnh báo hệ thống", "System Alerts"),
    ("Trạng thái cảm biến/van", "Sensor / valve status"),
    ("Cần chú ý", "Needs attention"),
    ("Phân tích Lượng nước Tiêu thụ", "Water Consumption Analysis"),
    ("Tỷ lệ so sánh nước cấp, hấp thụ thực tế và hao phí", "Delivered vs absorbed vs wasted water"),
    ("Tổng cấp", "Delivered"),
    ("Hấp thụ", "Absorbed"),
    ("Hao phí", "Waste"),
    ("Trung tâm sự cố", "Incident Center"),
    ("Tức thì", "Live"),
    ("Sự cố cần kiểm tra ngay", "Incidents requiring review"),
    ("Xử lý cảnh báo ngay", "Resolve alerts now"),
    ("Nước đã dùng", "Water Used"),
    ("Nước giữ lại (Hấp thụ)", "Water Retained (Uptake)"),
    ("Nước hao phí (Rò rỉ)", "Water Waste (Leakage)"),
    (" Dung lượng (Lít)", " Volume (Liters)"),
    (" Dung lượng: ", " Volume: "),
    (" Lít", " L"),
    ("Bảng Điều Khiển Bơm Nước", "Pump Control Console"),
    ("Kích hoạt tưới nước thủ công ngay lập tức cho các chậu cây đang bị thiếu ẩm.", "Trigger an immediate manual irrigation cycle for moisture-stressed pots."),
    ("Chọn Chậu Cần Tưới", "Select Pot to Water"),
    ("-- Chọn chậu đang cảnh báo khô --", "-- Select a pot with a dry-soil alert --"),
    ("Chậu P-01 (Hoa Hồng) - Ẩm: 35%", "Pot P-01 (Rose) - Moisture: 35%"),
    ("Chậu P-02 (Lan Hồ Điệp) - Ẩm: 40%", "Pot P-02 (Orchid) - Moisture: 40%"),
    ("Chậu P-03 (Cây Trầu Bà) - Ẩm: 55%", "Pot P-03 (Pothos) - Moisture: 55%"),
    ("Lượng Nước (ml)", "Water Volume (ml)"),
    ("Ví dụ: 500", "e.g. 500"),
    ("Khuyến nghị: 250ml - 500ml mỗi lần tưới.", "Recommended: 250ml – 500ml per cycle."),
    ("KÍCH HOẠT BƠM NƯỚC", "ACTIVATE PUMP"),
    ("Thao tác này sẽ được ghi nhận vào Nhật ký hệ thống dưới tên tài khoản của bạn.", "This action is recorded in the system audit log under your account."),
    ("Đang gửi lệnh bơm...", "Sending pump command..."),
    ("Tưới Thủ Công | Smart Irrigation", "Manual Watering | Smart Irrigation"),
    ("Quản lý Lịch tưới tự động", "Automatic Irrigation Schedules"),
    ("Cấu hình thời gian kích hoạt rơ-le máy bơm theo lịch định kỳ hoặc biểu thức Cron", "Configure pump relay timing with a daily clock or Cron expression"),
    ("Danh sách Chậu", "Pot List"),
    ("Thêm Lịch Tưới Mới", "Add New Schedule"),
    ("Thời gian (Cron / Giờ)", "Time (Cron / Clock)"),
    ("VD: 07:30 Hàng ngày", "e.g. 07:30 Daily"),
    ("Nhập giờ chạy (vd: <code>06:30</code>) hoặc chu kỳ định sẵn.", "Enter a clock time (e.g. <code>06:30</code>) or a predefined cycle."),
    ("Thời lượng bơm", "Pump Duration"),
    ("Tối thiểu: 10s", "Min: 10s"),
    ("Tối đa: 300s (5 phút)", "Max: 300s (5 minutes)"),
    ("Lưu lịch tưới", "Save schedule"),
    ("Lịch trình đã thiết lập", "Configured Schedules"),
    ("Chu kỳ tự động", "Automatic cycle"),
    ("Thời gian thiết lập", "Schedule Time"),
    ("Trạng thái", "Status"),
    ("Thao tác", "Actions"),
    ("Đang Bật", "Enabled"),
    ("Tạm Tắt", "Paused"),
    ("Tạm dừng lịch tưới", "Pause this schedule"),
    ("Kích hoạt lịch tưới", "Enable this schedule"),
    ("Xóa lịch tưới", "Delete schedule"),
    ("Chưa có lịch tưới nào được thiết lập", "No irrigation schedules configured"),
    ("Sử dụng biểu mẫu bên trái để tạo khung giờ bơm tự động cho chậu này.", "Use the form on the left to create an automatic pump window for this pot."),
    ("Lịch tưới sẽ tự động đồng bộ xuống bo mạch vi điều khiển (ESP32 / NodeMCU) qua giao thức MQTT.", "Schedules are synced to ESP32 / NodeMCU controllers over MQTT."),
    ("Lịch tưới tự động - Smart Irrigation System", "Irrigation Schedules - Smart Irrigation System"),
    ("Chậu ID:", "Pot ID:"),
    ("Mô hình AI Dự đoán Tưới tiêu", "AI Irrigation Prediction Model"),
    ("Thuật toán học máy phân tích độ ẩm, lưu lượng và ánh sáng để ước lượng thời điểm khô hạn", "The model uses moisture, flow, and light to estimate the next dry-down time"),
    ("Thông số Đầu vào (Features)", "Input Features"),
    ("Độ ẩm đất hiện tại", "Current Soil Moisture"),
    ("Ngưỡng độ ẩm đất thực tế từ cảm biến", "Live soil moisture reading from the sensor"),
    ("Lượng nước vừa tưới", "Last Irrigation Volume"),
    ("Dung tích nước bơm trong chu kỳ gần nhất", "Pump volume from the most recent cycle"),
    ("Cường độ ánh sáng", "Light Intensity"),
    ("Ảnh hưởng trực tiếp đến tốc độ bốc thoát hơi nước", "Directly affects evapotranspiration rate"),
    ("Chạy Mô hình Dự đoán", "Run Prediction"),
    ("Kết quả Dự đoán (ML Output)", "Prediction Result (ML Output)"),
    ("Hoàn thành", "Complete"),
    ("Dựa trên dữ liệu huấn luyện nông nghiệp thông minh, chậu cây sẽ cần tưới lại vào lúc:", "Based on the trained agri dataset, this pot will need water again at:"),
    ("Thời điểm cần cấp nước tiếp theo", "Next watering window"),
    ("Đã tự động bù trừ hệ số bốc hơi thời tiết", "Weather evaporation coefficient applied"),
    ("Độ tin cậy của thuật toán:", "Model confidence:"),
    ("Độ tin cậy:", "Confidence:"),
    ("Dữ liệu vector đặc trưng (Features Tensor):", "Feature tensor:"),
    ("Mô hình đang ở trạng thái sẵn sàng", "Model is ready"),
    ('Hãy điền các thông số môi trường ở biểu mẫu bên trái và nhấn <strong>"Chạy Mô hình Dự đoán"</strong> để hệ thống suy luận thời điểm tưới tối ưu.', 'Enter environmental inputs on the left and click <strong>"Run Prediction"</strong> to estimate the optimal watering time.'),
    ("Dự báo tự động giúp tiết kiệm tới 35% lượng nước", "Automated forecasts can reduce water use by up to 35%"),
    ("Thuật toán tự động tái huấn luyện khi có dữ liệu cảm biến mới từ vườn.", "The model retrains automatically when new garden sensor data arrives."),
    ("Danh mục Cây trồng", "Plant Catalog"),
    ("Quản lý thông số độ ẩm lý tưởng, giống loài và chỉ dẫn chăm sóc tự động", "Manage ideal moisture ranges, species, and automated care profiles"),
    ("Thêm Cây Mới", "Add Plant"),
    ("Tìm tên cây hoặc loài...", "Search by plant name or species..."),
    ("Tìm kiếm", "Search"),
    ("Xóa lọc", "Clear filter"),
    ("Tên Cây", "Plant Name"),
    ("Giống / Loài", "Species"),
    ("Độ ẩm lý tưởng", "Ideal Moisture"),
    ("Mô tả", "Description"),
    ("Mã cây:", "Plant code:"),
    ("Khoảng độ ẩm lý tưởng của cảm biến", "Ideal sensor moisture range"),
    ("Chưa cài đặt", "Not configured"),
    ("Chỉnh sửa thông tin", "Edit details"),
    ("Xóa cây trồng này", "Delete this plant"),
    ("Không tìm thấy cây trồng nào", "No plants found"),
    ("Danh sách thực vật đang trống hoặc từ khóa tìm kiếm không khớp với dữ liệu nào.", "The catalog is empty, or your search did not match any records."),
    ("Tạo cây mới ngay", "Create a plant now"),
    ("Độ ẩm lý tưởng giúp hệ thống tự động kích hoạt van tưới tiêu chuẩn xác.", "Ideal moisture ranges drive precise automatic valve activation."),
    ("Quản lý Cây trồng - Smart Irrigation System", "Plant Management - Smart Irrigation System"),
    ("Danh sách Chậu / Khu vực tưới", "Pots / Irrigation Zones"),
    ("Quản lý thiết bị", "Device management"),
    ("Giám sát trạng thái van tưới, vị trí vật lý và liên kết cây trồng trên từng chậu thông minh", "Monitor valve status, physical location, and plant assignment per smart pot"),
    ("Thêm Chậu Mới", "Add Pot"),
    ("Tên Chậu / Khu vực", "Pot / Zone Name"),
    ("Vị trí đặt", "Location"),
    ("Đang trồng cây", "Planted Crop"),
    ("Chế độ tự động đang bật", "Automatic mode is on"),
    ("Chế độ tự động đã tắt", "Automatic mode is off"),
    ("Đang tưới", "Irrigating"),
    ("Tạm ngưng", "Paused"),
    ("Xem độ ẩm và thông số cảm biến thời gian thực", "View live moisture and sensor metrics"),
    ("Xem nhật ký lịch sử kích hoạt bơm nước", "View pump activation history"),
    ("Chỉnh sửa thông tin chậu", "Edit pot details"),
    ("Xóa chậu này", "Delete this pot"),
    ("Chưa có chậu cây nào được tạo", "No pots have been created yet"),
    ("Bắt đầu quản lý khu vườn thông minh của bạn bằng cách thêm mới chậu cây và gán cảm biến đo độ ẩm.", "Start managing your smart garden by adding a pot and assigning a moisture sensor."),
    ("Thêm Chậu Đầu Tiên", "Add First Pot"),
    ("Các vi điều khiển NodeMCU/ESP32 sẽ tự động nhận diện ID chậu khi kết nối vào mạng Mesh.", "NodeMCU/ESP32 controllers auto-detect pot IDs when they join the mesh network."),
    ("Quản lý Khu vực tưới / Chậu - Smart Irrigation System", "Irrigation Zones / Pots - Smart Irrigation System"),
    ("Giám sát", "Monitor"),
    ("Lịch sử", "History"),
    ("${plant != null ? 'Cập nhật' : 'Thêm mới'} Cây trồng - Smart Irrigation", "${plant != null ? 'Update' : 'Create'} Plant - Smart Irrigation"),
    ("${plant != null ? 'Chế độ Chỉnh sửa' : 'Thêm mới'}", "${plant != null ? 'Edit mode' : 'Create'}"),
    ("${plant != null ? 'CẬP NHẬT CÂY TRỒNG' : 'THÊM CÂY MỚI'}", "${plant != null ? 'UPDATE PLANT' : 'ADD NEW PLANT'}"),
    ("Cấu hình thông số sinh thái và khoảng độ ẩm tối ưu cho từng giống cây", "Configure ecological parameters and the optimal moisture range for each species"),
    ("Tên cây trồng", "Plant name"),
    ("Ví dụ: Cà chua bi, Hương thảo, Dâu tây...", "e.g. Cherry tomato, rosemary, strawberry..."),
    ("Giống / Loài (Species)", "Species"),
    ("Ví dụ: Solanum lycopersicum", "e.g. Solanum lycopersicum"),
    ("Ngưỡng Độ ẩm Đất Lý tưởng", "Ideal Soil Moisture Range"),
    ("Tối thiểu (%)", "Minimum (%)"),
    ("Kích hoạt bơm", "Pump trigger"),
    ("Ví dụ: 45.0", "e.g. 45.0"),
    ("Tối đa (%)", "Maximum (%)"),
    ("Ngắt bơm an toàn", "Safety cutoff"),
    ("Ví dụ: 75.0", "e.g. 75.0"),
    ("Mô tả thêm & Đặc tính tưới tiêu", "Notes & irrigation profile"),
    ("Nhập ghi chú về chu kỳ quang hợp, nhu cầu dinh dưỡng hoặc độ sâu của rễ...", "Notes on photoperiod, nutrient needs, or root depth..."),
    ("Quay lại danh sách", "Back to list"),
    ("Lưu thông tin", "Save"),
    ("${pot != null ? 'Cập nhật' : 'Thêm mới'} Chậu - Smart Irrigation System", "${pot != null ? 'Update' : 'Create'} Pot - Smart Irrigation System"),
    ("${pot != null ? 'Cập nhật' : 'Tạo mới'}", "${pot != null ? 'Update' : 'Create'}"),
    ("${pot != null ? 'CẬP NHẬT CHẬU CÂY' : 'THÊM CHẬU MỚI'}", "${pot != null ? 'UPDATE POT' : 'ADD NEW POT'}"),
    ("Cấu hình chậu trồng, vị trí vườn và chế độ tưới tự động thông minh", "Configure pot details, garden location, and automatic irrigation"),
    ("Bắt buộc", "Required"),
    ("Tùy chọn", "Optional"),
    ("Theo danh mục", "From catalog"),
    ("VD: Chậu Ban Công 1", "e.g. Balcony Pot 1"),
    ("VD: Tầng 2, góc trái ban công", "e.g. Floor 2, left balcony corner"),
    ("Chọn loại cây đang trồng", "Select planted crop"),
    ("-- Chọn một loại cây --", "-- Select a plant --"),
    ("Kích hoạt tưới tự động", "Enable automatic irrigation"),
    ("Tự động bơm khi độ ẩm đất dưới ngưỡng tối thiểu", "Pump automatically when soil moisture falls below the minimum"),
    ("Giám sát Độ ẩm Đất", "Soil Moisture Monitoring"),
    ("Thu nhận trực tiếp dữ liệu đo đạc thời gian thực từ các node cảm biến độ ẩm", "Live moisture telemetry from sensor nodes"),
    ("Tạo 1 bản ghi ảo 45.5% để Test kết nối Servlet", "Create a 45.5% mock reading to test the servlet"),
    ("+ Giả lập tín hiệu (Test)", "+ Simulate Signal (Test)"),
    ("Lọc theo Khu vực / Chậu:", "Filter by zone / pot:"),
    ("-- Tất cả các chậu --", "-- All pots --"),
    ("(Trồng:", "(Crop:"),
    ("Xem tất cả", "View all"),
    ("Thời gian ghi nhận", "Recorded At"),
    ("Loại Cây Đang Trồng", "Planted Crop"),
    ("Độ ẩm đất đo được", "Measured Soil Moisture"),
    ("Khu vực đo trực tuyến", "Online sensing zone"),
    ("Độ ẩm thấp hơn ngưỡng yêu cầu", "Moisture is below the required threshold"),
    ("Độ ẩm bão hòa vượt ngưỡng", "Moisture is above the saturation threshold"),
    ("Độ ẩm tối ưu cho cây", "Moisture is in the optimal range"),
    ("(Quá khô)", "(Too dry)"),
    ("(Ướt)", "(Saturated)"),
    ("(Tốt)", "(Optimal)"),
    ("Chưa có dữ liệu cảm biến nào được gửi về", "No sensor data has been received"),
    ("Hệ thống chưa nhận được gói tin telemetry từ cảm biến nào của chậu đã chọn. Bạn có thể nhấn nút giả lập bên trên để kiểm tra đường truyền.", "No telemetry packets have arrived for the selected pot. Use the simulator above to verify connectivity."),
    ("Dưới 30%: Khô hạn", "Below 30%: Drought"),
    ("30% - 80%: Lý tưởng", "30% – 80%: Ideal"),
    ("Trên 80%: Thừa nước", "Above 80%: Overwatered"),
    ("Dữ liệu Cảm biến - Smart Irrigation System", "Sensor Data - Smart Irrigation System"),
    ("Nhật ký Tưới tự động", "Automatic Irrigation Logs"),
    ("Ghi nhận thời gian kích hoạt van bơm và lượng nước tưới tiêu theo thời gian thực", "Live log of pump valve activations and delivered water volume"),
    ("Giả lập hệ thống vừa bơm nước 60s", "Simulate a 60-second pump cycle"),
    ("+ Giả lập Bơm nước (Test)", "+ Simulate Pump (Test)"),
    ("-- Tất cả các chậu cây --", "-- All pots --"),
    ("Thời gian tưới", "Irrigation Time"),
    ("Tên Chậu", "Pot Name"),
    ("Loại Cây", "Plant Type"),
    ("Thời gian bơm", "Pump Duration"),
    ("Lượng nước", "Water Volume"),
    (" giây", " sec"),
    ("Chưa có nhật ký tưới", "No irrigation logs yet"),
    ('Chưa ghi nhận lần bơm nước nào cho bộ lọc này. Bạn có thể nhấn <strong>"Giả lập Bơm nước"</strong> phía trên để tạo bản ghi thử nghiệm.', 'No pump cycles match this filter. Click <strong>"Simulate Pump"</strong> above to create a test record.'),
    ("Dữ liệu được đồng bộ hóa tự động từ các vi điều khiển van xả thông minh.", "Data is synced automatically from smart valve controllers."),
    ("Lịch sử Tưới - Smart Irrigation System", "Irrigation History - Smart Irrigation System"),
    ("Hệ thống Cảnh báo tự động", "Automated Alert Center"),
    ("Giám sát lưu lượng, độ ẩm chậu cây & phát hiện bất thường tức thì", "Monitor flow, pot moisture, and detect anomalies in real time"),
    ("-- Tất cả cảnh báo --", "-- All alerts --"),
    ("Cần xử lý ngay", "Needs action"),
    ("Đã khắc phục", "Resolved"),
    ("Thời gian", "Time"),
    ("Chậu cây", "Pot"),
    ("Loại sự cố", "Incident Type"),
    ("Chi tiết chẩn đoán", "Diagnostic Details"),
    ("TƯỚI THỪA", "OVERWATER"),
    ("THIẾU NƯỚC", "DRY STRESS"),
    ("LỖI CẢM BIẾN", "SENSOR FAULT"),
    ("NGHI RÒ RỈ", "LEAK SUSPECTED"),
    ("Chưa xử lý", "Open"),
    ("Xử lý xong", "Mark resolved"),
    ("Tuyệt vời! Không phát hiện sự cố", "All clear — no incidents detected"),
    ("Hệ thống tưới và các cảm biến đang hoạt động ổn định, độ ẩm đất đạt ngưỡng lý tưởng.", "Irrigation hardware and sensors are stable, and soil moisture is in range."),
    ('Nhấn <strong>"Xử lý xong"</strong> sau khi kiểm tra van hoặc cảm biến tại vườn.', 'Click <strong>"Mark resolved"</strong> after inspecting the valve or sensor in the garden.'),
    ("Quản lý Cảnh báo - Smart Irrigation System", "Alert Management - Smart Irrigation System"),
    ("Giây", "sec"),
    ("Tổng quan", "Overview"),
    ("Khu vườn", "Garden"),
    ("Quản lý Cây trồng", "Plant Management"),
    ("Chậu & Khu vực tưới", "Pots & Irrigation Zones"),
    ("Vận hành IoT", "IoT Operations"),
    ("Dữ liệu Cảm biến", "Sensor Data"),
    ("Lịch tưới tự động", "Auto Schedules"),
    ("Tưới thủ công", "Manual Watering"),
    ("Nhật ký bơm nước", "Pump Logs"),
    ("Quản lý Thiết bị", "Device Management"),
    ("AI Dự đoán", "AI Forecast"),
    ("Cảnh báo hệ thống", "System alerts"),
    ("Tài khoản", "Account"),
    ("Đăng xuất", "Sign out"),
    ("Hiệu quả", "Efficient"),
    ("Lỗi", "Issues"),
    ("Sửa", "Edit"),
    ("Xóa", "Delete"),
    ("Tắt", "Off"),
    ("Bật", "On"),
    ("VD: 60.5", "e.g. 60.5"),
    ("VD: 800", "e.g. 800"),
    ("VD: 5000", "e.g. 5000"),
]

INLINE_REPLACEMENTS = [
    (' class="dropdown-header text-uppercase text-muted fw-bold" style="font-size: 0.7rem; letter-spacing: 0.05em;"',
     ' class="dropdown-header dropdown-header-label text-uppercase text-muted fw-bold"'),
    (' class="mb-0 fw-bold text-dark tracking-tight" style="letter-spacing: -0.03em;"',
     ' class="mb-0 fw-bold text-dark tracking-tighter"'),
    (' class="mb-0 fw-bold text-dark tracking-tight" style="letter-spacing: -0.02em;"',
     ' class="mb-0 fw-bold text-dark tracking-tight"'),
    (' class="mb-0 fw-bold text-dark" style="letter-spacing: -0.02em;"',
     ' class="mb-0 fw-bold text-dark tracking-tight"'),
    (' class="fw-bold text-dark mb-1" style="letter-spacing: -0.02em;"',
     ' class="fw-bold text-dark mb-1 tracking-tight"'),
    (' class="bi bi-droplet-fill text-primary" style="font-size: 3rem;"',
     ' class="bi bi-droplet-fill text-primary icon-hero"'),
    (' class="text-center mt-4 text-muted" style="font-size: 0.85rem;"',
     ' class="text-center mt-4 text-muted helper-note"'),
    (' class="text-muted d-block mt-1" style="font-size: 0.76rem;"',
     ' class="text-muted d-block mt-1 text-hint"'),
    (' class="text-muted" style="font-size: 0.76rem;"',
     ' class="text-muted text-hint"'),
    (' class="text-muted" style="font-size: 0.74rem;"',
     ' class="text-muted text-xs"'),
    (' class="text-muted fw-normal" style="font-size: 0.75rem;"',
     ' class="text-muted fw-normal text-micro"'),
    (' class="text-muted" style="font-size: 0.75rem;"',
     ' class="text-muted text-micro"'),
    (' class="text-muted" style="font-size: 0.78rem;"',
     ' class="text-muted text-caption"'),
    (' class="bi bi-tag-fill text-muted" style="font-size: 0.72rem;"',
     ' class="bi bi-tag-fill text-muted icon-xs"'),
    (' class="bi bi-tree-fill" style="font-size: 0.72rem;"',
     ' class="bi bi-tree-fill icon-xs"'),
    (' class="bi bi-circle-fill text-primary me-1" style="font-size: 8px;"',
     ' class="bi bi-circle-fill text-primary me-1 icon-legend"'),
    (' class="bi bi-circle-fill text-success me-1" style="font-size: 8px;"',
     ' class="bi bi-circle-fill text-success me-1 icon-legend"'),
    (' class="bi bi-circle-fill text-danger me-1" style="font-size: 8px;"',
     ' class="bi bi-circle-fill text-danger me-1 icon-legend"'),
    (' class="bi bi-circle-fill text-danger me-1" style="font-size: 0.6rem;"',
     ' class="bi bi-circle-fill text-danger me-1 icon-dot"'),
    (' class="bi bi-circle-fill text-success me-1" style="font-size: 0.6rem;"',
     ' class="bi bi-circle-fill text-success me-1 icon-dot"'),
    (' class="bi bi-circle-fill text-warning me-1" style="font-size: 0.6rem;"',
     ' class="bi bi-circle-fill text-warning me-1 icon-dot"'),
    (' class="text-secondary small d-inline-block text-truncate" style="max-width: 220px;"',
     ' class="text-secondary small d-inline-block text-truncate truncate-cell"'),
    (' class="text-dark fw-medium" style="line-height: 1.4;"',
     ' class="text-dark fw-medium diagnosis-text"'),
    (' class="rounded-circle p-2 bg-white border d-flex align-items-center justify-content-center text-primary" style="width: 36px; height: 36px;"',
     ' class="rounded-circle p-2 bg-white border d-flex align-items-center justify-content-center text-primary toggle-icon-circle"'),
    (' class="form-check-label fw-bold text-dark d-block mb-0" for="statusSwitch" style="font-size: 0.88rem; cursor: pointer;"',
     ' class="form-check-label fw-bold text-dark d-block mb-0 toggle-title" for="statusSwitch"'),
    ('<span style="color: #94a3b8;">&bull;</span>',
     '<span class="footer-separator">&bull;</span>'),
    ('<div style="position: relative; height: 320px; width: 100%;">',
     '<div class="chart-canvas-wrap">'),
]

TH_WIDTHS = {
    "8%": "col-w-8",
    "11%": "col-w-11",
    "12%": "col-w-12",
    "15%": "col-w-15",
    "16%": "col-w-16",
    "17%": "col-w-17",
    "18%": "col-w-18",
    "20%": "col-w-20",
    "22%": "col-w-22",
    "23%": "col-w-23",
    "24%": "col-w-24",
    "25%": "col-w-25",
    "26%": "col-w-26",
    "28%": "col-w-28",
}


def strip_style_blocks(text: str) -> str:
    text = re.sub(r"\n?<!-- Custom Navbar Styles nhúng trực tiếp -->\n?", "\n", text)
    return re.sub(r"\s*<style[\s\S]*?</style>\s*", "\n", text, flags=re.IGNORECASE)


def ensure_css_link(text: str, filename: str) -> str:
    if filename in {"navbar.jsp", "footer.jsp"}:
        return text
    text = text.replace(APP_LINK, CSS_LINK)
    if CSS_LINK not in text:
        # insert after bootstrap icons if present, else after bootstrap css
        marker = 'href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">'
        if marker in text:
            text = text.replace(marker, marker + "\n    " + CSS_LINK, 1)
        else:
            text = text.replace("</head>", "    " + CSS_LINK + "\n</head>", 1)
    return text


def replace_th_widths(text: str) -> str:
    def repl(m):
        width = m.group(1)
        cls = TH_WIDTHS.get(width)
        rest = m.group(2) or ""
        if not cls:
            return m.group(0)
        if 'class="' in rest:
            rest = rest.replace('class="', f'class="{cls} ', 1)
            return f"<th{rest}"
        return f'<th class="{cls}"{rest}'

    return re.sub(r'<th\s+style="width:\s*([0-9]+%);"([^>]*)>', repl, text)


def apply_translations(text: str) -> str:
    for src, dst in TRANSLATIONS:
        text = text.replace(src, dst)
    return text


def process(path: Path) -> None:
    original = path.read_text(encoding="utf-8")
    text = original
    text = strip_style_blocks(text)
    text = ensure_css_link(text, path.name)
    text = text.replace('html lang="vi"', 'html lang="en"')
    for old, new in INLINE_REPLACEMENTS:
        text = text.replace(old, new)
    text = replace_th_widths(text)
    text = apply_translations(text)
    # leftover Vietnamese comments can stay; clean extra blank lines after head start
    text = re.sub(r"\n{3,}", "\n\n", text)
    if text != original:
        path.write_text(text, encoding="utf-8")
        print(f"updated {path.name}")
    else:
        print(f"unchanged {path.name}")


def main():
    for path in sorted(VIEWS.glob("*.jsp")):
        process(path)


if __name__ == "__main__":
    main()
