// Snowflake Definitive Guide 1st Edition by Joyce Kay Avila - August 2022
// ISBN-10 : 1098103823
// ISBN-13 : 978-1098103828
// Contact the author: https://www.linkedin.com/in/joycekayavila/
// Chapter 4: Exploring Snowflake SQL Commands, Data Types, and Functions


// Page 112 - Prep Work
// Create new worksheet: Chapter4 Syntax Examples, Data Types, and Functions
// Context setting - make sure role is set to SYSADMIN and COMPUTE_WH is the virtual warehouse

// Page 115 - Navigate to Activity -> Query History and view the options

// Page 118 - Createdatabase, schema, and tables to be used for chapter examples
USE ROLE SYSADMIN;
USE WAREHOUSE COMPUTE_WH;
CREATE OR REPLACE DATABASE DEMO4_DB;
CREATE OR REPLACE SCHEMA SUBQUERIES;
CREATE OR REPLACE TABLE DEMO4_DB.SUBQUERIES.DERIVED
 (ID integer, AMT integer, Total integer);
INSERT INTO DERIVED (ID, AMT, Total)
VALUES (1,1000,4000),(2,2000,3500),(3,3000, 9900),(4,4000,3000),
 (5,5000,3700),(6,6000,2222);
SELECT * FROM DEMO4_DB.SUBQUERIES.DERIVED;

// Page 119 - Add a second table for use in a later example
CREATE OR REPLACE TABLE DEMO4_DB.SUBQUERIES.TABLE2
 (ID integer, AMT integer, Total integer);
INSERT INTO TABLE2 (ID, AMT, Total)
VALUES (1,1000,8300),(2,1001,1900),(3,3000,4400),(4,1010,3535),
 (5,1200,3232),(6,1000,2222);
SELECT * FROM DEMO4_DB.SUBQUERIES.TABLE2;

// Page 120 - Execute an uncorrelated (i.e., independent) subquery
SELECT ID, AMT
FROM DEMO4_DB.SUBQUERIES.DERIVED
WHERE AMT = (SELECT MAX(AMT)
 FROM DEMO4_DB.SUBQUERIES.TABLE2);

// Page 120 - Execute a correlated query 
// Note that an error will be returned 
SELECT ID, AMT
FROM DEMO4_DB.SUBQUERIES.DERIVED
WHERE AMT = (SELECT AMT
 FROM DEMO4_DB.SUBQUERIES.TABLE2
 WHERE ID = ID); 
 
// Page 120 - Add MAX to the previous statement 
SELECT ID, AMT
FROM DEMO4_DB.SUBQUERIES.DERIVED
WHERE AMT = (SELECT MAX(AMT)
 FROM DEMO4_DB.SUBQUERIES.TABLE2
 WHERE ID = ID); 

// Page 120 - Change the equal sign to a greater than sign
SELECT ID, AMT
FROM DEMO4_DB.SUBQUERIES.DERIVED
WHERE AMT > (SELECT MAX(AMT)
 FROM DEMO4_DB.SUBQUERIES.TABLE2
 WHERE ID = ID);

// Page 121 - Change MAX to AVG
SELECT ID, AMT
FROM DEMO4_DB.SUBQUERIES.DERIVED
WHERE AMT > (SELECT AVG(AMT)
 FROM DEMO4_DB.SUBQUERIES.TABLE2
 WHERE ID = ID);

// Page 121 - Create a derived column from the AMT column and then create a second derived column
SELECT ID, AMT, AMT * 10 as AMT1, AMT1 + 20 as AMT2
FROM DEMO4_DB.SUBQUERIES.DERIVED;
 
// Page 122 - Create a derived column to be consumed by an outer SELECT query
SELECT sub.ID, sub.AMT, sub.AMT1 + 20 as AMT2
FROM (SELECT ID, AMT, AMT * 10 as AMT1
 FROM DEMO4_DB.SUBQUERIES.DERIVED) AS sub;
 
// Page 122 - Use a CTE subquery
WITH CTE1 AS (SELECT ID, AMT, AMT * 10 as AMT2
 FROM DEMO4_DB.SUBQUERIES.DERIVED)
SELECT a.ID, b.AMT, b.AMT2 + 20 as AMT2
FROM DEMO4_DB.SUBQUERIES.DERIVED a
 JOIN CTE1 b ON(a.ID = b.ID);
 
