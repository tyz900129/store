<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ include file="../lib.jsp" %>
<%
  request.setCharacterEncoding("UTF-8");
  setSecurityHeaders(response, false);
  HttpSession sess = request.getSession(false);
  if (!requireAdmin(sess)) {
    sendAuthError(out);
    return;
  }

  Connection conn = null;
  PreparedStatement ps = null;
  ResultSet rs = null;

  try {
    conn = getConn();
    String pageStr = safeParam(request.getParameter("page"));
    String sizeStr = safeParam(request.getParameter("size"));
    int pageNum = Math.max(1, safeInt(pageStr, 1));
    int sizeNum = Math.max(1, Math.min(100, safeInt(sizeStr, 20)));

    ps = conn.prepareStatement(
      "SELECT id, email, created_at FROM subscribers ORDER BY created_at DESC LIMIT ? OFFSET ?");
    ps.setInt(1, sizeNum);
    ps.setInt(2, (pageNum - 1) * sizeNum);
    rs = ps.executeQuery();
    StringBuilder items = new StringBuilder("[");
    boolean first = true;
    while (rs.next()) {
      if (!first) items.append(",");
      first = false;
      items.append("{\"id\":" + rs.getInt("id"))
           .append(",\"email\":" + jsonStr(rs.getString("email")))
           .append(",\"created_at\":" + jsonStr(rs.getString("created_at")))
           .append("}");
    }
    items.append("]");
    rs.close(); ps.close();

    ps = conn.prepareStatement("SELECT COUNT(*) FROM subscribers");
    rs = ps.executeQuery();
    int total = 0;
    if (rs.next()) total = rs.getInt(1);

    out.print("{\"code\":0,\"data\":{\"items\":" + items
      + ",\"total\":" + total + ",\"page\":" + pageNum + ",\"size\":" + sizeNum + "}}");
  } catch (Exception e) {
    sendError(out);
  } finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (ps != null) try { ps.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
  }
%>
