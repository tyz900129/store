<%@ page import="java.sql.*, java.util.*, java.text.*, java.security.*, javax.crypto.*, javax.crypto.spec.*, java.util.Base64, java.util.regex.*, java.io.*" %>
<%@ page import="java.util.regex.Pattern, java.util.regex.Matcher" %>
<%!
  // ==================== JSON 工具 ====================
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

  String jsonNum(Object n) {
    if (n == null) return "null";
    return n.toString();
  }

  // ==================== 数据库连接 ====================
  // 优先级: 环境变量 > db.properties (固定路径) > 内置默认
  private static final String DB_PROPS_PATH =
    "/vol1/@appdata/1Panel/1panel/apps/tomcat/tomcat/data/webapps/store/WEB-INF/classes/db.properties";
  private static Properties DB_PROPS = null;
  private static synchronized Properties loadDbProps() {
    if (DB_PROPS != null) return DB_PROPS;
    DB_PROPS = new Properties();
    try {
      java.io.FileInputStream fis = new java.io.FileInputStream(DB_PROPS_PATH);
      DB_PROPS.load(fis);
      fis.close();
    } catch (Exception e) { /* 文件不存在时保持空,走环境变量或默认 */ }
    return DB_PROPS;
  }

  String dbProp(String key, String def) {
    String env = System.getenv(key);
    if (env != null && !env.isEmpty()) return env;
    return loadDbProps().getProperty(key, def);
  }

  Connection getConn() throws Exception {
    Class.forName("com.mysql.cj.jdbc.Driver");
    String host = dbProp("DB_HOST", "127.0.0.1");
    String port = dbProp("DB_PORT", "3306");
    String name = dbProp("DB_NAME", "pawpatrol");
    String user = dbProp("DB_USER", "root");
    String pass = dbProp("DB_PASS", "");
    String url = "jdbc:mysql://" + host + ":" + port + "/" + name
               + "?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    return DriverManager.getConnection(url, user, pass);
  }

  // ==================== 密码哈希 (PBKDF2) ====================
  String hashPassword(String password) {
    try {
      SecureRandom random = new SecureRandom();
      byte[] salt = new byte[16];
      random.nextBytes(salt);
      PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, 100000, 256);
      SecretKeyFactory f = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
      byte[] hash = f.generateSecret(spec).getEncoded();
      return "PBKDF2:" + Base64.getEncoder().encodeToString(salt) + ":" + Base64.getEncoder().encodeToString(hash);
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }

  boolean checkPassword(String password, String stored) {
    try {
      if (!stored.startsWith("PBKDF2:")) return false;
      String[] parts = stored.substring(7).split(":");
      if (parts.length != 2) return false;
      byte[] salt = Base64.getDecoder().decode(parts[0]);
      byte[] hash = Base64.getDecoder().decode(parts[1]);
      PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, 100000, 256);
      SecretKeyFactory f = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
      byte[] testHash = f.generateSecret(spec).getEncoded();
      return MessageDigest.isEqual(hash, testHash);
    } catch (Exception e) {
      return false;
    }
  }

  // ==================== 安全响应头 ====================
  void setSecurityHeaders(HttpServletResponse response, boolean allowCors) {
    response.setContentType("application/json;charset=UTF-8");
    response.setHeader("X-Content-Type-Options", "nosniff");
    response.setHeader("X-Frame-Options", "DENY");
    response.setHeader("X-XSS-Protection", "1; mode=block");
    response.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
    if (allowCors) {
      response.setHeader("Access-Control-Allow-Origin", "*");
      response.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
      response.setHeader("Access-Control-Allow-Headers", "Content-Type");
    }
  }

  // ==================== Session 验证 ====================
  boolean requireAdmin(HttpSession session) {
    return session != null && session.getAttribute("adminUser") != null;
  }

  boolean requireAdmin(HttpSession session, String minRole) {
    if (session == null) return false;
    Object role = session.getAttribute("adminRole");
    if (role == null) return false;
    if ("admin".equals(minRole)) return "admin".equals(role);
    return true; // editor or admin
  }

  void sendAuthError(JspWriter out) throws Exception {
    out.print("{\"code\":401,\"msg\":\"unauthorized\"}");
  }

  // ==================== 输入校验 ====================
  String safeParam(String s) {
    if (s == null) return "";
    return s.trim();
  }

  boolean isValidEmail(String email) {
    return email != null && email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
  }

  boolean isValidSlug(String slug) {
    return slug != null && slug.matches("^[a-z0-9-]+$");
  }

  int safeInt(String s, int def) {
    try { return Integer.parseInt(s.trim()); } catch (Exception e) { return def; }
  }

  double safeDouble(String s, double def) {
    try { return Double.parseDouble(s.trim()); } catch (Exception e) { return def; }
  }

  // ==================== 安全随机 ====================
  String secureRandomString(int len) {
    String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    SecureRandom r = new SecureRandom();
    StringBuilder sb = new StringBuilder(len);
    for (int i = 0; i < len; i++) sb.append(chars.charAt(r.nextInt(chars.length())));
    return sb.toString();
  }

  String genOrderId() {
    return "PP" + new SimpleDateFormat("yyyyMMdd").format(new java.util.Date())
                 + String.format("%04d", new SecureRandom().nextInt(9000) + 1000);
  }

  // ==================== 通用错误输出（隐藏细节） ====================
  void sendError(JspWriter out, String msg) throws Exception {
    out.print("{\"code\":1,\"msg\":\"" + jsonStr(msg) + "\"}");
  }

  void sendError(JspWriter out) throws Exception {
    out.print("{\"code\":1,\"msg\":\"internal error\"}");
  }

  // 调试模式：环境变量 DEBUG_ADMIN=1 时输出真实异常
  void sendError(JspWriter out, Exception e) throws Exception {
    String dbg = System.getenv("DEBUG_ADMIN");
    if ("1".equals(dbg)) {
      StringWriter sw = new StringWriter();
      PrintWriter pw = new PrintWriter(sw);
      e.printStackTrace(pw);
      String stack = sw.toString().replace("\n", "\\n").replace("\"", "'");
      out.print("{\"code\":1,\"msg\":\"err: " + e.getClass().getSimpleName() + ": " + jsonStr(e.getMessage()) + "\",\"debug\":\"" + stack + "\"}");
    } else {
      out.print("{\"code\":1,\"msg\":\"internal error\"}");
    }
  }
%>