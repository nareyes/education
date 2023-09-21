use role accountadmin;
use warehouse compute_wh;


-- UPDATE 1
-- update a record in the raw table
update stream_db.public.sales_raw
    set product = 'Orange' where product = 'Orange Juice';


-- query data from stream
select * from stream_db.public.sales_stream; -- notice additional metadata columns (action, update, row_id)


-- merge data into final table (insert new record, delete old record)
merge into stream_db.public.sales_final as tgt
    using stream_db.public.sales_stream as src
        on tgt.id = src.id
    when matched
        and src.metadata$action = 'INSERT'
        and src.metadata$isupdate = 'true'
        then update
            set tgt.product = src.product,
                tgt.price = src.price,
                tgt.store_id = src.store_id;


-- query data from stream and final table
select * from stream_db.public.sales_stream; -- table is now empty since all records have been processed

select * from stream_db.public.sales_final; -- final table has been updated with updated records


-- UPDATE 2
-- update a record in the raw table
update stream_db.public.sales_raw
    set product = 'Potato' where product = 'Banana';


-- query data from stream
select * from stream_db.public.sales_stream; -- notice additional metadata columns (action, update, row_id)


-- merge data into final table (insert new record, delete old record)
merge into stream_db.public.sales_final as tgt
    using stream_db.public.sales_stream as src
        on tgt.id = src.id
    when matched
        and src.metadata$action = 'INSERT'
        and src.metadata$isupdate = 'true'
        then update
            set tgt.product = src.product,
                tgt.price = src.price,
                tgt.store_id = src.store_id;
    

-- query data from stream and final table
select * from stream_db.public.sales_stream; -- table is now empty since all records have been processed

select * from stream_db.public.sales_final; -- final table has been updated with updated records