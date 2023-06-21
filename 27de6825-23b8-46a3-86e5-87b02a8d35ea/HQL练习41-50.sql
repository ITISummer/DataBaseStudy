//region: 第n题：向所有用户推荐其朋友收藏但是用户自己未收藏的商品
//endregion =================================================================


//region: 第41题：现要求统计各直播间最大同时在线人数

CREATE TABLE live_events_41 (
    user_id STRING COMMENT '用户id',
    live_id STRING COMMENT '直播间id',
    in_datetime STRING COMMENT '进入直播间的时间',
    out_datetime STRING COMMENT '离开直播间的时间'
)
    COMMENT '直播信息表'
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
    STORED AS TEXTFILE;


INSERT INTO TABLE live_events_41
(live_id, user_id, out_datetime, in_datetime)
VALUES
    (1, '100', '2021-12-01 19:28:00', '2021-12-01 19:00:00'),
    (1, '100', '2021-12-01 19:53:00', '2021-12-01 19:30:00'),
    (2, '100', '2021-12-01 22:00:00', '2021-12-01 21:01:00'),
    (1, '101', '2021-12-01 20:55:00', '2021-12-01 19:05:00'),
    (2, '101', '2021-12-01 21:58:00', '2021-12-01 21:05:00'),
    (1, '102', '2021-12-01 19:25:00', '2021-12-01 19:10:00'),
    (2, '102', '2021-12-01 21:00:00', '2021-12-01 19:55:00'),
    (3, '102', '2021-12-01 22:05:00', '2021-12-01 21:05:00'),
    (1, '104', '2021-12-01 20:59:00', '2021-12-01 19:00:00'),
    (2, '104', '2021-12-01 22:56:00', '2021-12-01 21:57:00'),
    (2, '105', '2021-12-01 19:18:00', '2021-12-01 19:10:00'),
    (3, '106', '2021-12-01 21:10:00', '2021-12-01 19:01:00');


with t1 as (
    select
        live_id,
        in_datetime in_time,
        1 flag
    from live_events_41
    union all
    select
        live_id,
        out_datetime out_time,
        -1 flag
    from live_events_41
),t2 as (
    select
        live_id,
        sum(flag) over (partition by live_id order by in_time) online_person
    from t1
)
select live_id,max(online_person) max_online_person
from t2
group by live_id;

//endregion =================================================================


//region: 第42题：为属于同一会话的访问记录增加一个相同的会话id字段

CREATE TABLE page_view_events_42 (
    user_id STRING COMMENT '用户id',
    page_id STRING COMMENT '页面id',
    view_timestamp BIGINT COMMENT '访问时间戳'
)
    COMMENT '页面浏览记录表'
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
    STORED AS TEXTFILE;


INSERT INTO page_view_events_42 (page_id, view_timestamp, user_id)
VALUES
    ('home', 1659950435, 100),
    ('good_search', 1659950446, 100),
    ('good_list', 1659950457, 100),
    ('home', 1659950541, 100),
    ('good_detail', 1659950552, 100),
    ('cart', 1659950563, 100),
    ('home', 1659950435, 101),
    ('good_search', 1659950446, 101),
    ('good_list', 1659950457, 101),
    ('home', 1659950541, 101),
    ('good_detail', 1659950552, 101),
    ('cart', 1659950563, 101),
    ('home', 1659950435, 102),
    ('good_search', 1659950446, 102),
    ('good_list', 1659950457, 102),
    ('home', 1659950541, 103),
    ('good_detail', 1659950552, 103),
    ('cart', 1659950563, 103);


with t1 as (
    select
        user_id,
        page_id,
        cast(view_timestamp as bigint) as view_timestamp,
--         cast(view_timestamp as bigint)*1000 as view_timestamp,
--         nvl(lag(view_timestamp) over (partition by user_id order by cast(view_timestamp as bigint)),
--             lead(view_timestamp) over (partition by user_id order by cast(view_timestamp as bigint))
--             )*1000 timestamp_in_60
            lag(view_timestamp,1,0) over (partition by user_id order by cast(view_timestamp as bigint)) last_view_timestamp
    from page_view_events_42
),t2 as (
   select
        user_id,
        page_id,
        view_timestamp,
--         abs(unix_timestamp(from_utc_timestamp(view_timestamp,'Asia/Shanghai')) - unix_timestamp(from_utc_timestamp(timestamp_in_60,'Asia/Shanghai')))
        if(view_timestamp-last_view_timestamp>60,1,0) flag
    from t1
)
select
    user_id,
    page_id,
    view_timestamp,
    concat(user_id,'-',sum(flag) over (partition by user_id order by view_timestamp )) session_id
