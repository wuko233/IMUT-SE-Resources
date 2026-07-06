-- ============================================================
-- 在线图书馆管理系统 PostgreSQL 完整实现
-- ============================================================

-- 1. 创建数据库
DROP DATABASE IF EXISTS onlinelib;
CREATE DATABASE onlinelib;
\c onlinelib;

-- 2. 创建数据表
CREATE TABLE Category (
    CategoryID SERIAL PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL,
    CategoryDescription TEXT
);

CREATE TABLE "User" (
    UserID SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Gender CHAR(1) CHECK (Gender IN ('M', 'F')),
    IDNumber VARCHAR(18) NOT NULL UNIQUE,
    Contact VARCHAR(100),
    Account VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(100) NOT NULL,
    RegisterTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    BorrowLimit INT DEFAULT 5,
    OverdueTimes INT DEFAULT 0
);

CREATE TABLE Book (
    BookID SERIAL PRIMARY KEY,
    Title VARCHAR(200) NOT NULL,
    Author VARCHAR(100),
    Publisher VARCHAR(100),
    PublishDate DATE,
    ISBN VARCHAR(20) UNIQUE,
    CategoryID INT REFERENCES Category(CategoryID),
    Status VARCHAR(50) DEFAULT 'In Stock',
    CollectionQuantity INT DEFAULT 1
);

CREATE TABLE BorrowRecord (
    BorrowRecordID SERIAL PRIMARY KEY,
    UserID INT REFERENCES "User"(UserID),
    BookID INT REFERENCES Book(BookID),
    BorrowTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ReturnTime TIMESTAMP,
    RenewTimes INT DEFAULT 0,
    OverdueFee DECIMAL(10,2) DEFAULT 0.00,
    DueDate DATE
);

-- 3. 建立索引
CREATE INDEX idx_book_title ON Book (Title ASC);
CREATE UNIQUE INDEX idx_book_isbn ON Book (ISBN);

-- 4. 数据录入
INSERT INTO Category (CategoryName, CategoryDescription) VALUES
('文学', '小说、散文、诗歌等文学作品'),
('历史', '历史事件、历史人物、历史研究等'),
('科技', '计算机、电子、工程等技术类图书'),
('经济', '经济学、金融学、管理学等'),
('教育', '教育理论与方法、教材等'),
('艺术', '绘画、音乐、设计等艺术类图书'),
('哲学', '哲学思想、逻辑学、伦理学等'),
('医学', '医学理论、临床医学、护理学等'),
('法律', '法律法规、案例分析、法学理论等'),
('自然科学', '数学、物理、化学、生物等');

INSERT INTO "User" (Name, Gender, IDNumber, Contact, Account, Password, RegisterTime, BorrowLimit, OverdueTimes) VALUES
('张宝贵', 'M', '110101199001011234', '13800138001', 'zhangbaogui', 'password1', '2023-01-15 10:00:00', 5, 2),
('李秀英', 'F', '110101199002021235', '13800138002', 'lixiuying', 'password2', '2023-02-20 11:00:00', 5, 0),
('王强', 'M', '110101199003031236', '13800138003', 'wangqiang', 'password3', '2023-03-10 09:30:00', 5, 6),
('刘美丽', 'F', '110101199004041237', '13800138004', 'liumeili', 'password4', '2023-04-05 14:00:00', 5, 1),
('陈建国', 'M', '110101199005051238', '13800138005', 'chenjianguo', 'password5', '2023-05-12 16:00:00', 5, 0),
('赵小红', 'F', '110101199006061239', '13800138006', 'zhaoxiaohong', 'password6', '2023-06-18 08:00:00', 5, 3),
('孙大伟', 'M', '110101199007071240', '13800138007', 'sundawei', 'password7', '2023-07-22 13:00:00', 5, 0),
('周雅琴', 'F', '110101199008081241', '13800138008', 'zhouyaqin', 'password8', '2023-08-30 15:00:00', 5, 4),
('吴志远', 'M', '110101199009091242', '13800138009', 'wuzhiyuan', 'password9', '2023-09-10 10:30:00', 5, 0),
('郑丽华', 'F', '110101199010101243', '13800138010', 'zhenglihua', 'password10', '2023-10-01 09:00:00', 5, 1);

