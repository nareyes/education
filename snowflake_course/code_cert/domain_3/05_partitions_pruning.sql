/*
- clustering information system function 
- automatic clustering usage and cost monitoring 
*/

-- set context
use role sysadmin;

use database snowflake_sample_data;

use schema tpcds_sf100tcl;


-- check cluster_by column to determine if a table has a cluster key(s) 
show tables;

select 
    "name", 
    "database_name", 
    "schema_name", 
    "cluster_by" 
from table(result_scan(last_query_id()));

select system$clustering_information('catalog_sales'); --low overlap and depth

select system$clustering_information('catalog_sales', '(cs_list_price)'); -- high overlap and depth (bad col to partition)


select 
    cs_sold_date_sk, 
    cs_sold_time_sk, 
    cs_item_sk, 
    cs_order_number 
from catalog_sales
where 
    cs_sold_date_sk = 2451092 
    and cs_item_sk = 140947; -- only 4 out of 500k+ partitions scanned

    
-- applying a clustering key
-- create table my_table (c1 date, c2 string, c3 number) cluster by (c1);
-- alter table my_table cluster by (c1);


-- set context
use role accountadmin;
use database snowflake;
use schema account_usage;

-- monitoring automatic clustering serverless feature costs 
select 
  start_time, 
  end_time, 
  credits_used, 
  num_bytes_reclustered,
  table_name, 
  schema_name,
  database_name
from automatic_clustering_history;