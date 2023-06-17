//region: 第n题：向所有用户推荐其朋友收藏但是用户自己未收藏的商品
//endregion =================================================================


//region: 第21题：查询每个用户两个登录日期（以login_ts为准）之间的最大的空档期

SELECT
    user_id,
    IF(
                max(diff)
                >=
                DATEDIFF('2021-10-10', MAX(login_ts)),
                max(diff),
                DATEDIFF('2021-10-10', MAX(login_ts))
        ) AS max_diff
FROM (
         select
             user_id,
             abs(datediff(lag(login_ts) over (partition by user_id order by login_ts),login_ts)) diff,
             login_ts
         from user_login_detail_8
     )t1
GROUP BY user_id;

//endregion =================================================================


//region: 第22题：从登录明细表（user_login_detail）中查询在相同时刻，多地登陆（ip_address不同）的用户

select user_id
from(
    select
        user_id,
        login_ts,
        lag(logout_ts) over (partition by user_id order by login_ts) pre_logout_ts,
        if(unix_timestamp(login_ts)-unix_timestamp(lag(logout_ts) over (partition by user_id order by login_ts))<=0
            and ip_address <> lag(ip_address) over (partition by user_id order by login_ts),1,0 ) flag
    from user_login_detail_8
)t1
where flag=1
group by user_id;

desc function extended unix_timestamp;
SELECT (UNIX_TIMESTAMP('2021-09-27 08:00:00') - UNIX_TIMESTAMP('2021-09-27 08:00:00'))  AS mili_difference;
//endregion =================================================================


//region: 第23题：查询连续两个月销售总额大于等于任务总额的商品

select
    sku_id
--     count(1) cnt
from(
    select
        sku_id,
        total_amount,
        year_month,
        lag(year_month) over (partition by sku_id order by total_amount) pre_year_month,
        datediff(concat(year_month,'-01'),lag(concat(year_month,'-01')) over (partition by sku_id order by total_amount)) flag
    from (
        select
            sku_id,
            concat(year(create_date),'-',month(create_date)) year_month,
            sum(price*sku_num) total_amount
        from order_detail_3
        where sku_id in ('1','2')
        group by sku_id, concat(year(create_date),'-',month(create_date))
        having (
            case sku_id
            when '1' then total_amount>21000
            when '2' then total_amount>10000
            end
                   )
    )t1
)t2
group by sku_id,flag
having count(1) > 1;

//endregion =================================================================


//region: 第24题：从销售件数对商品进行分类，0-5000为冷门商品，5001-19999位一般商品，20000往上为热门商品，并求出不同类别商品的数量
select
    category,
    count(1) cn
from
    (
    select
        case
        when sum(sku_num) between 0 and 5000 then '冷门商品'
        when sum(sku_num) >=5001 and sum(sku_num) <=19999 then '一般商品'
        when sum(sku_num)>=20000 then '热门商品'
        end category
    from order_detail_3
    group by sku_id
)t1
group by category;
//endregion =================================================================


//region: 第25题：查询各个品类销售数量前三的商品。如果该品类小于三个商品，则输出所有的商品销量。

INSERT INTO sku_info_3 (category_id, from_date, price, name, sku_id)
VALUES
    (1, '2020-01-01', 2000.0, 'xiaomi 10', 1),
    (1, '2020-02-01', 10.0, '手机壳', 2),
    (1, '2020-03-01', 5000.0, 'apple 12', 3),
    (1, '2020-04-01', 6000.0, 'xiaomi 13', 4),
    (2, '2020-01-01', 500.0, '破壁机', 5),
    (2, '2020-02-01', 2000.0, '洗碗机', 6),
    (2, '2020-03-01', 100.0, '热水壶', 7),
    (2, '2020-04-01', 600.0, '微波炉', 8),
    (3, '2020-01-01', 1000.0, '自行车', 9),
    (3, '2020-02-01', 100.0, '帐篷', 10),
    (3, '2020-02-01', 50.0, '烧烤架', 11),
    (3, '2020-03-01', 20.0, '遮阳伞', 12);

