use role accountadmin;
use warehouse compute_wh;


-- show count of full table (32M)
select count (*)
from snowflake_sample_data.tpcds_sf10tcl.customer_address;


-- sampling with the row (bernoulli) method
-- more randomess
-- useful for smaller tables
select * 
from snowflake_sample_data.tpcds_sf10tcl.customer_address 
sample row (10) seed (27); -- 1% sample, seed insures same results each time


-- sampling with the system (random) method
-- more effective processing
-- useful for larger tables
select * 
from snowflake_sample_data.tpcds_sf10tcl.customer_address 
sample system (10) seed(23); -- samples 1% from each micro-partition, seed insures same results each time


-- create views with sample (row method) to compare distributions
create or replace view demo_db.public.customer_address_sample as (
    select * 
    from snowflake_sample_data.tpcds_sf10tcl.customer_address 
    sample row (1) seed(27)
); 

create or replace view demo_db.public.customer_address_sample_large as (
    select * 
    from snowflake_sample_data.tpcds_sf10tcl.customer_address 
    sample row (10) seed(27)
); 


-- inspect data
select count (*)
from demo_db.public.customer_address_sample; -- 324K

select count (*)
from demo_db.public.customer_address_sample_large; -- 3,2M


-- inspect comparisons of distribution
-- small sample (single family 3.24, apartment 3.2295, condo 3.2186, null 0.2975)
select
    ca_location_type,
    count(*) / 3254250 * 100
from demo_db.public.customer_address_sample
group by ca_location_type; 

-- large sample (single family 3.2255, apartment 3.2316, condo 3.2249, null 0.2986)
select 
    ca_location_type,
    count(*) / 32542500 * 100
from demo_db.public.customer_address_sample_large
group by ca_location_type;