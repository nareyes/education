use role accountadmin;
use warehouse compute_wh;


-- show tasks
show tasks;


-- query task history
select *
from table (information_schema.task_history())order by scheduled_time desc;


-- query task history for specific time period
select to_timestamp_ltz(current_timestamp); 

select *
from table (information_schema.task_history(
    result_limit => 5,
    -- task_name => '',
    scheduled_time_range_start  => to_timestamp_ltz ('2023-09-19 08:46:37.538 -0700'),
    scheduled_time_range_end    => to_timestamp_ltz ('2023-09-20 08:46:37.538 -0700')
    )
);