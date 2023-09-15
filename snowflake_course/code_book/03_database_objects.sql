// snowflake definitive guide 1st edition by joyce kay avila - august 2022
// isbn-10 : 1098103823
// isbn-13 : 978-1098103828
// contact the author: https://www.linkedin.com/in/joycekayavila/
// chapter 3: creating and managing snowflake secuirable database objects


-- set warehouse context
use warehouse compute_wh;


-- create permanent database (using sysadmin role)
use role sysadmin;

create or replace database demo_db_permanent;


-- create transient database (using sysadmin role)
use role sysadmin;

create or replace transient database demo_db_transient;


-- see databases accessible to various roles
-- notice retention period for each database
use role sysadmin;
show databases;

use role accountadmin;
show databases;


-- update data retention policy for a permanent database
-- maximum retention period is 90 days
use role sysadmin;
alter database demo_db_permanent
    set data_retention_time_in_days = 10;


-- update data retention policy for a transient database
-- maximum retention period is 1 day (below statement will fail)
use role sysadmin;
alter database demo_db_transient
    set data_retention_time_in_days = 10;


-- create a table in a permanent database
use role sysadmin;
use database demo_db_permanent;

create or replace table demo_db_permanent.public.summary (
    cash_amt number,
    receivables_amt number,
    customer_amt number
);


-- show permanent db table metadata
show tables;


-- create a table in a transient database
use role sysadmin;
use database demo_db_transient;
create or replace table demo_db_transient.public.summary (
    cash_amt number,
    receivables_amt number,
    customer_amt number
);


-- show transient db table metadata
show tables;


-- create schema by setting context
use role sysadmin;
use database demo_db_permanent;
create or replace schema banking;


-- create schema using fully qualified name
use role sysadmin;
create or replace schema demo_db_permanent.banking;


-- view schema metadata
show schemas;


-- changing schema retention time (defaults to database retention time)
use role sysadmin;
alter schema demo_db_permanent.banking
    set data_retention_time_in_days = 1;


-- moving table to a different schema
use role sysadmin;

create or replace schema demo_db_transient.banking;

alter table demo_db_transient.public.summary
    rename to demo_db_transient.banking.summary;


-- create schema with managed access
use role sysadmin;
create or replace schema demo_db_permanent.mschema
    with managed access;


show schemas;


-- information_schema account views (database context is irrelevant)
select * from information_schema.applicable_roles;
select * from information_schema.databases;
select * from information_schema.enabled_roles;
select * from information_schema.load_history;
select * from information_schema.replication_databases;


-- information_schema database views (database context is relevant)
select * from demo_db_permanent.information_schema.columns;
select * from demo_db_permanent.information_schema.external_tables;
select * from demo_db_permanent.information_schema.file_formats;
select * from demo_db_permanent.information_schema.functions;
select * from demo_db_permanent.information_schema.object_privileges;
select * from demo_db_permanent.information_schema.pipes;
select * from demo_db_permanent.information_schema.procedures;
select * from demo_db_permanent.information_schema.referential_constraints;
select * from demo_db_permanent.information_schema.schemata;
select * from demo_db_permanent.information_schema.sequences;
select * from demo_db_permanent.information_schema.stages;
select * from demo_db_permanent.information_schema.table_constraints;
select * from demo_db_permanent.information_schema.table_privileges;
select * from demo_db_permanent.information_schema.table_storage_metrics;
select * from demo_db_permanent.information_schema.tables;
select * from demo_db_permanent.information_schema.usage_privileges;
select * from demo_db_permanent.information_schema.views;


-- query account_usage schema in showflake database for credits used over time
use role accountadmin;
use warehouse compute_wh;

select
    start_time::date as usage_date,
    warehouse_name,
    sum (credits_used) as total_credits_consumed
from snowflake.account_usage.warehouse_metering_history
where start_time >= date_trunc (month, current_date)
group  by 1, 2
order by 2, 1;


-- creating tables (fully qualified names are not required if context is set, but it is a best practice)
use role sysadmin;
use warehouse compute_wh;
use database demo_db_permanent;

create or replace schema demo_db_permanent.banking;

create or replace table demo_db_permanent.banking.customer_acct (
    customer_account int,
    amount int,
    transaction_ts timestamp
);

create or replace table demo_db_permanent.banking.cash (
    customer_account int,
    amount int,
    transcation_ts timestamp 
);

