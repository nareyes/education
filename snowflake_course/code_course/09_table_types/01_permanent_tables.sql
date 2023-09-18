-- permanent tables (create table) default
-- used for permanent data that needs protection
-- time travel retention period (0-90 days)
-- fail safe


use role accountadmin;
use warehouse compute_wh;


-- create permanent table (permanent tables are not transient)
create or replace table demo_db.public.customers_permanent (
    id int,
    first_name string,
    last_name string,
    email string,
    gender string,
    job string,
    phone string
);


-- show all tables in database
show tables;


-- view table metrics
select * from snowflake.account_usage.table_storage_metrics;

-- clean up
drop table if exists demo_db.public.customers_permanent;