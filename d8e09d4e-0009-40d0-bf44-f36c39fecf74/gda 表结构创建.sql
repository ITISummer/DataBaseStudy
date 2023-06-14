# 元数据表表结构如下：
drop table if exists table_meta_info;
create table  table_meta_info
(
    id                      bigint auto_increment comment '表id' primary key,
    table_name              varchar(200)  null comment '表名',
    schema_name             varchar(200)  null comment '库名',
    col_name_json           varchar(2000) null comment '字段名json ( 来源:hive)',
    partition_col_name_json varchar(4000) null comment '分区字段名json( 来源:hive)',
    table_fs_owner          varchar(200)  null comment 'hdfs所属人 ( 来源:hive)',
    table_parameters_json   varchar(2000) null comment '参数信息 ( 来源:hive)',
    table_comment           varchar(200)  null comment '表备注 ( 来源:hive)',
    table_fs_path           varchar(200)  null comment 'hdfs路径 ( 来源:hive)',
    table_input_format      varchar(200)  null comment '输入格式( 来源:hive)',
    table_output_format     varchar(200)  null comment '输出格式 ( 来源:hive)',
    table_row_format_serde  varchar(200)  null comment '行格式 ( 来源:hive)',
    table_create_time       varchar(200)  null comment '表创建时间 ( 来源:hive)',
    table_type              varchar(200)  null comment '表类型 ( 来源:hive)',
    table_bucket_cols_json  varchar(200)  null comment '分桶列 ( 来源:hive)',
    table_bucket_num        bigint        null comment '分桶个数 ( 来源:hive)',
    table_sort_cols_json    varchar(200)  null comment '排序列 ( 来源:hive)',
    table_size              bigint        null comment '数据量大小 ( 来源:hdfs)',
    table_total_size        bigint        null comment '所有副本数据总量大小  ( 来源:hdfs)',
    table_last_modify_time  datetime      null comment '最后修改时间   ( 来源:hdfs)',
    table_last_access_time  datetime      null comment '最后访问时间   ( 来源:hdfs)',
    fs_capcity_size         bigint        null comment '当前文件系统容量   ( 来源:hdfs)',
    fs_used_size            bigint        null comment '当前文件系统使用量   ( 来源:hdfs)',
    fs_remain_size          bigint        null comment '当前文件系统剩余量   ( 来源:hdfs)',
    assess_date             varchar(10)   null comment '考评日期 ',
    create_time             datetime      null comment '创建时间 (自动生成)',
    update_time             datetime      null comment '更新时间  (自动生成)',
    constraint table_meta_info_pk
        unique (table_name, schema_name, assess_date)
)
    comment '元数据表';


# 4.4查询Hive中各表的元数据
# 4.7.1创建辅助信息表
drop table if exists table_meta_info_extra;
create table if not exists table_meta_info_extra
(
    id                   bigint auto_increment comment '表id'
        primary key,
    table_name           varchar(200) null comment '表名',
    schema_name          varchar(200) null comment '库名',
    tec_owner_user_name  varchar(20)  null comment '技术负责人   ',
    busi_owner_user_name varchar(20)  null comment '业务负责人 ',
    lifecycle_type       varchar(20)  null comment '存储周期类型(FOREVER、NORMAL、UNSET)',
    lifecycle_days       bigint       null comment '生命周期(天) ',
    security_level       varchar(20)  null comment '安全级别 (UNSET、PUBLIC、INSIDE、INSIDE_LIMIT、PROTECT)',
    dw_level             varchar(20)  null comment '数仓所在层级(ODSDWDDIMDWSADS) ( 来源: 附加)',
    create_time          datetime     null comment '创建时间 (自动生成)',
    update_time          datetime     null comment '更新时间  (自动生成)',
    constraint table_meta_info_extra_pk
        unique (table_name, schema_name)
)
    comment '元数据表附加信息';

# 6.2.1考评指标参数表
create table governance_metric
(
    id                 bigint auto_increment comment 'id' primary key,
    metric_name        varchar(200)  null comment '指标名称',
    metric_code        varchar(200)  null comment '指标编码',
    metric_desc        varchar(2000) null comment '指标描述',
    governance_type    varchar(20)   null comment '治理类型',
    metric_params_json varchar(2000) null comment '指标参数',
    governance_url     varchar(500)  null comment '治理连接',
    is_disabled        varchar(1)    null comment '是否启用'
)
    comment '考评指标参数表';

