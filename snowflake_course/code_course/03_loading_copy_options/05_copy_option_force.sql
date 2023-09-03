use warehouse compute_wh;


-- create table
create or replace table demo_db.public.orders_force (
    order_id    varchar(30),
    amount      varchar(30),
    profit      int,
    quantity    int,
    category    varchar(30),
    subcategory varchar(30)
);


-- create stage
create or replace stage manage_db.public.aws_stage_orders
    url = 's3://snowflakebucket-copyoption/size/';

list @manage_db.public.aws_stage_orders;


-- load data
copy into demo_db.public.orders_force
    from @manage_db.public.aws_stage_orders
    file_format = manage_db.file_formats.csv_format
    pattern = '.*Order.*';

select * from demo_db.public.orders; -- 3,000 rows


-- attempt to re-load data (copy will not process already loaded files)
copy into demo_db.public.orders_force
    from @manage_db.public.aws_stage_orders
    file_format = manage_db.file_formats.csv_format
    pattern = '.*Order.*';


-- re-load data using copy option force
copy into demo_db.public.orders_force
    from @manage_db.public.aws_stage_orders
    file_format = manage_db.file_formats.csv_format
    pattern = '.*Order.*'
    force = true; -- be mindful of duplication. this may be an option applicable to specific a use case.


-- inspect data
select * from demo_db.public.orders_force; -- now 6,000 rows. all records have been duplicated due to force option.