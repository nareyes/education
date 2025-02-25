// Snowflake Definitive Guide 1st Edition by Joyce Kay Avila - August 2022
// ISBN-10 : 1098103823
// ISBN-13 : 978-1098103828
// Contact the author: https://www.linkedin.com/in/joycekayavila/
// Chapter 5: Leveraging Snowflake Access Controls


// Page 148 - Prep Work
// Create new worksheet: Chapter5 Snowflake Access Controls
// Context setting - make sure role is set to SYSADMIN and COMPUTE_WH is the virtual warehouse

// Page 150 - Create Virtual Warehouses
USE ROLE SYSADMIN;
USE WAREHOUSE COMPUTE_WH;
CREATE OR REPLACE WAREHOUSE VW1_WH WITH WAREHOUSE_SIZE='X-SMALL'
INITIALLY_SUSPENDED=true;
CREATE OR REPLACE WAREHOUSE VW2_WH WITH WAREHOUSE_SIZE='X-SMALL'
INITIALLY_SUSPENDED=true;
CREATE OR REPLACE WAREHOUSE VW3_WH WITH WAREHOUSE_SIZE='X-SMALL'
INITIALLY_SUSPENDED=true;

// Page 151 - SHOW command will confirm the virtual warehouses were created
SHOW WAREHOUSES;

// Page 151 - SHOW command will confirm the virtual warehouses available to the SYSADMIN role
USE ROLE SYSADMIN;
SHOW DATABASES;

// Page 151 - SHOW command will confirm the virtual warehouses available to the PUBLIC role
USE ROLE PUBLIC;
SHOW DATABASES;

// Page 151 - SHOW command will confirm the virtual warehouses available to the ACCOUNTADMIN role
USE ROLE ACCOUNTADMIN;
SHOW DATABASES;

// Page 152 - Create schemas right after createing database and then create schema with fully qualified name
USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE DB1;
CREATE OR REPLACE DATABASE DB2;
CREATE OR REPLACE SCHEMA DB2_SCHEMA1;
CREATE OR REPLACE SCHEMA DB2_SCHEMA2;
CREATE OR REPLACE SCHEMA DB1.DB1_SCHEMA1;

// Page 152 - Use the SHOW command to confirm the details of the databases
SHOW DATABASES;

// Page 152 - Use the ACCOUNTADMIN role to create a new Resource Monitor
USE ROLE ACCOUNTADMIN;
CREATE OR REPLACE RESOURCE MONITOR MONITOR1_RM WITH CREDIT_QUOTA=10000
TRIGGERS ON 75 PERCENT DO NOTIFY
 ON 98 PERCENT DO SUSPEND
 ON 105 PERCENT DO SUSPEND_IMMEDIATE;
 
// Page 152 - Use the SHOW command to confirm the Resource Monitors that were created 
SHOW RESOURCE MONITORS;

// Page 153 - Create some new users
USE ROLE USERADMIN;
CREATE OR REPLACE USER USER1 LOGIN_NAME=ARNOLD;
CREATE OR REPLACE USER USER2 LOGIN_NAME=BEATRICE;
CREATE OR REPLACE USER USER3 LOGIN_NAME=COLLIN;
CREATE OR REPLACE USER USER4 LOGIN_NAME=DIEDRE;

// Page 153 - Use the SHOW command for the USERADMIN role
// Error is expected
USE ROLE USERADMIN;
SHOW USERS;

// Page 153 - Use the SHOW command for the SECURITYADMIN role
USE ROLE SECURITYADMIN;
SHOW USERS;

// Page 156 - Use the SHOW command for the USERADMIN role to display roles
USE ROLE USERADMIN;
SHOW ROLES;

// Page 156 - Use the SHOW command for the SECURITYADMIN role to display roles
USE ROLE SECURITYADMIN;
SHOW ROLES;

// Page 157 - Create 10 custom roles
USE ROLE USERADMIN;
CREATE OR REPLACE ROLE DATA_SCIENTIST;
CREATE OR REPLACE ROLE ANALYST_SR;
CREATE OR REPLACE ROLE ANALYST_JR;
CREATE OR REPLACE ROLE DATA_EXCHANGE_ASST;
CREATE OR REPLACE ROLE ACCOUNTANT_SR;
CREATE OR REPLACE ROLE ACCOUNTANT_JR;
CREATE OR REPLACE ROLE PRD_DBA;
CREATE OR REPLACE ROLE DATA_ENGINEER;
CREATE OR REPLACE ROLE DEVELOPER_SR;
CREATE OR REPLACE ROLE DEVELOPER_JR;
SHOW ROLES;