from t2;

-- 别人的解析
SELECT
	user_id,
        page_id,
        view_timestamp,
        concat(user_id,"-",flag) session_id
from(
    SELECT
        user_id,
        page_id,
        view_timestamp,
        sum(flag) over(PARTITION by user_id ORDER by view_timestamp) flag
    from(
        SELECT
            user_id,
            page_id,
            view_timestamp,
            --打标签，本次page的时间戳减去上个页面的时间戳，如果大于60秒，证明本次page是会话的初始page，打上一个1的标签
            IF(view_timestamp-last_view_timestamp>60,1,0) flag
        from(
            SELECT
                  user_id,
                  page_id,
                  view_timestamp,
                  --取出上一个page页面的时间戳
                  lag(view_timestamp,1,0) over(PARTITION by user_id order by view_timestamp ) last_view_timestamp
            FROM page_view_events_42
        )t1
    )t2
)t3;


-- SELECT (unix_timestamp(from_utc_timestamp(1659950435000,'Asia/Shanghai')) - unix_timestamp(from_utc_timestamp(1659950446000,'Asia/Shanghai'))) AS diff_seconds;
//endregion =================================================================


//region: 第43题：现要求统计各用户最长的连续登录天数，间断一天也算作连续

CREATE TABLE login_events_43 (
    user_id INT COMMENT '用户id',
    login_datetime STRING COMMENT '登录时间'
)
COMMENT '用户登录日志表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;


INSERT INTO login_events_43 (login_datetime, user_id) VALUES
           ('2021-12-01 19:00:00', '100'),
           ('2021-12-01 19:30:00', '100'),
           ('2021-12-02 21:01:00', '100'),
           ('2021-12-03 11:01:00', '100'),
           ('2021-12-01 19:05:00', '101'),
           ('2021-12-01 21:05:00', '101'),
           ('2021-12-03 21:05:00', '101'),
           ('2021-12-05 15:05:00', '101'),
           ('2021-12-06 19:05:00', '101'),
           ('2021-12-01 19:55:00', '102'),
           ('2021-12-01 21:05:00', '102'),
           ('2021-12-02 21:57:00', '102'),
           ('2021-12-03 19:10:00', '102'),
           ('2021-12-04 21:57:00', '104'),
           ('2021-12-02 22:57:00', '104'),
           ('2021-12-01 10:01:00', '105');

with t0 as (
    select
        user_id,
        date_format(login_datetime,'yyyy-MM-dd') as login_datetime
    from login_events_43
),t1 as (
    select
        user_id,
        login_datetime login_date,
        lag(login_datetime,1,login_datetime) over(partition by user_id order by login_datetime) pre_login_datetime,
        datediff(login_datetime,lag(login_datetime,1,login_datetime) over(partition by user_id order by login_datetime)) date_diff,
        if(datediff(login_datetime,lag(login_datetime,1,login_datetime) over(partition by user_id order by login_datetime))>2,1,0) flag
    from t0
    group by user_id, login_datetime
),t2 as (
    select
        user_id,
        login_date,
        date_diff,
        concat(user_id,'-',sum(flag) over (partition by user_id order by login_date)) flag_id
    from t1
),t3 as (
    select
        user_id,
        sum(date_diff) sum_date
    from t2
    group by user_id,flag_id
)
SELECT
    user_id,
    max(sum_date)+1 max_day_count
from t3
GROUP by user_id;


//endregion =================================================================


//region: 第44题：现要求统计每个品牌的优惠总天数，若某个品牌在同一天有多个优惠活动，则只按一天计算

drop table if exists promotion_info_44;
create table promotion_info_44
(
    promotion_id string comment '优惠活动id',
    brand        string comment '优惠品牌',
    start_date   string comment '优惠活动开始日期',
    end_date     string comment '优惠活动结束日期'
) comment '各品牌活动周期表';

