//region: 第n题：向所有用户推荐其朋友收藏但是用户自己未收藏的商品
//endregion =================================================================

//region: 第3题：查询各品类销售商品的种类数及销量最高的商品
USE hql_practice;
CREATE TABLE IF NOT EXISTS order_detail (
  order_detail_id STRING COMMENT '订单明细id',
  order_id STRING COMMENT '订单id',
  sku_id STRING COMMENT '商品id',
  create_date STRING COMMENT '下单日期',
  price STRING COMMENT '商品单价',
  sku_num STRING COMMENT '商品件数'
) COMMENT '订单明细表';

INSERT INTO order_detail_3 (order_detail_id, order_id, sku_id, create_date, price, sku_num)
VALUES
    ('1', '1', '1', '2021-09-30', '2000.00', '2'),
    ('2', '1', '3', '2021-09-30', '5000.00', '5'),
    ('22', '10', '4', '2020-10-02', '6000.00', '1'),
    ('23', '10', '5', '2020-10-02', '500.00', '24'),
    ('24', '10', '6', '2020-10-02', '2000.00', '5');


CREATE TABLE IF NOT EXISTS sku_info (
    sku_id STRING COMMENT '商品id',
    name STRING COMMENT '商品名称',
    category_id STRING COMMENT '分类id',
    from_date STRING COMMENT '上架日期',
    price STRING COMMENT '商品价格'
) COMMENT '商品信息表';


INSERT INTO sku_info_3 (sku_id, name, category_id, from_date, price)
VALUES
    ('1', 'xiaomi 10', '1', '2020-01-01', '2000'),
    ('6', '洗碗机', '2', '2020-02-01', '2000'),
    ('9', '自行车', '3', '2020-01-01', '1000');

CREATE TABLE IF NOT EXISTS category_info (
     category_id STRING COMMENT '分类id',
     category_name STRING COMMENT '分类名称'
) COMMENT '商品分类信息表';


INSERT INTO category_info_3 (category_id, category_name)
VALUES
    ('1', '数码'),
    ('2', '厨卫'),
    ('3', '户外');



with t2 as (
    SELECT si.category_id,
           ci.category_name,
           t1.sku_id,
           si.name sku_name,
           t1.order_num,
           row_number() over (partition by ci.category_id order by order_num desc ) rn

    FROM
        (
            -- 统计每种商品的销量
            SELECT sku_id,sum(sku_num) order_num
            FROM order_detail_3
            GROUP BY sku_id
        )t1 left JOIN sku_info_3 si on t1.sku_id = si.sku_id
            JOIN category_info_3 ci on si.category_id = ci.category_id
),t3 as (
    select t2.category_id,count(t2.sku_id) sku_cnt from t2 group by t2.category_id
)
select t2.category_id,
       t2.category_name,
       t2.sku_id,
       t2.sku_name,
       t2.order_num,
       t3.sku_cnt
from t2 join t3 on t2.category_id=t3.category_id
where t2.rn=1;
//endregion =================================================================


//region: 第4题：统计每个用户截止其每个下单日期的累积消费金额，以及每个用户在其每个下单日期的VIP等级
CREATE TABLE IF NOT EXISTS order_info_4 (
      order_id STRING COMMENT '订单id',
      user_id STRING COMMENT '用户id',
      create_date STRING COMMENT '下单日期',
      total_amount STRING COMMENT '订单金额'
) COMMENT '订单信息表';

-- drop table if exists order_info_4;

INSERT INTO order_info_4 (order_id, user_id, total_amount, create_date)
VALUES
    ('1', '101', '29000.00', '2021-09-27'),
    ('2', '101', '70500.00', '2021-09-28'),
    ('3', '101', '43300.00', '2021-09-29'),
    ('4', '101', '860.00', '2021-09-30'),
    ('5', '102', '46180.00', '2021-10-01'),
    ('6', '102', '50000.00', '2021-10-01'),
    ('7', '102', '75500.00', '2021-10-01'),
    ('8', '102', '6170.00', '2021-10-02'),
    ('9', '103', '18580.00', '2021-10-02'),
    ('10', '103', '28000.00', '2021-10-02'),
    ('11', '103', '23400.00', '2021-10-02'),
    ('12', '103', '5910.00', '2021-10-03'),
    ('13', '104', '13000.00', '2021-10-03'),
    ('14', '104', '69500.00', '2021-10-03'),
    ('15', '104', '2000.00', '2021-10-03'),
    ('16', '104', '5380.00', '2021-10-03'),
    ('17', '105', '6210.00', '2021-10-04'),
    ('18', '105', '68000.00', '2021-10-04'),
    ('19', '105', '43100.00', '2021-10-04'),
    ('20', '105', '2790.00', '2021-10-04'),
    ('21', '106', '9390.00', '2021-10-04'),
    ('22', '106', '58000.00', '2021-10-05'),
    ('23', '106', '46600.00', '2021-10-05'),
    ('24', '106', '5160.00', '2021-10-05'),
    ('25', '107', '55350.00', '2021-10-05'),
    ('26', '107', '14500.00', '2021-10-05'),
    ('27', '107', '47400.00', '2021-10-06'),
    ('28', '107', '6900.00', '2021-10-06'),
    ('29', '108', '56570.00', '2021-10-06'),
    ('30', '108', '44500.00', '2021-10-06'),
    ('31', '108', '50800.00', '2021-10-07'),
    ('32', '108', '3900.00', '2021-10-07'),
    ('33', '109', '41480.00', '2021-10-07'),
    ('34', '109', '88000.00', '2021-10-07'),
    ('35', '109', '15000.00', '2020-10-08'),
    ('36', '109', '9020.00', '2020-10-08'),
    ('37', '1010', '9260.00', '2020-10-08'),
    ('38', '1010', '12000.00', '2020-10-08'),
    ('39', '1010', '23900.00', '2020-10-08'),
    ('40', '1010', '6790.00', '2020-10-08');

