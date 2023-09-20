use role accountadmin;
use warehouse compute_wh;


-- query load history (db specific)
select * from demo_db.information_schema.load_history;


-- query load histort from global db
select * from snowflake.account_usage.load_history;


-- querying specific tables/schema from global load history
select *
from snowflake.account_usage.load_history
where
    schema_name = 'PUBLIC'
    and table_name = 'ORDER_DETAILS_ERRORS';


select *
from snowflake.account_usage.load_history
where
    schema_name = 'PUBLIC'
    and table_name = 'ORDER_DETAILS_ERRORS'
    and error_count > 0;


select *
from snowflake.account_usage.load_history
where date (last_load_time) <= dateadd (days, -1, current_date); -- returns loads prior to today