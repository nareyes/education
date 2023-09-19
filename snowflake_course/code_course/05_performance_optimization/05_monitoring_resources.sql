use role accountadmin;
use warehouse compute_wh;


-- table storage
select * from snowflake.account_usage.table_storage_metrics;


-- how much is queried in databases
select * from snowflake.account_usage.query_history;

select 
    database_name,
    count(*) as number_of_queries,
    sum(credits_used_cloud_services) as sum_credits_used
from snowflake.account_usage.query_history
group by database_name;


-- usage of credits by warehouses
select * from snowflake.account_usage.warehouse_metering_history;


-- usage of credits by warehouses // grouped by day
select 
    date(start_time),
    sum(credits_used) as sum_credits_used
from snowflake.account_usage.warehouse_metering_history
group by date(start_time);


-- usage of credits by warehouses // grouped by warehouse
select
    warehouse_name,
    sum(credits_used) as sum_credits_used
from snowflake.account_usage.warehouse_metering_history
group by warehouse_name;


-- usage of credits by warehouses // grouped by warehouse & day
select
    date(start_time) as start_time,
    warehouse_name,
    sum(credits_used) as sum_credits_used
from snowflake.account_usage.warehouse_metering_history
group by warehouse_name, date(start_time);