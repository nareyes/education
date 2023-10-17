/*
- managing masking policies
- managing row access policies
- centralized policy management
*/

-- create database, schema and table for test data
use role sysadmin;

create database sales_db;

create schema sales_schema;

create table customers (
    id number, 
    name string,
    email string,
    country_code string
);

insert into customers
values 
    (138763, 'kajal yash','k-yash@gmail.com' ,'in'), 
    (896731, 'iza jacenty','jacentyi@stanford.edu','pl'),
    (799521, 'finn conley','conley76@outlook.co.uk','ie');


-- create reader role
use role accountadmin; 

grant usage on database sales_db to role analyst; 

grant usage on schema sales_db.sales_schema to role analyst;

grant select on table sales_db.sales_schema.customers to role analyst; 


-- create a masking admin role
create role masking_admin;

grant usage on database sales_db to role masking_admin; 

grant usage on schema sales_db.sales_schema to role masking_admin;

grant create masking policy, create row access policy on schema sales_db.sales_schema to role masking_admin;

grant apply masking policy, apply row access policy  on account to role masking_admin;

grant role masking_admin to user dbtsandbox;


-- create masking policy
use role masking_admin;

use schema sales_db.sales_schema;

create or replace masking policy email_mask as (val string) returns string ->
    case
        when current_role() in ('ANALYST') then val 
        else regexp_replace(val,'.+\@','******@')
    end;

alter table customers 
    modify column email 
    set masking policy email_mask;


-- verify policy
use role analyst;

select * from customers;

use role sysadmin;

select * from customers;


-- create simple row access policy
use role masking_admin;

use schema sales_db.sales_schema;

create or replace row access policy rap as (val varchar) returns boolean ->
    case
        when 'ANALYST' = current_role() then true
        else false
    end;

alter table customers add row access policy rap on (email); -- will fail due to email in use with another policy

alter table customers add row access policy rap on (name);


-- verify policy 
use role analyst;

select * from customers;

use role sysadmin;

select * from customers;


-- create mapping table 
use role sysadmin;

create table title_country_mapping (
    title string,
    country_iso_code string
);

insert into title_country_mapping values ('ANALYST','pl');

grant select on table title_country_mapping to role masking_admin;

use role masking_admin;

create or replace row access policy customer_policy as (country_code varchar) returns boolean ->
  'SYSADMIN' = current_role()
      or exists (
            select 1 from title_country_mapping
              where title = current_role()
                and country_iso_code = country_code
          );


alter table customers add row access policy customer_policy on (country_code); -- will fail

alter table customers drop all row access policies;

alter table customers add row access policy customer_policy on (country_code);


-- verify policy
use role sysadmin;

select * from customers; 

use role analyst;

select * from customers; 

-- clean up
use role sysadmin;

drop database sales_db;