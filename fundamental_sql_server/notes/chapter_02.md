# Ch 2: Single Table Queries

##### Elements of the SELECT Statement
- Syntax Order
	- SELECT
	- FROM
	- WHERE
	- GROUP BY
	- HAVING
	- ORDER BY

- Processing Order
	- FROM
	- WHERE
	- GROUP BY
	- HAVING
	- SELECT
	- ORDER BY

> Clause: Syntactical component of a query (Ex: In the WHERE clause, we specify a predicate)
> 
> Phase: Logical manipulation taking place as part of a query (Ex: The WHERE phase returns rows for which the predicate evaluates to TRUE)

##### The FROM Clause
- Specify table names and table aliases (if needed)
- Regular identifiers (table and column names) that comply with formatting rules do not need to be delimited
- Irregular identifiers must be surrounded by " ", ' ', or [ ]
- To return all rows from a table with no special manipulation, all we need is a query with a FROM clause specifying a table, and a SELECT clause specifying the attributes (columns) we want to return

``` SQL
FROM Sales.Orders

OrderDetails -- regular
'Order Details' -- irregular
[Order Details] -- irregular


SELECT
    orderid, 
    custid, 
    empid, 
    orderdate, 
    freight
FROM Sales.Orders;
```

##### The WHERE Clause
- Predicates or logical expressions are specified in the WHERE clause
- Rows for which the logical expression evaluates to TRUE are returned, while FALSE and UNKOWN are discarded
- Filtering queries reduces network traffic created by returning all rows

``` SQL
SELECT 
    orderid, 
    custid, 
    empid, 
    orderdate, 
    freight 
FROM Sales.Orders
WHERE custid = 71;
```

##### The GROUP BY Clause
- Arranges rows returned by the previous logical processing phases into groups, determined by elements specified in the clause
- All phases subsequent to the GROUP BY phase (including HAVING, SELECT and ORDER BY) must operate on groups
- Each group is represented by a single row (scalar value) in the final result
- Elements that are not in the GROUP BY clause must be inputted as aggregate functions in the SELECT statement
- Note that all aggregate functions except for COUNT(\*) ignores NULLs

``` SQL
SELECT
  empid, 
  YEAR(orderdate) AS orderyear, 
  SUM(freight) AS totalfreight, 
  COUNT(*) AS numorders 
FROM Sales.Orders 
WHERE custid = 71 
GROUP BY empid, YEAR(orderdate);
```

##### The HAVING Clause
- Group specific filter that filters elements in the GROUP BY clause
- Only groups for which the HAVING predicates evaluate to TRUE are returned, while FALSE and UNKNOWN are discarded
- Because the HAVING clause is processed after the GROUP BY clause, you can refer to aggregate functions in the logical expression

``` SQL
SELECT
    empid, 
    YEAR(orderdate) AS orderyear,
    COUNT(*) AS numorders 
FROM Sales.Orders 
WHERE custid = 71 
GROUP BY empid, YEAR(orderdate) 
HAVING COUNT(*) > 1;
-- Returns employees who sold more than one order to customer 71, grouped by employee and year.
```

##### The SELECT Clause
- The SELECT clause is where attributes (columns) are specified
- Expressions with no manipulations default to the source attribute name, while expressions with manipulations need to be aliased in order to return a column name
- Since the SELECT clause is processed after the FROM, WHERE, GROUP BY, and HAVING clauses, aliases assigned in the SELECT statement cannot be referenced in those clauses
- The DISTINCT clause can be used in the SELECT statement to remove duplicate rows
- SQL allows specifying an asterisk (\*) in the SELECT list instead of specific attributes, returning all attributes in the specified table. This is considered bad programming practice in most cases, and individual attributes should be listed in the order in which you want them returned in the result set.

``` SQL
SELECT * 
FROM Sales.Orders;

SELECT O.*
FROM Sales.Orders AS O;


SELECT
    orderid,
    SUM(freight) AS totalfreight -- aliased column
FROM Sales.Orders
GROUP BY orderid;

SELECT DISTINCT 
    empid, 
    YEAR(orderdate) AS orderyear 
FROM Sales.Orders 
WHERE custid = 71;
```

