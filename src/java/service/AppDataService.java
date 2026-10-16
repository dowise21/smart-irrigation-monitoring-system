package service;

import dao.AlertDAO;
import dao.IrrigationHistoryDAO;
import dao.PlantDAO;
import dao.PotDAO;
import dao.SensorDataDAO;
import dao.WateringScheduleDAO;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import model.Alert;
import model.IrrigationHistory;
import model.Plant;
import model.Pot;
import model.SensorData;
import model.WateringSchedule;
import util.AppConfig;
import util.Json;
import util.ScheduleFormat;

/**
 * Builds the JSON the front end consumes. Field names are the ones the existing
 * JavaScript already used for its demo data (zone, alert, run, schedule), so the pages
 * did not have to be rewritten around a new model:
 *
 *   zone     = an active Pot joined with its Plant and latest SensorReading
 *   alert    = an unresolved Alert row
 *   run      = a WateringSession joined with WaterAnalysis
 *   schedule = a WateringSchedule row
 */
public class AppDataService {

    private final PotDAO potDAO = new PotDAO();
    private final PlantDAO plantDAO = new PlantDAO();
    private final SensorDataDAO sensorDAO = new SensorDataDAO();
    private final AlertDAO alertDAO = new AlertDAO();
    private final IrrigationHistoryDAO historyDAO = new IrrigationHistoryDAO();
    private final WateringScheduleDAO scheduleDAO = new WateringScheduleDAO();

    /** Active pots in ascending id order (PotDAO returns newest first). */
    public List<Pot> activePots() {
        List<Pot> pots = new ArrayList<>();
        for (Pot pot : potDAO.getAll()) {
            if (pot.isStatus()) {
                pots.add(pot);
            }
        }
        Collections.reverse(pots);
        return pots;
    }

    /** Latest moisture reading per pot id. */
    public Map<Integer, SensorData> latestReadings() {
        Map<Integer, SensorData> latest = new HashMap<>();
        for (SensorData reading : sensorDAO.getRecentData(0, 500)) { // newest first
            if (!latest.containsKey(reading.getPotId())) {
                latest.put(reading.getPotId(), reading);
            }
        }
        return latest;
    }

    public String zonesJson() {
        Map<Integer, Plant> plants = new HashMap<>();
        for (Plant plant : plantDAO.getAll()) {
            plants.put(plant.getPlantId(), plant);
        }
        Map<Integer, SensorData> readings = latestReadings();

        StringBuilder json = new StringBuilder("[");
        for (Pot pot : activePots()) {
            Plant plant = plants.get(pot.getPlantId());
            SensorData reading = readings.get(pot.getPotId());
            double min = plant != null && plant.getIdealMoistureMin() != null ? plant.getIdealMoistureMin() : AppConfig.DEFAULT_MOISTURE_MIN;
            double max = plant != null && plant.getIdealMoistureMax() != null ? plant.getIdealMoistureMax() : AppConfig.DEFAULT_MOISTURE_MAX;
            if (json.length() > 1) {
                json.append(',');
            }
            double moistureVal = reading == null ? 65.0 : reading.getMoistureLevel();
            json.append("{\"id\":").append(Json.quote(String.valueOf(pot.getPotId())))
                    .append(",\"potId\":").append(pot.getPotId())
                    .append(",\"name\":").append(Json.quote(pot.getPotName()))
                    .append(",\"potName\":").append(Json.quote(pot.getPotName()))
                    .append(",\"location\":").append(Json.quote(pot.getLocation()))
                    .append(",\"crop\":").append(Json.quote(pot.getPlantName()))
                    .append(",\"plantName\":").append(Json.quote(pot.getPlantName()))
                    .append(",\"plantId\":").append(pot.getPlantId())
                    .append(",\"nodeId\":").append(pot.getPotId())
                    .append(",\"soilMoisture\":").append(Json.number(moistureVal))
                    .append(",\"moisture\":").append(Json.number(moistureVal))
                    .append(",\"recordedAt\":").append(reading == null ? "null" : Json.quote(iso(reading.getRecordedAt())))
                    .append(",\"targetMin\":").append(Json.number(min))
                    .append(",\"targetMax\":").append(Json.number(max))
                    .append('}');
        }
        return json.append(']').toString();
    }

