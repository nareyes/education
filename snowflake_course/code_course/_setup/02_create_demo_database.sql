-- create demo database
-- or replace syntax is not useful for production env
-- better to use if not exists syntax
create or replace database demo_db;

-- create demo schema
use database demo_db;
create or replace schema demo_schema;

-- create demo table
create or replace table demo_db.demo_schema.demo_table (
    col1 string
    col2 string,
    col3 string,
)
comment = 'create demo table with sql command';

-- query table
select * from demo_db.demo_schema.demo_table;