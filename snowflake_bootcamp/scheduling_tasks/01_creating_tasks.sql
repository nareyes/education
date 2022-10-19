USE WAREHOUSE COMPUTE_WH;


-- CREATE TRANSIENT DATABASE
CREATE OR REPLACE DATABASE TASK_DB;


-- CREATE TABLE
CREATE OR REPLACE TABLE CUSTOMERS (
    CUSTOMER_ID     INT AUTOINCREMENT START = 1 INCREMENT = 1,
    FIRST_NAME      VARCHAR(40) DEFAULT 'JENNIFER',
    CREATED_DATE    DATE
);

SELECT * FROM TASK_DB.PUBLIC.CUSTOMERS;


-- CREATE TASK
CREATE OR REPLACE TASK CUSTOMER_INSERT
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = '1 MINUTE' -- TWO SCHEDULING OPTIONS. CRON IN NEXT WORKSHEET.
    AS 
        INSERT INTO CUSTOMERS (CREATED_DATE) 
        VALUES (CURRENT_TIMESTAMP); -- DEFAULT STATE IS SUSPENDED

SHOW TASKS;


-- RESUME AND SUSPEND TASK
ALTER TASK CUSTOMER_INSERT RESUME;
ALTER TASK CUSTOMER_INSERT SUSPEND;


-- INSPECT DATA
SELECT * FROM TASK_DB.PUBLIC.CUSTOMERS;