    public String alertsJson() {
        return alertsJson(alertDAO.getAlerts(false));
    }

    /** Serialises an (already paginated) alert list for the front end. */
    public String alertsJson(List<Alert> alerts) {
        StringBuilder json = new StringBuilder("[");
        for (Alert alert : alerts) {
            String type = alert.getAlertType() == null ? "" : alert.getAlertType().toUpperCase(Locale.ROOT);
            String severity;
            String title;
            String icon;
            switch (type) {
                case "DRY_STRESS":
                    severity = "critical"; title = "Soil moisture below target"; icon = "i-drop"; break;
                case "LEAK":
                    severity = "critical"; title = "Possible water leak"; icon = "i-warning"; break;
                case "OVERWATER":
                    severity = "warning"; title = "Over-watering detected"; icon = "i-drop"; break;
                case "SENSOR_FAULT":
                    severity = "warning"; title = "Sensor fault suspected"; icon = "i-signal"; break;
                case "CALIBRATION_MISSING":
                    severity = "warning"; title = "Pump calibration missing"; icon = "i-warning"; break;
                default:
                    severity = "info"; title = "System notice"; icon = "i-check";
            }
            if (json.length() > 1) {
                json.append(',');
            }
            json.append("{\"id\":").append(Json.quote("AL-" + alert.getAlertId()))
                    .append(",\"dbId\":").append(alert.getAlertId())
                    .append(",\"severity\":").append(Json.quote(severity))
                    .append(",\"title\":").append(Json.quote(title))
                    .append(",\"description\":").append(Json.quote(alert.getMessage()))
                    .append(",\"zoneId\":").append(Json.quote(String.valueOf(alert.getPotId())))
                    .append(",\"node\":").append(Json.quote(String.format("NODE-%02d", alert.getPotId())))
                    .append(",\"createdAt\":").append(alert.getCreatedAt() == null ? System.currentTimeMillis() : alert.getCreatedAt().getTime())
                    .append(",\"icon\":").append(Json.quote(icon))
                    .append('}');
        }
        return json.append(']').toString();
    }

    public String historyJson() {
        StringBuilder json = new StringBuilder("[");
        for (IrrigationHistory run : historyDAO.getHistory(0, 200)) {
            double minutes = run.getDurationSeconds() == null ? 0 : run.getDurationSeconds() / 60.0;
            double liters = run.getWaterAmount() != null ? run.getWaterAmount() : minutes * AppConfig.PUMP_FLOW_LITERS_PER_MINUTE;
            if (json.length() > 1) {
                json.append(',');
            }
            json.append("{\"id\":").append(Json.quote("S-" + run.getHistoryId()))
                    .append(",\"dbId\":").append(run.getHistoryId())
                    .append(",\"zoneId\":").append(Json.quote(String.valueOf(run.getPotId())))
                    .append(",\"minutes\":").append(Json.number(minutes))
                    .append(",\"liters\":").append(Json.number(liters))
                    .append(",\"source\":").append(Json.quote(label(run.getSource(), "Device")))
                    .append(",\"status\":").append(Json.quote(label(run.getStatus(), "Completed")))
                    .append(",\"startedAt\":").append(Json.quote(iso(run.getIrrigationTime())));
            if (run.getRetainRatio() != null) {
                // Water waste = water used - water retained (same definition as DashboardDAO.getWaterKPIs)
                json.append(",\"excessLiters\":").append(Json.number(liters * (1 - run.getRetainRatio())));
            }
            json.append('}');
        }
        return json.append(']').toString();
    }

    public String schedulesJson() {
        StringBuilder json = new StringBuilder("[");
        for (WateringSchedule schedule : scheduleDAO.getAllActivePotSchedules()) {
            if (json.length() > 1) {
                json.append(',');
            }
            json.append(scheduleJson(schedule));
        }
        return json.append(']').toString();
    }

