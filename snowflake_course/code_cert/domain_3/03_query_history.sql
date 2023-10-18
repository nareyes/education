/*
- query history page
- query profile
- account usage view: query history
- information schema table function: query history
*/

-- set context
use role sysadmin;

use database snowflake_sample_data;

use schema tpch_sf1000;


-- run demo query
select
    c_custkey, 
    c_name, 
    c_address, 
    c_acctbal 
from customer 
order by c_acctbal desc
limit 10000;


-- account usage view (365 days of query history)
use role accountadmin;


-- set context 
use database snowflake;

use schema account_usage;


-- query history view (can take up to 45 min)
select * 
from query_history 
where warehouse_size is not null
order by start_time desc
limit 100;


-- ten longest running queries in seconds
select 
  query_id, 
  query_text, 
  user_name, 
  role_name,
  execution_status, 
  round(total_elapsed_time / 1000,2) as total_elapsed_time_sec   
from query_history
where total_elapsed_time_sec > 3
order by total_elapsed_time_sec desc
limit 10;


-- create temporary database for access to information schema
create database demo_db;

use schema demo_db.information_schema;


-- ten longest running queries in seconds (show account wide query history but there is a latency)
select 
  query_id, 
  query_text, 
  user_name, 
  role_name,
  execution_status, 
  round(total_elapsed_time / 1000,2) as total_elapsed_time_sec   
from table(information_schema.query_history())
where total_elapsed_time_sec > 3
order by total_elapsed_time_sec desc
limit 10;


-- clean up
drop database demo_db;