create or replace table demo_db_permanent.banking.receivables (
    customer_account int,
    amount int,
    transaction_ts timestamp 
);

create or replace table demo_db_permanent.banking.new_table (
    customer_account int,
    amount int,
    transaction_ts timestamp
);


-- show table metadata
show tables;

drop table demo_db_permanent.banking.new_table;

show tables;


-- creating non-materialized view (fully qualified names are not required if context is set, but it is a best practice)
use role sysadmin;
use warehouse compute_wh;

create or replace view demo_db_transient.public.new_view as (
    select cc_name
    from (
        select * 
        rom snowflake_sample_data.tpcds_sf100tcl.call_center
    )
);

select * from demo_db_transient.public.new_view;


-- creating materialized view (fully qualified names are not required if context is set, but it is a best practice)
use role sysadmin;
use warehouse compute_wh;

create or replace materialized view demo_db_transient.public.new_view_mvw as (
    select cc_name
    from (
        select * 
        from snowflake_sample_data.tpcds_sf100tcl.call_center
    )
);

select * from demo_db_transient.public.new_view;


-- show view metadata
use schema demo_db_transient.public;
show views;


-- create materialized and non-materialized views to show differences
create or replace materialized view demo_db_transient.banking.summary_mvw as
select * from (select * from demo_db_transient.banking.summary);

create or replace view demo_db_transient.banking.summary_vw as
select * from (select * from demo_db_transient.banking.summary);

use schema demo_db_transient.banking;
show views;


-- create file format for loading json data into a stage
use role sysadmin;
use database demo_db_transient;

create or replace file format ff_json
    type = json;


-- create internal stage using file format object
use role sysadmin;
use database demo_db_transient;
use schema demo_db_transient.banking;

create or replace temporary stage banking_stg
    file_format = ff_json;


-- create udf to show javascript properties avaialble for udfs and procedures
use role sysadmin;
use database demo_db_permanent;

-- create or replace function js_properties()
--     returns string 
--     language javascript as 
--         'return Object.getOwnPropertyNames(this)';

-- select js_properties();


-- create javascript udf which returns a scalar result
use role sysadmin;
use database demo_db_permanent;

-- create or replace function factorial (n variant)
--     returns variant 
--     language javascript as 
--         'var f = n;
--         for (i = n - 1; i > 0; i--) {
--             f = f * i
--         }
--         return f';

-- select factorial(5);

-- select factorial(35); -- numeric value out of range (javascript udf limitation)


-- secure udf demo
-- create demo table
use role sysadmin;
use warehouse compute_wh;

create or replace table demo_db_permanent.public.sales as (
    select *
    from snowflake_sample_data.tpcds_sf100tcl.web_sales
)
limit 100000;

select top 10 * from demo_db_permanent.public.sales;

-- query products sold along with the product which has an sk of 1
select
    1 as input_item,
    ws_web_site_sk as basket_item,
    count (distinct ws_order_number) as baskets
from demo_db_permanent.public.sales
where ws_order_number in (
    select ws_order_number
    from demo_db_permanent.public.sales
    where ws_web_site_sk = 1
)
group by ws_web_site_sk
order by 3 desc, 2 asc;

-- create secure sql udf function
use role sysadmin;

create or replace secure function
    demo_db_permanent.public.get_mktbasket (input_web_site_sk number(38))

    returns table (
        input_item number (38, 0),
        basket_item number (38, 0),
        baskets number (38, 0)
    ) as 
        'select
            input_web_site_sk,
            ws_web_site_sk as basket_item,
            count (distinct ws_order_number) as baskets
        from demo_db_permanent.public.sales
        where ws_order_number in (
            select ws_order_number
            from demo_db_permanent.public.sales
            where ws_web_site_sk = input_web_site_sk
        )
        group by ws_web_site_sk
        order by 3 desc, 2 asc';
    
select * from table(demo_db_permanent.public.get_mktbasket(1));

select * from table(demo_db_permanent.public.get_mktbasket(2));





 



 




// Page 89 - Create a stored procedure
USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE DEMO3E_DB;
CREATE OR REPLACE PROCEDURE STOREDPROC1(ARGUMENT1 VARCHAR)
RETURNS string not null
language javascript AS
$$
var INPUT_ARGUMENT1 = ARGUMENT1;
var result = `${INPUT_ARGUMENT1}`
return result;
$$;

