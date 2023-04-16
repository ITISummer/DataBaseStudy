set hive.exec.mode.local.auto=true;
set hive.exec.mode.local.auto;
use zjcs;
/*
 2.21 从登录明细表（user_login_detail）中查询每个用户两个登录日期（以login_ts为准）之间的最大的空档期。
 统计最大空档期时， 用户最后一次登录至今的空档也要考虑在内，假设今天为2021-10-10
*/
select uld.user_id,
       min(uld.login_ts) min_date,
       max(uld.login_ts) max_date,
       datediff(date_format(max(uld.login_ts),'yyyy-MM-dd'),date_format(min(uld.login_ts),'yyyy-MM-dd')) min_max_date_diff,
       datediff('2021-10-10',date_format(max(uld.login_ts),'yyyy-MM-dd')) max_now_date_diff
from user_login_detail uld
group by uld.user_id;

/*
 2.22 从登录明细表（user_login_detail）中查询在相同时刻，多地登录（ip_address不同）的用户
*/
-- 答案
select
    distinct t2.user_id
from
    (
        select
            t1.user_id,
            if(t1.max_logout is null ,2,if(t1.max_logout<t1.login_ts,1,0)) flag
        from
            (
                select
                    user_id,
                    login_ts,
                    logout_ts,
                    max(logout_ts)over(partition by user_id order by login_ts rows between unbounded preceding and 1 preceding) max_logout
                from
                    user_login_detail
            )t1
    )t2
where
        t2.flag=0;

/*
 2.23 商家要求每个商品每个月需要售卖出一定的销售总额（任务总额）
假设1号商品销售总额大于21000，2号商品销售总额大于10000，其余商品没有要求
请写出SQL从订单详情表中（order_detail）查询连续两个月销售总额大于等于任务总额的商品
*/
select t2.sku_id, add_months(t2.ym,-rn) rym, count(1) cnt
from
    (
        select t1.sku_id,t1.ym,
               row_number() over (partition by t1.sku_id order by t1.ym) rn
        from
            (
                -- 求出1号商品  和  2号商品 每个月的购买总额 并过滤掉没有满足指标的商品
                select od.sku_id,sum(od.price*od.sku_num) month_price_total, concat(substr(od.create_date,0,7),'-01') ym
                from order_detail od
                where od.sku_id='1' or od.sku_id='2'
                group by od.sku_id,substr(od.create_date,0,7),'-01'
                having (sku_id=1 and month_price_total>=21000) or (sku_id=2 and month_price_total>=10000)
            )t1
    )t2
group by t2.sku_id,add_months(t2.ym,-rn)
having cnt>1;

/*
 2.24
从订单详情表中（order_detail）对销售件数对商品进行分类，
 0-5000为冷门商品，5001-19999位一般商品，20000往上为热门商品，
 并求出不同类别商品的数量
 */

select t2.label,count(1) cnt
from
    (
        select t1.sku_id,
               case
                   when t1.sum_sku_num>=0 and t1.sum_sku_num<=5000 then '冷门商品'
                   when t1.sum_sku_num>=5001 and t1.sum_sku_num<=19999 then '一般商品'
                   when t1.sum_sku_num>=20000 then '热门商品'
                   end label
        from
            (
                select od.sku_id,sum(od.sku_num) sum_sku_num
                from order_detail od
                group by od.sku_id
            )t1
    )t2
group by t2.label;

/*
 2.25 从订单详情表中（order_detail）和商品（sku_info）中查询各个品类销售数量前三的商品。
 如果该品类小于三个商品，则输出所有的商品销量
 */
select t1.category_id,t1.sku_id
from
    (
        select si.category_id,od.sku_id,si.name,sum(od.sku_num) sum_sku_num,
               rank() over (partition by si.category_id order by sum(od.sku_num) desc) rk
        from
            order_detail od join sku_info si on od.sku_id = si.sku_id
        group by si.category_id, od.sku_id, si.name
    )t1
where rk<=3;

/*
 2.26 从商品（sku_info）中求中位数如果是偶数则输出中间两个值的平均值，如果是奇数，则输出中位数即可
 */
select t1.category_id,
       if(size(t1.prices)%2=0,(prices[cast(size(t1.prices)/2 as int)-1]+prices[cast(size(t1.prices)/2 as int)])/2,prices[cast(size(t1.prices)/2 as int)-1])
from
(
    select si.category_id,sort_array(collect_list(si.price)) prices
    from sku_info si
    group by si.category_id
)t1;

-- 答案
--求个每个品类 价格排序 商品数量 以及打上奇偶数的标签
select
  sku_id,
  category_id,
  price,
  row_number()over(partition by category_id order by price desc) rk,
  count(*)over(partition by category_id) cn,
  count(*)over(partition by category_id)%2 falg
