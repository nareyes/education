/*
- time travel 
- data_retention_time_in_days parameter
- time travel sql extensions
*/

-- set context
use role accountadmin;


-- create demo objects
create database demo_db;

create schema demo_schema;

create table demo_table_tt (
    id string, 
    first_name string, 
    age number
);

insert into demo_table_tt
    values ('55d899','edric',56),('mmd829','jayanthi',23),('7dm899','chloe',51);


-- verify retention_time is set to default of 1
show databases like 'demo_db';


-- change retention_time
-- setting data_retention_time_in_days to 0 effectively disables time travel
alter account set data_retention_time_in_days = 90;

alter database demo_db set data_retention_time_in_days = 90;

alter schema demo_schema set data_retention_time_in_days = 10;

alter table demo_table_tt set data_retention_time_in_days = 5;


-- verify updated retention_time 
show databases like 'demo_db';

show schemas like 'demo_schema';

show tables like 'demo_table_tt';


-- undrop
show tables history;

drop table demo_table_tt;

show tables history;

undrop table demo_table_tt;

show tables history;

select * from demo_table_tt;


-- the at keyword allows you to capture historical data inclusive of all changes made by a statement or transaction up until that point.
truncate table demo_table_tt;

select * from demo_table_tt;


--  select table as it was 5 minutes ago, expressed in difference in seconds between current time
select * 
from demo_table_tt at(offset => -60*5);


-- select rows from point in time of inserting records into table
select * 
from demo_table_tt at(statement => '<insert_statement_id>');


-- select tables as it was 15 minutes ago using timestamp
select * 
from demo_table_tt at(timestamp => dateadd(minute,-15, current_timestamp()));


-- the before keyword allows you to select historical data from a table up to, but not including any changes made by a specified statement or transaction.
-- select rows from before truncate command
select * 
from demo_table_tt before(statement => '<insert_statement_id>');

select * 
from demo_table_tt before(statement => '<truncate_statement_id>');


-- create table using before keyword
create table demo_table_tt_restored
as 
    select * 
    from demo_table_tt before(statement => '<truncate_statement_id>');

select * from demo_table_tt_restored;


-- clean up
drop database demo_db;
alter account set data_retention_time_in_days = 1;