##### The ORDER BY Clause
- Used to sort the rows in the output for presentation purposes
- Without an ORDER BY clause, a query result has no guaranteed order
- Since the ORDER BY phase is processed after the SELECT phase where column aliases are defined, you can refer to the aliases
- Ascending order is the default, but you can specify sort order by adding ASC or DESC to the statement (it is considered best practice to specify ASC even though that is the default)
- You can specify elements in the ORDER BY clause that do not appear in the SELECT clause, unless a DISTINCT clause is specified. 

``` SQL
SELECT 
    empid, 
    YEAR(orderdate) AS orderyear, 
    COUNT(*) AS numorders 
FROM Sales.Orders 
WHERE custid = 71 
GROUP BY empid, YEAR(orderdate) 
HAVING COUNT(*) > 1 
ORDER BY empid ASC, orderyear DESC;
```

##### The TOP Filter
- T-SQL feature that limits the number or percentage of rows returned by the query
- It relies on two elements;
	- The number or percent of rows to return
	- A sort order specified in the ORDER BY clause (optional)
- When percent is used, the number of rows returned is calculated based on a percentage of the number of qualifying rows, rounded up
- If DISTINCT is specified in the SELECT statement, the TOP filter is evaluated after duplicate rows have been removed.
- The WITH TIES expression can be added to the TOP filter to return rows with the same sort value. 

``` SQL
SELECT TOP (5)
    orderid,
    orderdate,
    custid,
    empid
FROM Sales.Orders
ORDER BY orderdate DESC; -- returns 5 rows

SELECT TOP (5) WITH TIES 
    orderid, 
    orderdate, 
    custid, 
    empid 
FROM Sales.Orders 
ORDER BY orderdate DESC; -- returns 8 rows due to duplicate orderdate results

SELECT TOP (100) *
FROM Sales.Orders; -- this query can be used to explore the table without pulling all rows

SELECT TOP (1) PERCENT
    orderid,
    orderdate,
    custid,
    empid
FROM Sales.Orders
ORDER BY orderdate DESC; -- returns the first 1% of records
```

##### The OFFSET-FETCH Filter
- The OFFSET-FETCH filter supports a skipping option, making it useful for ad-hoc paging purposes
- This filter is considered an extension to the ORDER BY clause.
- The OFFSET clause indicated how many rows to skip, and the FETCH clause indicates how many rows to return after the skipped rows
- The OFFSET-FETCH filter must have an ORDER BY clause
- The FETCH clause must be combined with the OFFSET clause. If you do not want to skip any rows, you can specify this with OFFSET 0 ROWS.
- OFFSET without FETCH is allowed, and will return all remaining rows in the result after the query skips the indicated number of rows in the OFFSET clause

``` SQL
SELECT 
    orderid, 
    orderdate, 
    custid, 
    empid 
FROM Sales.Orders 
ORDER BY orderdate ASC, orderid ASC
	OFFSET 50 ROWS FETCH NEXT 25 ROWS ONLY;
```

##### Predicates and Operators
- Predicates are logical expressions that evaluate to TRUE, FALSE, or UNKNOWN
	- IN: Checks whether a value is equal to at least one of the elements in a specified set
	- BETWEEN: Checks whether a value is in a specified range, inclusive of the specified delimiters
	- LIKE: Checks whether a character string meets a specified pattern
- Predicates can be combined with logical operators such as AND, OR, NOT
- Standard comparison operators include: = , > , < , >= , <= , <> (not equal)
- Standard arithmetic operators include: + , - , * , / , % (modulo)
- Standard null predicates include: IS NULL and IS NOT NULL
- When multiple operators appear in the same expression, SQL evaluates based on order of precedence (PEMDAS)
	- Parenthesis (Give you full control over precedence)
	- Multiplication, Division, Modulo
	- Positive, Negative, Addition, Concatenation, Subtraction
	- Comparison Operators
	- NOT
	- AND
	- BETWEEN, IN, LIKE, OR
	- Assignment ( = )

