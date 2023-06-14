USE WAREHOUSE COMPUTE_WH;


-- CREATE FILE FORMAT OBJECT
CREATE OR REPLACE FILE FORMAT MANAGE_DB.PUBLIC.JSON_FORMAT
    TYPE = JSON;

DESC FILE FORMAT MANAGE_DB.PUBLIC.JSON_FORMAT;


-- CREATE STAGE
CREATE OR REPLACE STAGE MANAGE_DB.PUBLIC.INSTRUMENT_STAGE
    URL = 's3://s3snowflakestorage/json/'
    STORAGE_INTEGRATION = S3_INT
    FILE_FORMAT = MANAGE_DB.PUBLIC.JSON_FORMAT;

LIST @MANAGE_DB.PUBLIC.INSTRUMENT_STAGE;


-- QUERY STAGE TO DETERMINE JSON FORMAT
SELECT * FROM @MANAGE_DB.PUBLIC.INSTRUMENT_STAGE;


-- QUERY STAGE WITH FORMATTED COLUMNS
SELECT 
    $1:asin::STRING                 AS ASIN,
    $1:helpful                      AS HELPFUL,
    $1:overall                      AS OVERALL,
    $1:reviewText::STRING           AS REVIEW_TEXT,
    $1:reviewTime::STRING           AS REVIEW_TIME,
    DATE_FROM_PARTS (
        RIGHT ($1:reviewTime::STRING,4),
        LEFT ($1:reviewTime::STRING,2),
        CASE 
            WHEN SUBSTRING ($1:reviewTime::STRING,5,1) = ','
            THEN SUBSTRING ($1:reviewTime::STRING,4,1)
            ELSE SUBSTRING ($1:reviewTime::STRING,4,2)
        END
    )                               AS REVIEW_TIME_FORMATTED,
    $1:reviewerID::STRING           AS REVIEWER_ID,
    $1:reviewerName::STRING         AS REVIEWER_NAME,
    $1:summary::STRING              AS SUMMARY,
    DATE($1:unixReviewTime::INT)    AS UNIX_REVIEW_TIME
FROM @MANAGE_DB.PUBLIC.INSTRUMENT_STAGE;


-- CREATE DESTINATION TABLE
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.INSTRUMENT_REVIEWS (
    ASIN                STRING,
    HELPFUL             STRING,
    OVERALL             STRING,
    REVIEW_TEXT         STRING,
    REVIEW_TIME         DATE,
    REVIEWER_ID         STRING,
    REVIEWER_NAME       STRING,
    SUMMARY             STRING,
    UNIX_REVIEW_TIME    DATE
);

SELECT * FROM DEMO_DB.PUBLIC.INSTRUMENT_REVIEWS;


-- LOAD TRANSOFRMED JSON DATA
COPY INTO DEMO_DB.PUBLIC.INSTRUMENT_REVIEWS
    FROM (
        SELECT 
            $1:asin::STRING                 AS ASIN,
            $1:helpful                      AS HELPFUL,
            $1:overall                      AS OVERALL,
            $1:reviewText::STRING           AS REVIEW_TEXT,
            DATE_FROM_PARTS (
                RIGHT ($1:reviewTime::STRING,4),
                LEFT ($1:reviewTime::STRING,2),
                CASE 
                    WHEN SUBSTRING ($1:reviewTime::STRING,5,1) = ','
                    THEN SUBSTRING ($1:reviewTime::STRING,4,1)
                    ELSE SUBSTRING ($1:reviewTime::STRING,4,2)
                END
            )                               AS REVIEW_TIME,
            $1:reviewerID::STRING           AS REVIEWER_ID,
            $1:reviewerName::STRING         AS REVIEWER_NAME,
            $1:summary::STRING              AS SUMMARY,
            DATE($1:unixReviewTime::INT)    AS UNIX_REVIEW_TIME
        FROM @MANAGE_DB.PUBLIC.INSTRUMENT_STAGE
    );


-- INSPECT DATA
SELECT * FROM DEMO_DB.PUBLIC.INSTRUMENT_REVIEWS;