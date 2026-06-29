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

  String method = request.getMethod();
  Connection conn = null;
  PreparedStatement ps = null;
  ResultSet rs = null;

  try {
    conn = getConn();

    if ("GET".equals(method)) {
      String id = safeParam(request.getParameter("id"));
      String pageStr = safeParam(request.getParameter("page"));
      String sizeStr = safeParam(request.getParameter("size"));
      int pageNum = Math.max(1, safeInt(pageStr, 1));
      int sizeNum = Math.max(1, Math.min(100, safeInt(sizeStr, 20)));

      if (!id.isEmpty()) {
        ps = conn.prepareStatement(
          "SELECT id, title, slug, description, price, original_price, currency, images_json, category_id, pet, stock, status, rating, created_at FROM products WHERE id = ?");
        ps.setInt(1, safeInt(id, 0));
        rs = ps.executeQuery();
        if (rs.next()) {
          out.print("{\"code\":0,\"data\":{""
            + "\"id\":" + rs.getInt("id") + ","
            + "\"title\":" + jsonStr(rs.getString("title")) + ","
            + "\"slug\":" + jsonStr(rs.getString("slug")) + ","
            + "\"description\":" + jsonStr(rs.getString("description")) + ","
            + "\"price\":" + rs.getDouble("price") + ","
            + "\"original_price\":" + (rs.getObject("original_price") == null ? "null" : rs.getDouble("original_price")) + ","
            + "\"currency\":" + jsonStr(rs.getString("currency")) + ","
            + "\"images\":" + rs.getString("images_json") + ","
            + "\"category_id\":" + jsonStr(rs.getString("category_id")) + ","
            + "\"pet\":" + jsonStr(rs.getString("pet")) + ","
            + "\"stock\":" + rs.getInt("stock") + ","
            + "\"status\":" + jsonStr(rs.getString("status")) + ","
            + "\"rating\":" + rs.getDouble("rating") + ","
            + "\"created_at\":" + jsonStr(rs.getString("created_at"))
            + "}}");
        } else {
          out.print("{\"code\":1,\"msg\":\"not found\"}");
        }
      } else {
        // list
        ps = conn.prepareStatement(
          "SELECT p.id, p.title, p.slug, p.price, p.stock, p.status, c.name AS category_name FROM products p LEFT JOIN categories c ON c.id = p.category_id ORDER BY p.id DESC LIMIT ? OFFSET ?");
        ps.setInt(1, sizeNum);
        ps.setInt(2, (pageNum - 1) * sizeNum);
        rs = ps.executeQuery();
        StringBuilder items = new StringBuilder("[");
        boolean first = true;
        while (rs.next()) {
          if (!first) items.append(",");
          first = false;
          items.append("{\"id\":" + rs.getInt("id"))
               .append(",\"title\":" + jsonStr(rs.getString("title")))
               .append(",\"slug\":" + jsonStr(rs.getString("slug")))
               .append(",\"price\":" + rs.getDouble("price"))
               .append(",\"stock\":" + rs.getInt("stock"))
               .append(",\"status\":" + jsonStr(rs.getString("status")))
               .append(",\"category\":" + jsonStr(rs.getString("category_name")))
               .append("}");
        }
        items.append("]");
        rs.close(); ps.close();

        ps = conn.prepareStatement("SELECT COUNT(*) FROM products");
        rs = ps.executeQuery();
        int total = 0;
        if (rs.next()) total = rs.getInt(1);

        out.print("{\"code\":0,\"data\":{\"items\":" + items
          + ",\"total\":" + total + ",\"page\":" + pageNum + ",\"size\":" + sizeNum + "}}");
      }
    } else if ("POST".equals(method)) {
      if (!requireAdmin(sess, "admin")) {
        sendAuthError(out); return;
      }
      StringBuilder body = new StringBuilder();
      BufferedReader br = request.getReader();
      String line;
      while ((line = br.readLine()) != null) body.append(line);
      String json = body.toString();

      String action = "", id = "";
      Matcher m = Pattern.compile("\"action\"\\s*:\\s*\"([^\"]+)\"").matcher(json);
      if (m.find()) action = m.group(1);
      m = Pattern.compile("\"id\"\\s*:\\s*(\\d+)").matcher(json);
      if (m.find()) id = m.group(1);

      String title = extractJsonStr(json, "title");
      String slug = extractJsonStr(json, "slug");
      String description = extractJsonStr(json, "description");
      String price = extractJsonNum(json, "price");
      String originalPrice = extractJsonNum(json, "original_price");
      String categoryId = extractJsonStr(json, "category_id");
      String pet = extractJsonStr(json, "pet");
      String stock = extractJsonNum(json, "stock");
      String status = extractJsonStr(json, "status");
      String imagesJson = extractJsonStr(json, "images_json");

      if ("update".equals(action) && !id.isEmpty()) {
        ps = conn.prepareStatement(
          "UPDATE products SET title=?, slug=?, description=?, price=?, original_price=?, category_id=?, pet=?, stock=?, status=?, images_json=? WHERE id=?");
        ps.setString(1, title);
        ps.setString(2, slug);
        ps.setString(3, description);
        ps.setBigDecimal(4, new java.math.BigDecimal(price.isEmpty() ? "0" : price));
        if (originalPrice.isEmpty()) ps.setNull(5, Types.DECIMAL);
        else ps.setBigDecimal(5, new java.math.BigDecimal(originalPrice));
        ps.setString(6, categoryId);
        ps.setString(7, pet.isEmpty() ? "all" : pet);
        ps.setInt(8, safeInt(stock, 0));
        ps.setString(9, status.isEmpty() ? "active" : status);
        ps.setString(10, imagesJson.isEmpty() ? "[]" : imagesJson);
        ps.setInt(11, safeInt(id, 0));
        ps.executeUpdate();
        out.print("{\"code\":0,\"msg\":\"updated\"}");
      } else if ("create".equals(action)) {
        if (title.isEmpty()) { out.print("{\"code\":1,\"msg\":\"title required\"}"); return; }
        ps = conn.prepareStatement(
          "INSERT INTO products(title, slug, description, price, original_price, category_id, pet, stock, status, images_json) VALUES(?,?,?,?,?,?,?,?,?,?)", Statement.RETURN_GENERATED_KEYS);
        ps.setString(1, title);
        ps.setString(2, slug.isEmpty() ? null : slug);
        ps.setString(3, description);
        ps.setBigDecimal(4, new java.math.BigDecimal(price.isEmpty() ? "0" : price));
        if (originalPrice.isEmpty()) ps.setNull(5, Types.DECIMAL);
        else ps.setBigDecimal(5, new java.math.BigDecimal(originalPrice));
        ps.setString(6, categoryId);
        ps.setString(7, pet.isEmpty() ? "all" : pet);
        ps.setInt(8, safeInt(stock, 0));
        ps.setString(9, status.isEmpty() ? "active" : status);
        ps.setString(10, imagesJson.isEmpty() ? "[]" : imagesJson);
        ps.executeUpdate();
        rs = ps.getGeneratedKeys();
        int newId = 0;
        if (rs.next()) newId = rs.getInt(1);
        out.print("{\"code\":0,\"id\":" + newId + ",\"msg\":\"created\"}");
      } else {
        out.print("{\"code\":1,\"msg\":\"invalid action\"}");
      }
    } else if ("DELETE".equals(method)) {
      if (!requireAdmin(sess, "admin")) {
        sendAuthError(out); return;
      }
      String id = safeParam(request.getParameter("id"));
      if (id.isEmpty()) { out.print("{\"code\":1,\"msg\":\"id required\"}"); return; }
      ps = conn.prepareStatement("DELETE FROM products WHERE id = ?");
      ps.setInt(1, safeInt(id, 0));
      ps.executeUpdate();
      out.print("{\"code\":0,\"msg\":\"deleted\"}");
    } else {
      out.print("{\"code\":1,\"msg\":\"method not supported\"}");
    }
  } catch (Exception e) {
    sendError(out);
  } finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (ps != null) try { ps.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
  }
%>
<%!
  // 简单的 JSON 字段提取辅助（仅用于 admin POST）
  String extractJsonStr(String json, String key) {
    Matcher m = Pattern.compile("\"" + key + "\"\\s*:\\s*\"([^\"]*)\"").matcher(json);
    if (m.find()) return m.group(1);
    return "";
  }
  String extractJsonNum(String json, String key) {
    Matcher m = Pattern.compile("\"" + key + "\"\\s*:\\s*([\\d.]+|null)").matcher(json);
    if (m.find()) { String v = m.group(1); return "null".equals(v) ? "" : v; }
    m = Pattern.compile("\"" + key + "\"\\s*:\\s*\"([\\d.]*)\"").matcher(json);
    if (m.find()) return m.group(1);
    return "";
  }
%>
