-- ============================================================
-- 在线客房管理系统 - 完整数据库SQL脚本
-- 数据库: PostgreSQL
-- 项目名称: OnlineHotelSystem
-- ============================================================

-- 一、创建数据库
DROP DATABASE IF EXISTS OnlineHotelSystem;
CREATE DATABASE OnlineHotelSystem
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'zh_CN.UTF-8'
    LC_CTYPE = 'zh_CN.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

\c OnlineHotelSystem;

-- 启用加密扩展
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 二、创建数据库表

-- 1. 用户表 (users)
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
CREATE TABLE reservations (
    reservation_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in_time TIMESTAMP NOT NULL,
    check_out_time TIMESTAMP NOT NULL,
    reservation_status VARCHAR(20) DEFAULT 'Pending'
);

-- 4. 订单表 (orders)
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    order_status VARCHAR(20) DEFAULT 'Pending',
    total_amount DECIMAL(10, 2) NOT NULL,
    order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. 用户评价表 (reviews)
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    room_id INT NOT NULL,
    content VARCHAR(500),
    rating DECIMAL(3, 2) CHECK (rating >= 1 AND rating <= 5)
);

-- 6. 审计日志表 (audit_log)
CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    user_id INT,
    action VARCHAR(100),
    table_name VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 用户订单汇总临时表（用于游标存储过程）
CREATE TABLE IF NOT EXISTS user_order_summary (
    user_id INT PRIMARY KEY,
    order_count INT DEFAULT 0,
    total_spent DECIMAL(10, 2) DEFAULT 0.00
);

-- 三、参照完整性：创建外键约束

-- 预订表外键
ALTER TABLE reservations
    ADD CONSTRAINT fk_reservations_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE reservations
    ADD CONSTRAINT fk_reservations_room
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- 订单表外键
ALTER TABLE orders
    ADD CONSTRAINT fk_orders_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- 评价表外键
ALTER TABLE reviews
    ADD CONSTRAINT fk_reviews_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE reviews
    ADD CONSTRAINT fk_reviews_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE reviews
    ADD CONSTRAINT fk_reviews_room
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- 四、索引创建

-- 为用户表的用户名和邮箱创建索引
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);

-- 为房间表的房间类型创建索引
CREATE INDEX idx_rooms_type ON rooms(room_type);

-- 为订单表的user_id创建索引（提高关联查询效率）
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- 为预订表创建索引
CREATE INDEX idx_reservations_user_id ON reservations(user_id);
CREATE INDEX idx_reservations_room_id ON reservations(room_id);

-- 为评价表创建索引
CREATE INDEX idx_reviews_order_id ON reviews(order_id);
CREATE INDEX idx_reviews_room_id ON reviews(room_id);

-- 五、域完整性：CHECK约束已在建表时设置

-- 六、插入初始数据

-- 插入用户表数据（密码使用MD5加密示例，实际应使用更强加密）
INSERT INTO users (user_id, username, sex, password, email, phone, address) VALUES
(1, 'Name1', FALSE, md5('password1'), 'user1@example.com', '13312678900', '123 Main St'),
(2, 'Name2', FALSE, md5('Password2'), 'User2@163.com', '13312678905', '西安市'),
(3, 'Name3', TRUE, md5('Password3'), 'User3@163.com', '13312670043', '北京市海淀区');

-- 密码加密更新（满足需求：密码要加密）
-- 注意：MD5仅用于示例演示，生产环境请使用 bcrypt 或 scram-sha-256
UPDATE users SET password = md5(password);

-- 插入房间表数据
INSERT INTO rooms (room_id, room_number, room_type, price, status, description) VALUES
(101, 'A1801', 'Single', 199.99, 'Available', 'A single room'),
(102, 'A1803', 'Double', 299.99, 'Booked', 'A double room'),
(103, 'A1804', 'Suite', 499.99, 'Available', 'A luxurious suite');

-- 插入订单表数据（先插入订单，因为预订表和reviews可能需要关联）
INSERT INTO orders (order_id, user_id, order_status, total_amount, order_time) VALUES
(1, 1, 'Completed', 499.99, CURRENT_TIMESTAMP),
(2, 2, 'Pending', 299.99, CURRENT_TIMESTAMP),
(3, 3, 'Pending', 599.97, CURRENT_TIMESTAMP);

