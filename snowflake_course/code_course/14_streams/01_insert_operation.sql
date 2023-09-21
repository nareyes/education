use role accountadmin;
use warehouse compute_wh;


-- create database
create or replace database stream_db;


-- create sales table
create or replace table stream_db.public.sales_raw (
    id varchar,
    product varchar,
    price varchar,
    amount varchar,
    store_id varchar
);


-- insert values
insert into stream_db.public.sales_raw
    values
        (1, 'Banana', 1.99, 1, 1),
        (2, 'Lemon', 0.99, 1, 1),
        (3, 'Apple', 1.79, 1, 2),
        (4, 'Orange Juice', 1.89, 1, 2),
        (5, 'Cereals', 5.98, 2, 1);

select * from stream_db.public.sales_raw;


-- create store table
create or replace table stream_db.public.stores (
    store_id number,
    location varchar,
    employees number
);


-- insert values
insert into stream_db.public.stores
    values
        (1, 'Chicago', 33),
        (2, 'London', 12);

select * from stream_db.public.stores;


-- create final sales table
create or replace table stream_db.public.sales_final (
    id int,
    product varchar,
    price number,
    amount int,
    store_id int,
    location varchar,
    employees int
);


-- insert values
insert into stream_db.public.sales_final
    select
        s.id,
        s.product,
        s.price,
        s.amount,
        s.store_id,
        st.location,
        st.employees
    from stream_db.public.sales_raw as s
        inner join stream_db.public.stores as st
            on s.store_id = st.store_id;

select * from stream_db.public.sales_final;


-- create stream object (standard and append-only options, standard is default)
-- standard: insert, update, delete
-- append-only: insert
create or replace stream stream_db.public.sales_stream
    on table stream_db.public.sales_raw;
    -- append_only = true;

show streams;

desc stream stream_db.public.sales_stream;


-- query data from stream and raw table
select * from stream_db.public.sales_raw;

select * from stream_db.public.sales_stream; -- empty table since there haven't been changes since the stream was created


-- insert values into raw table
-- rows will also appear in stream object since they are new records
insert into stream_db.public.sales_raw
    values
        (6, 'Milk', 2.99, 1, 1),
        (7, 'Bread', 1.99, 1, 2);


-- query data from stream and final table
select * from stream_db.public.sales_stream; -- notice additional metadata columns (action, update, row_id)

select * from stream_db.public.sales_final; -- notice that the final table has not been updated with above records yet


-- insert values into final table from stream
insert into stream_db.public.sales_final
    select
        s.id,
        s.product,
        s.price,
        s.amount,
        s.store_id,
        st.location,
        st.employees
    from stream_db.public.sales_stream as s
        inner join stream_db.public.stores as st
            on s.store_id = st.store_id;


-- query data from stream and final table
select * from stream_db.public.sales_stream; -- table is now empty since all records have been processed

select * from stream_db.public.sales_final; -- final table has been updated with new records


-- insert additional values into raw table
insert into stream_db.public.sales_raw
    values
        (8, 'Eggs', 2.99, 1, 1),
        (9, 'Butter', 1.99, 1, 2);


-- insert additional values into final table from stream
insert into stream_db.public.sales_final
    select
        s.id,
        s.product,
        s.price,
        s.amount,
        s.store_id,
        st.location,
        st.employees
    from stream_db.public.sales_stream as s
        inner join stream_db.public.stores as st
            on s.store_id = st.store_id;


-- query data from stream and final table
select * from stream_db.public.sales_stream; -- table is now empty since all records have been processed

select * from stream_db.public.sales_final; -- final table has been updated with new records