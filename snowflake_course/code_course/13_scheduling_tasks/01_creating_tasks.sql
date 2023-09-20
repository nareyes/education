use role accountadmin;
use warehouse compute_wh;


-- create transient database
create or replace database task_db;


-- create table
create or replace table task_db.public.customers (
    customer_id int autoincrement start = 1 increment = 1,
    first_name varchar(40) default 'Nick',
    created_date date
);

select * from task_db.public.customers;


-- create task
create or replace task customer_insert
    warehouse = compute_wh
    schedule = '1 minute' -- two scheduling options, cron in next worksheet
    as 
        insert into task_db.public.customers (created_date) 
        values (current_timestamp); -- default state is suspended

show tasks;


-- resume and suspend task
alter task customer_insert resume;
alter task customer_insert suspend;


-- inspect data
select * from task_db.public.customers;