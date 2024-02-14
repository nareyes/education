-----------------------------
-- setting up environments --
-----------------------------
create or replace database data_vault;

create or replace schema l0_src comment = 'SCHEMA FOR LANDING AREA OBJECTS';

create or replace schema l1_rdv comment = 'SCHEMA FOR RAW VAULT OBJECTS';


-----------------------------
-- set up the landing area -- 
-----------------------------
-- This exercise will pull from a single source system called 'sys 1'

use schema l0_src;


create or replace table src_nation (
    iso2_code	varchar (2)     not null,
    n_nationkey number(38,0)    not null,
    n_name      varchar(25)     not null,
    n_regionkey number(38,0)    not null,
    n_comment   varchar(152),
    load_dts    timestamp_ntz   not null,
    rec_src     varchar         not null,

    constraint pk_src_nation            primary key ( n_nationkey ),
    constraint ak_src_nation_n_name     unique ( n_name ),
    constraint ak_src_nation_iso2_code  unique ( iso2_code )
) comment = 'ISO 3166 2-LETTER COUNTRY CODES'
as 
    select *
        ,current_timestamp()        
        ,'sys 1'    
    from (     
        select v.code, n.*  
        from snowflake_sample_data.tpch_sf10.nation n
        inner join (
            select $1 id, $2 code from values  
                (0, 'AL'),
                (1, 'AR'),
                (2, 'BR'),
                (3, 'CA'),
                (4, 'EG'),
                (5, 'ET'),
                (6, 'FR'),
                (7, 'DE'),
                (8, 'IN'),
                (9, 'ID'),
                (10, 'IR'),
                (11, 'IQ'),
                (12, 'JP'),
                (13, 'JO'),
                (14, 'KE'),
                (15, 'MA'),
                (16, 'MZ'),
                (17, 'PE'),
                (18, 'CN'),
                (19, 'RO'),
                (20, 'SA'),
                (21, 'VN'),
                (22, 'RU'),
                (23, 'GB'),
                (24, 'US')
            ) as v
    on n.n_nationkey = v.id
    );


create or replace table src_customer (
    c_custkey    number(38,0)   not null,
    c_name       varchar(25),
    c_address    varchar(40),
    iso2_code	 varchar (2)    not null,
    c_phone      varchar(15),
    c_acctbal    number(12,2),
    c_mktsegment varchar(10),
    c_comment    varchar,
    load_dts     timestamp_ntz  not null,
    rec_src      varchar        not null,

    constraint pk_src_customer  primary key ( c_custkey )
) comment = 'REGISTERED CUSTOMERS WITH OR WITHOUT PREVIOUS ORDERS FROM SRC SYSTEM 1';


create or replace table src_orders (
    o_orderkey      number(38,0)    not null,
    o_custkey       number(38,0)    not null,
    o_orderstatus   varchar(1),
    o_totalprice    number(12,2),
    o_orderdate     date,
    o_orderpriority varchar(15),
    o_clerk         varchar(15),
    o_shippriority  number(38,0),
    o_comment       varchar ,
    load_dts        timestamp_ntz   not null,
    rec_src         varchar         not null,

    constraint pk_src_orders primary key ( o_orderkey )
) comment = 'CUSTOMER ORDER HEADERS';


--------------------------------------------
-- simulate data loads from source system -- 
--------------------------------------------

-- create streams for outbound loads to the raw vault
create or replace stream src_customer_strm on table src_customer;
create or replace stream src_orders_strm on table src_orders;


-- task to  simulate a subset of daily records
create or replace task load_daily_init
    warehouse = data_engineer_wh
    schedule = '10 MINUTE'
    as 
    create or replace transient table current_load as 
    select distinct c_custkey as custkey from snowflake_sample_data.tpch_sf10.customer sample (1000 rows);


create or replace task load_src_customer
    warehouse = data_engineer_wh
    after  load_daily_init
    as
    insert into src_customer (
        select
            c_custkey
            , c_name
            , c_address
            , iso2_code
            , c_phone
            , c_acctbal
            , c_mktsegment
            , c_comment
            , current_timestamp()
            , 'sys 1'
        from snowflake_sample_data.tpch_sf10.customer c 
        inner join current_load l  on c.c_custkey = l.custkey
        inner join src_nation n on c.c_nationkey = n.n_nationkey 
    );


