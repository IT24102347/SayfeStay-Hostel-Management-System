package org.example.servlet;

import org.example.dao.ChatDAO;
import org.example.model.ChatMessage;
import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/sendMessage")
public class SendMessageServlet extends HttpServlet {
    private ChatDAO chatDAO = new ChatDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String requestNo = req.getParameter("requestNo");
        String message = req.getParameter("message");
        String senderRole = "student".equals(user.getRole()) ? "Student" : "Staff";

        ChatMessage msg = new ChatMessage();
        msg.setRequestNo(requestNo);
        msg.setSenderId(user.getUserId());
        msg.setSenderRole(senderRole);
        msg.setMessage(message);

        chatDAO.sendMessage(msg);
        resp.setStatus(HttpServletResponse.SC_OK);
    }
}