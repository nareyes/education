use warehouse exercise_wh;


-- create stage
create or replace stage exercise_db.external_stage.file_formats
    url = 's3://snowflake-assignments-mc/fileformat/';


-- list files
list @exercise_db.external_stage.file_formats;


-- create schema
create or replace schema exercise_db.file_formats;

-- create file format object
create or replace file format exercise_db.file_formats.csv_pipe_format
    type = 'csv'
    field_delimiter = '|'
    skip_header = 1;


-- load customers data
copy into exercise_db.public.customers
    from @exercise_db.external_stage.file_formats
    files = ('customers4.csv')
    file_format = exercise_db.file_formats.csv_pipe_format;


-- inspect data
select * from exercise_db.public.customers
limit 10;

select
    city,
    count(*) as customer_count
from exercise_db.public.customers
group by city
order by city asc;