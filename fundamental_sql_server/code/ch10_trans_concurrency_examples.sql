----------------------------------------------
-- Chapter 10: Transactions and Concurrency --
----------------------------------------------
USE tsql_fundamentals;


-- Determine Transaction
-- Returns 0 If Not in an Open Transaction
SELECT @@TRANCOUNT

-- Transaction Exampls
BEGIN TRAN;

DECLARE @neworderid AS INT;

INSERT INTO Sales.Orders (custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shippostalcode, shipcountry)
    VALUES
      (85, 5, '20090212', '20090301', '20090216', 3, 32.38, N'Ship to 85-B', N'6789 rue de l''Abbaye', N'Reims', N'10345', N'France');

SET @neworderid = SCOPE_IDENTITY();
SELECT @neworderid AS neworderid;

INSERT INTO Sales.OrderDetails (orderid, productid, unitprice, qty, discount)
    VALUES
        (@neworderid, 11, 14.00, 12, 0.000)
        ,(@neworderid, 42, 9.80, 10, 0.000)
        ,(@neworderid, 72, 34.80, 5, 0.000);

COMMIT TRAN;

DELETE FROM Sales.OrderDetails
WHERE orderid > 11077;

DELETE FROM Sales.Orders
WHERE orderid > 11077;

