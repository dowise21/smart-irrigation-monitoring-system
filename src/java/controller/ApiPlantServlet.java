package controller;

import dao.PlantDAO;
import dao.PotDAO;
import dao.SensorDataDAO;
import dao.WateringSessionDAO;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Plant;
import model.Pot;
import model.SensorData;
import service.AppDataService;
import util.AppConfig;
import util.Json;

/**
 * JSON endpoint backing the Plant Management page (/plants -> plantManagement.jsp)
 * and threshold synchronization across Dashboard / Watering Management:
 *   GET  /api/plants                        -> array of active Pot-Plant records with Area & threshold info
 *   POST /api/plants action=water           -> triggers manual watering for a plant
 *   POST /api/plants action=updateThreshold -> updates min/max moisture thresholds for a Pot/Plant
 *   POST /api/plants action=add             -> creates a new plant and assigns/creates its Pot in an Area
 *   POST /api/plants action=update          -> updates an existing plant and syncs its Pot & Area
 *   POST /api/plants action=delete          -> deletes a plant and deactivates its Pot
 */
@WebServlet(name = "ApiPlantServlet", urlPatterns = {"/api/plants"})
public class ApiPlantServlet extends HttpServlet {

    private final AppDataService data = new AppDataService();
    private final PlantDAO plantDAO = new PlantDAO();
    private final PotDAO potDAO = new PotDAO();
    private final WateringSessionDAO sessionDAO = new WateringSessionDAO();
    private final SensorDataDAO sensorDAO = new SensorDataDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ApiSupport.write(response, HttpServletResponse.SC_OK, data.plantsJson());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String role = ApiSupport.role(request);

