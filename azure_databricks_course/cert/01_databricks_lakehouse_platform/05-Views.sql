-- Databricks notebook source
-- create demo table
create table if not exists smartphones (
      id int,
      name string, 
      brand string, 
      year int
);

-- insert values
insert into smartphones
values
      (1, 'iPhone 14', 'Apple', 2022),
      (2, 'iPhone 13', 'Apple', 2021),
      (3, 'iPhone 6', 'Apple', 2014),
      (4, 'iPad Air', 'Apple', 2013),
      (5, 'Galaxy S22', 'Samsung', 2022),
      (6, 'Galaxy Z Fold', 'Samsung', 2022),
      (7, 'Galaxy S9', 'Samsung', 2016),
      (8, '12 Pro', 'Xiaomi', 2022),
      (9, 'Redmi 11T Pro', 'Xiaomi', 2022),
      (10, 'Redmi Note 11', 'Xiaomi', 2021);

-- COMMAND ----------

-- query table list
show tables;

-- COMMAND ----------

-- create permanent view
create view view_apple_phones
as 
    select * 
    from smartphones 
    where brand = 'Apple';

-- query permanent view
select *
from view_apple_phones;

-- COMMAND ----------

-- query table list (includes views)
show tables;

-- COMMAND ----------

-- create temp view (session)
-- terminated with session
create temp view temp_view_phones_brands
as
    select distinct brand
    from smartphones;


-- query temp view
select *
from temp_view_phones_brands;

-- COMMAND ----------

-- query table list (includes temp views)
show tables;

-- COMMAND ----------

-- create global temp view (cluster)
-- terminated with cluster
create global temp view global_temp_view_latest_phones
as
    select * 
    from smartphones
    where year > 2020
    order by year desc;

-- query global view (must include global_temp prefix)
select *
from global_temp.global_temp_view_latest_phones;

-- COMMAND ----------

-- query table list (does not include global views)
show tables;

-- COMMAND ----------

-- query tables in global_temp schema
show tables in global_temp;

-- COMMAND ----------

-- cleanup
drop table smartphones;
drop view view_apple_phones;
drop view global_temp.global_temp_view_latest_phones;
