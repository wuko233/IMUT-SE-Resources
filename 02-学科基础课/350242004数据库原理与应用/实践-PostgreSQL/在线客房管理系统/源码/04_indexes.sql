-- ============================================================
-- 步骤4: 创建索引提高查询性能
-- ============================================================

-- 为用户表的用户名和邮箱创建索引
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);

-- 为房间表的房间类型创建索引
CREATE INDEX idx_rooms_type ON rooms(room_type);

-- 为订单表创建索引
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- 为预订表创建索引
CREATE INDEX idx_reservations_user_id ON reservations(user_id);
CREATE INDEX idx_reservations_room_id ON reservations(room_id);

-- 为评价表创建索引
CREATE INDEX idx_reviews_order_id ON reviews(order_id);
CREATE INDEX idx_reviews_room_id ON reviews(room_id);

-- 查看已创建的索引
SELECT indexname, indexdef FROM pg_indexes WHERE schemaname = 'public';
