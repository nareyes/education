use role accountadmin;
use warehouse compute_wh;


-- create reader account
create managed account share_acct
    admin_name = share_acct,
    admin_password = 'UpperLower123',
    type = reader;


-- show accounts
show managed accounts;


-- share data with reader accounts
alter share orders_share
    add account = qn65522 -- locator
    share_restrictions = false; -- overrides restriction for business critical accts


show shares;

desc share cidgeve.qj59379.orders_share;


-- additional steps in share account
-- create a database & schema using share
-- create a virtual warehouse for compute resources


-- create a database in consumer account using the share
create database data_share_db from share <account_name_producer>.orders_share;

-- validate table access
select * from  data_share_db.public.orders;

-- setup virtual warehouse
create warehouse read_wh with
warehouse_size='x-small'
auto_suspend = 180
auto_resume = true
initially_suspended = true;


-- create user
create user test_user password = 'UpperLower123';

-- grant usage on warehouse
grant usage on warehouse read_wh to role public;


-- grating privileges on a shared database for other users
grant imported privileges on database data_share_db to role public;