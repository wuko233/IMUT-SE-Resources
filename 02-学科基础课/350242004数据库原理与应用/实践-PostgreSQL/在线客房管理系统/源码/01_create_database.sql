-- 步骤1：创建数据库
DROP DATABASE IF EXISTS OnlineHotelSystem;
CREATE DATABASE OnlineHotelSystem
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;
