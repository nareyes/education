-- set role context
use role accountadmin;

-- create virtual warehouse
create or replace warehouse compute_wh_sql
with
    warehouse_size = xsmall
    warehouse_type = 'standard'
    min_cluster_count = 1
    max_cluster_count = 3 -- enables multi-cluster warehouse
    scaling_policy = 'standard'
    auto_resume = true
    auto_suspend = 600 -- in seconds
    initially_suspended = true;


-- drop virtual warehouse
drop warehouse compute_wh_sql;