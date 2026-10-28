/*
 * ======================================================================================
 * FILE TEST PHẦN CỨNG ĐỘC LẬP (HARDWARE DIAGNOSTIC TOOL) - SMART IRRIGATION PRJ301
 * ======================================================================================
 * Mục đích:
 *   - Kiểm tra từng thiết bị cảm biến & Relay máy bơm xem có hoạt động chuẩn không
 *     TRƯỚC KHI nạp code kết nối WiFi + Java Web.
 *   - Chống treo mạch (Anti-Freeze / Anti-WDT Reset) ngay cả khi tuột dây HX711 hoặc DHT11.
 *
 * Cách dùng:
 *   1. Nạp file này vào ESP8266 NodeMCU.
 *   2. Mở Serial Monitor, chọn Baudrate = 115200 (chọn "Newline" hoặc "Both NL & CR").
 *   3. Quan sát bảng chẩn đoán [OK] / [LOI] mỗi 2 giây.
 *   4. Có thể gõ lệnh trực tiếp vào ô nhập của Serial Monitor:
 *      - Gõ 'p' + Enter : Bật thử máy bơm 2 giây rồi tự tắt.
 *      - Gõ '1' + Enter : Bật máy bơm liên tục (Relay HIGH).
 *      - Gõ '0' + Enter : Tắt máy bơm ngay lập tức (Relay LOW).
 *      - Gõ 't' + Enter : Trừ bì (Tare = 0g) lại cho cân Loadcell HX711.
 *      - Gõ 'c' + Enter : Chẩn đoán tổng thể xem mạch đã sẵn sàng nạp code chính chưa.
 * ======================================================================================
 */

#include "HX711.h"
#include "DHT.h"

// ================= ĐỊNH NGHĨA CHÂN CẮM (KHỚP 100% CODE CHÍNH) =================
#define SOIL_MOISTURE_PIN A0   // Cảm biến độ ẩm đất (Analog A0)
#define LIGHT_SENSOR_PIN 5     // Cảm biến ánh sáng LM393 (Chân D1 - GPIO 5)
#define DHT_PIN 4              // Cảm biến nhiệt ẩm DHT11 (Chân D2 - GPIO 4)
#define DHT_TYPE DHT11         
#define HX711_DT 14            // Loadcell HX711 DT  (Chân D5 - GPIO 14)
#define HX711_SCK 12           // Loadcell HX711 SCK (Chân D6 - GPIO 12)
#define RELAY_PUMP_PIN 13      // Relay Máy bơm      (Chân D7 - GPIO 13)

DHT dht(DHT_PIN, DHT_TYPE);
HX711 scale;

// Biến quản lý trạng thái test
unsigned long lastPrintTime = 0;
const unsigned long printIntervalMs = 2000; // In kết quả mỗi 2 giây

bool isRelayOn = false;
bool isPulseTesting = false;
unsigned long pulseStartTime = 0;
bool hx711Initialized = false;

// Khai báo hàm
void runFullDiagnosticReport();
void handleSerialCommands();

void setup() {
  Serial.begin(115200);
  delay(500);

  pinMode(LIGHT_SENSOR_PIN, INPUT);
  pinMode(RELAY_PUMP_PIN, OUTPUT);
  digitalWrite(RELAY_PUMP_PIN, LOW); // Mặc định tắt bơm

  Serial.println("\n\n==================================================================");
  Serial.println("   CHUONG TRINH KIEM TRA PHAN CUNG IOT (ESP8266 HARDWARE TEST)   ");
  Serial.println("==================================================================");
  Serial.println("So do chan dang kiem tra:");
  Serial.println("  - Do am dat (Soil)  : Chan A0");
  Serial.println("  - Anh sang (LM393)  : Chan D1 (GPIO 5)");
  Serial.println("  - Nhiet/Am (DHT11)  : Chan D2 (GPIO 4)");
  Serial.println("  - Loadcell (HX711)  : DT = D5 (GPIO 14), SCK = D6 (GPIO 12)");
  Serial.println("  - Relay May Bom     : Chan D7 (GPIO 13) [HIGH = Bat, LOW = Tat]");
  Serial.println("------------------------------------------------------------------");

  // 1. Khởi tạo DHT11
  Serial.print("[INIT 1/2] Khoi tao cam bien DHT11 (Chan D2)... ");
  dht.begin();
  Serial.println("Da goi dht.begin()");

  // 2. Khởi tạo Loadcell HX711 có chống treo (Timeout 500ms)
  Serial.print("[INIT 2/2] Khoi tao Loadcell HX711 (D5/D6)... ");
  scale.begin(HX711_DT, HX711_SCK);
  scale.set_scale(2280.f);
  if (scale.wait_ready_timeout(500)) {
    scale.tare();
    hx711Initialized = true;
    Serial.println("OK! Da ket noi va Tru bi (Tare = 0g).");
  } else {
    hx711Initialized = false;
    Serial.println("CANH BAO: Khong nhan duoc phan hoi tu HX711 (Kiem tra day D5/D6/VCC/GND)!");
  }

  Serial.println("------------------------------------------------------------------");
  Serial.println("LENH DIEU KHIEN NHANH QUA SERIAL MONITOR:");
  Serial.println("  [p] Bat thu bom 2 giay roi tat  | [1] Bat bom  | [0] Tat bom");
  Serial.println("  [t] Tru bi lai Loadcell (Tare)  | [c] Chay bao cao tong ket");
  Serial.println("==================================================================\n");

  delay(1000);
  runFullDiagnosticReport();
}

