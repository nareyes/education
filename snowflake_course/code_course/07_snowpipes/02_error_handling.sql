use role accountadmin;
use warehouse compute_wh;

-- validate pipe
select system$pipe_status('manage_db.snowpipes.employee_pipe');


-- retrieve error message
select * from table (
    validate_pipe_load (
        pipe_name => 'manage_db.snowpipes.employee_pipe',
        start_time => dateadd (hour, -2, current_timestamp()) -- last 2 hours
    )
);


-- retrieve command history (returns additional error details)
select * from table (
    manage_db.information_schema.copy_history (
        table_name => 'manage_db.snowpipes.employee_pipe',
        start_time => dateadd (hour, -2, current_timestamp())
    )
);