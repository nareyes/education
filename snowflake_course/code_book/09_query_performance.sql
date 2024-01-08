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


--------------------------------------------
-- search optimization examples from ch12 --
--------------------------------------------

--,prep work
-- removing cached results for performance testing
use role sysadmin;
use warehouse compute_wh;
create or replace database demo12_db;
create or replace schema cybersecurity;
alter session set use_cached_result = false;

-- create a base table
create or replace table basetable as
    select * from snowflake_sample_data.tpch_sf100.lineitem;
    
-- clone the table for use in the clustering example and then enable clustering
create or replace table clusterexample clone basetable;
alter table clusterexample cluster by (l_shipdate); 

-- verify that the clustering is complete
select system$clustering_information('clusterexample','(l_shipdate)');
/*
{
  "cluster_by_keys" : "LINEAR(l_shipdate)",
  "total_partition_count" : 914,
  "total_constant_partition_count" : 2,
  "average_overlaps" : 265.1882,
  "average_depth" : 161.1072,
  "partition_depth_histogram" : {
    "00000" : 0,
    "00001" : 2,
    "00002" : 0,
    "00003" : 0,
    "00004" : 0,
    "00005" : 0,
    "00006" : 0,
    "00007" : 0,
    "00008" : 0,
    "00009" : 0,
    "00010" : 0,
    "00011" : 0,
    "00012" : 0,
    "00013" : 0,
    "00014" : 0,
    "00015" : 0,
    "00016" : 0,
    "00032" : 2,
    "00064" : 24,
    "00128" : 259,
    "00256" : 627
  },
  "clustering_errors" : [ ]
}
*/

-- compare the results to the unclustered base table
-- identical clustering
select system$clustering_information('basetable','(l_shipdate)');
/*
{
  "cluster_by_keys" : "LINEAR(l_shipdate)",
  "total_partition_count" : 914,
  "total_constant_partition_count" : 2,
  "average_overlaps" : 265.1882,
  "average_depth" : 161.1072,
  "partition_depth_histogram" : {
    "00000" : 0,
    "00001" : 2,
    "00002" : 0,
    "00003" : 0,
    "00004" : 0,
    "00005" : 0,
    "00006" : 0,
    "00007" : 0,
    "00008" : 0,
    "00009" : 0,
    "00010" : 0,
    "00011" : 0,
    "00012" : 0,
    "00013" : 0,
    "00014" : 0,
    "00015" : 0,
    "00016" : 0,
    "00032" : 2,
    "00064" : 24,
    "00128" : 259,
    "00256" : 627
  },
  "clustering_errors" : [ ]
}
*/

-- clone the table and add search optimization
create or replace table optimizeexample clone basetable;
alter table optimizeexample add search optimization;

-- use the show command to see the details
show tables;
/*
table_name         | automatic_clustering   | search_optimization
-----------------------------------------------------------------
basetable          | off                    | off
clusterexample     | on                     | off
optimizeexample    | off                    | on
*/

-- get an example of a record to be used later for the point lookup query
select * from basetable limit 1; -- l_orderkey ='363617027'

-- use the l_orderkey result value on basetable
-- runtime: 6.6s
select * from basetable where l_orderkey ='363617027';

-- use the l_orderkey result value on clustered table
-- runtime: 7.2s
select * from clusterexample where l_orderkey ='363617027';

-- use the range of dates from the previous search on clustered table
-- runtime: 694ms
select * from clusterexample
    where l_shipdate >= '1992-12-05'and l_shipdate <='1993-02-20'
    and l_orderkey = '363617027';

-- use the l_orderkey result value on optimized table
-- runtime: 851ms
select * from optimizeexample where l_orderkey ='363617027';

-- run the clusteing information query again now that some time has passed
-- partition count increases as clustering takes time
select system$clustering_information('clusterexample','(l_shipdate)');
/*
{
  "cluster_by_keys" : "LINEAR(l_shipdate)",
  "total_partition_count" : 913,
  "total_constant_partition_count" : 6,
  "average_overlaps" : 6.138,
  "average_depth" : 4.3669,
  "partition_depth_histogram" : {
    "00000" : 0,
    "00001" : 4,
    "00002" : 16,
    "00003" : 243,
    "00004" : 310,
    "00005" : 163,
    "00006" : 105,
    "00007" : 46,
    "00008" : 19,
    "00009" : 7,
    "00010" : 0,
    "00011" : 0,
    "00012" : 0,
    "00013" : 0,
    "00014" : 0,
    "00015" : 0,
    "00016" : 0
  },
  "clustering_errors" : [ ]
}
*/


------------------
-- code cleanup --
------------------

drop database demo12_db;
alter session set use_cached_result = true;