INSERT INTO Book (Title, Author, Publisher, PublishDate, ISBN, CategoryID, Status, CollectionQuantity) VALUES
('红楼梦', '曹雪芹', '人民文学出版社', '2020-01-01', '9787020002207', 1, 'In Stock', 3),
('数据库原理与应用', '王珊', '高等教育出版社', '2022-06-01', '9787040451234', 3, 'In Stock', 5),
('中国通史', '吕思勉', '中华书局', '2019-03-15', '9787101001234', 2, 'In Stock', 2),
('经济学原理', '曼昆', '北京大学出版社', '2021-08-20', '9787301123456', 4, 'In Stock', 4),
('教育心理学', '陈琦', '北京师范大学出版社', '2020-05-10', '9787303012345', 5, 'In Stock', 3),
('艺术的故事', '贡布里希', '广西美术出版社', '2018-04-01', '9787801234567', 6, 'In Stock', 2),
('西方哲学史', '罗素', '商务印书馆', '2021-09-01', '9787100012345', 7, 'In Stock', 3),
('内科学', '葛均波', '人民卫生出版社', '2022-01-01', '9787117123456', 8, 'In Stock', 4),
('民法典解读', '王利明', '法律出版社', '2021-01-01', '9787519751234', 9, 'In Stock', 3),
('高等数学', '同济大学', '高等教育出版社', '2023-02-01', '9787040123456', 10, 'In Stock', 5),
('Python编程：从入门到实践', 'Eric Matthes', '人民邮电出版社', '2022-07-01', '9787115546081', 3, 'In Stock', 4),
('活着', '余华', '作家出版社', '2020-06-01', '9787506365437', 1, 'In Stock', 3),
('明朝那些事儿', '当年明月', '中国友谊出版公司', '2019-12-01', '9787505722460', 2, 'In Stock', 2);

INSERT INTO BorrowRecord (UserID, BookID, BorrowTime, ReturnTime, RenewTimes, OverdueFee, DueDate) VALUES
(1, 1, '2025-01-01 10:00:00', NULL, 0, 0.00, '2025-02-01'),
(1, 2, '2025-01-05 11:00:00', '2025-02-04 09:00:00', 1, 0.00, '2025-02-05'),
(2, 3, '2025-03-01 14:00:00', NULL, 0, 0.00, '2025-04-01'),
(3, 4, '2025-02-10 09:00:00', '2025-04-20 10:00:00', 0, 20.00, '2025-03-10'),
(4, 5, '2025-03-15 16:00:00', NULL, 1, 0.00, '2025-05-15'),
(5, 6, '2025-04-01 10:00:00', NULL, 0, 0.00, '2025-05-01'),
(6, 7, '2025-02-20 11:00:00', '2025-03-25 14:00:00', 0, 0.00, '2025-03-20'),
(7, 8, '2025-03-10 09:00:00', NULL, 0, 0.00, '2025-04-10'),
(8, 9, '2025-01-20 13:00:00', '2025-05-10 10:00:00', 2, 55.00, '2025-02-20'),
(9, 10, '2025-04-05 15:00:00', NULL, 0, 0.00, '2025-05-05'),
(10, 11, '2025-03-20 10:00:00', NULL, 0, 0.00, '2025-04-20'),
(1, 12, '2025-04-10 09:00:00', NULL, 0, 0.00, '2025-05-10'),
(3, 1, '2025-03-05 14:00:00', '2025-04-06 11:00:00', 0, 0.00, '2025-04-05'),
(5, 2, '2025-02-15 10:00:00', NULL, 1, 15.00, '2025-03-15'),
(7, 3, '2025-04-12 09:00:00', NULL, 0, 0.00, '2025-05-12'),
(2, 11, '2025-04-15 11:00:00', NULL, 0, 0.00, '2025-05-15'),
(4, 12, '2025-03-25 16:00:00', '2025-04-30 10:00:00', 0, 5.00, '2025-04-25');

