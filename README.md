# PawPatrol Store

> 跨境电商独立站框架 · 主营宠物周边 · Tomnee 的第一个 storefront

## 在线访问

🌐 **https://www.apperload.com/store/**

## 技术栈

- **前端**：原生 HTML + CSS + ES Module JavaScript（无构建步骤）
- **后端**：JSP + JDBC 直连 MySQL
- **服务器**：Tomcat 8.5+（端口 8866，Cloudflare 隧道映射到域名）
- **数据库**：MySQL 5.7+ / 8.0

## 目录结构

```
store/
├── index.html              # 首页
├── products.html           # 商品列表
├── product.html            # 商品详情
├── cart.html               # 购物车
├── checkout.html           # 结算
├── about.html              # 关于我们
├── contact.html            # 联系我们
├── 404.html                # 404 页面
├── assets/
│   ├── css/                # 样式（base/layout/components/pages）
│   ├── js/                 # JS 模块（data/cart/ui/main/pages）
│   └── img/                # 图片
├── admin/                  # 管理后台（单页应用）
│   ├── login.html          # 登录页
│   └── index.html          # 控制台（仪表盘/商品/订单/订阅）
├── api/                    # JSP 后端接口
│   ├── products.jsp        # 商品列表/详情
│   ├── categories.jsp      # 分类
│   ├── subscribe.jsp       # 邮件订阅
│   ├── order.jsp           # 订单提交
│   ├── lib.jsp             # 公共工具（JSON/安全/数据库）
│   └── admin/              # 管理后台 API
│       ├── login.jsp       # 登录
│       ├── logout.jsp      # 登出
│       ├── session.jsp     # 会话校验
│       ├── dashboard.jsp   # 仪表盘统计
│       ├── products.jsp    # 商品 CRUD
│       ├── orders.jsp      # 订单管理
│       └── subscribers.jsp # 订阅列表
├── migrations/
│   ├── 001_init.sql        # 建表
│   ├── 002_seed.sql        # 初始数据
│   └── 003_admin.sql       # 管理后台与安全增强
├── WEB-INF/
│   ├── web.xml             # Servlet 配置
│   ├── classes/            # 编译产物
│   │   ├── db.properties.example
│   │   └── db.properties   # 真实配置（git ignored）
│   └── lib/                # 依赖 JAR
├── .gitignore
├── deploy.sh               # 部署脚本
└── README.md
```

## 快速开始

### 1. 克隆仓库

```bash
git clone git@github.com:tyz900129/store.git
cd store
```

### 2. 配置数据库

```bash
cp WEB-INF/classes/db.properties.example WEB-INF/classes/db.properties
# 编辑 db.properties 填入真实数据库信息
# 或使用环境变量（推荐）：
#   export DB_HOST=mysql
#   export DB_PORT=3306
#   export DB_NAME=pawpatrol
#   export DB_USER=root
#   export DB_PASS=your_password
```

### 3. 初始化数据库

```bash
mysql -u root -p pawpatrol < migrations/001_init.sql
mysql -u root -p pawpatrol < migrations/002_seed.sql
mysql -u root -p pawpatrol < migrations/003_admin.sql
```

### 4. 部署到 Tomcat

把整个 `store/` 目录复制到 Tomcat 的 `webapps/` 下，重启 Tomcat：

```bash
cp -r store /opt/tomcat/webapps/
/opt/tomcat/bin/catalina.sh restart
```

### 5. 访问

浏览器打开 `http://localhost:8866/store/`

管理后台：`http://localhost:8866/store/admin/login.html`
- 默认账号：`admin`
- 默认密码：`admin123`（生产环境请立即修改）

## 开发工作流（Trae Solo）

```bash
# 1. Trae Solo 打开 store/ 目录
# 2. AI 修改代码后点 Accept
# 3. 提交并推送
git add .
git commit -m "feat: 商品详情页加入颜色切换"
git push

# 4. 服务器拉取最新
./deploy.sh
```

## API 端点

| 端点 | 方法 | 说明 |
|------|------|------|
| `/store/api/products.jsp` | GET | 商品列表（支持 `?category=bed&pet=dog&q=xxx`） |
| `/store/api/products.jsp?id=1` | GET | 商品详情 |
| `/store/api/categories.jsp` | GET | 商品分类 |
| `/store/api/subscribe.jsp` | POST | 邮件订阅 |
| `/store/api/order.jsp` | POST | 提交订单 |
| `/store/api/admin/login.jsp` | POST | 管理员登录 |
| `/store/api/admin/logout.jsp` | POST | 登出 |
| `/store/api/admin/dashboard.jsp` | GET | 仪表盘数据 |
| `/store/api/admin/products.jsp` | GET/POST/DELETE | 商品 CRUD |
| `/store/api/admin/orders.jsp` | GET/POST | 订单管理 |
| `/store/api/admin/subscribers.jsp` | GET | 订阅列表 |

## 安全

参见 [`.trae/documents/SECURITY.md`](.trae/documents/SECURITY.md)。主要改进包括：

- 全站 API 启用安全响应头（nosniff、X-Frame-Options、XSS-Protection）
- 管理员密码使用 PBKDF2 哈希存储
- 所有数据库查询使用 PreparedStatement，防止 SQL 注入
- 异常信息不再暴露给客户端
- 订单号生成使用 SecureRandom

## 许可

本仓库为个人/团队内部使用，未指定开源许可。
