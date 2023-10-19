/*
- creating share object
- creating reader account
- create database from share
- adding objects to share
- revoke access to a share
*/

-- set context 
use role sysadmin;

use warehouse compute_wh;


-- create demo database and schema
create database demo_db;

create schema demo_schema;


-- create table and secure view
create table demo_table (
    name string, 
    age int
);

insert into demo_table 
    values ('edric',56),('jayanthi',23),('chloe',51),('rowland',50),('lorna',33),('satish',19);

create secure view demo_sec_view
as 
    select name 
    from demo_table 
    where age > 30;

    
-- set context to create share
use role accountadmin;


-- create a share and include two tables
create share demo_share comment = 'sharing demo data';
grant usage on database demo_db to share demo_share;
grant usage on schema demo_db.demo_schema to share demo_share;
grant select on table demo_db.demo_schema.demo_table to share demo_share;


-- create a reader account
create managed account snowflake_tutorial_reader_account 
    admin_name = 'admin', 
    admin_password = 'Passw0rd', 
    type = reader;

show managed accounts;


-- add reader account to share
alter share demo_share add accounts = <reader_account_locator>;


----------------------------------------------------------------------
----------------------------------------------------------------------

-- execute from within reader account
use role accountadmin;


-- create a database in the reader account from a share
create database demo_db_reader from share <main_account_locator>.demo_share;

grant imported privileges on database demo_db_reader to role sysadmin;


--create warehouse in reader account
use role sysadmin;

create or replace warehouse compute_xs with 
    warehouse_size = 'xsmall'
    warehouse_type = 'standard'
    auto_suspend = 600 
    auto_resume = true 
    scaling_policy = 'standard';

    
-- set context
use warehouse compute_xs;

use schema demo_schema;

select * from demo_table;


----------------------------------------------------------------------
----------------------------------------------------------------------

-- execute from within main account
-- add additional objects
grant select on view demo_sec_view to share demo_share;


-- execute from within reader account as sysadmin
-- if changes made to a definition of a schema-level object the grant will have to be reissued
select * from demo_sec_view;


-- execute from within main account as accountadmin
-- remove access to share from reader account
alter share demo_share remove accounts = <reader_account_locator>;

-- clean up
drop share demo_share;

drop database demo_db;

drop managed account snowflake_tutorial_reader_account;