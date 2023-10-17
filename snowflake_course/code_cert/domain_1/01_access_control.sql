/*
access control
- role-based access control (rbac)
- discretionary access control (dac)
- roles & privileges
- privilege inheritance
*/

-- set context
use role accountadmin;


-- show roles
show roles;

select 
    "name", 
    "comment" 
from table(result_scan(last_query_id()));

show grants to role securityadmin;


-- create database and schema
use role sysadmin;

create database films_db;

create schema films_schema;

create table films_sysadmin (
    id string, 
    title string,  
    release_date date,
    rating int
);


-- create custom role inherited by sysadmin system-defined role
use role securityadmin;

create role analyst;

grant usage
    on database films_db
    to role analyst;

grant usage, create table
    on schema films_db.films_schema
    to role analyst;

grant usage
    on warehouse compute_wh
    to role analyst;
  
grant role analyst to role sysadmin;

grant role analyst to user dbtsandbox;


-- verify privileges 
show grants to role sysadmin;

show grants of role analyst;

show grants to role analyst;


-- set context
use role analyst;

use schema films_db.films_schema;


-- create table
create table films_analyst (
    id string, 
    title string,  
    release_date date,
    rating int
);

show tables;

show databases;

select 
    "name", 
    "owner" 
from table(result_scan(last_query_id()));


-- future grants
use role securityadmin;

grant usage on future schemas in database films_db to role analyst;

use role sysadmin;

create schema music_schema;

create schema books_schema;

show schemas;

use role analyst;

show schemas;

show grants to role analyst;


--create user and grant role
use role useradmin;

create user demo_user 
    password = 'temp' 
    default_role = analyst 
    default_warehouse = 'compute_wh' 
    must_change_password = true;

use role securityadmin;

grant role analyst to user demo_user;


-- validate as demo_user
use schema films_db.films_schema;

show tables;


-- clean up
use role sysadmin;
drop database films_db;