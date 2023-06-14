// ===========================dwd==============================
-- dwd 层建表
DROP TABLE IF EXISTS dwd_interaction_user_favor_add_inc;
CREATE EXTERNAL TABLE dwd_interaction_user_favor_add_inc
(
    `id`          STRING COMMENT '编号',
    `user_id`     STRING COMMENT '用户id',
    `sku_id`      STRING COMMENT 'sku_id',
    `create_time` STRING COMMENT '添加收藏时间'
) COMMENT '用户添加收藏表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/gmall/dwd/dwd_interaction_user_favor_add_inc/'
    TBLPROPERTIES ("orc.compress" = "snappy");

-- 首日装载
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table dwd_interaction_user_favor_add_inc partition(dt)
select
    data.id,
    data.user_id,
    data.sku_id,
    data.create_time,
    date_format(data.create_time,'yyyy-MM-dd')
from ods_favor_info_inc
where dt='2022-06-08'
and type = 'bootstrap-insert' and data.is_cancel=0;

-- 每日装载
insert overwrite table dwd_interaction_user_favor_add_inc partition(dt='2022-06-09')
select
    data.id,
    data.user_id,
    data.sku_id,
    data.create_time
from ods_favor_info_inc
where dt='2022-06-09'
and type = 'insert';


-- dwd 层建表
DROP TABLE IF EXISTS dwd_interaction_user_favor_cancel_inc;
CREATE EXTERNAL TABLE dwd_interaction_user_favor_cancel_inc
(
    `id`          STRING COMMENT '编号',
    `user_id`     STRING COMMENT '用户id',
    `sku_id`      STRING COMMENT 'sku_id',
    `operate_time` STRING COMMENT '取消收藏时间'
) COMMENT '用户取消收藏表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/gmall/dwd/dwd_interaction_user_favor_cancel_inc/'
    TBLPROPERTIES ("orc.compress" = "snappy");

-- 首日装载
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table dwd_interaction_user_favor_cancel_inc partition(dt)
select
    data.id,
    data.user_id,
    data.sku_id,
    data.operate_time,
    date_format(data.operate_time,'yyyy-MM-dd')
from ods_favor_info_inc
where dt='2022-06-08'
  and type = 'bootstrap-insert' and data.is_cancel=1;

-- 每日装载
insert overwrite table dwd_interaction_user_favor_cancel_inc partition(dt='2022-06-09')
select
    data.id,
    data.user_id,
    data.sku_id,
    data.operate_time
from ods_favor_info_inc
where dt='2022-06-09'
  and type = 'update';

// ===========================dws_1d==============================
-- dws创建表
DROP TABLE IF EXISTS dws_interaction_user_favor_add_1d;
CREATE EXTERNAL TABLE dws_interaction_user_favor_add_1d
(
    `user_id`             STRING COMMENT '用户id',
  	`sku_id`             STRING COMMENT '商品id',
    `sku_name`           STRING COMMENT 'sku名称',
    `favor_add_count_1d` BIGINT COMMENT '用户收藏商品次数'
) COMMENT '互动域用户粒度收藏商品最近1日汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/gmall/dws/dws_interaction_user_favor_add_1d'
    TBLPROPERTIES ('orc.compress' = 'snappy');

--（1）首日装载
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table dws_interaction_user_favor_add_1d partition(dt)
select
	user_id,
    sku_id,
    sku_name,
    favor_add_count,
    dt
from
(
    select
        user_id,
        sku_id,
        count(*) favor_add_count,
        dt
    from dwd_interaction_user_favor_add_inc
    where dt<='2022-06-08'
    group by dt,user_id,sku_id
)favor
left join
(
    select
        id,
        sku_name
    from dim_sku_full
    where dt='2022-06-08'
)sku
on favor.sku_id=sku.id;

--（2）每日装载
insert overwrite table dws_interaction_user_favor_add_1d partition(dt='2022-06-09')
select
  	user_id,
    sku_id,
    sku_name,
    favor_add_count
from
(
    select
        user_id,
        sku_id,
        count(*) favor_add_count
    from dwd_interaction_user_favor_add_inc
    -- 只选择每日的就行
    where dt='2022-06-09'
    group by user_id,sku_id
)favor
left join
(
    -- 这里会按分区查询是因为以防新日期会有新的后台运营数据插入
    select
        id,
        sku_name
    from dim_sku_full
    where dt='2022-06-09'
)sku
on favor.sku_id=sku.id;

-- dws创建表
DROP TABLE IF EXISTS dws_interaction_user_favor_cancel_1d;
CREATE EXTERNAL TABLE dws_interaction_user_favor_cancel_1d
(
    `user_id`             STRING COMMENT '用户id',
    `sku_id`             STRING COMMENT '商品id',
    `sku_name`           STRING COMMENT 'sku名称',
    `favor_cancel_count_1d` BIGINT COMMENT '用户取消收藏商品次数'
) COMMENT '互动域用户粒度取消收藏商品最近1日汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/gmall/dws/dws_interaction_user_favor_cancel_1d'
    TBLPROPERTIES ('orc.compress' = 'snappy');