// Page 89 - Call the stored procedure
CALL STOREDPROC1('I really love Snowflake ❄');

// Page 90 - Look at information for Snowflake stored procedures
SELECT * FROM DEMO3E_DB.INFORMATION_SCHEMA.PROCEDURES;

// Page 90 - Create a stored procedure for deposits
USE ROLE SYSADMIN; USE DATABASE DEMO_DB_PERMANENT; USE SCHEMA BANKING;
CREATE OR REPLACE PROCEDURE deposit(PARAM_ACCT FLOAT, PARAM_AMT FLOAT)
returns STRING LANGUAGE javascript AS
 $$
 var ret_val = ""; var cmd_debit = ""; var cmd_credit = "";
 // INSERT data into tables
 cmd_debit = "INSERT INTO DEMO_DB_PERMANENT.BANKING.CASH VALUES ("
 + PARAM_ACCT + "," + PARAM_AMT + ",current_timestamp());";
 cmd_credit = "INSERT INTO DEMO_DB_PERMANENT.BANKING.CUSTOMER_ACCT VALUES ("
 + PARAM_ACCT + "," + PARAM_AMT + ",current_timestamp());";
 // BEGIN transaction
 snowflake.execute ({sqlText: cmd_debit});
 snowflake.execute ({sqlText: cmd_credit});
 ret_val = "Deposit Transaction Succeeded";
 return ret_val;
 $$;

// Page 91 - Create a stored procedure for withdrawal
USE ROLE SYSADMIN;USE DATABASE DEMO_DB_PERMANENT; USE SCHEMA BANKING;
CREATE OR REPLACE PROCEDURE withdrawal(PARAM_ACCT FLOAT, PARAM_AMT FLOAT)
returns STRING LANGUAGE javascript AS
 $$
 var ret_val = ""; var cmd_debit = ""; var cmd_credit = "";
 // INSERT data into tables
 cmd_debit = "INSERT INTO DEMO_DB_PERMANENT.BANKING.CUSTOMER_ACCT VALUES ("
 + PARAM_ACCT + "," + (-PARAM_AMT) + ",current_timestamp());";
 cmd_credit = "INSERT INTO DEMO_DB_PERMANENT.BANKING.CASH VALUES ("
 + PARAM_ACCT + "," + (-PARAM_AMT) + ",current_timestamp());";
 // BEGIN transaction
 snowflake.execute ({sqlText: cmd_debit});
 snowflake.execute ({sqlText: cmd_credit});
 ret_val = "Withdrawal Transaction Succeeded";
 return ret_val;
 $$;

// Page 91 - Create a stored procedure for loan_payment
USE ROLE SYSADMIN;USE DATABASE DEMO_DB_PERMANENT; USE SCHEMA BANKING;
CREATE OR REPLACE PROCEDURE loan_payment(PARAM_ACCT FLOAT, PARAM_AMT FLOAT)
returns STRING LANGUAGE javascript AS
 $$
 var ret_val = ""; var cmd_debit = ""; var cmd_credit = "";
 // INSERT data into the tables
 cmd_debit = "INSERT INTO DEMO_DB_PERMANENT.BANKING.CASH VALUES ("
 + PARAM_ACCT + "," + PARAM_AMT + ",current_timestamp());";
 cmd_credit = "INSERT INTO DEMO_DB_PERMANENT.BANKING.RECEIVABLES VALUES ("
 + PARAM_ACCT + "," +(-PARAM_AMT) + ",current_timestamp());";
 //BEGIN transaction
 snowflake.execute ({sqlText: cmd_debit});
 snowflake.execute ({sqlText: cmd_credit});
 ret_val = "Loan Payment Transaction Succeeded";
 return ret_val;
 $$;

// Page 91 - Run call statements for each of the stored procedures to test them
CALL withdrawal(21, 100);
CALL loan_payment(21, 100);
CALL deposit(21, 100);

// Page 91 - See what happened when we called the procedures
SELECT CUSTOMER_ACCOUNT, AMOUNT FROM DEMO_DB_PERMANENT.BANKING.CASH;

// Page 92 - Truncate the tables
USE ROLE SYSADMIN; USE DATABASE DEMO_DB_PERMANENT; USE SCHEMA BANKING;
TRUNCATE TABLE DEMO_DB_PERMANENT.BANKING.CUSTOMER_ACCT;
TRUNCATE TABLE DEMO_DB_PERMANENT.BANKING.CASH;
TRUNCATE TABLE DEMO_DB_PERMANENT.BANKING.RECEIVABLES;

