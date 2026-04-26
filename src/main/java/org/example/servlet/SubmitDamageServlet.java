package org.example.servlet;

import org.example.dao.DamageDAO;
import org.example.model.DamageReport;
import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;

@WebServlet("/student/damage/report")
@MultipartConfig(maxFileSize = 1024 * 1024 * 5, maxRequestSize = 1024 * 1024 * 25)
public class SubmitDamageServlet extends HttpServlet {
    private static final String UPLOAD_DIR = "uploads/damage";
    private DamageDAO damageDAO = new DamageDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"Student".equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String requestNo = req.getParameter("requestNo");
        String description = req.getParameter("description");

        DamageReport damage = new DamageReport();
        damage.setStudentId(user.getUserId());
        damage.setRequestNo(requestNo != null && !requestNo.isEmpty() ? requestNo : null);
        damage.setDescription(description);
        damage.setStatus("Pending");

        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        for (int i = 1; i <= 4; i++) {
            Part photo = req.getPart("photo" + i);
            if (photo != null && photo.getSize() > 0) {
                String fileName = System.currentTimeMillis() + "_" + photo.getSubmittedFileName();
                photo.write(uploadPath + File.separator + fileName);
                String relativePath = UPLOAD_DIR + "/" + fileName;
                switch (i) {
                    case 1: damage.setPhoto1(relativePath); break;
                    case 2: damage.setPhoto2(relativePath); break;
                    case 3: damage.setPhoto3(relativePath); break;
                    case 4: damage.setPhoto4(relativePath); break;
                }
            }
        }

        int id = damageDAO.createDamage(damage);
        if (id > 0) {
            session.setAttribute("successMsg", "Damage reported successfully!");
        } else {
            session.setAttribute("errorMsg", "Failed to report damage.");
        }
        resp.sendRedirect(req.getContextPath() + "/student/laundry/request");
    }
}