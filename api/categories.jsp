<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>
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
  response.setHeader("Access-Control-Allow-Origin", "*");
  Connection conn = null; Statement ps = null; ResultSet rs = null;
  StringBuilder outBuf = new StringBuilder("{\"code\":0,\"data\":[");
  try {
    conn = getConn();
    ps = conn.createStatement();
    rs = ps.executeQuery(
      "SELECT c.id, c.name, c.icon, COUNT(p.id) AS cnt " +
      "FROM categories c LEFT JOIN products p ON p.category_id = c.id " +
      "GROUP BY c.id, c.name, c.icon ORDER BY c.id");
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
    outBuf = new StringBuilder("{\"code\":1,\"msg\":\"").append(jsonStr(e.getMessage())).append("\"}");
  } finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (ps != null) try { ps.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
  }
  out.print(outBuf.toString());
%>
