// Snowflake Definitive Guide 1st Edition by Joyce Kay Avila - August 2022
// ISBN-10 : 1098103823
// ISBN-13 : 978-1098103828
// Contact the author: https://www.linkedin.com/in/joycekayavila/
// Chapter 3: Creating and Managing Snowflake Secuirable Database Objects


// Page 54 - Prep Work
// Create new worksheet: Chapter3 Creating Database Objects
// Context setting - make sure role is set to SYSADMIN and COMPUTE_WH is the virtual warehouse

// Page 56 - Create a Permanent Database via the Web UI
// Navigate to Data -> Databases
// Confirm your role is set to SYSADMIN
// Use the +Database button to create a new Snowflake database
// Enter "DEMO3A_DB" ad the database name
// Include a comment "Permanent Database for Chapter 3 Exercises"
// Click the Create button

// Page 58 - Create a Transient Database via the Worksheet
// Navigate back to the worksheet
// Confirm your role is set to SYSADMIN
USE ROLE SYSADMIN; 
USE WAREHOUSE COMPUTE_WH;
CREATE OR REPLACE TRANSIENT DATABASE DEMO3B_DB
Comment = 'Transient Database for Chapter 3 Exercises';

// Page 59 - Via the Web UI, see the databases accessible to your role 
// Navigate to Databases UI and look to the right
// Note that your role should be set to SYSADMIN

// Page 59 - Via the worksheet, see the databases accessible to your role
// Navigate back to the worksheet
// Change role to ACCOUNTADMIN via the drop-down menu on the right
// Be sure to notice the retention time for each database
USE ROLE ACCOUNTADMIN;
SHOW DATABASES;

// Page 60 - Change the data retention time for a permanent database
// Make sure your role is set to SYSADMIN
USE ROLE SYSADMIN;
ALTER DATABASE DEMO3A_DB
SET DATA_RETENTION_TIME_IN_DAYS=10;

//Page 61 - Attempt to change the retention time for a transiet database
//will receive an error
USE ROLE SYSADMIN;
ALTER DATABASE DEMO3B_DB
SET DATA_RETENTION_TIME_IN_DAYS=10;

//Page 61 - Create a table in a transient database
USE ROLE SYSADMIN;
CREATE OR REPLACE TABLE DEMO3B_DB.PUBLIC.SUMMARY
 (CASH_AMT number,
 RECEIVABLES_AMT number,
 CUSTOMER_AMT number);

// Page 62 - Using the SHOW TABLES command to see the details of tables
SHOW TABLES;

// Page 63 - Example 1 of how to create a new schema by setting context
USE ROLE SYSADMIN; USE DATABASE DEMO3A_DB;
CREATE OR REPLACE SCHEMA BANKING;

// Page 64 - Example 2 of how to create a new schema using fully qualifed name
USE ROLE SYSADMIN;
CREATE OR REPLACE SCHEMA DEMO3A_DB.BANKING;

// Page 65 - Using the SHOW SCHEMAS command to see the details of schemas
SHOW SCHEMAS;

// Page 66 - Change the retention time for a schema
USE ROLE SYSADMIN;
ALTER SCHEMA DEMO3A_DB.BANKING
SET DATA_RETENTION_TIME_IN_DAYS=1;

// Page 67 - Moving a table to a different (newly created) schema
USE ROLE SYSADMIN;
CREATE OR REPLACE SCHEMA DEMO3B_DB.BANKING;
ALTER TABLE DEMO3B_DB.PUBLIC.SUMMARY
RENAME TO DEMO3B_DB.BANKING.SUMMARY;

// Page 64 - Create a schema with managed access
USE ROLE SYSADMIN; USE DATABASE DEMO3A_DB;
CREATE OR REPLACE SCHEMA MSCHEMA WITH MANAGED ACCESS;

// Page 65 - Using the SHOW SCHEMAS command to see details of schemas
SHOW SCHEMAS;

// Page 67 - Information Schema for a database (Example #1)
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.INFORMATION_SCHEMA.DATABASES;

// Page 67 - Information Schema for a database (Example #2)
SELECT * FROM DEMO3A_DB.INFORMATION_SCHEMA.DATABASES;

// Page 67 - Information schema for applicable roles (Example #1)
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.INFORMATION_SCHEMA.APPLICABLE_ROLES;

// Page 67 - Information schema for applicable roles (Example #2)
SELECT * FROM DEMO3A_DB.INFORMATION_SCHEMA.APPLICABLE_ROLES;

