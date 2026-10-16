package controller;

import dao.SensorDataDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.SensorData;
import service.AppDataService;
import util.Json;

/**
 * GET /api/sensors            -> latest reading per active irrigation zone (Pot)
 * GET /api/sensors?history=1  -> recent sensor reading series (optional potId filter)
 */
@WebServlet(name = "SensorApiServlet", urlPatterns = {"/api/sensors"})
public class SensorApiServlet extends HttpServlet {

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
                        .append(",\"recordedAt\":").append(Json.quote(String.valueOf(reading.getRecordedAt())))
                        .append('}');
            }
            json.append(']');
            ApiSupport.write(response, HttpServletResponse.SC_OK, json.toString());
            return;
        }
        ApiSupport.write(response, HttpServletResponse.SC_OK, data.zonesJson());
    }
}
