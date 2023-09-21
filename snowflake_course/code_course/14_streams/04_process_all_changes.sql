use role accountadmin;
use warehouse compute_wh;


-- insert, update, and delete changes
insert into stream_db.public.sales_raw
    values (10, 'Lemon Juice', 2.99, 1, 1);

insert into stream_db.public.sales_raw
    values (11, 'Mango', 2.00, 1, 1);

update stream_db.public.sales_raw
    set price = 3.00
    where product ='Mango';
       
delete from stream_db.public.sales_raw
    where product = 'Potato';  


-- query data from stream
select * from stream_db.public.sales_stream; -- notice additional metadata columns (action, update, row_id)


-- delete, update, insert operation
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



-- query data from stream and final table
select * from stream_db.public.sales_stream; -- table is now empty since all records have been processed

select * from stream_db.public.sales_final; -- final table has been updated with updated records