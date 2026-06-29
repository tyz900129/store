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
  out.print("{\"code\":0,\"user\":{\"username\":" + jsonStr((String)sess.getAttribute("adminUser"))
    + ",\"name\":" + jsonStr((String)sess.getAttribute("adminName"))
    + ",\"role\":" + jsonStr((String)sess.getAttribute("adminRole")) + "}}");
%>
