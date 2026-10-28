#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecure.h> 
#include <ArduinoJson.h>
#include "HX711.h"
#include "DHT.h"

// ================= 1. CẤU HÌNH MẠNG & API JAVA WEB =================
const char* ssid = "Cafe MTV";
const char* password = "69696969@";

String serverTelemetryUrl = "http://192.168.1.28:8080/PRJ301_Smart_Irrigation_System/api/sensor/readings";
String serverCommandUrl   = "http://192.168.1.28:8080/PRJ301_Smart_Irrigation_System/api/watering/command";

int potId = 1; // Mặc định Chậu #1 khi mới khởi động, tự động đổi theo Web UI hoặc gõ số 1..9 trên Serial Monitor!

// ===== NGƯỠNG ĐỘ ẨM ĐỘNG & THÔNG TIN CHẬU ĐANG GẮN MẠCH VẬT LÝ (ĐỒNG BỘ TỪ DATABASE WEB) =====
float minMoistureThreshold = 35.0f; // Ngưỡng kích hoạt tưới tự động & cảnh báo Khô hạn (DRY_STRESS)
float maxMoistureThreshold = 75.0f; // Ngưỡng cảnh báo Ngập úng (OVERWATER) & tự ngắt bơm bảo vệ
String currentPotName      = "Chau #1";
String currentPlantName    = "Cay trong";

// ===== CẤU HÌNH GỬI EMAIL GOOGLE APPS SCRIPT (4 LOẠI CẢNH BÁO) =====
String googleScriptUrl = "https://script.google.com/macros/s/AKfycbwVZQ8jL_4cmWpIKg6QnBNt05nPE5l7s8k6e4_rnge6VycvibPNlRO3rpipRDrDIITB/exec"; 
unsigned long lastEmailTime = 0;
const unsigned long emailCooldown = 300000; // Cooldown 5 phút cho cùng 1 loại cảnh báo
String lastAlertTypeSent = "";              // Cho phép gửi ngay nếu chuyển sang kịch bản cảnh báo khác khi Demo

// Biến lưu cảnh báo do Java Backend phát hiện từ lịch sử DB (ví dụ: LEAK - Rò rỉ nước)
String serverDetectedAlertType = "";
String serverDetectedAlertMsg  = "";

// ================= 3. ĐỊNH NGHĨA CHÂN PHẦN CỨNG =================
#define SOIL_MOISTURE_PIN A0   
#define LIGHT_SENSOR_PIN 5     
#define DHT_PIN 4              
#define DHT_TYPE DHT11         
#define HX711_DT 14            
#define HX711_SCK 12           
#define RELAY_PUMP_PIN 13      

DHT dht(DHT_PIN, DHT_TYPE);
HX711 scale;

// ===== CÁC BIẾN QUẢN LÝ THỜI GIAN (NON-BLOCKING MILLIS) =====
unsigned long previousMillis = 0;
unsigned long lastCommandCheckTime = 0;

// Biến quản lý trạng thái máy bơm
bool isPumpRunning = false;
unsigned long pumpStartTime = 0;
unsigned long pumpDurationMs = 0;

// Khai báo hàm
void triggerAlertEmailIfNeeded(String alertType, String alertMessage);
void sendEmailViaGoogleScript(String alertType, String alertMessage);
void sendDataToWebApp(int moisture, int light, float temp, float hum, float weight, bool hasSensorFault, String faultMsg);
void checkCommandFromWebApp();
void notifyPumpStoppedToWebApp();
void syncPlantThresholdFromJson(const JsonDocument& doc);
void checkSerialPotSwitch();

