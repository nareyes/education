create or replace database demo_tpch; 

create or replace schema operations 
with managed access  
data_retention_time_in_days = 14;


-- part table
create or replace table part (
    part_id          number(38,0)   not null,
    name             varchar        not null,
    manufacturer     varchar        not null,
    brand            varchar        not null,
    type             varchar        not null,
    size_centimeters number(38,0)   not null,
    container        varchar        not null,
    retail_price_usd number(12,2)   not null,
    comment          varchar,

    constraint pk_part primary key ( part_id ) rely
) comment = 'PARTS WE DISTRIBUTE'
as 
    select
        p_partkey,
        p_name, 
        p_mfgr, 
        p_brand, 
        p_type, 
        p_size, 
        p_container, 
        p_retailprice, 
        p_comment  
    from snowflake_sample_data.tpch_sf10.part;


-- location table
create or replace table location (
    location_id number(38,0)    not null,
    name        varchar(25)     not null,
    region_id   number(38,0)    not null,
    comment     varchar(152),

    constraint pk_location primary key ( location_id) rely,
    constraint ak_location_name unique ( name ) rely
) comment = 'LOCATION ASSIGNED TO CUSTOMER OR SUPPLIER'
as 
    select 
        n_nationkey, 
        n_name, 
        n_regionkey, 
        n_comment  
    from snowflake_sample_data.tpch_sf10.nation;


-- supplier table
create or replace table supplier (
    supplier_id         number(38,0)    not null,
    name                varchar         not null,
    address             varchar         not null,
    location_id         number(38,0)    not null,
    phone               varchar         not null,
    account_balance_usd number(12,2)    not null,
    comment             varchar,

    constraint pk_supplier primary key ( supplier_id ) rely,
    constraint fk_supplier_based_in_location foreign key ( location_id ) references location ( location_id ) rely
) comment = 'SUPPLIERS WHO WE BUY FROM'
as 
    select 
        s_suppkey, 
        s_name, 
        s_address, 
        s_nationkey, 
        s_phone, 
        s_acctbal, 
        s_comment  
    from snowflake_sample_data.tpch_sf10.supplier;


-- customer table
create or replace table customer (
    customer_id         number(38,0)   not null,
    name                varchar        not null,
    address             varchar        not null,
    location_id         number(38,0)   not null,
    phone               varchar(15)    not null,
    account_balance_usd number(12,2)   not null,
    market_segment      varchar(10)    not null,
    comment             varchar,

    constraint pk_customer primary key ( customer_id ) rely,
    constraint fk_customer_based_in_location foreign key ( location_id ) references location ( location_id ) rely
) comment = 'REGISTERED CUSOTMERS'
as 
    select 
        c_custkey, 
        c_name, 
        c_address, 
        c_nationkey, 
        c_phone, 
        c_acctbal, 
        c_mktsegment, 
        c_comment  
    from snowflake_sample_data.tpch_sf10.customer;


-- sales order table
create or replace table sales_order (
    sales_order_id  number(38,0)    not null,
    customer_id     number(38,0)    not null,
    order_status    varchar(1),
    total_price_usd number(12,2),
    order_date      date,
    order_priority  varchar(15),
    clerk           varchar(15),
    ship_priority   number(38,0),
    comment         varchar(79),

    constraint pk_sales_order primary key ( sales_order_id ) rely,
    constraint fk_sales_order_placed_by_customer foreign key ( customer_id ) references customer ( customer_id ) rely
) comment = 'SINGLE ORDER PER CUSTOMER'
as 
    select 
        o_orderkey, 
        o_custkey, 
        o_orderstatus, 
        o_totalprice, 
        o_orderdate, 
        o_orderpriority, 
        o_clerk, 
        o_shippriority, 
        o_comment  
    from snowflake_sample_data.tpch_sf10.orders;


-- inventory table
create or replace table inventory (
    part_id           number(38,0) not null comment 'PART OF UNIQUE IDENTIFIER WITH PS_SUPPKEY',
    supplier_id       number(38,0) not null comment 'PART OF UNIQUE IDENTIFIER WITH PS_PARTKEY',
    available_amount  number(38,0) not null comment 'NUMBER OF PARTS AVAILABLE FOR SALE',
    supplier_cost_usd number(12,2) not null comment 'ORIGINAL COST PAID TO SUPPLIER',
    comment           varchar(),

    constraint pk_inventory primary key ( part_id, supplier_id ) rely,
    constraint fk_inventory_stores_part foreign key ( part_id ) references part ( part_id ) rely,
    constraint fk_inventory_supplied_by_supplier foreign key ( supplier_id ) references supplier ( supplier_id ) rely
) comment = 'WAREHOUSE INVENTORY'
as 
    select 
        ps_partkey, 
        ps_suppkey, 
        ps_availqty, 
        ps_supplycost, 
        ps_comment
    from snowflake_sample_data.tpch_sf10.partsupp;