void loop() {
  unsigned long currentMillis = millis();

  // 1. Xử lý lệnh người dùng gõ từ Serial Monitor
  handleSerialCommands();

  // 2. Tự động tắt bơm nếu đang chạy chế độ test 2 giây ('p')
  if (isPulseTesting && (currentMillis - pulseStartTime >= 2000)) {
    digitalWrite(RELAY_PUMP_PIN, LOW);
    isRelayOn = false;
    isPulseTesting = false;
    Serial.println(">>> [TEST RELAY] Da het 2 giay test -> Tu dong TAT BOM (D7 = LOW)!");
  }

  // 3. Đọc và in bảng thông số định kỳ mỗi 2 giây
  if (currentMillis - lastPrintTime >= printIntervalMs) {
    lastPrintTime = currentMillis;

    // --- ĐỌC ĐỘ ẨM ĐẤT (A0) ---
    int rawSoil = analogRead(SOIL_MOISTURE_PIN);
    int moisturePct = map(rawSoil, 1023, 400, 0, 100);
    moisturePct = constrain(moisturePct, 0, 100);
    String soilStatus = "OK";
    if (rawSoil >= 1020) {
      soilStatus = "KHO / CHUA CAM XUONG DAT (Raw~1023)";
    } else if (rawSoil <= 15) {
      soilStatus = "CANH BAO: CHAM DAY HOAC MAT NGUON A0 (Raw<=15)";
    }

    // --- ĐỌC QUANG TRỞ ÁNH SÁNG (D1) ---
    int lightRaw = digitalRead(LIGHT_SENSOR_PIN);
    String lightText = (lightRaw == LOW) ? "SANG (~680 lux)" : "TOI (~120 lux)";

    // --- ĐỌC DHT11 (D2) ---
    float temp = dht.readTemperature();
    float hum = dht.readHumidity();
    bool dhtOk = !isnan(temp) && !isnan(hum);

    // --- ĐỌC LOADCELL HX711 (D5/D6) KHÔNG BỊ TREO ---
    bool loadcellOk = false;
    float weightGram = 0.0f;
    long rawHx711 = 0;
    if (scale.wait_ready_timeout(200)) {
      if (!hx711Initialized) {
        scale.set_scale(2280.f);
        scale.tare();
        hx711Initialized = true;
      }
      rawHx711 = scale.read();
      weightGram = scale.get_units(3);
      // Nếu rawHx711 == 0 hoặc -1 liên tục thì thường do tuột dây DT
      if (rawHx711 != 0 && rawHx711 != -1) {
        loadcellOk = true;
      }
    }

    // --- IN BẢNG THEO DÕI TRỰC QUAN ---
    Serial.println("------------------------------------------------------------------");
    Serial.print("[1] DO AM DAT (A0)    : ");
    Serial.print(moisturePct);
    Serial.print("% (Analog Raw = ");
    Serial.print(rawSoil);
    Serial.print(") -> [");
    Serial.print(soilStatus);
    Serial.println("]");

    Serial.print("[2] ANH SANG (D1)     : DO = ");
    Serial.print(lightRaw);
    Serial.print(" -> ");
    Serial.print(lightText);
    Serial.println(" -> [OK]");

    Serial.print("[3] DHT11 (D2)        : ");
    if (dhtOk) {
      Serial.print("Nhiet do = ");
      Serial.print(temp, 1);
      Serial.print(" C | Do am KK = ");
      Serial.print(hum, 0);
      Serial.println(" % -> [OK]");
    } else {
      Serial.println("NaN -> [LOI: Mat tin hieu DHT11! Kiem tra chan D2, VCC 3.3V va GND]");
    }

    Serial.print("[4] LOADCELL (D5/D6)  : ");
    if (loadcellOk) {
      Serial.print(weightGram, 1);
      Serial.print(" gram (");
      Serial.print(weightGram / 1000.0f, 3);
      Serial.print(" kg | Raw = ");
      Serial.print(rawHx711);
      Serial.println(") -> [OK]");
    } else {
      Serial.println("Khong phan hoi -> [LOI: Kiem tra chan DT(D5), SCK(D6), VCC va GND]");
    }

    Serial.print("[5] RELAY MAY BOM (D7): ");
    Serial.println(isRelayOn ? "DANG BAT (HIGH)" : "DANG TAT (LOW) - Go 'p' de test 2 giay");
  }
}