void setup() {
  Serial.begin(115200);
  
  pinMode(LIGHT_SENSOR_PIN, INPUT);
  pinMode(RELAY_PUMP_PIN, OUTPUT);
  digitalWrite(RELAY_PUMP_PIN, LOW); // Mặc định tắt máy bơm

  dht.begin();
  scale.begin(HX711_DT, HX711_SCK);
  scale.set_scale(2280.f); 
  if (scale.wait_ready_timeout(500)) {
    scale.tare();
  } else {
    Serial.println("[WARN] HX711 chua san sang luc khoi dong - bo qua tare() de chong treo mach!");
  }

  WiFi.begin(ssid, password);
  Serial.print("\nKet noi WiFi");
  while (WiFi.status() != WL_CONNECTED) { 
    delay(500); 
    Serial.print("."); 
  }
  Serial.println("\nOK! IP ESP8266: " + WiFi.localIP().toString());
  Serial.println(">>> MEO DEMO NHIEU CHAU (1 MAY BOM VAT LY):");
  Serial.println("    - Cach 1: Bam nut 'Gan Mach & Bom' hoac chon Chau tren Giao dien Web.");
  Serial.println("    - Cach 2: Go so thu tu Chau (1, 2, 3, 4...) vao o Serial Monitor nay roi nhan Enter!");
}

void loop() {
  unsigned long currentMillis = millis();

  // Cho phép đổi nhanh Chậu gắn với mạch ESP8266 & Máy bơm ngay từ Serial Monitor (gõ 1, 2, 3, 4...)
  checkSerialPotSwitch();

  // -------------------------------------------------------------
  // LOGIC 1: TỰ ĐỘNG TẮT BƠM KHI HẾT HẸN GIỜ (NON-BLOCKING)
  // -------------------------------------------------------------
  if (isPumpRunning) {
    if (currentMillis - pumpStartTime >= pumpDurationMs) {
      digitalWrite(RELAY_PUMP_PIN, LOW); // Tắt bơm
      isPumpRunning = false;
      Serial.println(">>> DA HET THOI GIAN HEN GIO: Tu dong tat bom!");
      
      // Báo về Java Web rằng bơm đã tắt để giao diện Web đồng bộ về trạng thái OFF
      notifyPumpStoppedToWebApp();
    }
  }

  // -------------------------------------------------------------
  // LOGIC 2: ĐỌC 4 CẢM BIẾN, ĐỒNG BỘ WEB & KIỂM TRA 4 LOẠI CẢNH BÁO (Mỗi 5 giây)
  // -------------------------------------------------------------
  if (currentMillis - previousMillis >= 5000) {
    previousMillis = currentMillis;
    
    int moisture = map(analogRead(SOIL_MOISTURE_PIN), 1023, 400, 0, 100);
    moisture = constrain(moisture, 0, 100);
    float t = dht.readTemperature();
    float h = dht.readHumidity();
    float weight = scale.wait_ready_timeout(200) ? scale.get_units(3) : -999.0f; 
    int light = digitalRead(LIGHT_SENSOR_PIN);

    // Kiểm tra lỗi phần cứng cảm biến (DHT11 trả về NaN hoặc Loadcell HX711 tuột dây < -500)
    bool hasSensorFault = (isnan(t) || isnan(h) || weight < -500.0f);
    String faultMsg = "";
    if (hasSensorFault) {
      faultMsg = "Mat tin hieu tu cam bien ";
      if (isnan(t) || isnan(h)) faultMsg += "DHT11 (Chân D2) ";
      if (weight < -500.0f)     faultMsg += "Loadcell HX711 (Chân D5/D6) ";
      faultMsg += "tai chau [" + currentPlantName + "]. Vui long kiem tra day cam!";
    }

    // 1. Gửi dữ liệu lên Java Web Backend:
    //    - Backend tự động lưu SQL Server, kiểm tra 4 quy tắc cảnh báo (bao gồm LEAK rò rỉ nước),
    //    - Nếu moisture < min_moisture_threshold, Backend tự động xếp lệnh START bơm (AUTO) vào hàng đợi,
    //    - Đồng thời trả về minMoisture, maxMoisture, plantName và alertType mới nhất.
    serverDetectedAlertType = "";
    serverDetectedAlertMsg  = "";
    sendDataToWebApp(moisture, light, t, h, weight, hasSensorFault, faultMsg);

    // 2. Bảo vệ chống ngập úng tức thì tại biên: nếu độ ẩm vượt ngưỡng tối đa khi bơm đang chạy -> Ngắt ngay
    if (moisture > maxMoistureThreshold && isPumpRunning) {
      digitalWrite(RELAY_PUMP_PIN, LOW);
      isPumpRunning = false;
      Serial.println(">>> [BAO VE NGAP UNG] Do am dat vuot nguong Max -> Ngat bom khan cap!");
      notifyPumpStoppedToWebApp();
    }

    // 3. Xử lý gửi Email cho đủ 4 Loại Cảnh báo Sự cố:
    //    Ưu tiên 1: Cảnh báo Lỗi cảm biến (SENSOR_FAULT)
    if (hasSensorFault) {
      triggerAlertEmailIfNeeded("SENSOR_FAULT", faultMsg);
    }
    //    Ưu tiên 2: Cảnh báo Rò rỉ nước (LEAK) do Java Backend phát hiện từ lịch sử SensorReading
    else if (serverDetectedAlertType == "LEAK") {
      triggerAlertEmailIfNeeded("LEAK", serverDetectedAlertMsg);
    }
    //    Ưu tiên 3: Cảnh báo Ngập úng (OVERWATER: moisture > max_moisture_threshold)
    else if (moisture > maxMoistureThreshold) {
      String msg = "Canh bao ngap ung chau [" + currentPlantName + "]: Do am dat dat "
                 + String(moisture) + "%, vuot nguong toi da cho phep ("
                 + String(maxMoistureThreshold, 1) + "%). He thong da khoa may bom!";
      triggerAlertEmailIfNeeded("OVERWATER", msg);
    }
    //    Ưu tiên 4: Cảnh báo Khô hạn (DRY_STRESS: moisture < min_moisture_threshold)
    else if (moisture < minMoistureThreshold) {
      String msg = "Canh bao kho han chau [" + currentPlantName + "]: Do am dat hien tai rot xuong "
                 + String(moisture) + "% (thap hon nguong kich hoat tuoi "
                 + String(minMoistureThreshold, 1) + "%). He thong dang kich hoat bom tu dong!";
      triggerAlertEmailIfNeeded("DRY_STRESS", msg);
    }
  }

  // -------------------------------------------------------------
  // LOGIC 3: NHẬN LỆNH ĐIỀU KHIỂN TỪ WEB / AUTO-WATERING (Mỗi 1 giây)
  // -------------------------------------------------------------
  if (currentMillis - lastCommandCheckTime >= 1000) {
    lastCommandCheckTime = currentMillis;
    checkCommandFromWebApp();
  }
}

