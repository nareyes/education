use role accountadmin;
use warehouse compute_wh;


-- create stored procedure
create or replace procedure customers_insert_procedure (create_date varchar)
    returns string not null
    language javascript
    as
        $$
        var sql_command = 'insert into task_db.public.customers (create_date) values(:1);'
        snowflake.execute(
            {
            sqltext: sql_command,
            binds: [create_date]
            }
        );
        return 'Successfully Executed.';
        $$;


-- create task
create or replace task customer_tasks_procedure
    warehouse = compute_wh
    schedule = '1 minute'
    as call customers_insert_procedure (current_timestamp);
    
show tasks;


-- resume task (default is suspended)
alter task customer_tasks_procedure resume;


-- inspect data
select * from task_db.public.customers;


-- suspend task
alter task customer_taks_procedure suspend;