select
    t1.sku_id,
    t1.category_id
from (
select
    si3.category_id,
    od3.sku_id,
    sum(od3.sku_num) sum_sku,
    row_number() over (partition by si3.category_id order by sum(od3.sku_num) desc) rn
from order_detail_3 od3 join sku_info_3  si3 on od3.sku_id = si3.sku_id
group by si3.category_id,od3.sku_id
)t1
where rn <= 3;

//endregion =================================================================


//region: 第26题：求出各分类商品价格的中位数，如果一个分类下的商品个数为偶数则输出中间两个值的平均值，如果是奇数，则输出中间数即可。
/*
with t1 as (
    select
        category_id,
        count(price) cnt
    from sku_info_3
    group by category_id
)
select
    t1.category_id,
    CASE
        WHEN t1.cnt % 2 = 0 THEN (percentile(cast(price as bigint), 0.5) + percentile(cast(price as bigint), 0.5 + 1.0 / t1.cnt)) / 2
        ELSE percentile(cast(price as bigint), 0.5)
    END AS median_price
from t1 join sku_info_3 si3 on t1.category_id = si3.category_id
group by t1.category_id;
*/

with t1 as (
    select
        category_id,
        count(price) cnt,
        sort_array(collect_list(price)) price_list
    from ( select category_id,cast(price as decimal(16,2)) from sku_info_3 )t0
    group by category_id
)
select category_id,
       if(cnt % 2 == 0,
          cast((price_list[cast(cnt / 2 - 1 as int)] + price_list[cast(cnt / 2 as int)]) / 2 as decimal(16, 2)),
          cast(price_list[cast(cnt / 2 as int)] as decimal(16, 2))) medprice
from t1;

//endregion =================================================================


//region: 第27题：从订单详情表（order_detail）中找出销售额连续3天超过100的商品

select sku_id
from
(
    select
        sku_id,
        sum(sku_num*price) sum_total_amount,
    --     create_date,
        date_sub(create_date,row_number() over (partition by sku_id order by create_date)) date_diff
    from order_detail_3
    group by sku_id,create_date
    having sum_total_amount > 100
)t1
group by sku_id,date_diff
having count(date_diff) >= 3;


//endregion =================================================================


//region: 第28题：从用户登录明细表（user_login_detail）中首次登录算作当天新增，第二天也登录了算作一日留存
with t1 as (

select
    user_id,
    date_format(min(login_ts),'yyyy-MM-dd') first_login_ts,
    date_format(max(login_ts),'yyyy-MM-dd') second_login_ts,
    datediff(max(login_ts),min(login_ts)) flag
from
(
    select
        user_id,
        date_format(login_ts,'yyyy-MM-dd') login_ts,
        dense_rank() over (partition by user_id order by date_format(login_ts,'yyyy-MM-dd')) drk
    from user_login_detail_8
)t1
where drk <= 2
group by user_id
)
select
    t1.first_login_ts first_login,
    sum(1) register,
--     sum(if(flag=1,1,0)) retainer
    cast(sum(if(flag=1,1,0)) / sum(1) as decimal(16,2)) retention
from t1
group by t1.first_login_ts;

//endregion =================================================================


//region: 第29题：从订单详情表（order_detail）中，求出商品连续售卖的时间区间
select
    sku_id,
    min(create_date) start_date,
    max(create_date) end_date
from (
    select
        sku_id,
        create_date,
        row_number() over (partition by sku_id order by create_date) rn,
        date_sub(create_date,row_number() over (partition by sku_id order by create_date)) date_diff
    from order_detail_3
    group by sku_id, create_date
)t1
group by sku_id,date_diff;
//endregion =================================================================


