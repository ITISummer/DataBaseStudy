use default;
set hive.exec.mode.local.auto=true;
set hive.exec.mode.local.auto;

create table order_info
(
    order_id     string, --订单id
    user_id      string, -- 用户id
    user_name    string, -- 用户姓名
    order_date   string, -- 下单日期
    order_amount int     -- 订单金额
);

insert overwrite table order_info
values ('1', '1001', '小元', '2022-01-01', '10'),
       ('2', '1002', '小海', '2022-01-02', '15'),
       ('3', '1001', '小元', '2022-02-03', '23'),
       ('4', '1002', '小海', '2022-01-04', '29'),
       ('5', '1001', '小元', '2022-01-05', '46'),
       ('6', '1001', '小元', '2022-04-06', '42'),
       ('7', '1002', '小海', '2022-01-07', '50'),
       ('8', '1001', '小元', '2022-01-08', '50'),
       ('9', '1003', '小辉', '2022-04-08', '62'),
       ('10', '1003', '小辉', '2022-04-09', '62'),
       ('11', '1004', '小猛', '2022-05-10', '12'),
       ('12', '1003', '小辉', '2022-04-11', '75'),
       ('13', '1004', '小猛', '2022-06-12', '80'),
       ('14', '1003', '小辉', '2022-04-13', '94');

select * from order_info;

-- （1）统计每个用户截至目前每次下单的累积下单总额
select
    order_id,
    user_id,
    user_name,
    order_date,
    order_amount,
    sum(order_amount) over(partition by user_id order by order_date rows between unbounded preceding and current row) sum_so_far
from order_info;

-- （2）统计每个用户截至每次下单的当月累积下单总额
select
    order_id,
    user_id,
    user_name,
    order_date,
    order_amount,
    sum(order_amount) over(partition by user_id,substr(order_date,1,7) order by order_date rows between unbounded preceding and current row) sum_so_far
from order_info;

-- （3）统计每个用户每次下单距离上次下单相隔的天数（首次下单按0天算）
describe function extended datediff;

select
    order_id,
    user_id,
    user_name,
    order_date,
    order_amount,
    nvl(datediff(order_date,last_order_date),0) diff
from
 (
    select
        *,
        lag(order_date,1,null)over(partition by user_id order by order_date)last_order_date
    from order_info
) t1;

-- （4）查询所有下单记录以及每个用户的每个下单记录所在月份的首/末次下单日期
select
    *,
    first_value(order_date)over(partition by user_id,substr(order_date,1,7) order by order_date)first_date,
    last_value(order_date)over(partition by user_id,substr(order_date,1,7)  order by order_date)last_date
from order_info;

-- （5）为每个用户的所有下单记录按照订单金额进行排名
/*
https://www.cnblogs.com/JasonCeng/p/13087894.html
本文对Hive中常用的三个排序函数row_number()、dense_rank()、rank()的特性进行类比和总结，
并通过笔者亲自动手写的一个小实验，直观展现这三个函数的特点。

三个排序函数的共同点与区别
函数	            不同点
row_number()    无重复排名（相同排名的按序排名）
dense_rank()	有相同排名，但不会跳过占用的排名
rank()	        有相同排名，但会跳过占用的排名
 */
select
    *,
    rank() over(partition by user_id order by order_amount desc) rk,
    dense_rank() over(partition by user_id order by order_amount desc) drk,
    row_number() over(partition by user_id order by order_amount desc) rn
from order_info;
