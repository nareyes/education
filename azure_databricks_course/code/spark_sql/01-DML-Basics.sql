-- Databricks notebook source
-- MAGIC %md
-- MAGIC # SparkSQL DML Basics
-- MAGIC - Metadata Queries
-- MAGIC - Basic Queries
-- MAGIC - Simple Functions
-- MAGIC - Joins

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Metadata Queries

-- COMMAND ----------

show databases;

-- COMMAND ----------

select
  current_database();

-- COMMAND ----------

use formula1_processed;

-- COMMAND ----------

show tables;

-- COMMAND ----------

desc formula1_processed.drivers;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Basic Queries

-- COMMAND ----------

-- Select & Limit
select
  *
from
  formula1_processed.drivers
limit
  10;

-- COMMAND ----------

-- Filter (Multiple Conditions)
select
  name,
  nationality,
  dob as data_of_birth
from
  formula1_processed.drivers
WHEwhereRE
  nationality = 'British'
  and dob >= '1990-01-01';

-- COMMAND ----------

-- Order BY
select
  name,
  nationality,
  dob as data_of_birth
from
  formula1_processed.drivers
order by
  nationality asc,
  dob desc;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Simple Functions

-- COMMAND ----------

-- concat
select
  *,
  concat (driver_ref, '-', code) as driver_ref_code
from
  formula1_processed.drivers;

-- COMMAND ----------

-- split
select
  *,
  split (name, ' ') [0] as forename,
  split (name, ' ') [1] as surname
from
  formula1_processed.drivers;

-- COMMAND ----------

-- Current Timestamp
select
  *,
  current_timestamp()
from
  formula1_processed.drivers;

-- COMMAND ----------

-- Date Format
select
  *,
  date_format (dob, 'dd-MM-yyyy') as dob_formatted
from
  formula1_processed.drivers;

-- COMMAND ----------

-- Date Add
select
  *,
  date_add (dob, 1) as dob_plus_one
from
  formula1_processed.drivers;

-- COMMAND ----------

-- Count
select
  COUNT(*) as record_count
from
  formula1_processed.drivers;

-- COMMAND ----------

-- Max
select
  MAX (dob) AS max_dob
from
  formula1_processed.drivers;

-- COMMAND ----------

-- Count & Group By
select
  nationality,
  COUNT(*) as record_count
from
  formula1_processed.drivers
group by
  nationality
order by
  nationality asc;

-- COMMAND ----------

-- Filter Group By
select
  nationality,
  count(*) as record_count
from
  formula1_processed.drivers
group by
  nationality
having
  count(*) > 100
order by
  nationality asc;

-- COMMAND ----------

-- Rank Function
select
  nationality,
  name,
  dob,
  rank() over (
    partition by nationality
    order by
      dob desc
  ) as age_rank_by_nationality
from
  formula1_processed.drivers
order by
  nationality asc,
  age_rank_by_nationality asc;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Joins

-- COMMAND ----------

use formula1_curated;

-- COMMAND ----------

-- Create Temp Views for Demo
create or replace temp view vw_driver_standings_2018 as
  select
    race_year,
    driver_name,
    team,
    total_points,
    total_wins,
    rank
  from
    formula1_curated.driver_standings
  where
    race_year = 2018;

create or replace temp view vw_driver_standings_2020 as
  select
    race_year,
    driver_name,
    team,
    total_points,
    total_wins,
    rank
  from
    formula1_curated.driver_standings
  where
    race_year = 2020;

-- COMMAND ----------

-- Query Head 2018
select
  *
from
  vw_driver_standings_2018
limit
  10;

-- COMMAND ----------

-- Query Head 2020
select
  *
from
  vw_driver_standings_2020
limit
  10;

-- COMMAND ----------

-- Inner Join
select
  *
from
  vw_driver_standings_2018 as d_2018
  inner join vw_driver_standings_2020 as d_2020 on (d_2018.driver_name = d_2020.driver_name);

-- COMMAND ----------

-- Left Join
select
  *
from
  vw_driver_standings_2018 as d_2018
  left join vw_driver_standings_2020 as d_2020 on (d_2018.driver_name = d_2020.driver_name)

-- COMMAND ----------

-- Right Join
select
  *
from
  vw_driver_standings_2018 as d_2018
  right join vw_driver_standings_2020 as d_2020 on (d_2018.driver_name = d_2020.driver_name)

-- COMMAND ----------

-- Full Join
-- Left Join
select
  *
from
  vw_driver_standings_2018 as d_2018 
  full join vw_driver_standings_2020 as d_2020 on (d_2018.driver_name = d_2020.driver_name)

-- COMMAND ----------

-- Semi Join
select
  *
from
  vw_driver_standings_2018 as d_2018 
  semi join vw_driver_standings_2020 as d_2020 on (d_2018.driver_name = d_2020.driver_name)

-- COMMAND ----------

-- Anti Join
select
  *
from
  vw_driver_standings_2018 as d_2018
  left join vw_driver_standings_2020 as d_2020 on (d_2018.driver_name = d_2020.driver_name)

-- COMMAND ----------

-- Cross Join
select
  *
from
  vw_driver_standings_2018 as d_2018
  cross join vw_driver_standings_2020 as d_2020
