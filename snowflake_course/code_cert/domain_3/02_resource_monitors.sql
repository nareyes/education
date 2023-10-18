/*
- virtual warehouse usage and credit monitoring through ui and sql 
- resource monitors
*/

-- set context
use role accountadmin;
use warehouse compute_wh;
use database snowflake;
use schema account_usage;


-- warehouse compute credit history
select * 
from warehouse_metering_history
where warehouse_name = 'COMPUTE_WH';


-- total credits used grouped by warehouse
select
    warehouse_name,
    sum(credits_used) as total_credits_used
from warehouse_metering_history
where start_time >= date_trunc(month, current_date)
group by warehouse_name
order by total_credits_used desc;


-- warehouse metering history for account using the information schema
select *
from table(information_schema.warehouse_metering_history(dateadd('days',-7,current_date())));


-- create resource monitor
create resource monitor compute_wh_rm with 
    credit_quota = 1 
    triggers 
        on 50 percent do notify
        on 90 percent do suspend 
        on 100 percent do suspend_immediate;

 
-- resource monitor object can be applied at account level 
alter account set resource_monitor = "COMPUTE_WH_RM";


-- apply resource monitor at virtual warehouse level 
alter warehouse "COMPUTE_WH" set resource_monitor = "COMPUTE_WH_RM";


-- clean up
drop resource monitor compute_wh_rm;