-- 插入预订表数据
INSERT INTO reservations (reservation_id, user_id, room_id, check_in_time, check_out_time, reservation_status) VALUES
(1, 1, 101, '2025-05-01 14:00:00', '2025-05-03 12:00:00', 'Paid'),
(2, 2, 102, '2025-06-01 14:00:00', '2025-06-05 12:00:00', 'Pending'),
(3, 3, 103, '2025-07-01 14:00:00', '2025-07-03 12:00:00', 'Pending');

-- 插入用户评价表数据
INSERT INTO reviews (review_id, order_id, user_id, room_id, content, rating) VALUES
(1, 1, 1, 101, 'Great room!', 5),
(2, 2, 2, 102, 'Good service', 4),
(3, 3, 3, 103, 'Excellent experience', 5);

-- 七、创建视图：用户订单汇总
CREATE OR REPLACE VIEW user_order_summary_view AS
SELECT 
    u.user_id,
    u.username,
    COUNT(o.order_id) AS order_count,
    COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.username;

-- 八、创建函数：计算订单总金额
CREATE OR REPLACE FUNCTION calculate_total_amount(room_price DECIMAL(10, 2), nights INT)
RETURNS DECIMAL(10, 2) AS $$
DECLARE
    total DECIMAL(10, 2);
BEGIN
    total := room_price * nights;
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- 九、创建存储过程：添加新订单（使用PL/pgSQL函数模拟存储过程）
CREATE OR REPLACE FUNCTION add_order(
    p_user_id INT,
    p_room_id INT,
    p_check_in_time TIMESTAMP,
    p_check_out_time TIMESTAMP
)
RETURNS VOID AS $$
DECLARE
    nights INT;
    room_price DECIMAL(10, 2);
    total_amount DECIMAL(10, 2);
    new_order_id INT;
BEGIN
    -- 获取房间价格
    SELECT price INTO room_price FROM rooms WHERE room_id = p_room_id;
    
    -- 计算住宿天数
    nights := EXTRACT(DAY FROM (p_check_out_time - p_check_in_time));
    IF nights <= 0 THEN
        nights := 1;
    END IF;
    
    -- 计算总金额
    total_amount := calculate_total_amount(room_price, nights);
    
    -- 插入订单
    INSERT INTO orders (user_id, order_status, total_amount, order_time)
    VALUES (p_user_id, 'Pending', total_amount, CURRENT_TIMESTAMP)
    RETURNING order_id INTO new_order_id;
    
    -- 插入预订记录
    INSERT INTO reservations (user_id, room_id, check_in_time, check_out_time, reservation_status)
    VALUES (p_user_id, p_room_id, p_check_in_time, p_check_out_time, 'Pending');
END;
$$ LANGUAGE plpgsql;

-- 十、创建游标存储过程：计算每个用户的订单总数
CREATE OR REPLACE FUNCTION calculate_user_orders()
RETURNS TABLE(user_id INT, order_count BIGINT) AS $$
DECLARE
    rec RECORD;
    cur CURSOR FOR SELECT u.user_id FROM users u;
BEGIN
    -- 清空临时汇总表
    DELETE FROM user_order_summary;
    
    -- 打开游标
    OPEN cur;
    
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        
        -- 统计每个用户的订单数
        INSERT INTO user_order_summary (user_id, order_count)
        VALUES (rec.user_id, (SELECT COUNT(*) FROM orders WHERE orders.user_id = rec.user_id))
        ON CONFLICT (user_id) DO UPDATE SET order_count = EXCLUDED.order_count;
        
        user_id := rec.user_id;
        order_count := (SELECT COUNT(*) FROM orders WHERE orders.user_id = rec.user_id);
        RETURN NEXT;
    END LOOP;
    
    CLOSE cur;
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- 十一、触发器设计

-- 触发器1：自动更新房间状态为已预订
CREATE OR REPLACE FUNCTION trg_update_room_status_on_reservation()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.reservation_status IN ('Pending', 'Paid') THEN
        UPDATE rooms SET status = 'Booked' WHERE room_id = NEW.room_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_room_status_on_reservation
    AFTER INSERT ON reservations
    FOR EACH ROW
    EXECUTE FUNCTION trg_update_room_status_on_reservation();

-- 触发器2：取消预订时更新房间状态为空闲
CREATE OR REPLACE FUNCTION trg_update_room_status_on_cancel()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.reservation_status = 'Cancelled' AND OLD.reservation_status <> 'Cancelled' THEN
        UPDATE rooms SET status = 'Available' WHERE room_id = NEW.room_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_room_status_on_cancel
    AFTER UPDATE ON reservations
    FOR EACH ROW
    EXECUTE FUNCTION trg_update_room_status_on_cancel();