// Page 158 - Create system service account roles
USE ROLE USERADMIN;
CREATE OR REPLACE ROLE LOADER;
CREATE OR REPLACE ROLE VISUALIZER;
CREATE OR REPLACE ROLE REPORTING;
CREATE OR REPLACE ROLE MONITORING;

// Page 158 - Create system object access roles
USE ROLE USERADMIN;
CREATE OR REPLACE ROLE DB1_SCHEMA1_READONLY;
CREATE OR REPLACE ROLE DB1_SCHEMA1_ALL;
CREATE OR REPLACE ROLE DB2_SCHEMA1_READONLY;
CREATE OR REPLACE ROLE DB2_SCHEMA1_ALL;
CREATE OR REPLACE ROLE DB2_SCHEMA2_READONLY;
CREATE OR REPLACE ROLE DB2_SCHEMA2_ALL;
CREATE OR REPLACE ROLE RM1_MODIFY;
CREATE OR REPLACE ROLE WH1_USAGE;
CREATE OR REPLACE ROLE WH2_USAGE;
CREATE OR REPLACE ROLE WH3_USAGE;
CREATE OR REPLACE ROLE DB1_MONITOR;
CREATE OR REPLACE ROLE DB2_MONITOR;
CREATE OR REPLACE ROLE WH1_MONITOR;
CREATE OR REPLACE ROLE WH2_MONITOR;
CREATE OR REPLACE ROLE WH3_MONITOR;
CREATE OR REPLACE ROLE RM1_MONITOR;

// Page 160 - Complete the system-level role hierarchy assignments
USE ROLE USERADMIN;
GRANT ROLE RM1_MONITOR TO ROLE MONITORING;
GRANT ROLE WH1_MONITOR TO ROLE MONITORING;
GRANT ROLE WH2_MONITOR TO ROLE MONITORING;
GRANT ROLE WH3_MONITOR TO ROLE MONITORING;
GRANT ROLE DB1_MONITOR TO ROLE MONITORING;
GRANT ROLE DB2_MONITOR TO ROLE MONITORING;
GRANT ROLE WH3_USAGE TO ROLE MONITORING;

GRANT ROLE DB1_SCHEMA1_ALL TO ROLE LOADER;
GRANT ROLE DB2_SCHEMA1_ALL TO ROLE LOADER;
GRANT ROLE DB2_SCHEMA2_ALL TO ROLE LOADER;
GRANT ROLE WH3_USAGE TO ROLE LOADER;

GRANT ROLE DB2_SCHEMA1_READONLY TO ROLE VISUALIZER;
GRANT ROLE DB2_SCHEMA2_READONLY TO ROLE VISUALIZER;
GRANT ROLE WH3_USAGE TO ROLE VISUALIZER;

GRANT ROLE DB1_SCHEMA1_READONLY TO ROLE REPORTING;
GRANT ROLE DB2_SCHEMA1_READONLY TO ROLE REPORTING;
GRANT ROLE DB2_SCHEMA2_READONLY TO ROLE REPORTING;

GRANT ROLE WH3_USAGE TO ROLE REPORTING;
GRANT ROLE MONITORING TO ROLE ACCOUNTANT_SR;
GRANT ROLE LOADER TO ROLE DEVELOPER_SR;
GRANT ROLE VISUALIZER TO ROLE ANALYST_JR;

GRANT ROLE REPORTING TO ROLE ACCOUNTANT_JR;
GRANT ROLE RM1_MODIFY TO ROLE ACCOUNTANT_SR;

// Page 161 - Complete the functional role hierarchy assignment
USE ROLE USERADMIN;
GRANT ROLE ACCOUNTANT_JR TO ROLE ACCOUNTANT_SR;
GRANT ROLE ANALYST_JR TO ROLE ANALYST_SR;
GRANT ROLE ANALYST_SR TO ROLE DATA_SCIENTIST;
GRANT ROLE DEVELOPER_JR TO ROLE DEVELOPER_SR;
GRANT ROLE DEVELOPER_SR TO ROLE DATA_ENGINEER;
GRANT ROLE DATA_ENGINEER TO ROLE PRD_DBA;
GRANT ROLE ACCOUNTANT_SR TO ROLE ACCOUNTADMIN;
GRANT ROLE DATA_EXCHANGE_ASST TO ROLE ACCOUNTADMIN;
GRANT ROLE DATA_SCIENTIST TO ROLE SYSADMIN;
GRANT ROLE PRD_DBA TO ROLE SYSADMIN;