// Page 69 - Information about schemas in the Snowflake sample database (Example #1)
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.INFORMATION_SCHEMA.SCHEMATA;

// Page 69 - Information about schemas in the Snowflake sample database (Example #2)
SHOW SCHEMAS IN DATABASE SNOWFLAKE_SAMPLE_DATA;

// Page 69 - Information schema for table privileges (Example #1)
SELECT * FROM DEMO3A_DB.INFORMATION_SCHEMA.TABLE_PRIVILEGES;

// Page 69 - Information schema for table privileges (Example #2)
SELECT * FROM DEMO3B_DB.INFORMATION_SCHEMA.TABLE_PRIVILEGES;

// Page 70 - Show credits used over time by each virtual warehouse
// Make sure your role is set to ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;USE DATABASE SNOWFLAKE;USE SCHEMA ACCOUNT_USAGE;
USE WAREHOUSE COMPUTE_WH;
SELECT start_time::date AS USAGE_DATE, WAREHOUSE_NAME,
 SUM(credits_used) AS TOTAL_CREDITS_CONSUMED
FROM warehouse_metering_history
WHERE start_time >= date_trunc(Month, current_date)
GROUP BY 1,2
ORDER BY 2,1;

// Page 74 - Create some tables
// Make sure you are using the SYSADMIN role
USE ROLE SYSADMIN; USE DATABASE DEMO3A_DB;
CREATE OR REPLACE SCHEMA BANKING;
CREATE OR REPLACE TABLE CUSTOMER_ACCT
 (Customer_Account int, Amount int, transaction_ts timestamp);
CREATE OR REPLACE TABLE CASH
 (Customer_Account int, Amount int, transaction_ts timestamp);
CREATE OR REPLACE TABLE RECEIVABLES
 (Customer_Account int, Amount int, transaction_ts timestamp);
 

// Page 74 - Creating a table without specifying the database or schema
USE ROLE SYSADMIN;
CREATE OR REPLACE TABLE NEWTABLE
 (Customer_Account int,
 Amount int,
 transaction_ts timestamp); 
 
// Page 75 - Drop the table, best practice is using fully qualified name
// Make sure you are using the SYSADMIN role
DROP TABLE DEMO3A_DB.BANKING.NEWTABLE;
 
// Page 77 - Create a new view 
USE ROLE SYSADMIN;
CREATE OR REPLACE VIEW DEMO3B_DB.PUBLIC.NEWVIEW AS
SELECT CC_NAME
FROM (SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CALL_CENTER);

// Page 77 - Create a new materializesd view 
USE ROLE SYSADMIN;
CREATE OR REPLACE MATERIALIZED VIEW DEMO3B_DB.PUBLIC.NEWVIEW_MVW AS
SELECT CC_NAME
FROM (SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CALL_CENTER);

// Page 77 - Use the SHOW VIEWS command to see information on the views
USE SCHEMA DEMO3B_DB.PUBLIC;
SHOW VIEWS;

// Page 78 - Create a materialized view 
CREATE OR REPLACE MATERIALIZED VIEW DEMO3B_DB.BANKING.SUMMARY_MVW AS
SELECT * FROM (SELECT * FROM DEMO3B_DB.BANKING.SUMMARY);

// Page 78 - Create a nonmaterialized view 
CREATE OR REPLACE VIEW DEMO3B_DB.BANKING.SUMMARY_VW AS
SELECT * FROM (SELECT * FROM DEMO3B_DB.BANKING.SUMMARY);

// Page 81 - Create a basic file format for loading JSON data into a stage
USE ROLE SYSADMIN; USE DATABASE DEMO3B_DB;
CREATE OR REPLACE FILE FORMAT FF_JSON TYPE = JSON;

// Page 81 - Creating an internal stage using the recently created file format
USE DATABASE DEMO3B_DB; USE SCHEMA BANKING;
CREATE OR REPLACE TEMPORARY STAGE BANKING_STG FILE_FORMAT = FF_JSON;

// Page 84 - Create a UDF to show the JavaScript properties available for UDFs and procedures
USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE DEMO3C_DB;
CREATE OR REPLACE FUNCTION JS_PROPERTIES()
RETURNS string LANGUAGE JAVASCRIPT AS
 $$ return Object.getOwnPropertyNames(this); $$;
 
// Page 84 - Display the results of the recently created UDF
SELECT JS_PROPERTIES();

