set hive.exec.mode.local.auto=true;
set hive.exec.mode.local.auto;
use zjcs;
/*
2.1 查询订单明细表（order_detail）中销量（下单件数）排名第二的商品id，
如果不存在返回null，如果存在多个排名第二的商品则需要全部返回。
*/
select sku_id from (
    select sku_id
    from (
        select sku_id,sum_sku_num,
               dense_rank() over (order by sum_sku_num desc) rk
        from(
            select sku_id, sum(sku_num) sum_sku_num
            from order_detail
            group by sku_id
        ) t1
    ) t2
    where rk=2
) t3 right join ( -- 为保证在没有结果时，返回null
         select 1
     ) t4
     on 1 = 1;

/*
 2.2 查询订单信息表(order_info)中最少连续3天下单的用户id
 */
select user_id, count(1) sum_flag
from
(
    select user_id,create_date,
           date_sub(create_date,row_number() over (partition by user_id order by create_date)) flag
    from
    (
        select user_id,create_date
        from order_info
        group by user_id,create_date
    )t1
)t2
group by user_id,flag
-- having sum_flag>=3
order by sum_flag desc ;

/*
2.3 从订单明细表(order_detail)统计各品类(category_info)销售出的商品种类数及累积销量最好的商品
*/
select category_id,
       category_name,
       sku_id,
       name,
       sum_sku_num,
       sku_cnt,
       rk
from
(
    select t1.sku_id,sku.name, sku.category_id,cate.category_name,t1.sum_sku_num,
           rank() over (partition by sku.category_id order by t1.sum_sku_num desc) rk,
           count(distinct t1.sku_id) over (partition by sku.category_id) sku_cnt
    from
    (   -- 根据商品id(sku_id)分组，统计卖出的数量
        select sku_id,
            sum(sku_num) sum_sku_num
        from order_detail
        group by sku_id
    ) t1 left join sku_info sku on t1.sku_id=sku.sku_id
    left join category_info cate on sku.category_id = cate.category_id
) t2
where rk=1;

/*
从订单信息表(order_info)中统计每个用户截止其每个下单日期的累积消费金额，以及每个用户在其每个下单日期的VIP等级。
用户vip等级根据累积消费金额计算，计算规则如下：
设累积消费总额为X，

若0=<X<10000,则vip等级为普通会员
若10000<=X<30000,则vip等级为青铜会员
若30000<=X<50000,则vip等级为白银会员
若50000<=X<80000,则vip为黄金会员
若80000<=X<100000,则vip等级为白金会员
若X>=100000,则vip等级为钻石会员
 */
select user_id,create_date,sum_so_far,
        case
        when sum_so_far>=0 and sum_so_far<10000 then '普通会员'
        when sum_so_far>=10000 and sum_so_far<30000 then '青铜会员'
        when sum_so_far>=30000 and sum_so_far<50000 then '白银会员'
        when sum_so_far>=50000 and sum_so_far<80000 then '黄金会员'
        when sum_so_far>=80000 and sum_so_far<100000 then '白金会员'
        when sum_so_far>=100000 then '钻石会员'
        else '非会员'
        end vip_level
from
(
    select *,
        sum(t1.sum_per_day_amount) over(partition by user_id order by t1.create_date rows between unbounded preceding and current row) sum_so_far
    from(
        select oi.user_id,oi.create_date,
               sum(total_amount) sum_per_day_amount
        from order_info oi
        group by user_id, create_date
    ) t1
) t2;

/*
 2.5 从订单信息表(order_info)中查询首次下单后第二天仍然下单的用户占所有下单用户的比例，结果保留一位小数，使用百分数显示
 */
select concat(round(sum(if(datediff(buy_date_second,buy_date_first)=1,1,0))/count(1)*100,1),'%') percentege
from(
    select user_id,
           min(create_date) buy_date_first,
           max(create_date) buy_date_second
    from(
        select user_id,create_date,
                rank() over (partition by user_id order by create_date) rk
        from (
                 select user_id, create_date
                 from order_info
                 group by user_id, create_date
             )t1
    )t2
    where rk<=2
    group by user_id
)t3;

