USE WAREHOUSE COMPUTE_WH;


-- CREATE STAGE
CREATE OR REPLACE STAGE MANAGE_DB.PUBLIC.JSON_STAGE
    URL = 's3://bucketsnowflake-jsondemo/';

LIST @MANAGE_DB.PUBLIC.JSON_STAGE;


-- CREATE JSON FILE FORMAT
CREATE OR REPLACE FILE FORMAT MANAGE_DB.PUBLIC.JSON_FORMAT
    TYPE = JSON;

DESC FILE FORMAT MANAGE_DB.PUBLIC.JSON_FORMAT;


-- CREATE TABLE
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.JSON_RAW_HR (
    RAW_FILE    VARIANT
);

SELECT * FROM DEMO_DB.PUBLIC.JSON_RAW_HR;


-- COPY JSON DATA
COPY INTO DEMO_DB.PUBLIC.JSON_RAW_HR
    FROM @MANAGE_DB.PUBLIC.JSON_STAGE
    FILE_FORMAT = MANAGE_DB.PUBLIC.JSON_FORMAT
    FILES = ('HR_data.json');


-- INSPECT DATA
SELECT * FROM DEMO_DB.PUBLIC.JSON_RAW_HR;