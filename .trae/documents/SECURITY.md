# PawPatrol Store 安全说明

## 已修复的安全问题

### 1. SQL 注入防护
- 所有数据库查询已统一使用 `PreparedStatement`，禁止字符串拼接 SQL
- `categories.jsp` 原使用 `Statement`，已升级为 `PreparedStatement`

### 2. 密码安全
- 管理员密码使用 **PBKDF2WithHmacSHA256**（100,000 轮迭代 + 随机 16 字节盐）存储
- 禁止明文或弱哈希（如 MD5/SHA1 无盐）保存密码
- 默认管理员账号：`admin` / `admin123`（生产环境请立即修改）

### 3. 会话与认证
- 管理后台使用 JSP Session，配置 30 分钟超时
- 所有 Admin API 均校验 Session，未登录返回 401
- 角色区分：`admin`（可增删改） vs `editor`（仅查看/编辑）
- 登出接口立即销毁 Session

### 4. 安全响应头
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 1; mode=block`
- `Referrer-Policy: strict-origin-when-cross-origin`
- 公共 API 保留受控的 CORS（管理 API 不开放跨域）

### 5. 错误信息隐藏
- 生产环境异常不再直接返回堆栈或数据库错误详情
- 统一返回 `{code:1, msg:"internal error"}`，详情记录于服务器日志

### 6. 输入校验
- 邮箱格式校验（订阅、订单）
- Slug 格式限制 `[a-z0-9-]+`
- 数值参数安全转换（异常时回退到默认值）
- 分页大小上限限制（防止全表扫描）

### 7. 随机数安全
- 订单号生成从 `java.util.Random` 升级为 `java.security.SecureRandom`

### 8. 数据库连接
- JDBC URL 已启用 `useSSL=true`（生产环境请配置有效证书）
- 移除 `allowPublicKeyRetrieval=true`（仅在开发/测试环境需要）

## 仍需注意的事项

1. **HTTPS**：生产环境必须全站启用 HTTPS，防止 Session Cookie 被窃听
2. **Rate Limiting**：当前未实现请求频率限制，建议在 Nginx/Cloudflare 层配置
3. **文件上传**：管理后台目前无图片上传功能，所有图片使用外部 URL；如需上传请单独实现文件类型与大小校验
4. **CSRF**：当前公共 API（订阅、下单）无 CSRF Token，建议前端页面与 API 同源部署以降低风险
5. **日志审计**：建议定期审计 `admin_users.last_login` 和订单变更记录
