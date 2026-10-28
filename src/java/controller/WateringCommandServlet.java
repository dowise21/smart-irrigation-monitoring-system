package controller;

import dao.WateringSessionDAO;
import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import service.AlertService;
import util.DBContext;
import util.Json;

/**
 * IoT Watering Command Endpoint:
 *   GET  /api/watering/command?potId=1            -> Polled by ESP8266/ESP32 every 1s to check for a pending pump command
 *                                                    AND dynamic plant moisture thresholds (minMoisture, maxMoisture, plantName).
 *   GET  /api/watering/command?potId=1&status=OFF -> Called by ESP8266 when timer auto-stops to notify Web UI.
 *   GET  /api/watering/command?potId=1&peek=1     -> Polled by Web UI to inspect pump status without consuming queue.
 *   POST /api/watering/command                    -> Enqueues START/ON or STOP/OFF command from Web UI or IoT device.
 */
@WebServlet(name = "WateringCommandServlet", urlPatterns = {"/api/watering/command"})
public class WateringCommandServlet extends HttpServlet {

    /** Maximum hardware pump duration per single IoT command (seconds) to protect relay/pump. */
    private static final int MAX_HARDWARE_DURATION_SECONDS = 120;
    /** Command expiration window (5 minutes) so stale commands do not fire unexpectedly if MCU was offline. */
    private static final long COMMAND_TTL_MS = 5 * 60 * 1000L;

    private static final Map<Integer, PendingCommand> COMMAND_QUEUE = new ConcurrentHashMap<>();
    private static final Map<Integer, ActivePumpState> PUMP_STATES = new ConcurrentHashMap<>();

    /**
     * Dynamic Hardware Binding: tracks which Pot ID the single physical ESP8266 + water pump
     * is currently attached to during a multi-pot demo.
     */
    private static volatile int activeHardwarePotId = 1;

    public static int getActiveHardwarePotId() {
        return activeHardwarePotId;
    }

    public static void setActiveHardwarePotId(int potId) {
        if (potId > 0) {
            activeHardwarePotId = potId;
        }
    }

    private static final class PendingCommand {
        final String command;
        final int durationSeconds;
        final long createdAtMs;

        PendingCommand(String command, int durationSeconds) {
            this.command = command;
            this.durationSeconds = durationSeconds;
            this.createdAtMs = System.currentTimeMillis();
        }

        boolean isExpired() {
            return (System.currentTimeMillis() - createdAtMs) > COMMAND_TTL_MS;
        }
    }

    public static final class ActivePumpState {
        public final int potId;
        public final int durationSeconds;
        public final long startedAtMs;
        public final long endsAtMs;
        public volatile boolean stopped;

        ActivePumpState(int potId, int durationSeconds) {
            this.potId = potId;
            this.durationSeconds = durationSeconds;
            this.startedAtMs = System.currentTimeMillis();
            this.endsAtMs = this.startedAtMs + (durationSeconds * 1000L);
            this.stopped = false;
        }

        public boolean isRunning() {
            return !stopped && System.currentTimeMillis() < endsAtMs;
        }

        public int getRemainingSeconds() {
            if (!isRunning()) {
                return 0;
            }
            return (int) Math.max(0L, Math.ceil((endsAtMs - System.currentTimeMillis()) / 1000.0));
        }
    }

    public static ActivePumpState getPumpState(int potId) {
        return PUMP_STATES.get(potId);
    }

    /**
     * Enqueues a START command for the given potId so the ESP8266 will execute it on its next poll.
     * Automatically binds the single physical hardware pump to this potId.
     */
    public static void enqueueStart(int potId, int durationSeconds) {
        if (potId <= 0 || durationSeconds <= 0) {
            return;
        }
        activeHardwarePotId = potId;
        int safeDuration = Math.max(1, Math.min(MAX_HARDWARE_DURATION_SECONDS, durationSeconds));
        COMMAND_QUEUE.put(potId, new PendingCommand("START", safeDuration));
        PUMP_STATES.put(potId, new ActivePumpState(potId, safeDuration));
    }

    /**
     * Enqueues an immediate STOP command for the given potId so the ESP8266 turns off the relay on its next poll.
     */
    public static void enqueueStop(int potId) {
        if (potId <= 0) {
            return;
        }
        activeHardwarePotId = potId;
        COMMAND_QUEUE.put(potId, new PendingCommand("STOP", 0));
        ActivePumpState st = PUMP_STATES.get(potId);
        if (st != null) {
            st.stopped = true;
        }
        stopPendingSessionInDb(potId);
    }