-- 得到每个用户每个下单日的总money,并按下单日期进行升序排序
with t1 as (
    select
        user_id,create_date,sum(total_amount) cd_money
    from order_info_4
    group by user_id,create_date
), t2 as (
    select user_id,create_date,
       sum(if(cd_money is null,0,cd_money)) over (partition by user_id order by date_format(create_date,'yyyy-MM-dd') rows between unbounded preceding and current row ) money_sum_so_far
    from t1
)
select t2.user_id,
       t2.create_date,
       t2.money_sum_so_far sum_so_far,
       case
           when   money_sum_so_far >=0 and money_sum_so_far < 10000 then '普通会员'
           when   money_sum_so_far >=10000 and money_sum_so_far < 30000 then '青铜会员'
           when   money_sum_so_far >=30000 and money_sum_so_far < 50000 then '白银会员'
           when   money_sum_so_far >=50000 and money_sum_so_far < 80000 then '黄金会员'
           when   money_sum_so_far >=80000 and money_sum_so_far < 100000 then '白金会员'
           when   money_sum_so_far >=100000  then '钻石会员'
       end vip_level
       from t2;
-- order by cast(user_id as int), create_date
//endregion =================================================================


//region: 第5题：从订单信息表(order_info)中查询首次下单后第二天仍然下单的用户占所有下单用户的比例，结果保留一位小数，使用百分数显示
with t2 as
(
    select
        user_id ,date_sub(create_date,rn)
    from(
        select
               user_id, create_date,
               row_number() over (partition by user_id order by create_date) rn
        from order_info_4
        group by user_id, create_date
    )t1
    where t1.rn <= 2
    group by user_id ,date_sub(create_date,rn)
    having count(user_id) == 2

), t3 as (
    select count(user_id) order_2nd from t2
), t4 as (
    select count(distinct user_id) total_order_person from order_info_4
)
select concat(round(t3.order_2nd / t4.total_order_person,2) * 100,'%') percentage
from t3 join t4 on 1=1;
//endregion =================================================================


//region: 第6题：从订单明细表(order_detail)统计每个商品销售首年的年份，销售数量和销售总额
select od1.sku_id,
       od1.min_year year,
       sum(if(year(od2.create_date)==od1.min_year,od2.sku_num,0)) order_num,
       sum(if(year(od2.create_date)==od1.min_year,od2.price*od2.sku_num,0)) order_amount
from
    (
        select
            sku_id,
            min(year(create_date)) min_year
        from order_detail_3
        group by sku_id
    ) od1 join order_detail_3 od2
               on od1.sku_id = od2.sku_id
group by od1.sku_id,od1.min_year;

//endregion =================================================================


//region: 第7题：从订单明细表(order_detail)中筛选出去年总销量小于100的商品及其销量，假设今天的日期是2022-01-10，不考虑上架时间小于一个月的商品

select
    t1.sku_id,
    t1.sku_name,
    sum(od3.sku_num) order_num
from
(
    -- 排除上架时间小于一个月的商品
    select
        sku_id,
        name sku_name
    from sku_info_3
    where from_date <= date_sub('2022-01-10',30)
)t1 join order_detail_3 od3
on t1.sku_id = od3.sku_id
where year(od3.create_date) = '2021'
group by t1.sku_id,t1.sku_name
having order_num <= 100;

//endregion =================================================================


//region: 第8题：从用户登录明细表（user_login_detail）中查询每天的新增用户数
-- drop table user_login_detail_8;

CREATE TABLE IF NOT EXISTS user_login_detail_8 (
     user_id STRING COMMENT '用户id',
     ip_address STRING COMMENT 'ip地址',
     login_ts STRING COMMENT '登录时间',
     logout_ts STRING COMMENT '登出时间'
) COMMENT '用户登录明细表';

INSERT INTO user_login_detail_8 (user_id, ip_address, login_ts, logout_ts)
VALUES
    ('101', '180.149.130.161', '2021-09-21 08:00:00', '2021-09-27 08:30:00'),
    ('102', '120.245.11.2', '2021-09-22 09:00:00', '2021-09-27 09:30:00'),
    ('103', '27.184.97.3', '2021-09-23 10:00:00', '2021-09-27 10:30:00');


