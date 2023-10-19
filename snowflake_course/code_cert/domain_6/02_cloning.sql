/*
- clone objects
- cloning and time travel
*/

-- set context
use role sysadmin;


-- create demo objects
create database demo_db;

create schema demo_schema;

create table demo_table (
    id string, 
    first_name string, 
    age number
);

insert into demo_table 
    values ('55d899','edric',56),('mmd829','jayanthi',23);
    

-- cloning is metadata operation only, no data is transferred: "zero-copy" cloning
create table demo_table_clone clone demo_table;

select * from demo_table_clone;


-- we can create clones of clones
create table demo_table_clone_two clone demo_table_clone;

select * from demo_table_clone_two;


-- easily and quickly create entire database from existing database
create database demo_db_clone clone demo_db;

use database demo_db_clone;

use schema demo_schema;


-- cloning is recursive for databases and schemas
show tables;

select * from demo_table;


-- data added to cloned database table will start to store micro-partitions, incurring additional cost
insert into demo_table 
    values ('7dm899','chloe',51);

    
-- cloned table changed
select * from demo_table;


-- source table unchanged
select * from demo_db.demo_schema.demo_table;


-- create clone from point in past with time travel 
create or replace table demo_table_clone_time_travel clone demo_table
at(offset => -60*2);

select * from demo_table_clone_time_travel;


-- clean up
drop database demo_db;

drop database demo_db_clone;