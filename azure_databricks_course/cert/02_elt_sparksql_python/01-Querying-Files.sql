-- Databricks notebook source
-- MAGIC %md-sandbox
-- MAGIC
-- MAGIC <div  style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://dalhussein.blob.core.windows.net/course-resources/bookstore_schema.png" alt="Databricks Learning" style="width: 600">
-- MAGIC </div>

-- COMMAND ----------

-- MAGIC %run ../00-Includes/02-Copy-Datasets

-- COMMAND ----------

-- MAGIC %python
-- MAGIC # display customers files
-- MAGIC files = dbutils.fs.ls(f"{dataset_bookstore}/customers-json")
-- MAGIC display(files)

-- COMMAND ----------

-- query single json file
select *
from json.`dbfs:/mnt/demo-datasets/bookstore/customers-json/export_001.json`;
-- from json.`${dataset.bookstore}/customers-json/export_001.json`
-- ${dataset.bookstore} == dbfs:/mnt/demo-datasets/bookstore


-- COMMAND ----------

-- query multiple json files using wildcard (*)
select *
from json.`${dataset.bookstore}/customers-json/export_*.json`;

-- COMMAND ----------

-- query directory (assumes all files have the same format and schema)
select *
from json.`${dataset.bookstore}/customers-json`;

-- COMMAND ----------

-- query record count
select count(*)
from json.`${dataset.bookstore}/customers-json`;

-- COMMAND ----------

-- add input file name for debugging purposes (useful spark sql function)
select *,
  input_file_name() as source_file
from json.`${dataset.bookstore}/customers-json`;

-- COMMAND ----------

-- query directory using text prefix
-- allows any text based format (csv, tsv, json, etc)
-- useful when data is corrupted and custom text functions are needed to extract data
select *
from text.`${dataset.bookstore}/customers-json`;

-- COMMAND ----------

-- query row bytes and some metadata using binaryFile
-- length in bytes, content is the binary representation of the file
select *
from binaryFile.`${dataset.bookstore}/customers-json`;

-- COMMAND ----------

-- MAGIC %python
-- MAGIC # display books files
-- MAGIC files = dbutils.fs.ls(f"{dataset_bookstore}/books-csv")
-- MAGIC display(files)

-- COMMAND ----------

-- query directory (assumes all files have the same format and schema)
-- in this example, the header row was not properly identified and is populated in the first row
-- cause is this file is delimited with a ; instead of a ,
-- this read approach does not allow for options so it is not productive 
select *
from csv.`${dataset.bookstore}/books-csv`;

-- COMMAND ----------

-- one solution is to create an external table pointing to an external data source
-- this allows options but excludes benefits of delta tables 
create table books_csv (
  book_id string, 
  title string, 
  author string,
  category string, 
  price double
)

using csv
options (
  header = "true",
  delimiter = ";"
)

location "${dataset.bookstore}/books-csv"; -- location is what makes this an external table

-- query new table
select *
from books_csv;

-- COMMAND ----------

-- query books_csv table metadata
-- external table, no data movement
-- table is querying to file
describe extended books_csv;

-- COMMAND ----------

-- an alternate solution is to create a delta table (managed) using ctas
-- ctas is useful for external data sources with well-defined schemas (schema inferred)
create table customers as
  select *
  from json.`${dataset.bookstore}/customers-json`;

-- query table metadata
describe extended customers;

-- COMMAND ----------

-- this approach will not work for the books files since the schema is not well-defined
create table books_unparsed as
  select *
  from csv.`${dataset.bookstore}/books-csv`;


-- query table
select *
from books_unparsed;

-- COMMAND ----------

-- create temp view as an intermediary step that allows options
create temp view books_tmp_vw (
  book_id string, 
  title string, 
  author string, 
  category string, 
  price double
)

using csv
options (
  path = "${dataset.bookstore}/books-csv/export_*.csv",
  header = "true",
  delimiter = ";"
);

-- create delta table off temp view that properly parsed the file
create table books as
  select *
  from books_tmp_vw;

-- query final table
select *
from books;

-- COMMAND ----------

-- query table metadata (confirm delta table)
describe extended books;