select min_login_date,count(user_id) user_login_cnt
from
(
    select
        user_id,
        min(date_format(login_ts,'yyyy-MM-dd')) min_login_date
        from user_login_detail_8
    group by user_id
)t1
group by min_login_date;

//endregion =================================================================


//region: 第9题：统计出每种商品销售件数最多的日期及当日销量，如果有同一商品多日销量并列的情况，取其中的最小日期。
select
    sku_id,
    create_date,
    order_num sum_num
    from
(
    select
        sku_id,
        create_date,
        sum(sku_num) order_num,
        row_number() over (partition by sku_id order by sum(sku_num) desc, create_date ) rn
    from order_detail_3
    group by sku_id, create_date
)t1
where rn = 1;

//endregion =================================================================


//region: 第10题：查询累积销售件数高于其所属品类平均数的商品

with t1 as (
    select
           si3.category_id,
           od3.sku_id,
           si3.name sku_name,
           od3.sku_num
from order_detail_3 od3 join sku_info_3 si3
on od3.sku_id = si3.sku_id
), t2 as (
    -- 求每个分类下的平均销量
    select
        t1.category_id,
        sum(sku_num) / count( DISTINCT sku_id) avg_order_num_by_cate
        from t1
        group by t1.category_id
), t3 as (
    select
        t1.category_id,
        t1.sku_id,
        t1.sku_name,
        sum(t1.sku_num) sum_order_num
        from t1
        group by t1.sku_id,t1.sku_name, t1.category_id
) select
      t3.sku_id,
      t3.sku_name,
      t3.sum_order_num,
      cast(t2.avg_order_num_by_cate as int)
      from t2 join t3 on t2.category_id = t3.category_id
where t3.sum_order_num > cast(t2.avg_order_num_by_cate as int);

//endregion =================================================================


//region: 第11题：查询每个用户的注册日期（首次登录日期）、总登录次数以及其在2021年的登录次数、订单数和订单总额。
select t1.user_id,
       t1.register_date,
       t1.total_login_count,
       t1.login_count_2021,
       t2.order_count_2021,
       t2.order_amount_2021
from
(
    SELECT user_id,
      min(date_format(login_ts,'yyyy-MM-dd')) register_date,
      count(login_ts) total_login_count,
      sum(if(year(login_ts)='2021',1,0)) login_count_2021
    FROM user_login_detail_8
    GROUP BY user_id
)t1
join
(
    SELECT
        user_id,
        sum(if(year(create_date)='2021',1,0)) order_count_2021,
        sum(if(year(create_date)='2021',total_amount,0)) order_amount_2021
    FROM order_info_4
    group by user_id
)t2 on t1.user_id = t2.user_id
WHERE order_amount_2021 != 0.0;
//endregion =================================================================


//region: 第12题：查询所有商品（sku_info表）截至到2021年10月01号的最新商品价格

-- 创建 sku_price_modify_detail_12 表

CREATE TABLE sku_price_modify_detail_12 (
    sku_id STRING COMMENT '商品id',
    new_price STRING COMMENT '本次变更之后的价格',
    change_date STRING COMMENT '变更日期'
)
    COMMENT '商品价格变更明细表'
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
    STORED AS TEXTFILE;

-- 插入数据
INSERT INTO sku_price_modify_detail_12 VALUES
    ('1', '1900.00', '2021-09-25'),
    ('1', '2000.00', '2021-09-26'),
    ('2', '80.00', '2021-09-29'),
    ('2', '10.00', '2021-09-30');

select
    t1.sku_id,
    spmd12.new_price price
from (
    select
        sku_id,
        max(change_date) max_change_date
    from sku_price_modify_detail_12
    where change_date <= '2021-10-01'
    group by sku_id
)t1 join sku_price_modify_detail_12 spmd12
on t1.sku_id = spmd12.sku_id and t1.max_change_date = spmd12.change_date;

//endregion =================================================================


//region: 第13题：求出每个用户的首单（用户的第一个订单）中即时订单的比例，保留两位小数，以小数形式显示。

-- 创建 delivery_info 表
CREATE TABLE delivery_info_13 (
    delivery_id STRING COMMENT '运单 id',
    order_id STRING COMMENT '订单 id',
    user_id STRING COMMENT '用户 id',
    order_date STRING COMMENT '下单日期',
    custom_date STRING COMMENT '期望配送日期'
)
    COMMENT '配送信息表'
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
    STORED AS TEXTFILE;