from
  sku_info  t1;

--求出偶数品类的中位数
select
  distinct t1.category_id,
  avg(t1.price)over(partition by t1.category_id) medprice
from
  (
    select
    sku_id,
    category_id,
    price,
    row_number()over(partition by category_id order by price desc) rk,
    count(*)over(partition by category_id) cn,
    count(*)over(partition by category_id)%2 falg
    from
    sku_info
  )t1
where
  t1.falg=0 and (t1.rk=cn/2  or t1.rk=cn/2+1);

--求出奇数品类的中位数
select
  t1.category_id,
  t1.price
from
  (
    select
    sku_id,
    category_id,
    price,
    row_number()over(partition by category_id order by price desc) rk,
    count(*)over(partition by category_id) cn,
    count(*)over(partition by category_id)%2 falg
    from
    sku_info
  )t1
where
  t1.falg=1 and t1.rk=round(cn/2);

-- 竖向拼接
select
  distinct t1.category_id,
  avg(t1.price)over(partition by t1.category_id) medprice
from
  (
    select
    sku_id,
    category_id,
    price,
    row_number()over(partition by category_id order by price desc) rk,
    count(*)over(partition by category_id) cn,
    count(*)over(partition by category_id)%2 falg
    from
    sku_info
  )t1
where
  t1.falg=0 and (t1.rk=cn/2  or t1.rk=cn/2+1)

union

select
  t1.category_id,
  t1.price/1
from
  (
    select
    sku_id,
    category_id,
    price,
    row_number()over(partition by category_id order by price desc) rk,
    count(*)over(partition by category_id) cn,
    count(*)over(partition by category_id)%2 falg
    from
    sku_info
  )t1
where
  t1.falg=1 and t1.rk=round(cn/2);

/*
 2.27 从订单详情表（order_detail）中找出销售额连续3天超过100的商品
 */
 select t1.sku_id,count(1) cnt
from
(
    select od.sku_id,od.create_date,sum(od.sku_num*od.price) sum_sku_num,
       row_number() over (partition by od.sku_id order by create_date,sum(od.sku_num*od.price)) rn,
        date_sub(od.create_date,row_number() over (partition by od.sku_id order by create_date,sum(od.sku_num*od.price))) flag
    from order_detail od
    group by od.sku_id,od.create_date
    having sum_sku_num>100
)t1
group by t1.sku_id,t1.flag
having cnt>=3;

/*
 2.28 从用户登录明细表（user_login_detail）中首次登录算作当天新增，第二天也登录了算作一日留存
 */
select t1.login_ts,count(1) cnt,
       sum(if(t1.flag1==1,1,0)) person,
       sum(if(t1.flag1==1,1,0))/count(1) retention
from
(
    select uld.user_id,date_format(uld.login_ts,'yyyy-MM-dd') login_ts,
           datediff(lead(uld.login_ts,1,null) over (partition by uld.user_id order by uld.login_ts),uld.login_ts) flag1,
           row_number() over (partition by uld.user_id order by uld.login_ts) flag2
    from user_login_detail uld
)t1
where flag2==1
group by t1.login_ts;

/*
 2.29 TODO 待完善，从订单详情表（order_detail）中，求出商品连续售卖的时间区间
 */
select t1.sku_id,
        min(t1.create_date) start_date,
        max(t1.create_date) end_date
from
(
    select od.sku_id,od.create_date,
            date_sub(od.create_date,row_number() over (partition by od.sku_id order by od.create_date)) flag
    from order_detail od
    group by od.sku_id, od.create_date
)t1
group by t1.sku_id,t1.flag;

/*
 2.30 分别从登录明细表（user_login_detail）和配送信息表(delivery_info)中用户登录时间和下单时间统计登录次数和交易次数
 注意点：
 1. 在 count() 里面指定统计某字段时，如果该字段为空则该字段所在行不会被统计，如果直接count(1)，则该行会被统计
 2. 处理 group by 后面没有的字段时，可利用聚合函数，比如 collect_set() 或者 collect_list(), sum() 等聚合函数
*/
select t1.user_id,t1.login_date,
       collect_list(t1.login_count)[0] login_count,
       count(di.user_id) order_count
from
(
    select uld.user_id,date_format(uld.login_ts,'yyyy-MM-dd') login_date,count(1) login_count
    from user_login_detail uld
    group by uld.user_id,date_format(uld.login_ts,'yyyy-MM-dd')
)t1
left join delivery_info di on t1.user_id=di.user_id and t1.login_date=di.order_date
group by t1.user_id, t1.login_date;

/*
 2.31 从订单明细表（order_detail）中列出每个商品每个年度的购买总额
 */
