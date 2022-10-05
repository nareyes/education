-- CREATE NEW STAGE
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROR
    URL = 's3://bucketsnowflakes4';

LIST @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROR;


-- CREATE TABLE
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.ORDER_DETAILS_ERRORS (
    ORDER_ID    VARCHAR(30),
    AMOUNT      INT,
    PROFIT      INT,
    QUANITTY    INT,
    CATEGORY    VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
);

SELECT * FROM DEMO_DB.PUBLIC.ORDER_DETAILS_ERRORS;


-- COPY DATA WITH CONTINUE ON ERROR (SKIPS LOADING RECORDS THAT CAUSE ERROR)
COPY INTO DEMO_DB.PUBLIC.ORDER_DETAILS_ERRORS
    FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROR
    FILE_FORMAT = (
        TYPE = CSV
        FIELD_DELIMITER = ','
        SKIP_HEADER = 1
    )
    FILES = ('OrderDetails_error.csv', 'OrderDetails_error2.csv')
    ON_ERROR = 'CONTINUE';

TRUNCATE TABLE DEMO_DB.PUBLIC.ORDER_DETAILS_ERRORS;


-- COPY DATA WITH ABORT ON ERROR (ABORTS ENTIRE LOAD IF AN ERROR IS CAUSED FROM ANY FILE)
COPY INTO DEMO_DB.PUBLIC.ORDER_DETAILS_ERRORS
    FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROR
    FILE_FORMAT = (
        TYPE = CSV
        FIELD_DELIMITER = ','
        SKIP_HEADER = 1
    )
    FILES = ('OrderDetails_error.csv', 'OrderDetails_error2.csv')
    ON_ERROR = 'ABORT_STATEMENT';

TRUNCATE TABLE DEMO_DB.PUBLIC.ORDER_DETAILS_ERRORS;


-- COPY DATA WITH SKIP FILE ON ERROR (SKIPS FILE IF THERE IS AN ERROR)
COPY INTO DEMO_DB.PUBLIC.ORDER_DETAILS_ERRORS
    FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROR
    FILE_FORMAT = (
        TYPE = CSV
        FIELD_DELIMITER = ','
        SKIP_HEADER = 1
    )
    FILES = ('OrderDetails_error.csv', 'OrderDetails_error2.csv')
    ON_ERROR = 'SKIP_FILE';

TRUNCATE TABLE DEMO_DB.PUBLIC.ORDER_DETAILS_ERRORS;


-- COPY DATA WITH SKIP FILE ON ERROR (SKIPS FILE IF THERE IS N ERRORS)
COPY INTO DEMO_DB.PUBLIC.ORDER_DETAILS_ERRORS
    FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROR
    FILE_FORMAT = (
        TYPE = CSV
        FIELD_DELIMITER = ','
        SKIP_HEADER = 1
    )
    FILES = ('OrderDetails_error.csv', 'OrderDetails_error2.csv')
    ON_ERROR = 'SKIP_FILE_3';

TRUNCATE TABLE DEMO_DB.PUBLIC.ORDER_DETAILS_ERRORS;


-- COPY DATA WITH SKIP FILE ON ERROR (SKIPS FILE IF THERE IS N% ERRORS)
COPY INTO DEMO_DB.PUBLIC.ORDER_DETAILS_ERRORS
    FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROR
    FILE_FORMAT = (
        TYPE = CSV
        FIELD_DELIMITER = ','
        SKIP_HEADER = 1
    )
    FILES = ('OrderDetails_error.csv', 'OrderDetails_error2.csv')
    ON_ERROR = 'SKIP_FILE_1%';

TRUNCATE TABLE DEMO_DB.PUBLIC.ORDER_DETAILS_ERRORS;


-- CLEAN UP
DROP TABLE IF EXISTS DEMO_DB.PUBLIC.ORDER_DETAILS_ERRORS;