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
      String statusFilter = safeParam(request.getParameter("status"));
      String pageStr = safeParam(request.getParameter("page"));
      String sizeStr = safeParam(request.getParameter("size"));
      int pageNum = Math.max(1, safeInt(pageStr, 1));
      int sizeNum = Math.max(1, Math.min(100, safeInt(sizeStr, 20)));

      if (!id.isEmpty()) {
        // 订单详情 + 商品项
        ps = conn.prepareStatement(
          "SELECT id, email, address_json, total, currency, status, admin_note, created_at, updated_at FROM orders WHERE id = ?");
        ps.setString(1, id);
        rs = ps.executeQuery();
        if (rs.next()) {
          StringBuilder order = new StringBuilder();
          order.append("{\"code\":0,\"data\":{"
            + "\"id\":" + jsonStr(rs.getString("id")) + ","
            + "\"email\":" + jsonStr(rs.getString("email")) + ","
            + "\"address\":" + rs.getString("address_json") + ","
            + "\"total\":" + rs.getDouble("total") + ","
            + "\"currency\":" + jsonStr(rs.getString("currency")) + ","
            + "\"status\":" + jsonStr(rs.getString("status")) + ","
            + "\"admin_note\":" + jsonStr(rs.getString("admin_note")) + ","
            + "\"created_at\":" + jsonStr(rs.getString("created_at")) + ","
            + "\"updated_at\":" + jsonStr(rs.getString("updated_at")) + ","
            + "\"items\":");
          rs.close(); ps.close();

          ps = conn.prepareStatement(
            "SELECT oi.product_id, oi.qty, oi.price, p.title FROM order_items oi JOIN products p ON p.id = oi.product_id WHERE oi.order_id = ?");
          ps.setString(1, id);
          rs = ps.executeQuery();
          order.append("[");
          boolean first = true;
          while (rs.next()) {
            if (!first) order.append(",");
            first = false;
            order.append("{\"product_id\":" + rs.getInt("product_id"))
                 .append(",\"title\":" + jsonStr(rs.getString("title")))
                 .append(",\"qty\":" + rs.getInt("qty"))
                 .append(",\"price\":" + rs.getDouble("price"))
                 .append("}");
          }
          order.append("]}}");
          out.print(order.toString());
        } else {
          out.print("{\"code\":1,\"msg\":\"not found\"}");
        }
      } else {
        // 列表
        StringBuilder sql = new StringBuilder(
          "SELECT id, email, total, currency, status, created_at FROM orders WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (!statusFilter.isEmpty()) { sql.append("AND status = ? "); params.add(statusFilter); }
        sql.append("ORDER BY created_at DESC LIMIT ? OFFSET ?");
        params.add(sizeNum);
        params.add((pageNum - 1) * sizeNum);

        ps = conn.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
        rs = ps.executeQuery();
        StringBuilder items = new StringBuilder("[");
        boolean first = true;
        while (rs.next()) {
          if (!first) items.append(",");
          first = false;
          items.append("{\"id\":" + jsonStr(rs.getString("id")))
               .append(",\"email\":" + jsonStr(rs.getString("email")))
               .append(",\"total\":" + rs.getDouble("total"))
               .append(",\"currency\":" + jsonStr(rs.getString("currency")))
               .append(",\"status\":" + jsonStr(rs.getString("status")))
               .append(",\"created_at\":" + jsonStr(rs.getString("created_at")))
               .append("}");
        }
        items.append("]");
        rs.close(); ps.close();

        ps = conn.prepareStatement("SELECT COUNT(*) FROM orders" + (statusFilter.isEmpty() ? "" : " WHERE status = ?"));
        if (!statusFilter.isEmpty()) ps.setString(1, statusFilter);
        rs = ps.executeQuery();
        int total = 0;
        if (rs.next()) total = rs.getInt(1);

        out.print("{\"code\":0,\"data\":{\"items\":" + items
          + ",\"total\":" + total + ",\"page\":" + pageNum + ",\"size\":" + sizeNum + "}}");
      }
    } else if ("POST".equals(method)) {
      StringBuilder body = new StringBuilder();
      BufferedReader br = request.getReader();
      String line;
      while ((line = br.readLine()) != null) body.append(line);
      String json = body.toString();

      String orderId = "", status = "", note = "";
      Matcher m;
      m = Pattern.compile("\"id\"\\s*:\\s*\"([^\"]+)\"").matcher(json); if (m.find()) orderId = m.group(1);
      m = Pattern.compile("\"status\"\\s*:\\s*\"([^\"]+)\"").matcher(json); if (m.find()) status = m.group(1);
      m = Pattern.compile("\"admin_note\"\\s*:\\s*\"([^\"]*)\"").matcher(json); if (m.find()) note = m.group(1);

      if (orderId.isEmpty()) { out.print("{\"code\":1,\"msg\":\"id required\"}"); return; }

      ps = conn.prepareStatement("UPDATE orders SET status = ?, admin_note = ? WHERE id = ?");
      ps.setString(1, status.isEmpty() ? "pending" : status);
      ps.setString(2, note);
      ps.setString(3, orderId);
      ps.executeUpdate();
      out.print("{\"code\":0,\"msg\":\"updated\"}");
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
