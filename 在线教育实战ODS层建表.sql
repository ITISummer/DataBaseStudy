-- 全量表 ods_表名_full
-- 增量表 ods_表名_inc

-- ===============全量表 ods_表名_full===============
-- 分类表
DROP TABLE IF EXISTS ods_base_category_info_full;
CREATE EXTERNAL TABLE ods_base_category_info_full(
    `id`  STRING COMMENT '编号（主键）',
    `category_name`  STRING COMMENT '分类名称',
    `create_time`  STRING COMMENT '创建时间',
    `update_time`  STRING COMMENT '更新时间',
    `deleted`  STRING COMMENT '是否删除'
) COMMENT '分类表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_base_category_info_full/';

-- 省份表
DROP TABLE IF EXISTS ods_base_province_full;
CREATE EXTERNAL TABLE ods_base_province_full(
    `id` STRING COMMENT '编号（主键）',
    `name` STRING COMMENT '省份名称',
    `region_id` STRING COMMENT '大区id',
    `area_code` STRING COMMENT '行政区位码',
    `iso_code` STRING COMMENT '国际编码',
    `iso_3166_2` STRING COMMENT 'ISO3166 编码'
) COMMENT '省份表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_base_province_full/';

-- 来源表
DROP TABLE IF EXISTS ods_base_source_full;
CREATE EXTERNAL TABLE ods_base_source_full(
`id`  STRING COMMENT '引流来源id',
`source_site` STRING COMMENT '引流来源名称',
`source_url` STRING COMMENT '引流来源链接'
) COMMENT '来源表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_base_source_full/';

-- 科目表
DROP TABLE IF EXISTS ods_base_subject_info_full;
CREATE EXTERNAL TABLE ods_base_subject_info_full(
`id`   STRING COMMENT '编号（主键）',
`subject_name` STRING COMMENT '科目名称',
`category_id`  STRING COMMENT '分类',
`create_time`  STRING COMMENT '创建时间',
`update_time`  STRING COMMENT '更新时间',
`deleted`  STRING COMMENT '是否删除'
) COMMENT '科目表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_base_subject_info_full/';

-- 章节表
DROP TABLE IF EXISTS ods_chapter_info_full;
CREATE EXTERNAL TABLE ods_chapter_info_full(
    `id` STRING COMMENT '引流来源链接编号（主键）',
    `chapter_name` STRING COMMENT '章节名称',
    `course_id` STRING COMMENT '课程id',
    `video_id` STRING COMMENT '视频id',
    `publisher_id` STRING COMMENT '发布者id',
    `is_free` STRING COMMENT '是否免费',
    `create_time` STRING COMMENT '创建时间',
    `deleted` STRING COMMENT '是否删除',
    `update_time` STRING COMMENT '更新时间'
) COMMENT '章节表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_chapter_info_full/';

-- 课程信息表
DROP TABLE IF EXISTS ods_course_info_full;
CREATE EXTERNAL TABLE ods_course_info_full(
    `id` STRING COMMENT '编号（主键）',
    `course_name` STRING COMMENT '课程名称',
    `course_slogan` STRING COMMENT '课程标语',
    `course_cover_url` STRING COMMENT '课程封面',
    `subject_id` STRING COMMENT '学科id',
    `teacher` STRING COMMENT '讲师名称',
    `publisher_id` STRING COMMENT '发布者id',
    `chapter_num` BIGINT COMMENT '章节数',
    `origin_price` STRING COMMENT '价格',
    `reduce_amount` STRING COMMENT '优惠金额',
    `actual_price` DECIMAL(16,2) COMMENT '实际价格',
    `course_introduce` STRING COMMENT '课程介绍',
    `create_time` STRING COMMENT '创建时间',
    `deleted` STRING COMMENT '是否删除',
    `update_time` STRING COMMENT '更新时间'
) COMMENT '课程信息表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_course_info_full/';

-- 知识点表
DROP TABLE IF EXISTS ods_knowledge_point_full;
CREATE EXTERNAL TABLE ods_knowledge_point_full(
    `id` STRING COMMENT '编号（主键）',
    `point_txt` STRING COMMENT '知识点内容',
    `point_level` STRING COMMENT '知识点级别',
    `course_id` STRING COMMENT '课程id',
    `chapter_id` STRING COMMENT '章节id',
    `create_time` STRING COMMENT '创建时间',
    `update_time` STRING COMMENT '修改时间',
    `publisher_id` STRING COMMENT '发布者id',
    `deleted` STRING COMMENT '是否删除'
) COMMENT '知识点表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_knowledge_point_full/';

