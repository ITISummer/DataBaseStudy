create table student(id int, name string)
row format delimited fields terminated by '\t';

select * from stu1;

-- 加载本地文件到 Hive
load data local inpath '/opt/module/datas/student.txt' into table student;
load data local inpath '/opt/module/datas/student.txt' overwrite into table student;
select * from student;
-- 加载HDFS上数据到student表中
load data inpath '/user/lv/student.txt' into table student;
load data inpath '/user/lv/student.txt' overwrite into table student;

-- insert 关键字
-- 新建一张表
create table student1(
    id int,
    name string
)
row format delimited fields terminated by '\t';

insert overwrite table student1 select id, name from student;
select * from student1;
insert into table student1 values (1,'wangwu'),(2,'zhaoliu');

insert overwrite local directory '/opt/module/datas/student' ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe' select id,name from student;

-- 导出数据
export table default.student to '/user/hive/warehouse/export/student';
-- 导入数据
import table student2 from '/user/hive/warehouse/export/student';
select * from student2;

-------------------------------基本查询-------------------------------
-- 创建部门表
create table if not exists dept(
    deptno int,
    dname string,
    loc int
)
row format delimited fields terminated by '\t';

-- 创建员工表
create table if not exists emp(
    empno int,
    ename string,
    job string,
    sal double,
    deptno int
)
row format delimited fields terminated by '\t';

-- 导入部门数据
load data local inpath '/opt/module/datas/dept.txt' into table dept;
load data local inpath '/opt/module/datas/emp.txt' into table emp;

-- 查询导入的数据
select * from dept;
select * from emp;

-- 查询时重命名
select ename as name, deptno dn from emp;

-- limit语句
select * from emp limit 5;
select * from emp limit 2,3;

-- order by 语句
select * from emp order by sal;
select * from emp order by sal desc;
select ename,  sal * 2 twosal from emp order by twosal;
select ename, deptno, sal from emp order by deptno, sal;

-- where 子句
select * from emp where sal > 1000;
select * from emp where sal > 1000 and deptno = 30;
-- 聚合函数
select count(*) cnt from emp;
select max(sal) max_sal from emp;
select min(sal) min_sal from emp;
select sum(sal) sum_sal from emp;
select avg(sal) avg_sal from emp;

-- group by
select
    t.deptno,
    avg(t.sal) avg_sal
from emp t
group by t.deptno;

select
    deptno,
    avg(sal) avg_sal
from emp
group by deptno
having avg_sal > 2000;

select
    e.empno,
    e.ename,
    d.dname
from emp e
join dept d
on e.deptno = d.deptno;

-- 连接
select
    e.empno,
    e.ename,
    d.deptno
from emp e
join dept d
on e.deptno = d.deptno;

-- 左外连接
select
    e.empno,
    e.ename,
    d.deptno
from emp e
left join dept d
on e.deptno = d.deptno;

-- 右外连接
select
    e.empno,
    e.ename,
    d.deptno
from emp e
right join dept d
on e.deptno = d.deptno;

-- 满外连接
select
    e.empno,
    e.ename,
    d.deptno
from emp e
full join dept d
on e.deptno = d.deptno;

-- 多表连接
create table if not exists location(
  loc int,           -- 部门位置id
  loc_name string   -- 部门位置
)
row format delimited fields terminated by '\t';
load data local inpath '/opt/module/datas/location.txt' into table location;
select * from location;

-- 多表连接
select
    e.ename,
    d.dname,
    l.loc_name
from emp e
join dept d
on d.deptno = e.deptno
join location l
on d.loc = l.loc;

-- 联合
select
    *
from emp
where deptno=30
union
select
    *
from emp
where deptno=40;