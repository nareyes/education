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