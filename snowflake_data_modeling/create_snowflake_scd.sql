----------------------------------------------
-- setting up the warehouse and environment --
----------------------------------------------
create warehouse if not exists data_engineer_wh warehouse_size = xsmall;
/* or replace 'data_engineer_wh' in the script below 
   with the name of an existing warehouse that 
   you have access to. */

use database nreyes;
create or replace schema modeling_scd; 


-----------------------------
-- prepare the base tables --
-----------------------------

create or replace table source_system_customer (
    customer_id         number(38,0) not null,
    name                varchar not null,
    address             varchar not null,
    location_id         number(38,0) not null,
    phone               varchar(15) not null,
    account_balance_usd number(12,2) not null,
    market_segment      varchar(10) not null,
    comment             varchar comment 'user comments',

    constraint pk_customer primary key ( customer_id ) 
)
comment = 'loaded from snowflake_sample_data.tpch_sf10.customer'
as 
    select c_custkey, c_name, c_address, c_nationkey, c_phone, c_acctbal, c_mktsegment, c_comment  
    from snowflake_sample_data.tpch_sf10.customer;

create or replace table src_customer (
    customer_id         number(38,0) not null,
    name                varchar not null,
    address             varchar not null,
    location_id         number(38,0) not null,
    phone               varchar(15) not null,
    account_balance_usd number(12,2) not null,
    market_segment      varchar(10) not null,
    comment             varchar comment 'base load of one fourth of total records',
    __ldts              timestamp_ntz not null default current_timestamp(), -- load date

    constraint pk_customer primary key ( customer_id, __ldts )
)
comment = 'source customers for loading changes'
as 
    select
        customer_id
        ,name
        ,address
        ,location_id
        ,phone
        ,account_balance_usd
        ,market_segment
        ,comment
        ,current_timestamp()
    from source_system_customer
    where true 
    and mod(customer_id,4)= 0; -- load one quarter of existing recrods

-- create a clone of src_customer for future exercises
create or replace table src_customer_bak clone src_customer; 

-- create insert task
create or replace task load_src_customer
warehouse = data_engineer_wh
schedule = '10 minute'
as 
    insert into src_customer (
        select
            customer_id
            ,name
            ,address
            ,location_id
            ,phone
            -- if customer id ends in 3, vary the balance amount
            ,iff(mod(customer_id,3)= 0,  (account_balance_usd+random()/100000000000000000)::number(32,2), account_balance_usd)
            ,market_segment
            ,comment
            ,current_timestamp()
        from operations.customer sample (1000 rows)
    );

---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------


------------
-- Type 1 -- 
------------

-- reset source table
create or replace table src_customer clone src_customer_bak;

-- create base table
create or replace table dim_customer_t1 (
    customer_id         number(38,0) not null,
    name                varchar not null,
    address             varchar not null,
    location_id         number(38,0) not null,
    phone               varchar(15) not null,
    account_balance_usd number(12,2) not null,
    market_segment      varchar(10) not null,
    comment             varchar comment 'base load of one fourth of total records',
    diff_hash			varchar (32) not null,
    __ldts              timestamp_ntz not null default current_timestamp() comment 'load date of latest source record',

    constraint pk_customer primary key ( customer_id )
)
comment = 'type 1 customer dim'
as 
    select customer_id
        , name	
        , address
        , location_id
        , phone
        , account_balance_usd
        , market_segment
        , comment
        , md5(account_balance_usd) -- hash type 1 attributes for easy compare
        , __ldts
    from src_customer;

-- simulate a source load
execute task load_src_customer;

-- load type 1
-- get only latest recrrecordsods from src_customer
-- in a real-world scenario, create a view to get the latest records to make the logic leaner
merge into dim_customer_t1 dc
using (
    select *, md5(account_balance_usd) as diff_hash 
	from src_customer  where __ldts =  (select max(__ldts) from src_customer)
) sc
on dc.customer_id = sc.customer_id
when not matched -- new records, insert
then insert values (
	customer_id
	,name
	,address
	,location_id
	,phone
    ,account_balance_usd
	,market_segment
	,comment
    ,diff_hash
    ,__ldts
)
when matched -- record exists
and dc.diff_hash != sc.diff_hash -- check for changes in t.1 dim
then update 
set
    dc.account_balance_usd  = sc.account_balance_usd
	,dc.__ldts = sc.__ldts -- to indicate when last updated
	,dc.diff_hash = sc.diff_hash;

