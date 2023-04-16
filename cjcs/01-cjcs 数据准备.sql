show databases ;
create database cjcs;
show databases ;
use cjcs;

-- 创建学生表
DROP TABLE IF EXISTS student;
create table if not exists student(
    stu_id string COMMENT '学生id',
    stu_name string COMMENT '学生姓名',
    birthday string COMMENT '出生日期',
    sex string COMMENT '性别'
)
row format delimited fields terminated by ','
stored as textfile;

-- 创建课程表
DROP TABLE IF EXISTS course;
create table if not exists course(
    course_id string COMMENT '课程id',
    course_name string COMMENT '课程名',
    tea_id string COMMENT '任课老师id'
)
row format delimited fields terminated by ','
stored as textfile;

-- 创建老师表
DROP TABLE IF EXISTS teacher;
create table if not exists teacher(
    tea_id string COMMENT '老师id',
    tea_name string COMMENT '学生姓名'
)
row format delimited fields terminated by ','
stored as textfile;

-- 创建分数表
DROP TABLE IF EXISTS score;
create table if not exists score(
    stu_id string COMMENT '学生id',
    course_id string COMMENT '课程id',
    score int COMMENT '成绩'
)
row format delimited fields terminated by ','
stored as textfile;

show tables;

-- 插入数据
load data local inpath '/opt/module/datas/student.txt' into table student;

load data local inpath '/opt/module/datas/course.txt' into table course;

load data local inpath '/opt/module/datas/teacher.txt' into table teacher;

load data local inpath '/opt/module/datas/score.txt' into table score;

-- 验证数据插入情况
select * from student limit 5;
select * from course limit 5;
select * from teacher limit 5;
select * from score limit 5;
