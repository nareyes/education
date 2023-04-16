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


-------------------
-- DELETING DATA --
-------------------

-- Create Demo Tables
DROP TABLE IF EXISTS dbo.Orders, dbo.Customers
GO

CREATE TABLE dbo.Customers (
    custid        INT          NOT NULL CONSTRAINT PK_Customers PRIMARY KEY(custid)
    ,companyname  NVARCHAR(40) NOT NULL
    ,contactname  NVARCHAR(30) NOT NULL
    ,contacttitle NVARCHAR(30) NOT NULL
    ,address      NVARCHAR(60) NOT NULL
    ,city         NVARCHAR(15) NOT NULL
    ,region       NVARCHAR(15) NULL
    ,postalcode   NVARCHAR(10) NULL
    ,country      NVARCHAR(15) NOT NULL
    ,phone        NVARCHAR(24) NOT NULL
    ,fax          NVARCHAR(24) NULL
);

CREATE TABLE dbo.Orders (
    orderid         INT          NOT NULL CONSTRAINT PK_Orders PRIMARY KEY(orderid)
    ,custid         INT          NULL     CONSTRAINT FK_Orders_Customers FOREIGN KEY(custid) REFERENCES dbo.Customers(custid)
    ,empid          INT          NOT NULL
    ,orderdate      DATE         NOT NULL
    ,requireddate   DATE         NOT NULL
    ,shippeddate    DATE         NULL
    ,shipperid      INT          NOT NULL
    ,freight        MONEY        NOT NULL CONSTRAINT DFT_Orders_freight DEFAULT(0)
    ,shipname       NVARCHAR(40) NOT NULL
    ,shipaddress    NVARCHAR(60) NOT NULL
    ,shipcity       NVARCHAR(15) NOT NULL
    ,shipregion     NVARCHAR(15) NULL
    ,shippostalcode NVARCHAR(10) NULL
    ,shipcountry    NVARCHAR(15) NOT NULL
);
GO

INSERT INTO dbo.Customers SELECT * FROM Sales.Customers;
INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;


-- DELETE Statement (w/ Optional Filter Predicate)
/* 
DELETE FROM <table_name>
WHERE <filter_predicate>
*/
DELETE FROM dbo.Orders
WHERE orderdate < '20150101' -- Expensive, Fully Logged


-- TRUNCATE Statement (No Filter Predicate, Deletes All Rows)
TRUNCATE TABLE dbo.Orders; -- Inexpensive, Minimally Logged


-- DELETE Based on JOIN (Allows Filtered Attributes From Another Table)
-- Non-Standard
DELETE FROM O
FROM dbo.Orders AS O
    INNER JOIN dbo.Customers AS C
        ON O.custid = C.custid
        WHERE C.country = N'USA';

-- DELETE w/ Subquery (Same Example As Above)
-- Standard
DELETE FROM dbo.Orders
WHERE EXISTS (
    SELECT * FROM dbo.Customers AS C
    WHERE Orders.custid = C.custid
        AND C.country = N'USA'
);


-------------------
-- UPDATING DATA --
-------------------
DROP TABLE IF EXISTS dbo.OrderDetails, dbo.Orders
GO

CREATE TABLE dbo.Orders (
    orderid         INT          NOT NULL CONSTRAINT PK_Orders PRIMARY KEY(orderid)
    ,custid         INT          NULL
    ,empid          INT          NOT NULL
    ,orderdate      DATE         NOT NULL
    ,requireddate   DATE         NOT NULL
    ,shippeddate    DATE         NULL
    ,shipperid      INT          NOT NULL
    ,freight        MONEY        NOT NULL CONSTRAINT DFT_Orders_freight DEFAULT(0)
    ,shipname       NVARCHAR(40) NOT NULL
    ,shipaddress    NVARCHAR(60) NOT NULL
    ,shipcity       NVARCHAR(15) NOT NULL
    ,shipregion     NVARCHAR(15) NULL
    ,shippostalcode NVARCHAR(10) NULL
    ,shipcountry    NVARCHAR(15) NOT NULL
);

CREATE TABLE dbo.OrderDetails (
    orderid   INT           NOT NULL
    ,productid INT           NOT NULL
    ,unitprice MONEY         NOT NULL CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0)
    ,qty       SMALLINT      NOT NULL CONSTRAINT DFT_OrderDetails_qty DEFAULT(1)
    ,discount  NUMERIC(4, 3) NOT NULL CONSTRAINT DFT_OrderDetails_discount DEFAULT(0)

    ,CONSTRAINT PK_OrderDetails         PRIMARY KEY(orderid, productid)
    ,CONSTRAINT FK_OrderDetails_Orders  FOREIGN KEY(orderid) REFERENCES dbo.Orders(orderid)
    ,CONSTRAINT CHK_discount            CHECK (discount BETWEEN 0 AND 1)
    ,CONSTRAINT CHK_qty                 CHECK (qty > 0)
    ,CONSTRAINT CHK_unitprice           CHECK (unitprice >= 0)
);
GO

INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;
INSERT INTO dbo.OrderDetails SELECT * FROM Sales.OrderDetails;


-- UPDATE Statement
/*
UPDATE <table_name>
    SET <condition>
WHERE <filter_predicate>
*/
UPDATE dbo.OrderDetails
    SET discount += 0.05
WHERE productid = 51;


-- UPDATE Based on JOIN (Allows Filtered Attributes From Another Table)
-- Non-Standard
UPDATE D
    SET discount += 0.05
FROM dbo.OrderDetails AS D
    INNER JOIN dbo.Orders AS O
        ON D.orderid = O.orderid
        WHERE O.custid = 1;

-- UPDATE w/ Subquery (Same Example As Above)
-- Standard
UPDATE dbo.OrderDetails
    SET discount += 0.05
WHERE EXISTS (
    SELECT * FROM dbo.Orders AS O
    WHERE O.orderid = OrderDetails.orderid
        AND O.custid = 1
);