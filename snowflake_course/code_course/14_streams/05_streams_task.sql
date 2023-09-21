use role accountadmin;
use warehouse compute_wh;


-- create tasks with change operations
create or replace task stream_db.public.cdc_task
    warehouse = compute_wh
    schedule = '1 minute'
    when system$stream_has_data('stream_db.public.sales_stream')
    as

    merge into stream_db.public.sales_final as tgt
        using (
            select 
                str.*, 
                st.location, 
                st.employees
            from stream_db.public.sales_stream as str
                inner join stream_db.public.stores as st
                    on str.store_id = st.store_id
        ) as src
        on tgt.id = src.id
        when matched -- delete
            and src.metadata$action = 'DELETE' 
            and src.metadata$isupdate = 'false'
            then delete                   
        when matched -- update
            and src.metadata$action ='INSERT' 
            and src.metadata$isupdate  = 'true'       
            then update 
            set tgt.product = src.product,
                tgt.price = src.price,
                tgt.amount = src.amount,
                tgt.store_id = src.store_id
        when not matched -- delete 
            and src.metadata$action ='INSERT'
            then insert 
                (id, product, price, store_id, amount, employees, location)
            values
                (src.id, src.product, src.price, src.store_id, src.amount, src.employees, src.location);

alter task stream_db.public.cdc_task resume;


-- change data operations
insert into stream_db.public.sales_raw
    values 
        (11, 'Milk', 1.99, 1, 2),
        (12, 'Chocolate', 4.49, 1, 2),
        (13, 'Cheese', 3.89, 1, 1);

update stream_db.public.sales_raw
    set product = 'Chocolate Bar'
    where product ='Chocolate';
       
delete from stream_db.public.sales_raw
    where product = 'Mango';  


-- query data from stream and final table
select * from stream_db.public.sales_stream; -- table is now empty since all records have been processed

select * from stream_db.public.sales_final; -- final table has been updated with updated records


-- verify history
select *
from table (information_schema.task_history())
order by name asc, scheduled_time desc;


-- suspend task
alter task stream_db.public.cdc_task suspend;