insert overwrite table promotion_info_44
values (1, 'oppo', '2021-06-05', '2021-06-09'),
       (2, 'oppo', '2021-06-11', '2021-06-21'),
       (3, 'vivo', '2021-06-05', '2021-06-15'),
       (4, 'vivo', '2021-06-09', '2021-06-21'),
       (5, 'redmi', '2021-06-05', '2021-06-21'),
       (6, 'redmi', '2021-06-09', '2021-06-15'),
       (7, 'redmi', '2021-06-17', '2021-06-26'),
       (8, 'huawei', '2021-06-05', '2021-06-26'),
       (9, 'huawei', '2021-06-09', '2021-06-15'),
       (10, 'huawei', '2021-06-17', '2021-06-21');

with t1 as (
    select
        brand,
        start_date,
        end_date,
        max(end_date) over (partition by brand order by start_date rows between unbounded preceding and 1 preceding ) max_end_date
    from promotion_info_44
),t2 as (
    select
        brand,
        max_end_date,
        if(max_end_date is null  or start_date > max_end_date,start_date,date_add(max_end_date,1)) as start_date,
        end_date
    from t1
)
select
    brand,
    sum(datediff(end_date,start_date)+1) promotion_day_count
    from t2
where end_date>start_date
group by brand;
//endregion =================================================================


//region: 第45题：复购率指用户在一段时间内对某商品的重复购买比例，复购率越大，则反映出消费者对品牌的忠诚度就越高，也叫回头率


CREATE TABLE order_detail_45 (
    order_date STRING COMMENT '下单日期',
    user_id STRING COMMENT '用户id',
    price STRING COMMENT '产品价格',
    product_id STRING COMMENT '产品id',
    cnt STRING COMMENT '产品购买数量',
    order_id STRING COMMENT '订单id'
)
COMMENT '订单详情表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;


INSERT INTO order_detail_45 (order_date, user_id, price, product_id, cnt, order_id) VALUES
     ('2022-01-01', '1', '5000', '1', '1', '1'),
     ('2022-01-02', '1', '5500', '3', '1', '2'),
     ('2022-02-01', '1', '35', '7', '2', '3'),
     ('2022-03-03', '2', '3800', '2', '3', '4'),
     ('2022-03-04', '2', '80', '5', '1', '5'),
     ('2022-02-05', '2', '45', '8', '3', '6'),
     ('2022-02-04', '3', '5500', '3', '1', '7'),
     ('2022-01-02', '3', '10', '6', '2', '8'),
     ('2022-02-03', '3', '20', '9', '3', '9'),
     ('2022-01-04', '4', '3800', '2', '4', '10'),
     ('2022-03-02', '4', '35', '7', '1', '11'),
     ('2022-02-05', '4', '45', '8', '1', '12'),
     ('2022-03-04', '5', '35', '7', '2', '13'),
     ('2022-03-05', '5', '45', '8', '4', '14'),
     ('2022-02-05', '5', '20', '9', '2', '15'),
     ('2022-02-04', '1', '5000', '1', '1', '16'),
     ('2022-03-03', '1', '3800', '2', '2', '17'),
     ('2022-03-05', '1', '45', '8', '3', '18'),
     ('2022-04-05', '2', '80', '5', '4', '19'),
     ('2022-02-06', '2', '35', '7', '5', '20'),
     ('2022-02-06', '2', '45', '8', '1', '21'),
     ('2022-02-08', '3', '5500', '3', '2', '22'),
     ('2022-02-07', '3', '80', '5', '2', '23'),
     ('2022-03-04', '3', '20', '9', '3', '24'),
     ('2022-01-07', '4', '3800', '2', '4', '25'),
     ('2022-02-05', '4', '80', '5', '2', '26'),
     ('2022-02-06', '4', '10', '6', '1', '27'),
     ('2022-02-05', '5', '35', '7', '2', '28'),
     ('2022-03-06', '5', '45', '8', '3', '29'),
     ('2022-03-06', '5', '20', '9', '4', '30');


