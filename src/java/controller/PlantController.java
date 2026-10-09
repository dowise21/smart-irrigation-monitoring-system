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
import model.Plant;

@WebServlet(name = "PlantController", urlPatterns = {"/plants"})
public class PlantController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PlantController.class.getName());
    private final PlantDAO plantDAO = new PlantDAO();

    // Xử lý các yêu cầu hiển thị giao diện (READ, Hiển thị form Thêm/Sửa)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "list"; // Mặc định là xem danh sách
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
                    deletePlant(request, response);
                    break;
                default:
                    listPlants(request, response);
                    break;
            }
        } catch (IOException | ServletException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi tại PlantController (GET): {0}", ex.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi hệ thống khi xử lý yêu cầu.");
        }
    }

    // Xử lý các yêu cầu gửi dữ liệu từ Form (CREATE, UPDATE)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Đặt encoding UTF-8 để nhận tiếng Việt từ form không bị lỗi font
        request.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        try {
            switch (action) {
                case "insert":
                    insertPlant(request, response);
                    break;
                case "update":
                    updatePlant(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/plants");
                    break;
            }
        } catch (IOException ex) {
            LOGGER.log(Level.SEVERE, "Lỗi tại PlantController (POST): {0}", ex.getMessage());
        }
    }

    // --- CÁC HÀM NGHIỆP VỤ ---

    // 1. Lấy danh sách + Tìm kiếm + Phân trang
    private void listPlants(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        if (keyword == null) keyword = "";

        // Thiết lập phân trang
        int page = 1;
        int recordsPerPage = 10; // Mỗi trang hiển thị 10 cây
        
        if (request.getParameter("page") != null) {
            page = Integer.parseInt(request.getParameter("page"));
        }

        List<Plant> listPlant = plantDAO.search(keyword, page, recordsPerPage);
        int totalRecords = plantDAO.count(keyword);
        int totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);

        // Đẩy dữ liệu sang file JSP
        request.setAttribute("listPlant", listPlant);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/WEB-INF/views/plant-list.jsp").forward(request, response);
    }

    // 2. Mở form Thêm mới
    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/plant-form.jsp").forward(request, response);
    }

    // 3. Mở form Sửa (Lấy dữ liệu cũ đổ vào form)
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Plant existingPlant = plantDAO.findById(id);
        
        request.setAttribute("plant", existingPlant);
        request.getRequestDispatcher("/WEB-INF/views/plant-form.jsp").forward(request, response);
    }

    // 4. Lưu dữ liệu Thêm mới vào Database
    private void insertPlant(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String name = request.getParameter("plantName");
        String species = request.getParameter("species");
        String minStr = request.getParameter("idealMoistureMin");
        String maxStr = request.getParameter("idealMoistureMax");
        String description = request.getParameter("description");

        Double min = (minStr != null && !minStr.isEmpty()) ? Double.valueOf(minStr) : null;
        Double max = (maxStr != null && !maxStr.isEmpty()) ? Double.valueOf(maxStr) : null;

        Plant newPlant = new Plant(0, name, species, min, max, description, null);
        plantDAO.insert(newPlant);
        
        // Quay lại trang danh sách
        response.sendRedirect(request.getContextPath() + "/plants");
    }

    // 5. Cập nhật dữ liệu vào Database
    private void updatePlant(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("plantId"));
        String name = request.getParameter("plantName");
        String species = request.getParameter("species");
        String minStr = request.getParameter("idealMoistureMin");
        String maxStr = request.getParameter("idealMoistureMax");
        String description = request.getParameter("description");

        Double min = (minStr != null && !minStr.isEmpty()) ? Double.valueOf(minStr) : null;
        Double max = (maxStr != null && !maxStr.isEmpty()) ? Double.valueOf(maxStr) : null;

        Plant plant = new Plant(id, name, species, min, max, description, null);
        plantDAO.update(plant);
        
        // Quay lại trang danh sách
        response.sendRedirect(request.getContextPath() + "/plants");
    }

    // 6. Xóa cây trồng
    private void deletePlant(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        plantDAO.delete(id);
        
        // Quay lại trang danh sách
        response.sendRedirect(request.getContextPath() + "/plants");
    }
}