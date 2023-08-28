-- Databricks notebook source
-- MAGIC %md-sandbox
-- MAGIC
-- MAGIC <div  style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://dalhussein.blob.core.windows.net/course-resources/bookstore_schema.png" alt="Databricks Learning" style="width: 600">
-- MAGIC </div>

-- COMMAND ----------

-- MAGIC %run ../00-Includes/02-Copy-Datasets

-- COMMAND ----------

-- query table
-- books column is an array structType
select *
from orders;

-- COMMAND ----------

-- filter array given lambda function
-- extract books with quantity >= 2
select
  order_id,
  books,
  filter (books, i -> i.quantity >= 2) as multiple_copies
from orders;

-- COMMAND ----------

-- adding a where clause cleans up the result
-- subquery and where clause used to eliminate empty arrays
select order_id, multiple_copies
from (
  select
    order_id,
    filter (books, i -> i.quantity >= 2) as multiple_copies
  from orders)
where size(multiple_copies) > 0;

-- COMMAND ----------

-- transform applies transformation to each item in the array and returns the item
select
  order_id,
  books,
  transform (
    books,
    b -> cast(b.subtotal * 0.8 as int)
  ) as subtotal_after_discount
from orders;

-- COMMAND ----------

-- create udf (user defined function)
-- permanent object persisted to database (re-usable)
create or replace function get_url(email string)
returns string

return concat("https://www.", split(email, "@")[1])

-- COMMAND ----------

-- apply udf in a query
select email, get_url(email) as domain
from customers;

-- COMMAND ----------

-- function metadata
describe function get_url;

-- COMMAND ----------

-- function metadata extended
-- shows sql logic
describe function extended get_url;

-- COMMAND ----------

-- more complex udf
create function site_type(email string)
returns string
return case 
          when email like "%.com" then "Commercial business"
          when email like "%.org" then "Non-profits organization"
          when email like "%.edu" then "Educational institution"
          else concat("Unknow extenstion for domain: ", split(email, "@")[1])
       end;

-- COMMAND ----------

-- apply udf in a query
select email, site_type(email) as domain_category
from customers;

-- COMMAND ----------

-- clean up udf's
drop function get_url;
drop function site_type;
