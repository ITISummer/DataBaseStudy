-- 1. 打成jar包上传到服务器
-- hive (default)>
add jar /opt/software/HiveUDTFDemo-1.0-SNAPSHOT.jar;
-- 创建临时函数与开发好的java class关联
create temporary function date_range as "com.itis.hive.DateRangeUDF";
-- 调试函数
select date_range('2018-02-27','2018-03-01');
select explode(date_range('2018-02-27','2018-03-01'));

-- 选择性删除函数
-- drop temporary function if exists kaoshi.date_range;
-- desc function date_range;

-- 建表
create table good_promotion(
    brand string,
    stt string,
    edt string
)
row format delimited
fields terminated by '\t';
LOAD DATA LOCAL INPATH '/opt/module/hive/datas/good_promotion.txt' INTO TABLE good_promotion;

-- 解法一：参考：[HiveSQL——打折日期交叉问题](https://www.cnblogs.com/wdh01/p/16898604.html)
select brand, sum(if(day_nums >= 0, day_nums + 1, 0)) day_nums
from (select brand, datediff(edt, stt_new) day_nums
      from (select brand, stt, if(maxEndDate is null, stt, if(stt > maxEndDate, stt, date_add(maxEndDate, 1))) stt_new, edt
            from (select brand, stt, edt,
                         max(edt) over (partition by brand order by stt rows between unbounded preceding and 1 preceding) maxEndDate
                  from good_promotion
                 )t1
           )t2
     )t3
group by brand;


-- 解法二：使用自定义UDF函数 date_range
set hive.exec.mode.local.auto=true;
set hive.exec.mode.local.auto;

select brand,dt,stt,edt
from(
        select brand, stt, edt, date_range(stt,edt) dts
        from good_promotion
    )t1 lateral view explode(dts) tmp as dt;

-- 方案二最终答案
-- 设置 hive 本地运行
set hive.exec.mode.local.auto=true;
-- 3. 按品牌进行分组统计
select brand,count(1) days
from (
         -- 2. 按品牌和dt进行去重
         select distinct brand,dt
         from
             (
                 -- 1. 计算日期范围：[stt,edt]
                 select brand,stt,edt,date_range(stt,edt) dts
                 from good_promotion
             ) t1 lateral view explode(dts) tmp as dt
     )t2
group by brand
order by days;