-- 试卷表
DROP TABLE IF EXISTS ods_test_paper_full;
CREATE EXTERNAL TABLE ods_test_paper_full(
    `id` STRING COMMENT '编号（主键）',
    `paper_title` STRING COMMENT '试卷名称',
    `course_id` STRING COMMENT '课程id',
    `create_time` STRING COMMENT '创建时间',
    `update_time` STRING COMMENT '更新时间',
    `publisher_id` STRING COMMENT '发布者id',
    `deleted` STRING COMMENT '是否删除'
) COMMENT '试卷表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_test_paper_full/';

-- 试卷问题表
DROP TABLE IF EXISTS ods_test_paper_question_full;
CREATE EXTERNAL TABLE ods_test_paper_question_full(
    `id` STRING COMMENT '编号（主键）',
    `paper_id` STRING COMMENT '试卷id',
    `question_id` STRING COMMENT '题目id',
    `score` STRING COMMENT '得分',
    `create_time` STRING COMMENT '创建时间',
    `deleted` STRING COMMENT '是否删除',
    `publisher_id` STRING COMMENT '发布者id'
) COMMENT '试卷问题表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_test_paper_question_full/';

-- 知识点问题表
DROP TABLE IF EXISTS ods_test_point_question_full;
CREATE EXTERNAL TABLE ods_test_point_question_full(
    `id` STRING COMMENT '编号（主键）',
    `point_id` STRING COMMENT '知识点id',
    `question_id` STRING COMMENT '问题id',
    `create_time` STRING COMMENT '创建时间',
    `publisher_id` STRING COMMENT '发布者id',
    `deleted` STRING COMMENT '是否删除'
) COMMENT '知识点问题表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_test_point_question_full/';

-- 问题信息表
DROP TABLE IF EXISTS ods_test_question_info_full;
CREATE EXTERNAL TABLE ods_test_question_info_full(
    `id` STRING COMMENT '编号（主键）',
    `question_txt` STRING COMMENT '题目内容',
    `chapter_id` STRING COMMENT '章节id',
    `course_id` STRING COMMENT '课程id',
    `question_type` STRING COMMENT '题目类型',
    `create_time` STRING COMMENT '创建时间',
    `update_time` STRING COMMENT '更新时间',
    `publisher_id` STRING COMMENT '发布者id',
    `deleted` STRING COMMENT '是否删除'
) COMMENT '问题信息表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_test_question_info_full/';

-- 问题选项表
DROP TABLE IF EXISTS ods_test_question_option_full;
CREATE EXTERNAL TABLE ods_test_question_option_full(
    `id` STRING COMMENT '编号（主键）',
    `option_txt` STRING COMMENT '选项内容',
    `question_id` STRING COMMENT '题目id',
    `is_correct` STRING COMMENT '是否正确',
    `create_time` STRING COMMENT '创建时间',
    `update_time` STRING COMMENT '更新时间',
    `deleted` STRING COMMENT '是否删除'
) COMMENT '问题选项表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_test_question_option_full/';

-- 测验表
DROP TABLE IF EXISTS ods_test_exam_full;
CREATE EXTERNAL TABLE ods_test_exam_full(
    `id` STRING COMMENT '编号（主键）',
    `paper_id` STRING COMMENT '考卷id',
    `user_id` STRING COMMENT '用户id',
    `score` STRING COMMENT '分数',
    `duration_sec` STRING COMMENT '所用时长',
    `create_time` STRING COMMENT '创建时间',
    `submit_time` STRING COMMENT '提交时间',
    `update_time` STRING COMMENT '更新时间',
    `deleted` STRING COMMENT '是否删除'
) COMMENT '测验表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_test_exam_full/';

-- 测验问题表
DROP TABLE IF EXISTS ods_test_exam_question_full;
CREATE EXTERNAL TABLE ods_test_exam_question_full(
    `id` STRING COMMENT '编号（主键）',
    `exam_id` STRING COMMENT '考试id',
    `paper_id` STRING COMMENT '试卷id',
    `question_id` STRING COMMENT '问题id',
    `user_id` STRING COMMENT '用户id',
    `answer` STRING COMMENT '答案',
    `is_correct` STRING COMMENT '是否正确',
    `score` STRING COMMENT '本题得分',
    `create_time` STRING COMMENT '创建时间',
    `update_time` STRING COMMENT '更新时间',
    `deleted` STRING COMMENT '是否删除'
) COMMENT '测验问题表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_test_exam_question_full/';

