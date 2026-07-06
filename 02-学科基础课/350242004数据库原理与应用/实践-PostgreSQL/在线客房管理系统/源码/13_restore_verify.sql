-- ============================================================
-- 步骤13: 备份恢复验证
-- ============================================================

SELECT 'RESTORE VERIFY' AS type, table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

SELECT 'RESTORED COUNTS' AS type, 'users' AS table_name, COUNT(*) AS record_count FROM users
UNION ALL
SELECT 'RESTORED COUNTS', 'rooms', COUNT(*) FROM rooms
UNION ALL
SELECT 'RESTORED COUNTS', 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'RESTORED COUNTS', 'reservations', COUNT(*) FROM reservations
UNION ALL
SELECT 'RESTORED COUNTS', 'reviews', COUNT(*) FROM reviews;
