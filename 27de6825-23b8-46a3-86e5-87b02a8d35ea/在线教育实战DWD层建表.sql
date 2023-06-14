-- 互动域收藏课程事务事实表
DROP TABLE IF EXISTS dwd_interaction_favor_add_inc;
CREATE EXTERNAL TABLE dwd_interaction_favor_add_inc
(
    `id`          STRING COMMENT '编号',
    `user_id`     STRING COMMENT '用户id',
    `course_id`      STRING COMMENT '课程id',
    `create_time` STRING COMMENT '收藏时间'
) COMMENT '互动域收藏课程事务事实表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dwd/dwd_interaction_favor_add_inc/'
    TBLPROPERTIES ("orc.compress" = "snappy");

-- 互动域用户课程评价事务事实表
DROP TABLE IF EXISTS dwd_interaction_course_review_inc;
CREATE EXTERNAL TABLE dwd_interaction_course_review_inc
(
    `id`          STRING COMMENT '编号',
    `user_id`     STRING COMMENT '用户id',
    `course_id`      STRING COMMENT '课程id',
    `review_stars` BIGINT COMMENT '课程评分 1-5'
) COMMENT '互动域用户课程评价事务事实表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dwd/dwd_interaction_course_review_inc/'
    TBLPROPERTIES ("orc.compress" = "snappy");


-- 互动域用户章节评价事务事实表
DROP TABLE IF EXISTS dwd_interaction_chapter_review_inc;
CREATE EXTERNAL TABLE dwd_interaction_chapter_review_inc
(
    `id`          STRING COMMENT '编号',
    `user_id`     STRING COMMENT '用户id',
    `chapter_id`  BIGINT COMMENT '章节id',
    `position_sec` BIGINT COMMENT '章节进度'
) COMMENT '互动域用户章节评价事务事实表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dwd/dwd_interaction_chapter_review_inc/'
    TBLPROPERTIES ("orc.compress" = "snappy");


-- 互动域用户测验事务事实表
DROP TABLE IF EXISTS dwd_interaction_exam_test_inc;
CREATE EXTERNAL TABLE dwd_interaction_exam_test_inc
(
    `id`          STRING COMMENT '测验id',
    `user_id`     STRING COMMENT '用户id',
    `paper_id` STRING COMMENT '考卷id',
    `score` STRING COMMENT '分数'
) COMMENT '互动域用户测验事务事实表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dwd/dwd_interaction_exam_test_inc/'
    TBLPROPERTIES ("orc.compress" = "snappy");
