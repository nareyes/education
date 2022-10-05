-- CREATE TABLE
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.LOAN_PAYMENT (
    LOAN_ID STRING,
    LOAN_STATUS STRING,
    PRINCIPAL STRING,
    TERMS STRING,
    EFFECTIVE_DATE STRING,
    DUE_DATE STRING,
    PAID_OFF_TIME STRING,
    PAST_DUE_DAYS STRING,
    AGE STRING,
    EDUCATION STRING,
    GENDER STRING
);

SELECT * FROM DEMO_DB.PUBLIC.LOAN_PAYMENT;


-- LOAD DATA FROM S3 BUCKET
COPY INTO DEMO_DB.PUBLIC.LOAN_PAYMENT
    FROM s3://bucketsnowflakes3/Loan_payments_data.csv 
    FILE_FORMAT = (
        TYPE = CSV 
        FIELD_DELIMITER = ',' 
        SKIP_HEADER = 1 -- TRUE
    );
    
    
-- INSPECT DATA
SELECT * FROM DEMO_DB.PUBLIC.LOAN_PAYMENT;