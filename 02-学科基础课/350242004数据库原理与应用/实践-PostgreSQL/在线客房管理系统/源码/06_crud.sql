-- ============================================================
-- 步骤6: 增删改查操作演示
-- ============================================================

-- 1. 更新操作：将房间表中room_id为101的房间状态更新为'Booked'
UPDATE rooms SET status = 'Booked' WHERE room_id = 101;
SELECT 'UPDATE' AS operation, room_id, room_number, status FROM rooms WHERE room_id = 101;

-- 2. 删除操作：删除预订表中room_id为101且user_id为1的记录
-- 先备份查看
SELECT 'BEFORE DELETE' AS operation, * FROM reservations WHERE room_id = 101 AND user_id = 1;
-- 执行删除
DELETE FROM reservations WHERE room_id = 101 AND user_id = 1;
-- 查看删除后结果
SELECT 'AFTER DELETE' AS operation, * FROM reservations WHERE room_id = 101 AND user_id = 1;

-- 3. 查询操作：查询所有价格大于200的房间信息
SELECT 'QUERY price > 200' AS operation, room_id, room_number, room_type, price, status
FROM rooms WHERE price > 200;

-- 4. 查询操作：查询用户1预定的所有房间订单信息
SELECT 'QUERY user 1 reservations' AS operation, 
       r.reservation_id, r.room_id, rm.room_number, rm.room_type, 
       r.check_in_time, r.check_out_time, r.reservation_status
FROM reservations r
JOIN rooms rm ON r.room_id = rm.room_id
WHERE r.user_id = 1;