-- 插入数据
INSERT INTO delivery_info_13 (order_date, user_id, delivery_id, custom_date, order_id)
VALUES
    ('2021-09-27', 101, 1, '2021-09-29', 1),
    ('2021-09-28', 101, 2, '2021-09-28', 2),
    ('2021-09-29', 101, 3, '2021-09-30', 3),
    ('2021-09-30', 101, 4, '2021-10-01', 4),
    ('2021-10-01', 102, 5, '2021-10-01', 5),
    ('2021-10-01', 102, 6, '2021-10-01', 6),
    ('2021-10-01', 102, 7, '2021-10-01', 7),
    ('2021-10-02', 102, 8, '2021-10-02', 8),
    ('2021-10-02', 103, 9, '2021-10-03', 9),
    ('2021-10-02', 103, 10, '2021-10-03', 10),
    ('2021-10-02', 103, 11, '2021-10-03', 11),
    ('2021-10-03', 103, 12, '2021-10-03', 12),
    ('2021-10-03', 104, 13, '2021-10-04', 13),
    ('2021-10-03', 104, 14, '2021-10-04', 14),
    ('2021-10-03', 104, 15, '2021-10-04', 15),
    ('2021-10-03', 104, 16, '2021-10-04', 16),
    ('2021-10-04', 105, 17, '2021-10-04', 17),
    ('2021-10-04', 105, 18, '2021-10-04', 18),
    ('2021-10-04', 105, 19, '2021-10-04', 19),
    ('2021-10-04', 105, 20, '2021-10-04', 20),
    ('2021-10-04', 106, 21, '2021-10-04', 21),
    ('2021-10-05', 106, 22, '2021-10-05', 22),
    ('2021-10-05', 106, 23, '2021-10-05', 23),
    ('2021-10-05', 106, 24, '2021-10-07', 24),
    ('2021-10-05', 107, 25, '2021-10-05', 25),
    ('2021-10-05', 107, 26, '2021-10-05', 26),
    ('2021-10-06', 107, 27, '2021-10-06', 27),
    ('2021-10-06', 107, 28, '2021-10-07', 28),
    ('2021-10-06', 108, 29, '2021-10-06', 29),
    ('2021-10-06', 108, 30, '2021-10-06', 30),
    ('2021-10-07', 108, 31, '2021-10-09', 31),
    ('2021-10-07', 108, 32, '2021-10-09', 32),
    ('2021-10-07', 109, 33, '2021-10-08', 33),
    ('2021-10-07', 109, 34, '2021-10-08', 34),
    ('2021-10-08', 109, 35, '2021-10-09', 35),
    ('2021-10-08', 109, 36, '2021-10-09', 36),
    ('2021-10-08', 1010, 37, '2021-10-10', 37),
    ('2021-10-08', 1010, 38, '2021-10-10', 38),
    ('2021-10-08', 1010, 39, '2021-10-10', 39),
    ('2021-10-08', 1010, 40, '2021-10-10', 40);


-- 第一种写法
with t1 as (
    -- 求每个用户最早订单的日期
    select
        user_id,
        min(order_date) min_order_date
    from delivery_info_13
    group by user_id
),t2 as (
    select count(*) ontime_order_cnt
    from (
             -- 求得每个用户最早订单中及时订单数
             select t1.user_id, row_number() over (PARTITION BY t1.user_id order by t1.min_order_date) rn
             from t1 join delivery_info_13 di13
             on t1.user_id = di13.user_id and t1.min_order_date = di13.custom_date
         )tmp
    where rn = 1
),t3 as (
    select count(*) total_order_cnt
    from (
             -- 求得每个用户最早订单中及时订单数
             select t1.user_id, row_number() over (PARTITION BY t1.user_id order by t1.min_order_date) rn
             from t1 join delivery_info_13 di13
             on t1.user_id = di13.user_id and t1.min_order_date = di13.order_date
         )tmp
    where rn = 1
)
select cast(round(t2.ontime_order_cnt / t3.total_order_cnt,2)as decimal(16,2)) percentage from t2,t3;


-- 第二种写法
select
    cast(round(sum(if(order_date=custom_date,1,0))/count(*),2) as decimal(16,2)) percentage
from
    (
        select
            delivery_id,
            user_id,
            order_date,
            custom_date,
            row_number() over (partition by user_id order by order_date) rn
        from delivery_info_13
    )t1
where rn=1;
//endregion =================================================================


//region: 第14题：向所有用户推荐其朋友收藏但是用户自己未收藏的商品

CREATE TABLE friendship_info_14 (
    user1_id VARCHAR(255),
    user2_id VARCHAR(255)
);

INSERT INTO friendship_info_14 (user1_id, user2_id)
VALUES
    ('101', '1010'),
    ('101', '108'),
    ('101', '106'),
    ('101', '104'),
    ('101', '102'),
    ('102', '1010'),
    ('102', '108'),
    ('102', '106'),
    ('102', '104'),
    ('102', '102'),
    ('103', '1010'),
    ('103', '108'),
    ('103', '106'),
    ('103', '104'),
    ('103', '102'),
    ('104', '1010'),
    ('104', '108'),
    ('104', '106'),
    ('104', '104'),
    ('104', '102'),
    ('105', '1010'),
    ('105', '108'),
    ('105', '106'),
    ('105', '104'),
    ('105', '102'),
    ('106', '1010'),
    ('106', '108'),
    ('106', '106'),
    ('106', '104'),
    ('106', '102'),
    ('107', '1010'),
    ('107', '108'),
    ('107', '106'),
    ('107', '104'),
    ('107', '102'),
    ('108', '1010'),
    ('108', '108'),
    ('108', '106'),
    ('108', '104'),
    ('108', '102'),
    ('109', '1010'),
    ('109', '108'),
    ('109', '106'),
    ('109', '104'),
    ('109', '102'),
    ('1010', '1010'),
    ('1010', '108'),
    ('1010', '106'),
    ('1010', '104'),
    ('1010', '102');

