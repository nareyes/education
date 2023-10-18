/*
1) metadata cache
2) results cache
3) virtual warehouse local storage
*/

-- set context
use role accountadmin;

use schema snowflake_sample_data.tpch_sf1000;


-- suspend warehouse for metadata cache demo
alter warehouse compute_wh suspend;

alter warehouse set auto_resume = false;


-- count all records (metadata cache operation)
select count(*) from customer;


-- context functions (metadata cache operation)
select current_user();


-- object descriptions (metadata cache operation)
describe table customer;


-- list objects (metadata cache operation)
show tables;


-- system functions  (metadata cache operation)
select system$clustering_information('lineitem', ('l_orderkey'));


-- query that requires a wh will faill
select * from customer;


-- results cache
alter warehouse compute_wh resume if suspended;

alter warehouse set auto_resume = true;

select 
    c_custkey, 
    c_name, 
    c_address, 
    c_nationkey, 
    c_phone 
from customer 
limit 1000000; -- duration 1.9s


select 
    c_custkey, 
    c_name, 
    c_address, 
    c_nationkey, 
    c_phone 
from customer 
limit 1000000; -- duration 79ms (from results from cache)


-- syntactically different
select 
    c_custkey, 
    c_name, 
    c_address, 
    c_nationkey, 
    c_acctbal f
from customer 
limit 1000000; -- duration 1.7s (not from results cache)


-- includes functions evaluated at execution time (run 2x)
select 
    c_custkey, 
    c_name, 
    c_address, 
    c_nationkey,
    c_phone, 
    current_timestamp() 
from customer 
limit 1000000; -- duration 1.7s, 1.9s (not from results cache)

use role accountadmin;


-- turning use_cashce_result off
alter account set use_cached_result = false;

select c_custkey, c_name, c_address, c_nationkey, c_phone from customer limit 1000000; -- prior ran query, duration 1.9s


-- local storage
select 
    o_orderkey, 
    o_custkey, 
    o_orderstatus, 
    o_totalprice, 
    o_orderdate
from orders
where o_orderdate > date('1997-09-19')
order by o_orderdate
limit 1000;

select 
    o_orderkey, 
    o_custkey, 
    o_orderstatus, 
    o_totalprice, 
    o_orderdate
from orders
where o_orderdate > date('1997-09-19')
order by o_orderdate
limit 1000; -- pulls from warehouse cache 


-- additional column
select 
    o_orderkey, 
    o_custkey, 
    o_orderstatus, 
    o_totalprice, 
    o_orderdate,
    o_orderpriority
from orders
where o_orderdate > date('1997-09-19')
order by o_orderdate
limit 1000; -- still benefits from warehouse cache


-- warehouse cache is purged when warehouse is suspended
alter warehouse compute_wh suspend;

alter warehouse compute_wh resume;

select 
    o_orderkey, 
    o_custkey, 
    o_orderstatus, 
    o_totalprice, 
    o_orderdate
from orders
where o_orderdate > date('1997-09-19')
order by o_orderdate
limit 1000; -- does not pull from warehouse cache 


-- clean up
alter account set use_cached_result = true;