// ---------------------- CÁC HÀM XỬ LÝ CON ----------------------

// CẬP NHẬT CHẬU ĐANG GẮN MẠCH VẬT LÝ (POT ID), NGƯỠNG ĐỘ ẨM ĐỘNG (MIN / MAX) & CẢNH BÁO TỪ SERVER JAVA WEB
void syncPlantThresholdFromJson(const JsonDocument& doc) {
  int previousPotId = potId;
  if (doc.containsKey("activePotId")) {
    int newPotId = doc["activePotId"].as<int>();
    if (newPotId > 0) {
      potId = newPotId;
    }
  } else if (doc.containsKey("potId")) {
    int newPotId = doc["potId"].as<int>();
    if (newPotId > 0) {
      potId = newPotId;
    }
  }
  if (doc.containsKey("potName")) {
    String pName = doc["potName"].as<String>();
    if (pName.length() > 0) {
      currentPotName = pName;
    }
  }
  if (doc.containsKey("minMoisture")) {
    float newMin = doc["minMoisture"].as<float>();
    if (newMin > 0.0f && newMin <= 100.0f) {
      minMoistureThreshold = newMin;
    }
  }
  if (doc.containsKey("maxMoisture")) {
    float newMax = doc["maxMoisture"].as<float>();
    if (newMax > 0.0f && newMax <= 100.0f) {
      maxMoistureThreshold = newMax;
    }
  }
  if (doc.containsKey("plantName")) {
    String name = doc["plantName"].as<String>();
    if (name.length() > 0) {
      currentPlantName = name;
    }
  }
  if (doc.containsKey("alertType")) {
    serverDetectedAlertType = doc["alertType"].as<String>();
  }
  if (doc.containsKey("alertMessage")) {
    serverDetectedAlertMsg = doc["alertMessage"].as<String>();
  }
  if (potId != previousPotId) {
    Serial.println("\n>>> [GAN MACH & BOM VAT LY] Da chuyen ESP8266 + May bom sang Chau #"
      + String(potId) + ": " + currentPotName + " (" + currentPlantName
      + " | Nguong: " + String(minMoistureThreshold, 0) + "% - " + String(maxMoistureThreshold, 0) + "%)");
  }
}

