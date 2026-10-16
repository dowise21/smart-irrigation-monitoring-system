package controller;

import dao.IrrigationHistoryDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.IrrigationHistory;

@WebServlet(name = "ExportCSVController", urlPatterns = {"/export-history"})
public class ExportCSVController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"Irrigation_History_Report.csv\"");

        try (PrintWriter out = response.getWriter()) {
            out.write('\ufeff');
            out.println("Session ID,Garden / Pot,Plant,Start Time,Duration (s),Water Used (L),Status,Source");

            IrrigationHistoryDAO dao = new IrrigationHistoryDAO();
            List<IrrigationHistory> list = dao.getHistory(0, 1000);

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

            for (IrrigationHistory h : list) {
                String timeStr = h.getIrrigationTime() != null ? sdf.format(h.getIrrigationTime()) : "";
                String duration = h.getDurationSeconds() != null ? String.valueOf(h.getDurationSeconds()) : "0";
                String amount = h.getWaterAmount() != null ? String.format("%.2f", h.getWaterAmount()) : "0.00";
                String status = h.getStatus() != null ? h.getStatus() : "COMPLETED";
                String source = h.getSource() != null ? h.getSource() : "DEVICE";

                out.println(String.format("%d,\"%s\",\"%s\",%s,%s,%s,%s,%s",
                        h.getHistoryId(),
                        escapeCsv(h.getPotName()),
                        escapeCsv(h.getPlantName()),
                        timeStr,
                        duration,
                        amount,
                        status,
                        source));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static String escapeCsv(String s) {
        return s == null ? "" : s.replace("\"", "\"\"");
    }
}