    public String scheduleJson(WateringSchedule schedule) {
        String[] parsed = ScheduleFormat.parse(schedule.getCronExpression());
        return "{\"id\":" + Json.quote(String.valueOf(schedule.getScheduleId()))
                + ",\"dbId\":" + schedule.getScheduleId()
                + ",\"zoneId\":" + Json.quote(String.valueOf(schedule.getPotId()))
                + ",\"time\":" + Json.quote(parsed[0])
                + ",\"frequency\":" + Json.quote(parsed[1])
                + ",\"minutes\":" + Json.number(schedule.getDurationSeconds() / 60.0)
                + ",\"enabled\":" + schedule.isIsActive() + "}";
    }

    public Pot resolvePotForPlant(Plant plant, List<Pot> pots) {
        if (pots == null || pots.isEmpty()) {
            return null;
        }
        if (plant.getDefaultPotId() != null) {
            for (Pot pot : pots) {
                if (pot.getPotId() == plant.getDefaultPotId()) {
                    return pot;
                }
            }
        }
        for (Pot pot : pots) {
            if (pot.getPlantId() == plant.getPlantId()) {
                return pot;
            }
        }
        return pots.get(0);
    }

    public String plantsJson() {
        List<Pot> pots = activePots();
        Map<Integer, SensorData> readings = latestReadings();
        Map<Integer, Date> lastWatered = new HashMap<>();
        for (IrrigationHistory run : historyDAO.getHistory(0, 200)) {
            if (!lastWatered.containsKey(run.getPotId()) && run.getIrrigationTime() != null) {
                lastWatered.put(run.getPotId(), run.getIrrigationTime());
            }
        }

        StringBuilder json = new StringBuilder("[");
        for (Plant plant : plantDAO.getAll()) {
            Pot pot = resolvePotForPlant(plant, pots);
            int potId = pot == null ? 1 : pot.getPotId();
            String garden = pot == null ? "Garden 1" : pot.getPotName();
            SensorData reading = readings.get(potId);
            Date wateredAt = lastWatered.get(potId);
            double min = plant.getIdealMoistureMin() != null ? plant.getIdealMoistureMin() : AppConfig.DEFAULT_MOISTURE_MIN;
            double max = plant.getIdealMoistureMax() != null ? plant.getIdealMoistureMax() : AppConfig.DEFAULT_MOISTURE_MAX;
            String category = (plant.getSpecies() == null || plant.getSpecies().trim().isEmpty())
                    ? "Vegetable" : plant.getSpecies().trim();

            if (json.length() > 1) {
                json.append(',');
            }
            json.append("{\"id\":").append(plant.getPlantId())
                    .append(",\"name\":").append(Json.quote(plant.getPlantName()))
                    .append(",\"category\":").append(Json.quote(category))
                    .append(",\"garden\":").append(Json.quote(garden))
                    .append(",\"zoneId\":").append(Json.quote(String.valueOf(potId)))
                    .append(",\"nodeId\":").append(potId)
                    .append(",\"soilMoisture\":").append(reading == null ? "null" : Json.number(reading.getMoistureLevel()))
                    .append(",\"temperature\":").append(Json.number(26.0 + (potId % 4) * 0.4))
                    .append(",\"targetMin\":").append(Json.number(min))
                    .append(",\"targetMax\":").append(Json.number(max))
                    .append(",\"waterAmountMl\":").append(plant.getWaterAmountMl() > 0 ? plant.getWaterAmountMl() : 250)
                    .append(",\"lastWateredAt\":").append(wateredAt == null ? "null" : Json.quote(iso(wateredAt)))
                    .append('}');
        }
        return json.append(']').toString();
    }

    private static String iso(Date date) {
        if (date == null) {
            return new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX").format(new Date());
        }
        return new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX").format(date);
    }

    /** "MANUAL" -> "Manual" */
    private static String label(String value, String fallback) {
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        String lower = value.trim().toLowerCase(Locale.ROOT);
        return Character.toUpperCase(lower.charAt(0)) + lower.substring(1);
    }
}

