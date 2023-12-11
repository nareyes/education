---------------------------------------------------------------------------------------------
-- Chapter 7: Implementing Data Governance, Account Security, and Data Protection/Recovery --
---------------------------------------------------------------------------------------------

---------------
-- prep work --
---------------

-- create user
use role useradmin;
create or replace user adam
    password = 'Temp1234'
    login_name = adam
    display_name = adam
    must_change_password = false;

-- create roles
use role useradmin;
create or replace role hr_role;
create or replace role area1_role;
create or replace role area2_role;

-- create objects and insert data
use role sysadmin;
use warehouse compute_wh;
create or replace database demo7_db;
create or replace schema tag_library;
create or replace schema hrdata;
create or replace schema ch7data;

create or replace table demo7_db.ch7data.ratings (
    emp_id integer
    ,rating integer
    ,dept_id varchar
    ,area integer
);

insert into demo7_db.ch7data.ratings 
    values
    (1, 77, '100', 1)
    ,(2, 80, '100', 1)
    ,(3, 72, '101', 1)
    ,(4, 94, '200', 2)
    ,(5, 88, '300', 3)
    ,(6, 91, '400', 3);

-- grant permissions
use role securityadmin;
grant usage on warehouse compute_wh to role hr_role;
grant usage on warehouse compute_wh to role area1_role;
grant usage on warehouse compute_wh to role area2_role;

grant usage on database demo7_db to role hr_role;
grant usage on database demo7_db to role area1_role;
grant usage on database demo7_db to role area2_role;

grant usage on schema demo7_db.ch7data to role hr_role;
grant usage on schema demo7_db.hrdata to role hr_role;
grant usage on schema demo7_db.ch7data to role area1_role;
grant usage on schema demo7_db.ch7data to role area2_role;

grant select on all tables in schema demo7_db.ch7data to role hr_role;
grant select on all tables in schema demo7_db.ch7data to role area1_role;
grant select on all tables in schema demo7_db.ch7data to role area2_role;

-- assign roles to users
grant role hr_role to user adam;
grant role area1_role to user adam;
grant role area2_role to user adam;
grant role area1_role to role sysadmin;
grant role area2_role to role sysadmin;
-- did not grant hr_role to sysadmin to avoid unauthroized sensitive data access

-- grant future priveleges
use role accountadmin;
grant select on future tables in schema demo7_db.hrdata to role hr_role;
grant insert on future tables in schema demo7_db.hrdata to role hr_role;


-------------------------
-- access history view --
-------------------------

use role accountadmin;
select *
from snowflake.account_usage.access_history;

-- number of queries each user has run
select
    user_name
    ,count(*) as cnt_queries
from snowflake.account_usage.access_history
group by user_name 
order by cnt_queries desc;

-- most frequently used tables
select
    obj.value:objectname::string tablename
    ,count(*) uses 
from snowflake.account_usage.access_history, table(flatten(base_objects_accessed)) as obj 
group by tablename 
order by uses desc;

-- what tables are being accessed, by whom, and how frequently
select
    obj.value:objectname::string tablename
    ,user_name
    ,count(*) uses 
from snowflake.account_usage.access_history, table(flatten(base_objects_accessed)) as obj 
group by 1, 2 
order by uses desc;


----------------------------------
-- data protection and recovery --
----------------------------------

-- change retention period
use role sysadmin;
alter database demo7_db set data_retention_time_in_days = 90;

-- query all tables retention time
use role sysadmin;
select
    table_catalog
    ,table_schema
    ,table_name
    ,retention_time
from demo7_db.information_schema.tables;

-- time travel example
use role sysadmin;
select * from demo7_db.ch7data.ratings;

update demo7_db.ch7data.ratings
    set area = 4;

select * from demo7_db.ch7data.ratings;

select * from demo7_db.ch7data.ratings at (offset => -60*5); -- query table 5 minutes in the past

create or replace table demo7_db.ch7data.ratings
as select * from demo7_db.ch7data.ratings at (offset => -60*5); -- recreate table with data prior to change

select * from demo7_db.ch7data.ratings;

-- drop and undrop
drop table demo7_db.ch7data.ratings;
undrop table demo7_db.ch7data.ratings;

select * from demo7_db.ch7data.ratings;

-- query storage breakdown
use role accountadmin;
select
    table_name
    ,active_bytes
    ,time_travel_bytes
    ,failsafe_bytes
from snowflake.account_usage.table_storage_metrics;


---------------------
-- data governance --
---------------------

-- create tag library schema
use role sysadmin;
create or replace schema demo7_db.tag_library;

-- create classifications
use role sysadmin;
create or replace tag classification;
alter tag classification set comment =
    "Tag Tables or Views with one of the following classification values: 'Confidential', 'Restricted', 'Internal', 'Public'";