with t1 as (
    select
        max(order_date)  max_order_date -- 2022-04-05
    from order_detail_45
),t2 as (
   select
       product_id,
       user_id,
       order_date,
       row_number() over (partition by product_id,user_id order by order_date) rn
    from order_detail_45 join t1 on 1=1
    where datediff(max_order_date,order_date) < 90
),t3 as (
   select
       product_id,
       count(distinct user_id) total_person,
       sum(if(rn>1,1,0)) return_person,
       cast(sum(if(rn>1,1,0))/count(distinct user_id) as decimal(16,2)) cpr
    from t2
    group by product_id
)
select
    product_id,
    cpr
from t3
order by cpr desc,product_id;

//endregion =================================================================


//region: 第46题：注：出勤率指用户看直播时间超过40分钟，求出每个课程的出勤率（结果保留两位小数）


-- 创建表 user_login_46
CREATE TABLE user_login_46 (
    user_id STRING COMMENT '用户id',
    course_id STRING COMMENT '课程id',
    login_in STRING COMMENT '登录时间',
    login_out STRING COMMENT '登出时间'
) COMMENT '用户登录信息表';

-- 插入数据
INSERT INTO user_login_46 (course_id, login_out, user_id, login_in)
VALUES
    ('1', '2022-06-02 10:09:36', '1', '2022-06-02 09:08:24'),
    ('1', '2022-06-02 11:44:21', '1', '2022-06-02 11:07:24'),
    ('2', '2022-06-02 14:21:50', '1', '2022-06-02 13:50:24'),
    ('2', '2022-06-02 15:30:20', '2', '2022-06-02 13:50:10'),
    ('3', '2022-06-02 18:30:40', '2', '2022-06-02 18:10:10'),
    ('1', '2022-06-02 11:09:36', '3', '2022-06-02 09:07:24'),
    ('2', '2022-06-02 15:20:26', '3', '2022-06-02 14:00:00'),
    ('3', '2022-06-02 18:59:40', '4', '2022-06-02 18:10:10'),
    ('3', '2022-06-02 18:59:40', '5', '2022-06-02 18:30:10'),
    ('2', '2022-06-02 14:11:50', '6', '2022-06-02 13:50:24');


-- 创建表 course_apply_46
CREATE TABLE course_apply_46 (
     course_id STRING COMMENT '课程id',
     course_name STRING COMMENT '课程名称',
     user_id ARRAY<STRING> COMMENT '用户id'
) COMMENT '课程报名表';

-- 插入数据
INSERT INTO course_apply_46 (course_id, course_name, user_id)
VALUES
    ('1', 'java', ARRAY('1', '2', '3', '4', '5', '6')),
    ('2', '大数据', ARRAY('1', '2', '3', '6')),
    ('3', '前端', ARRAY('2', '3', '4', '5'));


with t1 as (
    select
        user_id,
        course_id,
        cast((unix_timestamp(login_out) - unix_timestamp(login_in)) / 60 as int) duration
    from user_login_46
),t2 as (
   select
       course_id,
       collect_set(user_id) user_cnt
   from t1
   where duration>=40
   group by course_id
),t3 as (
    select
        ca.course_id,
        cast((size(t2.user_cnt) / size(ca.user_id)) as decimal(16,2)) adr
    from t2 join course_apply_46 ca on t2.course_id = ca.course_id
)
select
    *
from t3;

//endregion =================================================================


//region: 第47题：统计周一到周五各时段的叫车量、平均等待接单时间和平均调度时间,全部以event_time-开始打车时间为时段划分依据


-- 创建表 get_car_record_47
CREATE TABLE get_car_record_47 (
    uid STRING COMMENT '用户id',
    city STRING COMMENT '城市',
    end_time STRING COMMENT '结束时间:取消或者接单',
    order_id STRING COMMENT '订单id',
    event_time STRING COMMENT '下单时间'
) COMMENT '用户下单表';