        if ("bindHardware".equals(action)) {
            Integer potId = ApiSupport.intParam(request, "potId");
            if (potId == null) {
                potId = ApiSupport.intParam(request, "zoneId");
            }
            if (potId == null || potId <= 0) {
                ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "Valid potId is required.");
                return;
            }
            WateringCommandServlet.setActiveHardwarePotId(potId);
            ApiSupport.write(response, HttpServletResponse.SC_OK,
                    "{\"ok\":true,\"message\":" + Json.quote("Hardware ESP8266 & Pump bound to Pot #" + potId)
                    + ",\"potId\":" + potId + ",\"activeHardwarePotId\":" + potId + "}");
            return;
        }

        if ("water".equals(action)) {
            if (!"ADMIN".equals(role) && !"TECHNICIAN".equals(role) && !"STAFF".equals(role)) {
                ApiSupport.error(response, HttpServletResponse.SC_FORBIDDEN,
                        "Only Admin, Technician and Staff accounts can execute manual watering.");
                return;
            }
            waterPlant(request, response);
            return;
        }

        if ("updateThreshold".equals(action)) {
            if (!"ADMIN".equals(role) && !"MANAGER".equals(role) && !"TECHNICIAN".equals(role) && !"STAFF".equals(role)) {
                ApiSupport.error(response, HttpServletResponse.SC_FORBIDDEN,
                        "Your account role cannot update irrigation thresholds.");
                return;
            }
            updateThreshold(request, response);
            return;
        }

        // Only ADMIN and MANAGER may add, edit or delete plants
        if (!"ADMIN".equals(role) && !"MANAGER".equals(role)) {
            ApiSupport.error(response, HttpServletResponse.SC_FORBIDDEN,
                    "Only Admin and Manager accounts can add, edit, or delete plants.");
            return;
        }

        if ("add".equals(action)) {
            savePlant(request, response, false);
        } else if ("update".equals(action)) {
            savePlant(request, response, true);
        } else if ("delete".equals(action)) {
            deletePlant(request, response);
        } else {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "Unknown action.");
        }
    }

    private void updateThreshold(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer potId = ApiSupport.intParam(request, "potId");
        if (potId == null) {
            potId = ApiSupport.intParam(request, "zoneId");
        }
        Integer plantId = ApiSupport.intParam(request, "plantId");
        if (plantId == null) {
            plantId = ApiSupport.intParam(request, "id");
        }
        Double targetMin = ApiSupport.doubleParam(request, "targetMin");
        if (targetMin == null) {
            targetMin = ApiSupport.doubleParam(request, "minMoisture");
        }
        Double targetMax = ApiSupport.doubleParam(request, "targetMax");
        if (targetMax == null) {
            targetMax = ApiSupport.doubleParam(request, "maxMoisture");
        }

        if ((potId == null || potId <= 0) && (plantId == null || plantId <= 0)) {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "potId or plantId is required.");
            return;
        }
        if (targetMin != null && (targetMin < 0 || targetMin > 100)) {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "targetMin must be between 0 and 100.");
            return;
        }
        if (targetMax != null && (targetMax < 0 || targetMax > 100)) {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "targetMax must be between 0 and 100.");
            return;
        }
        if (targetMin != null && targetMax != null && targetMin >= targetMax) {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "Minimum moisture must be lower than maximum moisture.");
            return;
        }

        if (plantDAO.updateThresholdsByPotOrPlant(potId, plantId, targetMin, targetMax)) {
            ApiSupport.write(response, HttpServletResponse.SC_OK,
                    "{\"ok\":true,\"message\":\"Thresholds updated.\""
                    + (potId != null ? ",\"potId\":" + potId : "")
                    + (targetMin != null ? ",\"targetMin\":" + Json.number(targetMin) : "")
                    + (targetMax != null ? ",\"targetMax\":" + Json.number(targetMax) : "")
                    + "}");
        } else {
            ApiSupport.error(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not update thresholds.");
        }
    }

    private void waterPlant(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = ApiSupport.intParam(request, "id");
        if (id == null) {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "Plant id is required.");
            return;
        }
        Plant plant = plantDAO.findById(id);
        if (plant == null) {
            ApiSupport.error(response, HttpServletResponse.SC_NOT_FOUND, "Plant not found.");
            return;
        }
        List<Pot> pots = data.activePots();
        Pot pot = data.resolvePotForPlant(plant, pots);
        if (pot == null) {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "No active irrigation zone available.");
            return;
        }

        int waterMl = plant.getWaterAmountMl() > 0 ? plant.getWaterAmountMl() : 250;
        int durationSeconds = Math.max(1, (int) Math.ceil(waterMl / sessionDAO.getEffectivePumpRate(pot.getPotId())));
        int sessionId = sessionDAO.insertManualWatering(pot.getPotId(), durationSeconds, waterMl);
        if (sessionId == 0) {
            ApiSupport.error(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not record watering session.");
            return;
        }
        WateringCommandServlet.enqueueStart(pot.getPotId(), durationSeconds);

        // Also bump sensor reading slightly to reflect the watering event
        Map<Integer, SensorData> readings = data.latestReadings();
        SensorData latest = readings.get(pot.getPotId());
        double currentMoisture = latest != null ? latest.getMoistureLevel() : 55.0;
        double newMoisture = Math.min(95.0, Math.round((currentMoisture + Math.max(2.0, waterMl / 60.0)) * 10.0) / 10.0);
        sensorDAO.insert(pot.getPotId(), newMoisture);

        ApiSupport.write(response, HttpServletResponse.SC_OK,
                "{\"ok\":true,\"message\":" + Json.quote("Started watering " + plant.getPlantName())
                + ",\"sessionId\":" + sessionId + ",\"soilMoisture\":" + Json.number(newMoisture) + "}");
    }

    private void savePlant(HttpServletRequest request, HttpServletResponse response, boolean isUpdate) throws IOException {
        String name = request.getParameter("name");
        if (name == null || name.trim().isEmpty()) {
            name = request.getParameter("plantName");
        }
        String category = request.getParameter("category");
        if (category == null || category.trim().isEmpty()) {
            category = request.getParameter("species");
        }
        String rawZoneId = request.getParameter("zoneId");
        boolean isNewPot = "__new_pot__".equals(rawZoneId);
        Integer zoneId = isNewPot ? null : ApiSupport.intParam(request, "zoneId");
        if (zoneId == null && !isNewPot) {
            zoneId = ApiSupport.intParam(request, "potId");
        }
        Integer areaId = ApiSupport.intParam(request, "areaId");
        String newPotName = request.getParameter("newPotName");
        if (newPotName == null || newPotName.trim().isEmpty()) {
            newPotName = request.getParameter("potName");
        }
        Integer waterAmountMl = ApiSupport.intParam(request, "waterAmountMl");
        Double targetMin = ApiSupport.doubleParam(request, "targetMin");
        if (targetMin == null) {
            targetMin = ApiSupport.doubleParam(request, "minMoistureThreshold");
        }
        Double targetMax = ApiSupport.doubleParam(request, "targetMax");
        if (targetMax == null) {
            targetMax = ApiSupport.doubleParam(request, "maxMoistureThreshold");
        }

        if (name == null || name.trim().isEmpty() || category == null || category.trim().isEmpty()) {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "Plant name and category are required.");
            return;
        }
        if (name.trim().length() > 100 || category.trim().length() > 100) {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "Plant name and category must be at most 100 characters.");
            return;
        }
        if (waterAmountMl != null && (waterAmountMl < 50 || waterAmountMl > 5000)) {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "Water amount must be between 50 and 5000 ml.");
            return;
        }
        if ((targetMin != null && (targetMin < 0 || targetMin > 100))
                || (targetMax != null && (targetMax < 0 || targetMax > 100))) {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "Moisture thresholds must be between 0 and 100.");
            return;
        }
        if (targetMin != null && targetMax != null && targetMin >= targetMax) {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "Minimum moisture must be lower than maximum moisture.");
            return;
        }
        int waterMl = waterAmountMl != null ? waterAmountMl : 250;
        String waterReq = request.getParameter("waterRequirement");
        if (waterReq == null || waterReq.trim().isEmpty()) {
            waterReq = waterMl + " ml/lần";
        }

        if (isUpdate) {
            Integer id = ApiSupport.intParam(request, "id");
            if (id == null) {
                id = ApiSupport.intParam(request, "plantId");
            }
            if (id == null) {
                ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "Plant id is required.");
                return;
            }
            Plant existing = plantDAO.findById(id);
            if (existing == null) {
                ApiSupport.error(response, HttpServletResponse.SC_NOT_FOUND, "Plant not found.");
                return;
            }
            existing.setPlantName(name.trim());
            existing.setSpecies(category.trim());
            existing.setWaterAmountMl(waterMl);
            existing.setWaterRequirement(waterReq.trim());
            if (targetMin != null) {
                existing.setMinMoistureThreshold(targetMin);
            }
            if (targetMax != null) {
                existing.setMaxMoistureThreshold(targetMax);
            }
            int resolvedPotId = (zoneId != null && zoneId > 0)
                    ? zoneId
                    : (existing.getDefaultPotId() != null ? existing.getDefaultPotId() : 1);
            if (isNewPot) {
                int createdPotId = potDAO.insertWithHardware(
                        (newPotName != null && !newPotName.trim().isEmpty()) ? newPotName.trim() : ("Chậu " + name.trim()),
                        areaId != null && areaId > 0 ? areaId : 1,
                        existing.getPlantId()
                );
                if (createdPotId > 0) {
                    resolvedPotId = createdPotId;
                }
            }
            existing.setDefaultPotId(resolvedPotId);
            if (!plantDAO.update(existing)) {
                ApiSupport.error(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not update plant.");
                return;
            }
            if (!isNewPot && resolvedPotId > 0) {
                potDAO.syncPotPlantAssignment(resolvedPotId, existing.getPlantId(), areaId, newPotName);
            }
            ApiSupport.write(response, HttpServletResponse.SC_OK,
                    "{\"ok\":true,\"message\":\"Plant updated.\",\"id\":" + existing.getPlantId()
                    + ",\"potId\":" + resolvedPotId + "}");
        } else {
            double min = targetMin != null ? targetMin : AppConfig.DEFAULT_MOISTURE_MIN;
            double max = targetMax != null ? targetMax : AppConfig.DEFAULT_MOISTURE_MAX;
            Plant plant = new Plant(0, name.trim(), category.trim(), min, max, null, null);
            plant.setWaterRequirement(waterReq.trim());
            plant.setWaterAmountMl(waterMl);
            plant.setDefaultPotId(zoneId != null && zoneId > 0 ? zoneId : null);
            int newId = plantDAO.insert(plant);
            if (newId == 0) {
                ApiSupport.error(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not add plant.");
                return;
            }
            int resolvedPotId;
            if (isNewPot || zoneId == null || zoneId <= 0) {
                resolvedPotId = potDAO.insertWithHardware(
                        (newPotName != null && !newPotName.trim().isEmpty()) ? newPotName.trim() : ("Chậu " + name.trim()),
                        areaId != null && areaId > 0 ? areaId : 1,
                        newId
                );
            } else {
                resolvedPotId = zoneId;
                potDAO.syncPotPlantAssignment(resolvedPotId, newId, areaId, newPotName);
            }
            ApiSupport.write(response, HttpServletResponse.SC_OK,
                    "{\"ok\":true,\"message\":" + Json.quote("Plant added.") + ",\"id\":" + newId
                    + ",\"potId\":" + resolvedPotId + "}");
        }
    }

    private void deletePlant(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = ApiSupport.intParam(request, "id");
        if (id == null) {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "Plant id is required.");
            return;
        }
        if (plantDAO.delete(id)) {
            ApiSupport.ok(response, "Plant deleted.");
        } else {
            ApiSupport.error(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not delete plant.");
        }
    }
}