/*
2.6 从订单明细表(order_detail)统计每个商品销售首年的年份，销售数量和销售总额。
 */
select t1.sku_id,t1.first_year,sum(od2.sku_num) sum_sku_num,sum(od2.sku_num*od2.price) order_amount
from(
    select od.sku_id,year(min(od.create_date)) first_year
    from order_detail od
    group by od.sku_id
)t1 join order_detail od2 on t1.sku_id=od2.sku_id and t1.first_year=year(od2.create_date)
group by t1.sku_id,t1.first_year;
-- 答案
select sku_id,
       year(create_date),
       sum(sku_num),
       sum(price*sku_num)
from (
         select order_id,
                sku_id,
                price,
                sku_num,
                create_date,
                rank() over (partition by sku_id order by year(create_date)) rk
         from order_detail
     ) t1
where rk = 1
group by sku_id,year(create_date);


/*
2.7 从订单明细表(order_detail)中筛选出去年总销量小于100的商品及其销量，
假设今天的日期是2022-01-10，不考虑上架时间小于一个月的商品
 */
select t1.sku_id,si.name,sum_sku_num
from(
    select od.sku_id,sum(od.sku_num) sum_sku_num
    from order_detail od
    where year(od.create_date)=2021
    and datediff('2022-01-10',od.create_date)>30
    group by od.sku_id
    having sum_sku_num<100
)t1 join sku_info si on t1.sku_id=si.sku_id;

/*
2.8 从用户登录明细表（user_login_detail）中查询每天的新增用户数，
若一个用户在某天登录了，且在这一天之前没登录过，则任务该用户为这一天的新增用户
 */
 select date_format(t1.login_date,'yyyy-MM-dd') format_login_date, count(1) cnt
from(
    select uld.user_id,min(uld.login_ts) login_date
    from user_login_detail uld
    group by uld.user_id
)t1
group by date_format(t1.login_date,'yyyy-MM-dd');
-- 答案
select
    login_date_first,
    count(*) user_count
from
(
    select
        user_id,
        min(date_format(login_ts,'yyyy-MM-dd')) login_date_first
    from user_login_detail
    group by user_id
)t1
group by login_date_first;

/*
2.9 从订单明细表（order_detail）中统计出每种商品销售件数最多的日期及当日销量，
如果有同一商品多日销量并列的情况，取其中的最小日期
*/
select sku_id,create_date,day_sail_num
from(
        select od.sku_id,od.create_date,sum(od.sku_num) day_sail_num,
               row_number() over (partition by sku_id order by od.sku_id,sum(od.sku_num) desc,od.create_date) rn
        from order_detail od
        group by od.sku_id, od.create_date
--     order by od.sku_id,day_sail_num desc,od.create_date
)t1
where rn=1;

-- 答案
select sku_id,
       create_date,
       sum_num
from (
         select sku_id,
                create_date,
                sum_num,
                row_number() over (partition by sku_id order by sum_num desc,create_date asc) rn
         from (
                  select sku_id,
                         create_date,
                         sum(sku_num) sum_num
                  from order_detail
                  group by sku_id, create_date
              ) t1
     ) t2
where rn = 1;

/*
 2.10 从订单明细表（order_detail）中查询累积销售件数高于其所属品类平均数的商品
 */
select sku_id,name,sum_sku_num,avg_sku_num
from(
    select t1.sku_id,t2.name,t1.sum_sku_num,
            avg(t1.sum_sku_num) over(partition by t2.category_id) avg_sku_num
    from
    (
        select od.sku_id, sum(od.sku_num) sum_sku_num
        from order_detail od
        group by od.sku_id
    ) t1
    join
    (
        select si.sku_id, name, category_id
        from sku_info si
    ) t2
    on t1.sku_id=t2.sku_id
)t3
where sum_sku_num>avg_sku_num;
-- 答案
select sku_id,
       name,
       sum_num,
       cate_avg_num
from (
         select od.sku_id,
                category_id,
                name,
                sum_num,
                avg(sum_num) over (partition by category_id) cate_avg_num
         from (
                  select sku_id,
                         sum(sku_num) sum_num
                  from order_detail
                  group by sku_id
              ) od
                  left join
              (
                  select sku_id,
                         name,
                         category_id
                  from sku_info
              ) sku
              on od.sku_id = sku.sku_id) t1