CREATE TABLE favor_info_14 (
    user_id VARCHAR(255),
    sku_id VARCHAR(255),
    create_date DATE
);

INSERT INTO favor_info_14 (user_id, sku_id, create_date)
VALUES
    ('101', '3', '2021-09-23'),
    ('101', '12', '2021-09-23'),
    ('101', '6', '2021-09-25'),
    ('101', '10', '2021-09-21'),
    ('101', '5', '2021-09-25'),
    ('102', '1', '2021-09-24'),
    ('102', '2', '2021-09-24'),
    ('102', '8', '2021-09-23'),
    ('102', '12', '2021-09-22'),
    ('102', '11', '2021-09-23'),
    ('102', '9', '2021-09-25'),
    ('102', '4', '2021-09-25'),
    ('102', '6', '2021-09-23'),
    ('102', '7', '2021-09-26'),
    ('103', '8', '2021-09-24'),
    ('103', '5', '2021-09-25'),
    ('103', '6', '2021-09-26'),
    ('103', '12', '2021-09-27'),
    ('103', '7', '2021-09-25'),
    ('103', '10', '2021-09-25'),
    ('103', '4', '2021-09-24'),
    ('103', '11', '2021-09-25'),
    ('103', '3', '2021-09-27'),
    ('104', '9', '2021-09-28'),
    ('104', '7', '2021-09-28'),
    ('104', '8', '2021-09-25'),
    ('104', '3', '2021-09-28'),
    ('104', '11', '2021-09-25'),
    ('104', '6', '2021-09-25'),
    ('104', '12', '2021-09-28'),
    ('105', '8', '2021-10-08'),
    ('105', '9', '2021-10-07'),
    ('105', '7', '2021-10-07'),
    ('105', '11', '2021-10-06'),
    ('105', '5', '2021-10-07'),
    ('105', '4', '2021-10-05'),
    ('105', '10', '2021-10-07'),
    ('106', '12', '2021-10-08'),
    ('106', '1', '2021-10-08'),
    ('106', '4', '2021-10-04'),
    ('106', '5', '2021-10-08'),
    ('106', '2', '2021-10-04'),
    ('106', '6', '2021-10-04'),
    ('106', '7', '2021-10-08'),
    ('107', '5', '2021-09-29'),
    ('107', '3', '2021-09-28'),
    ('107', '10', '2021-09-27'),
    ('108', '9', '2021-10-08'),
    ('108', '3', '2021-10-10'),
    ('108', '8', '2021-10-10'),
    ('108', '10', '2021-10-07'),
    ('108', '11', '2021-10-07'),
    ('109', '2', '2021-09-27'),
    ('109', '4', '2021-09-29'),
    ('109', '5', '2021-09-29'),
    ('109', '9', '2021-09-30'),
    ('109', '8', '2021-09-26'),
    ('1010', '2', '2021-09-29'),
    ('1010', '9', '2021-09-29'),
    ('1010', '1', '2021-10-01');


-- 得到每个用户的所有朋友的收藏列表,使用 collect_set 进行去重
select
    t1.user1_id,
--     collect_set(t1.friends_collect_list),
    t1.friends_collect_list,
    t2.user_collect_list
    from(
select
    fi14.user1_id,
    collect_set(fi.sku_id) friends_collect_list
from friendship_info_14 fi14 join favor_info_14 fi
on fi14.user2_id = fi.user_id
group by fi14.user1_id
)t1 join (
-- 得到每个用户收藏列表
select fi14.user1_id,
       collect_set(fi.sku_id) user_collect_list
from friendship_info_14 fi14 join favor_info_14 fi
on fi14.user1_id = fi.user_id
group by fi14.user1_id
)t2 on t1.user1_id = t2.user1_id;

desc function extended collect_set;
desc function extended collect_list;

-- 最终答案
set hive.auto.convert.join=false;
select
    t3.user1_id,
    t3.friends_collect_item sku_id
--     t4.user_collect_item

from (
         select t1.user1_id,friends_collect_item
         from
             (
                 select
                     fi14.user1_id,
                     collect_set(fi.sku_id) friends_collect_list
                 from friendship_info_14 fi14 join favor_info_14 fi
                                                on fi14.user2_id = fi.user_id
                 group by fi14.user1_id
             )t1
                 lateral view explode(t1.friends_collect_list) tmp as friends_collect_item
     )t3
 left join
     (
         select t1.user1_id,user_collect_item
         from
             (
                 -- 得到每个用户收藏列表
                 select fi14.user1_id,
                        collect_set(fi.sku_id) user_collect_list
                 from friendship_info_14 fi14 join favor_info_14 fi
                                                on fi14.user1_id = fi.user_id
                 group by fi14.user1_id
             )t1
                 lateral view explode(t1.user_collect_list) tmp as user_collect_item
     )t4 on t3.user1_id = t4.user1_id and t3.friends_collect_item = t4.user_collect_item