``` SQL
-- Predicates
SELECT 
    orderid, 
    empid, 
    orderdate
FROM Sales.Orders
WHERE orderid IN(10248, 10249, 10250);

-- Predicates and Logical Operators
SELECT 
    orderid, 
    empid, 
    orderdate
FROM Sales.Orders 
WHERE orderid BETWEEN 10300 AND 10310; -- inclusive

SELECT  
    empid, 
    firstname, 
    lastname
FROM HR.Employees 
WHERE lastname LIKE N'D%'; -- N (NCHAR or NVARCHAR data types), % is a wild card, anything follows

-- Comparison Operators
SELECT 
    orderid, 
    empid, 
    orderdate
FROM Sales.Orders 
WHERE orderdate >= 2016-01-01;

-- Predicates and Comparison Operators
SELECT 
    orderid, 
    empid, 
    orderdate
FROM Sales.Orders
WHERE orderdate >= '2016-01-01' AND empid IN (1, 3, 5);

-- Arithmetic
SELECT 
    orderid, 
    productid, 
    qty, 
    unitprice, 
    discount, 
    qty * unitprice * (1 - discount) AS val
FROM Sales.OrderDetails;

-- Precedence (AND has precedence over OR, despite the order query is written
SELECT 
    orderid, 
    custid, 
    empid, 
    orderdate 
FROM Sales.Orders 
WHERE  
    custid = 1 AND 
    empid IN(1, 3, 5) OR  
    custid = 85 AND 
    empid IN(2, 4, 6);
```

##### CASE Expressions
- Scalar expression that returns a value based on conditional logic
- Allowed in the SELECT, WHERE, HAVING, and ORDER BY clauses
- Two forms of CASE expressions are simple and searched
	- Use simple to compare one value or scalar expression with a list of possible values and return a value for the first match
	- Use searched when you need to specify predicates in the WHEN clause rather than being restricted to using equality comparisons
		- Returns the value in the THEN clause that is associated with the first WHEN predicate that evaluates to TRUE
- Functions that act as abbreviates CASE expressions include: ISNULL and COALESCE (standard)
	- ISNULL accepts two arguments as input and returns the first value that is not NULL, or NULL if both are NULL
	- COALESCE accepts two or more arguments as input and returns the first value that is not NULL (at least one of the arguments must be NOT NULL)

``` SQL
-- Simple
SELECT
    productid,
    productname,
    categoryid,
    CASE categoryid
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
FROM Production.Products;

-- Searched (More Flexibility)
SELECT
    orderid,
    custid,
    val,
    CASE
        WHEN val < 1000.00 THEN 'Less than 1000'
        WHEN val BETWEEN 1000.00 and 3000.00 THEN 'Between 1000 and 3000'
        WHEN val > 3000.00 THEN 'More than 3000'
        ELSE 'Unknown' -- Optional, Defaults to ELSE IS NULL
    END AS valuecategory
FROM Sales.OrderValues;
-- These queries are for illustration purposes. In these specific cases, the category names would be stored in a seperate table that can be joined. 

-- ISNULL (Returns first non NULL value)
SELECT ISNULL('Hello', 'World'); -- Returns 'Hello'
SELECT ISNULL(NULL, 'World'); -- Returns 'World'
SELECT ISNULL(NULL, NULL); -- Return NULL (there isn't a non-NULL value)


-- COALESCE (Returns first non NULL value)
SELECT COALESCE('Hello', NULL, 'World', NULL, NULL); -- Returns 'Hello'
SELECT COALESCE(NULL, NULL, 'Hello', NULL, 'World'); -- Returns 'Hello'
```

##### Character Data Types
- SQL Server supports two kinds of character data types: 
	- Regular data types include CHAR and VARCHAR (1 byte per character)
	- Unicode data types include NCHAR and NVARCHAR (4 bytes per character)
		- When expressing a Unicode character literal, the character N (for National) is prefixed before the string
	- Data types without the VAR element in its name (CHAR, NCHAR) have a fixed length
	- Data types with the VAR element in its name (VARCHAR, NVARCHAR) have a variable length
		- SQL Server will use as much storage space as needed in the row