// Page 92 - Confirm no data is in the tables, after being truncated
SELECT CUSTOMER_ACCOUNT, AMOUNT FROM DEMO_DB_PERMANENT.BANKING.CASH;

// Page 92 - Call the stored procedures 
USE ROLE SYSADMIN;
CALL deposit(21, 10000);
CALL deposit(21, 400);
CALL loan_payment(14, 1000);
CALL withdrawal(21, 500);
CALL deposit(72, 4000);
CALL withdrawal(21, 250);

// Page 92 - Create a stored procedure for Transactions Summary
USE ROLE SYSADMIN; USE DATABASE DEMO_DB_TRANSIENT; USE SCHEMA BANKING;
CREATE OR REPLACE PROCEDURE Transactions_Summary()
returns STRING LANGUAGE javascript AS
 $$
 var cmd_truncate = `TRUNCATE TABLE IF EXISTS DEMO_DB_TRANSIENT.BANKING.SUMMARY;`
 var sql = snowflake.createStatement({sqlText: cmd_truncate});
 //Summarize Cash Amount
 var cmd_cash = `Insert into DEMO_DB_TRANSIENT.BANKING.SUMMARY (CASH_AMT)
 select sum(AMOUNT) from DEMO_DB_PERMANENT.BANKING.CASH;`
 var sql = snowflake.createStatement({sqlText: cmd_cash});
 //Summarize Receivables Amount
 var cmd_receivables = `Insert into DEMO_DB_TRANSIENT.BANKING.SUMMARY
 (RECEIVABLES_AMT) select sum(AMOUNT) from DEMO_DB_PERMANENT.BANKING.RECEIVABLES;`
 var sql = snowflake.createStatement({sqlText: cmd_receivables});
 //Summarize Customer Account Amount
 var cmd_customer = `Insert into DEMO_DB_TRANSIENT.BANKING.SUMMARY (CUSTOMER_AMT)
 select sum(AMOUNT) from DEMO_DB_PERMANENT.BANKING.CUSTOMER_ACCT;`
 var sql = snowflake.createStatement({sqlText: cmd_customer});
 //BEGIN transaction
 snowflake.execute ({sqlText: cmd_truncate});
 snowflake.execute ({sqlText: cmd_cash});
 snowflake.execute ({sqlText: cmd_receivables});
 snowflake.execute ({sqlText: cmd_customer});
 ret_val = "Transactions Successfully Summarized";
 return ret_val;
 $$;

// Page 93 - Call the Transactions Summary stored procedure 
CALL Transactions_Summary();

// Page 93 - Take a look at the contents of the table
SELECT * FROM DEMO_DB_TRANSIENT.BANKING.SUMMARY;

// Page 93 - Take a look at the contents of the materialized view
USE ROLE SYSADMIN; USE DATABASE DEMO_DB_TRANSIENT;USE SCHEMA BANKING;
SELECT * FROM DEMO_DB_TRANSIENT.BANKING.SUMMARY_MVW;

// Page 93 - Take a look at the contents of the nonmaterialized view
USE ROLE SYSADMIN; USE DATABASE DEMO_DB_TRANSIENT;USE SCHEMA BANKING;
SELECT * FROM DEMO_DB_TRANSIENT.BANKING.SUMMARY_VW;

// Page 93 - Create a stored procedure to drop a database
USE ROLE SYSADMIN; USE DATABASE DEMO3E_DB;
CREATE OR REPLACE PROCEDURE drop_db()
RETURNS STRING NOT NULL LANGUAGE javascript AS
 $$
 var cmd = `DROP DATABASE DEMO_DB_PERMANENT;`
 var sql = snowflake.createStatement({sqlText: cmd});
 var result = sql.execute();
 return 'Database has been successfully dropped';
 $$;

// Page 94 - Call the procedure
CALL drop_db();

// Page 94 - Replace the procedure to drop a different database
USE ROLE SYSADMIN;
CREATE OR REPLACE PROCEDURE drop_db() RETURNS STRING NOT NULL
 LANGUAGE javascript AS
 $$
 var cmd = `DROP DATABASE "DEMO_DB_TRANSIENT";`
 var sql = snowflake.createStatement({sqlText: cmd});
 var result = sql.execute();
 return 'Database has been successfully dropped';
 $$;
 
