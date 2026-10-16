package util;

import dao.WateringSessionDAO;

/**
 * Business constants that both the servlets and the front end must agree on.
 * The front end reads them from /app-data.js (window.SI_DATA.config) instead of hard-coding its own copy.
 */
public final class AppConfig {

    /** Reference daily water quota shown on the dashboard and irrigation pages (liters). */
    public static final double DAILY_QUOTA_LITERS = 160;

    /** Pump throughput in liters per minute (derived from the pump rate used to convert volume to run-time). */
    public static final double PUMP_FLOW_LITERS_PER_MINUTE = WateringSessionDAO.PUMP_RATE_ML_PER_SECOND * 60 / 1000.0;

    /** Fallback ideal soil-moisture window when a plant has none configured (percent). */
    public static final double DEFAULT_MOISTURE_MIN = 60;
    public static final double DEFAULT_MOISTURE_MAX = 80;

    private AppConfig() {
    }
}