- Single quotes are used to delimit character strings
- Double quotes (or square brackets) are used to delimit irregular identifiers such as table or column names

##### Functions
- Common T-SQL functions;

``` SQL
CONCAT(StringValue1, StringValue2, StringValueN)

SUBSTRING(String, Start, Length)

LEFT(String, N), RIGHT(String, N) -- N is the number of characters to extract from the left or right end of the supplied string

LEN(String)

DATALENGTH(Expression)

REPLACE(String, Substring1, Substring2) -- Replaces all occurences of Substring1 with Substring2

REPLICATE(String, N) -- N is the number of times the string is replicated

UPPER(String), LOWER(String)

LTRIM(String), RTRIM(String) -- Removes leading or trailing spaces

FORMAT(Value, Format, Culture)
```

##### The LIKE Predicate
- Checks whether a character string matches a specified pattern, supported by wildcard characters
	- The percent wildcard represents a string of any size, including an empty string
	- The underscore wildcard represents a single character
	- The \[List] wildcard represents a single character that must be one of the specified characters in the list
	- The \[Range] wildcard represents a single character that must be within the specified range
	- The \[^List or Range] wildcard represents a single character that is NOT within the specified list or range 

``` SQL
-- Percent Wildcard
SELECT
    empid,
    lastname
FROM HR.Employees
WHERE lastname LIKE N'D%'; -- Returns any lastname starts with D, with any length. 

-- Underscore Wildcard
SELECT
    empid,
    lastname
FROM HR.Employees
WHERE lastname LIKE N'_e%'; -- Returns any lastname with an e for the second character, with any length after the wildcard.

-- [List] Wildcard
SELECT
    empid,
    lastname
FROM HR.Employees
WHERE lastname LIKE N'[ABC]%'; -- Returns any lastname with A, B, or C as a first character, with any length. 

-- [Range] Wildcarad
SELECT
    empid,
    lastname
FROM HR.Employees
WHERE lastname LIKE N'[A-E]%'; -- Returns any lastname with A, B, C, D, or E as a first character, with any length.

-- [^ List or Range] Wildcard
SELECT
    empid,
    lastname
FROM HR.Employees
WHERE lastname LIKE N'[^A-E]%'; -- Returns any last name that does NOT start with A, B, C, D, or E, with and length. 
```

##### The ESCAPE Character
- If you want to search for a character that is also used as a wildcard  (such as %, _ , \[ \]), you can use as escape character
- Specify a character that would not appear in the data as the escape character in front of the character you are searching for
- Specify the keyword ESCAPE followed by the escape character immediately after the patters

``` SQL
SELECT
    empid,
    lastname
FROM HR.Employees
WHERE lastname LIKE N'%!_%' ESCAPE '!'; -- Returns any last name with an underscore in the name (zero results)
```

##### Date & Time Data Types
- T-SQL supports six data and time data types
- DATETIME and SMALLDATETIME are legacy types
- DATE, TIME, DATETIME2, and DATETIMEOFFSET are later additions
- These types differ in storage requirements, supported date range, and precision
- https://docs.microsoft.com/en-us/sql/t-sql/functions/date-and-time-data-types-and-functions-transact-sql?view=sql-server-ver16

##### Converting to Date
- Used to express dates in language-dependent formats 
- The CONVERT function converts a character-string literal to a requested data type, with a specified styling number
- https://docs.microsoft.com/en-us/sql/t-sql/functions/cast-and-convert-transact-sql?view=sql-server-ver15

``` SQL
SELECT CONVERT(DATE, '02/12/2016', 101); -- YYYY-MM-DD
-- Returns 2016-02-12

SELECT CONVERT(DATE, '02/12/2016', 103); -- YYYY-DD-MM
-- Returns 2016-12-02
```

##### Filtering Date Ranges
- Filtering date ranges such as a whole year or month can be done with functions such as YEAR and MONTH
	- This eliminates the possibility of using efficient indexing 
