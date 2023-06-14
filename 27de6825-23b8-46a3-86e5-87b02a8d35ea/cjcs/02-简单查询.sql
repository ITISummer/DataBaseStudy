-- 设置本地模式（当数据量较少的时候，设置 hive 本地运行）
set hive.exec.mode.local.auto=true;

set hive.exec.mode.local.auto;
-- 查询姓名中带“冰”的学生名单
select * from student where stu_name like '%冰%';

-- 查询姓“王”老师的个数
select count(1) as count_wang from teacher where tea_name like '王%';

-- 检索课程编号为 "04" 且分数小于60的学生的课程信息，结果按分数降序排列
select c.course_id,c.course_name,s.score
from course c join score s
on c.course_id = s.course_id
where c.course_id = '04' and s.score < 60
order by s.score desc;

-- 查询数学成绩不及格的学生和其对应的成绩，按照学号升序排序
select s2.*,s.score,c.course_id
from score s join course c on s.course_id = c.course_id
join student s2 on s.stu_id = s2.stu_id
where c.course_name='数学' and s.score < 60
order by s.stu_id;