UPDATE Book SET Status = 'Borrowed' WHERE BookID IN (1, 3, 5, 6, 7, 8, 9, 10, 11, 12);

-- ============================================================
-- 5. 查询操作
-- ============================================================

-- 1）查询所有当前在库('In Stock')的图书信息
SELECT * FROM Book WHERE Status = 'In Stock';

-- 2）查询用户"张宝贵"的所有借阅记录，包括图书名称
SELECT br.BorrowRecordID, b.Title, br.BorrowTime, br.ReturnTime, br.RenewTimes, br.OverdueFee
FROM BorrowRecord br
JOIN "User" u ON br.UserID = u.UserID
JOIN Book b ON br.BookID = b.BookID
WHERE u.Name = '张宝贵';

-- 3）查询每个图书分类的图书数量
SELECT c.CategoryName, COUNT(b.BookID) AS BookCount
FROM Category c
LEFT JOIN Book b ON c.CategoryID = b.CategoryID
GROUP BY c.CategoryName;

-- 4）查询逾期未还的借阅记录，并计算逾期天数和逾期费用
SELECT br.BorrowRecordID, u.Name, b.Title, br.DueDate,
       CURRENT_DATE - br.DueDate AS OverdueDays,
       (CURRENT_DATE - br.DueDate) * 0.5 AS CalculatedOverdueFee
FROM BorrowRecord br
JOIN "User" u ON br.UserID = u.UserID
JOIN Book b ON br.BookID = b.BookID
WHERE br.ReturnTime IS NULL AND br.DueDate < CURRENT_DATE;

-- 5）查询借阅次数最多的前5名用户
SELECT u.Name, COUNT(br.BorrowRecordID) AS BorrowCount
FROM "User" u
JOIN BorrowRecord br ON u.UserID = br.UserID
GROUP BY u.UserID, u.Name
ORDER BY BorrowCount DESC
LIMIT 5;

-- 6）查询所有未借出的图书，按图书分类排序
SELECT b.*, c.CategoryName
FROM Book b
JOIN Category c ON b.CategoryID = c.CategoryID
WHERE b.Status = 'In Stock'
ORDER BY c.CategoryName;

-- 7）查询每个用户的借阅上限和当前借阅数量
SELECT u.Name, u.BorrowLimit,
       COUNT(br.BorrowRecordID) FILTER (WHERE br.ReturnTime IS NULL) AS CurrentBorrowCount
FROM "User" u
LEFT JOIN BorrowRecord br ON u.UserID = br.UserID
GROUP BY u.UserID, u.Name, u.BorrowLimit;

-- 8）查询所有借阅过“数据库原理与应用”这本图书的用户姓名
SELECT DISTINCT u.Name
FROM "User" u
JOIN BorrowRecord br ON u.UserID = br.UserID
JOIN Book b ON br.BookID = b.BookID
WHERE b.Title = '数据库原理与应用';

-- 9）更新所有逾期未还的借阅记录的逾期费用
UPDATE BorrowRecord
SET OverdueFee = (CURRENT_DATE - DueDate) * 0.5
WHERE ReturnTime IS NULL AND DueDate < CURRENT_DATE;

-- 10）删除所有已经归还且无逾期费用的借阅记录
DELETE FROM BorrowRecord WHERE ReturnTime IS NOT NULL AND OverdueFee = 0.00;

-- ============================================================
-- 6. 创建视图
-- ============================================================
CREATE OR REPLACE VIEW vw_UserBorrowInfo AS
SELECT u.UserID, u.Name, b.Title, br.BorrowTime, br.ReturnTime, br.RenewTimes, br.OverdueFee
FROM "User" u
JOIN BorrowRecord br ON u.UserID = br.UserID
JOIN Book b ON br.BookID = b.BookID;

