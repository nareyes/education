-- cron scheduling
-- using cron <minute> <hour> <day of month> <month> <day of week> <timezone>

/*
__________ minute (0-59)
| ________ hour (0-23)
| | ______ day of month (1-31, or L)
| | | ____ month (1-12, JAN-DEC)
| | | | __ day of week (0-6, SUN-SAT, or L)
| | | | | __ timezone (utc or named timezone)
| | | | | |
* * * * * *
*/

-- cron scheduling examples
-- every minute
-- schedule = 'using cron * * * * * utc'


-- every day at 6am utc
-- schedule = 'using cron 0 6 * * * utc'

-- every hour starting at 9 am and ending at 5 pm on sundays 
-- schedule = 'using cron 0 9-17 * * sun america/los_angeles'


use role accountadmin;
use warehouse compute_wh;


-- create task with cron scheduler
create or replace task customer_insert_cron
    warehouse = compute_wh
    schedule = 'using cron 0 9-17 * * sun utc'
    as 
        insert into task_db.public.customers (created_date) 
        values (current_timestamp); -- default state is suspended


show tasks;