select od.sku_id,year(od.create_date) year_date, sum(od.sku_num*od.price) year_amount
from order_detail od
group by od.sku_id,year(od.create_date);

/*
 2.32 从订单详情表（order_detail）中查询2021年9月27号-2021年10月3号这一周所有商品每天销售情况
 */
select od.sku_id,
       sum(if(`dayofweek`(od.create_date)=2,od.sku_num,0)) Monday,
       sum(if(`dayofweek`(od.create_date)=3,od.sku_num,0)) Tuesday,
       sum(if(`dayofweek`(od.create_date)=4,od.sku_num,0)) Wednesday,
       sum(if(`dayofweek`(od.create_date)=5,od.sku_num,0)) Thurseday,
       sum(if(`dayofweek`(od.create_date)=6,od.sku_num,0)) Friday,
       sum(if(`dayofweek`(od.create_date)=7,od.sku_num,0)) Saturday,
       sum(if(`dayofweek`(od.create_date)=1,od.sku_num,0)) Sunday
from order_detail od
where od.create_date between '2021-09-27' and '2021-10-03'
group by od.sku_id;

/*
 2.33 从商品价格变更明细表（sku_price_modify_detail），得到最近一次价格的涨幅情况，并按照涨幅升序排序
 */
desc function extended lag;
desc function extended lead;

select t1.sku_id,t1.new_price-t1.last_price price_change
from
(
select spmd.sku_id,spmd.change_date,spmd.new_price,
    lead(spmd.new_price,1,null) over(partition by spmd.sku_id order by spmd.change_date desc) last_price
from sku_price_modify_detail spmd
)t1
where t1.last_price is not null
order by price_change;

/*
 2.34 通过商品信息表（sku_info）订单信息表（order_info）订单明细表（order_detail）
 分析如果有一个用户成功下单两个及两个以上的购买成功的手机订单 （购买商品为xiaomi 10，apple 12，xiaomi 13）
 那么输出这个用户的id及第一次成功购买手机的日期和第二次成功购买手机的日期，以及购买手机成功的次数
 */
select t2.user_id,min(t2.create_date) first_date,max(t2.create_date) second_date,sum(t2.cnt) count
from
(
    select oi.user_id,t1.order_id,t1.create_date,count(t1.sku_id) cnt,
           row_number() over (partition by oi.user_id order by t1.create_date) rn
    from
    (
        select od.order_id,od.sku_id,od.create_date
        from order_detail od
        where od.sku_id in (1,3,4)
    )t1 join order_info oi on t1.order_id=oi.order_id
    group by oi.user_id, t1.order_id,t1.create_date
)t2
where rn<=2
group by t2.user_id;

/*
 2.35 从订单明细表（order_detail）中求出同一个商品在2021年和2022年中同一个月的售卖情况对比
 */
select od.sku_id,month(od.create_date) Month,
       sum(`if`(year(od.create_date)=2020,sku_num,0)) 2020_skusum,
       sum(`if`(year(od.create_date)=2021,sku_num,0)) 2021_skusum
from order_detail od
where year(od.create_date) between 2020 and 2021
group by od.sku_id,month(od.create_date);

/*
 2.36 从订单明细表（order_detail）和收藏信息表（favor_info）统计2021国庆期间，每个商品总收藏量和购买量
 */
select t1.sku_id,t1.sum_sku_num,nvl(t2.favor_cnt,0)
from
(
select od.sku_id,sum(od.sku_num) sum_sku_num
from order_detail od
where od.create_date between '2021-10-01' and '2021-10-07'
group by od.sku_id
)t1
full join
(
select ri.sku_id,count(1) favor_cnt
from favor_info ri
where ri.create_date between '2021-10-01' and '2021-10-07'
group by ri.sku_id
)t2
on t1.sku_id=t2.sku_id;


/*
2.37
用户等级：
    新增用户：近7天新增
    沉睡用户：近7天未活跃但是在7天前活跃
    流失用户：近30天未活跃但是在30天前活跃
    忠实用户：近7天活跃且非新用户
假设今天是数据中所有日期的最大值，从用户登录明细表中的用户登录时间给各用户分级，求出各等级用户的人数
 */
 select t2.level,count(1) cnt
