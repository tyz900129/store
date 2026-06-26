-- =====================================================
-- PawPatrol Store · 数据库初始化
-- 在 MySQL 8.x 中执行
-- =====================================================

CREATE DATABASE IF NOT EXISTS `pawpatrol` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `pawpatrol`;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS subscribers;

CREATE TABLE categories (
  id        VARCHAR(32) PRIMARY KEY,
  name      VARCHAR(64)  NOT NULL,
  icon      VARCHAR(32),
  sort      INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE products (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  title         VARCHAR(255) NOT NULL,
  slug          VARCHAR(255) UNIQUE,
  description   TEXT,
  price         DECIMAL(10,2) NOT NULL,
  original_price DECIMAL(10,2) NULL,
  currency      CHAR(3) DEFAULT 'USD',
  images_json   JSON,
  category_id   VARCHAR(32),
  pet           ENUM('cat','dog','small','all') DEFAULT 'all',
  stock         INT DEFAULT 0,
  rating        DECIMAL(3,2) DEFAULT 5.00,
  created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id),
  INDEX idx_pet (pet),
  INDEX idx_cat (category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE orders (
  id           VARCHAR(32) PRIMARY KEY,
  email        VARCHAR(128) NOT NULL,
  address_json JSON,
  total        DECIMAL(10,2),
  currency     CHAR(3) DEFAULT 'USD',
  status       ENUM('pending','paid','shipped','done','refund') DEFAULT 'pending',
  created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE order_items (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  order_id   VARCHAR(32),
  product_id INT,
  qty        INT,
  price      DECIMAL(10,2),
  FOREIGN KEY (order_id)   REFERENCES orders(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE reviews (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT,
  author     VARCHAR(64),
  rating     INT,
  content    TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE subscribers (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  email      VARCHAR(128) UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