select * from dim_customer_t1 limit 1000;


------------
-- Type 2 -- 
------------

-- reset source table
create or replace table src_customer clone src_customer_bak;


-- create base table
-- using timestamps for from/to columns because this example will perform
-- multiple loads in a given day. most business scenarios would use a date type column. 
create or replace table dim_customer_t2 (
    customer_id         number(38,0) not null,
    name                varchar not null,
    address             varchar not null,
    location_id         number(38,0) not null,
    phone               varchar(15) not null,
    account_balance_usd number(12,2) not null,
    market_segment      varchar(10) not null,
    comment             varchar comment 'base load of one fourth of total records',
    from_dts			timestamp_ntz not null,
    to_dts			    timestamp_ntz not null,
    diff_hash			varchar (32) not null,

    constraint pk_customer primary key ( customer_id, from_dts )
)
comment = 'type 2 customer dim'
as 
    select
        customer_id
        ,name	
        ,address
        ,location_id
        ,phone
        ,account_balance_usd
        ,market_segment
        ,comment
        ,__ldts -- from_date
        ,'9999-12-31'::timestamp_ntz -- to_date
        ,md5(account_balance_usd) -- hash type 2 attributes for easy compare
    from src_customer;


-- create a stream on the t2 dim
create or replace stream strm_dim_customer_t2 on table dim_customer_t2;

-- simulate a source load
execute task load_src_customer;


-- load type 2
-- step 1 (very similar to type 1 SCD merge)
-- get only latest records from src_customer. 
-- in a real-world scenario, create a view to get the latest records to make the logic leaner
merge into dim_customer_t2 dc
using (
    select *, md5(account_balance_usd) as diff_hash 
	from src_customer  where __ldts =  (select max(__ldts) from src_customer)
) sc
on dc.customer_id = sc.customer_id
and  dc.to_dts = '9999-12-31'
when not matched -- new records, insert
then insert values (
	customer_id
	,name	
	,address
	,location_id
	,phone
    ,account_balance_usd
	,market_segment
	,comment
    ,__ldts -- from_date
    ,'9999-12-31'::timestamp_ntz -- to_date
    ,md5(account_balance_usd) -- hash type 2 attributes for easy compare
)
when matched -- record exists
and dc.diff_hash != sc.diff_hash -- check for changes in t.2 dim
then update 
set
    dc.account_balance_usd  = sc.account_balance_usd
	,dc.from_dts = sc.__ldts  -- update the from date to the latest load
	,dc.diff_hash = sc.diff_hash;


-- load type 2
-- step 2 (update metadata in updated t.2 attributes)
insert into dim_customer_t2 
select 
    customer_id
    ,name	
    ,address
    ,location_id
    ,phone
    ,account_balance_usd
    ,market_segment
    ,comment
    ,from_dts 						 -- original from date
    ,dateadd(second,-1, new_to_dts)  -- delimit new to_date to be less than inserted from_dts
    ,diff_hash
from strm_dim_customer_t2 strm 
    inner join   ((select max(__ldts) as new_to_dts from src_customer)) -- get the to_dts for current load
        on true 
        and strm.metadata$action = 'delete'  -- get before-image for updated records 
where true;

-- recreate the stream
-- because it now contains the inserted (updated) records
-- this step is optional because our logic filters on 
-- strm.metadata$action = 'DELETE', but it's cleaner
create or replace stream strm_dim_customer_t2 on table dim_customer_t2;


-- embed steps 1 and 2 into a task tree for easy loading
create or replace task tsk_load_dim_customer_t2
warehouse = data_engineer_wh
schedule = '10 minute'
as select true;