from
(
    select uld.user_id,
           case
               when (date_format(max(uld.login_ts),'yyyy-MM-dd') <=date_sub(today, 30))
                   then '流失用户'-- 最近登录时间三十天前
               when (date_format(min(uld.login_ts),'yyyy-MM-dd') <=date_sub(today, 7) and date_format(max(uld.login_ts),'yyyy-MM-dd') >=date_sub(today, 7))
                   then '忠实用户' -- 最早登陆时间是七天前,并且最近七天登录过
               when (date_format(min(uld.login_ts),'yyyy-MM-dd') >=date_sub(today, 7))
                   then '新增用户' -- 最早登录时间是七天内
               when (date_format(min(uld.login_ts),'yyyy-MM-dd') <= date_sub(today, 7) and date_format(max(uld.login_ts),'yyyy-MM-dd') <= date_sub(today, 7))
                   then '沉睡用户'-- 最早登陆时间是七天前,最大登录时间也是七天前
               end level
    from user_login_detail uld join
    (
        select date_format(max(uld.login_ts),'yyyy-MM-dd') today
        from user_login_detail uld
    )t1
    on 1=1
    group by uld.user_id,t1.today
)t2
 group by t2.level;

/*
2.38 - TODO 难
用户每天签到可以领1金币，并可以累计签到天数，连续签到的第3、7天分别可以额外领2和6金币。
每连续签到7天重新累积签到天数。
从用户登录明细表中求出每个用户金币总数，并按照金币总数倒序排序
*/
-- 求出每个用户的金币总数（答案）
select
    t3.user_id,
    sum(t3.coin_cn) sum_coin_cn
from
    (
        -- 按用户id，登录日期分组统计金币数量
        select
            t2.user_id,
            max(t2.counti_cn)+sum(if(t2.counti_cn%3=0,2,0))+sum(if(t2.counti_cn%7=0,6,0)) coin_cn
        from
            (
                -- 求连续并标志是连续的第几天
                select
                    t1.user_id,
                    t1.login_date,
                    date_sub(t1.login_date,t1.rk) login_date_rk,
                    count(*)over(partition by t1.user_id, date_sub(t1.login_date,t1.rk) order by t1.login_date) counti_cn
                from
                    (
                        -- 按用户id和登录日期分组统计
                        select
                            user_id,
                            date_format(login_ts,'yyyy-MM-dd') login_date,
                            rank()over(partition by user_id order by date_format(login_ts,'yyyy-MM-dd')) rk
                        from
                            user_login_detail
                        group by
                            user_id,date_format(login_ts,'yyyy-MM-dd')
                    )t1
            )t2
        group by
            t2.user_id,t2.login_date_rk
    )t3
group by
    t3.user_id
order by
    sum_coin_cn desc;


/*
 2.39
动销率定义为品类商品中一段时间内有销量的商品占当前已上架总商品数的比例（有销量的商品/已上架总商品数）。
滞销率定义为品类商品中一段时间内没有销量的商品占当前已上架总商品数的比例。（没有销量的商品/已上架总商品数）。

只要当天任一店铺有任何商品的销量就输出该天的结果
从订单明细表（order_detail）和商品信息表（sku_info）表中求出国庆7天每天每个品类的商品的动销率和滞销率
 */

-- 每一天的动销率 和 滞销率
select
    t2.category_id,
    t2.`第1天`/t3.cn,
    1-t2.`第1天`/t3.cn,
    t2.`第2天`/t3.cn,
    1-t2.`第2天`/t3.cn,
    t2.`第3天`/t3.cn,
    1-t2.`第3天`/t3.cn,
    t2.`第4天`/t3.cn,
    1-t2.`第4天`/t3.cn,
    t2.`第5天`/t3.cn,
    1-t2.`第5天`/t3.cn,
    t2.`第6天`/t3.cn,
    1-t2.`第6天`/t3.cn,
    t2.`第7天`/t3.cn,
    1-t2.`第7天`/t3.cn
from
    (
        select
            t1.category_id,
            sum(if(t1.create_date='2021-10-01',1,0)) `第1天`,
            sum(if(t1.create_date='2021-10-02',1,0)) `第2天`,
            sum(if(t1.create_date='2021-10-03',1,0)) `第3天`,
            sum(if(t1.create_date='2021-10-04',1,0)) `第4天`,
            sum(if(t1.create_date='2021-10-05',1,0)) `第5天`,
            sum(if(t1.create_date='2021-10-06',1,0)) `第6天`,
            sum(if(t1.create_date='2021-10-07',1,0)) `第7天`
        from
            (
                -- 求出各分类上架的商品数
                select
                    distinct
                    si.category_id,
                    od.create_date,
                    si.name
                from order_detail od join sku_info si on od.sku_id=si.sku_id
                where od.create_date between '2021-10-01' and '2021-10-07'
            )t1
        group by t1.category_id
    )t2
        join
    (
        select
            category_id,
            count(*) cn
        from
            sku_info
        group by
            category_id
    )t3
    on
            t2.category_id=t3.category_id;


-- 查询每个品类下商品上架数量
select si.category_id, count(1) cnt
from sku_info si
group by si.category_id