create or replace task load_src_orders
    warehouse = data_engineer_wh
    after  load_daily_init
    as
    insert into src_orders (
        select 
            o_orderkey
            , o_custkey
            , o_orderstatus
            , o_totalprice
            , o_orderdate
            , o_orderpriority
            , o_clerk
            , o_shippriority
            , o_comment
            , current_timestamp()
            , 'sys 1'
        from snowflake_sample_data.tpch_sf10.orders o
        inner join current_load l on o.o_custkey = l.custkey
);

alter task load_src_customer resume;
alter task load_src_orders resume;
execute task load_daily_init;


-- save a trip to the task history page
select *
from table(information_schema.task_history())
order by scheduled_time desc;


-- verify records loaded from "source" system
select  'order' as tbl , count(distinct load_dts) as loads,  count(*) cnt from src_orders group by 1 
union all 
select  'customer' as tbl , count(distinct load_dts) as loads,  count(*) cnt from src_customer group by 1;


--------------------------------------------
-- create views for loading the raw vault --
--------------------------------------------

create or replace view src_customer_strm_outbound as 
    select 
        * -- source columns
        ,sha1_binary(upper(trim(c_custkey))) as hub_customer_hk -- business key hash        
        ,sha1_binary(upper(array_to_string(array_construct( 
            nvl(trim(c_name)        ,'x')
            ,nvl(trim(c_address)    ,'x')              
            ,nvl(trim(iso2_code)    ,'x')                 
            ,nvl(trim(c_phone)      ,'x')            
            ,nvl(trim(c_acctbal)    ,'x')               
            ,nvl(trim(c_mktsegment) ,'x')                 
            ,nvl(trim(c_comment)    ,'x')               
        ), '^')))  as customer_hash_diff -- record hash diff
    from src_customer_strm src;


create or replace view src_order_strm_outbound as 
    select 
        *  -- source columns
        ,sha1_binary(upper(trim(o_orderkey))) as hub_order_hk -- business key hash
        ,sha1_binary(upper(trim(o_custkey))) as hub_customer_hk -- business key hash
        ,sha1_binary(upper(array_to_string(array_construct( nvl(trim(o_orderkey),'x'),nvl(trim(o_custkey),'x')), '^')))  as lnk_customer_order_hk -- business key hash                                          
        ,sha1_binary(upper(array_to_string(array_construct( nvl(trim(o_orderstatus)    , 'x')         
            ,nvl(trim(o_totalprice)     , 'x')        
            ,nvl(trim(o_orderdate)      , 'x')       
            ,nvl(trim(o_orderpriority)  , 'x')           
            ,nvl(trim(o_clerk)          , 'x')    
            ,nvl(trim(o_shippriority)   , 'x')          
            ,nvl(trim(o_comment)        , 'x')      
        ), '^'))) as order_hash_diff -- record hash diff    
    from src_orders_strm;


----------------------
-- set up raw vault --
----------------------

use schema l1_rdv;

-- create the hubs
create or replace table hub_customer (
    hub_customer_hk  binary             not null,
    c_custkey        number(38,0)       not null,
    load_dts         timestamp_ntz(9)   not null,
    rec_src          varchar(16777216)  not null,

    constraint pk_hub_customer primary key ( hub_customer_hk )
);                                    


create or replace table hub_order (
    hub_order_hk  binary            not null,
    o_orderkey    number(38,0)      not null,
    load_dts      timestamp_ntz(9)  not null,
    rec_src       varchar(16777216) not null,

    constraint pk_hub_order primary key ( hub_order_hk )
);


-- create the ref table
create or replace table ref_nation (
    iso2_code   varchar(2)          not null,
    n_nationkey number(38,0)        not null,
    n_regionkey number(38,0)        not null,
    n_name      varchar(16777216),
    n_comment   varchar(16777216),
    load_dts    timestamp_ntz(9)    not null,
    rec_src     varchar(16777216)   not null,

    constraint pk_ref_nation primary key ( iso2_code ),
    constraint ak_ref_nation unique 	  ( n_nationkey )
)
as 
select 
    iso2_code,
    n_nationkey,
    n_regionkey,
    n_name,
    n_comment,
    load_dts,
    rec_src     
