/*
- introduce databases & schemas
- understand table and view types
*/

-- set context 
use role accountadmin;

use warehouse compute_wh;

use database snowflake_sample_data;

use schema tpch_sf1;


-- describe table schema
desc table customer;


-- provide details on all tables in current context
show tables;


-- filter output of show tables using like string matching
show tables like 'customer';


select 
    "name", 
    "database_name", 
    "schema_name", 
    "kind", 
    "is_external", 
    "retention_time" 
from table(result_scan(last_query_id()));


-- create demo database & schema 
create database demo_db;

create schema demo_schema;

use role sysadmin;

use database demo_db;

use schema demo_schema;

-- create three table types
create table permanent_table (
    name string,
    age int
);

create temporary table temporary_table (
    name string,
    age int
);

create transient table transient_table (
    name string,
    age int
);


show tables;

select 
    "name", 
    "database_name", 
    "schema_name", 
    "kind", 
    "is_external", 
    "retention_time" 
from table(result_scan(last_query_id()));


-- successful retention time (permanent tables between 0 and 90)
alter table permanent_table set data_retention_time_in_days = 90;


-- invalid retention time (transient tables can be between 0 and 1)
alter table transient_table set data_retention_time_in_days = 2;


-- create external table 
create external table ext_table (
  col1 varchar as (value:col1::varchar),
  col2 varchar as (value:col2::int),
  col3 varchar as (value:col3::varchar)
)

location = @s1/logs/
file_format = (type = parquet);


-- refresh external table metadata so it reflects latest changes in external cloud storage
alter external table ext_table refresh;


-- create three views - one of each type
create view standard_view as
    select * 
    from permanent_table;

create secure view secure_view as
    select * 
    from permanent_table;

create materialized view materialized_view as
    select * 
    from permanent_table;

show views;

select 
    "name", 
    "database_name", 
    "schema_name", 
    "is_secure", 
    "is_materialized" 
from table(result_scan(last_query_id()));


-- secure view functionality
grant usage on database demo_db to role sysadmin;
grant usage on schema demo_schema to role sysadmin;
grant select, references on table standard_view to role sysadmin;
grant select, references on table secure_view to role sysadmin;


-- ddl returned from secure view as role that owns secure view
select get_ddl('view', 'secure_view');


-- set context
use role sysadmin;


-- will not work with sysadmin role as only ownership role can view ddl
select get_ddl('view', 'secure_view');


-- will work with sysadmin role as view not desginated as secure  
select get_ddl('view', 'standard_view');


-- set context
use role accountadmin;

-- clean up
drop database demo_db;