// Page 94 - Create a task which will delay the stored procedure by 15 minutes 
USE ROLE SYSADMIN; USE DATABASE DEMO3E_DB;
CREATE OR REPLACE TASK tsk_wait_15
WAREHOUSE = COMPUTE_WH SCHEDULE = '15 MINUTE'
AS CALL drop_db();

// Page 94 - ACCOUNTADMIN role is needed to grant the "Execute Task" ability to the SYSADMIN role
USE ROLE ACCOUNTADMIN;
GRANT EXECUTE TASK ON ACCOUNT TO ROLE SYSADMIN;

// Page 94 - Resume the task because all taks are created in a suspended state
USE ROLE SYSADMIN;
ALTER TASK IF EXISTS tsk_wait_15 RESUME;

// Page 94 - Check to see of the task is in a scheduled state
SELECT * FROM table(information_schema.task_history
 (task_name => 'tsk_wait_15',
 scheduled_time_range_start =>
 dateadd('hour', -1, current_timestamp())));

// Need to wait for 15 minutes to pass

// Page 95 - Suspend the task 
 USE ROLE SYSADMIN;
ALTER TASK IF EXISTS tsk_15 SUSPEND;

// Page 95 - Create a sequence
USE ROLE SYSADMIN; USE DATABASE DEMO3E_DB;
CREATE OR REPLACE SEQUENCE SEQ_01 START = 1 INCREMENT = 1;
CREATE OR REPLACE TABLE SEQUENCE_TEST(i integer);

// Page 95 - Execute the sequence three or four times; run each statement separately and view the results
SELECT SEQ_01.NEXTVAL;

SELECT SEQ_01.NEXTVAL;

SELECT SEQ_01.NEXTVAL;

SELECT SEQ_01.NEXTVAL;

// Page 95 - Create a sequence
USE ROLE SYSADMIN;USE DATABASE DEMO3E_DB;
CREATE OR REPLACE SEQUENCE SEQ_02 START = 1 INCREMENT = 2;
CREATE OR REPLACE TABLE SEQUENCE_TEST(i integer);

// Page 95 - See the results of how the sequence is incremented
SELECT SEQ_02.NEXTVAL a, SEQ_02.NEXTVAL b,SEQ_02.NEXTVAL c,SEQ_02.NEXTVAL d;

// Page 97 - Statements to set things up for the stream example
USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE DEMO3F_DB;
CREATE OR REPLACE SCHEMA BANKING;
CREATE OR REPLACE TABLE BRANCH (ID varchar, City varchar, Amount number (20,2));
INSERT INTO BRANCH (ID, City, Amount)
values
 (12001, 'Abilene', 5387.97),
 (12002, 'Barstow', 34478.10),
 (12003, 'Cadbury', 8994.63);

// Page 97 - View the records in the table
SELECT * FROM BRANCH;

// Page 97 - Create two streams and use SHOW STREAMS to see details
CREATE OR REPLACE STREAM STREAM_A ON TABLE BRANCH;
CREATE OR REPLACE STREAM STREAM_B ON TABLE BRANCH;
SHOW STREAMS;

// Page 97 - Streams are empty; Result of statements will be "Query produced no results"
SELECT * FROM STREAM_A;

SELECT * FROM STREAM_B;

// Page 97 - Insert some records into the table
INSERT INTO BRANCH (ID, City, Amount)
values
 (12004, 'Denton', 41242.93),
 (12005, 'Everett', 6175.22),
 (12006, 'Fargo', 443689.75);
 
// Page 97 - See what is now in the table and each of the streams; run the statements one at a time
SELECT * FROM BRANCH;

SELECT * FROM STREAM_A;

SELECT * FROM STREAM_B;

// Page 97 - Create another stream
CREATE OR REPLACE STREAM STREAM_C ON TABLE BRANCH;

// Page 98 - Add more records to the table
INSERT INTO BRANCH (ID, City, Amount)
values
 (12007, 'Galveston', 351247.79),
 (12008, 'Houston', 917011.27);
 
// Page 98 - Recreate Stream B 
CREATE OR REPLACE STREAM STREAM_B ON TABLE BRANCH; 

