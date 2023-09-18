-- temporary tables (create temporary table)
-- used for non-permanent data
-- only exists in current session
-- time travel retention period (0-1 day)
-- no fail safe 


use role accountadmin;
use warehouse compute_wh;


-- create temporary table
create or replace temporary table demo_db.public.customers_temporary (
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
-- temporary tables only exists within current session so we do not need to drop