-- Databricks notebook source
-- MAGIC %md-sandbox
-- MAGIC
-- MAGIC <div  style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://dalhussein.blob.core.windows.net/course-resources/bookstore_schema.png" alt="Databricks Learning" style="width: 600">
-- MAGIC </div>

-- COMMAND ----------

-- MAGIC %run ../00-Includes/02-Copy-Datasets

-- COMMAND ----------

-- query cutomer data
-- nested json string under profile
select *
from customers;

-- COMMAND ----------

-- query table metadata to confirm profile data type
describe customers;

-- COMMAND ----------

-- syntax to parse nested json string
select customer_id, profile:first_name, profile:address:country 
from customers;

-- COMMAND ----------

-- from json will fail without first defining the structType
select from_json(profile) as profile_struct
from customers;

-- COMMAND ----------

-- create temp view with structType for profile column
create or replace temp view parsed_customers as
  select 
    customer_id, 
    from_json(profile, schema_of_json('{"first_name":"Thomas","last_name":"Lane","gender":"Male","address":{"street":"06 Boulevard Victor Hugo","city":"Paris","country":"France"}}')) AS profile_struct
  from customers;

-- query temp view
select *
from parsed_customers;

-- COMMAND ----------

-- query table metadata
-- notice profile_struct data type
describe parsed_customers;

-- COMMAND ----------

-- can now query json array using profile_struct prefix
select 
  customer_id, 
  profile_struct.first_name, 
  profile_struct.address.country
from parsed_customers;

-- COMMAND ----------

-- using wildcard will flatten fields into columns
-- this is a more effective approach to parse a large nested json
create or replace temp view customers_final as
  select 
    customer_id, 
    profile_struct.*
  from parsed_customers;

-- query temp view
select *
from customers_final;

-- COMMAND ----------

-- query orders table to understand schema
-- books is an array
SELECT
  order_id, 
  customer_id, 
  books
from orders;

-- COMMAND ----------

-- explode places each element of array in its own row
select 
  order_id, 
  customer_id, 
  explode(books) AS book 
from orders;

-- COMMAND ----------

-- collect_set allows us to further dive into the array
select 
  customer_id,
  collect_set(order_id) AS orders_set,
  collect_set(books.book_id) AS books_set
from orders
group by customer_id;

-- COMMAND ----------

-- flatten with distinct values
select 
  customer_id,
  collect_set(books.book_id) As before_flatten,
  array_distinct(flatten(collect_set(books.book_id))) AS after_flatten
from orders
group by customer_id;

-- COMMAND ----------

-- inner join functionality
create or replace view orders_enriched as
  select *
  from (
    select *, explode(books) AS book 
    from orders) o
  inner join books as b
    on o.book.book_id = b.book_id;

-- query view
select *
from orders_enriched;

-- COMMAND ----------

-- union functionality
create or replace temp view orders_updates as
  select *
  from parquet.`${dataset.bookstore}/orders-new`;

select * from orders 
UNION 
select * from orders_updates;

-- COMMAND ----------

-- intersect functionality
select * from orders 
intersect 
select * from orders_updates 

-- COMMAND ----------

-- minus functionality
select * from orders 
minus 
select * from orders_updates 

-- COMMAND ----------

-- pivot functionality 
create or replace table transactions AS

select * from (
  select
    customer_id,
    book.book_id AS book_id,
    book.quantity AS quantity
  from orders_enriched
) pivot (
  sum(quantity) for book_id in (
    'B01', 'B02', 'B03', 'B04', 'B05', 'B06',
    'B07', 'B08', 'B09', 'B10', 'B11', 'B12'
  )
);

-- query tabl
select *
from transactions;
