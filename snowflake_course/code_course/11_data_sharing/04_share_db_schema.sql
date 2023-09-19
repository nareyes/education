use role accountadmin;
use warehouse compute_wh;


-- clone db
create or replace database demo_db_share
    clone demo_db;


-- create share object
use role accountadmin;
create or replace share db_share;


-- grant usage on database & schema
grant usage on database demo_db_share to share db_share;
grant usage on schema demo_db_share.public to share db_share;


-- grant select on all tables
grant select on all tables in schema demo_db_share.public to share db_share;
grant select on all tables in database demo_db_share to share db_share;


-- add account to share
alter share db_share
    add account = <'account-id'>