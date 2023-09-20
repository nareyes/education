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


-- time travel method 1: look back specified time (offset in seconds)
update demo_db.public.customers_tt
    set first_name = 'Joyen';

select * from demo_db.public.customers_tt;

select * from demo_db.public.customers_tt at (offset => -120);


-- time travel method 2: look back specified time stamp (re-create and load table first)
alter session set timezone = 'UTC';
select current_timestamp; -- 2023-09-18 17:42:27.378 +0000

update demo_db.public.customers_tt
    set job = 'Data Scientist';

select * from demo_db.public.customers_tt;

select * from demo_db.public.customers_tt before (timestamp => '2023-09-18 17:42:27.378 +0000'::timestamp);


-- time travel method 3: look back to specified query id
update demo_db.public.customers_tt
    set gender = 'F'; -- query id: 01af1369-0001-5812-0004-81e600020052

select * from demo_db.public.customers_tt;

select * from demo_db.public.customers_tt before (statement => '01af1369-0001-5812-0004-81e600020052');