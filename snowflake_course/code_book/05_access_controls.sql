-----------------------------------------------------
-- Chapter 5: Leveraging Snowflake Access Controls --
-----------------------------------------------------

----------------------
-- creating objects --
----------------------

-- create warehouses
use role sysadmin;
use warehouse compute_wh;

create or replace warehouse vw1_wh
    with
    warehouse_size = 'x-small'
    initially_suspended = true;
    
create or replace warehouse vw2_wh 
    with
    warehouse_size = 'x-small'
    initially_suspended = true;
    
create or replace warehouse vw3_wh 
    with 
    warehouse_size = 'x-small'
    initially_suspended = true;
    
show warehouses;


-- create databases and schemas
use role sysadmin;
create or replace database db1;
create or replace database db2;
create or replace schema db2_schema1;
create or replace schema db2_schema2;
create or replace schema db1.db1_schema1; -- db2 is set for context, this command uses namespace to create schema under db1
show databases;

-- show databases will only return those which the role has access to
use role public;
show databases;


-- create resource monitor (must use accountadmin)
use role accountadmin;
create or replace resource monitor monitor1_rm
    with 
    credit_quota=10000
    triggers
        on 75 percent do notify
        on 98 percent do suspend
        on 105 percent do suspend_immediate;
        
show resource monitors;


-- create users
use role useradmin;
create or replace user user1 login_name = arnold; 
create or replace user user2 login_name = beatrice; 
create or replace user user3 login_name = collin;
create or replace user user4 login_name = diedre;
show users;


---------------------------
-- creating custom roles --
---------------------------

use role useradmin;
show roles; -- take notice of is_current and is_inherited

use role securityadmin;
show roles; -- take notice of is_current and is_inherited
-- roles above another role in a hierarchy inherit that role

-- create functional roles
-- in practice, all custom roles should assigned to another role
-- this will be implemented later in the chapter
use role useradmin;
create or replace role data_scientist;
create or replace role analyst_sr; 
create or replace role analyst_jr;
create or replace role data_exchange_asst; 
create or replace role accountant_sr;
create or replace role accountant_jr;
create or replace role prd_dba;
create or replace role data_engineer;
create or replace role developer_sr; 
create or replace role developer_jr;
show roles;

-- create service account roles
use role useradmin;
create or replace role loader; 
create or replace role visualizer; 
create or replace role reporting; 
create or replace role monitoring;
show roles;

-- create object access roles
use role useradmin;
create or replace role db1_schema1_readonly; 
create or replace role db1_schema1_all; 
create or replace role db2_schema1_readonly; 
create or replace role db2_schema1_all; 
create or replace role db2_schema2_readonly; 
create or replace role db2_schema2_all;

create or replace role rm1_modify;

create or replace role wh1_usage; 
create or replace role wh2_usage; 
create or replace role wh3_usage;

create or replace role db1_monitor; 
create or replace role db2_monitor; 
create or replace role wh1_monitor; 
create or replace role wh2_monitor; 
create or replace role wh3_monitor; 
create or replace role rm1_monitor;

show roles;


-------------------------------- 
-- role hierarchy assignments --
--------------------------------

-- create system-level role hierarchy
-- reference figure 5.17 for visual
use role useradmin;
grant role rm1_monitor to role monitoring; 
grant role wh1_monitor to role monitoring;
grant role wh2_monitor to role monitoring; 
grant role wh3_monitor to role monitoring;
grant role db1_monitor to role monitoring; 
grant role db2_monitor to role monitoring;
grant role wh3_usage     to role monitoring;   

grant role db1_schema1_all to role loader;
grant role db2_schema1_all to role loader; 
grant role db2_schema2_all to role loader;
grant role wh3_usage to role loader;       

grant role db2_schema1_readonly to role visualizer;
grant role db2_schema2_readonly to role visualizer;
grant role wh3_usage to role visualizer;

grant role db1_schema1_readonly to role reporting; 
grant role db2_schema1_readonly to role reporting;
grant role db2_schema2_readonly to role reporting; 

grant role wh3_usage to role reporting;
grant role monitoring to role accountant_sr; 
grant role loader to role developer_sr;
grant role visualizer to role analyst_jr;    
grant role reporting to role accountant_jr;
grant role rm1_modify to role accountant_sr;

-- create functional-level role hierarchy
-- sysadmin or accountadmin should be top level role in a hierarchy
-- reference figure 5.18 for visual
use role useradmin;
grant role accountant_jr to role accountant_sr;
grant role analyst_jr to role analyst_sr; 
grant role analyst_sr to role data_scientist; 
grant role developer_jr to role developer_sr; 
grant role developer_sr to role data_engineer; 
grant role data_engineer to role prd_dba;
grant role accountant_sr to role accountadmin; 
grant role data_exchange_asst to role accountadmin; 
grant role data_scientist to role sysadmin;
grant role prd_dba to role sysadmin;

-- grant warehouse usage
grant role wh1_usage to role developer_jr;
grant role wh1_usage to role developer_sr;

grant role wh1_usage to role data_engineer; 
grant role wh1_usage to role prd_dba; 
grant role wh2_usage to role accountant_jr; 
grant role wh2_usage to role accountant_sr; 
grant role wh2_usage to role data_exchange_asst; 
grant role wh2_usage to role analyst_jr; 
grant role wh2_usage to role analyst_sr; 
grant role wh2_usage to role data_scientist;


