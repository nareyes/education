-- Databricks notebook source
-- create delta table (managed table)
create table employees (
  id int,
  name string,
  salary double
)

using delta; -- delta is the default format so this is not needed

-- COMMAND ----------

-- insert values into delta table
insert into employees
values
  (1, "Adam", 3500.0),
  (2, "Sarah", 4020.5),
  (3, "John", 2999.3),
  (4, "Thomas", 4000.3),
  (5, "Anna", 2500.0),
  (6, "Kim", 6200.3);

-- COMMAND ----------

-- query table
select *
from employees;

-- COMMAND ----------

-- query table metadata
describe detail employees;

-- COMMAND ----------

-- MAGIC %fs ls 'dbfs:/user/hive/warehouse/employees'

-- COMMAND ----------

-- update records in delta table
update employees
  set salary = salary + 100
  where name like 'A%';

-- COMMAND ----------

-- query table
select *
from employees;

-- COMMAND ----------

-- MAGIC %fs ls 'dbfs:/user/hive/warehouse/employees'

-- COMMAND ----------

-- exisiting files are not changed
-- new files are created with the change and the delta log is updated
-- total file count is still 1 because the most recent version of the table is stored in 1 file
describe detail employees;

-- COMMAND ----------

-- query table history
-- ver0: table was created
-- ver1: records written to table
-- ver2: update operation written to table
describe history employees;

-- COMMAND ----------

-- MAGIC %fs ls 'dbfs:/user/hive/warehouse/employees/_delta_log'

-- COMMAND ----------

-- MAGIC %fs head 'dbfs:/user/hive/warehouse/employees/_delta_log/00000000000000000002.json'
