-- Databricks notebook source
-- create managed table in default database (hive metastore)
create table managed_default (
  width int,
  length int,
  height int
);

-- insert values
insert into managed_default
values (3 int, 2 int, 1 int);

-- COMMAND ----------

-- query table metadata (location is default hive metastore)
describe extended managed_default;

-- COMMAND ----------

-- create external table
-- external tables needs location specified (path)
create table external_default (
  width int, 
  length int, 
  height int 
)

location 'dbfs:/mnt/demo/external_default';
  
insert into external_default
values (3 int, 2 int, 1 int);

-- COMMAND ----------

-- query table metadata (location is specified path)
describe extended external_default;

-- COMMAND ----------

-- drop managed table from database
-- files also dropped from fs because its a maanged table
drop table managed_default;

-- COMMAND ----------

-- MAGIC %fs ls 'dbfs:/user/hive/warehouse/managed_default'

-- COMMAND ----------

-- drop external table from database
-- files not dropped from fs because external table files are not managed by the hive metastore
drop table external_default;

-- COMMAND ----------

-- MAGIC %fs ls 'dbfs:/mnt/demo/external_default'

-- COMMAND ----------

-- create schema/database
-- both commands can be used (schemas == databases)
create schema new_default;

-- COMMAND ----------

-- query table metadata (notice .db extension for file path)
describe database extended new_default;

-- COMMAND ----------

use new_default;

-- create managed database in new table
create table managed_new_default (
  width int, 
  length int, 
  height int 
);

-- insert values
insert into managed_new_default
values (3 int, 2 int, 1 int);


-- create external table in new database
create table external_new_default (
  width int, 
  length int, 
  height int 
)

location 'dbfs:/mnt/demo/external_new_default';

-- insert values
insert into managed_new_default
values (3 int, 2 int, 1 int);

-- COMMAND ----------

-- query metadata
describe extended managed_new_default;

-- COMMAND ----------

-- query metadata
describe extended external_new_default;

-- COMMAND ----------

-- drop tables
-- same behavior as when stored in default database
DROP TABLE managed_new_default;
DROP TABLE external_new_default;

-- COMMAND ----------

-- MAGIC %fs ls 'dbfs:/user/hive/warehouse/managed_new_default'

-- COMMAND ----------

-- MAGIC %fs ls 'dbfs:/mnt/demo/external_new_default'

-- COMMAND ----------

-- create schema with specified location (outside of hive metastore)
-- nothing really changes here, tables are still accessible and drop elicits same behavior
create schema custom
location 'dbfs:/Shared/schemas/custom.db';


-- COMMAND ----------

-- query database metadata
describe database extended custom;

-- COMMAND ----------

use custom;

-- create managed database in new table
create table managed_custom (
  width int, 
  length int, 
  height int 
);

-- insert values
insert into managed_custom
values (3 int, 2 int, 1 int);


-- create external table in new database
create table external_custom (
  width int, 
  length int, 
  height int 
)

location 'dbfs:/mnt/demo/external_custom';

-- insert values
insert into external_custom
values (3 int, 2 int, 1 int);


-- COMMAND ----------

-- query metadata
describe extended managed_custom;

-- COMMAND ----------

-- query metadata
describe extended external_custom

-- COMMAND ----------

-- drop tables
-- same behavior as when stored in default database
drop table managed_custom;
drop table external_custom;

-- COMMAND ----------

-- MAGIC %fs ls 'dbfs:/Shared/schemas/custom.db/managed_custom'

-- COMMAND ----------

-- MAGIC %fs ls 'dbfs:/mnt/demo/external_custom'
