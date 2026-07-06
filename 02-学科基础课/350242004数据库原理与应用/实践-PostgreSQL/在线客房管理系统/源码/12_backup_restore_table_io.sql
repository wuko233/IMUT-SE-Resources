-- ============================================================
-- 步骤12: 数据表导出到TXT并重新导入
-- ============================================================

DROP TABLE IF EXISTS rooms_import_test;
CREATE TABLE rooms_import_test (
    room_id INT,
    room_number VARCHAR(20),
    room_type VARCHAR(50),
    price DECIMAL(10, 2),
    status VARCHAR(20),
    description TEXT,
    average_rating DECIMAL(3, 2)
);

\copy rooms(room_id, room_number, room_type, price, status, description, average_rating) TO '/run/media/wuko233/Data/大学/数据库/yitaai/rooms_export.txt' WITH (FORMAT csv, HEADER true, DELIMITER E'\t');

\copy rooms_import_test(room_id, room_number, room_type, price, status, description, average_rating) FROM '/run/media/wuko233/Data/大学/数据库/yitaai/rooms_export.txt' WITH (FORMAT csv, HEADER true, DELIMITER E'\t');

SELECT 'TXT EXPORT/IMPORT RESULT' AS type, COUNT(*) AS imported_count FROM rooms_import_test;
SELECT * FROM rooms_import_test ORDER BY room_id;