//region: 第30题：分别从登陆明细表（user_login_detail）和配送信息表中用户登录时间和下单时间统计登陆次数和交易次数
/*
select
    uld.user_id,
    date_format(uld.login_ts,'yyyy-MM-dd') login_date,
    sum(if(uld.login_ts is null,0,1)) login_count,
    sum(if(d.order_date is null,0,1)) order_count
from
user_login_detail_8 uld left join delivery_info_13 d
on uld.user_id = d.user_id and date_format(uld.login_ts,'yyyy-MM-dd') = date_format(d.order_date,'yyyy-MM-dd')
group by uld.user_id, uld.login_ts;
*/

with t1 as (
    select
        user_id,
        date_format(login_ts,'yyyy-MM-dd') login_dt,
        count(1) login_count
    from user_login_detail_8
    group by user_id,date_format(login_ts,'yyyy-MM-dd')
), t2 as (
    select
        user_id,
        order_date,
        count(1) order_count
    from delivery_info_13
    group by user_id,order_date
) select
      t1.user_id,
      t1.login_dt login_date,
      t1.login_count,
      nvl(t2.order_count,0),
      order_count
from t1 left join t2
on t1.user_id = t2.user_id and t1.login_dt = t2.order_date;
//endregion =================================================================


//region: 第31题：向所有用户推荐其朋友收藏但是用户自己未收藏的商品

select
    sku_id,
    year(create_date) year_date,
    cast(sum(sku_num*price) as decimal(16,2)) sku_sum
from order_detail_3
group by sku_id,year(create_date);

//endregion =================================================================


//region: 第32题：从订单详情表（order_detail）中查询2021年9月27号-2021年10月3号这一周所有商品每天销售情况。

select
    sku_id,
    sum(if(create_date='2021-09-27',sku_num,0)) monday,
    sum(if(create_date='2021-09-28',sku_num,0)) tuesday,
    sum(if(create_date='2021-09-29',sku_num,0)) wednesday,
    sum(if(create_date='2021-09-30',sku_num,0)) thursday,
    sum(if(create_date='2021-10-01',sku_num,0)) friday,
    sum(if(create_date='2021-10-02',sku_num,0)) saturday,
    sum(if(create_date='2021-10-03',sku_num,0)) sunday
from order_detail_3
where create_date between '2021-09-27' and '2021-10-03'
group by sku_id;

//endregion =================================================================


//region: 第33题：从商品价格变更明细表（sku_price_modify_detail），得到最近一次价格的涨幅情况，并按照涨幅升序排序。

INSERT INTO sku_price_modify_detail_12 (change_date, sku_id, new_price)
VALUES
    ('2021-09-25', 1, 1900.00),
    ('2021-09-26', 1, 2000.00),
    ('2021-09-29', 2, 80.00),
    ('2021-09-30', 2, 10.00),
    ('2021-09-25', 3, 4999.00),
    ('2021-09-26', 3, 5000.00),
    ('2021-09-26', 4, 5600.00),
    ('2021-09-27', 4, 6000.00),
    ('2021-09-27', 5, 490.00),
    ('2021-09-28', 5, 500.00),
    ('2021-09-30', 6, 1988.00),
    ('2021-10-01', 6, 2000.00),
    ('2021-09-28', 7, 88.00),
    ('2021-09-29', 7, 100.00),
    ('2021-09-28', 8, 800.00),
    ('2021-09-29', 8, 600.00),
    ('2021-09-27', 9, 1100.00),
    ('2021-09-28', 9, 1000.00),
    ('2021-10-01', 10, 90.00),
    ('2021-10-02', 10, 100.00),
    ('2021-10-01', 11, 66.00),
    ('2021-10-02', 11, 50.00),
    ('2021-09-28', 12, 35.00),
    ('2021-09-29', 12, 20.00);

with t1 as
(
    select
        sku_id,
        new_price,
        change_date,
        lag(new_price) over (partition by sku_id order by change_date) pre_price,
        row_number() over (partition by sku_id order by change_date) rn,
        cast(new_price - lag(new_price) over (partition by sku_id order by change_date)as decimal(16,2)) price_change
    from sku_price_modify_detail_12
    order by price_change
) select
      sku_id,
      price_change
