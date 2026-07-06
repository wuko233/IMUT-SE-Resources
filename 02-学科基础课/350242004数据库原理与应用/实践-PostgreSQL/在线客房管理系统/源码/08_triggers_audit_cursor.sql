-- ============================================================
-- 步骤8: 创建触发器、审计日志触发器、游标函数并测试
-- ============================================================

-- 1. 游标函数：遍历所有用户并计算订单总数
CREATE OR REPLACE FUNCTION calculate_user_orders()
RETURNS TABLE(result_user_id INT, result_order_count BIGINT) AS $$
DECLARE
    rec RECORD;
    cur CURSOR FOR SELECT u.user_id FROM users u ORDER BY u.user_id;
BEGIN
    DELETE FROM user_order_summary;
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;

        INSERT INTO user_order_summary (user_id, order_count, total_spent)
        SELECT rec.user_id, COUNT(*), COALESCE(SUM(total_amount), 0)
        FROM orders
        WHERE orders.user_id = rec.user_id;

        result_user_id := rec.user_id;
        result_order_count := (SELECT COUNT(*) FROM orders WHERE orders.user_id = rec.user_id);
        RETURN NEXT;
    END LOOP;
    CLOSE cur;
    RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT 'CURSOR calculate_user_orders' AS type, * FROM calculate_user_orders();
SELECT 'CURSOR summary table' AS type, * FROM user_order_summary ORDER BY user_id;

-- 2. 触发器：预订时自动更新房间状态为Booked
CREATE OR REPLACE FUNCTION trg_update_room_status_on_reservation()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.reservation_status IN ('Pending', 'Paid') THEN
        UPDATE rooms SET status = 'Booked' WHERE room_id = NEW.room_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_room_status_on_reservation ON reservations;
CREATE TRIGGER update_room_status_on_reservation
    AFTER INSERT ON reservations
    FOR EACH ROW
    EXECUTE FUNCTION trg_update_room_status_on_reservation();

-- 3. 触发器：取消预订时自动更新房间状态为Available
CREATE OR REPLACE FUNCTION trg_update_room_status_on_cancel()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.reservation_status = 'Cancelled' AND OLD.reservation_status <> 'Cancelled' THEN
        UPDATE rooms SET status = 'Available' WHERE room_id = NEW.room_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_room_status_on_cancel ON reservations;
CREATE TRIGGER update_room_status_on_cancel
    AFTER UPDATE ON reservations
    FOR EACH ROW
    EXECUTE FUNCTION trg_update_room_status_on_cancel();

-- 4. 触发器：提交评价后自动更新房间平均评分
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

DROP TRIGGER IF EXISTS update_room_average_rating ON reviews;
CREATE TRIGGER update_room_average_rating
    AFTER INSERT ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION trg_update_room_average_rating();

-- 5. 审计日志触发器：记录orders表插入、更新、删除
CREATE OR REPLACE FUNCTION trg_audit_orders_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (user_id, action, table_name, timestamp)
    VALUES (NEW.user_id, 'INSERT ORDER', 'orders', CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS audit_orders_insert ON orders;
CREATE TRIGGER audit_orders_insert
    AFTER INSERT ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trg_audit_orders_insert();

CREATE OR REPLACE FUNCTION trg_audit_orders_update()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (user_id, action, table_name, timestamp)
    VALUES (NEW.user_id, 'UPDATE ORDER', 'orders', CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS audit_orders_update ON orders;
CREATE TRIGGER audit_orders_update
    AFTER UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trg_audit_orders_update();

CREATE OR REPLACE FUNCTION trg_audit_orders_delete()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (user_id, action, table_name, timestamp)
    VALUES (OLD.user_id, 'DELETE ORDER', 'orders', CURRENT_TIMESTAMP);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS audit_orders_delete ON orders;
CREATE TRIGGER audit_orders_delete
    AFTER DELETE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trg_audit_orders_delete();

-- 6. 测试触发器
INSERT INTO orders (user_id, order_status, total_amount, order_time)
VALUES (2, 'Pending', 399.99, CURRENT_TIMESTAMP)
RETURNING order_id, user_id, order_status, total_amount;

INSERT INTO reservations (user_id, room_id, check_in_time, check_out_time, reservation_status)
VALUES (2, 103, '2025-09-01 14:00:00', '2025-09-03 12:00:00', 'Pending')
RETURNING reservation_id, user_id, room_id, reservation_status;

SELECT 'ROOM STATUS AFTER INSERT RESERVATION' AS type, room_id, room_number, status
FROM rooms WHERE room_id = 103;

UPDATE reservations
SET reservation_status = 'Cancelled'
WHERE room_id = 103 AND user_id = 2 AND reservation_status = 'Pending';

SELECT 'ROOM STATUS AFTER CANCEL' AS type, room_id, room_number, status
FROM rooms WHERE room_id = 103;

INSERT INTO reviews (order_id, user_id, room_id, content, rating)
VALUES ((SELECT MAX(order_id) FROM orders WHERE user_id = 2), 2, 103, 'Nice suite', 4.5)
RETURNING review_id, order_id, room_id, rating;

SELECT 'ROOM AVERAGE RATING' AS type, room_id, room_number, average_rating
FROM rooms WHERE room_id = 103;

UPDATE orders SET order_status = 'Completed' WHERE order_id = (SELECT MAX(order_id) FROM orders);

SELECT 'AUDIT LOG' AS type, log_id, user_id, action, table_name, timestamp
FROM audit_log ORDER BY log_id;
