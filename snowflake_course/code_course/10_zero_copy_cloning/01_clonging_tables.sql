use role accountadmin;
use warehouse compute_wh;


-- qyery demo table
select * from demo_db.public.customers;


-- clone table (must be permanent or transient table)
create or replace table demo_db.public.customers_clone
    clone demo_db.public.customers; -- include time travel syntax if needed


-- validate data
select * from demo_db.public.customers;
select * from demo_db.public.customers_clone;


-- update cloned table
update demo_db.public.customers_clone
    set last_name = null;
    

-- validate data (only cloned table was updated)
select * from demo_db.public.customers;
select * from demo_db.public.customers_clone;