// Page 84 - Creating a JavaScript UDF which returns a scalar result
USE ROLE SYSADMIN; USE DATABASE DEMO3C_DB;
CREATE OR REPLACE FUNCTION FACTORIAL(n variant)
RETURNS variant LANGUAGE JAVASCRIPT AS
 'var f=n;
 for (i=n-1; i>0; i--) {
 f=f*i}
 return f';
 
// Page 85 - Display the results of the recently created JavaScript UDF
SELECT FACTORIAL(5);
 
// Page 87 - Create a table with 100,000 rows from the demo database  
USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE DEMO3D_DB;
CREATE OR REPLACE TABLE DEMO3D_DB.PUBLIC.SALES AS
 (SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_SALES)
LIMIT 100000;

// Page 87 - Find products sold along with the product which has an SK of 1
SELECT 1 AS INPUT_ITEM, WS_WEB_SITE_SK AS BASKET_ITEM,
 COUNT (DISTINCT WS_ORDER_NUMBER) BASKETS
FROM DEMO3D_DB.PUBLIC.SALES
WHERE WS_ORDER_NUMBER IN
 (SELECT WS_ORDER_NUMBER
 FROM DEMO3D_DB.PUBLIC.SALES
 WHERE WS_WEB_SITE_SK = 1)
GROUP BY WS_WEB_SITE_SK
ORDER BY 3 DESC, 2;

// Page 88 - Create a Secure SQL UDF function
USE ROLE SYSADMIN;
CREATE OR REPLACE SECURE FUNCTION
 DEMO3D_DB.PUBLIC.GET_MKTBASKET(INPUT_WEB_SITE_SK number(38))
RETURNS TABLE (INPUT_ITEM NUMBER(38, 0), BASKET_ITEM NUMBER(38, 0),
 BASKETS NUMBER(38, 0)) AS
'SELECT input_web_site_sk, WS_WEB_SITE_SK as BASKET_ITEM,
 COUNT(DISTINCT WS_ORDER_NUMBER) BASKETS
 FROM DEMO3D_DB.PUBLIC.SALES
 WHERE WS_ORDER_NUMBER IN
 (SELECT WS_ORDER_NUMBER
FROM DEMO3D_DB.PUBLIC.SALES
WHERE WS_WEB_SITE_SK = input_web_site_sk)
 GROUP BY ws_web_site_sk
 ORDER BY 3 DESC, 2';

// Page 89 - Find products sold along with the product which has an SK of 1, without having access to underlying data
SELECT * FROM TABLE(DEMO3D_DB.PUBLIC.GET_MKTBASKET(1));

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
USE ROLE SYSADMIN; USE DATABASE DEMO3A_DB; USE SCHEMA BANKING;
CREATE OR REPLACE PROCEDURE deposit(PARAM_ACCT FLOAT, PARAM_AMT FLOAT)
returns STRING LANGUAGE javascript AS
 $$
 var ret_val = ""; var cmd_debit = ""; var cmd_credit = "";
 // INSERT data into tables
 cmd_debit = "INSERT INTO DEMO3A_DB.BANKING.CASH VALUES ("
 + PARAM_ACCT + "," + PARAM_AMT + ",current_timestamp());";
 cmd_credit = "INSERT INTO DEMO3A_DB.BANKING.CUSTOMER_ACCT VALUES ("
 + PARAM_ACCT + "," + PARAM_AMT + ",current_timestamp());";
 // BEGIN transaction
 snowflake.execute ({sqlText: cmd_debit});
 snowflake.execute ({sqlText: cmd_credit});
 ret_val = "Deposit Transaction Succeeded";
 return ret_val;
 $$;

// Page 91 - Create a stored procedure for withdrawal
USE ROLE SYSADMIN;USE DATABASE DEMO3A_DB; USE SCHEMA BANKING;
CREATE OR REPLACE PROCEDURE withdrawal(PARAM_ACCT FLOAT, PARAM_AMT FLOAT)
returns STRING LANGUAGE javascript AS
 $$
 var ret_val = ""; var cmd_debit = ""; var cmd_credit = "";
 // INSERT data into tables
 cmd_debit = "INSERT INTO DEMO3A_DB.BANKING.CUSTOMER_ACCT VALUES ("
 + PARAM_ACCT + "," + (-PARAM_AMT) + ",current_timestamp());";
 cmd_credit = "INSERT INTO DEMO3A_DB.BANKING.CASH VALUES ("
 + PARAM_ACCT + "," + (-PARAM_AMT) + ",current_timestamp());";
 // BEGIN transaction
 snowflake.execute ({sqlText: cmd_debit});
 snowflake.execute ({sqlText: cmd_credit});
 ret_val = "Withdrawal Transaction Succeeded";
 return ret_val;
 $$;