// Page 98 Delete the first record from each of the previous inserts
DELETE FROM BRANCH WHERE ID = 12001;
DELETE FROM BRANCH WHERE ID = 12004;
DELETE FROM BRANCH WHERE ID = 12007;

// Page 98 View the contents of the table and each stream; run one at a time
 SELECT * FROM BRANCH;
 
 SELECT * FROM STREAM_A;
 
 SELECT * FROM STREAM_B;
 
 SELECT * FROM STREAM_C;
 
// Page 99 Update a record in the Branch table 
UPDATE BRANCH
SET City = 'Fayetteville' WHERE ID = 12006;
SELECT * FROM BRANCH; 

// Page 99 View the contents of the table and each stream; run one at a time
SELECT * FROM BRANCH;
 
SELECT * FROM STREAM_A;
 
SELECT * FROM STREAM_B;

SELECT * FROM STREAM_C;

// Page 105 - Create a task admin role and grant necessary privileges
USE ROLE SECURITYADMIN;
CREATE ROLE TASKADMIN;

USE ROLE ACCOUNTADMIN;
GRANT EXECUTE TASK, EXECUTE MANAGED TASK ON ACCOUNT TO ROLE TASKADMIN;


// Page 105 - Assign the role to a specific user role and back to the SYSADMIN
USE ROLE SECURITYADMIN;
// Replace <USER_ROLE> with an actual role
// GRANT ROLE TASKADMIN TO ROLE <USER_ROLE>;
GRANT ROLE TASKADMIN TO ROLE SYSADMIN;

// Page 105 - Create a new database and schema for use with demonstrating tasks
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEMO3F_DB;
CREATE OR REPLACE SCHEMA TASKSDEMO;

// Page 105 - Create a new table for use in demonstrating tasks
CREATE OR REPLACE TABLE DEMO3F_DB.TASKSDEMO.PRODUCT
 (Prod_ID int,
 Prod_Desc varchar(),
 Category varchar(30),
 Segment varchar(20),
 Mfg_ID int,
 Mfg_Name varchar(50));
 
 // Page 105 - Insert some values in the table
 INSERT INTO DEMO3F_DB.TASKSDEMO.PRODUCT values
(1201, 'Product 1201', 'Category 1201', 'Segment 1201', '1201', 'Mfg 1201');
INSERT INTO DEMO3F_DB.TASKSDEMO.PRODUCT values
(1202, 'Product 1202', 'Category 1202', 'Segment 1202', '1202', 'Mfg 1202');
INSERT INTO DEMO3F_DB.TASKSDEMO.PRODUCT values
(1203, 'Product 1203', 'Category 1203', 'Segment 1203', '1203', 'Mfg 1203');
INSERT INTO DEMO3F_DB.TASKSDEMO.PRODUCT values
(1204, 'Product 1204', 'Category 1204', 'Segment 1204', '1204', 'Mfg 1204');
INSERT INTO DEMO3F_DB.TASKSDEMO.PRODUCT values
(1205, 'Product 1205', 'Category 1205', 'Segment 1205', '1205', 'Mfg 1205');
INSERT INTO DEMO3F_DB.TASKSDEMO.PRODUCT values
(1206, 'Product 1206', 'Category 1206', 'Segment 1206', '1206', 'Mfg 1206');

// Page 105 - Create a new Sales table
CREATE OR REPLACE TABLE DEMO3F_DB.TASKSDEMO.SALES
 (Prod_ID int,
 Customer varchar(),
 Zip varchar(),
 Qty int,
 Revenue decimal(10,2));
 
// Page 106 - Create a new stream 
CREATE OR REPLACE STREAM DEMO3F_DB.TASKSDEMO.SALES_STREAM
ON TABLE DEMO3F_DB.TASKSDEMO.SALES
APPEND_ONLY = TRUE;

// Page 106 - Insert values into the table to test that the stream works as expected
INSERT INTO DEMO3F_DB.TASKSDEMO.SALES VALUES
(1201, 'Amy Johnson', 45466, 45, 2345.67);
INSERT INTO DEMO3F_DB.TASKSDEMO.SALES VALUES
(1201, 'Harold Robinson', 89701, 45, 2345.67);
INSERT INTO DEMO3F_DB.TASKSDEMO.SALES VALUES
(1203, 'Chad Norton', 33236, 45, 2345.67);
INSERT INTO DEMO3F_DB.TASKSDEMO.SALES VALUES
(1206, 'Horatio Simon', 75148, 45, 2345.67);
INSERT INTO DEMO3F_DB.TASKSDEMO.SALES VALUES
(1205, 'Misty Crawford', 10001, 45, 2345.67);


