select count(1) from edu.user_info;
select * from edu.user_info limit 50;

update edu.user_info set login_name='aaaa' where id=1;

create database maxwell;
create user 'maxwell'@'%' identified by 'maxwell';
grant all on maxwell.* to 'maxwell'@'%';
grant select, replication client, replication slave on *.* to 'maxwell'@'%';

show tables;
select * from bootstrap;
select * from columns;
select * from `databases`;
select * from heartbeats;
select * from positions;
select * from `schemas`;
select * from tables where database_id=1;