// Page 161 - Grant usage of virtual warehouse to IT and business roles
GRANT ROLE WH1_USAGE TO ROLE DEVELOPER_JR;
GRANT ROLE WH1_USAGE TO ROLE DEVELOPER_SR;
GRANT ROLE WH1_USAGE TO ROLE DATA_ENGINEER;
GRANT ROLE WH1_USAGE TO ROLE PRD_DBA;

GRANT ROLE WH2_USAGE TO ROLE ACCOUNTANT_JR;
GRANT ROLE WH2_USAGE TO ROLE ACCOUNTANT_SR;
GRANT ROLE WH2_USAGE TO ROLE DATA_EXCHANGE_ASST;
GRANT ROLE WH2_USAGE TO ROLE ANALYST_JR;
GRANT ROLE WH2_USAGE TO ROLE ANALYST_SR;
GRANT ROLE WH2_USAGE TO ROLE DATA_SCIENTIST;

// Page 162 - Grant privileges to the functional roles and to grant privileges to custom roles only ACCOUNTADMIN can grant
USE ROLE ACCOUNTADMIN;
GRANT CREATE DATA EXCHANGE LISTING ON ACCOUNT TO ROLE DATA_EXCHANGE_ASST;
GRANT IMPORT SHARE ON ACCOUNT TO ROLE DATA_EXCHANGE_ASST;
GRANT CREATE SHARE ON ACCOUNT TO ROLE DATA_EXCHANGE_ASST;
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO ROLE MONITORING;
GRANT MONITOR ON RESOURCE MONITOR MONITOR1_RM TO ROLE MONITORING;
GRANT MONITOR USAGE ON ACCOUNT TO ROLE ACCOUNTANT_JR;
GRANT APPLY MASKING POLICY ON ACCOUNT TO ROLE ACCOUNTANT_SR;
GRANT MONITOR EXECUTION ON ACCOUNT TO ROLE ACCOUNTANT_SR;
GRANT MODIFY ON RESOURCE MONITOR MONITOR1_RM TO ROLE ACCOUNTANT_SR;

// Page 164 - Grant privileges
USE ROLE SYSADMIN;
GRANT USAGE ON DATABASE DB1 TO ROLE DB1_SCHEMA1_READONLY;
GRANT USAGE ON DATABASE DB2 TO ROLE DB2_SCHEMA1_READONLY;
GRANT USAGE ON DATABASE DB2 TO ROLE DB2_SCHEMA2_READONLY;
GRANT USAGE ON SCHEMA DB1.DB1_SCHEMA1 TO ROLE DB1_SCHEMA1_READONLY;
GRANT USAGE ON SCHEMA DB2.DB2_SCHEMA1 TO ROLE DB2_SCHEMA1_READONLY;
GRANT USAGE ON SCHEMA DB2.DB2_SCHEMA2 TO ROLE DB2_SCHEMA2_READONLY;


GRANT SELECT ON ALL TABLES IN SCHEMA DB1.DB1_SCHEMA1
 TO ROLE DB1_SCHEMA1_READONLY;
GRANT SELECT ON ALL TABLES IN SCHEMA DB2.DB2_SCHEMA1
 TO ROLE DB2_SCHEMA1_READONLY;
GRANT SELECT ON ALL TABLES IN SCHEMA DB2.DB2_SCHEMA2
 TO ROLE DB1_SCHEMA1_READONLY;
GRANT ALL ON SCHEMA DB1.DB1_SCHEMA1 TO ROLE DB1_SCHEMA1_ALL;
GRANT ALL ON SCHEMA DB2.DB2_SCHEMA1 TO ROLE DB2_SCHEMA1_ALL;
GRANT ALL ON SCHEMA DB2.DB2_SCHEMA2 TO ROLE DB2_SCHEMA2_ALL;
GRANT MONITOR ON DATABASE DB1 TO ROLE DB1_MONITOR;
GRANT MONITOR ON DATABASE DB2 TO ROLE DB2_MONITOR;
GRANT MONITOR ON WAREHOUSE VW1_WH TO ROLE WH1_MONITOR;
GRANT MONITOR ON WAREHOUSE VW2_WH TO ROLE WH2_MONITOR;
GRANT MONITOR ON WAREHOUSE VW3_WH TO ROLE WH3_MONITOR;
GRANT USAGE ON WAREHOUSE VW1_WH TO WH1_USAGE;
GRANT USAGE ON WAREHOUSE VW2_WH TO WH2_USAGE;
GRANT USAGE ON WAREHOUSE VW3_WH TO WH3_USAGE;

