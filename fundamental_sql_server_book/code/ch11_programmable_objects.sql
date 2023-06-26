---------------------------------------
-- Chapter 11: Programmable Objects --
--------------------------------------
USE tsql_fundamentals;

---------------
-- VARIABLES --
---------------

-- Declare Variables
DECLARE @i1 AS INT;
    SET @i1 = 10;

DECLARE @i2 AS INT = 10;

SELECT @i1, @i2;


-- Declare Variable w/ Scalar Query
DECLARE @empname AS NVARCHAR(70);
    SET @empname = (
        SELECT firstname + N' ' + lastname
        FROM HR.Employees
        WHERE empid = 3
    );

SELECT @empname as empname;


-- Multiple Assignment w/ SET
DECLARE
    @firstname AS NVARCHAR(20)
    ,@lastname AS NVARCHAR(40);

    SET @firstname = ( 
        SELECT firstname
        FROM HR.Employees
        WHERE empid = 3
    );

    SET @lastname = (
        SELECT lastname
        FROM HR.Employees
        WHERE empid = 3
    );

SELECT @firstname AS firstname, @lastname AS lastname;


-- Multiple Assignments w/ Assignment SELECT Statement
DECLARE
    @firstname AS NVARCHAR(20)
    ,@lastname AS NVARCHAR(40);

SELECT
    @firstname = firstname
    ,@lastname  = lastname
FROM HR.Employees
WHERE empid = 3;

SELECT @firstname AS firstname, @lastname AS lastname;


-------------
-- BATCHES --
-------------

-- Valid batch
PRINT 'First batch';
GO


-- Invalid batch
PRINT 'Second batch';
SELECT custid FROM Sales.Customers;
SELECT orderid FOM Sales.Orders;
GO


-- Valid batch
PRINT 'Third batch';
SELECT empid FROM HR.Employees;


-- Batches and Variables
DECLARE @i AS INT;
SET @i = 10;

PRINT @i;
GO -- Succeeds

PRINT @i; -- Fails


------------------
-- CONTROL FLOW --
------------------

-- Basic Control Flow
IF YEAR(SYSDATETIME()) <> YEAR(DATEADD(day, 1, SYSDATETIME()))
    PRINT 'Today is the last day of the year.';
ELSE
    PRINT 'Today is not the last day of the year.';


-- Nested Control Flow
IF YEAR(SYSDATETIME()) <> YEAR(DATEADD(day, 1, SYSDATETIME()))
    PRINT 'Today is the last day of the year.';
ELSE
    IF MONTH(SYSDATETIME()) <> MONTH(DATEADD(day, 1, SYSDATETIME()))
        PRINT 'Today is the last day of the month but not the last day of the year.';
    ELSE
        PRINT 'Today is not the last day of the month.';


-- Control Flow w/ Statement Blocks
IF DAY(SYSDATETIME()) = 1

	BEGIN
        PRINT 'Today is the first day of the month.';
        PRINT 'Starting first-of-month-day process.';
        /* ... process code goes here ... */
        PRINT 'Finished first-of-month-day database process.';
	END;
	
ELSE
	BEGIN
        PRINT 'Today is not the first day of the month.';
        PRINT 'Starting non-first-of-month-day process.';
        /* ... process code goes here ... */
        PRINT 'Finished non-first-of-month-day process.';
	END;


-- While Loop
DECLARE @i AS INT = 1;
WHILE @i <= 10
BEGIN
	PRINT @i;
	SET @i = @i + 1;
END;


-- While Loop w/ Break
DECLARE @i AS INT = 1;
WHILE @i <= 10
BEGIN
	IF @i = 6 BREAK;
	PRINT @i;
	SET @i = @i + 1;
END;


-- While Loop w/ Continue
DECLARE @i AS INT = 0;
WHILE @i < 10
BEGIN
	SET @i = @i + 1;
	IF @i = 6 CONTINUE;
	PRINT @i;
END;


-- While Loop Example for Numbers Table
SET NOCOUNT ON;

DROP TABLE IF EXISTS dbo.Numbers;

CREATE TABLE dbo.Numbers(n INT NOT NULL PRIMARY KEY);
GO

DECLARE @i AS INT = 1;

WHILE @i <= 1000
BEGIN
	INSERT INTO dbo.Numbers(n) VALUES(@i);
	SET @i = @i + 1;
END;

SELECT * FROM dbo.Numbers;