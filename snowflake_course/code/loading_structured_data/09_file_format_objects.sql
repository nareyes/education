USE WAREHOUSE COMPUTE_WH;


-- CREATE AND ALTER FILE FORMAT OBJECT
CREATE OR REPLACE FILE FORMAT MANAGE_DB.PUBLIC.CSV_FORMAT
    SKIP_HEADER = 1;


-- SHOW FILE FORMAT PROPERTIES
DESC FILE FORMAT MANAGE_DB.PUBLIC.CSV_FORMAT;


-- CREATE TABLE FOR EXAMPLE
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.ORDER_DETAILS_EX (
    ORDER_ID    VARCHAR(30),
    AMOUNT      INT,
    PROFIT      INT,
    QUANTITY    INT,
    CATEGORY    VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
);


-- INSPECT NEW TABLE
SELECT * FROM DEMO_DB.PUBLIC.ORDER_DETAILS_EX;


-- LOAD DATA FROM S3 BUCKET
COPY INTO DEMO_DB.PUBLIC.ORDER_DETAILS_EX
    FROM @AWS_STAGE
    FILE_FORMAT = MANAGE_DB.PUBLIC.CSV_FORMAT
    FILES = ('OrderDetails.csv')
    ON_ERROR = 'ABORT_STATEMENT';


-- VALIDATE NEW TABLE
SELECT * FROM DEMO_DB.PUBLIC.ORDER_DETAILS_EX;


-- CLEAN UP
DROP TABLE IF EXISTS DEMO_DB.PUBLIC.ORDER_DETAILS_EX;