    /**
     * Marks the pump as OFF when the ESP8266 timer finishes and notifies the server.
     */
    public static void markDeviceStopped(int potId) {
        if (potId <= 0) {
            return;
        }
        int[] targets = (activeHardwarePotId > 0 && activeHardwarePotId != potId)
                ? new int[]{potId, activeHardwarePotId}
                : new int[]{potId};
        for (int target : targets) {
            ActivePumpState st = PUMP_STATES.get(target);
            if (st != null) {
                st.stopped = true;
            }
            PendingCommand pending = COMMAND_QUEUE.get(target);
            if (pending != null && ("STOP".equals(pending.command) || "OFF".equals(pending.command))) {
                COMMAND_QUEUE.remove(target);
            }
        }
    }

    /**
     * Clears any pending command for the given potId.
     */
    public static void clearCommand(int potId) {
        if (potId > 0) {
            COMMAND_QUEUE.remove(potId);
            ActivePumpState st = PUMP_STATES.get(potId);
            if (st != null) {
                st.stopped = true;
            }
        }
    }

    private static String thresholdJsonFields(int potId) {
        AlertService.PotPlantThreshold t = AlertService.getPotPlantThreshold(potId);
        return ",\"activePotId\":" + activeHardwarePotId
                + ",\"potName\":" + Json.quote(t.potName)
                + ",\"areaName\":" + Json.quote(t.areaName)
                + ",\"plantName\":" + Json.quote(t.plantName)
                + ",\"minMoisture\":" + Json.number(t.minMoisture)
                + ",\"maxMoisture\":" + Json.number(t.maxMoisture);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer bindPotId = ApiSupport.intParam(request, "bindPotId");
        if (bindPotId != null && bindPotId > 0) {
            setActiveHardwarePotId(bindPotId);
            ApiSupport.write(response, HttpServletResponse.SC_OK,
                    "{\"ok\":true,\"message\":" + Json.quote("Hardware ESP8266 & Pump bound to Pot #" + bindPotId)
                    + ",\"potId\":" + bindPotId + ",\"command\":\"NONE\",\"duration\":0"
                    + thresholdJsonFields(bindPotId) + "}");
            return;
        }

        Integer potId = ApiSupport.intParam(request, "potId");
        if (potId == null || potId <= 0) {
            potId = activeHardwarePotId > 0 ? activeHardwarePotId : 1;
        }

        if ("bindHardware".equalsIgnoreCase(request.getParameter("action"))) {
            setActiveHardwarePotId(potId);
            ApiSupport.write(response, HttpServletResponse.SC_OK,
                    "{\"ok\":true,\"message\":" + Json.quote("Hardware ESP8266 & Pump bound to Pot #" + potId)
                    + ",\"potId\":" + potId + ",\"command\":\"NONE\",\"duration\":0"
                    + thresholdJsonFields(potId) + "}");
            return;
        }

        // Resolve the active bound pot for the physical ESP8266 + single water pump
        int targetPotId = ("1".equals(request.getParameter("peek")) || "1".equals(request.getParameter("lockPotId")))
                ? potId
                : (activeHardwarePotId > 0 ? activeHardwarePotId : potId);

        // 1. Check if ESP8266 is notifying that its timer finished and pump turned OFF
        String statusParam = request.getParameter("status");
        if (statusParam == null || statusParam.isEmpty()) {
            statusParam = request.getParameter("ack");
        }
        if (statusParam == null || statusParam.isEmpty()) {
            statusParam = request.getParameter("command");
        }
        if (statusParam != null) {
            String norm = statusParam.trim().toUpperCase();
            if ("OFF".equals(norm) || "STOP".equals(norm) || "STOPPED".equals(norm) || "COMPLETED".equals(norm)) {
                markDeviceStopped(targetPotId);
                ApiSupport.write(response, HttpServletResponse.SC_OK,
                        "{\"ok\":true,\"potId\":" + targetPotId + ",\"command\":\"NONE\",\"duration\":0"
                        + thresholdJsonFields(targetPotId) + "}");
                return;
            }
        }

        // 2. Non-destructive status peek for Web UI
        if ("1".equals(request.getParameter("peek"))) {
            ActivePumpState st = PUMP_STATES.get(potId);
            boolean running = st != null && st.isRunning();
            int remaining = st != null ? st.getRemainingSeconds() : 0;
            int total = st != null ? st.durationSeconds : 0;
            ApiSupport.write(response, HttpServletResponse.SC_OK,
                    "{\"ok\":true,\"potId\":" + potId
                    + ",\"command\":" + Json.quote(running ? "START" : "NONE")
                    + ",\"duration\":" + total
                    + ",\"running\":" + running
                    + ",\"remainingSeconds\":" + remaining
                    + thresholdJsonFields(potId) + "}");
            return;
        }

        // 3. Normal ESP8266 poll: pop command from queue for the bound hardware Pot (or fallback to polled potId)
        PendingCommand cmd = COMMAND_QUEUE.remove(targetPotId);
        int executedPotId = targetPotId;
        if (cmd == null && potId != targetPotId) {
            cmd = COMMAND_QUEUE.remove(potId);
            if (cmd != null) {
                executedPotId = potId;
            }
        }
        if (cmd != null && !cmd.isExpired()) {
            if ("START".equals(cmd.command) || "ON".equals(cmd.command)) {
                PUMP_STATES.put(executedPotId, new ActivePumpState(executedPotId, cmd.durationSeconds));
            }
            ApiSupport.write(response, HttpServletResponse.SC_OK,
                    "{\"ok\":true,\"potId\":" + executedPotId
                    + ",\"command\":" + Json.quote(cmd.command)
                    + ",\"duration\":" + cmd.durationSeconds
                    + thresholdJsonFields(executedPotId) + "}");
            return;
        }

        // 4. Fallback: check if there is any PENDING/RUNNING WateringSession in the DB for this targetPotId
        int dbDuration = pollPendingSessionFromDb(targetPotId);
        if (dbDuration > 0) {
            int safeDuration = Math.max(1, Math.min(MAX_HARDWARE_DURATION_SECONDS, dbDuration));
            PUMP_STATES.put(targetPotId, new ActivePumpState(targetPotId, safeDuration));
            ApiSupport.write(response, HttpServletResponse.SC_OK,
                    "{\"ok\":true,\"potId\":" + targetPotId
                    + ",\"command\":\"START\",\"duration\":" + safeDuration
                    + thresholdJsonFields(targetPotId) + "}");
            return;
        }

        ApiSupport.write(response, HttpServletResponse.SC_OK,
                "{\"ok\":true,\"potId\":" + targetPotId + ",\"command\":\"NONE\",\"duration\":0"
                + thresholdJsonFields(targetPotId) + "}");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String body = readBodyIfJson(request);

        Integer potId = ApiSupport.intParam(request, "potId");
        if (potId == null) {
            potId = extractJsonInt(body, "potId");
        }
        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = extractJsonString(body, "action");
        }
        String command = request.getParameter("command");
        if (command == null || command.trim().isEmpty()) {
            command = extractJsonString(body, "command");
        }
        if ("bindHardware".equalsIgnoreCase(action) || "bind".equalsIgnoreCase(action)) {
            command = "BIND";
        }
        if (command == null || command.trim().isEmpty()) {
            command = "START";
        }
        command = command.trim().toUpperCase();