where sum_num > cate_avg_num;

/*
2.11 从用户登录明细表（user_login_detail）
和订单信息表（order_info）中查询每个用户的注册日期（首次登录日期）、
总登录次数以及其在2021年的登录次数、订单数和订单总额
 */
select distinct t1.user_id,t1.register_date,t1.total_login_count,t1.login_count_2021,
       sum(1) over (partition by oi.user_id) order_count_2021,
       sum(oi.total_amount) over (partition by oi.user_id) order_amount_2021
from(
    select uld.user_id,min(date_format(login_ts,'yyyy-MM-dd')) register_date,count(1) total_login_count,
            sum(if(year(login_ts)=2021,1,0)) login_count_2021
    from user_login_detail uld
    group by uld.user_id
) t1 join order_info oi on t1.user_id=oi.user_id
where year(oi.create_date)=2021;

-- 答案
select login.user_id,
       register_date,
       total_login_count,
       login_count_2021,
       order_count_2021,
       order_amount_2021
from (
         select user_id,
                min(date_format(login_ts, 'yyyy-MM-dd'))    register_date,
                count(1)                                    total_login_count,
                count(if(year(login_ts) = '2021', 1, null)) login_count_2021
         from user_login_detail
         group by user_id
     ) login
         join
     (
         select user_id,
                count(distinct(order_id))          order_count_2021,
                sum(total_amount) order_amount_2021
         from order_info
         where year(create_date) = '2021'
         group by user_id
     ) oi
     on login.user_id = oi.user_id;

/*
 2.12 从商品价格修改明细表（sku_price_modify_detail）中查询2021-10-01及以前的全部商品的价格，假设所有商品初始价格默认都是99
 */
select si.sku_id,nvl(t1.new_price,99)
from(
    select sku_id,new_price,change_date,
            row_number() over (partition by sku_id order by change_date desc) rn
    from sku_price_modify_detail
    where change_date<='2021-10-01'
) t1 right join sku_info si on t1.sku_id=si.sku_id
where rn=1;

-- 答案
select sku_info.sku_id,
       nvl(new_price, 99) price
from sku_info
         left join
     (
         select sku_id,
                new_price
         from (
                  select sku_id,
                         new_price,
                         change_date,
                         row_number() over (partition by sku_id order by change_date desc) rn
                  from sku_price_modify_detail
                  where change_date <= '2021-10-01'
              ) t1
         where rn = 1
     ) t2
     on sku_info.sku_id = t2.sku_id;

/*
 2.13
订单配送中，如果期望配送日期和下单日期相同，称为即时订单，如果期望配送日期和下单日期不同，称为计划订单。
请从配送信息表（delivery_info）中求出每个用户的首单（用户的第一个订单）中即时订单的比例，保留两位小数，以小数形式显示
 */
select sum(if(t1.order_date=t1.custom_date,1,0))/count(1) percentage
from(
    select di.user_id,di.order_id,di.order_date,di.custom_date,
           row_number() over (partition by di.user_id order by di.order_date) rn
    from delivery_info di
)t1
where rn=1;
-- 答案
select
    round(sum(if(order_date=custom_date,1,0))/count(*),2) percentage
from
(
    select
        delivery_id,
        user_id,
        order_date,
        custom_date,
        row_number() over (partition by user_id order by order_date) rn
    from delivery_info
)t1
where rn=1;

/*
 2.14 现需要请向所有用户推荐其朋友收藏但是用户自己未收藏的商品，
 请从好友关系表（friendship_info）和收藏表（favor_info）中查询出应向哪位用户推荐哪些商品
 */

-- 答案
select
    t1.user_id,
    sort_array(collect_set(friend_favor.sku_id)) recon_sku_id
from
(
    select
        user1_id user_id,
        user2_id friend_id
    from friendship_info
    union
    select
        user2_id,
        user1_id
    from friendship_info
)t1
    -- 求朋友收藏的商品
left join favor_info friend_favor
on t1.friend_id=friend_favor.user_id
    -- 求自己收藏的商品
