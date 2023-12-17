-------------------------------------------------
-- Chapter 8: Managing Snowflake Account Costs --
-------------------------------------------------

---------------
-- prep work --
---------------

use role sysadmin;
use warehouse compute_wh;

create or replace warehouse vw2_wh
    with 
    warehouse_size = medium
    auto_suspend = 300 
    auto_resume = true
    initially_suspended=true;
    
create or replace warehouse vw3_wh 
    with 
    warehouse_size = small
    auto_suspend = 300 
    auto_resume = true
    initially_suspended=true;

create or replace warehouse vw4_wh 
    with 
    warehouse_size = medium
    auto_suspend = 300 
    auto_resume = true
    initially_suspended=true;
    
create or replace warehouse vw5_wh 
    with 
    warehouse_size = small
    auto_suspend = 300 
    auto_resume = true
    initially_suspended=true;
    
create or replace warehouse vw6_wh 
    with 
    warehouse_size = medium
    auto_suspend = 300 
    auto_resume = true
    initially_suspended=true;


-----------------------
-- resource monitors --
-----------------------

-- create account level rm
use role accountadmin;
create or replace resource monitor monitor1_rm 
    with 
    credit_quota = 5000
    triggers on 50 percent do notify
             on 75 percent do notify
             on 100 percent do notify
             on 110 percent do notify
             on 125 percent do notify;
alter account set resource_monitor = monitor1_rm;

show resource monitors;

-- create warehouse level rm's
use role accountadmin;
create or replace resource monitor monitor5_rm 
    with credit_quota = 1500
    triggers on 50 percent do notify
             on 75 percent do notify
             on 100 percent do notify
             on 110 percent do notify
             on 125 percent do notify;
alter warehouse vw2_wh set resource_monitor = monitor5_rm;

create or replace resource monitor monitor2_rm 
    with credit_quota = 500
    triggers on 50 percent do notify
             on 75 percent do notify
             on 100 percent do notify
             on 100 percent do suspend
             on 110 percent do notify
             on 110 percent do suspend_immediate;             
alter warehouse vw3_wh set resource_monitor = monitor2_rm;

create or replace resource monitor monitor6_rm 
    with credit_quota = 500
    triggers on 50 percent do notify
             on 75 percent do notify
             on 100 percent do notify
             on 100 percent do suspend
             on 110 percent do notify
             on 110 percent do suspend_immediate;             
alter warehouse vw6_wh set resource_monitor = monitor6_rm;

create or replace resource monitor monitor4_rm 
    with credit_quota = 500
    triggers on 50 percent do notify
             on 75 percent do notify
             on 100 percent do notify
             on 100 percent do suspend
             on 110 percent do notify
             on 110 percent do suspend_immediate;             
alter warehouse vw6_wh set resource_monitor = monitor4_rm; -- this will override the previous rm

create or replace resource monitor monitor3_rm 
    with credit_quota = 1500
    triggers on 50 percent do notify
             on 75 percent do notify
             on 100 percent do notify
             on 100 percent do suspend
             on 110 percent do notify
             on 110 percent do suspend_immediate;             
alter warehouse vw4_wh set resource_monitor = monitor3_rm;
alter warehouse vw5_wh set resource_monitor = monitor3_rm;


show resource monitors;
show warehouses;

-- drop rm
use role accountadmin;
drop resource monitor monitor6_rm;

show resource monitors;
show warehouses;

-- query warehouses without an attached rm (run show warehouses first)
use role accountadmin;
show warehouses;

select
    "name"
    ,"size"
from table (result_scan(last_query_id()))
where "resource_monitor" = 'null';


---------------------------------
-- querying account_usage view --
---------------------------------

-- credits used by warehouse and start/end time
use role accountadmin;
set credit_price = 3.00;
select 
    warehouse_name
    ,start_time
    ,end_time
    ,credits_used
    ,($credit_price*credits_used) as dollars_used                         
from snowflake.account_usage.warehouse_metering_history
order by start_time desc;

-- credits and dollars used by warehouse
use role accountadmin;
set credit_price = 3.00;
select
    warehouse_name
    ,sum(credits_used_compute) as credits_used_compute_30days
    ,($credit_price * credits_used_compute_30days) as dollars_used_30days
from snowflake.account_usage.warehouse_metering_history
where start_time >= dateadd(day, -30, current_timestamp())
group by 1
order by 2 desc;


--------------
-- clean up --
--------------
USE ROLE ACCOUNTADMIN;

DROP RESOURCE MONITOR MONITOR1_RM;
DROP RESOURCE MONITOR MONITOR2_RM; 
DROP RESOURCE MONITOR MONITOR3_RM;
DROP RESOURCE MONITOR MONITOR4_RM;
DROP RESOURCE MONITOR MONITOR5_RM;

DROP WAREHOUSE VW2_WH;
DROP WAREHOUSE VW3_WH;
DROP WAREHOUSE VW4_WH;
DROP WAREHOUSE VW5_WH;
DROP WAREHOUSE VW6_WH;