-- 视频表
DROP TABLE IF EXISTS ods_video_info_full;
CREATE EXTERNAL TABLE ods_video_info_full(
    `id` STRING COMMENT '编号（主键）',
    `video_name` STRING COMMENT '视频名称',
    `during_sec` STRING COMMENT '时长',
    `video_status` STRING COMMENT '状态 未上传，上传中，上传完',
    `video_size` BIGINT COMMENT '大小',
    `video_url` STRING COMMENT '视频存储路径',
    `video_source_id` STRING COMMENT '云端资源编号',
    `version_id` STRING COMMENT '版本号',
    `chapter_id` STRING COMMENT '章节id',
    `course_id` STRING COMMENT '课程id',
    `publisher_id` STRING COMMENT '发布者id',
    `create_time` STRING COMMENT '创建时间',
    `update_time` STRING COMMENT '更新时间',
    `deleted` STRING COMMENT '是否删除'
) COMMENT '视频表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_video_info_full/';


-- ===============增量表 ods_表名_inc===============
-- 日志表(需要重导)
DROP TABLE IF EXISTS ods_log_inc;
CREATE EXTERNAL TABLE ods_log_inc
(
    `common`   STRUCT<
    ar :STRING,
    ba :STRING,
    ch :STRING,
    is_new :STRING,
    md :STRING,
    mid :STRING,
    os :STRING,
    sc :STRING, -- 新增
    sid :STRING,
    uid :STRING,
    vc :STRING> COMMENT '公共信息',
    -- 新增
    `appVideo` STRUCT<play_sec: BIGINT,
    position_sec: BIGINT,
    video_id: STRING>,
    `page`     STRUCT<during_time :STRING,
    item :STRING,
    item_type :STRING,
    last_page_id :STRING,
    page_id :STRING> COMMENT '页面信息',
    `actions`  ARRAY<STRUCT<action_id:STRING,
    item:STRING,
    item_type:STRING,
    ts:BIGINT>> COMMENT '动作信息',
    `displays` ARRAY<STRUCT<
    display_type :STRING,
    item :STRING,
    item_type :STRING,
    `order`: BIGINT, -- 新增
    pos_id :STRING>> COMMENT '曝光信息',
    `start`    STRUCT<
    entry :STRING,
    first_open :BIGINT,
    loading_time :BIGINT,
    open_ad_id :BIGINT,
    open_ad_ms :BIGINT,
    open_ad_skip_ms :BIGINT> COMMENT '启动信息',
    `err`      STRUCT<
    error_code:BIGINT,
    msg:STRING> COMMENT '错误信息',
    `ts`       BIGINT  COMMENT '时间戳'
) COMMENT '日志信息表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_log_inc/';

-- load data inpath '/edu_origin_data/edu/log/edu_topic_log/2022-06-08' overwrite into table edu.ods_log_inc partition (dt='2022-06-08');