left join favor_info user_favor
on t1.user_id=user_favor.user_id
    -- 求朋友收藏的和自己收藏的相同的商品
and friend_favor.sku_id=user_favor.sku_id
    -- 去除为空的值
where user_favor.sku_id is null
group by t1.user_id;

/*
 2.15 从登录明细表（user_login_detail）中查询出，
 所有用户的连续登录两天及以上的日期区间，以登录时间（login_ts）为准
 */
 select t1.user_id,
        min(t1.login_ts) min_date,
        max(t1.login_ts) max_date
from
(
    select uld.user_id,date_format(uld.login_ts,'yyyy-MM-dd') login_ts,
           date_sub(uld.login_ts,row_number() over (partition by user_id order by uld.login_ts)) flag
--            row_number() over (partition by uld.user_id order by uld.login_ts) rn
    from user_login_detail uld
)t1
group by t1.user_id,flag
having count(1)>=2;

/*
 2.16 从订单信息表（order_info）和用户信息表（user_info）中，
 分别统计每天男性和女性用户的订单总金额，如果当天男性或者女性没有购物，则统计结果为0
 */
 select t1.create_date,
        sum(if(ui.gender='男',t1.total_amount,0)) total_amount_male,
        sum(if(ui.gender='女',t1.total_amount,0)) total_amount_female
from
(
    select oi.user_id,oi.create_date,sum(oi.total_amount) total_amount
    from order_info oi
    group by oi.user_id,oi.create_date
)t1 join user_info ui on t1.user_id=ui.user_id
group by t1.create_date
order by t1.create_date;

/*
 2.17 查询截止每天的最近3天内的订单金额总和以及订单金额日平均值，保留两位小数，四舍五入
 */

 select t1.create_date,
        round(sum(t1.day_total_amount) over (order by t1.create_date rows between 2 preceding and current row),2) 3d_sum_total_amount,
        round(avg(t1.day_total_amount) over (order by t1.create_date rows between 2 preceding and current row),2) 3d_avg_total_amount
from
 (
     select oi.create_date, sum(oi.total_amount) day_total_amount
     from order_info oi
     group by oi.create_date
 )t1;

-- 答案
select create_date,
       round(sum(total_amount_by_day) over (order by create_date rows between 2 preceding and current row ),2) total_3d,
       round(avg(total_amount_by_day) over (order by create_date rows between 2 preceding and current row ), 2) avg_3d
from (
         select create_date,
                sum(total_amount) total_amount_by_day
         from order_info
         group by create_date
     ) t1;

/*
 2.18 从订单明细表(order_detail)中查询出所有购买过商品1和商品2，但是没有购买过商品3的用户
 */
-- 答案
select user_id
from (
         select user_id,
                collect_set(sku_id) skus
         from order_detail od
                  left join
              order_info oi
              on od.order_id = oi.order_id
         group by user_id
     ) t1
where array_contains(skus, '1')
  and array_contains(skus, '2')
  and !array_contains(skus, '3');


/*
 2.19 从订单明细表（order_detail）中统计每天商品1和商品2销量（件数）的差值（商品1销量-商品2销量
 */
 select t1.create_date,sum_sku_id1-sum_sku_id2 sale_diff
from
(
 select od.create_date,
        sum(if(od.sku_id='1',od.sku_num,0)) sum_sku_id1,
        sum(if(od.sku_id='2',od.sku_num,0)) sum_sku_id2
from order_detail od
group by od.create_date
)t1;

-- 答案
select create_date,
       sum(if(sku_id = '1', sku_num, 0)) - sum(if(sku_id = '2', sku_num, 0)) diff
from order_detail
where sku_id in ('1', '2')
group by create_date;

/*
 2.20 从订单信息表（order_info）中查询出每个用户的最近三笔订单
*/
select t1.user_id,t1.create_date
from
(
select oi.user_id, oi.create_date,
       row_number() over (partition by oi.user_id order by oi.create_date desc) rn
from order_info oi
)t1
where rn<=3;

select oi.user_id, oi.create_date
from order_info oi
group by oi.user_id, oi.create_date
order by oi.user_id,create_date desc;
