function doPost(e) {
  try {
    var jsonData = JSON.parse(e.postData.contents);
    
    // Chỉ nhận các thông số cơ bản từ ESP8266
    var potId = jsonData.potId;
    var alertType = jsonData.alertType; 
    var alertMessage = jsonData.alertMessage;
    
    // ==========================================
    // CẤU HÌNH EMAIL CỐ ĐỊNH TẠI ĐÂY
    // Người gửi: Tự động là tài khoản Gmail bạn đang dùng tạo Script
    var emailNhan = "levanngoan2104@gmail.com"; // Có thể thêm nhiều email: "email1@gmail.com, email2@gmail.com"
    // ==========================================
    
    var alertColor = "#d9534f"; 
    if (alertType === "SENSOR_FAULT") alertColor = "#f0ad4e"; 
    if (alertType === "OVERWATER") alertColor = "#0275d8"; 
    
    var subject = "[CẢNH BÁO HỆ THỐNG] " + alertType + " - Chậu số " + potId;
    var htmlBody = "<h2 style='color:" + alertColor + ";'>EcoIrrigation - Phát hiện sự cố</h2>" +
                   "<p>Hệ thống vừa ghi nhận một sự cố <b>" + alertType + "</b> tại chậu số " + potId + ".</p>" +
                   "<div style='background-color:#f8f9fa; padding:15px; border-left:4px solid " + alertColor + ";'>" +
                   "<strong>Chi tiết sự cố:</strong> " + alertMessage + 
                   "</div>" +
                   "<p>Vui lòng truy cập Dashboard để kiểm tra và xử lý ngay.</p>";

    // Ra lệnh cho Google gửi Mail
    MailApp.sendEmail({
      to: emailNhan,
      subject: subject,
      htmlBody: htmlBody
    });

    return ContentService.createTextOutput(JSON.stringify({"status": "success"})).setMimeType(ContentService.MimeType.JSON);

  } catch (error) {
    return ContentService.createTextOutput(JSON.stringify({"status": "error", "message": error.toString()})).setMimeType(ContentService.MimeType.JSON);
  }
}