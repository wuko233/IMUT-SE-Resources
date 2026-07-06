-- ============================================================
-- 步骤10: 事务处理 - 保证订单和预订一致性
-- ============================================================

BEGIN;

INSERT INTO orders (user_id, order_status, total_amount, order_time)
VALUES (1, 'Pending', 599.97, CURRENT_TIMESTAMP)
RETURNING order_id, user_id, order_status, total_amount;

INSERT INTO reservations (user_id, room_id, check_in_time, check_out_time, reservation_status)
VALUES (1, 103, '2025-10-01 14:00:00', '2025-10-04 12:00:00', 'Pending')
RETURNING reservation_id, user_id, room_id, check_in_time, check_out_time, reservation_status;

COMMIT;

SELECT 'TRANSACTION ORDERS' AS type, order_id, user_id, order_status, total_amount
FROM orders WHERE user_id = 1 ORDER BY order_id DESC LIMIT 3;

SELECT 'TRANSACTION RESERVATIONS' AS type, reservation_id, user_id, room_id, reservation_status
FROM reservations WHERE user_id = 1 ORDER BY reservation_id DESC LIMIT 3;