- Alternatively, range filtering can be used to maintain index possibilities
``` SQL
-- Date Filter Functions
SELECT
    orderid,
    custid,
    empid,
    orderdate
FROM Sales.Orders
WHERE YEAR(orderdate) = 2015 AND MONTH(orderdate) = 01; -- Returns all orders from Jan 2016

-- Date Filter Range
SELECT
    orderid,
    custid,
    empid,    
    orderdate
FROM Sales.Orders
WHERE orderdate >= '2016-01-01' AND orderdate < '2016-02-01'; -- Returns all orders from Jan 2016
```

##### Current Date & Time Functions
- https://docs.microsoft.com/en-us/sql/t-sql/functions/date-and-time-data-types-and-functions-transact-sql?view=sql-server-ver16

``` SQL
SELECT 
  GETDATE()           AS [GETDATE], 
  CURRENT_TIMESTAMP   AS [CURRENT_TIMESTAMP], 
  GETUTCDATE()        AS [GETUTCDATE], 
  SYSDATETIME()       AS [SYSDATETIME], 
  SYSUTCDATETIME()    AS [SYSUTCDATETIME], 
  SYSDATETIMEOFFSET() AS [SYSDATETIMEOFFSET];
```

##### CAST, CONVERT, and PARSE Functions with TRY Counterparts
- Used to convert an input value to some type target type, returning a converted value if the conversion succeed and an error if it does not
- Each function has a TRY counterpart, that returns a NULL instead of an error in the case where a conversion fails (best practice)
- CAST is standard, while CONVERT and PARSE are not
	- PARSE is more expensive than CONVERT so it will not be covered
- It is recommended to use CAST unless style numbers or culture are needed
- Syntax:
	- CAST(value AS datatype)
	- TRY_CAST(value AS data type)
	- CONVERT (data type, value, style number)
	- TRY_CONVERT (data type, value, style number)

``` SQL
-- CAST
SELECT TRY_CAST('20160212' AS DATE); -- Returns 2016-02-12

SELECT TRY_CAST(SYSDATETIME() AS DATE); -- Returns YYYY-MM-DD

SELECT TRY_CAST(SYSDATETIME() AS TIME); -- Returns hh:mm:ss:nnnnnnn

-- CONVERT
SELECT TRY_CONVERT(CHAR(8), CURRENT_TIMESTAMP, 112); -- Returns a string 'YYYYMMDD'

SELECT TRY_CONVERT(CHAR(12), CURRENT_TIMESTAMP, 114); -- Returns a string 'hh:mm:ss:nnnnnnn'
```

##### The DATEADD Function
- Adds a specified number of units of a specified date part to an input date and time value
- Syntax: DATEADD(part, n, value)
- Valid values for part include;
	- YEAR
	- QUARTER
	- MONTH
	- DAYOFYEAR
	- DAY
	- WEEK
	- WEEKDAY
	- HOUR
	- MINUTE
	- SECOND
	- MILLISECOND
	- MICROSECOND
	- NANOSECOND
- The return type for a date and time input is the same as the input type
- If the function is given a string literal as input, the output is DATETIME

``` SQL
SELECT DATEADD(YEAR, 1, '20160212'); -- Returns 2017-02-12 00:00:00.000

SELECT DATEADD(MONTH, 3, '2016-02-01'); -- Returns 2016-05-01 00:00:00.000

SELECT DATEADD(MONTH, -1, CAST('2016-02-1' AS DATE)); -- Returns 2016-01-01
```

##### The DATEDIFF and DATEDIFF_BIG Functions
- Return the difference between two date and time values in terms of a specified date part
- DATEDIFF returns a INT value (4-byte integer), while DATEDIFF_BIG returns a BIGINT value(8-byte integer)
- Syntax:
	- DATEDIFF(part, dt_val1, dt_val2)
	- DATEDIFF_BIG(part, dt_val1, dt_val2)
- Valid values for part are the same for the DATEADD function above

