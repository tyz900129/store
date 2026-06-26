<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, java.util.regex.*" %>
<%!
  String jsonStr(String s) {
    if (s == null) return "null";
    StringBuilder sb = new StringBuilder("\"");
    for (int i = 0; i < s.length(); i++) {
      char c = s.charAt(i);
      switch (c) {
        case '"': sb.append("\\\""); break;
        case '\\': sb.append("\\\\"); break;
        case '\n': sb.append("\\n"); break;
        case '\r': sb.append("\\r"); break;
        case '\t': sb.append("\\t"); break;
        default:
          if (c < 0x20) sb.append(String.format("\\u%04x", (int)c));
          else sb.append(c);
      }
    }
    sb.append("\"");
    return sb.toString();
  }
  Connection getConn() throws Exception {
    Class.forName("com.mysql.cj.jdbc.Driver");
    String url = "jdbc:mysql://" + System.getenv().getOrDefault("DB_HOST", "mysql")
               + ":" + System.getenv().getOrDefault("DB_PORT", "3306")
               + "/" + System.getenv().getOrDefault("DB_NAME", "pawpatrol")
               + "?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=UTC";
    return DriverManager.getConnection(url,
      System.getenv().getOrDefault("DB_USER", "root"),
      System.getenv().getOrDefault("DB_PASS", "root"));
  }
%>
<%
  request.setCharacterEncoding("UTF-8");
  response.setHeader("Access-Control-Allow-Origin", "*");
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
    out.print("{\"code\":1,\"msg\":\"" + jsonStr(e.getMessage()) + "\"}");
  } finally {
    if (ps != null) try { ps.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
  }
%>
