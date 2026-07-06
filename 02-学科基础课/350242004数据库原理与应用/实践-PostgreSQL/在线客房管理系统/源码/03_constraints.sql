-- ============================================================
-- 步骤3: 创建参照完整性(外键约束)和域完整性(CHECK)
-- ============================================================

-- 预订表外键约束
ALTER TABLE reservations
    ADD CONSTRAINT fk_reservations_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE reservations
    ADD CONSTRAINT fk_reservations_room
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- 订单表外键约束
ALTER TABLE orders
    ADD CONSTRAINT fk_orders_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- 评价表外键约束
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

-- 域完整性：reviews表的rating已添加CHECK约束
-- 以下用于验证约束是否存在
SELECT conname, contype FROM pg_constraint WHERE conrelid = 'reviews'::regclass;
