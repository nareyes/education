use role accountadmin;
use warehouse compute_wh;


-- storage usage on account level
select * 
from snowflake.account_usage.storage_usage 
order by usage_date desc;


-- storage usage on account level formatted
select 
    usage_date, 
    storage_bytes / (1024*1024*1024) as storage_gb,  
    stage_bytes / (1024*1024*1024) as stage_gb,
    failsafe_bytes / (1024*1024*1024) as failsafe_gb
from snowflake.account_usage.storage_usage 
order by usage_date desc;


-- storage usage on table level
select * 
from snowflake.account_usage.table_storage_metrics;


-- storage usage on table level formatted
select 	
    id, 
    table_name, 
    table_schema,
    active_bytes / (1024*1024*1024) as storage_used_gb,
    time_travel_bytes / (1024*1024*1024) as time_travel_storage_used_gb,
    failsafe_bytes / (1024*1024*1024) as failsafe_storage_used_gb
from snowflake.account_usage.table_storage_metrics
order by failsafe_storage_used_gb desc;