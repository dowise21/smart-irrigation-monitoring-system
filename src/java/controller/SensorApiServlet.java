package controller;

import dao.SensorDataDAO;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.SensorData;
import service.AlertService;
import service.AppDataService;
import util.Json;

/**
 * GET  /api/sensors            -> latest reading per active irrigation zone (Pot)
 * GET  /api/sensors?history=1  -> recent sensor reading series (optional potId filter)
 * POST /api/sensor/readings    -> IoT device (ESP8266/ESP32) pushes JSON or form telemetry
 * POST /api/sensors            -> Alias for IoT telemetry ingestion
 */
@WebServlet(name = "SensorApiServlet", urlPatterns = {"/api/sensors", "/api/sensor/readings"})
public class SensorApiServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(SensorApiServlet.class.getName());
    private static final Map<Integer, LiveTelemetry> LIVE_TELEMETRY = new ConcurrentHashMap<>();
    private static volatile LiveTelemetry latestGlobalTelemetry = null;

    public static final class LiveTelemetry {
        public final int potId;
        public final Double temperature;
        public final Double humidity;
        public final Double weightKg;
        public final Integer lightLux;
        public final long recordedAtMs;

        public LiveTelemetry(int potId, Double temperature, Double humidity, Double weightKg, Integer lightLux) {
            this.potId = potId;
            this.temperature = temperature;
            this.humidity = humidity;
            this.weightKg = weightKg;
            this.lightLux = lightLux;
            this.recordedAtMs = System.currentTimeMillis();
        }
    }

    public static LiveTelemetry getLiveTelemetry(int potId) {
        LiveTelemetry t = LIVE_TELEMETRY.get(potId);
        return t != null ? t : latestGlobalTelemetry;
    }

    private final AppDataService data = new AppDataService();
    private final SensorDataDAO sensorDAO = new SensorDataDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("1".equals(request.getParameter("history"))) {
            Integer potId = ApiSupport.intParam(request, "potId");
            List<SensorData> readings = sensorDAO.getRecentData(potId == null ? 0 : potId, 100);
            StringBuilder json = new StringBuilder("[");
            for (SensorData reading : readings) {
                if (json.length() > 1) {
                    json.append(',');
                }
                json.append("{\"dataId\":").append(reading.getDataId())
                        .append(",\"potId\":").append(reading.getPotId())
                        .append(",\"potName\":").append(Json.quote(reading.getPotName()))
                        .append(",\"plantName\":").append(Json.quote(reading.getPlantName()))
                        .append(",\"moisture\":").append(Json.number(reading.getMoistureLevel()))
                        .append(",\"weightKg\":").append(reading.getWeightKg() == null ? "null" : Json.number(reading.getWeightKg()))
                        .append(",\"lightLux\":").append(reading.getLightLux() == null ? "null" : reading.getLightLux())
                        .append(",\"recordedAt\":").append(Json.quote(String.valueOf(reading.getRecordedAt())))
                        .append('}');
            }
            json.append(']');
            ApiSupport.write(response, HttpServletResponse.SC_OK, json.toString());
            return;
        }
        ApiSupport.write(response, HttpServletResponse.SC_OK, data.zonesJson());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleTelemetryPost(request, response, sensorDAO, true);
    }

    /**
     * Shared telemetry ingestion supporting both JSON body (ESP8266/ESP32 ArduinoJson)
     * and form-urlencoded parameters.
     */
    static void handleTelemetryPost(HttpServletRequest request, HttpServletResponse response,
            SensorDataDAO sensorDAO, boolean jsonResponse) throws IOException {
        request.setCharacterEncoding("UTF-8");
        try {
            String body = WateringCommandServlet.readBodyIfJson(request);

            Integer potId = ApiSupport.intParam(request, "potId");
            if (potId == null) {
                potId = WateringCommandServlet.extractJsonInt(body, "potId");
            }
            if (potId == null || potId <= 0) {
                potId = WateringCommandServlet.getActiveHardwarePotId() > 0
                        ? WateringCommandServlet.getActiveHardwarePotId() : 1;
            }

            boolean bindHw = "1".equals(request.getParameter("bindHardware"))
                    || (body != null && body.contains("\"bindHardware\":true"));
            if (bindHw && potId > 0) {
                WateringCommandServlet.setActiveHardwarePotId(potId);
            }

            boolean lockPot = "1".equals(request.getParameter("lockPotId"))
                    || (body != null && body.contains("\"lockPotId\":true"));
            if (!lockPot && WateringCommandServlet.getActiveHardwarePotId() > 0) {
                potId = WateringCommandServlet.getActiveHardwarePotId();
            }

            Double moisture = ApiSupport.doubleParam(request, "moisture");
            if (moisture == null) {
                moisture = WateringCommandServlet.extractJsonDouble(body, "moisture");
            }

            // Detect explicit hardware sensor fault flag or negative error codes (-999) from ESP8266
            Integer sensorFaultFlag = ApiSupport.intParam(request, "sensorFault");
            if (sensorFaultFlag == null) {
                sensorFaultFlag = WateringCommandServlet.extractJsonInt(body, "sensorFault");
            }
            boolean hardwareFault = (sensorFaultFlag != null && sensorFaultFlag == 1)
                    || (body != null && body.contains("\"sensorFault\":true"));

            // Support both "weightKg" (kg) and "weight" (grams or kg from HX711 Loadcell)
            Double weightKg = ApiSupport.doubleParam(request, "weightKg");
            if (weightKg == null) {
                weightKg = WateringCommandServlet.extractJsonDouble(body, "weightKg");
            }
            Double rawWeight = ApiSupport.doubleParam(request, "weight");
            if (rawWeight == null) {
                rawWeight = WateringCommandServlet.extractJsonDouble(body, "weight");
            }
            if (rawWeight != null && rawWeight <= -500) {
                hardwareFault = true;
            }
            if (weightKg == null && rawWeight != null) {
                if (rawWeight < 0 && rawWeight > -500) {
                    rawWeight = 0.0;
                }
                if (rawWeight >= 0) {
                    weightKg = rawWeight > 50.0 ? Math.round((rawWeight / 1000.0) * 1000.0) / 1000.0 : rawWeight;
                }
            }

            // Support both "lightLux" (lux) and "light" (digital 0/1 from LM393 or raw lux)
            Integer lightLux = ApiSupport.intParam(request, "lightLux");
            if (lightLux == null) {
                lightLux = WateringCommandServlet.extractJsonInt(body, "lightLux");
            }
            if (lightLux == null) {
                Integer rawLight = ApiSupport.intParam(request, "light");
                if (rawLight == null) {
                    rawLight = WateringCommandServlet.extractJsonInt(body, "light");
                }
                if (rawLight != null) {
                    lightLux = Math.max(0, Math.min(200000, rawLight));
                }
            }

            if (potId == null || potId <= 0) {
                throw new IllegalArgumentException("potId must be positive.");
            }
            if (moisture == null || Double.isNaN(moisture) || moisture < 0 || moisture > 100) {
                throw new IllegalArgumentException("moisture must be between 0 and 100.");
            }
            if (weightKg != null && (weightKg.isNaN() || weightKg < 0 || weightKg > 1000)) {
                weightKg = null;
            }
            if (lightLux != null && (lightLux < 0 || lightLux > 200000)) {
                lightLux = null;
            }

            Double temperature = ApiSupport.doubleParam(request, "temperature");
            if (temperature == null) {
                temperature = WateringCommandServlet.extractJsonDouble(body, "temperature");
            }
            if (temperature != null && (temperature.isNaN() || temperature <= -40 || temperature > 80 || temperature == 0.0)) {
                if (temperature <= -900) {
                    hardwareFault = true;
                }
                temperature = null;
            }

            Double humidity = ApiSupport.doubleParam(request, "humidity");
            if (humidity == null) {
                humidity = WateringCommandServlet.extractJsonDouble(body, "humidity");
            }
            if (humidity != null && (humidity.isNaN() || humidity <= 0 || humidity > 100)) {
                if (humidity <= -900) {
                    hardwareFault = true;
                }
                humidity = null;
            }

            LiveTelemetry prev = LIVE_TELEMETRY.get(potId);
            LiveTelemetry live = new LiveTelemetry(
                    potId,
                    temperature != null ? temperature : (prev != null ? prev.temperature : null),
                    humidity != null ? humidity : (prev != null ? prev.humidity : null),
                    weightKg != null ? weightKg : (prev != null ? prev.weightKg : null),
                    lightLux != null ? lightLux : (prev != null ? prev.lightLux : null)
            );
            LIVE_TELEMETRY.put(potId, live);
            latestGlobalTelemetry = live;

            boolean success = sensorDAO.insert(potId, moisture, weightKg, lightLux);
            if (hardwareFault) {
                String faultMsg = WateringCommandServlet.extractJsonString(body, "faultMessage");
                new AlertService().recordHardwareSensorFault(potId, faultMsg);
            }

            if (success) {
                AlertService.PotPlantThreshold threshold = AlertService.getPotPlantThreshold(potId);
                AlertService.TelemetryEvaluationResult eval = AlertService.getLastEvaluation(potId);
                String alertFields = "";
                if (eval != null && eval.alertType != null) {
                    alertFields = ",\"alertType\":" + Json.quote(eval.alertType)
                            + ",\"alertMessage\":" + Json.quote(eval.alertMessage)
                            + ",\"autoWaterTriggered\":" + eval.autoWaterTriggered
                            + ",\"autoWaterDuration\":" + eval.autoWaterDurationSeconds;
                }
                if (jsonResponse || ApiSupport.isAjax(request) || !body.isEmpty()) {
                    ApiSupport.write(response, HttpServletResponse.SC_OK,
                            "{\"ok\":true,\"message\":\"Telemetry recorded.\",\"potId\":" + potId
                            + ",\"activePotId\":" + WateringCommandServlet.getActiveHardwarePotId()
                            + ",\"potName\":" + Json.quote(threshold.potName)
                            + ",\"areaName\":" + Json.quote(threshold.areaName)
                            + ",\"moisture\":" + Json.number(moisture)
                            + ",\"plantName\":" + Json.quote(threshold.plantName)
                            + ",\"minMoisture\":" + Json.number(threshold.minMoisture)
                            + ",\"maxMoisture\":" + Json.number(threshold.maxMoisture)
                            + alertFields + "}");
                } else {
                    response.getWriter().write("OK");
                }
            } else {
                if (jsonResponse || ApiSupport.isAjax(request) || !body.isEmpty()) {
                    ApiSupport.error(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                            "Database error while saving sensor reading.");
                } else {
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                            "Database error while saving sensor reading.");
                }
            }
        } catch (NullPointerException | IllegalArgumentException ex) {
            LOGGER.log(Level.WARNING, "Rejected sensor reading: {0}", ex.getMessage());
            if (jsonResponse || ApiSupport.isAjax(request)) {
                ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, ex.getMessage());
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid sensor data.");
            }
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error receiving sensor reading: {0}", ex.getMessage());
            if (jsonResponse || ApiSupport.isAjax(request)) {
                ApiSupport.error(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not save sensor reading.");
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not save sensor reading.");
            }
        }
    }
}
