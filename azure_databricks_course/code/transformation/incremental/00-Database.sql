-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### Create Incremental Load Database

-- COMMAND ----------

-- MAGIC %sql
-- MAGIC -- Create Curated Database
-- MAGIC create database if not exists formula1_curated_inc
-- MAGIC   location 'abfss://curated-database-incremental@dbcourselakehouse.dfs.core.windows.net/';
