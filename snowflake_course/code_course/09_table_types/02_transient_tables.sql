-- transient tables (create transient table)
-- used for data that does not need protection
-- time travel retention period (0-1 day)
-- no fail safe
 

use role accountadmin;
use warehouse compute_wh;


-- create transient table
create or replace transient table demo_db.public.customers_transient (
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
drop table if exists demo_db.public.customers_transient;