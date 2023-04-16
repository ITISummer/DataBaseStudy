set hive.exec.mode.local.auto=true;
set hive.exec.mode.local.auto;
use cjcs;
-- 4.1.1 [课堂讲解]查询所有课程成绩均小于60分的学生的学号、姓名
select t1.stu_id,s.stu_name
from (
    select s.stu_id
    from score s
    group by s.stu_id
    having max(s.score) < 60
) t1 join student s
on t1.stu_id = s.stu_id;
-- 4.1.2 查询没有学全所有课的学生的学号、姓名
select t1.stu_id,s3.stu_name from (
    select s.stu_id,count(1) cnt
    from student s left join score s2
    on s.stu_id = s2.stu_id
    group by s.stu_id
    having cnt < 5
) t1 join student s3
on t1.stu_id = s3.stu_id;
-- 4.1.3 查询出只选修了三门课程的全部学生的学号和姓名
select t1.stu_id,s.stu_name
from(
    select s.stu_id, count(1) cnt
    from score s
    group by s.stu_id
    having cnt=3
) t1 join student s
on t1.stu_id=s.stu_id;