-- 插入数据
INSERT INTO get_car_record_47 (uid, city, end_time, order_id, event_time)
VALUES
    ('107', '北京', '2021-09-20 11:00:30', '9017', '2021-09-20 11:00:00'),
    ('108', '北京', '2021-09-20 21:00:40', '9008', '2021-09-20 21:00:00'),
    ('108', '北京', '2021-09-20 19:01:00', '9018', '2021-09-20 18:59:30'),
    ('102', '北京', '2021-09-21 09:01:00', '9002', '2021-09-21 08:59:00'),
    ('106', '北京', '2021-09-21 18:01:00', '9006', '2021-09-21 17:58:00'),
    ('103', '北京', '2021-09-22 08:01:00', '9003', '2021-09-22 07:58:00'),
    ('104', '北京', '2021-09-23 08:01:00', '9004', '2021-09-23 07:59:00'),
    ('103', '北京', '2021-09-24 20:01:00', '9019', '2021-09-24 19:59:20'),
    ('101', '北京', '2021-09-24 08:30:00', '9011', '2021-09-24 08:28:10');


-- 创建表 get_car_order_47
CREATE TABLE get_car_order_47 (
    order_id STRING COMMENT '订单id',
    uid STRING COMMENT '用户id',
    driver_id STRING COMMENT '司机id',
    order_time STRING COMMENT '接单时间',
    start_time STRING COMMENT '开始时间',
    finish_time STRING COMMENT '结束时间',
    fare STRING COMMENT '费用',
    grade STRING COMMENT '评分'
) COMMENT '司机订单信息表';

-- 插入数据
INSERT INTO get_car_order_47 (order_id, uid, driver_id, order_time, start_time, finish_time, fare, grade)
VALUES
    ('9017', '107', '213', '2021-09-20 11:00:30', '2021-09-20 11:02:10', '2021-09-20 11:31:00', '38.0', '5'),
    ('9008', '108', '204', '2021-09-20 21:00:40', '2021-09-20 21:03:00', '2021-09-20 21:31:00', '38.0', '4'),
    ('9018', '108', '214', '2021-09-20 19:01:00', '2021-09-20 19:04:50', '2021-09-20 19:21:00', '38.0', '5'),
    ('9002', '102', '202', '2021-09-21 09:01:00', '2021-09-21 09:06:00', '2021-09-21 09:31:00', '41.5', '5'),
    ('9006', '106', '203', '2021-09-21 18:01:00', '2021-09-21 18:09:00', '2021-09-21 18:31:00', '25.5', '4'),
    ('9007', '107', '203', '2021-09-22 11:01:00', '2021-09-22 11:07:00', '2021-09-22 11:31:00', '30.0', '5'),
    ('9003', '103', '202', '2021-09-22 08:01:00', '2021-09-22 08:15:00', '2021-09-22 08:31:00', '41.5', '4'),
    ('9004', '104', '202', '2021-09-23 08:01:00', '2021-09-23 08:13:00', '2021-09-23 08:31:00', '22.0', '4'),
    ('9005', '105', '202', '2021-09-23 10:01:00', '2021-09-23 10:13:00', '2021-09-23 10:31:00', '29.0', '5'),
    ('9019', '103', '202', '2021-09-24 20:01:00', '2021-09-24 20:11:00', '2021-09-24 20:51:00', '39.0', '4'),
    ('9011', '101', '211', '2021-09-24 08:30:00', '2021-09-24 08:31:00', '2021-09-24 08:54:00', '35.0', '5');

-- 从开始打车到司机接单为等待接单时间，从司机接单到上车为调度时间