from l0_src.src_nation;


-- create the sats
create or replace table sat_sys1_customer (
    hub_customer_hk  binary             not null,
    load_dts         timestamp_ntz(9)   not null,
    c_name           varchar(16777216),
    c_address        varchar(16777216),
    c_phone          varchar(16777216),
    c_acctbal        number(38,0),
    c_mktsegment     varchar(16777216),
    c_comment        varchar(16777216),
    iso2_code        varchar(2)         not null,
    hash_diff        binary             not null,
    rec_src          varchar(16777216)  not null,

    constraint pk_sat_sys1_customer primary key ( hub_customer_hk, load_dts ),
    constraint fk_sat_sys1_customer_hcust foreign key ( hub_customer_hk ) references hub_customer ( hub_customer_hk ),
    constraint fk_set_customer_rnation foreign key ( iso2_code ) references ref_nation ( iso2_code )
);                               


create or replace table sat_sys1_order (
    hub_order_hk    binary              not null,
    load_dts        timestamp_ntz(9)    not null,
    o_orderstatus   varchar(16777216),
    o_totalprice    number(38,0),
    o_orderdate     date,
    o_orderpriority varchar(16777216),
    o_clerk         varchar(16777216),
    o_shippriority  number(38,0),
    o_comment       varchar(16777216),
    hash_diff       binary              not null,
    rec_src         varchar(16777216)   not null,

    constraint pk_sat_sys1_order primary key ( hub_order_hk, load_dts ),
    constraint fk_sat_sys1_order foreign key ( hub_order_hk ) references hub_order ( hub_order_hk )
);   

-- create the link
create or replace table lnk_customer_order (
    lnk_customer_order_hk  binary               not null,
    hub_customer_hk        binary               not null,
    hub_order_hk           binary               not null,
    load_dts               timestamp_ntz(9)     not null,
    rec_src                varchar(16777216)    not null,

    constraint pk_lnk_customer_order primary key  ( lnk_customer_order_hk ),
    constraint fk1_lnk_customer_order foreign key ( hub_customer_hk ) references hub_customer ( hub_customer_hk ),
    constraint fk2_lnk_customer_order foreign key ( hub_order_hk )    references hub_order ( hub_order_hk )
);


-------------------------------------------------
-- load the Raw Vault using multi-table insert --
-------------------------------------------------
 
create or replace task customer_strm_tsk
    warehouse = data_engineer_wh
    schedule = '10 minute'
    when
    system$stream_has_data('l0_src.src_customer_strm')
    as 
    insert all
    -- make sure record does not already exist in the hub
    when (select count(1) from hub_customer tgt where tgt.hub_customer_hk = src_hub_customer_hk) = 0
    then into hub_customer  
    ( hub_customer_hk
    , c_custkey
    , load_dts
    , rec_src
    )  
    values 
    ( src_hub_customer_hk
    , src_c_custkey
    , src_load_dts
    , src_rec_src
    ) 
    -- make sure record does not already exist in the sat
    when (select count(1) from sat_sys1_customer tgt where tgt.hub_customer_hk = src_hub_customer_hk 
    -- only insert if changes based on hash diff are detected
    and tgt.hash_diff = src_customer_hash_diff) = 0
    then into sat_sys1_customer  
    (
    hub_customer_hk  
    , load_dts              
    , c_name            
    , c_address         
    , c_phone           
    , c_acctbal         
    , c_mktsegment      
    , c_comment         
    , iso2_code        
    , hash_diff         
    , rec_src              
    )  
    values 
    (
    src_hub_customer_hk  
    , src_load_dts              
    , src_c_name            
    , src_c_address         
    , src_c_phone           
    , src_c_acctbal         
    , src_c_mktsegment      
    , src_c_comment         
    , src_iso2_code     
    , src_customer_hash_diff         
    , src_rec_src              
    )
    select hub_customer_hk    src_hub_customer_hk
        , c_custkey           src_c_custkey
        , c_name              src_c_name
        , c_address           src_c_address
        , iso2_code           src_iso2_code
        , c_phone             src_c_phone
        , c_acctbal           src_c_acctbal
        , c_mktsegment        src_c_mktsegment
        , c_comment           src_c_comment    
        , customer_hash_diff  src_customer_hash_diff
        , load_dts            src_load_dts
        , rec_src             src_rec_src
    from l0_src.src_customer_strm_outbound src;


