use role sysadmin;
use warehouse compute_wh;


-- create customers table
create or replace table demo_db.public.customers (
    id int,
    first_name varchar,
    last_name varchar,
    email varchar,
    age int,
    city varchar
);


-- create external stage
create or replace stage manage_db.external_stage.customer_stage
    url = 's3://snowflake-assignments-mc/loadingdata/';
    -- open bucket. no credentials needed.

-- describe stage
list @manage_db.external_stage.customer_stage;


-- create file format object
create or replace file format manage_db.file_formats.csv_alt_format
    type = 'csv'
    field_delimiter = ';'
    skip_header = 1;


-- show file format properties
desc file format manage_db.file_formats.csv_format;

-- load data
copy into demo_db.public.customers
    from 's3://snowflake-assignments-mc/gettingstarted/customers.csv'
    file_format = manage_db.file_formats.csv_format;
    -- file_format = (
    --     type = csv
    --     field_delimiter = ','
    --     skip_header = 1
    -- );

copy into demo_db.public.customers
    from @manage_db.external_stage.customer_stage
    files = ('customers2.csv', 'customers3.csv')
    file_format = manage_db.file_formats.csv_alt_format;
    -- file_format = (
    --     type = csv
    --     field_delimiter = ';'
    --     skip_header = 1
    -- ) -- file format object has a comma delimiter set


-- inspect data
select * from demo_db.public.customers
limit 10;