-- set context
use role sysadmin;
use warehouse exercise_wh;


-- create stage schema
create or replace schema exercise_db.external_stage;


-- create stage
create or replace stage exercise_db.external_stage.aws_stage
    url = 's3://snowflake-assignments-mc/loadingdata/';


-- list files
list @exercise_db.external_stage.aws_stage;


-- load customers data
copy into exercise_db.public.customers
    from @exercise_db.external_stage.aws_stage
    files = ('customers2.csv', 'customers3.csv')
    file_format = (
        type = csv 
        field_delimiter = ';' 
        skip_header = 1   
    );


-- inspect data
select * from exercise_db.public.customers
limit 10;

select
    city,
    count(*) as customer_count
from exercise_db.public.customers
group by city
order by city asc;