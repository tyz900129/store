-- =====================================================
-- PawPatrol Store · 管理后台与安全增强
-- =====================================================
CREATE DATABASE IF NOT EXISTS `pawpatrol` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `pawpatrol`;

-- 管理员表
CREATE TABLE IF NOT EXISTS admin_users (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  username   VARCHAR(32)  NOT NULL UNIQUE,
  password   VARCHAR(255) NOT NULL COMMENT 'PBKDF2 hash',
  name       VARCHAR(64),
  role       ENUM('admin','editor') DEFAULT 'editor',
  last_login DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 默认管理员（密码: admin123，生产环境请立即修改）
INSERT IGNORE INTO admin_users (id, username, password, name, role) VALUES
  (1, 'admin', 'PBKDF2:f24npZR/fZ17zKi6RluDZg==:8srZSClUGDL1rNDichV6/Ccfj9D3IZ/UbLQOsU2VqJU=', 'Administrator', 'admin');

-- 订单表增强：添加备注字段（如果已存在则跳过）
ALTER TABLE orders ADD COLUMN admin_note TEXT;
ALTER TABLE orders ADD COLUMN updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- 产品表增强：添加状态字段
ALTER TABLE products ADD COLUMN status ENUM('active','inactive','soldout') DEFAULT 'active';