use role accountadmin;
use warehouse compute_wh;


-- create user
create user test_user
    password = 'test-user-pw';


-- grant usage on warehouse
grant usage on warehouse compute_wh to role public;


-- grant privelages to shared database
grant imported privelages on database data_share_db to role public;