-- where t3.user1_id = 1010 and t4.user_collect_item is null;
where t4.user_collect_item is null;
-- where t3.friends_collect_item is null;
//endregion =================================================================


//region: 第15题：所有用户的连续登录两天及以上的日期区间，以登录时间

INSERT INTO user_login_detail_8 (user_id, login_ts, logout_ts, ip_address)
VALUES
    (101, '2021-09-21 08:00:00', '2021-09-27 08:30:00', '180.149.130.161'),
    (101, '2021-09-27 08:00:00', '2021-09-27 08:30:00', '180.149.130.161'),
    (101, '2021-09-28 09:00:00', '2021-09-28 09:10:00', '180.149.130.161'),
    (101, '2021-09-29 13:30:00', '2021-09-29 13:50:00', '180.149.130.161'),
    (101, '2021-09-30 20:00:00', '2021-09-30 20:10:00', '180.149.130.161'),
    (102, '2021-09-22 09:00:00', '2021-09-27 09:30:00', '120.245.11.2'),
    (102, '2021-10-01 08:00:00', '2021-10-01 08:30:00', '120.245.11.2'),
    (102, '2021-10-01 07:50:00', '2021-10-01 08:20:00', '180.149.130.174'),
    (102, '2021-10-02 08:00:00', '2021-10-02 08:30:00', '120.245.11.2'),
    (103, '2021-09-23 10:00:00', '2021-09-27 10:30:00', '27.184.97.3'),
    (103, '2021-10-03 07:50:00', '2021-10-03 09:20:00', '27.184.97.3'),
    (104, '2021-09-24 11:00:00', '2021-09-27 11:30:00', '27.184.97.34'),
    (104, '2021-10-03 07:50:00', '2021-10-03 08:20:00', '27.184.97.34'),
    (104, '2021-10-03 08:50:00', '2021-10-03 10:20:00', '27.184.97.34'),
    (104, '2021-10-03 08:40:00', '2021-10-03 10:30:00', '120.245.11.89'),
    (105, '2021-10-04 09:10:00', '2021-10-04 09:30:00', '119.180.192.212'),
    (106, '2021-10-04 08:40:00', '2021-10-04 10:30:00', '119.180.192.66'),
    (106, '2021-10-05 21:50:00', '2021-10-05 22:40:00', '119.180.192.66'),
    (107, '2021-09-25 12:00:00', '2021-09-27 12:30:00', '219.134.104.7'),
    (107, '2021-10-05 22:00:00', '2021-10-05 23:00:00', '219.134.104.7'),
    (107, '2021-10-06 09:10:00', '2021-10-06 10:20:00', '219.134.104.7'),
    (107, '2021-10-06 09:00:00', '2021-10-06 10:00:00', '27.184.97.46'),
    (108, '2021-10-06 09:00:00', '2021-10-06 10:00:00', '101.227.131.22'),
    (108, '2021-10-06 22:00:00', '2021-10-06 23:00:00', '101.227.131.22'),
    (109, '2021-09-26 13:00:00', '2021-09-27 13:30:00', '101.227.131.29'),
    (109, '2021-10-06 08:50:00', '2021-10-06 10:20:00', '101.227.131.29'),
    (109, '2021-10-08 09:00:00', '2021-10-08 09:10:00', '101.227.131.29'),
    (1010, '2021-09-27 14:00:00', '2021-09-27 14:30:00', '119.180.192.10'),
    (1010, '2021-10-09 08:50:00', '2021-10-09 10:20:00', '119.180.192.10');

with t1 as (
    select
        user_id,
        date_format(login_ts,'yyyy-MM-dd') login_date,
        row_number() over (partition by user_id order by login_ts) rn
    from user_login_detail_8
    group by user_id, login_ts
), t2 as (
    select
        user_id,
        min(login_date) start_date,
        max(login_date) end_date
--         date_sub(login_date,rn) diff
    from t1
    group by user_id,  date_sub(login_date,rn)
    having start_date <> end_date
)
select * from t2;

//endregion =================================================================


//region: 第16题：分别统计每天男性和女性用户的订单总金额，如果当天男性或者女性没有购物，则统计结果为0。


-- 创建表
CREATE TABLE user_info_16 (
    user_id STRING,
    gender STRING,
    birthday STRING
)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
    STORED AS TEXTFILE;

