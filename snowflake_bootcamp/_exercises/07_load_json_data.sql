USE WAREHOUSE COMPUTE_WH;


-- CREATE STAGE
CREATE OR REPLACE STAGE MANAGE_DB.PUBLIC.JSON_STAGE
    URL = 's3://snowflake-assignments-mc/unstructureddata/';

LIST @MANAGE_DB.PUBLIC.JSON_STAGE;


-- CREATE FILE FORMAT OBJECT
CREATE OR REPLACE FILE FORMAT MANAGE_DB.PUBLIC.JSON_FORMAT
    TYPE = JSON;

DESC FILE FORMAT MANAGE_DB.PUBLIC.JSON_FORMAT;


-- CREATE TABLE
CREATE OR REPLACE TABLE EXERCISE_DB.PUBLIC.JSON_RAW_JOBSKILLS (
    RAW_FILE    VARIANT
);

SELECT * FROM EXERCISE_DB.PUBLIC.JSON_RAW_JOBSKILLS;


-- COPY JSON DATA
COPY INTO EXERCISE_DB.PUBLIC.JSON_RAW_JOBSKILLS
    FROM @MANAGE_DB.PUBLIC.JSON_STAGE
    FILE_FORMAT = MANAGE_DB.PUBLIC.JSON_FORMAT
    FILES = ('Jobskills.json');


-- INSPECT DATA
SELECT * FROM EXERCISE_DB.PUBLIC.JSON_RAW_JOBSKILLS;


-- CLEAN UP
DROP TABLE IF EXISTS EXERCISE_DB.PUBLIC.JSON_RAW_JOBSKILLS;