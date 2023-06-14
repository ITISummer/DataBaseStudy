use cjcs;
set hive.exec.mode.local.auto=true;
set hive.exec.mode.local.auto;

-- 5.1.1 [课堂讲解]查询有两门以上的课程不及格的同学的学号及其平均成绩
select s.stu_id, avg(s.score)
from score s
group by s.stu_id
having sum(if(s.score<60,1,0)) >2;
-- 5.1.2 查询所有学生的学号、姓名、选课数、总成绩
select s.stu_id,s.stu_name,nvl(t1.cnt,0),nvl(t1.sum_score,0)
from (
    select s.stu_id,count(1) cnt,sum(s.score) sum_score
    from score s
    group by s.stu_id
) t1 right join student s
on t1.stu_id=s.stu_id;
-- 5.1.3 查询平均成绩大于85的所有学生的学号、姓名和平均成绩
select s2.stu_id,s2.stu_name,t1.avg_score
from (
    select s.stu_id, avg(s.score) avg_score
    from score s
    group by stu_id
    having avg_score>85
) t1 join student s2
on t1.stu_id = s2.stu_id;
-- 5.1.4 查询学生的选课情况：学号，姓名，课程号，课程名称
select s2.stu_id,s2.stu_name,s.course_id,c.course_name
from score s right join student s2 on s.stu_id = s2.stu_id
join course c on s.course_id = c.course_id;
-- 5.1.5 查询出每门课程的及格人数和不及格人数
select t1.course_id,c.course_name,t1.`及格人数`,t1.`不及格人数`
from (
select s.course_id,
       sum(if(s.score>=60,1,0)) `及格人数`,
       sum(if(s.score<60,1,0)) `不及格人数`
from score s
group by s.course_id
) t1 join course c
on t1.course_id=c.course_id;
-- 5.1.6 查询课程编号为03且课程成绩在80分以上的学生的学号和姓名及课程信息
select s.stu_id,s2.stu_name,s.score,s.course_id,c.course_name
from score s join student s2 on s.stu_id = s2.stu_id
join course c on s.course_id = c.course_id
where s.course_id='03' and s.score>80;

-- 5.2.1 课程编号为"01"且课程分数小于60，按分数降序排列的学生信息
select s2.*, s.score
from score s join student s2 on s.stu_id = s2.stu_id
where s.course_id='01' and s.score<60
order by s.score desc;
-- 5.2.2 查询所有课程成绩在70分以上的学生的姓名、课程名称和分数，按分数升序排列
select t1.stu_id,s.stu_name,c.course_name,s2.score
from (
    select s.stu_id,min(s.score) min_score
    from score s
    group by s.stu_id
    having min(s.score) > 70
) t1 join student s on t1.stu_id=s.stu_id
join score s2 on t1.stu_id=s2.stu_id
join course c on s2.course_id = c.course_id
order by t1.stu_id,s2.score;
-- 5.2.3 查询该学生不同课程的成绩相同的学生编号、课程编号、学生成绩
select s.stu_id,s.course_id,s.score
from score s join score s2
on s.stu_id=s2.stu_id
and s.course_id<>s2.course_id
and s.score=s2.score;
-- 5.2.4 查询课程编号为'01'的课程比'02'的课程成绩高的所有学生的学号
select s.stu_id
from score s join score s2
on s.stu_id=s2.stu_id and s.score > s2.score
where s.course_id='01' and s2.course_id='02';
-- 5.2.5 查询学过编号为“01”的课程并且也学过编号为“02”的课程的学生的学号、姓名
select s.stu_id,s.stu_name
from
(
    select s.stu_id
    from score s
    where s.course_id='01'
    group by stu_id
) t1
join
(
    select s.stu_id
    from score s
    where s.course_id='02'
    group by stu_id
) t2
on t1.stu_id=t2.stu_id
join student s on t1.stu_id=s.stu_id;
-- 5.2.6 [课堂讲解]查询学过“李体音”老师所教的所有课的同学的学号、姓名
select s2.stu_id,s2.stu_name, count(1) cnt
from
(
    select c.tea_id,c.course_name,c.course_id
    from course c join teacher t on c.tea_id = t.tea_id
    where t.tea_name='李体音'
) t1 join score s on t1.course_id=s.course_id
join student s2 on s.stu_id = s2.stu_id
group by s2.stu_id, s2.stu_name
having cnt=2;

-- 5.2.7 [课堂讲解]查询学过“李体音”老师所讲授的任意一门课程的学生的学号、姓名
select distinct s2.stu_id,s2.stu_name
from score s join course c on s.course_id = c.course_id
join teacher t on c.tea_id = t.tea_id
join student s2 on s.stu_id = s2.stu_id
where t.tea_name='李体音';
-- or
select s2.stu_id,s2.stu_name
from
    (
        select c.tea_id,c.course_name,c.course_id
        from course c join teacher t on c.tea_id = t.tea_id
        where t.tea_name='李体音'
    ) t1 join score s on t1.course_id=s.course_id
         join student s2 on s.stu_id = s2.stu_id
group by s2.stu_id, s2.stu_name;

-- 5.2.8 [课堂讲解]查询没学过"李体音"老师讲授的任一门课程的学生姓名
select s.stu_name
from student s
where s.stu_id not in (
    select s.stu_id
    from score s
    where s.course_id in (
        select c.course_id
        from course c join teacher t on c.tea_id = t.tea_id
        where t.tea_name='李体音'
    )
);
-- 5.2.9 [课堂讲解]查询至少有一门课与学号为“001”的学生所学课程相同的学生的学号和姓名
select s.stu_id,s.stu_name
from student s
where s.stu_id in
(
    select s.stu_id
    from score s
    where course_id in
    (
        select s.course_id
        from score s
        where s.stu_id='001'
    )
) and s.stu_id <> '001';
-- 5.2.10 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
select s.stu_name,c.course_name,t2.score,t2.avg_score
from student s left join (
    select s.stu_id,s.course_id,s.score,t1.avg_score
    from score s join
    (
        select s.stu_id,avg(s.score) avg_score
        from score s
        group by s.stu_id
    ) t1 on s.stu_id=t1.stu_id
    ) t2 on s.stu_id=t2.stu_id
join course c on t2.course_id=c.course_id
order by t2.avg_score desc;
