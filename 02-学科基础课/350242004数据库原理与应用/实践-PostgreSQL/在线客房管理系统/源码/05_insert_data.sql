-- ============================================================
-- 步骤5: 插入初始数据
-- ============================================================

-- 插入用户表数据（密码使用MD5加密示例）
INSERT INTO users (user_id, username, sex, password, email, phone, address) VALUES
(1, 'Name1', FALSE, md5('password1'), 'user1@example.com', '13312678900', '123 Main St'),
(2, 'Name2', FALSE, md5('Password2'), 'User2@163.com', '13312678905', '西安市'),
(3, 'Name3', TRUE, md5('Password3'), 'User3@163.com', '13312670043', '北京市海淀区');

-- 插入房间表数据
INSERT INTO rooms (room_id, room_number, room_type, price, status, description) VALUES
(101, 'A1801', 'Single', 199.99, 'Available', 'A single room'),
(102, 'A1803', 'Double', 299.99, 'Booked', 'A double room'),
(103, 'A1804', 'Suite', 499.99, 'Available', 'A luxurious suite');

-- 插入订单表数据
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

-- 同步SERIAL序列，避免显式插入主键后自动编号重复
SELECT setval('users_user_id_seq', (SELECT MAX(user_id) FROM users));
SELECT setval('rooms_room_id_seq', (SELECT MAX(room_id) FROM rooms));
SELECT setval('orders_order_id_seq', (SELECT MAX(order_id) FROM orders));
SELECT setval('reservations_reservation_id_seq', (SELECT MAX(reservation_id) FROM reservations));
SELECT setval('reviews_review_id_seq', (SELECT MAX(review_id) FROM reviews));

-- 验证插入结果
SELECT 'users' AS table_name, COUNT(*) AS record_count FROM users
UNION ALL
SELECT 'rooms', COUNT(*) FROM rooms
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'reservations', COUNT(*) FROM reservations
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews;
