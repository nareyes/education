---------------------------------------------
--  Chapter 8 Exercises: Data Modification --
---------------------------------------------


-- EXERCISE 1
-- Run the following code to create the dbo.Customers table in the TSQLV4 database:
DROP TABLE IF EXISTS dbo.Customers
GO

CREATE TABLE dbo.Customers (
    custid          INT             NOT NULL PRIMARY KEY
    ,companyname    NVARCHAR(40)    NOT NULL
    ,country        NVARCHAR(15)    NOT NULL
    ,region         NVARCHAR(15)    NULL
    ,city           NVARCHAR(15)    NOT NULL
);

-- EXERCISE 1.1
/* Insert into the dbo.Customers table a row with the following information:
    custid: 100  
    companyname: Coho Winery  
    country: USA  
    region: WA  
    city: Redmond */
INSERT INTO dbo.Customers (custid, companyname, country, region, city)
    VALUES (100, 'Coho Winery', 'USA', 'WA', 'Redmond');


-- EXERCISE 1.2
-- Insert into the dbo.Customers table all customers from Sales.Customers who placed orders.
INSERT INTO dbo.Customers (custid, companyname, country, region, city)
    SELECT
        C.custid
        ,C.companyname
        ,C.country
        ,C.region
        ,C.city
    FROM Sales.Customers AS C
    WHERE EXISTS (
        SELECT * FROM Sales.Orders AS O
        WHERE O.custid = C.custid
    );


-- EXERCISE 1.3
-- Use a SELECT INTO statement to create and populate the dbo.Orders table with orders from the Sales.Orders table that were placed in the years 2014 through 2016.
DROP TABLE IF EXISTS dbo.OrdersYear
GO

SELECT *
INTO dbo.OrdersYear
FROM Sales.Orders
WHERE YEAR (orderdate) BETWEEN '2014' AND '2016';


-- EXERCISE 2
-- Delete from the dbo.Orders table orders that were placed before August 2014.
-- Use the OUTPUT clause to return the orderid and orderdate values of the deleted orders:
DELETE FROM dbo.OrdersYear
    OUTPUT
        deleted.orderid
        ,deleted.orderdate
WHERE orderdate < '2014-08-01';


-- EXERCISE 3
-- Delete from the dbo.Orders table orders placed by customers from Brazil.
DELETE FROM dbo.OrdersYear
WHERE EXISTS (
    SELECT * FROM dbo.Customers AS C
    WHERE OrdersYear.custid = C.custid
        AND C.country = N'Brazil'
);


-- EXERCISE 4
-- Update the dbo.Customers table, and change all NULL region values to <None>.
-- Use the OUTPUT clause to show the custid, oldregion, and newregion.
UPDATE dbo.Customers
    SET region = 'None'
        OUTPUT
            deleted.custid
            ,deleted.region AS oldregion
            ,inserted.region AS newregion
WHERE region IS NULL;


-- EXERCISE 5
-- Update all orders in the dbo.Orders table that were placed by United Kingdom customers,
-- and set their shipcountry, shipregion, and shipcity values to the country, region, and city values of the corresponding customers.
UPDATE O
  SET shipcountry = C.country,
      shipregion = C.region,
      shipcity = C.city
FROM dbo.Orders AS O
  INNER JOIN dbo.Customers AS C
    ON O.custid = C.custid
WHERE C.country = N'UK';


-- EXERCISE 6
-- Run the following code to create the tables Orders and OrderDetails and populate them with data:
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
    orderid    INT           NOT NULL
    ,productid INT           NOT NULL
    ,unitprice MONEY         NOT NULL CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0)
    ,qty       SMALLINT      NOT NULL CONSTRAINT DFT_OrderDetails_qty DEFAULT(1)
    ,discount  NUMERIC(4, 3) NOT NULL CONSTRAINT DFT_OrderDetails_discount DEFAULT(0)

    ,CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid)
    ,CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY(orderid) REFERENCES dbo.Orders(orderid)
    ,CONSTRAINT CHK_discount CHECK (discount BETWEEN 0 AND 1)
    ,CONSTRAINT CHK_qty CHECK (qty > 0)
    ,CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
);

INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;
INSERT INTO dbo.OrderDetails SELECT * FROM Sales.OrderDetails;

-- Write and test the T-SQL code that is required to truncate both tables, and make sure your code runs successfully.
ALTER TABLE dbo.OrderDetails DROP CONSTRAINT FK_OrderDetails_Orders;

TRUNCATE TABLE dbo.OrderDetails;
TRUNCATE TABLE dbo.Orders;

ALTER TABLE dbo.OrderDetails ADD CONSTRAINT FK_OrderDetails_Orders
    FOREIGN KEY(orderid) REFERENCES dbo.Orders(orderid);