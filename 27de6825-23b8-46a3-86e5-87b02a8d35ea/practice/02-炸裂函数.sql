use default;
set hive.exec.mode.local.auto=true;
set hive.exec.mode.local.auto;
-- 建表
create table movie_info(
    movie string,     --电影名称
    category string   --电影分类
)
row format delimited fields terminated by "\t";

insert overwrite table movie_info
values ("《疑犯追踪》", "悬疑,动作,科幻,剧情"),
       ("《Lie to me》", "悬疑,警匪,动作,心理,剧情"),
       ("《战狼2》", "战争,动作,灾难");

select * from movie_info;
desc function extended explode;
-- （1）需求说明：根据上述电影信息表，统计各分类的电影数量
select category_item,count(1) cnt
from
(
    select movie, category_item
    from
    (
        select movie, split(category,',') cates
        from movie_info
    )t1 lateral view explode(cates) tmp as category_item
) t2
group by category_item;