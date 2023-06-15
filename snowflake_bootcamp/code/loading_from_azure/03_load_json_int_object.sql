USE WAREHOUSE COMPUTE_WH;


-- CREATE FILE FORMAT OBJECT
CREATE OR REPLACE FILE FORMAT MANAGE_DB.PUBLIC.JSON_FORMAT
    TYPE = JSON;

DESC FILE FORMAT MANAGE_DB.PUBLIC.JSON_FORMAT;


-- CREATE STAGE
CREATE OR REPLACE STAGE MANAGE_DB.PUBLIC.AZURE_STAGE
    URL = 'azure://snowflakestoracct.blob.core.windows.net/json/'
    STORAGE_INTEGRATION = AZURE_INT
    FILE_FORMAT = MANAGE_DB.PUBLIC.JSON_FORMAT;

LIST @MANAGE_DB.PUBLIC.INSTRUMENT_STAGE;


-- QUERY STAGE TO DETERMINE JSON FORMAT
SELECT * FROM @MANAGE_DB.PUBLIC.AZURE_STAGE;


-- QUERY STAGE WITH FORMATTED COLUMNS
SELECT 
    $1:"Car Model"::STRING      AS CAR_MODEL, 
    $1:"Car Model Year"::INT    AS CAR_MODEL_YEAR,
    $1:"car make"::STRING       AS CAR_MAKE, 
    $1:"first_name"::STRING     AS FIRST_NAME,
    $1:"last_name"::STRING      AS LAST_NAME
FROM @MANAGE_DB.PUBLIC.AZURE_STAGE; 


-- CREATE DESTINATION TABLE
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.CAR_OWNER (
    CAR_MODEL       VARCHAR,
    CAR_MODEL_YEAR  INT,
    CAR_MAKE        VARCHAR,
    FIRST_NAME      VARCHAR,
    LAST_NAME       VARCHAR
);

SELECT * FROM DEMO_DB.PUBLIC.CAR_OWNER;


-- LOAD DATA
COPY INTO DEMO_DB.PUBLIC.CAR_OWNER
FROM (
    SELECT 
        $1:"Car Model"::STRING      AS CAR_MODEL, 
        $1:"Car Model Year"::INT    AS CAR_MODEL_YEAR,
        $1:"car make"::STRING       AS CAR_MAKE, 
        $1:"first_name"::STRING     AS FIRST_NAME,
        $1:"last_name"::STRING      AS LAST_NAME
    FROM @MANAGE_DB.PUBLIC.AZURE_STAGE
);


-- INSPECT DATA
SELECT * FROM DEMO_DB.PUBLIC.CAR_OWNER;