--（1）首日装载
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table dws_interaction_user_favor_cancel_1d partition(dt)
select
    user_id,
    sku_id,
    sku_name,
    favor_cancel_count,
    dt
from
    (
        select
            user_id,
            sku_id,
            count(*) favor_cancel_count,
            dt
        from dwd_interaction_user_favor_cancel_inc
        where dt<='2022-06-08'
        group by dt,user_id,sku_id
    )favor
        left join
    (
        select
            id,
            sku_name
        from dim_sku_full
        where dt='2022-06-08'
    )sku
    on favor.sku_id=sku.id;

--（2）每日装载
insert overwrite table dws_interaction_user_favor_cancel_1d partition(dt='2022-06-09')
select
    user_id,
    sku_id,
    sku_name,
    favor_cancel_count
from
    (
        select
            user_id,
            sku_id,
            count(*) favor_cancel_count
        from dwd_interaction_user_favor_cancel_inc
             -- 只选择每日的就行
        where dt='2022-06-09'
        group by user_id,sku_id
    )favor
        left join
    (
        -- 这里会按分区查询是因为以防新日期会有新的后台运营数据插入
        select
            id,
            sku_name
        from dim_sku_full
        where dt='2022-06-09'
    )sku
    on favor.sku_id=sku.id;

// ===========================dws_td==============================
-- 每日数据汇总
DROP TABLE IF EXISTS dws_interaction_user_favor_add_td;
CREATE EXTERNAL TABLE dws_interaction_user_favor_add_td
(
    `user_id`             STRING COMMENT '用户id',
  	`sku_id`             STRING COMMENT '商品id',
    `favor_add_count_td` BIGINT COMMENT '商品被收藏次数'
) COMMENT '互动域用户粒度收藏商品历史至今汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/gmall/dws/dws_interaction_user_favor_add_td'
    TBLPROPERTIES ('orc.compress' = 'snappy');

-- 首日数据加载
insert overwrite table dws_interaction_user_favor_add_td partition(dt='2022-06-08')
select
    user_id,
    sku_id,
    sum(favor_add_count_1d) favor_count
from dws_interaction_user_favor_add_1d
-- 首日可加可不加这个条件
where dt<='2022-06-08'
group by user_id,sku_id;

-- 每日数据加载
with ufct as (
    -- 历史至当日前一天汇总
    select user_id,
           sku_id,
           favor_add_count_td
    from dws_interaction_user_favor_add_td where dt=date_sub('2022-06-09',1)
    union
    -- 历史至当日汇总
    select user_id,
           sku_id,
           favor_add_count_1d
    from dws_interaction_user_favor_add_1d where dt='2022-06-09'
)
insert overwrite table dws_interaction_user_favor_add_td partition(dt='2022-06-09')
select user_id,
       sku_id,
       sum(favor_add_count_td) add
from ufct
group by user_id, sku_id;
-- having first < last;

-- dws_interaction_user_favor_cancel_td 每日数据汇总
DROP TABLE IF EXISTS dws_interaction_user_favor_cancel_td;
CREATE EXTERNAL TABLE dws_interaction_user_favor_cancel_td
(
    `user_id`             STRING COMMENT '用户id',
    `sku_id`             STRING COMMENT '商品id',
    `favor_cancel_count_td` BIGINT COMMENT '商品被收藏次数'
) COMMENT '互动域用户粒度收藏商品历史至今汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/gmall/dws/dws_interaction_user_favor_cancel_td'
    TBLPROPERTIES ('orc.compress' = 'snappy');

-- 首日数据加载
insert overwrite table dws_interaction_user_favor_cancel_td partition(dt='2022-06-08')
select
    user_id,
    sku_id,
    sum(favor_cancel_count_1d) favor_count
from dws_interaction_user_favor_cancel_1d
-- 首日可加可不加这个条件
where dt<='2022-06-08'
group by user_id,sku_id;

-- 每日数据加载
with ufct as (
    -- 历史至当日前一天汇总
    select user_id,
           sku_id,
           favor_cancel_count_td
    from dws_interaction_user_favor_cancel_td where dt=date_sub('2022-06-09',1)
    union
    -- 历史至当日汇总
    select user_id,
           sku_id,
           favor_cancel_count_1d
    from dws_interaction_user_favor_cancel_1d where dt='2022-06-09'
)
insert overwrite table dws_interaction_user_favor_cancel_td partition(dt='2022-06-09')
select user_id,
       sku_id,
       sum(favor_cancel_count_td) add
from ufct
group by user_id, sku_id;
-- having first < last;

