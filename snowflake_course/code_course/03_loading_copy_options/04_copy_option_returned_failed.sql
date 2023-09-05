use role sysadmin;
use warehouse compute_wh;


-- create table
create or replace table demo_db.public.orders_failed (
    order_id varchar(30),
    amount varchar(30),
    profit int,
    quantity int,
    category varchar(30),
    subcategory varchar(30)
);


-- create stage
create or replace stage manage_db.public.aws_stage_orders
    url = 's3://snowflakebucket-copyoption/returnfailed/';

list @manage_db.public.aws_stage_orders;


-- load data and return details for failed files only
copy into demo_db.public.orders_failed
    from @manage_db.public.aws_stage_orders
    file_format = manage_db.file_formats.csv_format
    pattern = '.*Order.*'
    on_error = continue
    return_failed_only = true; -- default false: returns details for all files


-- inspect data
select * from demo_db.public.orders_failed;