<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, java.text.*, java.util.regex.*" %>
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
  String genOrderId() {
    return "PP" + new SimpleDateFormat("yyyyMMdd").format(new Date())
                 + String.format("%04d", new Random().nextInt(9000) + 1000);
  }
%>
<%
  request.setCharacterEncoding("UTF-8");
  response.setHeader("Access-Control-Allow-Origin", "*");
  StringBuilder body = new StringBuilder();
  BufferedReader br = request.getReader();
  String line;
  while ((line = br.readLine()) != null) body.append(line);
  String json = body.toString();

  String email = "", total = "0", currency = "USD";
  Matcher m;
  m = Pattern.compile("\"email\"\\s*:\\s*\"([^\"]+)\"").matcher(json); if (m.find()) email = m.group(1);
  m = Pattern.compile("\"total\"\\s*:\\s*([\\d.]+)").matcher(json); if (m.find()) total = m.group(1);
  m = Pattern.compile("\"currency\"\\s*:\\s*\"([^\"]+)\"").matcher(json); if (m.find()) currency = m.group(1);

  if (email.isEmpty()) {
    out.print("{\"code\":1,\"msg\":\"email required\"}");
    return;
  }

  String orderId = genOrderId();
  Connection conn = null;
  try {
    conn = getConn();
    conn.setAutoCommit(false);
    PreparedStatement ins = conn.prepareStatement(
      "INSERT INTO orders(id, email, address_json, total, currency) VALUES(?, ?, ?, ?, ?)");
    ins.setString(1, orderId);
    ins.setString(2, email);
    ins.setString(3, json);
    ins.setBigDecimal(4, new java.math.BigDecimal(total));
    ins.setString(5, currency);
    ins.executeUpdate();

    // 解析 items
    Matcher itemsM = Pattern.compile("\"items\"\\s*:\\s*\\[(.*?)\\]", Pattern.DOTALL).matcher(json);
    if (itemsM.find()) {
      String itemsStr = itemsM.group(1);
      Matcher oneM = Pattern.compile("\\{[^}]*\\}").matcher(itemsStr);
      PreparedStatement insItem = conn.prepareStatement(
        "INSERT INTO order_items(order_id, product_id, qty, price) VALUES(?,?,?,?)");
      while (oneM.find()) {
        String one = oneM.group();
        String pid = "", qty = "1", price = "0";
        Matcher tm;
        tm = Pattern.compile("\"id\"\\s*:\\s*(\\d+)").matcher(one); if (tm.find()) pid = tm.group(1);
        tm = Pattern.compile("\"qty\"\\s*:\\s*(\\d+)").matcher(one); if (tm.find()) qty = tm.group(1);
        tm = Pattern.compile("\"price\"\\s*:\\s*([\\d.]+)").matcher(one); if (tm.find()) price = tm.group(1);
        if (!pid.isEmpty()) {
          insItem.setString(1, orderId);
          insItem.setInt(2, Integer.parseInt(pid));
          insItem.setInt(3, Integer.parseInt(qty));
          insItem.setBigDecimal(4, new java.math.BigDecimal(price));
          insItem.executeUpdate();
        }
      }
    }
    conn.commit();
    out.print("{\"code\":0,\"orderId\":\"" + orderId + "\"}");
  } catch (Exception e) {
    if (conn != null) try { conn.rollback(); } catch (Exception ex) {}
    out.print("{\"code\":1,\"msg\":\"" + jsonStr(e.getMessage()) + "\"}");
  } finally {
    if (conn != null) try { conn.close(); } catch (Exception e) {}
  }
%>