CREATE OR REPLACE VIEW vw_CategoryBookCount AS
SELECT c.CategoryName, COUNT(b.BookID) AS BookCount
FROM Category c
LEFT JOIN Book b ON c.CategoryID = b.CategoryID
GROUP BY c.CategoryName;

CREATE OR REPLACE VIEW vw_OverdueBorrow AS
SELECT br.BorrowRecordID, u.Name, b.Title, br.DueDate,
       CURRENT_DATE - br.DueDate AS OverdueDays, br.OverdueFee
FROM BorrowRecord br
JOIN "User" u ON br.UserID = u.UserID
JOIN Book b ON br.BookID = b.BookID
WHERE br.ReturnTime IS NULL AND br.DueDate < CURRENT_DATE;

CREATE OR REPLACE VIEW vw_UserBorrowLimit AS
SELECT u.UserID, u.Name, u.BorrowLimit,
       COUNT(br.BorrowRecordID) FILTER (WHERE br.ReturnTime IS NULL) AS CurrentBorrowCount
FROM "User" u
LEFT JOIN BorrowRecord br ON u.UserID = br.UserID
GROUP BY u.UserID, u.Name, u.BorrowLimit;

CREATE OR REPLACE VIEW vw_BookBorrowCount AS
SELECT b.BookID, b.Title, COUNT(br.BorrowRecordID) AS BorrowCount
FROM Book b
LEFT JOIN BorrowRecord br ON b.BookID = br.BookID
GROUP BY b.BookID, b.Title;

CREATE OR REPLACE VIEW vw_NewBooks AS
SELECT * FROM Book WHERE PublishDate >= CURRENT_DATE - INTERVAL '1 year';

CREATE OR REPLACE VIEW vw_UserTotalOverdueFee AS
SELECT u.UserID, u.Name, SUM(br.OverdueFee) AS TotalOverdueFee
FROM "User" u
JOIN BorrowRecord br ON u.UserID = br.UserID
GROUP BY u.UserID, u.Name;

CREATE OR REPLACE VIEW vw_AvailableBooks AS
SELECT * FROM Book WHERE Status = 'In Stock' AND CollectionQuantity > 0;

CREATE OR REPLACE VIEW vw_CategoryBorrowCount AS
SELECT c.CategoryName, COUNT(br.BorrowRecordID) AS BorrowCount
FROM Category c
LEFT JOIN Book b ON c.CategoryID = b.CategoryID
LEFT JOIN BorrowRecord br ON b.BookID = br.BookID
GROUP BY c.CategoryName;

CREATE OR REPLACE VIEW vw_UserBorrowHistory AS
SELECT u.UserID, u.Name, b.Title, br.BorrowTime, br.ReturnTime,
       CASE WHEN br.ReturnTime IS NULL AND br.DueDate < CURRENT_DATE THEN '已逾期'
            WHEN br.ReturnTime IS NULL THEN '借阅中'
            ELSE '已归还' END AS Status,
       br.OverdueFee
FROM "User" u
JOIN BorrowRecord br ON u.UserID = br.UserID
JOIN Book b ON br.BookID = b.BookID;

-- ============================================================
-- 7. 设计函数
-- ============================================================
CREATE OR REPLACE FUNCTION CalculateBorrowLimit(p_UserID INT)
RETURNS INT AS $$
DECLARE
    v_BorrowLimit INT;
    v_OverdueTimes INT;
BEGIN
    SELECT BorrowLimit, OverdueTimes INTO v_BorrowLimit, v_OverdueTimes
    FROM "User" WHERE UserID = p_UserID;
    IF v_OverdueTimes > 5 THEN
        v_BorrowLimit := v_BorrowLimit - 1;
    END IF;
    RETURN v_BorrowLimit;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CalculateAvailableBooks(p_BookID INT)
RETURNS INT AS $$
DECLARE
    v_CollectionQuantity INT;
    v_BorrowedCount INT;
