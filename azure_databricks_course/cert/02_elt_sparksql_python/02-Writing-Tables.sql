-- Databricks notebook source
-- MAGIC %md-sandbox
-- MAGIC
-- MAGIC <div  style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://dalhussein.blob.core.windows.net/course-resources/bookstore_schema.png" alt="Databricks Learning" style="width: 600">
-- MAGIC </div>

-- COMMAND ----------

-- MAGIC %run ../00-Includes/02-Copy-Datasets

-- COMMAND ----------

-- ctas auto infers schema info
-- does not support manual schema declaration
-- useful for external data ingestion with well-defined schemas (such as parquet files)
create table orders as
  select *
  from parquet.`${dataset.bookstore}/orders`;

-- query table
select *
from orders;

-- COMMAND ----------

-- this overwrites the table, version history is still available since this is a delta table
-- fully replaces content of table every time query is executed
create or replace table orders as
  select *
  from parquet.`${dataset.bookstore}/orders`;

-- query table metadata (version 2)
describe history orders;

-- COMMAND ----------

-- another option to overwrite using insert overwrite
-- can only overwrite existing table, cannot create a new one
-- can only overwrite records that match current table schema (eliminates risk of overwriting/changing schema)
insert overwrite orders
  select *
  from parquet.`${dataset.bookstore}/orders`;

-- query table metadata (version 3)
describe history orders;

-- COMMAND ----------

-- attempting to alter the schema (adding the timestamp) will cause a failure
insert overwrite orders
  select *, current_timestamp() 
  from parquet.`${dataset.bookstore}/orders`;

-- COMMAND ----------

-- append records to a table using insert into
insert into orders
  select *
  from parquet.`${dataset.bookstore}/orders-new`;

-- COMMAND ----------

-- query new record count (previously 1700)
-- no guarantes exisiting records will not be re-written
-- running the query multiple times continues to append the same records causing duplication issues
select count(*) 
from orders;

-- COMMAND ----------

-- alternate method to update records using merge into (upsert)
-- insert, update, and delete depending on the records scenario
-- create temp view for demo
create or replace temp view customers_updates as
  select *
  from json.`${dataset.bookstore}/customers-json-new`;

-- notes
merge into customers as c
  using customers_updates as u
  on c.customer_id = u.customer_id
when matched and c.email is NULL and u.email is not NULL then
  update set email = u.email, updated = u.updated
when not matched then insert *;

-- COMMAND ----------

-- create temp view for another merge demo
create or replace temp view books_updates (
  book_id string, 
  title string, 
  author string, 
  category string, 
  price double
)

using csv
options (
  path = "${dataset.bookstore}/books-csv-new",
  header = "true",
  delimiter = ";"
);

-- query table
select *
from books_updates;

-- COMMAND ----------

-- execute merge opertaion
-- only merge records that pass predicate
merge into books as b
  using books_updates as u
  on b.book_id = u.book_id and b.title = u.title
when not matched and u.category = 'Computer Science' then 
  insert *;