// Page 165 - Grant FUTURE direct assigned privileges
USE ROLE ACCOUNTADMIN;
GRANT SELECT ON FUTURE TABLES IN SCHEMA DB1.DB1_SCHEMA1
 TO ROLE DB1_SCHEMA1_READONLY;
GRANT SELECT ON FUTURE TABLES IN SCHEMA DB2.DB2_SCHEMA1
 TO ROLE DB2_SCHEMA1_READONLY;
GRANT SELECT ON FUTURE TABLES IN SCHEMA DB2.DB2_SCHEMA2
 TO ROLE DB2_SCHEMA2_READONLY;
GRANT SELECT ON FUTURE TABLES IN SCHEMA DB1.DB1_SCHEMA1 TO ROLE DB1_SCHEMA1_ALL;
GRANT SELECT ON FUTURE TABLES IN SCHEMA DB2.DB2_SCHEMA1 TO ROLE DB2_SCHEMA1_ALL;
GRANT SELECT ON FUTURE TABLES IN SCHEMA DB2.DB2_SCHEMA2 TO ROLE DB2_SCHEMA2_ALL;

// Page 165 - Assign roles to the users
USE ROLE USERADMIN;
GRANT ROLE DATA_EXCHANGE_ASST TO USER USER1;
GRANT ROLE DATA_SCIENTIST TO USER USER2;
GRANT ROLE ACCOUNTANT_SR TO USER USER3;
GRANT ROLE PRD_DBA TO USER USER4;

// Page 166 - Validating our work
// Error is expected
USE ROLE ACCOUNTANT_JR;
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY WHERE QUERY_TYPE = 'GRANT';

// Page 167 - Validating our work
USE ROLE ACCOUNTANT_SR;
USE WAREHOUSE VW2_WH;
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY WHERE QUERY_TYPE ='GRANT';

// Page 167 - Use the SHOW command to see the databases avaialable to the SYSADMIN role
USE ROLE SYSADMIN;
SHOW DATABASES;

// Page 167 - Take a look at the tables in the DB1_SCHEMA1 schema
USE SCHEMA DB1_SCHEMA1;
SHOW TABLES;

// Page 167 - Create a table
CREATE OR REPLACE TABLE DB1.DB1_SCHEMA1.TABLE1 (a varchar);
INSERT INTO TABLE1 VALUES ('A');

// Page 167 - Confirm the table was created
SHOW TABLES;

// Page 168 - Test if the REPORTING role can access the table
USE ROLE REPORTING;
USE WAREHOUSE VW3_WH;
SELECT * FROM DB1.DB1_SCHEMA1.TABLE1;

// Page 168 - Test if the VISUALIZER role can access the table
// Error is expected
USE ROLE VISUALIZER;
SELECT * FROM DB1.DB1_SCHEMA1.TABLE1;

// Page 168 - Additional queries to try
USE ROLE ACCOUNTANT_SR;
USE WAREHOUSE VW3_WH;
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS;
SHOW GRANTS ON ACCOUNT;
SHOW GRANTS ON DATABASE DB1;
SHOW GRANTS OF ROLE ANALYST_SR;
SHOW FUTURE GRANTS IN DATABASE DB1;
SHOW FUTURE GRANTS IN SCHEMA DB1.DB1_SCHEMA1;

// Page 169 Grant then Revoke a privilege
USE ROLE ACCOUNTADMIN;
GRANT MONITOR USAGE ON ACCOUNT TO ROLE ANALYST_JR;
USE ROLE USERADMIN;
REVOKE MONITOR USAGE ON ACCOUNT FROM ROLE ANALYST_JR;

// Page 169 - Create a new user
USE ROLE USERADMIN;
CREATE OR REPLACE USER USER10
PASSWORD='123'
LOGIN_NAME = ABARNETT
DISPLAY_NAME = AMY
FIRST_NAME = AMY
LAST_NAME = BARNETT
EMAIL = 'ABARNETT@COMPANY.COM'
MUST_CHANGE_PASSWORD=TRUE;

// Page 169 - Set up an expiration time for a user
USE ROLE USERADMIN;
ALTER USER USER10 SET DAYS_TO_EXPIRY = 30;

// Page 170 - assign default virtual warehouse and role that does not exist

USE ROLE USERADMIN;
ALTER USER USER10 SET DEFAULT_WAREHOUSE=WAREHOUSE52_WH;

USE ROLE USERADMIN;
ALTER USER USER10 SET DEFAULT_ROLE=IMAGINARY_ROLE;

// Sign out of your account and sign in as USER10 to test what happened as a result of the previous statements
// Sign back in to your main account

