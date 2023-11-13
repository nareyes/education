--------------------------------
-- Chapter 1: Getting Started --
--------------------------------

-- select role
select current_role();


-- select warehouse
select current_warehouse();


-- select database
select current_database();


-- set database context
use database snowflake_sample_data;
select current_database();