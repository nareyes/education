use role sysadmin;
use warehouse compute_wh;



-- create table
create or replace table demo_db.public.orders_validate (
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


-- validate data using copy command and return_errors (data is not loaded)
copy into demo_db.public.orders_validate
    from @manage_db.public.aws_stage_orders
    file_format = manage_db.file_formats.csv_format
    pattern = '.*Order.*'
    validation_mode = return_errors;


-- validate data using copy command and return n rows (data is not loaded)
copy into demo_db.public.orders_validate
    from @manage_db.public.aws_stage_orders
    file_format = manage_db.file_formats.csv_format
    pattern = '.*error.*'
    validation_mode = return_5_rows; -- will not return rows since first record has an error



-- storing rejected records in a table
create or replace table demo_db.public.rejected_records as
    select rejected_record
    -- from table (result_scan (last_query_id()))
    from table (result_scan ('01aebefb-0001-5289-0000-000481e6923d'));

select * from demo_db.public.rejected_records;


-- load data with continue (loads valid records)
copy into demo_db.public.orders_validate
    from @manage_db.public.aws_stage_orders
    file_format = manage_db.file_formats.csv_format
    pattern = '.*Order.*'
    on_error = continue; -- query id = 01aebefd-0001-5263-0000-000481e6a12d


-- query rejected records
select * 
from table (validate (demo_db.public.orders_validate, job_id => '_last'));


-- store rejected records from partial load ^
create or replace table demo_db.public.rejected_records as
    select *
    from table (validate (demo_db.public.orders_validate, job_id => '_last'));

select * from demo_db.public.rejected_records;


-- parse rejected record content and load into a seperate table
create or replace table demo_db.public.rejected_records_parsed as
    select
        split_part (rejected_record, ',', 1) as order_id, 
        split_part (rejected_record, ',', 2) as amount, 
        split_part (rejected_record, ',', 3) as profit, 
        split_part (rejected_record, ',', 4) as quatntity, 
        split_part (rejected_record, ',', 5) as category, 
        split_part (rejected_record, ',', 6) as subcategory
    from demo_db.public.rejected_records;


-- inspect parsed rejects records
select * from demo_db.public.rejected_records_parsed;