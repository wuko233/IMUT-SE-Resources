**在线客房管理系统数据库设计**

一、系统需求分析

（一）功能需求

用户注册与登录功能。

房间信息展示与搜索功能。

预订管理功能（包括预订、取消预订）。

订单管理功能。

用户评价功能。

管理员后台管理功能，包括房间管理、订单审核、用户管理等。

（二）数据需求

用户信息：用户名、密码、邮箱、手机号、地址等。

房间信息：房间号、房间类型、价格、状态（空闲、已预订、已入住）、描述等。

预订信息：预订ID、用户ID、房间ID、入住时间、离店时间、预订状态（已支付、待支付、已取消）等。

订单信息：订单号、用户ID、订单状态、总价、下单时间等。

用户评价信息：评价ID、订单ID、用户ID、评价内容、评分等。

（三）性能需求

系统应支持高并发访问，确保数据的快速查询和更新。

数据库应具备良好的扩展性和安全性。

二、数据库的概念结构设计

（一）实体及其属性

用户（Users）

用户ID（user_id）

用户名（username）

性别（sex）

密码（password）

邮箱（email）

手机号（phone）

地址（address）

房间（Rooms）

房间ID（room_id）

房间号（room_number）

房间类型（room_type）

价格（price）

状态（status）

描述（description）

预订（Reservations）

预订ID（reservation_id）

用户ID（user_id）

房间ID（room_id）

入住时间（check_in_time）

离店时间（check_out_time）

预订状态（reservation_status）

订单（Orders）

订单ID（order_id）

用户ID（user_id）

订单状态（order_status）

总金额（total_amount）

下单时间（order_time）

用户评价（Reviews）

评价ID（review_id）

订单ID（order_id）

用户ID（user_id）

评价内容（content）

评分（rating）

（二）属性间依赖关系

用户（Users）

user_id → username, password, email, phone, address

房间（Rooms）

room_id → room_number, room_type, price, status, description

预订（Reservations）

reservation_id → user_id, room_id, check_in_time, check_out_time,
reservation_status

订单（Orders）

order_id → user_id, order_status, total_amount, order_time

用户评价（Reviews）

review_id → order_id, user_id, content, rating

（三）E-R图

根据上述实体及其关系，可以画出E-R图。以下是简要描述：

用户（Users） 和 房间（Rooms） 是独立实体。

预订（Reservations） 关联 Users 和 Rooms。

订单（Orders） 关联 Users。

评价（Reviews） 关联 Orders 和 Users。

三、数据库逻辑设计

（一）转换为关系模式

Users([user_id]{.underline}, username, password, email, phone, address)

Rooms([room_id]{.underline}, room_number, room_type, price, status,
description)

Reservations([reservation_id,]{.underline} user_id, room_id,
check_in_time, check_out_time, reservation_status)

Orders([order_id]{.underline}, user_id, order_status, total_amount,
order_time)

Reviews(review_id, order_id, user_id, content, rating)

（二）规范化到3NF

每个关系模式已经符合3NF，因为它们的属性都只依赖于主键。

四、数据库设计与实现

（一）创建数据库

1\. 创建数据库，请给出创建数据库和使用数据库的SQL命令。

2.并按照以下要求创建数据库表，请给出创建数据库表的SQL命令。

以下是主要的数据库表及其字段设计：

（1）用户表（users）

  ----------------------- ----------------------- -----------------------
  描述                    字段名                  数据类型

  用户ID（主键）          user_id                 INT

  用户名（唯一）          User_name               VARCHAR(50)

  性别                    Sex                     Bit

  密码（加密存储）        password                VARCHAR(100)

  邮箱（唯一）            email                   VARCHAR(100)

  手机号                  phone                   CHAR(11)

  地址                    address                 TEXT
  ----------------------- ----------------------- -----------------------

（2）房间表（products）

  ----------------------- ----------------------- -----------------------
  字段名                  数据类型                描述

  Room_id                 INT                     房间ID（主键）

  Room_number             VARCHAR(20)             房间号

  room_type               Varchar（50）           房间类型

  price                   DECIMAL(10, 2),         房间价格

  Status                  VARCHAR(20)             房间状态

  description             TEXT                    房屋描述
  ----------------------- ----------------------- -----------------------

