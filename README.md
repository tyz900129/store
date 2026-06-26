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
├── api/                    # JSP 后端接口
│   ├── products.jsp        # 商品列表/详情
│   ├── categories.jsp      # 分类
│   ├── subscribe.jsp       # 邮件订阅
│   └── order.jsp           # 订单提交
├── migrations/
│   ├── 001_init.sql        # 建表
│   └── 002_seed.sql        # 初始数据
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
```

### 4. 部署到 Tomcat

把整个 `store/` 目录复制到 Tomcat 的 `webapps/` 下，重启 Tomcat：

```bash
cp -r store /opt/tomcat/webapps/
/opt/tomcat/bin/catalina.sh restart
```

### 5. 访问

浏览器打开 `http://localhost:8866/store/`

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

## 安全

参见 `.trae/documents/SECURITY.md`（待补充）

## 许可

本仓库为个人/团队内部使用，未指定开源许可。
