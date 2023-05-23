----------------------------------------------
-- Chapter 10: Transactions and Concurrency --
----------------------------------------------
USE tsql_fundamentals;

------------------
-- TRANSACTIONS --
------------------

-- Explicit Transactions
BEGIN TRAN;
    -- CODE
COMMIT TRAN;

/*Transaction Properties (ACID)
- Atomicity
- Consistency
- Isoltation
- Durability
*/


-- Determine Transaction Count
-- Returns 0 If Not in an Open Transaction
SELECT @@TRANCOUNT;

-- Transaction Examples
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

-- Validate Transaction order-d = @neworderid
SELECT TOP 5 * FROM Sales.Orders
ORDER BY orderid DESC;

SELECT TOP 5 * FROM Sales.OrderDetails
ORDER BY orderid DESC;

DELETE FROM Sales.OrderDetails
WHERE orderid > 11077;

DELETE FROM Sales.Orders
WHERE orderid > 11077;

------------------------
-- LOCKS AND BLOCKING --
------------------------
 
-- Azure SQL Uses Row-Versioning Model
-- Query WIll Return Most Recent Consistent State
BEGIN TRAN;

    UPDATE Production.Products
        SET unitprice = 20.00
    WHERE productid = 2;

COMMIT TRAN;

    -- Run From Seperate Query Window
    SELECT productid, unitprice
    FROM Production.Products
    WHERE productid = 2; -- Will return $19 until above transaction is committed


-- Disable Row-Versioning Model (to stay consistent with book)
ALTER DATABASE tsql_fundamentals
    SET READ_COMMITTED_SNAPSHOT OFF;


-- Return Lock Information (Locks Granted and Locks Waiting)
SELECT -- Use * For All Attributes
    request_session_id
    ,resource_type                 
    ,resource_database_id
    ,DB_NAME (resource_database_id) AS database_name
    ,resource_description
    ,OBJECT_NAME (resource_associated_entity_id) AS resource_id
    ,request_mode
    ,request_status
FROM sys.dm_tran_locks;

SELECT @@SPID; -- Return Current Session ID


-- Return Connections Associated with Session IDs (View Blocking Chains)
SELECT -- Use * For All Attributes
    session_id
    ,connect_time
    ,last_read
    ,last_write
    ,most_recent_sql_handle
FROM sys.dm_exec_connections
WHERE session_id IN (55, 54)

-- Return Last Code Invoked by Each Connection
SELECT session_id, text
FROM sys.dm_exec_connections
    CROSS APPLY sys.dm_exec_sql_text (most_recent_sql_handle) AS ST;

    -- Alternate Method, Returns Last Code Submitted by Sessions
    SELECT session_id, event_info
    FROM sys.dm_exec_connections
        CROSS APPLY sys.dm_exec_input_buffer (session_id, NULL) AS IB;


-- Return Session Information
SELECT -- Use * For All Attributes
    session_id
    ,login_time
    ,host_name
    ,program_name
    ,login_name
    ,nt_user_name
    ,last_request_start_time
    ,last_request_end_time
FROM sys.dm_exec_sessions;


-- Return Active Requests
-- Blocked Requests: blocking_session_id > 0
SELECT -- Use * For All Attributes
    session_id
    ,blocking_session_id
    ,command
    ,sql_handle
    ,database_id
    ,wait_type
    ,wait_time
    ,wait_resource
FROM sys.dm_exec_requests;
-- Filter Blocked Requests Only
-- WHERE blocking_session_id > 0;


-- Terminate Session Manually
KILL SESSION <session_id>;