use role sysadmin;
use warehouse compute_wh;


-- create schema
create or replace schema manage_db.file_formats;

-- create file format object
create or replace file format manage_db.file_formats.csv_format
    type = 'csv'
    field_delimiter = ','
    skip_header = 1;


-- show file format properties
desc file format manage_db.file_formats.csv_format;


-- create table for example
create or replace table demo_db.public.order_details_ex (
    order_id varchar(30),
    amount int,
    profit int,
    quantity int,
    category varchar(30),
    subcategory varchar(30)
);


-- load data
copy into demo_db.public.order_details_ex
    from @manage_db.external_stage.aws_stage
    file_format = manage_db.file_formats.csv_format
    files = ('OrderDetails.csv')
    on_error = 'abort_statement';


-- inspect data
select * from demo_db.public.order_details_ex;


-- clean up
drop table if exists demo_db.public.order_details_ex;