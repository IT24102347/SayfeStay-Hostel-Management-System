<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String query = request.getQueryString();
    String target = request.getContextPath() + "/admin/rooms";
    if (query != null && !query.trim().isEmpty()) {
        target = target + "?" + query;
    }
    response.sendRedirect(target);
%>
