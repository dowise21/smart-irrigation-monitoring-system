package service;

import dao.AlertDAO;
import java.util.logging.Logger;

public class AlertService {

    private static final Logger LOGGER = Logger.getLogger(AlertService.class.getName());
    private final AlertDAO alertDAO = new AlertDAO();

    /**
     * 1. Phân tích sau mỗi phiên tưới (Phát hiện OVERWATER và SENSOR_FAULT)
     * Gọi hàm này khi mạch ESP32 tưới xong hoặc khi sinh dữ liệu mẫu.
     */
    public void analyzeWateringSession(int potId, int sessionId, double waterMl, double retainRatio, double moistureBefore, double moistureAfter) {
        
        // LUẬT 1: TƯỚI THỪA (OVERWATER)
        // Điều kiện: Tưới nhiều nước (>1000ml) nhưng tỷ lệ giữ nước (Retain Ratio) lại quá thấp (< 0.5 tức 50%)
        if (waterMl >= 1000 && retainRatio < 0.5) {
            String msg = String.format("Cảnh báo tưới thừa! Đã dùng %.0f ml nước nhưng tỷ lệ giữ nước chỉ đạt %.0f%%. Nước đang bị tràn hoặc chảy lãng phí ra ngoài.", waterMl, retainRatio * 100);
            alertDAO.insertAlert(potId, sessionId, "OVERWATER", msg);
            LOGGER.info(" Đã phát hiện và ghi nhận lỗi OVERWATER cho chậu " + potId);
        }

        // LUẬT 2: LỖI CẢM BIẾN (SENSOR_FAULT)
        // Điều kiện: Đã bơm nước vào chậu nhưng độ ẩm (Moisture) sau khi tưới lại bằng hoặc thấp hơn trước khi tưới
        if (waterMl > 0 && moistureAfter <= moistureBefore) {
            String msg = String.format("Cảm biến nghi lỗi! Mạch báo đã tưới %.0f ml nhưng độ ẩm không tăng (Trước: %.1f%%, Sau: %.1f%%).", waterMl, moistureBefore, moistureAfter);
            alertDAO.insertAlert(potId, sessionId, "SENSOR_FAULT", msg);
            LOGGER.info(" Đã phát hiện và ghi nhận lỗi SENSOR_FAULT cho chậu " + potId);
        }
    }

    /**
     * 2. Phân tích dữ liệu cảm biến định kỳ (Phát hiện DRY_STRESS và LEAK)
     * Gọi hàm này mỗi khi cảm biến gửi độ ẩm mới lên.
     */
    public void checkSensorReading(int potId, double currentMoisture, double dryRate) {
        
        // LUẬT 3: CÂY THIẾU NƯỚC (DRY_STRESS)
        // Điều kiện: Độ ẩm đất tụt xuống dưới ngưỡng an toàn (Ví dụ: < 30%)
        if (currentMoisture < 30.0) {
            String msg = String.format("Cây đang thiếu nước! Độ ẩm hiện tại là %.1f%%, thấp hơn ngưỡng an toàn. Cần rút ngắn chu kỳ tưới.", currentMoisture);
            alertDAO.insertAlert(potId, null, "DRY_STRESS", msg);
            LOGGER.info(" Đã phát hiện và ghi nhận lỗi DRY_STRESS cho chậu " + potId);
        }

        // LUẬT 4: RÒ RỈ NƯỚC (LEAK)
        // Điều kiện: Dry Rate (tốc độ khô/giảm khối lượng) diễn ra nhanh một cách bất thường dù trời không nắng gắt
        if (dryRate > 5.0) { // Giả định > 5.0 kg/ngày là bất thường
            String msg = String.format("Nghi ngờ rò rỉ nước! Tốc độ khô đạt %.1f (mức bất thường). Hãy kiểm tra lại đáy chậu.", dryRate);
            alertDAO.insertAlert(potId, null, "LEAK", msg);
            LOGGER.info(" Đã phát hiện và ghi nhận lỗi LEAK cho chậu " + potId);
        }
    }
}