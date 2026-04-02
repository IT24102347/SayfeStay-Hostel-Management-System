package org.example.servlet;

import org.example.dao.DamageDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/staff/updateDamage")
public class UpdateDamageServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int damageId = Integer.parseInt(request.getParameter("damageId"));
            String status = request.getParameter("status");
            String staffResponse = request.getParameter("staffResponse");

            DamageDAO damageDAO = new DamageDAO();
            boolean updated = damageDAO.updateDamageReport(damageId, status, staffResponse);

            if (updated) {
                request.getSession().setAttribute("successMsg", "Damage report updated successfully!");
            } else {
                request.getSession().setAttribute("errorMsg", "Failed to update damage report");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/laundry/staff/dashboard");
    }
}