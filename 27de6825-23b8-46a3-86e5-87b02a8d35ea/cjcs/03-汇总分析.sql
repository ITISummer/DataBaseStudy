set hive.exec.mode.local.auto=true;
set hive.exec.mode.local.auto;
use cjcs;
-- 查询编号为'02'的课程的总成绩
select s.course_id, sum(s.score)
from score s
where s.course_id='02'
group by s.course_id;
-- 查询参加考试的学生个数
select * from score;
select * from student;
select count(distinct s.stu_id)
from score s;
-- 查询各科成绩最高和最低的分，以如下的形式显示：课程号，最高分，最低分
select s.course_id,max(s.score),min(s.score)
from score s
group by s.course_id;
-- 查询每门课程有多少学生参加了考试（有考试成绩）
select s.course_id, count(1)
from score s
group by s.course_id;
-- 查询男生、女生人数
select s.sex,count(1)
from student s
group by s.sex;
-- 查询平均成绩大于60分的学生的学号和平均成绩
select s.stu_id,avg(s.score)
from score s
group by s.stu_id
having avg(s.score)>60;
-- 查询至少选修四门课程的学生学号
select s.stu_id, count(s.course_id) cnt
from score s
group by s.stu_id
having cnt>=4;
-- [课堂讲解]查询同姓（假设每个学生姓名的第一个字为姓）的学生名单并统计同姓人数大于2的姓
select substring(s.stu_name,1,1), count(substring(s.stu_name,1,1)) cnt
from student s
group by substring(s.stu_name,1,1)
having cnt>=2;

select substr(s.stu_name,1,1), count(substr(s.stu_name,1,1)) cnt
from student s
group by substr(s.stu_name,1,1)
having cnt>=2;
-- 查询每门课程的平均成绩，结果按平均成绩升序排序，平均成绩相同时，按课程号降序排列
select s.course_id, avg(s.score) score_avg
from score s
group by s.course_id
order by score_avg asc, s.course_id desc;
-- 统计参加考试人数大于等于15的学科
select s.course_id, count(1) cnt
from score s
group by s.course_id
having cnt>15;
-- 查询学生的总成绩并按照总成绩降序排序
select s.stu_id, sum(s.score) score_sum
from score s
group by s.stu_id
order by score_sum desc;
-- [课堂讲解]按照如下格式显示学生的语文、数学、英语三科成绩，没有成绩的输出为0，按照学生的有效平均成绩降序显示
-- 学生id 语文 数学 英语 有效课程数 有效平均成绩
select s.stu_id,
       sum(if(c.course_name='语文',s.score,0)) `语文`,
       sum(if(c.course_name='数学',s.score,0)) `数学`,
       sum(if(c.course_name='英语',s.score,0)) `英语`,
       count(1) `有效课程数`,
       avg(s.score) `平均成绩`
from score s join course c
on s.course_id = c.course_id
group by s.stu_id
order by `平均成绩` desc;
-- 查询一共参加三门课程且其中一门为语文课程的学生的id和姓名
select t1.stu_id,s3.stu_name
from (
    select s.stu_id,count(1) cnt
    from score s
    group by s.stu_id
    having cnt=3
) t1 join score s2
on t1.stu_id=s2.stu_id
join student s3 on t1.stu_id = s3.stu_id
where s2.course_id='01';