-- lineitem table
create or replace table lineitem (
    line_number        number(38,0) not null,
    sales_order_id     number(38,0) not null,
    part_id            number(38,0) not null,
    supplier_id        number(38,0) not null,
    quantity           number(12,2),
    extended_price_usd number(12,2),
    discount_percent   number(12,2),
    tax_percent        number(12,2),
    return_flag        varchar(1),
    line_status        varchar(1),
    ship_date          date,
    commit_date        date,
    receipt_date       date,
    ship_instructions  varchar(25),
    ship_mode          varchar(10),
    comment            varchar(44),

    constraint pk_lineitem primary key ( line_number, sales_order_id ) rely,
    constraint fk_lineitem_consists_of_sales_order foreign key ( sales_order_id ) references sales_order ( sales_order_id ) rely,
    constraint fk_lineitem_containing_part foreign key ( part_id ) references part ( part_id ) rely,
    constraint fk_lineitem_supplied_by_supplier foreign key ( supplier_id ) references supplier ( supplier_id ) rely
) comment = 'VARIOUS LINE ITEMS PER ORDER'
as 
    select 
        l_orderkey, 
        l_partkey, 
        l_suppkey, 
        l_linenumber, 
        l_quantity, 
        l_extendedprice, 
        l_discount, 
        l_tax, 
        l_returnflag, 
        l_linestatus, 
        l_shipdate, 
        l_commitdate, 
        l_receiptdate, 
        l_shipinstruct, 
        l_shipmode, 
        l_comment 
    from snowflake_sample_data.tpch_sf10.lineitem;


-- loyalty customer table
create or replace table loyalty_customer (
    customer_id   number(38,0) not null,
    level         varchar      not null    comment 'CUSTOMER FULL NAME',
    type          varchar      not null    comment 'LOYALTY TIER: BRONZE, SILVER, OR GOLD',
    points_amount number       not null,
    comment       varchar                  comment 'CUSTOMER LOYALTY STATUS CALCULATED FROM SALES ORDER VOLUME',

    constraint pk_loyalty_customer primary key ( customer_id ) rely,
    constraint fk_loyalty_customer foreign key ( customer_id ) references customer ( customer_id ) rely
) comment = 'CLIENT LOYALTY PROGRAM WITH GOLD, SILVER, BRONZE STATUS'
AS 

    with
    
    cust as (
        select
            customer_id,
            name,
            address,
            location_id,
            phone,
            account_balance_usd,
            market_segment,
            comment 
        from customer
    ),

    ord as (
        select
            sales_order_id,
            customer_id,
            order_status,
            total_price_usd,
            order_date,
            order_priority,
            clerk,
            ship_priority,
            comment
        from sales_order 
    ),

    cust_ord as ( 
        select
            customer_id, 
            sum(total_price_usd) as total_price_usd 
        from (
            select 
                o.customer_id,
                o.total_price_usd
            from ord o 
                inner join cust c 
                    on o.customer_id = c.customer_id
            where true
                and account_balance_usd > 0 --no deadbeats 
                and  location_id != 22 -- excluding russia from loyalty program will send strong message to putin
        )
        group by customer_id
    ),

    business_logic as (
        select *,
            dense_rank() over  ( order by total_price_usd desc ) as  cust_level,
            case 
                when cust_level between 1 and 20 then 'Gold'
                when cust_level between 21 and 100 then 'Silver'
                when cust_level between 101 and 400 then 'Bronze'
            end as loyalty_level

        from cust_ord
        where true 
        qualify cust_level <= 400
        order by cust_level asc
    ),

    early_supporters as (
        -- the first five customers who believed in us
        select
            $1 as customer_id
        from values (349642), (896215) , (350965) , (404707), (509986)
    ),

    all_loyalty as (
        select
            customer_id,
            loyalty_level,
            'Top 400' as type
        from business_logic 
        
        union all
        
        select 
            customer_id,
            'Gold' as loyalty_level,
            'Early Supporter' as type
        from early_supporters
    ),

    rename as (
        select 
            customer_id,
            loyalty_level as level,
            type,
            0 as points_amount, --will be updated by marketing team
            '' as comments
        from all_loyalty
    )

    select
        * 
    from rename 
    where true;