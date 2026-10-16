package util;

/**
 * Tiny JSON helper so the API servlets do not need an external library.
 * Only what the Smart Irrigation front end needs: string escaping and number formatting.
 */
public final class Json {

    private Json() {
    }

    /** Returns {@code value} as a quoted, escaped JSON string ("" for null). */
    public static String quote(String value) {
        if (value == null) {
            return "\"\"";
        }
        StringBuilder sb = new StringBuilder(value.length() + 2).append('"');
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            switch (c) {
                case '\\': sb.append("\\\\"); break;
                case '"': sb.append("\\\""); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                case '<': sb.append("\\u003c"); break;   // keeps the payload safe inside <script>
                case '>': sb.append("\\u003e"); break;
                case '&': sb.append("\\u0026"); break;
                case '\u2028': sb.append("\\u2028"); break;
                case '\u2029': sb.append("\\u2029"); break;
                default:
                    if (c < 0x20) {
                        sb.append(String.format("\\u%04x", (int) c));
                    } else {
                        sb.append(c);
                    }
            }
        }
        return sb.append('"').toString();
    }

    /** Returns a JSON number, or {@code null} for NaN/Infinity. */
    public static String number(double value) {
        if (Double.isNaN(value) || Double.isInfinite(value)) {
            return "null";
        }
        if (value == Math.rint(value) && Math.abs(value) < 1e15) {
            return String.valueOf((long) value);
        }
        return String.valueOf(Math.round(value * 100.0) / 100.0);
    }

    /** Returns {@code {"ok":..,"message":..}} used by every write endpoint. */
    public static String result(boolean ok, String message) {
        return "{\"ok\":" + ok + ",\"message\":" + quote(message) + "}";
    }
}

