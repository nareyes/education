use warehouse compute_wh;


-- create table
create or replace table demo_db.public.orders_truncate_col (
    order_id varchar(30),
    amount varchar(30),
    profit int,
    quantity int,
    category varchar(10), -- set to 10 for demo
    subcategory varchar(30)
);


-- create stage
create or replace stage manage_db.public.aws_stage_orders
    url = 's3://snowflakebucket-copyoption/size/';

list @manage_db.public.aws_stage_orders;


-- load data (category column will cause an error due to size limit)
copy into demo_db.public.orders_truncate_col
    from @manage_db.public.aws_stage_orders
    file_format = manage_db.file_formats.csv_format
    pattern = '.*Order.*';


-- load data and truncate columns to prevent error in above situation
copy into demo_db.public.orders_truncate_col
    from @manage_db.public.aws_stage_orders
    file_format = manage_db.file_formats.csv_format
    pattern = '.*Order.*'
    truncatecolumns = true; -- default: false


-- insepct data
select * from demo_db.public.orders_truncate_col;