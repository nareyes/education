use role accountadmin;
use warehouse compute_wh;
use database demo_db;


-- show table metadata (default retention time = 1 day)
show tables  like 'customers_tt';


-- alter table to extend retention time (extended retention time will increase costs due to increased storage)
alter table demo_db.public.customers_tt
    set data_retention_time_in_days = 90;

show tables  like 'customers_tt';


-- query storage usage (see increased time travel bytes for above table)
use role accountadmin;

grant all privileges on table demo_db.public.customers_tt to role accountadmin;

select * 
from snowflake.account_usage.table_storage_metrics
where table_name = 'CUSTOMERS_TT';

select
    id, 
    table_name, 
    table_schema,
    table_catalog,
    active_bytes / (1024*1024*1024) as storage_used_gb,
    time_travel_bytes / (1024*1024*1024) as time_travel_storage_used_gb
from snowflake.account_usage.table_storage_metrics
order by storage_used_gb desc,time_travel_storage_used_gb desc;



-- query account storage usage by date
select * 
from snowflake.account_usage.storage_usage
order by usage_date desc;