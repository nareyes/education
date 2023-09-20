use role accountadmin;
use warehouse compute_wh; 

-- preview parsed parquet data from prior worksheet
select
    $1: "__index_level_0__":: int as index_level,
    $1: "cat_id":: varchar(50) as category,
    date ($1: "date":: int) as date,
    $1: "dept_id":: varchar(50) as dept_id,
    $1: "id":: varchar(50) as id,
    $1: "item_id":: varchar(50) as item_id,
    $1: "state_id":: varchar(50) as state_id,
    $1: "store_id":: varchar(50) as store_id,
    $1: "value":: int as value,
    metadata$filename as file_name,
    metadata$file_row_number as file_row_number,
    current_timestamp as load_date,
    to_timestamp_ntz (current_timestamp) as load_date_ntz -- no time zone
from @manage_db.external_stage.parquet_stage
limit 10;


-- create table
create or replace table demo_db.public.daily_sales_items (
    row_number int,
    index_level int,
    cat_id varchar(50),
    date date,
    dept_id varchar(50),
    id varchar(50),
    item_id varchar(50),
    state_id varchar(50),
    store_id varchar(50),
    value int,
    load_date_ntz timestamp default to_timestamp_ntz (current_timestamp)
);


-- insert parsed data
insert into demo_db.public.daily_sales_items (
    select
        metadata$file_row_number,    
        $1: "__index_level_0__":: int,
        $1: "cat_id":: varchar(50),
        date ($1: "date":: int),
        $1: "dept_id":: varchar(50),
        $1: "id":: varchar(50),
        $1: "item_id":: varchar(50),
        $1: "state_id":: varchar(50),
        $1: "store_id":: varchar(50),
        $1: "value":: int,
        to_timestamp_ntz (current_timestamp)
    from @manage_db.external_stage.parquet_stage
);


-- inspect data
select * 
from demo_db.public.daily_sales_items 
limit 10;