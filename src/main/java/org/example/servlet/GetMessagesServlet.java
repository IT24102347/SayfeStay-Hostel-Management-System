package org.example.servlet;

import com.google.gson.Gson;
import org.example.dao.ChatDAO;
import org.example.model.ChatMessage;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/getMessages")
public class GetMessagesServlet extends HttpServlet {
    private ChatDAO chatDAO = new ChatDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String requestNo = req.getParameter("requestNo");
        if (requestNo == null || requestNo.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        List<ChatMessage> messages = chatDAO.getMessagesByRequestNo(requestNo);
        Gson gson = new Gson();
        resp.getWriter().write(gson.toJson(messages));
    }
}