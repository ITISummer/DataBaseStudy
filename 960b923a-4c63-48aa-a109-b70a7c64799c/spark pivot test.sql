create table test_user_tags
(
    uid       string,
    tag_code  STRING,
    tag_value STRING
);
INSERT INTO test_user_tags
VALUES ('101', 'gender', 'f'),
       ('102', 'gender', 'm'),
       ('103', 'gender', 'm'),
       ('104', 'gender', 'f'),
       ('105', 'gender', 'm'),
       ('106', 'gender', 'f'),
       ('101', 'age', '60'),
       ('102', 'age', '70'),
       ('103', 'age', '80'),
       ('104', 'age', '70'),
       ('105', 'age', '90'),
       ('106', 'age', '90'),
       ('101', 'amount', '422'),
       ('102', 'amount', '4443'),
       ('103', 'amount', '12000'),
       ('104', 'amount', '6664'),
       ('105', 'amount', '900'),
       ('106', 'amount', '2000');

-- 聚合列： tagValue 旋转列：tag_code 维度列：uid
-- select * from (select uid,tag_code,tag_value from test_user_tags)t  pivot ( max(tag_value) as tv  for tag_code in ('gender','age','amount' ));
select *
from test_user_tags pivot ( max(tag_value) as tv  for tag_code in ('gender','age','amount' ));

select *
from (select uid, tagValue, 'tag_population_attribute_nature_gender' tagCode
      from upp.tag_population_attribute_nature_gender
      where dt = '2022-06-08'
      union all
      select uid, tagValue, 'tag_population_attribute_nature_period' tagCode
      from upp.tag_population_attribute_nature_period
      where dt = '2022-06-08'
      union all
      select uid, tagValue, 'tag_consumer_behavior_order_amount7d' tagCode
      from upp.tag_consumer_behavior_order_amount7d
      where dt = '2022-06-08') t pivot(
    min(tagValue)
    for tagCode in ('tag_population_attribute_nature_gender',
                  'tag_population_attribute_nature_period',
                   'tag_consumer_behavior_order_amount7d' )
);