from t1
group by sku_id,price_change,rn
having rn = max(rn) and price_change is not null
order by price_change;
//endregion =================================================================


//region: 第34题：输出这个用户的id及第一次成功购买手机的日期和第二次成功购买手机的日期，以及购买手机成功的次数。

with t1 as (
    select
        oi4.user_id,
        od3.order_id,
        oi4.create_date,
        dense_rank() over (partition by user_id order by od3.order_id, oi4.create_date) rn
    from order_info_4 oi4 join order_detail_3 od3
    on oi4.order_id = od3.order_id
    where /* user_id = '102' and */ od3.sku_id in (
        select sku_id
        from sku_info_3
        where name in ('xiaomi 10','apple 12','xiaomi 13')
        )
)
select
    user_id,
    min(create_date) first_date,
    max(create_date) last_date,
    count(order_id) order_time
from t1
where rn<=2
group by user_id;
//endregion =================================================================


//region: 第35题：求出同一个商品在2021年和2022年中同一个月的售卖情况对比。

select
    sku_id,
    month(create_date) month,
    sum(if(year(create_date)='2020',sku_num,0)) 2020_skusum,
    sum(if(year(create_date)='2021',sku_num,0)) 2021_skusum
from order_detail_3
group by sku_id,month(create_date);

//endregion =================================================================


//region: 第36题：统计2021国庆期间，每个商品总收藏量和购买量

with t1 as (
    select
        sku_id,
        sum(sku_num) sku_sum
    from order_detail_3
    where create_date between '2021-10-01' and '2021-10-07'
    group by sku_id
),t2 as (
    select
        sku_id,
        count(1) favor_cn
    from favor_info_14
    where create_date between '2021-10-01' and '2021-10-07'
    group by sku_id
)
select
    t1.sku_id,
    nvl(t1.sku_sum,0) as sku_sum,
    nvl(t2.favor_cn,0) as favor_cn
from t1 left join t2 on t1.sku_id = t2.sku_id;

//endregion =================================================================


//region: 第37题：从用户登录明细表中的用户登录时间给各用户分级，求出各等级用户的人数


with t1 as (
    select date_format(max(login_ts),'yyyy-MM-dd') cur_date
    from user_login_detail_8
)
,t2 as (
    select user_id,
           date_format(min(login_ts),'yyyy-MM-dd') first_login,
           date_format(max(login_ts),'yyyy-MM-dd') last_login
    from user_login_detail_8 group by user_id
),t3 as (
    select
        user_id,
        case
            when t2.last_login >= date_sub(t1.cur_date,7) and t2.last_login <= t1.cur_date and t2.first_login < date_sub(t1.cur_date,7) then '忠实用户'
            when t2.first_login between date_sub(t1.cur_date,7) and t1.cur_date then '新增用户'
            when t2.last_login < date_sub(t1.cur_date,7) then '沉睡用户'
            when t2.last_login < date_sub(t1.cur_date,30) then '流失用户'
            end as user_level
    from t2,t1
) select
      user_level level,
      count(1) cn
from t3
group by user_level;



with t1 as (
    select max(login_ts) as cur_date
    from user_login_detail_8
),
     t2 as (
         select user_id,
                case
                    when max(login_ts) between date_sub(t1.cur_date, 6) and t1.cur_date and min(login_ts) < date_sub(t1.cur_date, 6) then '忠实用户'
                    when min(login_ts) between date_sub(t1.cur_date, 6) and t1.cur_date then '新增用户'
                    when max(login_ts) < date_sub(t1.cur_date, 6) then '沉睡用户'
                    when max(login_ts) < date_sub(t1.cur_date, 29) then '流失用户'
                    end as level
         from user_login_detail_8, t1
         group by user_id, t1.cur_date
     )
select level, count(*) as user_count
from t2
group by level;

//endregion =================================================================


//region: 第38题：从用户登录明细表中求出每个用户金币总数，并按照金币总数倒序排序

