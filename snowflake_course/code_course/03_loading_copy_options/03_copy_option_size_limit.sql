use role accountadmin;
use warehouse compute_wh;


-- create table
create or replace table demo_db.public.orders (
    order_id varchar(30),
    amount varchar(30),
    profit int,
    quantity int,
    category varchar(30),
    subcategory varchar(30)
);


-- create stage
create or replace stage manage_db.public.aws_stage_orders
    url = 's3://snowflakebucket-copyoption/size/';

list @manage_db.public.aws_stage_orders;


-- load data with size limit (will only load first file in this case)
copy into demo_db.public.orders
    from @manage_db.public.aws_stage_orders
    file_format = manage_db.file_formats.csv_format
    pattern = '.*Order.*'
    size_limit = 50000; -- firs file exceeds limit but it will be loaded anyway


-- load data with increased size limit (will only load second file in this case)
-- first file was already loaded so it is skipped
copy into demo_db.public.orders
    from @manage_db.public.aws_stage_orders
    file_format = manage_db.file_formats.csv_format
    pattern = '.*Order.*'
    size_limit = 60000; -- second file exceeds limit but it will be loaded anyway


-- inspect data
select * from demo_db.public.orders;