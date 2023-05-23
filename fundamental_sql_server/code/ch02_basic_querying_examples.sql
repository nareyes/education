-------------------------------------
-- Chapter 2: Single Table Queries --
-------------------------------------
USE tsql_fundamentals;

------------------------
-- ELEMENTS OF SELECT --
------------------------

-- Syntax Order of a SQL Query
SELECT empid, YEAR (orderdate) AS orderyear, COUNT (*) as numorder
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR (orderdate)
HAVING COUNT (*) > 1
ORDER BY empid, orderyear

-- Processing Order of a SQL Query
    -- FROM Sales.Orders
    -- WHERE custid = 71
    -- GROUP BY empid, YEAR (orderdate)
    -- HAVING COUNT (*) > 1
    -- SELECT empid, YEAR (orderdate) AS orderyear, COUNT (*) as numorder
    -- ORDER BY empid, orderyear


-- FROM Clause
SELECT
    orderid
    ,custid
    ,empid
    ,orderdate
    ,freight
FROM Sales.Orders;


-- WHERE Clause
SELECT
    orderid
    ,custid
    ,empid
    ,orderdate
    ,freight
FROM Sales.Orders
WHERE custid = 71;

-- GROUP BY Clause
SELECT
    empid
    ,YEAR (orderdate) AS orderyear
    ,SUM (freight) as totalfreight
    ,COUNT (*) as numorders -- counts nulls
    ,COUNT (orderid) as numorders -- counts known values (same in this case since there are no NULL orderids)
                                                                                                -- SELECT orderid
                                                                                                -- FROM Sales.Orders
                                                                                                -- WHERE orderid IS NULL;
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR (orderdate);

SELECT
    empid
    ,YEAR (orderdate) AS orderyear
    ,COUNT (DISTINCT custid) AS numcusts -- distinct customers handled by each employee
FROM Sales.Orders
GROUP BY empid, YEAR (orderdate);


-- HAVING Clause
SELECT
    empid
    ,YEAR (orderdate) AS orderyear
    ,COUNT (*) as numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR (orderdate)
HAVING COUNT (*) > 1; -- filters groups with more than one record (order)


-- SELECT CLause
SELECT
    orderid
    ,SUM (freight) AS totalfreight -- aliased column, cannot be referenced in any phases prior to SELECT
FROM Sales.Orders
GROUP BY orderid;

SELECT DISTINCT 
    empid 
    ,YEAR(orderdate) AS orderyear 
FROM Sales.Orders 
WHERE custid = 71;


-- ORDER BY Clause
SELECT 
    empid 
    ,YEAR (orderdate) AS orderyear
    ,COUNT (*) AS numorders 
FROM Sales.Orders 
WHERE custid = 71 
GROUP BY empid, YEAR (orderdate) 
HAVING COUNT (*) > 1 
ORDER BY empid ASC, orderyear DESC; -- ASC is the default, be explicit
-- ORDER BY can reference columns not in the SELECT clause, unless DISTINCT is used


-- TOP Filter
SELECT TOP (100) *
FROM Sales.Orders; -- this query can be used to explore the table without pulling all rows

SELECT TOP (5)
    orderid
    ,orderdate
    ,custid
    ,empid
FROM Sales.Orders
ORDER BY orderdate DESC; -- returns 5 rows, non-deterministic (more than one result can be considered correct)

SELECT TOP (1) PERCENT -- rounded up
    orderid
    ,orderdate
    ,custid
    ,empid
FROM Sales.Orders
ORDER BY orderdate DESC;

SELECT TOP (5)
    orderid
    ,orderdate
    ,custid
    ,empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC; -- additional ordering property makes result deterministic (tiebreaker)

SELECT TOP (5) WITH TIES
    orderid
    ,orderdate
    ,custid
    ,empid
FROM Sales.Orders
ORDER BY orderdate DESC; -- returns more than 5 rows if there are duplicates in the ordering property


-- OFFSET-FETCH Filter
SELECT
    orderid
    ,orderdate
    ,custid
    ,empid