-- set hive.auto.convert.join=false;
-- set hive.auto.convert.join;

with t1 as (
    select
        user_id,
        date_format(login_ts,'yyyy-MM-dd') login_date,
        row_number() over (partition by user_id order by date_format(login_ts,'yyyy-MM-dd')) rn,
        date_sub(date_format(login_ts,'yyyy-MM-dd'),row_number() over (partition by user_id order by date_format(login_ts,'yyyy-MM-dd'))) date_diff
    from user_login_detail_8
    group by user_id, date_format(login_ts,'yyyy-MM-dd')
),t2 as(
    select
        user_id,
        date_diff,
        row_number() over (partition by user_id,date_diff order by date_diff) rn2
    from t1
)
select
    user_id,
    sum(if(rn2%7=3,3,if(rn2%7=0,7,1))) sum_coin_cn
from t2
group by user_id;


//endregion =================================================================


//region: 第39题：从订单明细表（order_detail）和商品信息表（sku_info）表中求出国庆7天每天每个品类的商品的动销率和滞销率

with t0 as (
  select
      distinct
               si3.category_id,
               od3.create_date,
               od3.sku_id
    from order_detail_3 od3 join sku_info_3 si3
    on od3.sku_id = si3.sku_id
    where od3.create_date between '2021-10-01' and '2021-10-07'
),t1 as (
    select
        category_id,
        count(1) cate_cn
    from sku_info_3
    group by category_id
),t2 as (
    select
        category_id,
        sum(if(t0.create_date='2021-10-01',1,0)) first,
        sum(if(t0.create_date='2021-10-02',1,0)) second,
        sum(if(t0.create_date='2021-10-03',1,0)) third,
        sum(if(t0.create_date='2021-10-04',1,0)) fourth,
        sum(if(t0.create_date='2021-10-05',1,0)) fifth,
        sum(if(t0.create_date='2021-10-06',1,0)) sixth,
        sum(if(t0.create_date='2021-10-07',1,0)) seventh
    from t0
    group by t0.category_id
)
select
    t1.category_id,
    cast(t2.first/t1.cate_cn as decimal(16,2)) first_sale_rate,
    1-cast(t2.first/t1.cate_cn as decimal(16,2)) first_unsale_rate,
    cast(t2.second/t1.cate_cn as decimal(16,2)) second_sale_rate,
    1-cast(t2.second/t1.cate_cn as decimal(16,2)) second_unsale_rate,
    cast(t2.third/t1.cate_cn as decimal(16,2)) third_sale_rate,
    1-cast(t2.third/t1.cate_cn as decimal(16,2)) third_unsale_rate,
    cast(t2.fourth/t1.cate_cn as decimal(16,2)) fourth_sale_rate,
    1-cast(t2.fourth/t1.cate_cn as decimal(16,2)) fourth_unsale_rate,
    cast(t2.fifth/t1.cate_cn as decimal(16,2)) fifth_sale_rate,
    1-cast(t2.fifth/t1.cate_cn as decimal(16,2)) fifth_unsale_rate,
    cast(t2.sixth/t1.cate_cn as decimal(16,2)) six_sale_rate,
    1-cast(t2.sixth/t1.cate_cn as decimal(16,2)) sixth_unsale_rate,
    cast(t2.seventh/t1.cate_cn as decimal(16,2)) seventh_sale_rate,
    1-cast(t2.seventh/t1.cate_cn as decimal(16,2)) seventh_unsale_rate
from t1 join t2
on t1.category_id = t2.category_id;

//endregion =================================================================


//region: 第40题：根据用户登录明细表（user_login_detail），求出平台同时在线最多的人数。
select
    max(max_login_cnt)
from(
    select sum(flag) over (order by l_time) max_login_cnt
    from(
        select
            login_ts l_time,
            1 flag
        from user_login_detail_8
        union all
        select
            logout_ts r_time,
            -1 flag
        from user_login_detail_8
    )t1
)t2;
//endregion =================================================================
