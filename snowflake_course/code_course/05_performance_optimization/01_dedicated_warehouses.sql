use role sysadmin;
-- dedicated virtual warehouse for different user groups and/or work loads
-- create dedicated virtual warehouses for every class of workload desired
-- choose appropriate warehouse size and type for the workload
-- implement auto-suspend and auto-resume to save costs
-- set appropriate time-outs for auto-suspend and auto-resume


-- data scientist group 
create warehouse ds_wh
with 
    warehouse_size = 'small'
    warehouse_type = 'standard'
    auto_suspend = 300
    auto_resume = true
    min_cluster_count = 1
    max_cluster_count = 3
    scaling_policy = 'standard';
    
    
-- dba group
create warehouse dba_wh
with 
    warehouse_size = 'small'
    warehouse_type = 'standard'
    auto_suspend = 300
    auto_resume = true
    min_cluster_count = 1
    max_cluster_count = 3
    scaling_policy = 'standard';


use role accountadmin;
-- create roles for ds and dbas
create role data_scientist;
grant usage on warehouse ds_wh to role data_scientist;

create role dba;
grant usage on warehouse dba_wh to role dba;


-- create users and assign roles/wh
-- data scientists
create user ds1
    password = 'ds1'
    login_name = 'ds1'
    default_role = 'data_scientist'
    default_warehouse = 'ds_wh'
    must_change_password = true;

create user ds2
    password = 'ds2'
    login_name = 'ds2'
    default_role = 'data_scientist'
    default_warehouse = 'ds_wh'
    must_change_password = true;

create user ds3
    password = 'ds3'
    login_name = 'ds3'
    default_role = 'data_scientist'
    default_warehouse = 'ds_wh'
    must_change_password = true;

-- dbas
create user dba1
    password = 'dba1'
    login_name = 'dba1'
    default_role = 'dba'
    default_warehouse = 'dba_wh'
    must_change_password = true;

create user dba2
    password = 'dba2'
    login_name = 'dba2'
    default_role = 'dba'
    default_warehouse = 'dba_wh'
    must_change_password = true;

create user dba3
    password = 'dba3'
    login_name = 'dba3'
    default_role = 'dba'
    default_warehouse = 'dba_wh'
    must_change_password = true;


-- asign roles to users (default set in the create user statement)
grant role data_scientist to user ds1;
grant role data_scientist to user ds2;
grant role data_scientist to user ds3;
    
grant role dba to user dba1;
grant role dba to user dba2;
grant role dba to user dba3;


-- drop objects
drop user ds1;
drop user ds2;
drop user ds3;
drop user dba1;
drop user dba2;
drop user dba3;

drop role data_scientist;
drop role dba;

drop warehouse ds_wh;
drop warehouse dba_wh;