# 6.2.2考评指标类别权重表
CREATE TABLE `governance_type` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `type_code` varchar(200) DEFAULT NULL COMMENT '治理项类型编码',
  `type_desc` varchar(2000) DEFAULT NULL COMMENT '治理项类型描述',
  `type_weight` decimal(10,2) DEFAULT NULL COMMENT '治理类型权重',
  PRIMARY KEY (`id`)
)
COMMENT='治理考评类别权重表';

# 6.2.3 治理考评结果明细
CREATE TABLE `governance_assess_detail` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `assess_date` varchar(20) DEFAULT NULL COMMENT '考评日期',
  `table_name` varchar(200) DEFAULT NULL COMMENT '表名',
  `schema_name` varchar(200) DEFAULT NULL COMMENT '库名',
  `metric_id` varchar(200) DEFAULT NULL COMMENT '指标项id',
  `metric_name` varchar(200) DEFAULT NULL COMMENT '指标项名称',
  `governance_type` varchar(200) DEFAULT NULL COMMENT '治理类型',
  `tec_owner` varchar(200) DEFAULT NULL COMMENT '技术负责人',
  `assess_score` decimal(10,2) DEFAULT NULL COMMENT '考评得分',
  `assess_problem` varchar(2000) DEFAULT NULL COMMENT '考评问题项',
  `assess_comment` varchar(2000) DEFAULT NULL COMMENT '考评备注',
  `is_assess_exception` varchar(1) DEFAULT '0' COMMENT '考评是否异常',
  `assess_exception_msg` varchar(2000) DEFAULT NULL COMMENT '异常信息',
  `governance_url` varchar(2000) DEFAULT NULL COMMENT '治理处理路径',
  `create_time` datetime DEFAULT NULL COMMENT '创建日期',
  PRIMARY KEY (`id`)
)
COMMENT='治理考评结果明细';

-- 9.1.1  各表的考评结果表
create table if not exists governance_assess_table(
    id                   bigint auto_increment comment 'id' primary key,
    assess_date          varchar(10)    null comment '考评日期',
    table_name           varchar(200)   null comment '表名',
    schema_name          varchar(200)   null comment '库名',
    tec_owner            varchar(200)   null comment '技术负责人',
    score_spec_avg       decimal(10, 2) null comment '规范分数',
    score_storage_avg    decimal(10, 2) null comment '存储分数',
    score_calc_avg       decimal(10, 2) null comment '计算分数',
    score_quality_avg    decimal(10, 2) null comment '质量分数',
    score_security_avg   decimal(10, 2) null comment '安全分数',
    score_on_type_weight decimal(10, 2) null comment '五维权重后分数',
    problem_num          bigint         null comment '问题项个数',
    create_time          datetime       null comment '创建日期')
    comment '表治理考评情况';

# 9.2.1  各个技术负责人的考评结果表
create table if not exists governance_assess_tec_owner(
    id             bigint auto_increment comment 'id' primary key,
    assess_date    varchar(10)    null comment '考评日期',
    tec_owner      varchar(200)   null comment '技术负责人',
    score_spec     decimal(10, 2) null comment '规范分数',
    score_storage  decimal(10, 2) null comment '存储分数',
    score_calc     decimal(10, 2) null comment '计算分数',
    score_quality  decimal(10, 2) null comment '质量分数',
    score_security decimal(10, 2) null comment '安全分数',
    score          decimal(10, 2) null comment '分数',
    table_num      bigint         null comment '涉及表',
    problem_num    bigint         null comment '问题项个数',
    create_time    datetime       null comment '创建时间')
    comment '技术负责人治理考评表';

# 9.3.1  各个全局的考评结果表
create table if not exists governance_assess_global(
    id             bigint auto_increment comment 'id' primary key,
    assess_date    varchar(10)    null comment '考评日期',
    score_spec     decimal(10, 2) null comment '规范分数',
    score_storage  decimal(10, 2) null comment '存储分数',
    score_calc     decimal(10, 2) null comment '计算分数',
    score_quality  decimal(10, 2) null comment '质量分数',
    score_security decimal(10, 2) null comment '安全分数',
    score          decimal(10, 2) null comment '分数',
    table_num      bigint         null comment '涉及表',
    problem_num    bigint         null comment '问题项个数',
    create_time    datetime       null comment '创建时间')
    comment '治理总考评表';