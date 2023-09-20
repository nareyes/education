use role accountadmin;
use warehouse compute_wh;

-- show tasks and suspend parent (customer_insert will be parent task for this example)
show tasks;

alter task customer_insert suspend;


-- create table
create or replace table task_db.public.customers_child (
    customer_id int,
    first_name varchar(40),
    create_date date
);


-- create child task
create or replace task customer_insert_child
    warehouse = compute_wh
    after customer_insert
    as 
        insert into task_db.public.customers_child 
        select * from customers;


-- show tasks
show tasks;


-- resume parent and child tasks (child first)
alter task customer_insert_child resume;
alter task customer_insert resume;


-- inspect data
select * from task_db.public.customers;
select * from task_db.public.customers_child;


-- suspend tasks (parent first)
alter task customer_insert suspend;
alter task customer_insert_child suspend;