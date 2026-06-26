<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, java.text.*" %>
<%!
  // 简易 JSON 工具（避免引入第三方库）
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
    String user = System.getenv().getOrDefault("DB_USER", "root");
    String pass = System.getenv().getOrDefault("DB_PASS", "root");
    return DriverManager.getConnection(url, user, pass);
  }
%>
<%
  request.setCharacterEncoding("UTF-8");
  response.setHeader("Access-Control-Allow-Origin", "*");
  response.setContentType("application/json;charset=UTF-8");

  String id      = request.getParameter("id");
  String cat     = request.getParameter("category");
  String pet     = request.getParameter("pet");
  String q       = request.getParameter("q");
  String pageStr = request.getParameter("page");
  String sizeStr = request.getParameter("size");

  int pageNum = pageStr == null ? 1 : Math.max(1, Integer.parseInt(pageStr));
  int sizeNum = sizeStr == null ? 12 : Math.max(1, Math.min(60, Integer.parseInt(sizeStr)));

  StringBuilder sql = new StringBuilder(
    "SELECT p.id, p.title, p.slug, p.description, p.price, p.currency, p.images_json, " +
    "p.category_id AS category, p.pet, p.stock, p.rating " +
    "FROM products p WHERE 1=1 ");
  List<Object> params = new ArrayList<>();
  if (id != null && !id.isEmpty()) { sql.append("AND p.id = ? "); params.add(Integer.parseInt(id)); }
  if (cat != null && !cat.isEmpty()) { sql.append("AND p.category_id = ? "); params.add(cat); }
  if (pet != null && !pet.isEmpty() && !"all".equals(pet)) { sql.append("AND p.pet = ? "); params.add(pet); }
  if (q != null && !q.isEmpty()) { sql.append("AND (p.title LIKE ? OR p.description LIKE ?) ");
    params.add("%" + q + "%"); params.add("%" + q + "%"); }
  sql.append("ORDER BY p.rating DESC, p.id ASC LIMIT ? OFFSET ?");
  params.add(sizeNum);
  params.add((pageNum - 1) * sizeNum);

  StringBuilder outBuf = new StringBuilder();
  outBuf.append("{");
  outBuf.append("\"code\":0,");
  outBuf.append("\"data\":{");

  Connection conn = null;
  PreparedStatement ps = null;
  ResultSet rs = null;
  try {
    conn = getConn();
    ps = conn.prepareStatement(sql.toString());
    for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
    rs = ps.executeQuery();

    outBuf.append("\"items\":[");
    boolean first = true;
    int count = 0;
    while (rs.next()) {
      if (!first) outBuf.append(",");
      first = false;
      outBuf.append("{");
      outBuf.append("\"id\":").append(rs.getInt("id")).append(",");
      outBuf.append("\"title\":").append(jsonStr(rs.getString("title"))).append(",");
      outBuf.append("\"slug\":").append(jsonStr(rs.getString("slug"))).append(",");
      outBuf.append("\"description\":").append(jsonStr(rs.getString("description"))).append(",");
      outBuf.append("\"price\":").append(rs.getBigDecimal("price")).append(",");
      outBuf.append("\"currency\":").append(jsonStr(rs.getString("currency"))).append(",");
      outBuf.append("\"category\":").append(jsonStr(rs.getString("category"))).append(",");
      outBuf.append("\"pet\":").append(jsonStr(rs.getString("pet"))).append(",");
      outBuf.append("\"stock\":").append(rs.getInt("stock")).append(",");
      outBuf.append("\"rating\":").append(rs.getBigDecimal("rating")).append(",");
      outBuf.append("\"images\":").append(rs.getString("images_json"));
      outBuf.append("}");
      count++;
    }
    outBuf.append("],");
    outBuf.append("\"total\":").append(count).append(",");
    outBuf.append("\"page\":").append(pageNum).append(",");
    outBuf.append("\"size\":").append(sizeNum);
  } catch (Exception e) {
    outBuf.delete(0, outBuf.length());
    outBuf.append("{\"code\":1,\"msg\":\"").append(jsonStr(e.getMessage())).append("\"}");
  } finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (ps != null) try { ps.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
  }
  outBuf.append("}}");
  out.print(outBuf.toString());
%>