with t1 as (
    select
           gcr.order_id,
           gcr.event_time, -- 下单时间
           gco.order_time, -- 接单时间
           gco.start_time, -- 发车时间
           gco.finish_time -- 结束时间
    from get_car_record_47 gcr join get_car_order_47 gco
    on gcr.order_id = gco.order_id
),t2 as (
    select
        '工作时间' period,
        count(order_id) get_car_num,
        cast(avg((unix_timestamp(order_time)-unix_timestamp(event_time))/60) as decimal(16,2)) wait_time,
        cast(avg((unix_timestamp(start_time)-unix_timestamp(order_time))/60) as decimal(16,2)) dispatch_time
    from t1
    where event_time >= concat(date_format(event_time,'yyyy-MM-dd'),' ','09:00:00') and event_time <  concat(date_format(event_time,'yyyy-MM-dd'),' ','17:00:00')
),t3 as (
    select
        '休息时间' period,
        count(order_id) get_car_num,
        cast(avg((unix_timestamp(order_time)-unix_timestamp(event_time))/60) as decimal(16,2)) wait_time,
        cast(avg((unix_timestamp(start_time)-unix_timestamp(order_time))/60) as decimal(16,2)) dispatch_time
    from t1
    where event_time >= concat(date_format(event_time,'yyyy-MM-dd'),' ','20:00:00') and event_time <=  concat(date_format(event_time,'yyyy-MM-dd'),' ','23:59:59')
      and date_add(event_time,1) >= concat(date_format(date_add(event_time,1),'yyyy-MM-dd'),' ','00:00:00') and event_time <  concat(date_format(date_add(event_time,1),'yyyy-MM-dd'),' ','07:00:00')
),t4 as (
    select
        '晚高峰' period,
        count(order_id) get_car_num,
        cast(avg((unix_timestamp(order_time)-unix_timestamp(event_time))/60) as decimal(16,2)) wait_time,
        cast(avg((unix_timestamp(start_time)-unix_timestamp(order_time))/60) as decimal(16,2)) dispatch_time
    from t1
    where event_time >= concat(date_format(event_time,'yyyy-MM-dd'),' ','17:00:00') and event_time <  concat(date_format(event_time,'yyyy-MM-dd'),' ','20:00:00')
),t5 as (
    select
        '早高峰' period,
        count(order_id) get_car_num,
        cast(avg((unix_timestamp(order_time)-unix_timestamp(event_time))/60) as decimal(16,2)) wait_time,
        cast(avg((unix_timestamp(start_time)-unix_timestamp(order_time))/60) as decimal(16,2)) dispatch_time
    from t1
    where event_time >= concat(date_format(event_time,'yyyy-MM-dd'),' ','07:00:00') and event_time <  concat(date_format(event_time,'yyyy-MM-dd'),' ','09:00:00')
)
select * from t2
union
select * from t3
union
select * from t4
union
select * from t5;
-- select unix_timestamp('2021-09-20 11:00:30') - unix_timestamp('2021-09-20 11:00:00')
//endregion =================================================================


//region: 第48题：拿到所有球队比赛的组合 每个队只比一次

-- 创建表 team
CREATE TABLE team (
    team_name STRING COMMENT '球队名称'
) COMMENT '球队表';

-- 插入数据
INSERT INTO team (team_name)
VALUES
    ('湖人'),
    ('骑士'),
    ('灰熊'),
    ('勇士');

with t1 as (
    select
        case team_name
            when '勇士' then 1
            when '湖人' then 2
            when '灰熊' then 3
            when '骑士' then 4
        end team_id,
        team_name
    from team
)
select
    t1.team_name team_name_1,
    t.team_name team_name_2
from t1 join t1 as t on t1.team_id < t.team_id;

//endregion =================================================================


//region: 第49题：找出近一个月发布的视频中热度最高的top3视频。

-- 创建表 user_video_log
-- drop table if exists user_video_log;

CREATE TABLE user_video_log (
    uid STRING COMMENT '用户id',
    video_id STRING COMMENT '视频id',
    start_time STRING COMMENT '开始时间',
    end_time STRING COMMENT '结束时间',
    if_like STRING COMMENT '是否点赞',
    if_retweet STRING COMMENT '是否喜欢',
    comment_id STRING COMMENT '评论id'
) COMMENT '用户视频观看记录表';