-- 购物车表(需要重导)
DROP TABLE IF EXISTS ods_cart_info_inc;
CREATE EXTERNAL TABLE ods_cart_info_inc
(
    `type` STRING COMMENT '变动类型',
    `ts`   BIGINT COMMENT '变动时间',
    `data` STRUCT<id :BIGINT,
                  user_id :BIGINT,
                  course_id :BIGINT,
                  course_name :STRING,
                  cart_price :DECIMAL(16,2),
                  img_url :STRING,
                  session_id :STRING,
                  create_time :STRING,
                  update_time :STRING,
                  deleted :STRING,
                  sold :STRING>,
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '购物车表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_cart_info_inc/';

-- load data inpath '/edu_origin_data_bak/edu/db/cart_info_inc/2022-06-08' overwrite into table edu.ods_cart_info_inc partition (dt='2022-06-08');

-- 章节评价表
DROP TABLE IF EXISTS ods_comment_info_inc;
CREATE EXTERNAL TABLE  ods_comment_info_inc(

`type` STRING COMMENT '变动类型',
    `ts`   BIGINT COMMENT '变动时间',
    `data` STRUCT<
            id : BIGINT,
            user_id : BIGINT,
            chapter_id : BIGINT,
            course_id : BIGINT,
            comment_txt : STRING,
            create_time : STRING,
            deleted : STRING
    >,
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '章节评价表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_comment_info_inc/';

-- 收藏表
DROP TABLE IF EXISTS ods_favor_info_inc;
CREATE EXTERNAL TABLE  ods_favor_info_inc(

`type` STRING COMMENT '变动类型',
    `ts`   BIGINT COMMENT '变动时间',
    `data` STRUCT<
            id : BIGINT,
            course_id : BIGINT,
            user_id : BIGINT,
            create_time : STRING,
            update_time : STRING,
            deleted : STRING
    >,
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '收藏表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_favor_info_inc/';

-- 订单明细表
DROP TABLE IF EXISTS ods_order_detail_inc;
CREATE EXTERNAL TABLE  ods_order_detail_inc(

`type` STRING COMMENT '变动类型',
    `ts`   BIGINT COMMENT '变动时间',
    `data` STRUCT<
            id : BIGINT,
            course_id : BIGINT,
            course_name : STRING,
            order_id : BIGINT,
            user_id : BIGINT,
            origin_amount : DECIMAL(16,2),
            coupon_reduce : DECIMAL(16,2),
            final_amount : DECIMAL(16,2),
            create_time : STRING,
            update_time : STRING
    >,
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '订单明细表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_order_detail_inc/';

-- 订单表
DROP TABLE IF EXISTS ods_order_info_inc;
CREATE EXTERNAL TABLE  ods_order_info_inc(

    `type` STRING COMMENT '变动类型',
    `ts`   BIGINT COMMENT '变动时间',
    `data` STRUCT<
            id :BIGINT,
            user_id :BIGINT,
            origin_amount :DECIMAL(16,2),
            coupon_reduce :DECIMAL(16,2),
            final_amount :DECIMAL(16,2),
            order_status :String,
            out_trade_no :String,
            trade_body :String,
            session_id :String,
            province_id :BIGINT,
            create_time :String,
            expire_time :String,
            update_time :String
    >,
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '订单表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_order_info_inc/';

-- 支付表
DROP TABLE IF EXISTS ods_payment_info_inc;
CREATE EXTERNAL TABLE  ods_payment_info_inc(

`type` STRING COMMENT '变动类型',
    `ts`   BIGINT COMMENT '变动时间',
    `data` STRUCT<
            id :STRING,
            out_trade_no :STRING,
            order_id :BIGINT,
            alipay_trade_no :STRING,
            total_amount :DECIMAL(16,2),
            trade_body :STRING,
            payment_type :STRING,
            payment_status :STRING,
            create_time :STRING,
            update_time :STRING,
            callback_content :STRING,
            callback_time :STRING
    >,
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '支付表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_payment_info_inc/';

-- 课程评价表
DROP TABLE IF EXISTS ods_review_info_inc;
CREATE EXTERNAL TABLE  ods_review_info_inc(

`type` STRING COMMENT '变动类型',
    `ts`   BIGINT COMMENT '变动时间',
    `data` STRUCT<
            id :BIGINT,
            user_id :BIGINT,
            course_id :BIGINT,
            review_txt :STRING,
            review_stars :BIGINT,
            create_time :STRING,
            deleted :STRING
    >,
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '课程评价表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_review_info_inc/';

-- 用户章节进度表
DROP TABLE IF EXISTS ods_user_chapter_process_inc;
CREATE EXTERNAL TABLE  ods_user_chapter_process_inc(

    `type` STRING COMMENT '变动类型',
    `ts`   BIGINT COMMENT '变动时间',
    `data` STRUCT<
            id :BIGINT,
            course_id :BIGINT,
            chapter_id :BIGINT,
            user_id :BIGINT,
            position_sec :BIGINT,
            create_time :STRING,
            update_time :STRING,
            deleted :STRING
    >,
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '用户章节进度表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_user_chapter_process_inc/';

-- 用户章节进度表
DROP TABLE IF EXISTS ods_user_info_inc;
CREATE EXTERNAL TABLE  ods_user_info_inc(

`type` STRING COMMENT '变动类型',
    `ts`   BIGINT COMMENT '变动时间',
    `data` STRUCT<
            id :BIGINT,
            login_name :STRING,
            nick_name :STRING,
            passwd :STRING,
            real_name :STRING,
            phone_num :STRING,
            email :STRING,
            head_img :STRING,
            user_level :STRING,
            birthday :STRING,
            gender :STRING,
            create_time :STRING,
            operate_time :STRING,
            `status` :STRING
    >,
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '用户章节进度表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_user_info_inc/';

-- VIP 变化表
DROP TABLE IF EXISTS ods_vip_change_detail_inc;
CREATE EXTERNAL TABLE  ods_vip_change_detail_inc(

`type` STRING COMMENT '变动类型',
    `ts`   BIGINT COMMENT '变动时间',
    `data` STRUCT<
            id :BIGINT,
            user_id :BIGINT,
            from_vip :BIGINT,
            to_vip :BIGINT,
            create_time :STRING
    >,
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT 'VIP 变化表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_vip_change_detail_inc/';


-- 导数据脚本
-- edu_hdfs_to_ods_log.sh '2022-06-08'
-- edu_hdfs_to_ods_db.sh all/表名 '2022-06-08'
