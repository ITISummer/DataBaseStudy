-- 创建学生表
DROP TABLE IF EXISTS student;
create table if not exists student_info
(
    stu_id   string COMMENT '学生id',
    stu_name string COMMENT '学生姓名',
    birthday string COMMENT '出生日期',
    sex      string COMMENT '性别'
)
    row format delimited fields terminated by ','
    stored as textfile;

-- 创建课程表
DROP TABLE IF EXISTS course;
create table if not exists course_info
(
    course_id   string COMMENT '课程id',
    course_name string COMMENT '课程名',
    tea_id      string COMMENT '任课老师id'
)
    row format delimited fields terminated by ','
    stored as textfile;

-- 创建老师表
DROP TABLE IF EXISTS teacher;
create table if not exists teacher_info
(
    tea_id   string COMMENT '老师id',
    tea_name string COMMENT '学生姓名'
)
    row format delimited fields terminated by ','
    stored as textfile;

-- 创建分数表
DROP TABLE IF EXISTS score;
create table if not exists score_info
(
    stu_id    string COMMENT '学生id',
    course_id string COMMENT '课程id',
    score     int COMMENT '成绩'
)
    row format delimited fields terminated by ','
    stored as textfile;

-- 插入数据
load data local inpath '/opt/module/datas/cjcs/student_info.txt' into table student_info;
load data local inpath '/opt/module/datas/cjcs/course_info.txt' into table course_info;
load data local inpath '/opt/module/datas/cjcs/teacher_info.txt' into table teacher_info;
load data local inpath '/opt/module/datas/cjcs/score_info.txt' into table score_info;

-- 查看插入的数据
select * from student_info limit 10;
select * from course_info limit 10;
select * from teacher_info limit 10;
select * from score_info limit 10;
