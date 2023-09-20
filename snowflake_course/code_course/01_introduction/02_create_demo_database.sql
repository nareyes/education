-- create demo database
-- or replace syntax is not useful for production env
-- better to use if not exists syntax
use role accountadmin;
create or replace database demo_db;


-- create demo schema
create or replace schema demo_db.demo_schema;


-- create demo table
create or replace table demo_db.demo_schema.demo_table (
    col1 string,
    col2 string,
    col3 string
);


-- query table
select * from demo_db.demo_schema.demo_table;


-- clean up
drop table if exists demo_db.demo_schema.demo_table;
drop schema if exists demo_db.demo_schema;