use role accountadmin;
use warehouse compute_wh;


-- delete a record from raw table
delete from stream_db.public.sales_raw
    where product = 'Lemon';


-- query data from stream
select * from stream_db.public.sales_stream; -- notice additional metadata columns (action, update, row_id)


-- merge data into final table (insert new record, delete old record)
merge into stream_db.public.sales_final as tgt
    using stream_db.public.sales_stream as src
    on tgt.id = src.id
    when matched
        and src.metadata$action = 'DELETE'
        and src.metadata$update = 'false'
        then delete;


-- query data from stream and final table
select * from stream_db.public.sales_stream; -- table is now empty since all records have been processed

select * from stream_db.public.sales_final; -- final table has been updated with updated records