// Page 91 - Create a stored procedure for loan_payment
USE ROLE SYSADMIN;USE DATABASE DEMO3A_DB; USE SCHEMA BANKING;
CREATE OR REPLACE PROCEDURE loan_payment(PARAM_ACCT FLOAT, PARAM_AMT FLOAT)
returns STRING LANGUAGE javascript AS
 $$
 var ret_val = ""; var cmd_debit = ""; var cmd_credit = "";
 // INSERT data into the tables
 cmd_debit = "INSERT INTO DEMO3A_DB.BANKING.CASH VALUES ("
 + PARAM_ACCT + "," + PARAM_AMT + ",current_timestamp());";
 cmd_credit = "INSERT INTO DEMO3A_DB.BANKING.RECEIVABLES VALUES ("
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
SELECT CUSTOMER_ACCOUNT, AMOUNT FROM DEMO3A_DB.BANKING.CASH;

// Page 92 - Truncate the tables
USE ROLE SYSADMIN; USE DATABASE DEMO3A_DB; USE SCHEMA BANKING;
TRUNCATE TABLE DEMO3A_DB.BANKING.CUSTOMER_ACCT;
TRUNCATE TABLE DEMO3A_DB.BANKING.CASH;
TRUNCATE TABLE DEMO3A_DB.BANKING.RECEIVABLES;

// Page 92 - Confirm no data is in the tables, after being truncated
SELECT CUSTOMER_ACCOUNT, AMOUNT FROM DEMO3A_DB.BANKING.CASH;

// Page 92 - Call the stored procedures 
USE ROLE SYSADMIN;
CALL deposit(21, 10000);
CALL deposit(21, 400);
CALL loan_payment(14, 1000);
CALL withdrawal(21, 500);
CALL deposit(72, 4000);
CALL withdrawal(21, 250);

// Page 92 - Create a stored procedure for Transactions Summary
USE ROLE SYSADMIN; USE DATABASE DEMO3B_DB; USE SCHEMA BANKING;
CREATE OR REPLACE PROCEDURE Transactions_Summary()
returns STRING LANGUAGE javascript AS
 $$
 var cmd_truncate = `TRUNCATE TABLE IF EXISTS DEMO3B_DB.BANKING.SUMMARY;`
 var sql = snowflake.createStatement({sqlText: cmd_truncate});
 //Summarize Cash Amount
 var cmd_cash = `Insert into DEMO3B_DB.BANKING.SUMMARY (CASH_AMT)
 select sum(AMOUNT) from DEMO3A_DB.BANKING.CASH;`
 var sql = snowflake.createStatement({sqlText: cmd_cash});
 //Summarize Receivables Amount
 var cmd_receivables = `Insert into DEMO3B_DB.BANKING.SUMMARY
 (RECEIVABLES_AMT) select sum(AMOUNT) from DEMO3A_DB.BANKING.RECEIVABLES;`
 var sql = snowflake.createStatement({sqlText: cmd_receivables});
 //Summarize Customer Account Amount
 var cmd_customer = `Insert into DEMO3B_DB.BANKING.SUMMARY (CUSTOMER_AMT)
 select sum(AMOUNT) from DEMO3A_DB.BANKING.CUSTOMER_ACCT;`
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
SELECT * FROM DEMO3B_DB.BANKING.SUMMARY;

// Page 93 - Take a look at the contents of the materialized view
USE ROLE SYSADMIN; USE DATABASE DEMO3B_DB;USE SCHEMA BANKING;
SELECT * FROM DEMO3B_DB.BANKING.SUMMARY_MVW;

// Page 93 - Take a look at the contents of the nonmaterialized view
USE ROLE SYSADMIN; USE DATABASE DEMO3B_DB;USE SCHEMA BANKING;
SELECT * FROM DEMO3B_DB.BANKING.SUMMARY_VW;

// Page 93 - Create a stored procedure to drop a database
USE ROLE SYSADMIN; USE DATABASE DEMO3E_DB;
CREATE OR REPLACE PROCEDURE drop_db()
RETURNS STRING NOT NULL LANGUAGE javascript AS
 $$
 var cmd = `DROP DATABASE DEMO3A_DB;`
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
 var cmd = `DROP DATABASE "DEMO3B_DB";`
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
DROP DATABASE DEMO3C_DB; DROP DATABASE DEMO3D_DB;
DROP DATABASE DEMO3E_DB; DROP DATABASE DEMO3F_DB;