create or replace task order_strm_tsk
    warehouse = data_engineer_wh
    schedule = '10 MINUTE'
    when
    system$stream_has_data('l0_src.src_orders_strm')
    as 
    insert all
    -- make sure record does not already exist in the hub
    when (select count(1) from hub_order tgt where tgt.hub_order_hk = src_hub_order_hk) = 0
        then into hub_order  
        ( hub_order_hk
        , o_orderkey
        , load_dts
        , rec_src
        )  
        values 
        ( src_hub_order_hk
        , src_o_orderkey
        , src_load_dts
        , src_rec_src
        )  
    -- make sure record does not already exist in the sat
    when (select count(1) from sat_sys1_order tgt where tgt.hub_order_hk = src_hub_order_hk 
    -- only insert if changes based on hash diff are detected
    and tgt.hash_diff = src_order_hash_diff) = 0
        then into sat_sys1_order  
        (
        hub_order_hk  
        , load_dts              
        , o_orderstatus  
        , o_totalprice   
        , o_orderdate    
        , o_orderpriority
        , o_clerk        
        , o_shippriority 
        , o_comment              
        , hash_diff         
        , rec_src              
        )  
        values 
        (
        src_hub_order_hk  
        , src_load_dts              
        , src_o_orderstatus  
        , src_o_totalprice   
        , src_o_orderdate    
        , src_o_orderpriority
        , src_o_clerk        
        , src_o_shippriority 
        , src_o_comment      
        , src_order_hash_diff         
        , src_rec_src              
        )
    -- make sure record does not already exist in the link
    when (select count(1) from lnk_customer_order tgt where tgt.lnk_customer_order_hk = src_lnk_customer_order_hk) = 0
        then into lnk_customer_order  
        (
        lnk_customer_order_hk  
        , hub_customer_hk              
        , hub_order_hk  
        , load_dts
        , rec_src              
        )  
        values 
        (
        src_lnk_customer_order_hk
        , src_hub_customer_hk
        , src_hub_order_hk  
        , src_load_dts              
        , src_rec_src              
        )
        select hub_order_hk           src_hub_order_hk
            , lnk_customer_order_hk  src_lnk_customer_order_hk
            , hub_customer_hk        src_hub_customer_hk
            , o_orderkey              src_o_orderkey
            , o_orderstatus           src_o_orderstatus  
            , o_totalprice            src_o_totalprice   
            , o_orderdate             src_o_orderdate    
            , o_orderpriority         src_o_orderpriority
            , o_clerk                 src_o_clerk        
            , o_shippriority          src_o_shippriority 
            , o_comment               src_o_comment      
            , order_hash_diff         src_order_hash_diff
            , load_dts                    src_load_dts
            , rec_src                    src_rec_src
        from l0_src.src_order_strm_outbound src;    

    
-- audit the record counts before and after calling the RV load tasks
select 'hub_customer' src, count(1) cnt from hub_customer
union all
select 'hub_order', count(1) from hub_order
union all
select 'sat_sys1_customer', count(1) from sat_sys1_customer
union all
select 'sat_sys1_order', count(1) from sat_sys1_order
union all
select 'ref_nation' src, count(1) cnt from ref_nation
union all 
select 'lnk_customer_order', count(1) from lnk_customer_order
union all
select 'l0_src.src_customer_strm_outbound', count(1) from l0_src.src_customer_strm_outbound
union all
select 'l0_src.src_order_strm_outbound', count(1) from l0_src.src_order_strm_outbound;


execute task  customer_strm_tsk;
execute task  order_strm_tsk ;


-- load more source records and repeat the previous tasks to load them into the DV
execute  task  l0_src.load_daily_init;  


-- probe the task history programatically instead of using snowsight ui
select *
from table(information_schema.task_history())
order by scheduled_time desc;


---------------------------
-- clean up environments --
---------------------------
drop database data_vault;
