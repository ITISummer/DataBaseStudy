show databases ;
show tables;

select * from stu;

create database db_hive1;

create database db_hive2 location '/db_hive2';

create database db_hive3 with dbproperties('create_date'='2022-11-18');

show databases like 'db_hive*';

desc database db_hive3;
desc database extended db_hive3;

alter database db_hive3 set dbproperties ('create_date'='2022-11-20');
describe database extended db_hive3;

drop database db_hive2;

drop database db_hive3 cascade ;
show databases ;

create table if not exists student(
    id int,
    name string
)
row format delimited fields terminated by '\t'
location '/user/hive/warehouse/student';

show tables;

select * from student;
drop table student;

create table teacher
(
    name     string,
    friends  array<string>,
    students map<string,int>,
    address  struct<city:string,street:string,postal_code:int>)
row format serde 'org.apache.hadoop.hive.serde2.JsonSerDe'
location '/user/hive/warehouse/teacher';

select * from teacher;
describe teacher;

create table teacher1 as select * from teacher;
create table teacher2 like teacher;

select * from teacher1;
select * from teacher2;

show tables like 'tea*';

-- desc stu;
-- desc formatted stu;

-- 重命名表
-- alter table stu rename to stu1;
select * from stu1;