-- 插入数据
INSERT INTO user_video_log (uid, start_time, if_retweet, if_like, end_time, video_id, comment_id)
VALUES
    ('101', '2021-09-24 10:00:00', '0', '1', '2021-09-24 10:00:20', '2001', null),
    ('105', '2021-09-25 11:00:00', '1', '0', '2021-09-25 11:00:30', '2002', null),
    ('102', '2021-09-25 11:00:00', '1', '1', '2021-09-25 11:00:30', '2002', null),
    ('101', '2021-09-26 11:00:00', '1', '0', '2021-09-26 11:00:30', '2002', null),
    ('101', '2021-09-27 11:00:00', '0', '1', '2021-09-27 11:00:30', '2002', null),
    ('102', '2021-09-28 11:00:00', '1', '0', '2021-09-28 11:00:30', '2002', null),
    ('103', '2021-09-29 11:00:00', '1', '0', '2021-09-29 11:00:30', '2002', null),
    ('102', '2021-09-30 11:00:00', '1', '1', '2021-09-30 11:00:30', '2002', null),
    ('101', '2021-10-01 10:00:00', '0', '1', '2021-10-01 10:00:20', '2001', null),
    ('102', '2021-10-01 10:00:00', '1', '0', '2021-10-01 10:00:15', '2001', null),
    ('103', '2021-10-01 11:00:50', '0', '1', '2021-10-01 11:01:15', '2001', null),
    ('106', '2021-10-02 10:59:05', '1', '0', '2021-10-02 11:00:05', '2002', null),
    ('107', '2021-10-02 10:59:05', '1', '0', '2021-10-02 11:00:05', '2002', null),
    ('108', '2021-10-02 10:59:05', '1', '1', '2021-10-02 11:00:05', '2002', null),
    ('109', '2021-10-03 10:59:05', '0', '1', '2021-10-03 11:00:05', '2002', null);

-- 创建表 video_info
CREATE TABLE video_info (
    video_id STRING COMMENT '视频id',
    author STRING COMMENT '作者id',
    tag STRING COMMENT '标签',
    duration STRING COMMENT '视频时长'
) COMMENT '视频信息表';

-- 插入数据
INSERT INTO video_info (video_id, author, tag, duration)
VALUES
    ('2001', '901', '旅游', '30'),
    ('2002', '901', '旅游', '60'),
    ('2003', '902', '影视', '90'),
    ('2004', '902', '美女', '90');


with t0 as (
    select
        max(end_time) today
    from user_video_log
) ,t1 as (
    select
        uv.video_id,
        uv.start_time,
        uv.end_time,
        max(end_time) over (partition by uv.video_id) max_end_time,
        uv.if_like,
        uv.if_retweet,
        uv.comment_id,
        vi.duration,
        if((unix_timestamp(end_time)-unix_timestamp(start_time))=cast(duration as bigint),1,0) is_full_played
    from user_video_log uv join video_info vi
    on uv.video_id = vi.video_id
),t2 as (
    select
        video_id,
--         cast((sum(is_full_played)/count(*)) as decimal(16,2)) full_played_rate, -- 完播率
        sum(is_full_played)/count(*) full_played_rate, -- 完播率
        sum(if_like) like_cnt, -- 点赞数
        sum((if(comment_id is not null,1,0))) comment_cnt, -- 评论数
        sum(if_retweet) retweet_cnt, -- 转发数
--         cast( 1 / (sum(if(max_end_time between date_sub(t0.today,29) and t0.today,datediff(today,max_end_time),0)) + 1) as decimal(16,2)) new_rate -- 新鲜度
        1/(0+1) new_rate -- 新鲜度
    from t1 join t0 on 1=1
    group by video_id
),t3 as (
   select
       t2.video_id,
       cast(ceil((100*full_played_rate+5*like_cnt+3*comment_cnt+2*retweet_cnt)*new_rate ) as DECIMAL(16,1)) heat
    from t2
    order by heat desc
    limit 3
)
select
*
from t3;

//endregion =================================================================


//region: 第50题：统计2020年每个月实际在职员工数量(只统计2020-03-31之前)，如果1个月在职天数只有1天，数量计算方式：1/当月天数。 如果一个月只有一天的话，只算30分之1个人

/*
SELECT mnt as mth, round(sum(tag), 2) as ps
from (SELECT mnt, id, cnt / month_day as tag
      from (SELECT MONTH(day_flag) as mnt, id, count(*) cnt
            from (SELECT id, en_dt, le_dt, date_add(en_dt, pos) as day_flag
                  from (SELECT id, en_dt, if(le_dt is null, '2020-03-31', le_dt) as le_dt
                        from emp
                        where en_dt <= '2020-03-31') t1 LATERAL VIEW posexplode(split(space(datediff(le_dt, en_dt)), ' ')) t2 as pos, flag) t2
            group by MONTH(day_flag), id) t3
               JOIN(SELECT month(dt) month_flag, count(*) month_day from cal group by month(dt)) t4
                   on t3.mnt = t4.month_flag) t5
group by mnt
*/

//endregion =================================================================
