-- Databricks notebook source
-- query table histoy
describe history employees;

-- COMMAND ----------

-- query older version of table (time travel) using version
select *
from employees version as of 2; -- shortcut: from employees@v2

-- COMMAND ----------

-- query older version of table (time travel) using timestamp
select *
from employees timestamp as of '2023-08-27T18:52:19.000+0000';

-- COMMAND ----------

-- delete from table to demo restore
delete from employees;

-- query table
select *
from employees;

-- COMMAND ----------

-- restore table
restore table employees to version as of 2;

-- query table
select *
from employees;

-- COMMAND ----------

-- query history
-- restore command is recorded as a transaction (ver4)
describe history employees;

-- COMMAND ----------

-- query detail to see num files
-- typically, tables are stored in multiple files
describe detail employees;

-- COMMAND ----------

-- optimize table
-- optimize command combines small files and re-writes to less larger files
-- zorder indexes on a provided column (will not provide benefit on such a small table)
optimize employees
zorder by id;

-- COMMAND ----------

-- query detail to see num files
describe detail employees;

-- COMMAND ----------

-- query history
describe history employees;

-- COMMAND ----------

-- MAGIC %fs ls 'dbfs:/user/hive/warehouse/employees'

-- COMMAND ----------

-- clean up old files (default retention is 7 days)
-- this will not delete any files since all are < 7 days old
vacuum employees;

-- COMMAND ----------

-- MAGIC %fs ls 'dbfs:/user/hive/warehouse/employees'

-- COMMAND ----------

-- update default retention period check (not advised in production)
set spark.databricks.delta.retentionDurationCheck.enabled = false;

-- COMMAND ----------

-- clean up old files
vacuum employees retain 0 hours;

-- COMMAND ----------

-- MAGIC %fs ls 'dbfs:/user/hive/warehouse/employees'

-- COMMAND ----------

-- query history
-- older versions have been removed and are no longer accessible
describe history employees;

-- COMMAND ----------

-- drop table
drop table employees;

-- COMMAND ----------

-- table does not exist
-- file was also deleted
select *
from employees;

-- COMMAND ----------

-- MAGIC %fs ls 'dbfs:/user/hive/warehouse/employees'
