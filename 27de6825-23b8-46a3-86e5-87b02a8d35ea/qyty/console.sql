set hive.exec.mode.local.auto=true;
set hive.exec.mode.local.auto;
use qyty;

-- 订单数据
drop table if exists order_detail;
create table order_detail(
  id           string comment '订单id',
  user_id      string comment '用户id',
  product_id   string comment '商品id',
  province_id  string comment '省份id',
  create_time  string comment '下单时间',
  product_num  int comment '商品件数',
  total_amount decimal(16, 2) comment '下单金额'
)
partitioned by (dt string)
row format delimited fields terminated by '\t';

load data local inpath '/opt/module/hive/datas/order_detail.txt' overwrite into table order_detail partition(dt='2020-06-14');

select * from order_detail limit 1;

-- 支付数据
drop table if exists payment_detail;
create table payment_detail(
    id              string comment '支付id',
    order_detail_id string comment '订单明细id',
    user_id         string comment '用户id',
    payment_time    string comment '支付时间',
    total_amount    decimal(16, 2) comment '支付金额'
)
partitioned by (dt string)
row format delimited fields terminated by '\t';

load data local inpath '/opt/module/hive/datas/payment_detail.txt' overwrite into table payment_detail partition(dt='2020-06-14');

select * from payment_detail limit 1;
-- 商品信息表
drop table if exists product_info;
create table product_info(
    id           string comment '商品id',
    product_name string comment '商品名称',
    price        decimal(16, 2) comment '价格',
    category_id  string comment '分类id'
)
row format delimited fields terminated by '\t';

load data local inpath '/opt/module/hive/datas/product_info.txt' overwrite into table product_info;

select * from product_info limit 1;
-- 省份信息表
drop table if exists province_info;
create table province_info(
    id            string comment '省份id',
    province_name string comment '省份名称'
)
row format delimited fields terminated by '\t';

load data local inpath '/opt/module/hive/datas/province_info.txt' overwrite into table province_info;
select * from province_info limit 1;
