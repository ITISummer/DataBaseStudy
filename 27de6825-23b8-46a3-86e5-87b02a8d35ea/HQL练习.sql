-- ========================第n题：查询各品类销售商品的种类数及销量最高的商品========================
-- ================================================

-- ========================第3题：查询各品类销售商品的种类数及销量最高的商品========================
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
-- ================================================


-- ========================第4题：统计每个用户截止其每个下单日期的累积消费金额，以及每个用户在其每个下单日期的VIP等级========================

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
-- ================================================

-- ========================第5题：从订单信息表(order_info)中查询首次下单后第二天仍然下单的用户占所有下单用户的比例，结果保留一位小数，使用百分数显示========================

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
-- ================================================

-- ========================第6题：从订单明细表(order_detail)统计每个商品销售首年的年份，销售数量和销售总额========================

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

-- ================================================

-- ========================第7题：从订单明细表(order_detail)中筛选出去年总销量小于100的商品及其销量，假设今天的日期是2022-01-10，不考虑上架时间小于一个月的商品========================

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

-- ================================================

-- ========================第8题：从用户登录明细表（user_login_detail）中查询每天的新增用户数========================
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

-- ================================================


-- ========================第9题：统计出每种商品销售件数最多的日期及当日销量，如果有同一商品多日销量并列的情况，取其中的最小日期。========================

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

-- ================================================


-- ========================第10题：查询累积销售件数高于其所属品类平均数的商品========================

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

-- ================================================
