USE WAREHOUSE COMPUTE_WH;


-- CREATE TABLE
CREATE OR REPLACE TABLE EXERCISE_DB.PUBLIC.EMPLOYEES (
    CUSTOMER_ID INT,
    FIRST_NAME  VARCHAR(50),
    LAST_NAME   VARCHAR(50),
    EMAIL       VARCHAR(50),
    AGE         INT,
    DEPARTMENT  VARCHAR(50)
);

SELECT * FROM EXERCISE_DB.PUBLIC.EMPLOYEES;


-- CREATE STAGE
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_EMPLOYEES
    URL = 's3://snowflake-assignments-mc/copyoptions/example2/';

LIST @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_EMPLOYEES;


-- CREATE AND ALTER FILE FORMAT OBJECT
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.CSV_FORMAT;

ALTER FILE FORMAT MANAGE_DB.FILE_FORMATS.CSV_FORMAT
    SET SKIP_HEADER = 1;
    
DESC FILE FORMAT MANAGE_DB.FILE_FORMATS.CSV_FORMAT;


-- USE COPY OPTION TO VALIDATE FOR ERRORS (RETURN ERRORS)
COPY INTO EXERCISE_DB.PUBLIC.EMPLOYEES
    FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_EMPLOYEES
    FILE_FORMAT = MANAGE_DB.FILE_FORMATS.CSV_FORMAT
    FILES = ('employees_error.csv')
    VALIDATION_MODE = RETURN_ERRORS;


-- ADD COPY OPTION TO TRUNCATE COLUMN AND AVOID ERROR
COPY INTO EXERCISE_DB.PUBLIC.EMPLOYEES
    FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_EMPLOYEES
    FILE_FORMAT = MANAGE_DB.FILE_FORMATS.CSV_FORMAT
    FILES = ('employees_error.csv')
    TRUNCATECOLUMNS = TRUE;


-- INSPECT DATA
SELECT * FROM EXERCISE_DB.PUBLIC.EMPLOYEES;