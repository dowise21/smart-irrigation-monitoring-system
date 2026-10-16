package controller;

import dao.PlantDAO;
import dao.PotDAO;
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
import model.Pot;

@WebServlet(name = "PotController", urlPatterns = {"/pots"})
public class PotController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PotController.class.getName());

    private final PotDAO potDAO = new PotDAO();
    private final PlantDAO plantDAO = new PlantDAO();

    // READ only. Mutations (insert/update/delete) are POST + redirect (PRG).
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
                    listPots(request, response);
                    break;
            }
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/pots");
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error in PotController (GET): {0}", ex.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "System error while processing zone request.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        String action = request.getParameter("action");

        try {
            if ("insert".equals(action)) {
                insertPot(request, session);
            } else if ("update".equals(action)) {
                updatePot(request, session);
            } else if ("delete".equals(action)) {
                deletePot(request, session);
            }
        } catch (IllegalArgumentException ex) { // includes NumberFormatException
            session.setAttribute("ERROR_MSG", ex instanceof NumberFormatException
                    ? "Invalid number in the submitted form." : ex.getMessage());
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error in PotController (POST): {0}", ex.getMessage());
            session.setAttribute("ERROR_MSG", "System error while saving the zone.");
        }
        response.sendRedirect(request.getContextPath() + "/pots");
    }

    // --- BUSINESS METHODS ---

    private void listPots(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Pot> listPot = potDAO.getAll();
        request.setAttribute("listPot", listPot);
        request.getRequestDispatcher("/plantManagement.jsp").forward(request, response);
    }

    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Plant> listPlant = plantDAO.getAll();
        request.setAttribute("listPlant", listPlant);
        request.getRequestDispatcher("/plantManagement.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Pot existingPot = potDAO.findById(id);
        List<Plant> listPlant = plantDAO.getAll();

        request.setAttribute("pot", existingPot);
        request.setAttribute("listPlant", listPlant);
        request.getRequestDispatcher("/plantManagement.jsp").forward(request, response);
    }

    private void insertPot(HttpServletRequest request, HttpSession session) {
        Pot pot = readPot(request, 0);
        if (potDAO.insert(pot) > 0) {
            session.setAttribute("SUCCESS_MSG", "Zone added.");
        } else {
            session.setAttribute("ERROR_MSG", "Could not add zone.");
        }
    }

    private void updatePot(HttpServletRequest request, HttpSession session) {
        int id = Integer.parseInt(request.getParameter("potId").trim());
        Pot pot = readPot(request, id);
        if (potDAO.update(pot)) {
            session.setAttribute("SUCCESS_MSG", "Zone updated.");
        } else {
            session.setAttribute("ERROR_MSG", "Could not update zone.");
        }
    }

    // POST only: a GET link must never delete data
    private void deletePot(HttpServletRequest request, HttpSession session) {
        int id = Integer.parseInt(request.getParameter("id").trim());
        if (potDAO.delete(id)) {
            session.setAttribute("SUCCESS_MSG", "Zone deleted.");
        } else {
            session.setAttribute("ERROR_MSG", "Could not delete zone.");
        }
    }

    /** Reads and validates the pot form. */
    private Pot readPot(HttpServletRequest request, int id) {
        String name = request.getParameter("potName") == null ? "" : request.getParameter("potName").trim();
        String location = request.getParameter("location") == null ? "" : request.getParameter("location").trim();
        int plantId = Integer.parseInt(request.getParameter("plantId").trim());
        // HTML checkbox: present when ticked, null otherwise
        boolean status = request.getParameter("status") != null;

        if (name.isEmpty()) {
            throw new IllegalArgumentException("Zone name is required.");
        }
        if (name.length() > 100 || location.length() > 200) {
            throw new IllegalArgumentException("Zone name (max 100) or location (max 200) is too long.");
        }
        if (plantId <= 0) {
            throw new IllegalArgumentException("Please select a plant for this zone.");
        }
        return new Pot(id, name, location, plantId, null, status);
    }
}