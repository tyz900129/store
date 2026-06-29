<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, java.util.regex.*" %>
<%@ include file="lib.jsp" %>
<%
  request.setCharacterEncoding("UTF-8");
  setSecurityHeaders(response, true);
  StringBuilder body = new StringBuilder();
  BufferedReader br = request.getReader();
  String line;
  while ((line = br.readLine()) != null) body.append(line);
  String email = "";
  Matcher m = Pattern.compile("\"email\"\\s*:\\s*\"([^\"]+)\"").matcher(body.toString());
  if (m.find()) email = m.group(1);
  if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
    out.print("{\"code\":1,\"msg\":\"invalid email\"}");
    return;
  }
  Connection conn = null; PreparedStatement ps = null;
  try {
    conn = getConn();
    ps = conn.prepareStatement("INSERT IGNORE INTO subscribers(email) VALUES(?)");
    ps.setString(1, email);
    ps.executeUpdate();
    out.print("{\"code\":0,\"msg\":\"subscribed\"}");
  } catch (Exception e) {
    sendError(out);
  } finally {
    if (ps != null) try { ps.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
  }
%>