// CHO PHÉP GÕ SỐ CHẬU (1, 2, 3, 4...) TRÊN SERIAL MONITOR ĐỂ CHUYỂN MẠCH & BƠM SANG CHẬU ĐÓ NGAY LẬP TỨC
void checkSerialPotSwitch() {
  if (Serial.available() > 0) {
    String input = Serial.readStringUntil('\n');
    input.trim();
    int requestedPot = input.toInt();
    if (requestedPot > 0) {
      potId = requestedPot;
      Serial.println("\n>>> [SERIAL SWITCH] Dang chuyen Mach ESP8266 & May bom sang Chau #" + String(potId) + "...");
      if (WiFi.status() == WL_CONNECTED) {
        WiFiClient client;
        HTTPClient http;
        http.begin(client, serverCommandUrl + "?bindPotId=" + String(potId));
        int httpCode = http.GET();
        if (httpCode == 200) {
          StaticJsonDocument<512> doc;
          if (!deserializeJson(doc, http.getString())) {
            syncPlantThresholdFromJson(doc);
          }
        }
        http.end();
      }
    }
  }
}

// KIỂM TRA COOLDOWN THÔNG MINH: Cho phép gửi ngay nếu chuyển sang loại cảnh báo mới khi Demo
void triggerAlertEmailIfNeeded(String alertType, String alertMessage) {
  unsigned long now = millis();
  bool isDifferentAlertType = (alertType != lastAlertTypeSent);
  if (isDifferentAlertType || lastEmailTime == 0 || (now - lastEmailTime >= emailCooldown)) {
    sendEmailViaGoogleScript(alertType, alertMessage);
    lastEmailTime = now;
    lastAlertTypeSent = alertType;
  }
}

void sendEmailViaGoogleScript(String alertType, String alertMessage) {
  Serial.println("\n[ALERT EMAIL] Phat hien " + alertType + " -> Dang gui Google Apps Script...");
  
  if (WiFi.status() == WL_CONNECTED) {
    WiFiClientSecure client;
    client.setInsecure(); // Bỏ qua kiểm tra chứng chỉ SSL để tiết kiệm RAM trên ESP8266
    
    HTTPClient http;
    http.setFollowRedirects(HTTPC_FORCE_FOLLOW_REDIRECTS);
    http.begin(client, googleScriptUrl);
    http.addHeader("Content-Type", "application/json");
    
    StaticJsonDocument<512> doc; 
    doc["potId"] = potId;
    doc["plantName"] = currentPlantName;
    doc["alertType"] = alertType;
    doc["alertMessage"] = alertMessage;
    
    String payload;
    serializeJson(doc, payload);
    
    int httpCode = http.POST(payload);
    if (httpCode > 0) {
      Serial.println("-> Da gui Email canh bao [" + alertType + "] thanh cong (HTTP " + String(httpCode) + ")");
    } else {
      Serial.println("-> Loi goi Google Script: " + http.errorToString(httpCode));
    }
    http.end();
  }
}

