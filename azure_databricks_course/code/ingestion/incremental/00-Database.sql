-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### Create Incremental Load Database

-- COMMAND ----------

-- MAGIC %sql
-- MAGIC -- Create Processed Database
-- MAGIC create database if not exists formula1_processed_inc
-- MAGIC   location 'abfss://processed-database-incremental@dbcourselakehouse.dfs.core.windows.net/';
