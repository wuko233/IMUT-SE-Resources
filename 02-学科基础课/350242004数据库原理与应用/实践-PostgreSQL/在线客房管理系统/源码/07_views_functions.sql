-- ============================================================
-- 步骤7: 创建视图、函数、存储过程
-- ============================================================

-- 1. 创建视图：用户订单汇总
CREATE OR REPLACE VIEW user_order_summary_view AS
SELECT 
    u.user_id,
    u.username,
    COUNT(o.order_id) AS order_count,
    COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.username;

-- 查询视图
SELECT 'VIEW user_order_summary_view' AS type, * FROM user_order_summary_view;

-- 2. 创建函数：计算订单总金额
CREATE OR REPLACE FUNCTION calculate_total_amount(room_price DECIMAL(10, 2), nights INT)
RETURNS DECIMAL(10, 2) AS $$
DECLARE
    total DECIMAL(10, 2);
BEGIN
    total := room_price * nights;
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- 测试函数
SELECT 'FUNCTION calculate_total_amount' AS type, 
       calculate_total_amount(199.99, 3) AS total_for_3_nights;

-- 3. 创建存储过程：添加新订单 (使用PL/pgSQL函数模拟)
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
BEGIN
    SELECT price INTO room_price FROM rooms WHERE room_id = p_room_id;
    nights := EXTRACT(DAY FROM (p_check_out_time - p_check_in_time));
    IF nights <= 0 THEN
        nights := 1;
    END IF;
    total_amount := calculate_total_amount(room_price, nights);
    
    INSERT INTO orders (user_id, order_status, total_amount, order_time)
    VALUES (p_user_id, 'Pending', total_amount, CURRENT_TIMESTAMP);
    
    INSERT INTO reservations (user_id, room_id, check_in_time, check_out_time, reservation_status)
    VALUES (p_user_id, p_room_id, p_check_in_time, p_check_out_time, 'Pending');
END;
$$ LANGUAGE plpgsql;

-- 测试存储过程
SELECT add_order(1, 101, '2025-08-01 14:00:00', '2025-08-05 12:00:00');

-- 验证存储过程执行结果
SELECT 'PROCEDURE add_order result' AS type, * FROM orders WHERE user_id = 1 ORDER BY order_id DESC LIMIT 2;
SELECT 'PROCEDURE add_order reservation' AS type, * FROM reservations WHERE user_id = 1 ORDER BY reservation_id DESC LIMIT 2;
