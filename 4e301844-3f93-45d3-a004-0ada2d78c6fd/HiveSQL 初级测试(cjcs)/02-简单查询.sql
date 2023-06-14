select
    *
from student_info
where stu_name like "%冰%";

select
    count(*)  wang_count
from teacher_info
where tea_name like '王%';

select
    stu_id,
    course_id,
    score
from score_info
where course_id ='04' and score<60
order by score desc;

select
    s.stu_id,
    s.stu_name,
    t1.score
from student_info s
join (
    select
        *
    from score_info
    where course_id=(select course_id from course_info where course_name='数学') and score < 60
    ) t1 on s.stu_id = t1.stu_id
order by s.stu_id;

-- 查询编号为 02 的课程总成绩
select course_id, sum(c.score)
from score_info c
where c.course_id='02'
group by course_id;

-- 查询参加考试的学生人数
select count(distinct s.stu_id) stu_num
from score_info s;

-- 查询各科成绩最高和最低的分，以如下的形式显示：课程号，最高分，最低分
select
    course_id,
    max(score) max_score,
    min(score) min_score
from score_info
group by course_id;

-- 查询每门课程有多少学生参加了考试（有考试成绩）
select
    course_id,
    count(stu_id) stu_num
from score_info
group by course_id;

-- 查询男生、女生人数
select
    sex,
    count(stu_id) count
from student_info
group by sex;

-- 查询平均成绩大于60分的学生的学号和平均成绩
select
    stu_id,
    avg(score) score_avg
from score_info
group by stu_id
having score_avg > 60;

-- 查询至少选修四门课程的学生学号
select
    stu_id,
    count(course_id) course_count
from score_info
group by stu_id
having course_count >=4;

-- [课堂讲解]查询同姓（假设每个学生姓名的第一个字为姓）的学生名单并统计同姓人数大于2的姓
select
    t1.first_name,
    count(*) count_first_name
from (
         select
             stu_id,
             stu_name,
             substr(stu_name,0,1) first_name
         from student_info
) t1
group by t1.first_name
having count_first_name >= 2;