-- 聚合
-- dws_interaction_user_favor_cnt_td 每日总数据汇总
-- DROP TABLE IF EXISTS dws_interaction_user_favor_cnt_td;
-- CREATE EXTERNAL TABLE dws_interaction_user_favor_cnt_td
-- (
--     `user_id`             STRING COMMENT '用户id',
--     `sku_id`             STRING COMMENT '商品id',
--     `favor_count_td` BIGINT COMMENT '商品被收藏次数'
-- ) COMMENT '互动域用户粒度收藏商品历史至今汇总表'
--     PARTITIONED BY (`dt` STRING)
--     STORED AS ORC
--     LOCATION '/warehouse/gmall/dws/dws_interaction_user_favor_cnt_td'
--     TBLPROPERTIES ('orc.compress' = 'snappy');

-- set hive.exec.dynamic.partition.mode=nonstrict;
-- insert overwrite table dws_interaction_user_favor_cnt_td partition(dt)
-- select duz.id,
--        nvl(dat.sku_id,'0000000000') sku_id,
--        nvl(dat.favor_add_count_td,0) favor_add_count_td,
--        nvl(dat.dt,'9999-12-31') dt
--     from dws_interaction_user_favor_add_td dat left join dws_interaction_user_favor_cancel_td dct
--     on dat.dt=dct.dt and dat.user_id != dct.user_id and dat.sku_id != dct.sku_id
--     right join dim_user_zip duz on dat.user_id = duz.id and duz.dt='9999-12-31';



-- select * from dws_interaction_user_favor_cnt_td;
--
-- set hive.exec.dynamic.partition.mode=nonstrict;
-- insert overwrite table dws_interaction_user_favor_cnt_td partition(dt)
-- select dat.user_id,
--        dat.sku_id,
--        dat.favor_add_count_td,
--        dat.dt
-- from dws_interaction_user_favor_add_td dat left join dws_interaction_user_favor_cancel_td dct
--         on dat.dt=dct.dt and dat.user_id != dct.user_id and dat.sku_id != dct.sku_id


/**
  题目：
  需求9: 统计目前所有用户收藏列表中每个商品的个数。
 */

-- ods层表缺失,需要自建全量表
/*
 配置 datax 导数据的 json 文件，然后直接运行后导入 hdfs ，再由 hdfs load data 到 ods 表

 对于商品库存、账户余额这些存量型指标，业务系统中通常就会计算并保存最新结果，
 所以定期同步一份全量数据到数据仓库，构建周期型快照事实表，
 就能轻松应对此类统计需求，而无需再对事务型事实表中大量的历史记录进行聚合了。
 */
DROP TABLE IF EXISTS ods_favor_info_full;
CREATE EXTERNAL TABLE ods_favor_info_full
(
    id STRING COMMENT 'id',
    user_id STRING COMMENT '用户id',
    sku_id STRING COMMENT 'sku_id',
    is_cancel STRING COMMENT '是否取消 0 正常 1 已取消',
    create_time STRING COMMENT '收藏时间',
    operate_time STRING COMMENT '取消收藏时间'
) COMMENT '购物车全量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/gmall/ods/ods_favor_info_full/';

-- 互动域收藏周期型快照事实表
-- 互动域收藏周期型快照事实表
DROP TABLE IF EXISTS dwd_interaction_favor_info_full;
CREATE EXTERNAL TABLE dwd_interaction_favor_info_full
(
    `id`        STRING COMMENT '编号',
    `user_id`   STRING COMMENT '用户id',
    `sku_id`    STRING COMMENT '商品id',
    `sku_name`  STRING COMMENT '商品名称',
    `create_time` STRING COMMENT '收藏时间',
    `category3_id`         STRING COMMENT '三级分类id',
    `category3_name`       STRING COMMENT '三级分类名称',
    `category2_id`         STRING COMMENT '二级分类id',
    `category2_name`       STRING COMMENT '二级分类名称',
    `category1_id`         STRING COMMENT '一级分类id',
    `category1_name`       STRING COMMENT '一级分类名称',
    `tm_id`                  STRING COMMENT '品牌id',
    `tm_name`               STRING COMMENT '品牌名称'
) COMMENT '互动域收藏周期型快照事实表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
    STORED AS ORC
    LOCATION '/warehouse/gmall/dwd/dwd_favor_info_full/'
    TBLPROPERTIES ('orc.compress' = 'snappy');

-- 数据加载：首日和每日一样
insert overwrite table dwd_interaction_favor_info_full partition(dt='2022-06-08')
select
    ofi.id,
    ofi.user_id,
    ofi.sku_id,
    dsf.sku_name,
    ofi.create_time,
    dsf.category3_id,  -- 可按照3级分类统计收藏个数
    dsf.category3_name,
    dsf.category2_id,	-- 可按照2级分类统计收藏个数
    dsf.category2_name,
    dsf.category1_id, -- 可按照1级分类统计收藏个数
    dsf.category1_name,
    dsf.tm_id, -- 可按照品牌统计收藏个数
    dsf.tm_name
from ods_favor_info_full ofi left join dim_sku_full dsf
on ofi.sku_id = dsf.id
where ofi.dt='2022-06-08' and is_cancel='0'
-- group by ofi.dt,user_id,sku_id;

