use role accountadmin;
use warehouse compute_wh;


-- mazimize automatic caching
-- automatic caching takes place when querys are re-run
-- results are cached for 24 hours or until underlying data has changed
-- caching is done at the warehouse level, meaning different users can benefit from each others caching
-- ensure similar queries are ran under same warehouse for optimal caching


-- run query
select avg (c_birth_year) as avg_birth_year
from snowflake_sample_data.tpcds_sf100tcl_old.customer;
-- initial attempt (duration = 2.8 seconds)
-- second attempt (duration = 131 miliseconds)