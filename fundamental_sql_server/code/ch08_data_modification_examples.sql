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

-- Create Demo Tables
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

------------------
-- MERGING DATA --
------------------

-- Create Demo Tables
DROP TABLE IF EXISTS dbo.Customers, dbo.CustomersStage
GO

CREATE TABLE dbo.Customers (
  custid       INT         NOT NULL CONSTRAINT PK_Customers PRIMARY KEY(custid)
  ,companyname VARCHAR(25) NOT NULL
  ,phone       VARCHAR(20) NOT NULL
  ,address     VARCHAR(50) NOT NULL
  
);

INSERT INTO dbo.Customers (custid, companyname, phone, address)
VALUES
    (1, 'cust 1', '(111) 111-1111', 'address 1')
    ,(2, 'cust 2', '(222) 222-2222', 'address 2')
    ,(3, 'cust 3', '(333) 333-3333', 'address 3')
    ,(4, 'cust 4', '(444) 444-4444', 'address 4')
    ,(5, 'cust 5', '(555) 555-5555', 'address 5');

CREATE TABLE dbo.CustomersStage (
  custid       INT         NOT NULL CONSTRAINT PK_CustomersStage PRIMARY KEY(custid)
  ,companyname VARCHAR(25) NOT NULL
  ,phone       VARCHAR(20) NOT NULL
  ,address     VARCHAR(50) NOT NULL
);

INSERT INTO dbo.CustomersStage(custid, companyname, phone, address)
VALUES
    (2, 'AAAAA', '(222) 222-2222', 'address 2')
    ,(3, 'cust 3', '(333) 333-3333', 'address 3')
    ,(5, 'BBBBB', 'CCCCC', 'DDDDD')
    ,(6, 'cust 6 (new)', '(666) 666-6666', 'address 6')
    ,(7, 'cust 7 (new)', '(777) 777-7777', 'address 7');

SELECT * FROM dbo.Customers;
SELECT * FROM dbo.CustomersStage;


-- MERGE Statement
/*
MERGE INTO <target_table>
USING <source_table>
    ON <matching_condition>
WHEN MATCHEN THEN
    UPDATE SET
        <update_conditions>
WHEN NOT MATCHEN THEN
    INSERT <fields>
    VALUES <values>
*/
-- MERGE WHEN MATCHED (ON custid)
-- Updates values when custid is matched, does not check matching of other values
MERGE INTO dbo.Customers AS TGT 
USING dbo.CustomersStage AS SRC
    ON TGT.custid = SRC.custid
WHEN MATCHED THEN
    UPDATE SET
        TGT.companyname = SRC.companyname
        ,TGT.phone      = SRC.phone
        ,TGT.address    = SRC.address
WHEN NOT MATCHED THEN
    INSERT (custid, companyname, phone, address)
    VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address);

SELECT * FROM dbo.Customers;


-- MERGE w/ DELETE Clause
MERGE INTO dbo.Customers AS TGT 
USING dbo.CustomersStage AS SRC
    ON TGT.custid = SRC.custid
WHEN MATCHED THEN
    UPDATE SET
        TGT.companyname = SRC.companyname
        ,TGT.phone      = SRC.phone
        ,TGT.address    = SRC.address
WHEN NOT MATCHED THEN
    INSERT (custid, companyname, phone, address)
    VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address)
WHEN NOT MATCHED BY SOURCE THEN -- Optional clause to delete rows from target
    DELETE;

SELECT * FROM dbo.Customers;


-- MERGE w/ WHEN MATCHED AND
-- Adds additional checks for value matches
MERGE INTO dbo.Customers AS TGT 
USING dbo.CustomersStage AS SRC
    ON TGT.custid = SRC.custid
WHEN MATCHED AND (
    TGT.companyname <> SRC.companyname
    OR TGT.phone    <> SRC.phone
    OR TGT.address  <> SRC.address
) THEN
    UPDATE SET
        TGT.companyname = SRC.companyname
        ,TGT.phone      = SRC.phone
        ,TGT.address    = SRC.address
WHEN NOT MATCHED THEN
    INSERT (custid, companyname, phone, address)
    VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address);

SELECT * FROM dbo.Customers;


-----------------------------------------
-- MODIFYING DATA W/ TABLE EXPRESSIONS --
-----------------------------------------

/*
Modifications still applied to source tables
Useful for debugging purposes
Much easier to run a SELECT statement to see changes
before running the UPDATE statement to make changes
*/

-- WITH CTE
WITH
T AS (
    SELECT
        O.custid
        ,D.orderid 
        ,D.productid
        ,D.discount
        ,D.discount + 0.05 AS newdiscount
    FROM dbo.OrderDetails AS D
        INNER JOIN dbo.Orders AS O
            ON D.orderid = O.orderid 
        WHERE O.custid = 1
)

UPDATE T 
    SET discount = newdiscount;


-- WITH DERIVED TABLE
UPDATE T 
    SET discount = newdiscount
FROM (
    SELECT
        O.custid
        ,D.orderid 
        ,D.productid
        ,D.discount
        ,D.discount + 0.05 AS newdiscount
    FROM dbo.OrderDetails AS D
        INNER JOIN dbo.Orders AS O
            ON D.orderid = O.orderid 
        WHERE O.custid = 1
) AS T;


/* Additional Example
Window Functions are not allowed in the SET clause
Workaround using CTE */

-- Create Demo Table
DROP TABLE IF EXISTS dbo.T1
GO

CREATE TABLE dbo.T1 (col1 INT, col2 INT);
GO

INSERT INTO dbo.T1 (col1)
    VALUES (20),(10),(30);

SELECT * FROM dbo.T1;