create or replace tag pii;
alter tag pii set comment = 
    "Tag Tables or Views with PII with one or more of the following values: 'Phone', 'Email', 'Address'";

create or replace tag sensitive_pii;
alter tag sensitive_pii set comment = 
    "Tag Tables or Views with Sensitive PII with one or more of the following values: 'SSN', 'DL', 'Passport', 'Financial', 'Medical'";

show tags;

-- create demo table
use role sysadmin;
create or replace table demo7_db.hrdata.employees (
    emp_id integer
    ,fname varchar(50)
    ,lname varchar(50)
    ,ssn varchar(50)
    ,email varchar(50)
    ,dept_id integer
    ,dept varchar(50));
    
insert into demo7_db.hrdata.employees (emp_id, fname, lname, ssn, email, dept_id, dept) 
    values
    (0, 'First', 'Last', '000-00-0000', 'email@email.com', '100', 'IT');

-- assign tags to demo table
alter table demo7_db.hrdata.employees
    set tag demo7_db.tag_library.classification = "Confidential";

alter table demo7_db.hrdata.employees modify email
    set tag demo7_db.tag_library.pii = "Email";
    
alter table demo7_db.hrdata.employees modify ssn
    set tag demo7_db.tag_library.sensitive_pii = "SSN";

-- query metadata
show tags;
select system$get_tag('classification', 'demo7_db.hrdata.employees', 'table');
select system$get_tag('sensitive_pii', 'demo7_db.hrdata.employees.ssn', 'column');
select system$get_tag('pii', 'demo7_db.hrdata.employees.email', 'column');
select system$get_tag('sensitive_pii', 'demo7_db.hrdata.employees.email', 'column'); -- returns null, email was not tagges with sensitive_pii

-- locate any object or column that has been tagged sensitive but does not have a data masking policy
-- there is up to a 2 hour delay when creating tags so this query may not return anything immediately 
use role accountadmin;

with 

column_with_tag as (

    select
        object_name table_name
        ,column_name column_name
        ,object_database db_name
        ,object_schema schema_name       
    from snowflake.account_usage.tag_references       
    where tag_schema = 'tag_library'      
        and (tag_name = 'sensitive_pii' or tag_name = 'pii')
        and column_name is not null
), 

column_with_policy as (
    select
        ref_entity_name table_name
        ,ref_column_name column_name
        ,ref_database_name db_name
        ,ref_schema_name schema_name
    from snowflake.account_usage.policy_references
    where policy_kind = 'masking policy'
)

select * from column_with_tag

minus

select * from column_with_policy;


------------------
-- data masking --
------------------

-- mask email and ssn
use role accountadmin;
create or replace masking policy demo7_db.hrdata.emailmask
    as (val string) returns string ->
	case
        when current_role() in ('hr_role') then val
        else '**masked**'
    end;

alter table demo7_db.hrdata.employees modify column email
    set masking policy demo7_db.hrdata.emailmask;

create or replace masking policy demo7_db.hrdata.ssnmask
    as (val string) returns string ->
    case
        when current_role() in ('hr_role') then val
        else '**masked**'
    end;

alter table demo7_db.hrdata.employees modify column ssn
    set masking policy demo7_db.hrdata.ssnmask;

select * from demo7_db.hrdata.employees; -- results masked since account_admin does not have privelege

-- log in with hr_role
-- results will not be masked
use role hr_role;
use warehouse compute_wh;
select * from demo7_db.hrdata.employees;

insert into demo7_db.hrdata.employees (emp_id, fname, lname, ssn, email, dept_id, dept)
    values 
    (1, 'Harry', 'Smith', '111-11-1111', 'harry@coemail.com', '100', 'IT'), 
    (2, 'Marsha', 'Addison', '222-22-2222', 'marsha@coemail.com', '100','IT'),
    (3, 'Javier', 'Sanchez', '333-33-3333', 'javier@coemail.com', '101', 'Marketing'),
    (4, 'Alicia', 'Rodriguez', '444-44-4444', 'alicia@coemail.com', '200', 'Finance'),
    (5, 'Marco', 'Anderson', '555-55-5555', 'marco@coemail.com', '300', 'HR'),
    (6, 'Barbara', 'Francis', '666-66-6666', 'barbara@coemail.com', '400', 'Exec');
    
select * from demo7_db.hrdata.employees;

-- conditional masking
use role accountadmin;
create or replace masking policy demo7_db.hrdata.namemask
    as (emp_id integer, dept_id integer) returns integer ->
    case
        when current_role() = 'hr_role'
	    then emp_id when dept_id = '100'
	    then emp_id
	    else '**masked**'
    end;

--------------
-- clean up --
--------------
use role accountadmin;
drop database demo7_db;
drop user adam;