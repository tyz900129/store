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
  Statement st = null;
  ResultSet rs = null;
  StringBuilder outBuf = new StringBuilder();
  try {
    conn = getConn();
    st = conn.createStatement();

    int productCount = 0, orderCount = 0, subscriberCount = 0, reviewCount = 0;
    double totalRevenue = 0;

    rs = st.executeQuery("SELECT COUNT(*) FROM products");
    if (rs.next()) productCount = rs.getInt(1);
    rs.close();

    rs = st.executeQuery("SELECT COUNT(*) FROM orders");
    if (rs.next()) orderCount = rs.getInt(1);
    rs.close();

    rs = st.executeQuery("SELECT COUNT(*) FROM subscribers");
    if (rs.next()) subscriberCount = rs.getInt(1);
    rs.close();

    rs = st.executeQuery("SELECT COUNT(*) FROM reviews");
    if (rs.next()) reviewCount = rs.getInt(1);
    rs.close();

    rs = st.executeQuery("SELECT COALESCE(SUM(total),0) FROM orders WHERE status IN ('paid','shipped','done')");
    if (rs.next()) totalRevenue = rs.getDouble(1);
    rs.close();

    // 最近 7 天订单数
    rs = st.executeQuery(
      "SELECT DATE(created_at) as d, COUNT(*) as c FROM orders WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) GROUP BY DATE(created_at) ORDER BY d");
    StringBuilder trend = new StringBuilder();
    trend.append("[");
    boolean first = true;
    while (rs.next()) {
      if (!first) trend.append(",");
      first = false;
      trend.append("{\"date\":").append(jsonStr(rs.getString("d")))
           .append(",\"count\":").append(rs.getInt("c")).append("}");
    }
    trend.append("]");
    rs.close();

    // 最近 5 个订单
    rs = st.executeQuery(
      "SELECT id, email, total, status, created_at FROM orders ORDER BY created_at DESC LIMIT 5");
    StringBuilder recentOrders = new StringBuilder();
    recentOrders.append("[");
    first = true;
    while (rs.next()) {
      if (!first) recentOrders.append(",");
      first = false;
      recentOrders.append("{\"id\":").append(jsonStr(rs.getString("id")))
        .append(",\"email\":").append(jsonStr(rs.getString("email")))
        .append(",\"total\":").append(rs.getDouble("total"))
        .append(",\"status\":").append(jsonStr(rs.getString("status")))
        .append(",\"created_at\":").append(jsonStr(rs.getString("created_at")))
        .append("}");
    }
    recentOrders.append("]");
    rs.close();

    outBuf.append("{\"code\":0,\"data\":{")
      .append("\"products\":").append(productCount).append(",")
      .append("\"orders\":").append(orderCount).append(",")
      .append("\"subscribers\":").append(subscriberCount).append(",")
      .append("\"reviews\":").append(reviewCount).append(",")
      .append("\"revenue\":").append(totalRevenue).append(",")
      .append("\"trend\":").append(trend).append(",")
      .append("\"recentOrders\":").append(recentOrders)
      .append("}}");
    out.print(outBuf.toString());
  } catch (Exception e) {
    sendError(out);
  } finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (st != null) try { st.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
  }
%>
