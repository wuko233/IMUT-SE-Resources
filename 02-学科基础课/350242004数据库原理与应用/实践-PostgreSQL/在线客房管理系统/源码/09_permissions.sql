-- ============================================================
-- 步骤9: 系统安全管理 - 用户权限管理
-- ============================================================

DROP ROLE IF EXISTS hotel_admin;
CREATE ROLE hotel_admin WITH LOGIN PASSWORD 'adminpassword';
GRANT USAGE ON SCHEMA public TO hotel_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO hotel_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO hotel_admin;

DROP ROLE IF EXISTS hotel_user;
CREATE ROLE hotel_user WITH LOGIN PASSWORD 'userpassword';
GRANT USAGE ON SCHEMA public TO hotel_user;
GRANT SELECT ON users TO hotel_user;
GRANT SELECT ON rooms TO hotel_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON reservations TO hotel_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON orders TO hotel_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON reviews TO hotel_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO hotel_user;

DROP ROLE IF EXISTS hotel_readonly;
CREATE ROLE hotel_readonly WITH LOGIN PASSWORD 'readonlypassword';
GRANT USAGE ON SCHEMA public TO hotel_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO hotel_readonly;

SELECT rolname, rolcanlogin FROM pg_roles
WHERE rolname IN ('hotel_admin', 'hotel_user', 'hotel_readonly')
ORDER BY rolname;

SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee IN ('hotel_admin', 'hotel_user', 'hotel_readonly')
ORDER BY grantee, table_name, privilege_type;
