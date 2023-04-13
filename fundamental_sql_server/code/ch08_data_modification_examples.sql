----------------------------------
-- Chapter 8: Data Modification --
----------------------------------
USE tsql_fundamentals;


--------------------
-- INSERTING DATA --
--------------------

-- Create Demo Tables
DROP TABLE IF EXISTS dbo.Orders
GO

CREATE TABLE dbo.Orders (
    orderid     INT         NOT NULL    CONSTRAINT PK_Orders     PRIMARY KEY
    ,orderdate  DATE        NOT NULL    CONSTRAINT DFT_orderdate DEFAULT (SYSDATETIME())
    ,empid      INT         NOT NULL
    ,custid     VARCHAR(10) NOT NULL
);

TRUNCATE TABLE dbo.Orders;
SELECT * FROM dbo.Orders;


-- Insert Single Row
INSERT INTO dbo.Orders (orderid, orderdate, empid, custid)
VALUES
    (10001, '20160212', 3, 'A');


-- Insert Single Row w/ Default
INSERT INTO dbo.Orders (orderid, empid, custid)
VALUES
    (10002, 5, 'B');


-- Insert Multiple Rows
INSERT INTO dbo.Orders (orderid, orderdate, empid, custid)
VALUES
    (10003, '20160213', 4, 'B')
    ,(10004, '20160214', 1, 'A')
    ,(10005, '20160213', 1, 'C')
    ,(10006, '20160215', 3, 'C');

-- VALUES As A Table-Value Constructor
SELECT *
FROM (
    VALUES
        (10003, '20160213', 4, 'B')
        ,(10004, '20160214', 1, 'A')
        ,(10005, '20160213', 1, 'C')
        ,(10006, '20160215', 3, 'C')
) AS Orders (orderid, orderdate, empid, custid);


-- INSERT SELECT Statement
INSERT INTO dbo.Orders (orderid, orderdate, empid, custid)
    SELECT
        orderid
        ,orderdate
        ,empid
        ,custid
    FROM Sales.Orders
    WHERE shipcountry = N'UK';


-- INSERT EXEC Statement
-- Create Demo Stored Proc
DROP PROCEDURE IF EXISTS Sales.GetOrders
GO

CREATE PROCEDURE Sales.GetOrders
    @country AS NVARCHAR(40)
AS

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE shipcountry = @country
GO

EXEC Sales.GetOrders
    @country = N'France';

-- INSERT EXEC
INSERT INTO dbo.Orders (orderid, orderdate, empid, custid)
    EXEC Sales.GetOrders
        @country = N'France';


-- SELECT INTO Statement
DROP TABLE IF EXISTS dbo.Orders
GO

SELECT orderid, orderdate, empid, custid
INTO dbo.Orders -- Must be a new table
FROM Sales.Orders;


-- SELECT INTO w/ EXCEPT
DROP TABLE IF EXISTS dbo.Locations
GO

SELECT country, region, city
INTO dbo.Locations
FROM Sales.Customers

EXCEPT

SELECT country, region, city
FROM HR.Employees; -- Excludes employee locations

SELECT * FROM dbo.Locations;


-- BULK INSERT Statement
TRUNCATE TABLE dbo.Orders;

BULK INSERT dbo.Orders FROM 'file_path'
    WITH (
        DATAFILETYPE = 'char'
        ,FIELDTERMINATOR = ','
        ,ROWTERMINATOR = '\n'
    );

SELECT * FROM dbo.Orders;

-----------------------
-- IDENTITY PROPERTY --
-----------------------

DROP TABLE IF EXISTS dbo.T1
GO

CREATE TABLE dbo.T1 (
    keycol      INT         NOT NULL IDENTITY (1,1) CONSTRAINT PK_T1 PRIMARY KEY
    ,datacol    VARCHAR(10) NOT NULL CONSTRAINT CHK_T1_datacol CHECK (datacol LIKE '[A-Z]%')
);

INSERT INTO dbo.T1 (datacol) -- Ignore identity column (automatically populated based on arguments
    VALUES ('AAA'), ('BBB'), ('CCC');

SELECT * FROM dbo.T1;
SELECT keycol, $identity FROM dbo.T1; -- Same Same


-- IDENT_CURRENT Function (Return Current Identity Value)
SELECT IDENT_CURRENT (N'dbo.T1') AS curridentity;


-- Insert Failure > Identity Col Still Increases
INSERT INTO dbo.T1 (datacol) VALUES ('123'); -- Fails due to check constraint
INSERT INTO dbo.T1 (datacol) VALUES ('DDD'); -- Succeeds
SELECT * FROM dbo.T1; -- Notice Identity skip


--------------
-- SEQUENCE --
--------------

CREATE SEQUENCE dbo.SeqOrderIDs AS INT
    MINVALUE 1
    INCREMENT BY 1
    CYCLE;

SELECT NEXT VALUE FOR dbo.SeqOrderIDs;
SELECT NEXT VALUE FOR dbo.SeqOrderIDs;
SELECT NEXT VALUE FOR dbo.SeqOrderIDs;

SELECT current_value
FROM sys.sequences
WHERE OBJECT_ID = OBJECT_ID(N'dbo.SeqOrderIDs');