``` SQL
SELECT DATEDIFF(DAY, '2016-01-01', '2016-12-31'); -- Returns 365

SELECT DATEDIFF(MONTH, '2016-01-01', '2016-12-31'); -- Returns 11
```

##### The DATEPART Function
- Returns an integer representing a requested part of a date and time value
- Syntax: DATEPART(part, dt_val)
- Valid values for part are the same for the DATEADD functions above, but also include:
	- TZoffset
	- ISO_WEEK

``` SQL
SELECT DATEPART(MONTH, '2016-01-01'); -- Returns 1 for January

SELECT DATEPART(YEAR, '2016-01-01'); -- Returns 2016
```

##### The YEAR, MONTH, and DAY Functions
- Abbreviations of the DATEPART function, returning an integer representation of the year, month, and day parts of an input date and time value
- Syntax:
	- YEAR(dt_val)
	- MONTH(dt_val)
	- DAY(dt_val)

``` SQL
SELECT 
  DAY('20160212') AS TheDay, 
  MONTH('20160212') AS TheMonth, 
  YEAR('20160212') AS TheYear;
```

##### The DATENAME Function
- Returns a character string representing a part of a date and time value
- Similar to DATEPART with the same part input options, returning a name where relevant (if the part requested does not have a name, the function returns a numeric value)
- Syntax: DATENAME(dt_val, part)

``` SQL
SELECT DATENAME(MONTH, '2016-01-01'); -- Returns January

SELECT DATENAME(YEAR, '2016-01-01'); -- Returns 2016 (year does not have a name)
```

##### THE ISDATE Function
- Accepts a character string as an argument, and returns 1 if it is convertible to a date and time data type, or 0 if it isn't
- Syntax: ISDATE(string)

``` SQL
SELECT ISDATE('20160212'); -- Returns 1 (Yes)

SELECT ISDATE('20160230'); -- Returns 0 (No)

SELECT ISDATE('TEST'); -- Returns 0 (No)
```

##### The FROMPARTS Function
- Accepts integer inputs representing parts of a date and time value and constructs a value of the requested type from those parts
- Syntax:
	- DATEFROMPARTS (year, month, day)
	- DATETIME2FROMPARTS (year, month, day, hour, minute, seconds, fractions, precision)
	- DATETIMEFROMPARTS (year, month, day, hour, minute, seconds, milliseconds)
	- DATETIMEOFFSETFROMPARTS (year, month, day, hour, minute, seconds, fractions, hour_offset, minute_offset, precision)
	- SMALLDATETIMEFROMPARTS (year, month, day, hour, minute)
	- TIMEFROMPARTS (hour, minute, seconds, fractions, precision)

``` SQL
SELECT 
  DATEFROMPARTS(2016, 02, 12), -- Returns 2016-02-12
  DATETIME2FROMPARTS(2016, 02, 12, 13, 30, 5, 1, 7), -- Returns 2016-02-12 13:30:05.0000001
  DATETIMEFROMPARTS(2016, 02, 12, 13, 30, 5, 997), -- Returns 2016-02-12 13:30:05.997
  DATETIMEOFFSETFROMPARTS(2016, 02, 12, 13, 30, 5, 1, -8, 0, 7), -- Returns 2016-02-12 13:30:05.0000001 -08:00
  SMALLDATETIMEFROMPARTS(2016, 02, 12, 13, 30), -- Returns 2016-02-12 13:30:00
  TIMEFROMPARTS(13, 30, 5, 1, 7); -- Returns 13:30:05.0000001
```

##### The EOMONTH Function
- Accepts an input date and time value and returns the respective end-of-month date as a DATE typed value
- Supports an optional second argument indicating how many months to add or subtract (negative)
- Syntax: EOMONTH(input, months_to_add)

``` SQL
SELECT EOMONTH('2016-01-01'); -- Returns 2016-01-31

SELECT EOMONTH('2016-01-01', 3); -- Returns 2016-04-30

SELECT
    orderid,
    orderdate,
    custid,
    empid
FROM Sales.Orders
WHERE orderdate = EOMONTH(orderdate); -- Returns all orders placed on the last day of the month
```