-- 插入数据
INSERT INTO TABLE user_info_16 (birthday, gender, user_id)
VALUES
    ('1990-01-01', '男', 101),
    ('1991-02-01', '女', 102),
    ('1992-03-01', '女', 103),
    ('1993-04-01', '男', 104),
    ('1994-05-01', '女', 105),
    ('1995-06-01', '男', 106),
    ('1996-07-01', '女', 107),
    ('1997-08-01', '男', 108),
    ('1998-09-01', '女', 109),
    ('1999-10-01', '男', 1010);

select
    oi4.create_date,
    cast(sum(if(ui16.gender='男',oi4.total_amount,0)) as decimal(16,2)) sum_male_amount ,
    cast(sum(if(ui16.gender='女',oi4.total_amount,0)) as decimal(16,2)) sum_female_amount
from order_info_4 oi4 join user_info_16 ui16 on oi4.user_id = ui16.user_id
group by oi4.create_date
order by oi4.create_date;

//endregion =================================================================


//region: 第17题：查询截止每天的最近3天内的订单金额总和以及订单金额日平均值，保留两位小数，四舍五入。
with t1 as (
    select
        create_date,
        sum(total_amount) amount
    from order_info_4
    group by create_date
)
-- select
--     create_date,
--     round(cast(sum(t1.amount) over(order by create_date rows between 2 preceding and current row )as decimal(16,2)),2) total_amount_3d,
--     round(cast(avg(t1.amount) over(order by create_date rows between 2 preceding and current row )as decimal(16,2)),2) avg_amount_3d
-- from t1
select
    t2.create_date,
    round(cast(sum(t3.amount) as decimal(16,2)),2) total_amount_3d,
    round(cast(avg(t3.amount) as decimal(16,2)),2) avg_amount_3d
    from t1 as t2 join t1 as t3 on 1=1
where t3.create_date between date_sub(t2.create_date,2) and t2.create_date
group by t2.create_date
order by t2.create_date;

//endregion =================================================================


//region: 第18题：从订单明细表(order_detail)中查询出所有购买过商品1和商品2，但是没有购买过商品3的用户

with t1 as (
    select
        oi4.user_id,
        collect_set(od.sku_id) sku_set
    from order_info_4 oi4 join order_detail_3 od on oi4.order_id = od.order_id
    group by oi4.user_id
)
select t1.user_id
from t1
where array_contains(sku_set,'1') and array_contains(sku_set,'2') and !array_contains(sku_set,'3');


