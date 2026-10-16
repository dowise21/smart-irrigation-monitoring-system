package util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Converts between the front end's schedule model ({time:"HH:mm", frequency:"daily|weekdays|once"})
 * and the single {@code cron_expression} column of WateringSchedule.
 *
 * Stored format is Quartz-style ("0 30 6 * * ?"), which is what the sample data uses.
 * Legacy rows written by the old schedule form ("07:30 Daily") are still understood.
 */
public final class ScheduleFormat {

    private static final Pattern QUARTZ = Pattern.compile("^\\s*\\S+\\s+(\\d{1,2})\\s+(\\d{1,2})(?:,\\d{1,2})*\\s+(\\S+)\\s+\\S+\\s+(\\S+)\\s*$");
    private static final Pattern LEGACY = Pattern.compile("^\\s*(\\d{1,2}):(\\d{2})\\s*(.*)$");
    private static final Pattern ONCE = Pattern.compile("^\\s*ONCE\\s+(\\d{1,2}):(\\d{2})\\s*$", Pattern.CASE_INSENSITIVE);

    private ScheduleFormat() {
    }

    /** @return {time, frequency} where frequency is daily, weekdays or once. */
    public static String[] parse(String cron) {
        String time = "07:00";
        String frequency = "daily";
        if (cron != null) {
            Matcher once = ONCE.matcher(cron);
            Matcher quartz = QUARTZ.matcher(cron);
            Matcher legacy = LEGACY.matcher(cron);
            if (once.matches()) {
                time = pad(once.group(1)) + ":" + once.group(2);
                frequency = "once";
            } else if (quartz.matches()) {
                time = pad(quartz.group(2)) + ":" + pad(quartz.group(1));
                String dayOfWeek = quartz.group(4).toUpperCase();
                if (dayOfWeek.contains("MON-FRI") || dayOfWeek.equals("2-6") || dayOfWeek.equals("1-5")) {
                    frequency = "weekdays";
                }
            } else if (legacy.matches()) {
                time = pad(legacy.group(1)) + ":" + legacy.group(2);
                String rest = legacy.group(3).toLowerCase();
                if (rest.contains("weekday")) {
                    frequency = "weekdays";
                } else if (rest.contains("once") || rest.contains("one time")) {
                    frequency = "once";
                }
            }
        }
        return new String[]{time, frequency};
    }

    /** Builds the value stored in cron_expression. Input is validated by {@link #isValidTime}. */
    public static String toCron(String time, String frequency) {
        String[] parts = time.split(":");
        int hour = Integer.parseInt(parts[0]);
        int minute = Integer.parseInt(parts[1]);
        if ("once".equals(frequency)) {
            return String.format("ONCE %02d:%02d", hour, minute);
        }
        if ("weekdays".equals(frequency)) {
            return "0 " + minute + " " + hour + " ? * MON-FRI";
        }
        return "0 " + minute + " " + hour + " * * ?";
    }

    public static boolean isValidTime(String time) {
        return time != null && time.matches("^([01]\\d|2[0-3]):[0-5]\\d$");
    }

    public static boolean isValidFrequency(String frequency) {
        return "daily".equals(frequency) || "weekdays".equals(frequency) || "once".equals(frequency);
    }

    private static String pad(String number) {
        return number.length() == 1 ? "0" + number : number;
    }
}

