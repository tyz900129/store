<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ include file="../lib.jsp" %>
<%
  request.setCharacterEncoding("UTF-8");
  setSecurityHeaders(response, true);

  StringBuilder body = new StringBuilder();
  BufferedReader br = request.getReader();
  String line;
  while ((line = br.readLine()) != null) body.append(line);
  String json = body.toString();

  String username = "", password = "";
  Matcher m;
  m = Pattern.compile("\"username\"\\s*:\\s*\"([^\"]+)\"").matcher(json); if (m.find()) username = m.group(1);
  m = Pattern.compile("\"password\"\\s*:\\s*\"([^\"]+)\"").matcher(json); if (m.find()) password = m.group(1);

  username = safeParam(username);
  password = safeParam(password);

  if (username.isEmpty() || password.isEmpty()) {
    out.print("{\"code\":1,\"msg\":\"username and password required\"}");
    return;
  }

  Connection conn = null;
  PreparedStatement ps = null;
  ResultSet rs = null;
  try {
    conn = getConn();
    ps = conn.prepareStatement(
      "SELECT id, username, password, name, role FROM admin_users WHERE username = ?");
    ps.setString(1, username);
    rs = ps.executeQuery();
    if (!rs.next()) {
      out.print("{\"code\":1,\"msg\":\"invalid credentials\"}");
      return;
    }

    String storedHash = rs.getString("password");
    if (!checkPassword(password, storedHash)) {
      out.print("{\"code\":1,\"msg\":\"invalid credentials\"}");
      return;
    }

    HttpSession sess = request.getSession(true);
    sess.setAttribute("adminUser", rs.getString("username"));
    sess.setAttribute("adminName", rs.getString("name"));
    sess.setAttribute("adminRole", rs.getString("role"));
    sess.setAttribute("adminId", rs.getInt("id"));
    sess.setMaxInactiveInterval(1800); // 30 minutes

    // update last_login
    PreparedStatement up = conn.prepareStatement(
      "UPDATE admin_users SET last_login = NOW() WHERE id = ?");
    up.setInt(1, rs.getInt("id"));
    up.executeUpdate();
    up.close();

    out.print("{\"code\":0,\"user\":{\"username\":" + jsonStr(rs.getString("username"))
      + ",\"name\":" + jsonStr(rs.getString("name"))
      + ",\"role\":" + jsonStr(rs.getString("role")) + "}}");
  } catch (Exception e) {
    sendError(out, e);
  } finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (ps != null) try { ps.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
  }
%>
