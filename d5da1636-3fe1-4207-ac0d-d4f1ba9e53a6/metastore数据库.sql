use metastore;
update metastore.DBS set DB_LOCATION_URI = 'hdfs://hadoop112:8020/user/hive/warehouse' where DB_ID=1;
update metastore.DBS set DB_LOCATION_URI = 'hdfs://hadoop112:8020/user/hive/warehouse/db_hive1.db' where DB_ID=6;
update metastore.DBS set DB_LOCATION_URI = 'hdfs://hadoop112:8020/user/hive/warehouse/cjcs.db' where DB_ID=11;
show tables;

select * from metastore.AUX_TABLE;
select * from metastore.BUCKETING_COLS;
select * from metastore.CDS;
select * from metastore.COLUMNS_V2;
select * from metastore.COMPACTION_QUEUE;
select * from metastore.COMPLETED_COMPACTIONS;
select * from metastore.COMPLETED_TXN_COMPONENTS;
select * from metastore.CTLGS;
update metastore.CTLGS set LOCATION_URI = 'hdfs://hadoop112:8020/user/hive/warehouse' where CTLG_ID=1;
select * from metastore.DATABASE_PARAMS;
select * from metastore.DBS;
select * from metastore.DB_PRIVS;
select * from metastore.DELEGATION_TOKENS;
select * from metastore.FUNCS;
select * from metastore.FUNC_RU;
# 有值
select * from metastore.GLOBAL_PRIVS;
select * from metastore.HIVE_LOCKS;
select * from metastore.IDXS;
select * from metastore.INDEX_PARAMS;
select * from metastore.I_SCHEMA;
select * from metastore.KEY_CONSTRAINTS;
select * from metastore.MASTER_KEYS;
select * from metastore.MATERIALIZATION_REBUILD_LOCKS;
select * from metastore.METASTORE_DB_PROPERTIES;
select * from metastore.MIN_HISTORY_LEVEL;
select * from metastore.MV_CREATION_METADATA;
select * from metastore.MV_TABLES_USED;
select * from metastore.NEXT_COMPACTION_QUEUE_ID;
select * from metastore.NEXT_LOCK_ID;
select * from metastore.NEXT_TXN_ID;
select * from metastore.NEXT_WRITE_ID;
select * from metastore.NOTIFICATION_LOG;
select * from metastore.NOTIFICATION_SEQUENCE;
select * from metastore.NUCLEUS_TABLES;
select * from metastore.PARTITIONS;
select * from metastore.PARTITION_EVENTS;
select * from metastore.PARTITION_KEYS;
select * from metastore.PARTITION_KEY_VALS;
select * from metastore.PARTITION_PARAMS;
select * from metastore.PART_COL_PRIVS;
select * from metastore.PART_COL_STATS;
select * from metastore.PART_PRIVS;
select * from metastore.REPL_TXN_MAP;
# 有值
select * from metastore.ROLES;
select * from metastore.ROLE_MAP;
select * from metastore.RUNTIME_STATS;
select * from metastore.SCHEMA_VERSION;
# 有值
select * from metastore.SDS;
update SDS set LOCATION = 'hdfs://hadoop112:8020/user/hive/warehouse/stu1' where SD_ID=1;
update SDS set LOCATION = 'hdfs://hadoop112:8020/user/hive/warehouse/teacher' where SD_ID=12;
update SDS set LOCATION = 'hdfs://hadoop112:8020/user/hive/warehouse/teacher1' where SD_ID=13;
update SDS set LOCATION = 'hdfs://hadoop112:8020/user/hive/warehouse/teacher2' where SD_ID=14;
update SDS set LOCATION = 'hdfs://hadoop112:8020/user/hive/warehouse/student' where SD_ID=16;
update SDS set LOCATION = 'hdfs://hadoop112:8020/user/hive/warehouse/student1' where SD_ID=17;
update SDS set LOCATION = 'hdfs://hadoop112:8020/user/hive/warehouse/student2' where SD_ID=18;
update SDS set LOCATION = 'hdfs://hadoop112:8020/user/hive/warehouse/dept' where SD_ID=19;
update SDS set LOCATION = 'hdfs://hadoop112:8020/user/hive/warehouse/emp' where SD_ID=20;
update SDS set LOCATION = 'hdfs://hadoop112:8020/user/hive/warehouse/location' where SD_ID=21;
update SDS set LOCATION ='hdfs://hadoop112:8020/user/hive/warehouse/cjcs.db/student_info' where SD_ID=22;
update SDS set LOCATION ='hdfs://hadoop112:8020/user/hive/warehouse/cjcs.db/course_info' where SD_ID=23;
update SDS set LOCATION ='hdfs://hadoop112:8020/user/hive/warehouse/cjcs.db/teacher_info' where SD_ID=24;
update SDS set LOCATION ='hdfs://hadoop112:8020/user/hive/warehouse/cjcs.db/score_info' where SD_ID=25;


select * from metastore.SD_PARAMS;
# 有值
select * from metastore.SEQUENCE_TABLE;
select * from metastore.SERDES;
# 有值
select * from metastore.SERDE_PARAMS;
select * from metastore.SKEWED_COL_NAMES;
select * from metastore.SKEWED_COL_VALUE_LOC_MAP;
select * from metastore.SKEWED_STRING_LIST;
select * from metastore.SKEWED_STRING_LIST_VALUES;
select * from metastore.SKEWED_VALUES;
select * from metastore.SORT_COLS;
# 有值
select * from metastore.TABLE_PARAMS;
# 有值
select * from metastore.TAB_COL_STATS;
# 有值
select * from metastore.TBLS;
select * from metastore.TBL_COL_PRIVS;
# 有值
select * from metastore.TBL_PRIVS;
select * from metastore.TXNS;
select * from metastore.TXN_COMPONENTS;
select * from metastore.TXN_TO_WRITE_ID;
select * from metastore.TYPES;
select * from metastore.TYPE_FIELDS;
# 有值
select * from metastore.VERSION;
select * from metastore.WM_MAPPING;
select * from metastore.WM_POOL;
select * from metastore.WM_POOL_TO_TRIGGER;
select * from metastore.WM_RESOURCEPLAN;
select * from metastore.WM_TRIGGER;
select * from metastore.WRITE_SET;