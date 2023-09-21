use role accountadmin;
use warehouse compute_wh;


-- clear cache for testing
alter session set use_cached_result = false;
alter warehouse compute_wh suspend;
alter warehouse compute_wh resume;


-- create table
create or replace table demo_db.public.orders as (
    select * 
    from snowflake_sample_data.tpch_sf100.orders
);

-- inspect data
select * 
from demo_db.public.orders
limit 100;


-- track execution times of query
select
    year (o_orderdate) as year,
    max (o_comment) as max_comment,
    min (o_comment) as min_comment,
    max (o_clerk) as max_clerk,
    min (o_clerk) as min_clerk
from demo_db.public.orders
group by year(o_orderdate)
order by year(o_orderdate); -- execution time: 9.3 sec


-- create materialized view
create or replace materialized view demo_db.public.orders_mv as (
    select
        year (o_orderdate) as year,
        max (o_comment) as max_comment,
        min (o_comment) as min_comment,
        max (o_clerk) as max_clerk,
        min (o_clerk) as min_clerk
    from demo_db.public.orders
    group by year(o_orderdate)
);


-- inspect data (execution time: 3.3 sec)
-- changes to underlining data will reflect in view
select * from demo_db.public.orders_mv;


-- show materialized views
use database demo_db;
show materialized views;


-- inspect credits used
select *
from table (demo_db.information_schema.materialized_view_refresh_history());


/*
Materialized views in Snowflake are a powerful feature that allows you to precompute and store the results of a query as a physical table, 
improving query performance and reducing computation costs. 

Here are the key points about materialized views in Snowflake:
- Definition: A materialized view is a precomputed summary table that holds the results of a specific query, which is executed and stored at the time of creation.
- Data Storage: Materialized views store the actual data, not just the query logic. This helps to avoid redundant computation when the same query is executed repeatedly.
- Query Optimization: Materialized views can significantly improve query performance by allowing Snowflake to use the precomputed results instead of re-executing the original query.
- Incremental Refresh: Materialized views can be refreshed incrementally, updating only the changed or new data, which is more efficient compared to a full refresh of the entire view.
- Refresh Policies: Snowflake allows you to define refresh policies for materialized views, specifying when and how often the view should be refreshed, such as on a schedule or based on data changes.
- Maintenance: Materialized views require maintenance to ensure they reflect the latest data accurately. This can involve refreshing the view, rebuilding it, or dropping and recreating it as needed.
- Query Rewrite: Snowflake can automatically rewrite a query to use a materialized view if it determines that using the view will be more efficient based on the query's structure and the materialized view's content.
- Usage Scenarios: Materialized views are useful for complex and frequently used queries, reporting, dashboarding, and scenarios where query performance is critical.
- Cost Considerations: While materialized views can improve query performance, they come with the trade-off of increased storage and maintenance costs, as they store duplicated data that needs to be synchronized with the source data.
- Permissions and Access: Access to materialized views is controlled using standard Snowflake access control mechanisms, allowing you to control who can query, modify, or manage the materialized views.
*/