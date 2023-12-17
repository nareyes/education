----------------------------------------------------------
-- Chapter 9: Analyzing and Improving Query Performance --
----------------------------------------------------------

-------------------
-- query history --
-------------------

-- query detail by user for last day
use role accountadmin;
select
    * 
from table (
    snowflake_sample_data.information_schema.query_history(
        dateadd('days', -1, current_timestamp()),
        current_timestamp()
    )
)
order by total_elapsed_time desc;

-- query detail with frequency and avg compilation
use role accountadmin;
select
    start_time
    ,hash(query_text)
    ,query_text
    ,count(*)
    ,avg(compilation_time)
    ,avg(execution_time)
from table (
    snowflake_sample_data.information_schema.query_history(
        dateadd('days', -1,         
        current_timestamp()),current_timestamp()
    )
)
group by start_time, hash(query_text), query_text
order by count(*) desc, avg(compilation_time) desc;


----------------
-- clustering --
----------------

-- query clustering information
use role accountadmin;
use database snowflake_sample_data;
use schema tpch_sf100;
select system$clustering_information( 'customer' , '(c_nationkey )' );


-------------------------------------------
-- determining clustering key candidates --
-------------------------------------------

-- cardinality and selectivity
use role accountadmin;
use database snowflake_sample_data;
use schema tpch_sf100;

select 'Total Records', count(c_nationkey) from customer

union

select 'Cardinality', count(distinct c_nationkey) from customer

union

select 'Selectivity', count(distinct c_nationkey) / count(c_nationkey) from customer;

-- distribution (looking for even distributions)
use role accountadmin;
use database snowflake_sample_data;
use schema tpch_sf100;
select c_nationkey, count(*) from customer group by c_nationkey order by c_nationkey;

-- creating table with cluster key
-- create or replace table <table name>
--     cluster by (<col or expression>);

-- alter table and add cluster key
-- alter table <table name> cluster by (column name(s));


-------------------------
-- search optimization --
-------------------------

-- adding so to an existing table
-- alter table [if exists] <table name> add search optimization;