-- ============================================================
-- 步骤2: 创建扩展并创建所有数据库表
-- ============================================================

-- 启用加密扩展
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. 用户表 (users)
DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    sex BOOLEAN,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone CHAR(11),
    address TEXT
);

-- 2. 房间表 (rooms)
DROP TABLE IF EXISTS rooms CASCADE;
CREATE TABLE rooms (
    room_id SERIAL PRIMARY KEY,
    room_number VARCHAR(20) NOT NULL,
    room_type VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Available',
    description TEXT,
    average_rating DECIMAL(3, 2) DEFAULT 0.00
);

-- 3. 预订表 (reservations)
DROP TABLE IF EXISTS reservations CASCADE;
CREATE TABLE reservations (
    reservation_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in_time TIMESTAMP NOT NULL,
    check_out_time TIMESTAMP NOT NULL,
    reservation_status VARCHAR(20) DEFAULT 'Pending'
);

-- 4. 订单表 (orders)
DROP TABLE IF EXISTS orders CASCADE;
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    order_status VARCHAR(20) DEFAULT 'Pending',
    total_amount DECIMAL(10, 2) NOT NULL,
    order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. 用户评价表 (reviews)
DROP TABLE IF EXISTS reviews CASCADE;
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    room_id INT NOT NULL,
    content VARCHAR(500),
    rating DECIMAL(3, 2) CHECK (rating >= 1 AND rating <= 5)
);

-- 6. 审计日志表 (audit_log)
DROP TABLE IF EXISTS audit_log CASCADE;
CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    user_id INT,
    action VARCHAR(100),
    table_name VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 用户订单汇总临时表
DROP TABLE IF EXISTS user_order_summary CASCADE;
CREATE TABLE user_order_summary (
    user_id INT PRIMARY KEY,
    order_count INT DEFAULT 0,
    total_spent DECIMAL(10, 2) DEFAULT 0.00
);
