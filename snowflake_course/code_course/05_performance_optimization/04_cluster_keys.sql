use role accountadmin;
use warehouse compute_wh;

-- choose appropriate table types and data types
-- transient tables for staging/development, temp tables for intermediate results, permanent tables for final results
-- introduce cluster keys for large tables
-- cluster keys create subsets of data in micro-partitions
-- improves scan efficiency for large tables
-- typically automated by snowflake (but can be manually set)
-- snowflake automaticlaly maintains cluster keys
-- clusters should be set on column(s) that are frequently used in joins, where clauses, group by, order by


-- create stage
create or replace stage manage_db.external_stage.aws_stage_cluster
    url = 's3://bucketsnowflakes3/';

list @manage_db.external_stage.aws_stage_cluster;


-- load data into orders table
truncate table demo_db.public.orders;

copy into demo_db.public.orders
    from @manage_db.external_stage.aws_stage_cluster
    file_format = manage_db.file_formats.csv_format
    pattern = '.*OrderDetails.*';

select * from demo_db.public.orders;


-- create table for caching demo (without defining cluster key)
create or replace table demo_db.public.orders_cluster (
    order_id varchar(30),
    amount number(38, 0),
    profit number(38, 0),
    quantity number(38, 0),
    category varchar(30),
    subcategory varchar(30),
    date date
);

-- cluster by (date);


-- insert duplicate data into orders caching for demo
insert into demo_db.public.orders_cluster (
    select
        t1.order_id,
        t1.amount,
        t1.profit,	
        t1.quantity,	
        t1.category,	
        t1.subcategory,	
        date(uniform(1500000000,1700000000,(random())))
    from demo_db.public.orders t1
        cross join (select * from demo_db.public.orders) t2
        cross join (select top 100 * from demo_db.public.orders) t3
);


-- query performance before cluster key
select * 
from demo_db.public.orders_cluster 
where date = '2020-06-09';


-- add cluster and run query to compare results
alter table demo_db.public.orders_cluster
    cluster by (date);

select * 
from demo_db.public.orders_cluster 
where date = '2020-01-05'; -- different date to prevent caching benefit


-- show cluster key
select clustering_key
from demo_db.information_schema.tables
where table_name = 'orders_cluster';



-- multiple cluster example
-- drop cluster
alter table demo_db.public.orders_cluster
    drop clustering key;


-- query performance before cluster key
select * 
from demo_db.public.orders_cluster 
where date = '2020-06-09' and category = 'Electronics';


-- add cluster and run query to compare results
alter table demo_db.public.orders_cluster
    cluster by (date, category);

select * 
from demo_db.public.orders_cluster 
where date = '2020-01-05' and category = 'Electronics'; -- different date to prevent caching benefit

-- show cluster key
select clustering_key
from demo_db.information_schema.tables
where table_name = 'orders_cluster';