// Page 171 - Set some correct defaults now for USER10
USE ROLE USERADMIN;
GRANT ROLE ACCOUNTANT_SR TO USER USER10;
ALTER USER USER10 SET DEFAULT_NAMESPACE=SNOWFLAKE.ACCOUNT_USAGE;
ALTER USER USER10 SET DEFAULT_WAREHOUSE=VW2_WH;
ALTER USER USER10 SET DEFAULT_ROLE = ACCOUNTANT_SR;
ALTER USER USER10 UNSET DEFAULT_WAREHOUSE;

// Sign out of your account again and sign in as USER10
// Sign back in to your main account

// Page 171 - Immediately clear a lock for a user
USE ROLE USERADMIN;
ALTER USER USER10 SET MINS_TO_UNLOCK=0;

// Page 171 - Attempt to reset a user's password with an unacceptable password
// Error is expected
USE ROLE USERADMIN;
ALTER USER USER10 SET PASSWORD = '123'
MUST_CHANGE_PASSWORD = TRUE;

// Page 172 - Reset a user's password correctly
USE ROLE USERADMIN;
ALTER USER USER10 SET PASSWORD = '123456Aa'
MUST_CHANGE_PASSWORD = TRUE;

// Page 172 - Demonstrate how the SECURITY admin can run the same statements
USE ROLE SECURITYADMIN;
ALTER USER USER10 SET PASSWORD = '123456Bb'
MUST_CHANGE_PASSWORD = TRUE;

// Page 172 - Abort a user's queries and prevent any new queries
USE ROLE USERADMIN;
ALTER USER USER10 SET DISABLED = TRUE;

// Page 172 - Use the DESC command to get a listing of user's values
USE ROLE USERADMIN;
DESC USER USER10;

// Page 173 - Reset value back to default value and check the results
USE ROLE USERADMIN;
ALTER USER USER10 SET DEFAULT_WAREHOUSE = DEFAULT;
USE ROLE USERADMIN;
DESC USER USER10;

// Page 173 - See a list of users
USE ROLE SECURITYADMIN;
SHOW USERS;

// Page 173 - Use the LIKE command 
USE ROLE SECURITYADMIN;
SHOW USERS LIKE 'USER%';

// Page 174 - Drop a user
USE ROLE USERADMIN;
DROP USER USER10;

// Page 175 - Edit User from the Web UI

// Page 176 - Manage Roles from the Web UI

// Page 179 - Code Cleanup
USE ROLE SYSADMIN;
DROP DATABASE DB1;
DROP DATABASE DB2;
SHOW DATABASES;
DROP WAREHOUSE VW1_WH; DROP WAREHOUSE VW2_WH; DROP WAREHOUSE VW3_WH;
SHOW WAREHOUSES;

USE ROLE ACCOUNTADMIN;
DROP RESOURCE MONITOR MONITOR1_RM;
SHOW RESOURCE MONITORS;

USE ROLE USERADMIN;
DROP ROLE DATA_SCIENTIST; DROP ROLE ANALYST_SR; DROP ROLE ANALYST_JR;
DROP ROLE DATA_EXCHANGE_ASST; DROP ROLE ACCOUNTANT_SR; DROP ROLE ACCOUNTANT_JR;
DROP ROLE PRD_DBA; DROP ROLE DATA_ENGINEER; DROP ROLE DEVELOPER_SR; DROP
ROLE DEVELOPER_JR; DROP ROLE LOADER; DROP ROLE VISUALIZER; DROP ROLE REPORTING;
DROP ROLE MONITORING; DROP ROLE RM1_MODIFY; DROP ROLE WH1_USAGE;
DROP ROLE WH2_USAGE; DROP ROLE WH3_USAGE; DROP ROLE DB1_MONITOR; DROP
ROLE DB2_MONITOR; DROP ROLE WH1_MONITOR; DROP ROLE WH2_MONITOR; DROP ROLE
WH3_MONITOR; DROP ROLE RM1_MONITOR; DROP ROLE DB1_SCHEMA1_READONLY; DROP ROLE
DB1_SCHEMA1_ALL; DROP ROLE DB2_SCHEMA1_READONLY; DROP ROLE DB2_SCHEMA1_ALL;
DROP ROLE DB2_SCHEMA2_READONLY; DROP ROLE DB2_SCHEMA2_ALL;
SHOW ROLES;

USE ROLE USERADMIN;
DROP USER USER1; DROP USER USER2; DROP USER USER3;DROP USER USER4;

USE ROLE SECURITYADMIN;
SHOW USERS;
