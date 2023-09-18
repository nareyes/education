use role sysadmin;
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

select * from demo_db.public.customers_tt; -- query id: 01af136d-0001-5a00-0004-81e60001f096


-- accidental update
update demo_db.public.customers_tt
    set last_name = 'Tyson'; -- query id: 01af136d-0001-59c0-0004-81e60002108e

update demo_db.public.customers_tt
    set job = 'Data Analyst'; -- query id: 01af136e-0001-5a00-0004-81e60001f0a2

select * from demo_db.public.customers_tt; -- query id: 01af136e-0001-5a00-0004-81e60001f0a6


-- inspect original data load
select * from demo_db.public.customers_tt before (statement => '01af136d-0001-5a00-0004-81e60001f096');


-- restore data to backup table
create or replace table demo_db.public.customers_tt_backup as (
    select * from demo_db.public.customers_tt before (statement => '01af136d-0001-5a00-0004-81e60001f096')
); -- query id: 01af1370-0001-5a00-0004-81e60001f0c2

select * from demo_db.public.customers_tt_backup;


-- truncate original table
-- if we re-create the table, we lose metadata (best practice is to truncate and insert backup)
truncate demo_db.public.customers_tt;

select * from demo_db.public.customers_tt;


-- reload data using time travel backuo
insert into demo_db.public.customers_tt
    select * from demo_db.public.customers_tt_backup;

select * from demo_db.public.customers_tt;