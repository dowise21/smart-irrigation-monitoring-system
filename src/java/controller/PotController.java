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
import model.Plant;
import model.Pot;

@WebServlet(name = "PotController", urlPatterns = {"/pots"})
public class PotController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PotController.class.getName());
    
    // Gọi cả 2 DAO để xử lý dữ liệu chéo nhau
    private final PotDAO potDAO = new PotDAO();
    private final PlantDAO plantDAO = new PlantDAO();

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
                case "delete":
                    deletePot(request, response);
                    break;
                default:
                    listPots(request, response);
                    break;
            }
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Lỗi tại PotController (GET): {0}", ex.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi hệ thống khi xử lý yêu cầu.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        try {
            switch (action) {
                case "insert":
                    insertPot(request, response);
                    break;
                case "update":
                    updatePot(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/pots");
                    break;
            }
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Lỗi tại PotController (POST): {0}", ex.getMessage());
        }
    }

    // --- CÁC HÀM NGHIỆP VỤ ---

    // 1. Lấy danh sách chậu
    private void listPots(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Pot> listPot = potDAO.getAll();
        request.setAttribute("listPot", listPot);
        request.getRequestDispatcher("/WEB-INF/views/pot-list.jsp").forward(request, response);
    }

    // 2. Mở form Thêm mới (Cần truyền listPlant sang để làm Menu Dropdown)
    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Plant> listPlant = plantDAO.getAll();
        request.setAttribute("listPlant", listPlant);
        
        request.getRequestDispatcher("/WEB-INF/views/pot-form.jsp").forward(request, response);
    }

    // 3. Mở form Sửa (Lấy dữ liệu cũ của chậu + lấy listPlant làm Dropdown)
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Pot existingPot = potDAO.findById(id);
        List<Plant> listPlant = plantDAO.getAll();
        
        request.setAttribute("pot", existingPot);
        request.setAttribute("listPlant", listPlant);
        request.getRequestDispatcher("/WEB-INF/views/pot-form.jsp").forward(request, response);
    }

    // 4. Lưu dữ liệu Thêm mới vào Database
    private void insertPot(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String name = request.getParameter("potName");
        String location = request.getParameter("location");
        int plantId = Integer.parseInt(request.getParameter("plantId"));
        
        // Checkbox trong HTML: Nếu tích thì có giá trị (khác null), nếu không tích thì request gửi về null
        boolean status = request.getParameter("status") != null;

        Pot newPot = new Pot(0, name, location, plantId, null, status);
        potDAO.insert(newPot);
        
        response.sendRedirect(request.getContextPath() + "/pots");
    }

    // 5. Cập nhật dữ liệu vào Database
    private void updatePot(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("potId"));
        String name = request.getParameter("potName");
        String location = request.getParameter("location");
        int plantId = Integer.parseInt(request.getParameter("plantId"));
        boolean status = request.getParameter("status") != null;

        Pot pot = new Pot(id, name, location, plantId, null, status);
        potDAO.update(pot);
        
        response.sendRedirect(request.getContextPath() + "/pots");
    }

    // 6. Xóa chậu
    private void deletePot(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        potDAO.delete(id);
        
        response.sendRedirect(request.getContextPath() + "/pots");
    }
}