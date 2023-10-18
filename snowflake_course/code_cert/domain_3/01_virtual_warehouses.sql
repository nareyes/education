/*
- virtual warehouse creation
- virtual warehouse sizes
- virtual warehouse state properties
- virtual warehouse behaviour
*/

-- set context
use role sysadmin;


-- create warehouse
create warehouse analysis_wh 
    warehouse_size = 'small' 
    auto_suspend = 600 
    auto_resume = true
    initially_suspended = true;

    
-- multi-cluster warehouse
create or replace warehouse analysis_mc_wh 
    warehouse_size = 'xsmall' 
    warehouse_type = 'standard' 
    auto_suspend = 600 
    auto_resume = true 
    min_cluster_count = 1 
    max_cluster_count = 2 
    scaling_policy = 'standard';

    
-- set context
use warehouse  analysis_wh;
use schema snowflake_sample_data.tpch_sf1000;


-- manually resume virtual warehouse
alter warehouse analysis_wh resume;


-- show state of virtual warehouse
show warehouses like 'analysis_wh';


-- manually suspend virtual warehouse
alter warehouse analysis_wh suspend;

show warehouses like 'analysis_wh';

select 
    c_custkey, 
    c_name, 
    c_address, 
    c_nationkey, 
    c_phone
from customer limit 100;

show warehouses like 'analysis_wh';


-- set configurations on-the-fly
alter warehouse analysis_wh set warehouse_size = large;

alter warehouse analysis_wh set auto_suspend = 300;

alter warehouse analysis_wh set auto_resume = false;

show warehouses like 'analysis_wh';


-- clean up
drop warehouse analysis_wh;

drop warehouse analysis_mc_wh;