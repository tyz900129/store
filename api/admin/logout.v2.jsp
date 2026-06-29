<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ include file="../lib.jsp" %>
<%
  request.setCharacterEncoding("UTF-8");
  setSecurityHeaders(response, false);
  HttpSession sess = request.getSession(false);
  if (sess != null) sess.invalidate();
  out.print("{\"code\":0,\"msg\":\"logged out\"}");
%>