BEGIN
    SELECT CollectionQuantity INTO v_CollectionQuantity
    FROM Book WHERE BookID = p_BookID;
    SELECT COUNT(*) INTO v_BorrowedCount
    FROM BorrowRecord WHERE BookID = p_BookID AND ReturnTime IS NULL;
    RETURN COALESCE(v_CollectionQuantity, 0) - COALESCE(v_BorrowedCount, 0);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CalculateUserOverdueFee(p_UserID INT)
RETURNS DECIMAL(10,2) AS $$
DECLARE
    v_TotalFee DECIMAL(10,2);
BEGIN
    SELECT COALESCE(SUM(OverdueFee), 0.00) INTO v_TotalFee
    FROM BorrowRecord WHERE UserID = p_UserID;
    RETURN v_TotalFee;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 8. 设计存储过程
-- ============================================================
CREATE OR REPLACE PROCEDURE RegisterUser(
    p_Name VARCHAR, p_Gender CHAR(1), p_IDNumber VARCHAR,
    p_Contact VARCHAR, p_Account VARCHAR, p_Password VARCHAR
)
LANGUAGE plpgsql AS $$
DECLARE
    v_Count INT;
BEGIN
    SELECT COUNT(*) INTO v_Count FROM "User" WHERE Account = p_Account;
    IF v_Count > 0 THEN
        RAISE EXCEPTION '账号已存在: %', p_Account;
    END IF;
    INSERT INTO "User" (Name, Gender, IDNumber, Contact, Account, Password, BorrowLimit, OverdueTimes)
    VALUES (p_Name, p_Gender, p_IDNumber, p_Contact, p_Account, p_Password, 5, 0);
END;
$$;