3.  预定表（reservations）

  ----------------------- ----------------------- -----------------------
  字段名                  数据类型                描述

  user_id                 INT                     用户ID

  Room_id                 INT                     房间id

  check_in_time           DATETIME                入住日期时间

  check_out_time          DATETIME                退房时间

  reservation_status      VARCHAR(20              订单状态
  ----------------------- ----------------------- -----------------------

4.  订单表（orders）

  ----------------------- --------------- ------------------------------------
  字段名                  数据类型        描述

  order_id                INT             订单ID（主键）

  user_id                 INT             用户ID（外键）

  order_status            VARCHAR(20)     订单状态（如"已支付"、"待发货"等）

  total_amount            DECIMAL(10,2)   订单总金额

  order_time              DATETIME        下单时间 （默认为当前时间NOW()）
  ----------------------- --------------- ------------------------------------

5.  用户评价表（reviews）

  ----------------------- --------------- --------------------------------
  字段名                  数据类型        描述

  review_id               INT             评价ID（主键）

  Order_id                INT             订单ID（外键）

  Content                 VARCHAR(20)     评价内容

  Rating                  DECIMAL(10,2)   评价分数1-5分
  ----------------------- --------------- --------------------------------

3\. 实体完整性

\- 每个表的主键字段（如user_id、product_id等）确保了实体的唯一性。

\- 使用\`AUTO_INCREMENT\`为每个表的主键字段自动生成唯一值。

4\. 索引

为用户表的用户名和邮箱字段创建索引，提高查询效率

为房间表的分类字段创建索引

5\. 域完整性

在\`reviews\`表中，\`rating\`字段使用\`CHECK\`约束限制其值在1到5之间。

6\. 参照完整性

在\`cart\`表、\`orders\`表和\`reviews\`表中，通过外键约束确保数据的参照完整性。

7\. 操作表数据

（1）插入数据（使用insert into命令user表等各表插入至少3条记录）

注意：密码要加密

User表数据：

  --------- ----------- ----- ----------- ------------------- ------------- --------------
  User_id   User_name   sex   password    email               phone         address

  1         Name1       0     password1   user1@example.com   13312678900   123 Main St

  2         Name2       0     Password2   User2@163.com       13312678905   西安市

  3         Name3       1     Password3   User3@163.com       13312670043   北京市海淀区
  --------- ----------- ----- ----------- ------------------- ------------- --------------

room表数据：

  --------- ------------- ------------- --------- ----------- ---------------
  Room_id   room_number   room_type     price     status      description

  101       A1801         Single        199.99    Available   A single room

  102       A1803         Double        299.99    Booked      A double room

  103       A1804         Suite         499.99    Available   A luxurious
                                                              suite
  --------- ------------- ------------- --------- ----------- ---------------

reservations表数据：

  -------------- -------------- --------------- ---------------- --------------------
  user_id        Room_id        check_in_time   check_out_time   reservation_status

  1              101            2025-05-01      2025-05-03       Paid

  2              102            2025-06-01      2025-06-05       Pending
  -------------- -------------- --------------- ---------------- --------------------

orders表数据

  ---------------- ---------------- ----------------- ------------- ------------
  order_id         User_id          Order_status      totalamount   Order_time

  1                1                Completed         499.99        Now()

  2                2                Pending           299.99        Now()
  ---------------- ---------------- ----------------- ------------- ------------

reviews表数据

  ----------------------- ----------- ------------ -----------------------
  review_id               Order_id    content      rating

  1                       1           Great room!  5

  2                       2           Good service 4
  ----------------------- ----------- ------------ -----------------------

2.  更新、删除、查询数据

将rooms表中room_id 为1的房间价格打八折；

删除预定表中room_id 为1的记录；

查询所有房间价格大于200的房间信息；

查询用户1预定的所有房间订单信息；

（二）创建数据库表

（三）实体完整性、索引、域完整性、参照完整性

每个表的主键字段确保了实体的唯一性。

使用AUTO_INCREMENT为每个表的主键字段自动生成唯一值。

为用户表的用户名和邮箱字段创建索引，提高查询效率。

为房间表的房间类型字段创建索引。

在reviews表中，rating字段使用CHECK约束限制其值在1到5之间。

在orders表和reviews表中，通过外键约束确保数据的参照完整性。

（四）操作表数据

1\. 插入数据

2\. 更新、删除、查询数据

将房间表中房间号为"101"的房间状态更新为"Booked"。

删除预订表中房间号为"101"且用户ID为1的记录。

查询所有价格大于200的房间信息。

查询用户用户1预订的所有房间信息。

（五）视图

创建一个视图，展示每个用户的订单总数和总金额。

sql

复制

CREATE VIEW user_order_summary AS

SELECT user_id, COUNT(order_id) AS order_count, SUM(total_amount) AS
total_spent

FROM orders

GROUP BY user_id;

（六）用户定义函数

创建一个函数，计算订单的总金额。

sql

复制

CREATE FUNCTION calculate_total_amount(room_price DECIMAL(10, 2), nights
INT) RETURNS DECIMAL(10, 2)

BEGIN

DECLARE total DECIMAL(10, 2);

SET total = room_price \* nights;

RETURN total;

END;

（七）存储过程

创建一个存储过程，用于添加新订单。

sql

复制

CREATE PROCEDURE add_order(IN user_id INT, IN room_id INT, IN
check_in_time DATETIME, IN check_out_time DATETIME)

BEGIN

DECLARE nights INT;

DECLARE total_amount DECIMAL(10, 2);

SELECT price INTO \@room_price FROM rooms WHERE room_id = room_id;

SET nights = DATEDIFF(check_out_time, check_in_time);

SET total_amount = calculate_total_amount(@room_price, nights);

INSERT INTO orders (user_id, order_status, total_amount, order_time)
VALUES (user_id, \'Pending\', total_amount, NOW());

INSERT INTO reservations (user_id, room_id, check_in_time,
check_out_time, reservation_status) VALUES (user_id, room_id,
check_in_time, check_out_time, \'Pending\');

END;

（八）游标

创建一个游标，遍历所有用户并计算其订单总数。

sql

复制

CREATE PROCEDURE calculate_user_orders()

BEGIN

DECLARE done INT DEFAULT FALSE;

DECLARE user_id INT;

DECLARE order_count INT DEFAULT 0;

DECLARE cur CURSOR FOR SELECT user_id FROM users;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cur;

read_loop: LOOP

FETCH cur INTO user_id;

IF done THEN

LEAVE read_loop;

END IF;

SELECT COUNT(order_id) INTO order_count FROM orders WHERE user_id =
user_id;

INSERT INTO user_order_summary (user_id, order_count) VALUES (user_id,
order_count);

END LOOP;

CLOSE cur;

END;

（九）触发器设计

触发器：自动更新房间状态

当用户预订房间时，自动将房间状态更新为"Booked"。

当用户取消预订时，自动将房间状态更新为"Available"。

sql

复制

CREATE TRIGGER update_room_status_on_reservation

AFTER INSERT ON reservations

FOR EACH ROW

BEGIN

UPDATE rooms SET status = \'Booked\' WHERE room_id = NEW.room_id;

END;

CREATE TRIGGER update_room_status_on_cancel

AFTER UPDATE ON reservations

FOR EACH ROW

BEGIN

IF NEW.reservation_status = \'Cancelled\' THEN

UPDATE rooms SET status = \'Available\' WHERE room_id = NEW.room_id;

END IF;

END;

触发器：自动更新房间平均评分

当用户提交评价时，自动更新房间的平均评分。

sql

复制

CREATE TRIGGER update_room_average_rating

AFTER INSERT ON reviews

FOR EACH ROW

BEGIN

UPDATE rooms SET average_rating = (SELECT AVG(rating) FROM reviews WHERE
room_id = NEW.room_id) WHERE room_id = NEW.room_id;

END;

（十）系统安全管理

用户权限管理

创建管理员用户，分配所有权限。

创建普通用户，分配预订、订单、评价的权限。

创建只读用户，分配查询权限。

sql

复制

CREATE USER \'admin\'@\'localhost\' IDENTIFIED BY \'adminpassword\';

GRANT ALL PRIVILEGES ON OnlineHotelSystem.\* TO \'admin\'@\'localhost\';

CREATE USER \'user\'@\'localhost\' IDENTIFIED BY \'userpassword\';

GRANT SELECT, INSERT, UPDATE, DELETE ON OnlineHotelSystem.reservations
TO \'user\'@\'localhost\';

GRANT SELECT, INSERT, UPDATE, DELETE ON OnlineHotelSystem.orders TO
\'user\'@\'localhost\';

GRANT SELECT, INSERT, UPDATE, DELETE ON OnlineHotelSystem.reviews TO
\'user\'@\'localhost\';

CREATE USER \'readonly\'@\'localhost\' IDENTIFIED BY
\'readonlypassword\';

GRANT SELECT ON OnlineHotelSystem.\* TO \'readonly\'@\'localhost\';

数据加密

对敏感数据（如用户密码）进行加密存储。

sql

复制

UPDATE users SET password = MD5(password);

审计日志

创建一个审计日志表，记录所有对数据库的修改操作。

sql

复制

CREATE TABLE audit_log (

log_id INT AUTO_INCREMENT PRIMARY KEY,

user_id INT,

action VARCHAR(100),

table_name VARCHAR(50),

timestamp DATETIME DEFAULT NOW()

);

（十一）事务处理

编写一个事务，确保用户预订房间时，订单和预订数据的一致性。

sql

复制

START TRANSACTION;

INSERT INTO orders (user_id, order_status, total_amount, order_time)
VALUES (1, \'Pending\', 599.97, NOW());

INSERT INTO reservations (user_id, room_id, check_in_time,
check_out_time, reservation_status) VALUES (1, 1, \'2025-05-01\',
\'2025-05-03\', \'Pending\');

COMMIT;

（十二）备份与恢复数据库

数据库备份，并完成恢复。

把数据表中的一个表导出到txt文件，在从txt文件导入

（十三）其他功能

1.求闭包

求给定R\<U，F\>，其中U={A，B，C，D，E，G}，F={AB→D，DB→EG，AC→E，BE→A，A→B
}，求AC的闭包（AC）F+。

2.根据闭包求候选码

求给定R\<U，F\>，其中U={A，B，C，D，E，G}，F={AB→D，DB→EG，AC→E，BE→A，A→B
}，求R的一个候选码。

3.LRLRN方法求全部候选码

使用LRLRN方法求给定R\<U，F\>，其中U={A，B，C，D，E，G}，F={AB→D，DB→EG，AC→E，BE→A，A→B
}的全部候选码。