FROM Sales.Orders
ORDER BY orderdate ASC, orderid ASC
    OFFSET 50 ROWS FETCH NEXT 25 ROWS ONLY; -- offset skips, fetch returns

SELECT
    orderid
    ,orderdate
    ,custid
    ,empid
FROM Sales.Orders
ORDER BY orderdate ASC, orderid ASC
    OFFSET 0 ROWS FETCH FIRST 25 ROWS ONLY; -- next and first are interchangeable

SELECT
    orderid
    ,orderdate
    ,custid
    ,empid
FROM Sales.Orders
ORDER BY orderdate ASC, orderid ASC
    OFFSET 1 ROW FETCH NEXT 1 ROW ONLY; -- row and rows are interchangeable

SELECT
    orderid
    ,orderdate
    ,custid
    ,empid
FROM Sales.Orders
ORDER BY orderdate ASC, orderid ASC
    OFFSET 50 ROWS; -- offset will work by itself, fetch will not


-- ROW_NUMBER Window Function
-- Window Functions are explained thouroughly in Ch 7
SELECT
    orderid
    ,custid
    ,val 
    ,ROW_NUMBER () OVER (ORDER BY custid ASC, val ASC) AS RowNum -- orders the window
FROM Sales.OrderValues
ORDER BY custid ASC, val ASC; -- order for presentation (same ordering properties in this case)

SELECT
    orderid
    ,custid
    ,val 
    ,ROW_NUMBER () OVER (PARTITION BY custid ORDER BY val ASC) AS RowNum -- partitions and orders the window
FROM Sales.OrderValues
ORDER BY custid ASC, val ASC; -- each partition (custid) returns a group of row nums which are unnique to each cust
-- above two query is still non-deterministic due to the ordering property in the window not being unique
-- we can add a tiebreaker to the window to make the query deterministic

SELECT
    orderid
    ,custid
    ,val 
    ,ROW_NUMBER () OVER (PARTITION BY custid ORDER BY custid ASC, val ASC) AS RowNum
FROM Sales.OrderValues
ORDER BY custid ASC, val ASC;


------------------------------
-- PREDICATES AND OPERATORS --
------------------------------

-- IN Predicate
SELECT
    orderid
    ,empid
    ,orderdate
FROM Sales.Orders
WHERE orderid IN (10248, 10249, 10250);


-- BETWEEN Predicate (same result as above query)
SELECT 
    orderid
    ,empid
    ,orderdate
FROM Sales.Orders 
WHERE orderid BETWEEN 10248 AND 10250; -- inclusive


-- Comparison Operators
SELECT 
    orderid
    ,empid
    ,orderdate
FROM Sales.Orders 
WHERE orderdate >= '2016-01-01';

-- Comparison and Logical Operators
SELECT 
    orderid
    ,empid
    ,orderdate
FROM Sales.Orders
WHERE 
    orderdate >= '2016-01-01' 
    AND empid IN (1, 3, 5);

-- Comparison and Logical Operators
SELECT 
    orderid
    ,empid
    ,orderdate
FROM Sales.Orders
WHERE 
    orderdate >= '2016-01-01' 
    AND empid NOT IN (1, 3, 5);


-- Arithmetic
SELECT 
    orderid
    ,productid
    ,qty
    ,unitprice
    ,discount
    ,qty * unitprice * (1 - discount) AS val
FROM Sales.OrderDetails;


-- Precedence (AND has precedence over OR, despite the order query is written)
-- Use PEMDAS to force precedence and improve readability
SELECT 
    orderid
    ,custid
    ,empid
    ,orderdate 
FROM Sales.Orders 
WHERE  
    (custid = 1 AND  empid IN (1, 3, 5)) 
    OR 
    (custid = 85 AND empid IN(2, 4, 6));


-- CASE Expressions
SELECT
    productid
    ,productname
    ,categoryid
    ,CASE categoryid
        WHEN 1 THEN 'Beverages' 
        WHEN 2 THEN 'Condiments' 
        WHEN 3 THEN 'Confections' 
        WHEN 4 THEN 'Dairy Products' 
        WHEN 5 THEN 'Grains/Cereals' 
        WHEN 6 THEN 'Meat/Poultry' 
        WHEN 7 THEN 'Produce' 
        WHEN 8 THEN 'Seafood' 
        ELSE 'Unknown Category' -- Optional, Defaults to ELSE IS NULL
    END AS categoryname