CREATE OR REPLACE PROCEDURE BorrowBook(p_UserID INT, p_BookID INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_Limit INT; v_CurrentBorrow INT;
    v_BookStatus VARCHAR; v_Available INT;
BEGIN
    v_Limit := CalculateBorrowLimit(p_UserID);
    SELECT COUNT(*) INTO v_CurrentBorrow FROM BorrowRecord
    WHERE UserID = p_UserID AND ReturnTime IS NULL;
    IF v_CurrentBorrow >= v_Limit THEN
        RAISE EXCEPTION '用户借阅数量已达上限';
    END IF;
    SELECT Status, CollectionQuantity INTO v_BookStatus, v_Available
    FROM Book WHERE BookID = p_BookID;
    v_Available := CalculateAvailableBooks(p_BookID);
    IF v_BookStatus != 'In Stock' OR v_Available <= 0 THEN
        RAISE EXCEPTION '图书不可借';
    END IF;
    INSERT INTO BorrowRecord (UserID, BookID, DueDate)
    VALUES (p_UserID, p_BookID, CURRENT_DATE + INTERVAL '30 days');
    UPDATE Book SET Status = 'Borrowed' WHERE BookID = p_BookID;
END;
$$;

CREATE OR REPLACE PROCEDURE ReturnBook(p_BorrowRecordID INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_UserID INT; v_BookID INT; v_BorrowTime TIMESTAMP;
    v_OverdueDays INT; v_Fee DECIMAL(10,2);
BEGIN
    SELECT UserID, BookID, BorrowTime INTO v_UserID, v_BookID, v_BorrowTime
    FROM BorrowRecord WHERE BorrowRecordID = p_BorrowRecordID;
    IF NOT FOUND THEN RAISE EXCEPTION '借阅记录不存在'; END IF;
    UPDATE BorrowRecord SET ReturnTime = CURRENT_TIMESTAMP
    WHERE BorrowRecordID = p_BorrowRecordID;
    UPDATE Book SET Status = 'In Stock' WHERE BookID = v_BookID;
    v_OverdueDays := CURRENT_DATE - (v_BorrowTime + INTERVAL '30 days');
    IF v_OverdueDays > 0 THEN
        v_Fee := v_OverdueDays * 0.5;
        UPDATE BorrowRecord SET OverdueFee = v_Fee
        WHERE BorrowRecordID = p_BorrowRecordID;
    END IF;
END;
$$;

-- ============================================================
-- 9. 游标
-- ============================================================
DO $$
DECLARE
    cur CURSOR FOR SELECT UserID FROM "User";
    v_UserID INT; v_BorrowCount INT;
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO v_UserID;
        EXIT WHEN NOT FOUND;
        SELECT COUNT(*) INTO v_BorrowCount FROM BorrowRecord WHERE UserID = v_UserID;
        RAISE NOTICE '用户ID: %, 借阅次数: %', v_UserID, v_BorrowCount;
    END LOOP;
    CLOSE cur;
END;
$$;

-- ============================================================
-- 10. 触发器
-- ============================================================
CREATE OR REPLACE FUNCTION trg_calculate_overdue_fee()
RETURNS TRIGGER AS $$
DECLARE
    v_DueDate DATE; v_OverdueDays INT;
BEGIN
    IF OLD.ReturnTime IS NULL AND NEW.ReturnTime IS NOT NULL THEN
        v_DueDate := COALESCE(NEW.DueDate, (NEW.BorrowTime::DATE + 30));
        v_OverdueDays := CURRENT_DATE - v_DueDate;
        IF v_OverdueDays > 0 THEN
            NEW.OverdueFee := v_OverdueDays * 0.5;
        ELSE
            NEW.OverdueFee := 0.00;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS CalculateOverdueFee ON BorrowRecord;
CREATE TRIGGER CalculateOverdueFee
BEFORE UPDATE ON BorrowRecord
FOR EACH ROW
EXECUTE FUNCTION trg_calculate_overdue_fee();

-- ============================================================
-- 11. 角色与权限
-- ============================================================
DROP ROLE IF EXISTS Librarian;
DROP ROLE IF EXISTS Reader;
CREATE ROLE Librarian;
GRANT SELECT ON "User" TO Librarian;
GRANT SELECT ON Book TO Librarian;
GRANT SELECT, INSERT, UPDATE ON BorrowRecord TO Librarian;
GRANT USAGE, SELECT ON SEQUENCE borrowrecord_borrowrecordid_seq TO Librarian;

CREATE ROLE Reader;
GRANT SELECT ON Book TO Reader;
GRANT SELECT ON Category TO Reader;
GRANT SELECT ON BorrowRecord TO Reader;

-- ============================================================
-- 12. 事务借书存储过程
-- ============================================================
CREATE OR REPLACE PROCEDURE BorrowBookTransaction(p_UserID INT, p_BookID INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_Limit INT; v_CurrentBorrow INT;
    v_BookStatus VARCHAR; v_Available INT;
BEGIN
    v_Limit := CalculateBorrowLimit(p_UserID);
    SELECT COUNT(*) INTO v_CurrentBorrow FROM BorrowRecord
    WHERE UserID = p_UserID AND ReturnTime IS NULL;
    IF v_CurrentBorrow >= v_Limit THEN
        RAISE EXCEPTION '用户借阅数量已达上限';
    END IF;
    SELECT Status, CollectionQuantity INTO v_BookStatus, v_Available
    FROM Book WHERE BookID = p_BookID;
    v_Available := CalculateAvailableBooks(p_BookID);
    IF v_BookStatus != 'In Stock' OR v_Available <= 0 THEN
        RAISE EXCEPTION '图书不可借';
    END IF;
    INSERT INTO BorrowRecord (UserID, BookID, DueDate)
    VALUES (p_UserID, p_BookID, CURRENT_DATE + INTERVAL '30 days');
    UPDATE Book SET CollectionQuantity = CollectionQuantity - 1 WHERE BookID = p_BookID;
    IF (SELECT CollectionQuantity FROM Book WHERE BookID = p_BookID) = 0 THEN
        UPDATE Book SET Status = 'Borrowed' WHERE BookID = p_BookID;
    END IF;
END;
$$;

-- ============================================================
-- 13. 备份与恢复
-- ============================================================
-- 备份（在命令行执行）
-- pg_dump -U postgres -d onlinelib -t borrowrecord > /tmp/borrowrecord_backup.sql
-- 恢复（在命令行执行）
-- psql -U postgres -d onlinelib -f /tmp/borrowrecord_backup.sql
