use role sysadmin;
use warehouse exercise_wh;


-- create employees table
create or replace table exercise_db.public.employees (
    customr_id int,
    first_name varchar,
    last_name varchar,
    email varchar,
    age int,
    department varchar
);


-- create stage
create or replace stage exercise_db.external_stage.copy_option
    url = 's3://snowflake-assignments-mc/copyoptions/example1';


-- list files
list @exercise_db.external_stage.copy_option;


-- create file format object
create or replace file format exercise_db.file_formats.csv_format
    type = 'csv'
    field_delimiter = ','
    skip_header = 1;


-- validate and return errors
copy into exercise_db.public.employees
    from @exercise_db.external_stage.copy_option
    file_format = exercise_db.file_formats.csv_format
    validation_mode = return_errors;


-- load data and ignore errors
copy into exercise_db.public.employees
    from @exercise_db.external_stage.copy_option
    file_format = exercise_db.file_formats.csv_format
    on_error = continue;


-- validate data
select * from exercise_db.public.employees;


-- create employees table for truncate example
create or replace table exercise_db.public.employees_truncate_col (
    customr_id int,
    first_name varchar,
    last_name varchar,
    email varchar(10),
    age int,
    department varchar
);


-- create stage
create or replace stage exercise_db.external_stage.copy_option
    url = 's3://snowflake-assignments-mc/copyoptions/example2';


-- list files
list @exercise_db.external_stage.copy_option;


-- use truncatecolumns
copy into exercise_db.public.employees_truncate_col
    from @exercise_db.external_stage.copy_option
    file_format = exercise_db.file_formats.csv_format
    truncatecolumns = true; 


-- validate data
select * from exercise_db.public.employees_truncate_col;