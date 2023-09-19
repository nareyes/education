use role sysadmin;
use warehouse compute_wh;


-- inspect data we wish to share
select * from demo_db.public.order_details;


-- create a share object
use role accountadmin;
create or replace share orders_share;


-- setup grants
-- grant usage on database
grant usage on database demo_db to share orders_share;


-- grant usage on schema
grant usage on schema demo_db.public to share orders_share; 


-- grant select on table
grant select on table demo_db.public.order_details to share orders_share;


-- validate grants
show grants to share orders_share;


-- add consumer account
alter share orders_share
    add account = <'account-id'>;


-- view share metadata
show shares;

desc share orders_share;
desc share <'account-id'>.orders_share;


-- create database
create database share_db from share <'account-id'>.orders_share;


-- additional steps in consumer account
-- create a database & schema using share
-- create a virtual warehouse for compute resources