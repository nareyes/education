use role accountadmin;
use warehouse compute_wh;


-- clone schema
create or replace schema demo_db.public_copy
    clone demo_db.public; -- include time travel syntax if needed


-- validate schemas
select * from demo_db.public.customers;
select * from demo_db.public_copy.customers;


-- clone database
create or replace database demo_db_dev
    clone demo_db; -- include time travel syntax if needed


-- validate database
select * from demo_db.public.customers;
select * from demo_db_dev.public.customers;


-- clean up
drop schema if exists demo_db.public_copy;
drop database if exists demo_db_dev;