use role sysadmin;
use warehouse compute_wh; 


-- create parquet file format (parquet formant needed in create stage statement)
create or replace file format manage_db.file_formats.parquet_format
    type = parquet;

desc file format manage_db.file_formats.parquet_format;


-- create stage
create or replace stage manage_db.external_stage.parquet_stage
    url = 's3://snowflakeparquetdemo'
    file_format = manage_db.file_formats.parquet_format;

list @manage_db.external_stage.parquet_stage;


-- preview data
select * 
from @manage_db.external_stage.parquet_stage 
limit 10;


-- parse parquet data
select
    $1:"__index_level_0__",
    $1:"cat_id",
    $1:"d",
    $1:"date",
    $1:"dept_id",
    $1:"id",
    $1:"item_id",
    $1:"state_id",
    $1:"store_id",
    $1:"value"
from @manage_db.external_stage.parquet_stage
limit 10;


-- parse with conversions
select
    $1: "__index_level_0__":: int as index_level,
    $1: "cat_id":: varchar(50) as category,
    date ($1: "date":: int) as date,
    $1: "dept_id":: varchar(50) as dept_id,
    $1: "id":: varchar(50) as id,
    $1: "item_id":: varchar(50) as item_id,
    $1: "state_id":: varchar(50) as state_id,
    $1: "store_id":: varchar(50) as store_id,
    $1: "value":: int as value
from @manage_db.external_stage.parquet_stage
limit 10;


-- adding metadata
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