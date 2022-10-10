USE ROLE ACCOUNTADMIN;
-- DEDICATED VIRTUAL WAREHOUSE FOR DIFFERENT USER GROUPS AND/OR WORK LOADS


-- CRAETE DEDICATED VIRTUAL WAREHOUSES FOR EVERY CLASS OF WORKLOAD DESIRED
-- DATA SCIENTIST GROUP 
CREATE WAREHOUSE DS_WH
    WITH WAREHOUSE_SIZE = 'SMALL'
    WAREHOUSE_TYPE = 'STANDARD'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 1
    SCALING_POLICY = 'STANDARD';
    
-- DBA GROUP
CREATE WAREHOUSE DBA_WH
    WITH WAREHOUSE_SIZE = 'SMALL'
    WAREHOUSE_TYPE = 'STANDARD'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 1
    SCALING_POLICY = 'STANDARD';


-- CREATE ROLES FOR DS AND DBAs
CREATE ROLE DATA_SCIENTIST;
GRANT USAGE ON WAREHOUSE DS_WH TO ROLE DATA_SCIENTIST;

CREATE ROLE DBA;
GRANT USAGE ON WAREHOUSE DBA_WH TO ROLE DBA;


-- CREATE USERS AND ASSIGN ROLES/WH
-- DATA SCIENTISTS
CREATE USER DS1
    PASSWORD = 'DS1'
    LOGIN_NAME = 'DS1'
    DEFAULT_ROLE = 'DATA_SCIENTIST'
    DEFAULT_WAREHOUSE = 'DS_WH'
    MUST_CHANGE_PASSWORD = TRUE;

CREATE USER DS2
    PASSWORD = 'DS2'
    LOGIN_NAME = 'DS2'
    DEFAULT_ROLE = 'DATA_SCIENTIST'
    DEFAULT_WAREHOUSE = 'DS_WH'
    MUST_CHANGE_PASSWORD = TRUE;

CREATE USER DS3
    PASSWORD = 'DS3'
    LOGIN_NAME = 'DS3'
    DEFAULT_ROLE = 'DATA_SCIENTIST'
    DEFAULT_WAREHOUSE = 'DS_WH'
    MUST_CHANGE_PASSWORD = TRUE;

-- DBAs
CREATE USER DBA1
    PASSWORD = 'DBA1'
    LOGIN_NAME = 'DBA1'
    DEFAULT_ROLE = 'DBA'
    DEFAULT_WAREHOUSE = 'DBA_WH'
    MUST_CHANGE_PASSWORD = TRUE;

CREATE USER DBA2
    PASSWORD = 'DBA2'
    LOGIN_NAME = 'DBA2'
    DEFAULT_ROLE = 'DBA'
    DEFAULT_WAREHOUSE = 'DBA_WH'
    MUST_CHANGE_PASSWORD = TRUE;

CREATE USER DBA3
    PASSWORD = 'DBA3'
    LOGIN_NAME = 'DBA3'
    DEFAULT_ROLE = 'DBA'
    DEFAULT_WAREHOUSE = 'DBA_WH'
    MUST_CHANGE_PASSWORD = TRUE;


-- ASIGN ROLES TO WAREHOUSES
GRANT ROLE DATA_SCIENTIST TO USER DS1;
GRANT ROLE DATA_SCIENTIST TO USER DS2;
GRANT ROLE DATA_SCIENTIST TO USER DS3;
    
GRANT ROLE DBA TO USER DBA1;
GRANT ROLE DBA TO USER DBA2;
GRANT ROLE DBA TO USER DBA3;


-- DROP OBJECTS
DROP USER DS1;
DROP USER DS2;
DROP USER DS3;
DROP USER DBA1;
DROP USER DBA2;
DROP USER DBA3;

DROP ROLE DATA_SCIENTIST;
DROP ROLE DBA;

DROP WAREHOUSE DS_WH;
DROP WAREHOUSE DBA_WH;