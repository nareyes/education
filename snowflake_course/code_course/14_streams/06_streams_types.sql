-- stream object (standard and append-only options, standard is default)
-- standard: insert, update, delete
-- append-only: insert


use role accountadmin;
use warehouse compute_wh;


-- create stream with default
create or replace stream sales_stream_standard
    on table stream_db.public.sales_raw;

-- create stream with append-only
create or replace stream sales_stream_append
    on table stream_db.public.sales_raw
    append_only = true;