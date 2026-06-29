<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="lib.jsp" %>
<%
  setSecurityHeaders(response, true);
  Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
  StringBuilder outBuf = new StringBuilder("{\"code\":0,\"data\":[");
  try {
    conn = getConn();
    ps = conn.prepareStatement(
      "SELECT c.id, c.name, c.icon, COUNT(p.id) AS cnt " +
      "FROM categories c LEFT JOIN products p ON p.category_id = c.id " +
      "GROUP BY c.id, c.name, c.icon ORDER BY c.id");
    rs = ps.executeQuery();
    boolean first = true;
    while (rs.next()) {
      if (!first) outBuf.append(",");
      first = false;
      outBuf.append("{")
            .append("\"id\":").append(jsonStr(rs.getString("id"))).append(",")
            .append("\"name\":").append(jsonStr(rs.getString("name"))).append(",")
            .append("\"icon\":").append(jsonStr(rs.getString("icon"))).append(",")
            .append("\"count\":").append(rs.getInt("cnt"))
            .append("}");
    }
    outBuf.append("]}");
  } catch (Exception e) {
    outBuf = new StringBuilder();
    sendError(out);
  } finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (ps != null) try { ps.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
  }
  out.print(outBuf.toString());
%>
