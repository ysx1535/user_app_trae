-- 创建数据库
CREATE DATABASE IF NOT EXISTS user_app
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE user_app;

-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  create_time DATETIME NOT NULL,
  INDEX idx_username (username),
  INDEX idx_create_time (create_time),
  INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;