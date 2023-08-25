-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### Create Delta Database

-- COMMAND ----------

-- MAGIC %sql
-- MAGIC -- Create Curated Database
-- MAGIC create database if not exists formula1_curated_delta
-- MAGIC   location 'abfss://curated-database-delta@dbcourselakehouse.dfs.core.windows.net/';
