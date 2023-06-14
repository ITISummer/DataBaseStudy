-- with uva as
--          (
-- -- 得到每个城市每种商品的点击次数并做排序
--              select
--                  city_id,
--                  click_product_id,
--                  sum(if(click_product_id!=-1,1,0) city_click_product_cnt,
--                      row_number() over (partition by city_id, click_product_id order by city_click_product_cnt) rn
--                      from user_visit_action
--                      group by city_id,click_product_id
--                      )
--                  select
-- 	ci.area,
-- 	pi.product_name,
-- 	sum(uva.city_click_product_cnt) area_click_product_cnt,
-- 	case uva.rn
-- 	when uva.rn=1 collect_list.add(ci.city_name+" "+ROUND((uva.city_click_product_cnt/sum(uva.city_click_product_cnt)*100),1)+"%"))
--     when uva.rn=2 collect_list.add(ci.city_name+" "+ROUND((uva.city_click_product_cnt/sum(uva.city_click_product_cnt)*100),1)+"%"))
-- 	else collect_list.add(其他+" "+ROUND(sum(if(uva.rn!=1 && uva.rn!=2,uva.city_click_product_cnt,0)/sum(uva.city_click_product_cnt)*100),1)+"%")
-- 	end city_percent_rn
-- from uva join city_info ci on uva.city_id = ci.city_id
--          join product_info pi on uva.click_product_id = pi.product_id
-- group by ci.area,pi.product_name


-- ChatGPT 修正后
-- WITH uva AS (
--     -- 得到每个城市每种商品的点击次数并做排序
--     SELECT
--     city_id,
--     click_product_id,
--     SUM(IF(click_product_id != -1, 1, 0)) AS city_click_product_cnt,
--     ROW_NUMBER() OVER (PARTITION BY city_id, click_product_id ORDER BY city_click_product_cnt) AS rn
--     FROM user_visit_action
--     GROUP BY city_id, click_product_id
--     )
-- SELECT
--     ci.area,
--     pi.product_name,
--     SUM(uva.city_click_product_cnt) AS area_click_product_cnt,
--     CASE uva.rn
--         WHEN 1 THEN COLLECT_LIST(ci.city_name || ' ' || ROUND((uva.city_click_product_cnt / SUM(uva.city_click_product_cnt) * 100), 1))
--         WHEN 2 THEN COLLECT_LIST(ci.city_name || ' ' || ROUND((uva.city_click_product_cnt / SUM(uva.city_click_product_cnt) * 100), 1))
--         ELSE COLLECT_LIST('其他' || ' ' || ROUND(SUM(IF(uva.rn != 1 AND uva.rn != 2, uva.city_click_product_cnt, 0)) / SUM(uva.city_click_product_cnt) * 100, 1))
--         END AS city_percent_rn
-- FROM uva
--          JOIN city_info ci ON uva.city_id = ci.city_id
--          JOIN product_info pi ON uva.click_product_id = pi.product_id
-- GROUP BY ci.area, pi.product_name;

create table `user_visit_action`(
    `user_id` bigint,
    `click_product_id` bigint,
    `city_id` bigint
);

create table `city_info`(
    `city_id` bigint,
    `city_name` string,
    `area` string
);

create table `product_info`(
    `product_id` bigint,
    `product_name` string
);

-- 再次手动修正
select ci.area,
       pi.product_name,
       sum(uva.city_click_product_cnt) area_click_product_cnt
from(
        -- 得到每个城市每种商品的点击次数并做排序
        SELECT
            city_id,
            click_product_id,
            SUM(IF(click_product_id != -1, 1, 0)) AS city_click_product_cnt,
            ROW_NUMBER() OVER (PARTITION BY city_id, click_product_id ORDER BY SUM(IF(click_product_id != -1, 1, 0))) AS rn
        FROM user_visit_action
        GROUP BY city_id, click_product_id
    )uva
        JOIN city_info ci ON uva.city_id = ci.city_id
        JOIN product_info pi ON uva.click_product_id = pi.product_id
GROUP BY ci.area, pi.product_name;
