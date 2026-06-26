# PawPatrol Store · 跨境电商独立站

> Handcrafted pet goods for cats, dogs and small pets.
> 部署在 Tomcat (端口 8866)，生产域名 `https://www.apperload.com/store/`。

## 目录结构

```
store/
├── index.html             # 首页
├── products.html          # 列表页
├── product.html           # 详情页
├── cart.html              # 购物车
├── checkout.html          # 结算
├── about.html             # 关于
├── contact.html           # 联系
├── 404.html               # 错误页
├── assets/
│   ├── css/               # 4 个 CSS 文件（base / layout / components / pages）
│   ├── js/                # main + data + cart + ui + pages/*
│   └── img/               # 图片（默认通过 Unsplash 远程加载）
├── api/                   # JSP 后端 API（输出 JSON）
│   ├── products.jsp
│   ├── categories.jsp
│   ├── subscribe.jsp
│   └── order.jsp
├── WEB-INF/
│   ├── web.xml
│   └── classes/db.properties
├── migrations/            # SQL 迁移文件
└── .trae/documents/       # PRD + 技术架构
```

## 部署步骤

1. **准备数据库**：在 MySQL 中执行
   ```bash
   mysql -uroot -p < migrations/001_init.sql
   mysql -uroot -p < migrations/002_seed.sql
   ```

2. **配置连接**（任选其一）：
   - 设置环境变量：`DB_HOST / DB_PORT / DB_NAME / DB_USER / DB_PASS`
   - 或修改 `WEB-INF/classes/db.properties`

3. **放置应用**：把 `store/` 目录复制到 Tomcat `webapps/` 下
   ```
   /vol1/@appdata/1Panel/1panel/apps/tomcat/tomcat/data/webapps/store
   ```

4. **访问**：
   - 内网：`http://<host>:8866/store/`
   - 域名：`https://www.apperload.com/store/`

## 框架特性

- ✅ 零构建：纯 HTML / CSS / ES Module JS，部署即用
- ✅ 响应式：桌面 / 平板 / 手机三档断点
- ✅ 可访问：语义化 HTML + 颜色对比度 ≥ 4.5:1
- ✅ 国际化：Intl API 原生多币种 / 多语言
- ✅ 状态：购物车 LocalStorage 持久化
- ✅ 后端：JSP 直连 MySQL 8.x
- ✅ 优雅降级：API 失败自动回退到 mock 数据

## 数据流

```
浏览器 (HTML+JS)
  ├─ 静态资源 ──→ /store/...
  └─ fetch JSON ──→ /store/api/*.jsp ──→ MySQL
```

## 二次开发

- **新增商品**：在 `migrations/002_seed.sql` 中插入 `products` 行
- **新增页面**：复制 `product.html` 模板，添加 `assets/js/pages/yourpage.js`
- **改 API**：编辑 `api/*.jsp`，调整 JSON 字段即可
- **改样式**：编辑 `assets/css/base.css` 中的 CSS 变量（颜色 / 间距 / 圆角）

## 后续路线

- [ ] Stripe / PayPal 真实支付
- [ ] 邮件确认（SendGrid / SMTP）
- [ ] 管理后台 `/admin/`
- [ ] 多语言 i18n
- [ ] Algolia 全文搜索
