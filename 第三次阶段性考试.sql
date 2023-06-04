-- 第一题
create table ip_info(
    time1 string,       -- 访问时间
    interface string,   -- 访问接口
    ip string           -- 访问的ip地址
)
row format delimited fields terminated by '\t';

load data local INPATH '/opt/module/hive/datas/ip_info.txt' overwrite into table ip_info;
-- LOAD DATA LOCAL INPATH '/path/to/data.csv' INTO TABLE my_table;



select ip, rk
from (
    select ip,count(1) cnt,rank() over (order by count(1) desc) rk
    from ip_info
    where date_format(time1,'yyyy-MM-dd')='2016-11-09' and hour(time1) = 14 and interface = '/api/user/login'
    group by ip
)t1
where rk<=2;

-- 第二题
CREATE TABLE `account`
(
    `dist_id` int,    -- '区组id'
    `account` string, -- '账号'
    `gold`    string -- '金币'
)
row format delimited fields terminated by '\t';

load data local INPATH '/opt/module/hive/datas/account.txt' overwrite into table account;


select dist_id,account,sum_gold,rk
from (
    select dist_id,account,sum(gold) sum_gold,rank() over (partition by dist_id order by sum(gold) desc ) rk
        from account
    group by dist_id, account
)t1
where rk <= 10
order by dist_id;


-- 第三题
// member会员表
create table member(
    memberid string,
    credits decimal(10,2)
)
row format delimited fields terminated by '\t';

-- load data local INPATH '/opt/module/hive/datas/member.txt' overwrite into table member;
// sale销售表
create table sale(
    memberid string,
    MNAccount double
)
row format delimited fields terminated by '\t';

load data local INPATH '/opt/module/hive/datas/sale.txt' overwrite into table sale;
// regoods退货表
create table regoods(
    memberid string,
    RMNAccount double
)
row format delimited fields terminated by '\t';
load data local INPATH '/opt/module/hive/datas/regoods.txt' overwrite into table regoods;

insert into member (memberid, credits)
select t1.memberid, round(sale_money-regoods_money,2)
    from
(
    select memberid, sum(MNAccount) sale_money
    from sale
    group by memberid
)t1
join
(
    select memberid,sum(RMNAccount) regoods_money
    from regoods
    group by memberid
)t2
on t1.memberid=t2.memberid;