INSERT INTO order_detail_3 (order_detail_id, sku_num, price, sku_id, create_date, order_id)
VALUES
    (1, 2, 2000.00, 1, '2021-09-27', 1),
    (2, 5, 5000.00, 3, '2021-09-27', 1),
    (3, 9, 6000.00, 4, '2021-09-28', 2),
    (4, 33, 500.00, 5, '2021-09-28', 2),
    (5, 37, 100.00, 7, '2021-09-29', 3),
    (6, 46, 600.00, 8, '2021-09-29', 3),
    (7, 12, 1000.00, 9, '2021-09-29', 3),
    (8, 43, 20.00, 12, '2021-09-30', 4),
    (9, 8, 2000.00, 1, '2021-10-01', 5),
    (10, 18, 10.00, 2, '2021-10-01', 5),
    (11, 6, 5000.00, 3, '2021-10-01', 5),
    (12, 8, 6000.00, 4, '2021-10-01', 6),
    (13, 1, 2000.00, 6, '2021-10-01', 6),
    (14, 17, 100.00, 7, '2021-10-01', 7),
    (15, 48, 600.00, 8, '2021-10-01', 7),
    (16, 45, 1000.00, 9, '2021-10-01', 7),
    (17, 48, 100.00, 10, '2021-10-02', 8),
    (18, 15, 50.00, 11, '2021-10-02', 8),
    (19, 31, 20.00, 12, '2021-10-02', 8),
    (20, 9, 2000.00, 1, '2021-10-02', 9),
    (21, 5800, 10.00, 2, '2021-10-02', 9),
    (22, 1, 6000.00, 4, '2021-10-02', 10),
    (23, 24, 500.00, 5, '2021-10-02', 10),
    (24, 5, 2000.00, 6, '2021-10-02', 10),
    (25, 39, 600.00, 8, '2021-10-02', 11),
    (26, 47, 100.00, 10, '2021-10-03', 12),
    (27, 19, 50.00, 11, '2021-10-03', 12),
    (28, 13000, 20.00, 12, '2021-10-03', 12),
    (29, 4, 2000.00, 1, '2021-10-03', 13),
    (30, 1, 5000.00, 3, '2021-10-03', 13),
    (31, 5, 6000.00, 4, '2021-10-03', 14),
    (32, 47, 500.00, 5, '2021-10-03', 14),
    (33, 8, 2000.00, 6, '2021-10-03', 14),
    (34, 20, 100.00, 7, '2021-10-03', 15),
    (35, 22, 100.00, 10, '2021-10-03', 16),
    (36, 42, 50.00, 11, '2021-10-03', 16),
    (37, 7400, 20.00, 12, '2021-10-03', 16),
    (38, 3, 2000.00, 1, '2021-10-04', 17),
    (39, 21, 10.00, 2, '2021-10-04', 17),
    (40, 8, 6000.00, 4, '2021-10-04', 18),
    (41, 28, 500.00, 5, '2021-10-04', 18),
    (42, 3, 2000.00, 6, '2021-10-04', 18),
    (43, 55, 100.00, 7, '2021-10-04', 19),
    (44, 11, 600.00, 8, '2021-10-04', 19),
    (45, 31, 1000.00, 9, '2021-10-04', 19),
    (46, 45, 50.00, 11, '2021-10-04', 20),
    (47, 27, 20.00, 12, '2021-10-04', 20),
    (48, 2, 2000.00, 1, '2021-10-04', 21),
    (49, 39, 10.00, 2, '2021-10-04', 21),
    (50, 1, 5000.00, 3, '2021-10-04', 21),
    (51, 8, 6000.00, 4, '2021-10-05', 22),
    (52, 20, 500.00, 5, '2021-10-05', 22),
    (53, 58, 100.00, 7, '2021-10-05', 23),
    (54, 18, 600.00, 8, '2021-10-05', 23),
    (55, 30, 1000.00, 9, '2021-10-05', 23),
    (56, 27, 100.00, 10, '2021-10-05', 24),
    (57, 28, 50.00, 11, '2021-10-05', 24),
    (58, 53, 20.00, 12, '2021-10-05', 24),
    (59, 5, 2000.00, 1, '2021-10-05', 25),
    (60, 35, 10.00, 2, '2021-10-05', 25),
    (61, 9, 5000.00, 3, '2021-10-05', 25),
    (62, 1, 6000.00, 4, '2021-10-05', 26),
    (63, 13, 500.00, 5, '2021-10-05', 26),
    (64, 1, 2000.00, 6, '2021-10-05', 26),
    (65, 30, 100.00, 7, '2021-10-06', 27),
    (66, 19, 600.00, 8, '2021-10-06', 27),
    (67, 33, 1000.00, 9, '2021-10-06', 27),
    (68, 37, 100.00, 10, '2021-10-06', 28),
    (69, 46, 50.00, 11, '2021-10-06', 28),
    (70, 45, 20.00, 12, '2021-10-06', 28),
    (71, 8, 2000.00, 1, '2021-10-06', 29),
    (72, 57, 10.00, 2, '2021-10-06', 29),
    (73, 8, 5000.00, 3, '2021-10-06', 29),
    (74, 3, 6000.00, 4, '2021-10-06', 30),
    (75, 33, 500.00, 5, '2021-10-06', 30),
    (76, 5, 2000.00, 6, '2021-10-06', 30),
    (77, 13, 600.00, 8, '2021-10-07', 31),
    (78, 43, 1000.00, 9, '2021-10-07', 31),
    (79, 24, 100.00, 10, '2021-10-07', 32),
    (80, 30, 50.00, 11, '2021-10-07', 32),
    (81, 8, 2000.00, 1, '2021-10-07', 33),
    (82, 48, 10.00, 2, '2021-10-07', 33),
    (83, 5, 5000.00, 3, '2021-10-07', 33),
    (84, 10, 6000.00, 4, '2021-10-07', 34),
    (85, 44, 500.00, 5, '2021-10-07', 34),
    (86, 1, 2000.00, 6, '2021-10-07', 34),
    (87, 1, 100.00, 7, '2021-10-08', 35),
    (88, 23, 600.00, 8, '2021-10-08', 35),
    (89, 41, 1000.00, 9, '2021-10-08', 35),
    (90, 35, 50.00, 11, '2021-10-08', 36),
    (91, 38, 20.00, 12, '2021-10-08', 36),
    (92, 4, 2000.00, 1, '2021-10-08', 37),
    (93, 2, 10.00, 2, '2021-10-08', 37),
    (94, 11, 5000.00, 3, '2021-10-08', 37),
    (95, 13, 6000.00, 4, '2021-10-08', 38),
    (96, 27, 500.00, 5, '2021-10-08', 38),
    (97, 48, 2000.00, 6, '2021-10-08', 38),
    (98, 30, 100.00, 7, '2021-10-09', 39),
    (99, 15, 600.00, 8, '2021-10-09', 39),
    (100, 38, 1000.00, 9, '2021-10-09', 39);

//endregion =================================================================


//region: 第19题：从订单明细表（order_detail）中统计每天商品1和商品2销量（件数）的差值（商品1销量-商品2销量）

select
    create_date,
    sum(if(sku_id='1',sku_num,0)) - sum(if(sku_id='2',sku_num,0)) diff
from order_detail_3
where sku_id in ('1','2')
group by create_date
order by create_date;

//endregion =================================================================


//region: 第20题：从订单信息表（order_info）中查询出每个用户的最近三个下单日期的所有订单
select
    user_id,
    order_id,
    create_date
from (
    select
        user_id,
        order_id,
        create_date,
        dense_rank() over (partition by user_id order by create_date desc) rn
    from order_info_4
)t1
where rn <=3;
//endregion =================================================================


