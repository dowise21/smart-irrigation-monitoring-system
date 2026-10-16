package controller;

import dao.PlantDAO;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Plant;

@WebServlet(name = "PlantController", urlPatterns = {"/plants"})
public class PlantController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PlantController.class.getName());
    private final PlantDAO plantDAO = new PlantDAO();

    // READ: list / new form / edit form. State-changing operations are POST-only (PRG).
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "new":
                    showNewForm(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                default:
                    listPlants(request, response);
                    break;
            }
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/plants");
        } catch (IOException | ServletException ex) {
            LOGGER.log(Level.SEVERE, "Error in PlantController (GET): {0}", ex.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "System error while processing plant request.");
        }
    }

    // CREATE / UPDATE / DELETE: always redirect afterwards (Post-Redirect-Get)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        String action = request.getParameter("action");
        try {
            if ("insert".equals(action)) {
                insertPlant(request, session);
            } else if ("update".equals(action)) {
                updatePlant(request, session);
            } else if ("delete".equals(action)) {
                deletePlant(request, session);
            }
        } catch (IllegalArgumentException ex) { // includes NumberFormatException
            session.setAttribute("ERROR_MSG", ex instanceof NumberFormatException
                    ? "Invalid number in the submitted form." : ex.getMessage());
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error in PlantController (POST): {0}", ex.getMessage());
            session.setAttribute("ERROR_MSG", "System error while saving the plant.");
        }
        response.sendRedirect(request.getContextPath() + "/plants");
    }

    // --- BUSINESS METHODS ---

    // 1. List + search + server-side pagination (OFFSET/FETCH in PlantDAO)
    private void listPlants(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        if (keyword == null) {
            keyword = "";
        }

        int page = 1;
        int recordsPerPage = 10;
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                page = Math.max(1, Integer.parseInt(pageParam.trim()));
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        List<Plant> listPlant = plantDAO.search(keyword, page, recordsPerPage);
        int totalRecords = plantDAO.count(keyword);
        int totalPages = Math.max(1, (int) Math.ceil(totalRecords * 1.0 / recordsPerPage));

        request.setAttribute("listPlant", listPlant);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/plantManagement.jsp").forward(request, response);
    }

    // 2. Open the "new" form
    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/plantManagement.jsp").forward(request, response);
    }

    // 3. Open the "edit" form (load existing data)
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Plant existingPlant = plantDAO.findById(id);

        request.setAttribute("plant", existingPlant);
        request.getRequestDispatcher("/plantManagement.jsp").forward(request, response);
    }

    // 4. Insert
    private void insertPlant(HttpServletRequest request, HttpSession session) {
        Plant plant = readPlant(request, 0);
        if (plantDAO.insert(plant) > 0) {
            session.setAttribute("SUCCESS_MSG", "Plant added.");
        } else {
            session.setAttribute("ERROR_MSG", "Could not add plant.");
        }
    }

    // 5. Update
    private void updatePlant(HttpServletRequest request, HttpSession session) {
        int id = Integer.parseInt(request.getParameter("plantId").trim());
        Plant plant = readPlant(request, id);
        if (plantDAO.update(plant)) {
            session.setAttribute("SUCCESS_MSG", "Plant updated.");
        } else {
            session.setAttribute("ERROR_MSG", "Could not update plant.");
        }
    }

    // 6. Delete (POST only - a GET link must never delete data)
    private void deletePlant(HttpServletRequest request, HttpSession session) {
        int id = Integer.parseInt(request.getParameter("id").trim());
        if (plantDAO.delete(id)) {
            session.setAttribute("SUCCESS_MSG", "Plant deleted.");
        } else {
            session.setAttribute("ERROR_MSG", "Could not delete plant.");
        }
    }

    /** Reads and validates the plant form. Throws IllegalArgumentException with a user-friendly message. */
    private Plant readPlant(HttpServletRequest request, int id) {
        String name = trim(request.getParameter("plantName"));
        String species = trim(request.getParameter("species"));
        String description = trim(request.getParameter("description"));
        String minStr = trim(request.getParameter("idealMoistureMin"));
        String maxStr = trim(request.getParameter("idealMoistureMax"));

        if (name.isEmpty()) {
            throw new IllegalArgumentException("Plant name is required.");
        }
        if (name.length() > 100 || species.length() > 100) {
            throw new IllegalArgumentException("Plant name and species must be at most 100 characters.");
        }

        Double min = minStr.isEmpty() ? null : Double.valueOf(minStr);
        Double max = maxStr.isEmpty() ? null : Double.valueOf(maxStr);
        if ((min != null && (min < 0 || min > 100)) || (max != null && (max < 0 || max > 100))) {
            throw new IllegalArgumentException("Moisture thresholds must be between 0 and 100.");
        }
        if (min != null && max != null && min >= max) {
            throw new IllegalArgumentException("Minimum moisture must be lower than maximum moisture.");
        }
        return new Plant(id, name, species, min, max, description, null);
    }

    private static String trim(String s) {
        return s == null ? "" : s.trim();
    }
}