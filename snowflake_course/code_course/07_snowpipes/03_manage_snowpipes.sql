use role accountadmin;
use warehouse compute_wh;


-- pipe information
desc pipe manage_db.snowpipes.employee_pipe;

show pipes; -- all pipes in account

show pipes in database manage_db; -- all pipes in database

show pipes in schema manage_db.snowpipes; -- all pipes in schema


-- pause pipe and check status
alter pipe manage_db.snowpipes.employee_pipe
    set pipe_execution_paused = true;
    
    
-- check status of paused pipe
select system$pipe_status('manage_db.snowpipes.employee_pipe');


-- resume pipe and check status
alter pipe manage_db.snowpipes.employee_pipe
    set pipe_execution_paused = false;

select system$pipe_status('manage_db.snowpipes.employee_pipe');


-- refresh pipe
alter pipe manage_db.snowpipes.employee_pipe refresh;