FROM Production.Products; -- Simple CASE expression: Checks for equality

SELECT
    orderid
    ,custid
    ,val
    ,CASE
        WHEN val < 1000.00                      THEN 'Less than 1000'
        WHEN val BETWEEN 1000.00 and 3000.00    THEN 'Between 1000 and 3000'
        WHEN val > 3000.00                      THEN 'More than 3000'
        ELSE 'Unknown'
    END AS valuecategory
FROM Sales.OrderValues; -- Searched CASE expression: Checks for predicate logic


-- ISNULL (Returns first non NULL value, or NULL if there isn't one)
SELECT ISNULL ('Hello', 'World'); -- Returns 'Hello'
SELECT ISNULL (NULL, 'World'); -- Returns 'World'
SELECT ISNULL (NULL, NULL); -- Return NULL (there isn't a non-NULL value)


-- COALESCE (Returns first non NULL value, or NULL if there isn't one)
-- COALESCE is standard and allows more than 2 arguments
SELECT COALESCE ('Hello', NULL, 'World', NULL, NULL); -- Returns 'Hello'
SELECT COALESCE (NULL, NULL, 'Hello', NULL, 'World'); -- Returns 'Hello'
SELECT COALESCE (NULL, NULL, NULL, NULL, NULL_Value); -- Returns NULL


-- IIF (Returns an expression based on a logical test)
SELECT
    orderid
    ,freight
    ,IIF (freight > 10, 'Heavy', 'Standard') AS freight_category
FROM Sales.Orders;


-- Three Value Predicate Logic (True, False, Unknown)
SELECT
    custid
    ,country
    ,region
    ,city
FROM Sales.Customers
WHERE Region = N'WA'; -- Result as expected, returns rows where predicate evaluates to True

SELECT
    custid
    ,country
    ,region
    ,city
FROM Sales.Customers
WHERE Region <> N'WA'; -- Result not always as expected, returns rows where predicate evaluates to True, discarding Unknowns (NULL)

SELECT
    custid
    ,country
    ,region
    ,city
FROM Sales.Customers
WHERE
    Region <> N'WA'
    OR region IS NULL; -- Explicit query and result, returns rows where predicate evaluates to True or Unknown


-- All At Once Operations
/* 
All expressions appearing in the same logical query processing phase are evaluated at the same point in time.
The expressions that appear in the same logical query processing phase are treated as a set, and a set has no order.
To bypass this behavior for filtering, we can use CASE expressions or PEMDAS with logical operators in the WHERE clause.
This forces the processing in a particular phase to occur in a specified order. 
 */


--------------------
-- CHARACTER DATA --
--------------------

 -- Collation Help
 SELECT
    name
    ,description
FROM SYS.FN_HelpCollations();


-- Concatenation with + Operator
SELECT
    empid
    ,firstname
    ,lastname
    ,firstname + N' ' + lastname AS fullname
FROM HR.Employees;


-- Concatenation with + Operator when NULLs Present, and CONCAT Function
SELECT
    custid
    ,country
    ,region
    ,city
    ,country + N', ' + region + N', ' + city AS location -- A single NULL will return NULL for the entire operation
    ,country + COALESCE (N', ' + region, N'') + N', ' + city AS location -- Programatically bypassing NULL behavior
    ,CONCAT (country + N', ', region + N', ', city) AS location -- CONCAT automatically converts NULLs to strings
FROM Sales.Customers;


-- SUBSTRING Function
SELECT
    custid
    ,companyname
    ,SUBSTRING (companyname, 10, 5) AS companysub
    ,SUBSTRING (companyname, 10, LEN (companyname)) AS companysubdynamic
FROM Sales.Customers;


-- LEFT and RIGHT Functions
SELECT
    custid
    ,companyname
    ,RIGHT (companyname, 5) AS companynameshort
    ,LEFT (UPPER (country), 3) AS countryshort -- Passing a function in the column parameter
FROM Sales.Customers;


-- LEN and DATALENGTH Functions
SELECT
    custid
    ,companyname
    ,LEN (companyname) AS companynamelen
    ,DATALENGTH (companyname) AS companynamebytes -- Typically 2x Bytes per Len for UNICODE
FROM Sales.Customers;


-- CHARINDEX and PATINDEX Functions
SELECT
    companyname
    ,CHARINDEX (' ', companyname) AS spaceindex
    ,address
    ,PATINDEX (N'%[0-9]%', address) AS spaceindex
FROM Sales.Customers;


-- REPLACE Function
SELECT
    companyname
    ,REPLACE (companyname, N' ', N'-') AS companyname
FROM Sales.Customers;


-- REPLICATE Function
SELECT REPLICATE ('ABC', 3);

SELECT
    supplierid
    ,REPLICATE ('0', 9) + CAST (supplierid AS VARCHAR (10)) AS supplierid
    ,RIGHT (REPLICATE ('0', 9) + CAST (supplierid AS VARCHAR (10)), 10) AS supplieridreplicate -- Creates a 10 digit ID
    ,FORMAT (supplierid, 'd10') AS supplieridfromat -- Same result, but more expensive
FROM Production.Suppliers;


-- STUFF Function (str, position, delete_len, insert_str)
SELECT STUFF ('axyze', 2, 3, 'bcd')


-- UPPER and LOWER Functions
SELECT
    city 
    ,country
    ,UPPER (city) AS cityupper
    ,LOWER (country) AS countrylower
FROM HR.Employees


-- LTRIM and RTRIM Functions
SELECT
    '     abc     ' AS fieldtotrim
    ,LEN ('     abc     ') AS fulllen
    ,LTRIM (RTRIM ('     abc     ')) AS trimedfield
    ,LEN (LTRIM (RTRIM ('     abc     '))) AS trimlen;


-- COMPRESS and DECOMPRESS Functions
WITH
CTE AS (
    SELECT COMPRESS (N'This is a CV. Imagine a very long CV') AS cvcompressed
)
SELECT
    cvcompressed
    ,CAST (
        DECOMPRESS (cvcompressed) AS NVARCHAR (MAX)
    ) AS cvdecompressed -- 
FROM CTE;


-- STRING_SPLIT Function
SELECT CAST (value as INT) orderid -- table function returns value
FROM STRING_SPLIT ('10248, 10249, 10250', ',') AS S;


-- LIKE Predicate
-- Percent Wildcard
SELECT  
    empid
    ,firstname
    ,lastname
FROM HR.Employees 
WHERE lastname LIKE N'D%'; -- N (NCHAR or NVARCHAR data types), % is a wild card, anything follows

-- Underscore Wildcard
SELECT
    empid
    ,lastname
FROM HR.Employees
WHERE lastname LIKE N'_e%'; -- Returns any lastname with an e for the second character, with any length after the wildcard.

-- [List] Wildcard
SELECT
    empid
    ,lastname
FROM HR.Employees
WHERE lastname LIKE N'[ABCDE]%'; -- Returns any lastname with A, B, or C as a first character, with any length. 

-- [Range] Wildcarad
SELECT
    empid
    ,lastname
FROM HR.Employees
WHERE lastname LIKE N'[A-E]%'; -- Returns any lastname with A, B, C, D, or E as a first character, with any length.

-- [^ List or Range] Wildcard (NOT IN)
SELECT
    empid
    ,lastname
FROM HR.Employees
WHERE lastname LIKE N'[^A-E]%'; -- Returns any last name that does NOT start with A, B, C, D, or E, with and length. 

-- ESCAPE Character
SELECT
    empid
    ,lastname
FROM HR.Employees
WHERE lastname LIKE N'%!_%' ESCAPE '!'; -- Returns any last name with an underscore in the name (zero results)


----------------------
-- DATE & TIME DATA --
----------------------

-- Converting to DATE (Not Recommended)
-- Use language neutral format 'YYYYMMDD' for string representations of dates
SELECT CONVERT (DATE, '02/12/2016', 101); -- YYYY-MM-DD
SELECT CONVERT (DATE, '02/12/2016', 103); -- YYYY-DD-MM


-- CAST (Language Neutral String-Literal)
SELECT CAST ('20160212' AS DATE);


-- Date Filter Functions (Does not maintain index improvements)
SELECT
    orderid
    ,custid
    ,empid
    ,orderdate
FROM Sales.Orders
WHERE YEAR (orderdate) = 2015 AND MONTH (orderdate) = 01;


-- Date Filter Range (Maintains index improvements)
SELECT
    orderid
    ,custid
    ,empid
    ,orderdate
FROM Sales.Orders
WHERE orderdate >= '2016-01-01' AND orderdate < '2016-02-01';


-- Current Date & Time Functions
SELECT 
  GETDATE()             AS [GETDATE]
  ,CURRENT_TIMESTAMP   AS [CURRENT_TIMESTAMP]
  ,GETUTCDATE()        AS [GETUTCDATE]
  ,SYSDATETIME()       AS [SYSDATETIME]
  ,SYSUTCDATETIME()    AS [SYSUTCDATETIME]
  ,SYSDATETIMEOFFSET() AS [SYSDATETIMEOFFSET];


-- System DATETIME (CAST to Date and Time)
SELECT
    CAST (SYSDATETIME() AS DATE) AS [SYSTEMDATE]
    ,CAST (SYSDATETIME() AS TIME) AS [SYSTEMTIME];


-- TRY Returns NULL if Input Isn't Convertible)
-- TRY_CAST
SELECT
    TRY_CAST ('20160212' AS DATE) AS [DATE]
    ,TRY_CAST (SYSDATETIME() AS DATE) AS [DATE]
    ,TRY_CAST (SYSDATETIME() AS TIME) AS [TIME];


-- TRY_CONVERT
SELECT
    TRY_CONVERT (CHAR(8), CURRENT_TIMESTAMP, 112) AS [DATE]
    ,TRY_CONVERT (CHAR(12), CURRENT_TIMESTAMP, 114) AS [TIME];


-- DATEADD
SELECT 
    DATEADD (YEAR, 1, '20160212') AS [DATETIME]
    ,DATEADD (MONTH, 3, '2016-02-01') AS [DATETIME]
    ,DATEADD (MONTH, -1, CAST ('2016-02-01' AS DATE)) AS [DATE];


-- DATEDIFF and DATEDIFF_BIG
SELECT
    DATEDIFF (DAY, '2016-01-01', '2016-12-31') AS DayDiff
    ,DATEDIFF (MONTH, '2016-01-01', '2016-12-31') AS MonthDiff;


-- DATEPART
SELECT
    DATEPART (MONTH, '2016-01-01') AS MonthPart
    ,DATEPART (YEAR, '2016-01-01') AS YearPart;


-- YEAR, MONTH, DAY
SELECT 
  DAY ('20160212') AS TheDay
  ,MONTH ('20160212') AS TheMonth 
  ,YEAR ('20160212') AS TheYear;


-- DATENAME
SELECT
   DATENAME(MONTH, '2016-01-01') AS MonthName -- Returns January
   ,DATENAME(YEAR, '2016-01-01') AS YearName; -- Returns 2016 as a string (year does not have a name)


-- ISDATE
SELECT ISDATE('20160212'); -- Returns 1 (Yes)
SELECT ISDATE('20160230'); -- Returns 0 (No)
SELECT ISDATE('TEST'); -- Returns 0 (No)


-- FROMPARTS Functions
SELECT 
  DATEFROMPARTS(2016, 02, 12) AS [DATE] -- Returns 2016-02-12
  ,DATETIME2FROMPARTS(2016, 02, 12, 13, 30, 5, 1, 7) AS [DATETIME] -- Returns 2016-02-12 13:30:05.0000001
  ,DATETIMEFROMPARTS(2016, 02, 12, 13, 30, 5, 997) AS [DATETIME] -- Returns 2016-02-12 13:30:05.997
  ,DATETIMEOFFSETFROMPARTS(2016, 02, 12, 13, 30, 5, 1, -8, 0, 7) AS [DATETIME] -- Returns 2016-02-12 13:30:05.0000001 -08:00
  ,SMALLDATETIMEFROMPARTS(2016, 02, 12, 13, 30) AS [DATETIME] -- Returns 2016-02-12 13:30:00
  ,TIMEFROMPARTS(13, 30, 5, 1, 7) AS [DATETIME]; -- Returns 13:30:05.0000001


-- EOMONTH Function
SELECT
    EOMONTH('2016-01-01') AS [DATE] -- Returns 2016-01-31
    ,EOMONTH('2016-01-01', 3) AS [DATE]; -- Returns 2016-04-30

SELECT
    orderid
    ,orderdate
    ,custid
    ,empid
FROM Sales.Orders
WHERE orderdate = EOMONTH (orderdate); -- Returns all orders placed on the last day of the month


-----------------------
-- QUERYING METADATA --
-----------------------

-- CATALOG VIEWS
-- Return Schema and Table Names
SELECT
    SCHEMA_NAME(schema_id) AS schema_name
    ,Name AS table_name
FROM sys.tables
ORDER BY schema_name, table_name;


-- Return Column Information for a Specified Table
SELECT
  Name AS column_name
  ,TYPE_NAME(system_type_id) AS column_type
  ,max_length
  ,collation_name
  ,is_nullable
FROM sys.columns
WHERE object_id = OBJECT_ID(N'SchemaName.TableName');

SELECT
  ', SUM (' + Name + ') AS ' + Name AS column_name
FROM sys.columns
WHERE object_id = OBJECT_ID(N'CL.VW_AppointmentEvent');


-- INFORMATION SCHEMA VIEWS 
-- SAME RESULTS AS CATALOG VIEWS

-- Return Schema and Table Names
SELECT
    TABLE_SCHEMA
    ,TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = N'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;


-- Return Column Information for a Specified Table
SELECT
    COLUMN_NAME
    ,DATA_TYPE
    ,CHARACTER_MAXIMUM_LENGTH
    ,COLLATION_NAME
    ,IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_SCHEMA = N'SchemaName'
    AND TABLE_NAME = N'TableName';


-- SYSTEM STORED PROCEDURES 
-- Return Objects That Can be Queried (Tables and Views)
EXEC sys.sp_tables;


-- Return Detailed Specified Object Information
EXEC sys.sp_help
    @objname = N'SchemaName.TableName';


-- Return Column Information for a Specified Object
EXEC sys.sp_columns
    @table_owner = N'SchemaName', -- Schema
    @table_name = N'TableName';


-- Return Constraint Information for a Specified Object
EXEC sys.sp_helpconstraint
    @objname = N'SchemaName.TableName';


-- Query system w/ DDM functions
SELECT
    c.name 
    ,t.name 
    ,c.is_masked 
    ,c.masking_function
FROM sys.masked_columns AS C
    INNER JOIN sys.tables AS T
        ON c.object_id = t.object_id;


-- SYSTEM FUNCTIONS
-- Return Instance Product Level
SELECT SERVERPROPERTY('ProductLevel') AS product_level;


-- Return Specified Property of Database
SELECT DATABASEPROPERTYEX(N'DatabaseName', 'Collation');


-- Return Specified Property for Specified Object
-- OBJECTPROPERTY Function Requires OBJECT_ID (Use OBJECT_ID Function to Get ID)
SELECT OBJECTPROPERTY(OBJECT_ID(N'SchemaName.TableName'), 'TableHasPrimaryKey') AS object_property;


-- Return Specified Property for Specified Column
-- OBJECTPROPERTY Function Requires OBJECT_ID (Use OBJECT_ID Function to Get ID)
SELECT COLUMNPROPERTY(OBJECT_ID(N'SchemaName.TableName'), N'ColumnName', 'AllowsNull') AS column_property;