// Page 123 - Create a new schema and table for multirow insert testing 
USE ROLE SYSADMIN;
CREATE OR REPLACE SCHEMA DEMO4_DB.TEST;
CREATE OR REPLACE TABLE DEMO4_DB.TEST.TEST1 (ID integer, DEPT Varchar);
INSERT INTO TEST1 (ID, DEPT)
VALUES (1,'one');
SELECT * FROM DEMO4_DB.TEST.TEST1;

// Page 123 - Insert a numerical value instead into the VARCHAR column
USE ROLE SYSADMIN;
CREATE OR REPLACE SCHEMA DEMO4_DB.TEST;
CREATE OR REPLACE TABLE DEMO4_DB.TEST.TEST1 (ID integer, DEPT Varchar);
INSERT INTO TEST1 (ID, DEPT)
VALUES (1,1);
SELECT * FROM DEMO4_DB.TEST.TEST1;

// Page 123 - Inserting both types into the column
//Error is expected
USE ROLE SYSADMIN;
CREATE OR REPLACE SCHEMA DEMO4_DB.TEST;
CREATE OR REPLACE TABLE DEMO4_DB.TEST.TEST1 (ID integer, DEPT Varchar);
INSERT INTO TEST1 (ID, DEPT)
VALUES (1,'one'), (2,2);
SELECT * FROM DEMO4_DB.TEST.TEST1;

// Page 124 - Instead Insert to values with the same data type 
USE ROLE SYSADMIN;
CREATE OR REPLACE SCHEMA DEMO4_DB.TEST;
CREATE OR REPLACE TABLE DEMO4_DB.TEST.TEST1 (ID integer, DEPT Varchar);
INSERT INTO TEST1 (ID, DEPT)
VALUES (1,'one'), (2,'two');
SELECT * FROM DEMO4_DB.TEST.TEST1;

// Page 124 - Now insert two numerical values
USE ROLE SYSADMIN;
CREATE OR REPLACE SCHEMA DEMO4_DB.TEST;
CREATE OR REPLACE TABLE DEMO4_DB.TEST.TEST1 (ID integer, DEPT Varchar);
INSERT INTO TEST1 (ID, DEPT)
VALUES (1,1), (2,2);
SELECT * FROM DEMO4_DB.TEST.TEST1;

// Page 124 - Continue to add another value
INSERT INTO TEST1 (ID, DEPT)
VALUES (5, 'five');
SELECT * FROM DEMO4_DB.TEST.TEST1;

// Page 128 - Fixed point numbers vary based on the data type
USE ROLE SYSADMIN;
CREATE OR REPLACE SCHEMA DEMO4_DB.DATATYPES;
CREATE OR REPLACE TABLE NUMFIXED (
 NUM NUMBER,
 NUM12 NUMBER(12, 0),
 DECIMAL DECIMAL (10, 2),
 INT INT,
 INTEGER INTEGER
);

// Page 128 - See the results showing the fixed-point number data types
DESC TABLE NUMFIXED;

// Page 128 - Compare fixed-point numbers to floating-point numbers
USE ROLE SYSADMIN; USE SCHEMA DEMO4_DB.DATATYPES;
CREATE OR REPLACE TABLE NUMFLOAT (
 FLOAT FLOAT,
 DOUBLE DOUBLE,
 DP DOUBLE PRECISION,
 REAL REAL
);

// Page 128 - See the results showing the data types
DESC TABLE NUMFLOAT;

// Page 129 - Create text strings
USE ROLE SYSADMIN; USE SCHEMA DEMO4_DB.DATATYPES;
CREATE OR REPLACE TABLE TEXTSTRING(
 VARCHAR VARCHAR,
 V100 VARCHAR(100),
 CHAR CHAR,
 C100 CHAR(100),
 STRING STRING,
 S100 STRING(100),
 TEXT TEXT,
 T100 TEXT(100)
);

// Page 130 - See the results showing the data types
DESC TABLE TEXTSTRING;

// Page 132 - Look at a few rows in the sample weather table
USE ROLE SYSADMIN;
USE SCHEMA SNOWFLAKE_SAMPLE_DATA.WEATHER;
SELECT * FROM DAILY_16_TOTAL
LIMIT 5;

// Page 132 - Look at the city data in the VARIANT column
SELECT v:city
FROM SNOWFLAKE_SAMPLE_DATA.WEATHER.DAILY_16_TOTAL
LIMIT 10;

