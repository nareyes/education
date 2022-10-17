USE WAREHOUSE COMPUTE_WH;


-- CLONE SCHEMA
CREATE OR REPLACE SCHEMA DEMO_DB.PUBLIC_COPY
    CLONE DEMO_DB.PUBLIC; -- INCLUDE TIME TRAVEL SYNTAX IF NEEDED


-- VALIDATE SCHEMAS
SELECT * FROM DEMO_DB.PUBLIC.CUSTOMERS;
SELECT * FROM DEMO_DB.PUBLIC_COPY.CUSTOMERS;


-- CLONE DATABASE
CREATE OR REPLACE DATABASE DEMO_DB_DEV
    CLONE DEMO_DB; -- INCLUDE TIME TRAVEL SYNTAX IF NEEDED


-- VALIDATE DATABASE
SELECT * FROM DEMO_DB.PUBLIC.CUSTOMERS;
SELECT * FROM DEMO_DB_DEV.PUBLIC.CUSTOMERS;


-- CLEAN UP
DROP SCHEMA IF EXISTS DEMO_DB.PUBLIC_COPY;
DROP DATABASE IF EXISTS DEMO_DB_DEV;