        String source = request.getParameter("source");
        if (source == null || source.trim().isEmpty()) {
            source = extractJsonString(body, "source");
        }

        if (potId == null || potId <= 0) {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "potId must be a positive integer.");
            return;
        }

        if ("BIND".equals(command) || "SELECT".equals(command)) {
            setActiveHardwarePotId(potId);
            ApiSupport.write(response, HttpServletResponse.SC_OK,
                    "{\"ok\":true,\"message\":" + Json.quote("Hardware ESP8266 & Pump bound to Pot #" + potId)
                    + ",\"potId\":" + potId + ",\"command\":\"BIND\",\"duration\":0"
                    + thresholdJsonFields(potId) + "}");
            return;
        }

        if ("STOP".equals(command) || "OFF".equals(command) || "STOPPED".equals(command) || "COMPLETED".equals(command)) {
            if ("DEVICE".equalsIgnoreCase(source)) {
                markDeviceStopped(potId);
                ApiSupport.write(response, HttpServletResponse.SC_OK,
                        "{\"ok\":true,\"potId\":" + potId + ",\"command\":\"OFF\",\"duration\":0,\"running\":false}");
            } else {
                enqueueStop(potId);
                ApiSupport.write(response, HttpServletResponse.SC_OK,
                        "{\"ok\":true,\"message\":" + Json.quote("Queued STOP command for Pot #" + potId)
                        + ",\"potId\":" + potId + ",\"command\":\"STOP\",\"duration\":0,\"running\":false}");
            }
            return;
        }

        if ("NONE".equals(command)) {
            clearCommand(potId);
            ApiSupport.write(response, HttpServletResponse.SC_OK,
                    "{\"ok\":true,\"potId\":" + potId + ",\"command\":\"NONE\",\"duration\":0,\"running\":false}");
            return;
        }

        Integer duration = ApiSupport.intParam(request, "duration");
        if (duration == null) {
            duration = extractJsonInt(body, "duration");
        }
        if (duration == null) {
            Double minutes = ApiSupport.doubleParam(request, "minutes");
            if (minutes == null) {
                minutes = extractJsonDouble(body, "minutes");
            }
            if (minutes != null && minutes > 0) {
                // Map UI minutes (5, 10, 15, 20) to hardware seconds (5s, 10s, 15s, 20s) for safe pot watering
                duration = (int) Math.round(minutes <= 2 ? minutes * 60 : Math.min(60, minutes));
            }
        }
        if (duration == null) {
            Double volumeMl = ApiSupport.doubleParam(request, "volume");
            if (volumeMl == null) {
                volumeMl = extractJsonDouble(body, "volume");
            }
            if (volumeMl != null && volumeMl > 0) {
                double pumpRate = new WateringSessionDAO().getEffectivePumpRate(potId);
                duration = Math.max(1, (int) Math.ceil(volumeMl / pumpRate));
            }
        }
        if (duration == null || duration <= 0) {
            duration = 5;
        }

        int safeDuration = Math.max(1, Math.min(MAX_HARDWARE_DURATION_SECONDS, duration));
        enqueueStart(potId, safeDuration);

        ApiSupport.write(response, HttpServletResponse.SC_OK,
                "{\"ok\":true,\"message\":" + Json.quote("Queued START command for Pot #" + potId + " (" + safeDuration + "s)")
                + ",\"potId\":" + potId + ",\"command\":\"START\",\"duration\":" + safeDuration
                + ",\"running\":true,\"remainingSeconds\":" + safeDuration + "}");
    }

    private static void stopPendingSessionInDb(int potId) {
        String sql = "UPDATE WateringSession SET status = 'STOPPED' WHERE pot_id = ? AND status IN ('PENDING', 'RUNNING')";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, potId);
            ps.executeUpdate();
        } catch (Exception ignored) {
        }
    }

    private int pollPendingSessionFromDb(int potId) {
        String selectSql = "SELECT TOP 1 session_id, duration_seconds FROM WateringSession "
                + "WHERE pot_id = ? AND status IN ('PENDING', 'RUNNING') ORDER BY start_time DESC, session_id DESC";
        String updateSql = "UPDATE WateringSession SET status = 'COMPLETED' WHERE session_id = ?";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(selectSql)) {
            ps.setInt(1, potId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int sessionId = rs.getInt("session_id");
                    int duration = rs.getInt("duration_seconds");
                    try (PreparedStatement psUp = cn.prepareStatement(updateSql)) {
                        psUp.setInt(1, sessionId);
                        psUp.executeUpdate();
                    }
                    return duration > 0 ? duration : 5;
                }
            }
        } catch (Exception ignored) {
        }
        return 0;
    }

    static String readBodyIfJson(HttpServletRequest request) throws IOException {
        String ct = request.getContentType();
        if (ct == null || !ct.toLowerCase().contains("json")) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        return sb.toString();
    }

    static Integer extractJsonInt(String json, String key) {
        Double d = extractJsonDouble(json, key);
        return d == null ? null : (int) Math.round(d);
    }

    static Double extractJsonDouble(String json, String key) {
        if (json == null || json.isEmpty()) {
            return null;
        }
        Pattern p = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*(-?\\d+(?:\\.\\d+)?)");
        Matcher m = p.matcher(json);
        if (m.find()) {
            try {
                return Double.valueOf(m.group(1));
            } catch (NumberFormatException ignored) {
            }
        }
        return null;
    }

    static String extractJsonString(String json, String key) {
        if (json == null || json.isEmpty()) {
            return null;
        }
        Pattern p = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*\"([^\"]*)\"");
        Matcher m = p.matcher(json);
        return m.find() ? m.group(1) : null;
    }
}

