<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.util.*" %>
<%!
  String readStream(InputStream is) throws Exception {
    BufferedReader br = new BufferedReader(new InputStreamReader(is, "UTF-8"));
    StringBuilder sb = new StringBuilder();
    String line;
    while ((line = br.readLine()) != null) { sb.append(line).append("\n"); }
    return sb.toString();
  }
%>
<%
  request.setCharacterEncoding("UTF-8");
  response.setContentType("application/json;charset=UTF-8");

  // 从环境变量读取部署密钥（推荐），或在此硬编码（不推荐）
  String expectedToken = System.getenv().getOrDefault("DEPLOY_TOKEN", "CHANGE_ME_IN_PRODUCTION");
  String reqToken = request.getParameter("token");
  if (reqToken == null || !reqToken.equals(expectedToken)) {
    response.setStatus(403);
    out.print("{\"code\":403,\"msg\":\"invalid token\"}");
    return;
  }

  String storeDir = "/vol1/@appdata/1Panel/1panel/apps/tomcat/tomcat/data/webapps/store";
  String gitConfig = "/vol1/@appdata/1Panel/1panel/apps/tomcat/tomcat/data/webapps/.gitconfig";

  List<String> output = new ArrayList<>();
  List<String> errors = new ArrayList<>();

  try {
    ProcessBuilder pb = new ProcessBuilder("bash", "-c",
      "cd " + storeDir + " && export GIT_CONFIG_GLOBAL=" + gitConfig + " && git fetch origin main && git pull --rebase --autostash origin main");
    pb.redirectErrorStream(false);
    Process p = pb.start();

    String stdout = readStream(p.getInputStream());
    String stderr = readStream(p.getErrorStream());
    int exitCode = p.waitFor();

    out.print("{\"code\":" + exitCode + ",\"stdout\":");
    out.print("\"");
    for (char c : stdout.toCharArray()) {
      if (c == '"') out.print("\\\"");
      else if (c == '\\') out.print("\\\\");
      else if (c == '\n') out.print("\\n");
      else if (c == '\r') out.print("\\r");
      else if (c < 0x20) out.print(String.format("\\u%04x", (int)c));
      else out.print(c);
    }
    out.print("\",\"stderr\":");
    out.print("\"");
    for (char c : stderr.toCharArray()) {
      if (c == '"') out.print("\\\"");
      else if (c == '\\') out.print("\\\\");
      else if (c == '\n') out.print("\\n");
      else if (c == '\r') out.print("\\r");
      else if (c < 0x20) out.print(String.format("\\u%04x", (int)c));
      else out.print(c);
    }
    out.print("\"}");
  } catch (Exception e) {
    out.print("{\"code\":1,\"msg\":\"exception: " + e.getMessage().replace("\\", "\\\\").replace("\"", "\\\"") + "\"}");
  }
%>
