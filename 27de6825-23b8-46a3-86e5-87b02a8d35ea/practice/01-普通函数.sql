use default;
set hive.exec.mode.local.auto=true;
set hive.exec.mode.local.auto;
-- 建表
create  table  employee(
    name string,  --姓名
    sex  string,  --性别
    birthday string, --出生年月
    hiredate string, --入职日期
    job string,   --岗位
    salary double, --薪资
    bonus double,  --奖金
    friends array<string>, --朋友
    children map<string,int> --孩子
);
-- 插入数据
insert into employee
  values('张无忌','男','1980/02/12','2022/08/09','销售',3000,12000,array('阿朱','小昭'),map('张小无',8,'张小忌',9)),
        ('赵敏','女','1982/05/18','2022/09/10','行政',9000,2000,array('阿三','阿四'),map('赵小敏',8)),
        ('宋青书','男','1981/03/15','2022/04/09','研发',18000,1000,array('王五','赵六'),map('宋小青',7,'宋小书',5)),
        ('周芷若','女','1981/03/17','2022/04/10','研发',18000,1000,array('王五','赵六'),map('宋小青',7,'宋小书',5)),
        ('郭靖','男','1985/03/11','2022/07/19','销售',2000,13000,array('南帝','北丐'),map('郭芙',5,'郭襄',4)),
        ('黄蓉','女','1982/12/13','2022/06/11','行政',12000,null,array('东邪','西毒'),map('郭芙',5,'郭襄',4)),
        ('杨过','男','1988/01/30','2022/08/13','前台',5000,null,array('郭靖','黄蓉'),map('杨小过',2)),
        ('小龙女','女','1985/02/12','2022/09/24','前台',6000,null,array('张三','李四'),map('杨小过',2));
-- 查询数据
select * from employee;
-- 1）统计每个月的入职人数
select month(replace(e.hiredate,'/','-')) mon, count(1) cnt
from employee e
group by month(replace(e.hiredate,'/','-'));

-- 2）查询每个人的年龄（年 + 月）
select e.name,
       concat(
           if(month(current_date())-month(replace(e.birthday,'/','-'))>0,year(current_date())-year(replace(e.birthday,'/','-')),year(current_date())-year(replace(e.birthday,'/','-'))-1),'年',
           if(month(current_date())-month(replace(e.birthday,'/','-'))>0,month(current_date())-month(replace(e.birthday,'/','-')),12+month(current_date())-month(replace(e.birthday,'/','-')))
           ,'月') age
from employee e;

-- 3）按照薪资，奖金的和进行倒序排序，如果奖金为null，置位0
select e.name,nvl(e.salary,0)+nvl(e.bonus,0) wedge
from employee e
order by wedge desc;

-- 4）查询每个人有多少个朋友
select e.name,size(e.friends) friends_num
from employee e;

-- 5）查询每个人的孩子的姓名
select e.name, map_keys(e.children) children_name
from employee e;