-- create merge task (step 1)
-- get only latest recrods from src_customer. 
-- in a real-world scenario, create a view to get the latest records to make the logic leaner
create or replace task tsk_load_1_dim_customer_t2
warehouse = data_engineer_wh
after tsk_load_dim_customer_t2
as 
merge into dim_customer_t2 dc
using (
    select *, md5(account_balance_usd) as diff_hash 
	from src_customer  where __ldts =  (select max(__ldts) from src_customer)
) sc
on dc.customer_id = sc.customer_id
and  dc.to_dts = '9999-12-31'
when not matched -- new records, insert
then insert values (
	customer_id
	,name	
	,address
	,location_id
	,phone
    ,account_balance_usd
	,market_segment
	,comment
    ,__ldts --from_date
    ,'9999-12-31'::timestamp_ntz -- to_date
    ,md5(account_balance_usd) -- hash type 2 attributes for easy compare
)
when matched -- record exists
and dc.diff_hash != sc.diff_hash -- check for changes in t.2 dim
then update 
set 
    dc.account_balance_usd  = sc.account_balance_usd
	,dc.from_dts = sc.__ldts  -- update the from date to the latest load
	,dc.diff_hash = sc.diff_hash;

alter task tsk_load_1_dim_customer_t2 resume;

-- create the insert task (step 2)
create or replace task tsk_load_2_dim_customer_t2
warehouse = data_engineer_wh
after tsk_load_1_dim_customer_t2
as 
insert into dim_customer_t2 
select 
    customer_id
    ,name	
    ,address
    ,location_id
    ,phone
    ,account_balance_usd
    ,market_segment
    ,comment
    ,from_dts 						 -- original from date
    ,dateadd(second,-1, new_to_dts)  -- delimit new to_date to be less than inserted from_dts
    ,diff_hash
from strm_dim_customer_t2 strm 
    inner join   ((select max(__ldts) as new_to_dts from src_customer)) -- get the to_dts for current load
        on true 
        and strm.metadata$action = 'delete'  -- get before-image for updated records 
where true;

alter task tsk_load_2_dim_customer_t2 resume;

-- simulate a source load
execute task load_src_customer;

-- load t.2 dim
execute task tsk_load_dim_customer_t2;

select * from dim_customer_t2 limit 1000;


------------
-- Type 3 -- 
------------

-- reset source table
create or replace table src_customer clone src_customer_bak;

-- create base table
-- before introducing a t.3 dimension in this example,
-- the table resembles a t.1
create or replace table dim_customer_t3 (
    customer_id         number(38,0) not null,
    name                varchar not null,
    address             varchar not null,
    location_id         number(38,0) not null,
    phone               varchar(15) not null,
    account_balance_usd number(12,2) not null,
    market_segment      varchar(10) not null,
    comment             varchar comment 'base load of one fourth of total records',
    diff_hash			varchar (32) not null,
    __ldts              timestamp_ntz not null default current_timestamp() comment 'load date of latest source record',

    constraint pk_customer primary key ( customer_id )
)
comment = 'type 1 customer dim'
as 
    select
        customer_id
        ,name	
        ,address
        ,location_id
        ,phone
        ,account_balance_usd
        ,market_segment
        ,comment
        ,md5(account_balance_usd) -- hash type 1 attributes for easy compare
        ,__ldts
    from src_customer;

-- add a type 3 dimension
alter table dim_customer_t3 add column original_account_balance_usd number(12,2);

update dim_customer_t3
set original_account_balance_usd = account_balance_usd;

-- simulate a source load
execute task load_src_customer ;

-- load type 1 in t3
-- get only latest recrods from src_customer.
-- in a real-world scenario, create a view to get the latest records to make the logic leaner
merge into dim_customer_t3 dc
using (
    select *, md5(account_balance_usd) as diff_hash 
	from src_customer  where __ldts =  (select max(__ldts) from src_customer)
) sc
on dc.customer_id = sc.customer_id
when not matched -- new records, insert
then insert values (
	customer_id
	,name
	,address
	,location_id
	,phone
    ,account_balance_usd
	,market_segment
	,comment
    ,diff_hash
    ,__ldts
    ,account_balance_usd -- this is the t.3 column and will not be updated going forward
)
when matched -- record exists
and dc.diff_hash != sc.diff_hash -- check for changes in t.1 dim
then update 
set
    dc.account_balance_usd  = sc.account_balance_usd
	,dc.__ldts = sc.__ldts -- to indicate when last updated
	,dc.diff_hash = sc.diff_hash;

select * from dim_customer_t3 limit 1000;