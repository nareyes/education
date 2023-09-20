use role accountadmin;
use warehouse compute_wh;


-- create table
create or replace table demo_db.public.customers_tt (
    id int,
    first_name string,
    last_name string,
    email string,
    gender string,
    job string,
    phone string
);

-- create file format object
create or replace file format manage_db.file_formats.csv_format
    type = csv
    field_delimiter = ','
    skip_header = 1;

desc file format manage_db.file_formats.csv_format;


-- create stage
create or replace stage manage_db.external_stage.time_travel_stage
    url = 's3://data-snowflake-fundamentals/time-travel/'
    file_format = manage_db.file_formats.csv_format;

list @manage_db.external_stage.time_travel_stage;


-- load data
copy into demo_db.public.customers_tt
    from @manage_db.external_stage.time_travel_stage
    files = ('customers.csv');

select * from demo_db.public.customers_tt;


-- accidental drop and undrop (tables)
drop table demo_db.public.customers_tt;

undrop table demo_db.public.customers_tt;

select * from demo_db.public.customers_tt;


-- accidental drop and undrop (schemas)
drop schema demo_db.public; -- all tables in schema will also be dropped

undrop schema demo_db.public; -- restores underlining tables

select * from demo_db.public.customers_tt;


-- accidental drop and undrop (database)
drop database demo_db;

undrop database demo_db; -- restores with all schemas and tables

select * from demo_db.public.customers_tt;