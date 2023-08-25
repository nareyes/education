-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### Create Delta Database

-- COMMAND ----------

-- MAGIC %sql
-- MAGIC -- Create Processed Database
-- MAGIC create database if not exists formula1_processed_delta
-- MAGIC   location 'abfss://processed-database-delta@dbcourselakehouse.dfs.core.windows.net/';