-- 触发器3：自动更新房间平均评分
CREATE OR REPLACE FUNCTION trg_update_room_average_rating()
RETURNS TRIGGER AS $$
DECLARE
    avg_rating DECIMAL(3, 2);
BEGIN
    SELECT COALESCE(AVG(rating), 0) INTO avg_rating
    FROM reviews
    WHERE room_id = NEW.room_id;
    
    UPDATE rooms SET average_rating = avg_rating WHERE room_id = NEW.room_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_room_average_rating
    AFTER INSERT ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION trg_update_room_average_rating();

-- 触发器4：审计日志触发器（记录orders表的插入操作）
CREATE OR REPLACE FUNCTION trg_audit_orders_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (user_id, action, table_name, timestamp)
    VALUES (NEW.user_id, 'INSERT ORDER', 'orders', CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audit_orders_insert
    AFTER INSERT ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trg_audit_orders_insert();

-- 触发器5：审计日志触发器（记录orders表的更新操作）
CREATE OR REPLACE FUNCTION trg_audit_orders_update()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (user_id, action, table_name, timestamp)
    VALUES (NEW.user_id, 'UPDATE ORDER', 'orders', CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audit_orders_update
    AFTER UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trg_audit_orders_update();

-- 触发器6：审计日志触发器（记录orders表的删除操作）
CREATE OR REPLACE FUNCTION trg_audit_orders_delete()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (user_id, action, table_name, timestamp)
    VALUES (OLD.user_id, 'DELETE ORDER', 'orders', CURRENT_TIMESTAMP);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audit_orders_delete
    AFTER DELETE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trg_audit_orders_delete();

-- 十二、用户权限管理
-- 创建角色（PostgreSQL中使用ROLE代替USER，具有兼容性）

-- 管理员角色
DROP ROLE IF EXISTS hotel_admin;
CREATE ROLE hotel_admin WITH LOGIN PASSWORD 'adminpassword';
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO hotel_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO hotel_admin;
GRANT USAGE ON SCHEMA public TO hotel_admin;

-- 普通用户角色
DROP ROLE IF EXISTS hotel_user;
CREATE ROLE hotel_user WITH LOGIN PASSWORD 'userpassword';
GRANT SELECT, INSERT, UPDATE, DELETE ON reservations TO hotel_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON orders TO hotel_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON reviews TO hotel_user;
GRANT SELECT ON users TO hotel_user;
GRANT SELECT ON rooms TO hotel_user;
GRANT USAGE ON SCHEMA public TO hotel_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO hotel_user;

-- 只读用户角色
DROP ROLE IF EXISTS hotel_readonly;
CREATE ROLE hotel_readonly WITH LOGIN PASSWORD 'readonlypassword';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO hotel_readonly;
GRANT USAGE ON SCHEMA public TO hotel_readonly;

-- 十三、事务处理示例函数
CREATE OR REPLACE FUNCTION transaction_book_room(
    p_user_id INT,
    p_room_id INT,
    p_check_in_time TIMESTAMP,
    p_check_out_time TIMESTAMP,
    p_total_amount DECIMAL(10, 2)
)
RETURNS BOOL AS $$
BEGIN
    -- 开始事务（PL/pgSQL中每个函数默认就是一个事务块）
    -- 插入订单
    INSERT INTO orders (user_id, order_status, total_amount, order_time)
    VALUES (p_user_id, 'Pending', p_total_amount, CURRENT_TIMESTAMP);
    
    -- 插入预订
    INSERT INTO reservations (user_id, room_id, check_in_time, check_out_time, reservation_status)
    VALUES (p_user_id, p_room_id, p_check_in_time, p_check_out_time, 'Pending');
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Transaction failed: %', SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- 十四、更新触发器后的房间平均评分（对已有数据生效）
-- 通过手动更新来触发触发器（如果数据是在触发器创建前插入的）
-- 这里我们重新计算所有房间的平均评分
UPDATE rooms r SET average_rating = (
    SELECT COALESCE(AVG(rating), 0) FROM reviews WHERE room_id = r.room_id
);

-- 十五、为每个房间的状态设置合适的初始值（基于预订记录）
UPDATE rooms SET status = 'Booked' WHERE room_id IN (
    SELECT DISTINCT room_id FROM reservations WHERE reservation_status IN ('Pending', 'Paid')
);
