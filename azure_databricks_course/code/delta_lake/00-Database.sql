-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### Create Delta Lake Demo Database

-- COMMAND ----------

-- MAGIC %sql
-- MAGIC -- Create Delta Lake Demo Database
-- MAGIC create database if not exists formula1_delta_demo
-- MAGIC   location 'abfss://delta-demo@dbcourselakehouse.dfs.core.windows.net/';
