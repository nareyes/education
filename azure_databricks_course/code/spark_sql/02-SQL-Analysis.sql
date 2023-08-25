-- Databricks notebook source
-- MAGIC %md
-- MAGIC # SQL Analysis - Race Results
-- MAGIC - Create Analysis Table
-- MAGIC - Dominant Drivers Analysis
-- MAGIC - Dominant Drivers Visualizations
-- MAGIC - Dominant Teams Analysis
-- MAGIC - Dominant Teams Visualizations
-- MAGIC - Create Drivers Dashboard
-- MAGIC - Create Teams Dashboard

-- COMMAND ----------

use formula1_processed;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Create Analysis Table

-- COMMAND ----------

-- Create Curated Table
create table formula1_curated.calculated_race_results
using parquet
as

  select
    ra.race_year
    ,c.name as team_name
    ,d.name as driver_name
    ,r.position
    ,r.points
    ,11-r.position as calculated_points
  from formula1_processed.results as r
    inner join formula1_processed.drivers as d
      on r.driver_id = d.driver_id
    inner join formula1_processed.constructors as c
      on r.constructor_id = c.constructor_id
    inner join formula1_processed.races as ra
      on r.race_id = ra.race_id
  where r.position <= 10;

-- COMMAND ----------

-- Query Curated Table
select * from formula1_curated.calculated_race_results;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Dominant Drivers Analysis

-- COMMAND ----------

-- Decade 1 Driver Analysis
select
  driver_name
  ,count(1) as total_races
  ,avg(calculated_points) as avg_points
  ,sum(calculated_points) as total_points
  ,rank() over(order by avg(calculated_points) desc) as driver_rank
from formula1_curated.calculated_race_results
where race_year between 2001 and 2010
group by driver_name
  having count(1) >= 50
order by avg_points desc;

-- COMMAND ----------

-- Decade 2 Driver Analysis
select
  driver_name
  ,count(1) as total_races
  ,avg(calculated_points) as avg_points
  ,sum(calculated_points) as total_points
  ,rank() over(order by avg(calculated_points) desc) as driver_rank
from formula1_curated.calculated_race_results
where race_year between 2011 and 2020
group by driver_name
  having count(1) >= 50
order by avg_points desc;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Dominant Drivers Visualizations

-- COMMAND ----------

-- Total Period Visualization View
create or replace temp view temp_vw_dominant_drivers
as

  select
    driver_name
    ,count(1) as total_races
    ,avg(calculated_points) as avg_points
    ,sum(calculated_points) as total_points
    ,rank() over(order by avg(calculated_points) desc) as driver_rank
  from formula1_curated.calculated_race_results
  group by driver_name
    having count(1) >= 50
  order by avg_points desc;

-- COMMAND ----------

-- Total Period Line Chart
select
  race_year
  ,driver_name
  ,count(1) as total_races
  ,avg(calculated_points) as avg_points
  ,sum(calculated_points) as total_points
from formula1_curated.calculated_race_results
where driver_name in (
  select driver_name
  from temp_vw_dominant_drivers
  where driver_rank <= 10
)
group by race_year, driver_name
order by race_year asc, avg_points desc, total_points desc;

-- COMMAND ----------

-- Total Period Area Chart
select
  race_year
  ,driver_name
  ,count(1) as total_races
  ,avg(calculated_points) as avg_points
  ,sum(calculated_points) as total_points
from formula1_curated.calculated_race_results
where driver_name in (
  select driver_name
  from temp_vw_dominant_drivers
  where driver_rank <= 10
)
group by race_year, driver_name
order by race_year asc, avg_points desc, total_points desc;

-- COMMAND ----------

-- Total Period Bar Chart
select
  race_year
  ,driver_name
  ,count(1) as total_races
  ,avg(calculated_points) as avg_points
  ,sum(calculated_points) as total_points
from formula1_curated.calculated_race_results
where driver_name in (
  select driver_name
  from temp_vw_dominant_drivers
  where driver_rank <= 10
)
group by race_year, driver_name
order by race_year asc, avg_points desc, total_points desc;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Dominant Teams Analysis

-- COMMAND ----------

-- Decade 1 Team Analysis
select
  team_name
  ,count(1) as total_races
  ,avg(calculated_points) as avg_points
  ,sum(calculated_points) as total_points
  ,rank() over(order by avg(calculated_points) desc) as team_rank
from formula1_curated.calculated_race_results
where race_year between 2001 and 2010
group by team_name
  having count(1) >= 100
order by avg_points desc;

-- COMMAND ----------

-- Decade 2 Team Analysis
select
  team_name
  ,count(1) as total_races
  ,avg(calculated_points) as avg_points
  ,sum(calculated_points) as total_points
  ,rank() over(order by avg(calculated_points) desc) as team_rank
from formula1_curated.calculated_race_results
where race_year between 2011 and 2020
group by team_name
  having count(1) >= 100
order by avg_points desc;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Dominant Teams Visualizations

-- COMMAND ----------

-- Total Period Visualization View
create or replace temp view temp_vw_dominant_teams
as

  select
    team_name
    ,count(1) as total_races
    ,avg(calculated_points) as avg_points
    ,sum(calculated_points) as total_points
    ,rank() over(order by avg(calculated_points) desc) as team_rank
  from formula1_curated.calculated_race_results
  group by team_name
    having count(1) >= 100
  order by avg_points desc;

-- COMMAND ----------

-- Total Period Line Chart
select
  race_year
  ,team_name
  ,count(1) as total_races
  ,avg(calculated_points) as avg_points
  ,sum(calculated_points) as total_points
from formula1_curated.calculated_race_results
where team_name in (
  select team_name
  from temp_vw_dominant_teams
  where team_rank <= 5
)
group by race_year, team_name
order by race_year asc, avg_points desc, total_points desc;

-- COMMAND ----------

-- Total Period Area Chart
select
  race_year
  ,team_name
  ,count(1) as total_races
  ,avg(calculated_points) as avg_points
  ,sum(calculated_points) as total_points
from formula1_curated.calculated_race_results
where team_name in (
  select team_name
  from temp_vw_dominant_teams
  where team_rank <= 5
)
group by race_year, team_name
order by race_year asc, avg_points desc, total_points desc;

-- COMMAND ----------

-- Total Period Bar Chart
select
  race_year
  ,team_name
  ,count(1) as total_races
  ,avg(calculated_points) as avg_points
  ,sum(calculated_points) as total_points
from formula1_curated.calculated_race_results
where team_name in (
  select team_name
  from temp_vw_dominant_teams
  where team_rank <= 5
)
group by race_year, team_name
order by race_year asc, avg_points desc, total_points desc;
