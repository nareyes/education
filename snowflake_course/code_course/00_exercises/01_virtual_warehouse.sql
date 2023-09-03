use role sysadmin;


-- create virtual warehouse
create or replace warehouse exercise_wh
    warehouse_size = 'xsmall'
    min_cluster_count = 1
    max_cluster_count = 3
    auto_suspend = 600
    auto_resume = true
    initially_suspended = true;


-- drop warehouse
drop warehouse if exists exercise_wh;