// Page 106 - Confirm that the values are included in the stream
SELECT * FROM DEMO3F_DB.TASKSDEMO.SALES_STREAM;

// Page 106 - Create a sales transaction table
CREATE OR REPLACE TABLE DEMO3F_DB.TASKSDEMO.SALES_TRANSACT
 (Prod_ID int,
 Prod_Desc varchar(),
 Category varchar(30),
 Segment varchar(20),
 Mfg_ID int,
 Mfg_Name varchar(50),
 Customer varchar(),
 Zip varchar(),
 Qty int,
 Revenue decimal (10, 2),
 TS timestamp);

// Page 106 - Manually enter some data
INSERT INTO
 DEMO3F_DB.TASKSDEMO.SALES_TRANSACT
 (Prod_ID,Prod_Desc,Category,Segment,Mfg_Id,
 Mfg_Name,Customer,Zip,Qty,Revenue,TS)
SELECT
 s.Prod_ID,p.Prod_Desc,p.Category,p.Segment,p.Mfg_ID,
 p.Mfg_Name,s.Customer,s.Zip,s.Qty,s.Revenue,current_timestamp
FROM
 DEMO3F_DB.TASKSDEMO.SALES_STREAM s
 JOIN DEMO3F_DB.TASKSDEMO.PRODUCT p ON s.Prod_ID = p.Prod_ID;
 
 // Page 107 - Confirm that the records were inserted into the table
 SELECT * FROM DEMO3F_DB.TASKSDEMO.SALES_TRANSACT;

// Page 107 - Automate the task
CREATE OR REPLACE TASK DEMO3F_DB.TASKSDEMO.SALES_TASK
WAREHOUSE = compute_wh
SCHEDULE = '1 minute'
WHEN system$stream_has_data('DEMO3F_DB.TASKSDEMO.SALES_STREAM')
AS
INSERT INTO
 DEMO3F_DB.TASKSDEMO.SALES_TRANSACT
 (Prod_ID,Prod_Desc,Category,Segment,Mfg_Id,
 Mfg_Name,Customer,Zip,Qty,Revenue,TS)
SELECT
 s.Prod_ID,p.Prod_Desc,p.Category,p.Segment,p.Mfg_ID,
 p.Mfg_Name,s.Customer,s.Zip,s.Qty,s.Revenue,current_timestamp
FROM
 DEMO3F_DB.TASKSDEMO.SALES_STREAM s
 JOIN DEMO3F_DB.TASKSDEMO.PRODUCT p ON s.Prod_ID = p.Prod_ID;
ALTER TASK DEMO3F_DB.TASKSDEMO.SALES_TASK RESUME;

// Page 107 - Insert values into the sales table
INSERT INTO DEMO3F_DB.TASKSDEMO.SALES VALUES
(1201, 'Edward Jameson', 45466, 45, 2345.67);
INSERT INTO DEMO3F_DB.TASKSDEMO.SALES VALUES
(1201, 'Margaret Volt', 89701, 45, 2345.67);
INSERT INTO DEMO3F_DB.TASKSDEMO.SALES VALUES
(1203, 'Antoine Lancaster', 33236, 45, 2345.67);
INSERT INTO DEMO3F_DB.TASKSDEMO.SALES VALUES
(1204, 'Esther Baker', 75148, 45, 2345.67);
INSERT INTO DEMO3F_DB.TASKSDEMO.SALES VALUES
(1206, 'Quintin Anderson', 10001, 45, 2345.67);

// Page 108 - Confirm that the values were capted by the Sales stream
SELECT * FROM DEMO3F_DB.TASKSDEMO.SALES_STREAM;

// Wait for a minute

// Page 108 - Confirm that the task worked
SELECT * FROM DEMO3F_DB.TASKSDEMO.SALES_TRANSACT;

// Page 108 - Suspend the task
ALTER TASK DEMO3F_DB.TASKSDEMO.SALES_TASK SUSPEND;

// Page 108 - Code Cleanup
DROP DATABASE demo_db_permanent; DROP DATABASE DEMO3D_DB;
DROP DATABASE DEMO3E_DB; DROP DATABASE DEMO3F_DB;

