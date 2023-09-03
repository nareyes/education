use warehouse exercise_wh;


-- create database
create or replace database exercise_db;


-- create customers table
create or replace table exercise_db.public.customers (
    id int,
    first_name varchar,
    last_name varchar,
    email varchar,
    age int,
    city varchar
);


-- load customers data
copy into exercise_db.public.customers
    from 's3://snowflake-assignments-mc/gettingstarted/customers.csv'
    file_format = (
        type = csv
        field_delimiter = ','
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