-- Update Failure
UPDATE dbo.T1
    SET col2 = ROW_NUMBER () OVER (ORDER BY col1); -- Will fail

-- Update Success
WITH
T AS (
    SELECT
        col1
        ,col2
        ,ROW_NUMBER () OVER (ORDER BY col1) AS rownum
    FROM dbo.T1
)

UPDATE T
    SET col2 = rownum;

SELECT * FROM dbo.T1;


-------------------
-- OUTPUT CLAUSE --
-------------------

-- Create Demo Tables
-- T1
DROP TABLE IF EXISTS dbo.T1
GO

CREATE TABLE dbo.T1 (
  keycol  INT          NOT NULL IDENTITY(1, 1) CONSTRAINT PK_T1 PRIMARY KEY
  ,datacol NVARCHAR(40) NOT NULL
);

-- Orders
DROP TABLE IF EXISTS dbo.Orders;
 CREATE TABLE dbo.Orders
(
  orderid         INT          NOT NULL  CONSTRAINT PK_Orders PRIMARY KEY(orderid)
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

INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;

-- Order Details
DROP TABLE IF EXISTS dbo.OrderDetails
GO 

CREATE TABLE dbo.OrderDetails (
  orderid    INT           NOT NULL
  ,productid INT           NOT NULL
  ,unitprice MONEY         NOT NULL CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0)
  ,qty       SMALLINT      NOT NULL CONSTRAINT DFT_OrderDetails_qty DEFAULT(1)
  ,discount  NUMERIC(4, 3) NOT NULL CONSTRAINT DFT_OrderDetails_discount DEFAULT(0)
  ,CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid)
  ,CONSTRAINT CHK_discount  CHECK (discount BETWEEN 0 AND 1)
  ,CONSTRAINT CHK_qty  CHECK (qty > 0)
  ,CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
);

INSERT INTO dbo.OrderDetails SELECT * FROM Sales.OrderDetails;

-- Products Audit
DROP TABLE IF EXISTS dbo.ProductsAudit, dbo.Products
GO

CREATE TABLE dbo.Products (
  productid    INT          NOT NULL
  ,productname  NVARCHAR(40) NOT NULL
  ,supplierid   INT          NOT NULL
  ,categoryid   INT          NOT NULL
  ,unitprice    MONEY        NOT NULL CONSTRAINT DFT_Products_unitprice DEFAULT(0)
  ,discontinued BIT          NOT NULL CONSTRAINT DFT_Products_discontinued DEFAULT(0)
  ,CONSTRAINT PK_Products PRIMARY KEY(productid)
  ,CONSTRAINT CHK_Products_unitprice CHECK(unitprice >= 0)
);

INSERT INTO dbo.Products SELECT * FROM Production.Products;

CREATE TABLE dbo.ProductsAudit (
  LSN       INT NOT NULL IDENTITY PRIMARY KEY,
  TS        DATETIME2 NOT NULL DEFAULT(SYSDATETIME()),
  productid INT NOT NULL,
  colname   SYSNAME NOT NULL,
  oldval    SQL_VARIANT NOT NULL,
  newval    SQL_VARIANT NOT NULL
);


-- INSERT w/ OUTPUT
INSERT INTO dbo.T1 (datacol)
  OUTPUT inserted.keycol, inserted.datacol
    SELECT lastname
    FROM HR.Employees
    WHERE country = N'USA';


-- INSERT w/ OUTPUT (Inserted in Table Variable)
-- Applicable to DELETE, UPDATE, and MERGE
DECLARE @NewRows TABLE (keycol INT, datacol NVARCHAR(40));

INSERT INTO dbo.T1(datacol)
    OUTPUT inserted.keycol, inserted.datacol
    INTO @NewRows (keycol, datacol) -- Can also use temp or actual tables
        SELECT lastname
        FROM HR.Employees
        WHERE country = N'UK';

SELECT * FROM @NewRows;


-- DELETE w/ OUTPUT
DELETE FROM dbo.Orders
  OUTPUT
    deleted.orderid,
    deleted.orderdate,
    deleted.empid,
    deleted.custid
WHERE orderdate < '20160101';


-- UPDATE w/ OUTPUT
UPDATE dbo.OrderDetails
    SET discount += 0.05
        OUTPUT
        inserted.orderid,
        inserted.productid,
        deleted.discount AS olddiscount,
        inserted.discount AS newdiscount
    WHERE productid = 51;


-- MERGE w/ OUTPUT ($action)
MERGE INTO dbo.Customers AS TGT
USING dbo.CustomersStage AS SRC
  ON TGT.custid = SRC.custid

WHEN MATCHED THEN
  UPDATE SET
    TGT.companyname = SRC.companyname,
    TGT.phone = SRC.phone,
    TGT.address = SRC.address

WHEN NOT MATCHED THEN
  INSERT (custid, companyname, phone, address)
  VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address)

OUTPUT
    $action AS action
    ,inserted.custid
    ,deleted.companyname AS oldcompanyname
    ,inserted.companyname AS newcompanyname
    ,deleted.phone AS oldphone
    ,inserted.phone AS newphone
    ,deleted.address AS oldaddress
    ,inserted.address AS newaddress;


-- Nested DML
INSERT INTO dbo.ProductsAudit (productid, colname, oldval, newval)
    SELECT productid, N'unitprice', oldval, newval
    FROM (
        UPDATE dbo.Products
        SET unitprice *= 1.15
            OUTPUT
                inserted.productid,
                deleted.unitprice AS oldval,
                inserted.unitprice AS newval
        WHERE supplierid = 1
    ) AS D
WHERE oldval < 20.0 AND newval >= 20.0;

SELECT * FROM dbo.ProductsAudit;