// Page 133 - Break out the CITY data and list in a logical order
SELECT v:city:id, v:city:name, v:city:country, v:city:coord
FROM SNOWFLAKE_SAMPLE_DATA.WEATHER.DAILY_16_TOTAL
LIMIT 10;

// Page 134 - Cast VARIANT data type to a VARCHAR data type and assign meaningful labels
SELECT v:city:id AS ID, v:city:name AS CITY,
 v:city:country AS COUNTRY, v:city:coord:lat AS LATITUDE,
 v:city:coord:lon AS LONGITUDE
FROM SNOWFLAKE_SAMPLE_DATA.WEATHER.DAILY_16_TOTAL
LIMIT 10;

// Page 134 - Break out the DATA column, which is stored as an array
SELECT v:city:id AS ID, v:city:name::varchar AS city,
 v:city.country::varchar AS country, v:city:coord:lon
 AS longitude, v:city:coord:lat AS latitude
FROM SNOWFLAKE_SAMPLE_DATA.WEATHER.DAILY_16_TOTAL
LIMIT 10;

// Page 134 - Describe the results of the last query
DESC RESULT LAST_QUERY_ID();

// Page 134 - Look at more DATA in the VARIANT column
SELECT v:data
FROM SNOWFLAKE_SAMPLE_DATA.WEATHER.DAILY_16_TOTAL
LIMIT 10;

// Page 135 - Look at an array element
SELECT v:data[5]
FROM SNOWFLAKE_SAMPLE_DATA.WEATHER.DAILY_16_TOTAL
LIMIT 10;

// Page 135 - Look at humidity value for a particiular day for a specific city and country
SELECT v:city:name AS city, v:city:country AS country,
 v:data[0]:humidity AS HUMIDITY
FROM SNOWFLAKE_SAMPLE_DATA.WEATHER.DAILY_16_TOTAL
LIMIT 10;

// Page 135 - Include the first two data elements for humidity and the day temperature  
SELECT v:data[0]:dt::timestamp AS TIME,
v:data[0]:humidity AS HUMIDITY0, v:data[0]:temp:day AS DAY_TEMP0,
v:data[1]:humidity AS HUMIDITY1, v:data[1]:temp:day AS DAY_TEMP1,
v:data AS DATA
FROM SNOWFLAKE_SAMPLE_DATA.WEATHER.DAILY_16_TOTAL
LIMIT 100;

// Page 136 - Use the LATERNAL FLATTEN
SELECT d.value:dt::timestamp AS TIME,
 v:city:name AS CITY, v:city:country AS COUNTRY,
 d.path AS PATH, d.value:humidity AS HUMIDITY,
d.value:temp:day AS DAY_TEMP,v:data AS DATA
FROM SNOWFLAKE_SAMPLE_DATA.WEATHER.DAILY_16_TOTAL,
LATERAL FLATTEN(input => daily_16_total.v:data) d
LIMIT 100;

// Page 137 - Use a nested FLATTEN
SELECT d.value:dt::timestamp AS TIME,
t.key,
v:city:name AS CITY, v:city:country AS COUNTRY,
d.path AS PATH,
d.value:humidity AS HUMIDITY,
d.value:temp:day AS DAY_TEMP,
d.value:temp:night AS NIGHT_TEMP,
v:data AS data
FROM SNOWFLAKE_SAMPLE_DATA.WEATHER.DAILY_16_TOTAL,
LATERAL FLATTEN(input => daily_16_total.v:data) d,
LATERAL FLATTEN(input => d.value:temp) t
WHERE v:city:id = 1274693
LIMIT 100;

// Page 142 - Example of an Aggregate Function
SELECT LETTER, SUM(LOCATION) as AGGREGATE
FROM (SELECT 'A' as LETTER, 1 as LOCATION
 UNION ALL (SELECT 'A' as LETTER,1 as LOCATION)
 UNION ALL (SELECT 'E' as LETTER,5 as LOCATION)
 ) as AGG_TABLE
GROUP BY LETTER;

// Page 142 - Example of a Window Function
SELECT LETTER, SUM(LOCATION) OVER (PARTITION BY LETTER) as WINDOW_FUNCTION
FROM (SELECT 'A' as LETTER, 1 as LOCATION
 UNION ALL (SELECT 'A' as LETTER, 1 as LOCATION)
 UNION ALL (SELECT 'E' as LETTER, 5 as LOCATION)
 ) as WINDOW_TABLE;
 
// Page 145 - Code Cleanup 
DROP DATABASE DEMO4_DB; 