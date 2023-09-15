use role accountadmin;
use warehouse compute_wh;

-- snowpipe enables loading once a file appears in a bucket/container
-- uses serverless features instead of warehouses


-- create storage integration object
create or replace storage integration s3_int
    type = external_stage
    storage_provider = s3
    enabled = true
    storage_aws_role_arn = ''
    -- storage_allowed_locations = ('<cloud>://<bucket>/<path>/')
    storage_allowed_locations = ('s3://s3snowflakestorage/csv', 's3://s3snowflakestorage/json');


-- inspect storage integration properties
desc integration s3_int;



use role sysadmin;
-- create file format object
create or replace file format manage_db.file_formats.csv_format
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('null', 'null')
    empty_field_as_null = true;

desc file format manage_db.file_formats.csv_format;


-- create stage
create or replace stage manage_db.external_stage.snowpipe_stage
    url = 's3://s3snowflakestorage/csv/snowpipe'
    storage_integration = s3_int
    file_format = manage_db.file_formats.csv_format;

list @manage_db.external_stage.snowpipe_stage;


-- create table
create or replace table demo_db.public.employees (
    id          int,
    first_name  string,
    last_name   string,
    email       string,
    location    string,
    depARTMENT  STRING
);


-- create pipe
create or replace schema manage_db.snowpipes;

create or replace pipe manage_db.snowpipes.employee_pipe
    auto_ingest = true
as
    copy into demo_db.public.employees
    from @manage_db.external_stage.snowpipe_stage;

desc pipe manage_db.snowpipes.employee_pipe; -- copy notification channel and update event notification in aws


-- inspect data (data should load 30-60sec after uploaded in s3 bucket)
select * from demo_db.public.employees;