void sendDataToWebApp(int moisture, int light, float temp, float hum, float weight, bool hasSensorFault, String faultMsg) {
  if (WiFi.status() == WL_CONNECTED) {
    WiFiClient client;
    HTTPClient http;
    
    float safeTemp = isnan(temp) ? -999.0f : temp;
    float safeHum = isnan(hum) ? -999.0f : hum;
    float safeWeight = isnan(weight) ? -999.0f : weight;
    float weightKg = (safeWeight > 50.0f) ? (safeWeight / 1000.0f) : (safeWeight < 0 ? 0.0f : safeWeight);
    int lightLux = (light == LOW) ? 680 : 120; // LM393 DO: 0 = Sáng (~680 lux), 1 = Tối (~120 lux)

    StaticJsonDocument<384> doc;
    doc["potId"] = potId;
    doc["moisture"] = moisture;
    doc["weight"] = safeWeight;
    doc["weightKg"] = weightKg;
    doc["light"] = light;
    doc["lightLux"] = lightLux;
    doc["temperature"] = safeTemp;
    doc["humidity"] = safeHum;
    doc["sensorFault"] = hasSensorFault ? 1 : 0;
    if (hasSensorFault && faultMsg.length() > 0) {
      doc["faultMessage"] = faultMsg;
    }

    String payload;
    serializeJson(doc, payload);

    http.begin(client, serverTelemetryUrl);
    http.addHeader("Content-Type", "application/json");
    
    int httpCode = http.POST(payload);
    String resp = httpCode > 0 ? http.getString() : "";
    if (httpCode == 200 && resp.length() > 0) {
      StaticJsonDocument<512> respDoc;
      if (!deserializeJson(respDoc, resp)) {
        syncPlantThresholdFromJson(respDoc);
      }
    }
    Serial.println("GUI API WEB -> Code: " + String(httpCode)
      + " | Chau #" + String(potId) + " (" + currentPotName + " - " + currentPlantName + ")"
      + " [Min:" + String(minMoistureThreshold, 0) + "% - Max:" + String(maxMoistureThreshold, 0) + "%]"
      + " | Do am: " + String(moisture) + "%");
    http.end();
  }
}

void notifyPumpStoppedToWebApp() {
  if (WiFi.status() == WL_CONNECTED) {
    WiFiClient client;
    HTTPClient http;
    http.begin(client, serverCommandUrl + "?potId=" + String(potId) + "&status=OFF&source=DEVICE");
    int httpCode = http.GET();
    Serial.println(">>> Da dong bo trang thai OFF ve Web (HTTP Code: " + String(httpCode) + ")");
    http.end();
  }
}

void checkCommandFromWebApp() {
  if (WiFi.status() == WL_CONNECTED) {
    WiFiClient client;
    HTTPClient http;
    
    http.begin(client, serverCommandUrl + "?potId=" + String(potId));
    
    int httpCode = http.GET();
    if (httpCode == 200) {
      StaticJsonDocument<384> doc;
      DeserializationError err = deserializeJson(doc, http.getString());
      
      if (!err) {
        // Luôn cập nhật ngưỡng min/max mới nhất của loài cây trong chậu mỗi giây
        syncPlantThresholdFromJson(doc);

        if (doc.containsKey("command")) {
          String cmd = doc["command"].as<String>();
          
          // 1. NẾU WEB HOẶC AUTO-WATERING RA LỆNH BẬT ("START" hoặc "ON")
          if (cmd == "START" || cmd == "ON") {
            if (!isPumpRunning) {
              int dur = doc["duration"] | 5; 
              if (dur <= 0) dur = 5;
              
              Serial.println("\n>>> NHAN LENH TU SERVER: Bat may bom " + String(dur) + " giay!");
              
              digitalWrite(RELAY_PUMP_PIN, HIGH);  // Đóng Relay -> Bật bơm
              isPumpRunning = true;
              pumpStartTime = millis();            // Ghi nhớ mốc thời gian bắt đầu
              pumpDurationMs = dur * 1000UL;       // Đổi giây ra mili-giây
            }
          }
          
          // 2. NẾU WEB HOẶC CHỐNG NGẬP ÚNG RA LỆNH TẮT ("STOP" hoặc "OFF")
          else if (cmd == "STOP" || cmd == "OFF") {
            if (isPumpRunning) {
              Serial.println("\n>>> NHAN LENH TU SERVER: Ngat may bom khan cap ngay lap tuc!");
              digitalWrite(RELAY_PUMP_PIN, LOW); // Ngắt Relay -> Tắt bơm
              isPumpRunning = false;
            }
          }
        }
      }
    }
    http.end();
  }
}