----------------------------------
-- granting priveleges to roles --
----------------------------------

-- grant direct global priveleges to functional roles
use role accountadmin;
grant create data exchange listing on account to role data_exchange_asst;
grant import share on account to role data_exchange_asst;
grant create share on account to role data_exchange_asst;
grant imported privileges on database snowflake to role monitoring; 
grant monitor on resource monitor monitor1_rm to role monitoring;
grant monitor usage on account to role accountant_jr;
grant apply masking policy on account to role accountant_sr;
grant monitor execution on account to role accountant_sr;
grant modify on resource monitor monitor1_rm to role accountant_sr;

-- grant direct assigned priveleges to object access roles
use role sysadmin;
grant usage on database db1 to role db1_schema1_readonly; 
grant usage on database db2 to role db2_schema1_readonly; 
grant usage on database db2 to role db2_schema2_readonly;
grant usage on schema db1.db1_schema1 to role db1_schema1_readonly; 
grant usage on schema db2.db2_schema1 to role db2_schema1_readonly;
grant usage on schema db2.db2_schema2 to role db2_schema2_readonly;

grant select on all tables in schema db1.db1_schema1 to role db1_schema1_readonly;
grant select on all tables in schema db2.db2_schema1 to role db2_schema1_readonly;
grant select on all tables in schema db2.db2_schema2 to role db1_schema1_readonly;

grant all on schema db1.db1_schema1 to role db1_schema1_all; 
grant all on schema db2.db2_schema1 to role db2_schema1_all; 
grant all on schema db2.db2_schema2 to role db2_schema2_all;

grant monitor on database db1 to role db1_monitor; 
grant monitor on database db2 to role db2_monitor;
grant monitor on warehouse vw1_wh to role wh1_monitor; 
grant monitor on warehouse vw2_wh to role wh2_monitor; 
grant monitor on warehouse vw3_wh to role wh3_monitor;

grant usage on warehouse vw1_wh to wh1_usage; 
grant usage on warehouse vw2_wh to wh2_usage; 
grant usage on warehouse vw3_wh to wh3_usage;

-- grant future direct assignments (must use accountadmin)
use role accountadmin;
grant select on future tables in schema db1.db1_schema1 to role db1_schema1_readonly;
grant select on future tables in schema db2.db2_schema1 to role db2_schema1_readonly;
grant select on future tables in schema db2.db2_schema2 to role db2_schema2_readonly;
grant select on future tables in schema db1.db1_schema1 to role db1_schema1_all;
grant select on future tables in schema db2.db2_schema1 to role db2_schema1_all;
grant select on future tables in schema db2.db2_schema2 to role db2_schema2_all;


------------------------------
-- assigning roles to users --
------------------------------

use role useradmin;
grant role data_exchange_asst to user user1;
grant role data_scientist to user user2; 
grant role accountant_sr to user user3; 
grant role prd_dba to user user4;


---------------------
-- user management --
---------------------

-- create user
use role useradmin;
create or replace user user10
    password='123'
    login_name = abarnett
    display_name = amy
    first_name = amy
    last_name = barnett
    email = 'abarnett@company.com'
    must_change_password=true;

-- change user properties
use role useradmin;
alter user user10 set days_to_expiry = 30;


-- set user defaults
use role useradmin;
grant role accountant_sr to user user10;
alter user user10 set default_namespace=snowflake.account_usage;
alter user user10 set default_warehouse=vw2_wh;
alter user user10 set default_role = accountant_sr;

-- describe a user
use role useradmin;
desc user user10;

-- show all users (must run as securityadmin)
use role securityadmin;
show users;
show users like 'user%'; -- using wildcards and like predicate

-- show all users (including dropped) by querying account usage
use role accountadmin;
select * from snowflake.account_usage.users;

-- disable a user
-- does not drop, aborts queries and disables login
user role useradmin;
alter user user10 set disabled = true;

-- drop user
use role useradmin;
drop user user10;


--------------
-- clean up --
--------------

use role sysadmin; 
drop database db1; 
drop database db2; 
show databases;

use role sysadmin;
drop warehouse vw1_wh;
drop warehouse vw2_wh;
drop warehouse vw3_wh;
show warehouses;

use role accountadmin;
drop resource monitor monitor1_rm;
show resource monitors;

use role useradmin;
drop role data_scientist; 
drop role analyst_sr; 
drop role analyst_jr;
drop role data_exchange_asst; 
drop role accountant_sr; 
drop role accountant_jr;
drop role prd_dba; 
drop role data_engineer; 
drop role developer_sr; 
drop role developer_jr; 
drop role loader; 
drop role visualizer; 
drop role reporting;
drop role monitoring;  
drop role rm1_modify; 
drop role wh1_usage;
drop role wh2_usage; 
drop role wh3_usage; 
drop role db1_monitor; 
drop role db2_monitor; 
drop role wh1_monitor; 
drop role wh2_monitor; 
drop role wh3_monitor; 
drop role rm1_monitor; 
drop role db1_schema1_readonly; 
drop role db1_schema1_all; 
drop role db2_schema1_readonly; 
drop role db2_schema1_all;
drop role db2_schema2_readonly; 
drop role db2_schema2_all;
show roles;

use role useradmin;
drop user user1; 
drop user user2; 
drop user user3;
drop user user4;

use role securityadmin; 
show users;