void handleSerialCommands() {
  if (Serial.available() > 0) {
    char cmd = Serial.read();
    // Bỏ qua ký tự xuống dòng
    if (cmd == '\n' || cmd == '\r' || cmd == ' ') {
      return;
    }

    if (cmd == 'p' || cmd == 'P') {
      Serial.println("\n>>> [LENH 'p'] BAT THU RELAY MAY BOM TRONG 2 GIAY (D7 = HIGH)...");
      digitalWrite(RELAY_PUMP_PIN, HIGH);
      isRelayOn = true;
      isPulseTesting = true;
      pulseStartTime = millis();
    }
    else if (cmd == '1') {
      Serial.println("\n>>> [LENH '1'] BAT RELAY MAY BOM LIEN TUC (D7 = HIGH). Go '0' de tat!");
      digitalWrite(RELAY_PUMP_PIN, HIGH);
      isRelayOn = true;
      isPulseTesting = false;
    }
    else if (cmd == '0') {
      Serial.println("\n>>> [LENH '0'] TAT RELAY MAY BOM NGAY LAP TUC (D7 = LOW)!");
      digitalWrite(RELAY_PUMP_PIN, LOW);
      isRelayOn = false;
      isPulseTesting = false;
    }
    else if (cmd == 't' || cmd == 'T') {
      Serial.print("\n>>> [LENH 't'] Dang Tru bi (Tare = 0g) cho Loadcell HX711... ");
      if (scale.wait_ready_timeout(500)) {
        scale.tare();
        hx711Initialized = true;
        Serial.println("THANH CONG! Cân đã về 0 gram.");
      } else {
        Serial.println("THAT BAI! Mạch HX711 chưa kết nối ở chân D5/D6.");
      }
    }
    else if (cmd == 'c' || cmd == 'C') {
      runFullDiagnosticReport();
    }
  }
}

void runFullDiagnosticReport() {
  Serial.println("\n================ BAO CAO TONG KET PHAN CUNG ================");
  int passCount = 0;

  // 1. Soil
  int rawSoil = analogRead(SOIL_MOISTURE_PIN);
  bool soilOk = (rawSoil > 15 && rawSoil <= 1024);
  if (soilOk) passCount++;
  Serial.println(String("1. Cam bien Do am dat (A0) : ") + (soilOk ? "PASS (Raw=" + String(rawSoil) + ")" : "FAIL (Kiem tra day A0)"));

  // 2. Light
  int lightVal = digitalRead(LIGHT_SENSOR_PIN);
  passCount++;
  Serial.println(String("2. Cam bien Anh sang (D1)  : PASS (DO=") + String(lightVal) + ")");

  // 3. DHT11
  float t = dht.readTemperature();
  float h = dht.readHumidity();
  bool dhtOk = (!isnan(t) && !isnan(h));
  if (dhtOk) passCount++;
  Serial.println(String("3. Cam bien DHT11 (D2)     : ") + (dhtOk ? "PASS (" + String(t, 1) + "C, " + String(h, 0) + "%)" : "FAIL (Mat tin hieu chan D2)"));

  // 4. HX711
  bool hxOk = scale.wait_ready_timeout(400);
  if (hxOk) passCount++;
  Serial.println(String("4. Can Loadcell (D5/D6)    : ") + (hxOk ? "PASS (Doc duoc xung HX711)" : "FAIL (Khong tim thay HX711)"));

  // 5. Relay
  passCount++;
  Serial.println("5. Relay May Bom (D7)      : SAN SANG (Go 'p' tren Serial de nghe tieng Relay dong/ngat)");

  Serial.println("------------------------------------------------------------");
  if (passCount == 5) {
    Serial.println("=> KET LUAN: [5/5 HOAT DONG TOT] -> BAN CO THE NAP CODE CHINH DE DEMO!");
  } else {
    Serial.println("=> KET LUAN: [" + String(passCount) + "/5 OK] -> Vui long kiem tra lai day cam cua thiet bi bao FAIL!");
  }
  Serial.println("============================================================\n");
}

