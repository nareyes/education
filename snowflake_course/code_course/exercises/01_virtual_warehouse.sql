use role sysadmin;


-- create virtual warehouse
create or replace warehouse exercise_wh
    warehouse_size = 'xsmall'
    auto_suspend = 600
    auto_resume = true;


-- drop warehouse
drop warehouse if exists exercise_wh;