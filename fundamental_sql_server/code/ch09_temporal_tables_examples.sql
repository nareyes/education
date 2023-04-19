--------------------------------
-- Chapter 9: Temporal Tables --
--------------------------------
USE tsql_fundamentals;


---------------------
-- CREATING TABLES --
---------------------

/* Temporal Table Requirements
- Primary key
- Start and end DATETIME2 columns
- Start: GENERATED ALWAYS AS ROW START (HIDDEN Optional)
- End: GENERATED ALWAYS AS ROW END (HIDDEN Optional)
- PERIOD FOR SYSTEM_TIME Option
- SYSTEM_VERSIONING Option
- Linked history table
*/

-- Create Temporal Table
CREATE TABLE dbo.Employees (
    empid        INT
    ,empname     VARCHAR(25)     NOT NULL    CONSTRAINT PK_Employees PRIMARY KEY NONCLUSTERED
    ,department  VARCHAR(50)     NOT NULL
    ,salary      NUMERIC(10,2)   NOT NULL
    ,sysstart    DATETIME2(0)    GENERATED ALWAYS AS ROW START HIDDEN    NOT NULL
    ,sysend      DATETIME2(0)    GENERATED ALWAYS AS ROW END HIDDEN      NOT NULL

    ,PERIOD FOR SYSTEM_TIME (sysstart, sysend)
    ,INDEX IX_Employees CLUSTERED (empid, sysstart, sysend)
)
WITH (
    SYSTEM_VERSIONING = ON (
        HISTORY_TABLE = dbo.EmployeesHistory
    )
);

SELECT * FROM dbo.Employees;
SELECT *, sysstart, sysend FROM dbo.Employees;


--------------------
-- MODIFYING DATA --
--------------------

-- Insert Data
INSERT INTO dbo.Employees (empid, empname, department, salary)
    VALUES
        (1, 'Sara', 'IT'       , 50000.00)
        ,(2, 'Don' , 'HR'       , 45000.00)
        ,(3, 'Judy', 'Sales'    , 55000.00)
        ,(4, 'Yael', 'Marketing', 55000.00)
        ,(5, 'Sven', 'IT'       , 45000.00)
        ,(6, 'Paul', 'Sales'    , 40000.00);

SELECT *, sysstart, sysend FROM dbo.Employees;
SELECT *, sysstart, sysend FROM dbo.EmployeesHistory;


-- Delete Data
DELETE FROM dbo.Employees
WHERE empid = 6;

SELECT *, sysstart, sysend FROM dbo.Employees;
SELECT *, sysstart, sysend FROM dbo.EmployeesHistory;


-- Update Data (Treated as Delete/Insert)
UPDATE dbo.Employees
    SET salary *= 1.05
WHERE department = 'IT';

SELECT *, sysstart, sysend FROM dbo.Employees;
SELECT *, sysstart, sysend FROM dbo.EmployeesHistory;


-- Update Data (Long Transactions)
-- Start/end time are recorded as the transaction start time
BEGIN TRAN
GO

UPDATE dbo.Employees
    SET department = 'Sales'
WHERE empid = 5

UPDATE dbo.Employees
    SET department = 'IT'
WHERE empid = 3

COMMIT TRAN 
GO

SELECT *, sysstart, sysend FROM dbo.Employees;
SELECT *, sysstart, sysend FROM dbo.EmployeesHistory;


-------------------
-- QUERYING DATA --
-------------------

-- Replicate Book Environment
IF OBJECT_ID(N'dbo.Employees', N'U') IS NOT NULL
BEGIN
    IF OBJECTPROPERTY(OBJECT_ID(N'dbo.Employees', N'U'), N'TableTemporalType') = 2
        ALTER TABLE dbo.Employees SET ( SYSTEM_VERSIONING = OFF );
    DROP TABLE IF EXISTS dbo.EmployeesHistory, dbo.Employees;
END
GO

CREATE TABLE dbo.Employees (
    empid        INT
    ,empname     VARCHAR(25)     NOT NULL    CONSTRAINT PK_Employees PRIMARY KEY NONCLUSTERED
    ,department  VARCHAR(50)     NOT NULL
    ,salary      NUMERIC(10,2)   NOT NULL
    ,sysstart    DATETIME2(0)    NOT NULL
    ,sysend      DATETIME2(0)    NOT NULL

    ,INDEX IX_Employees CLUSTERED (empid, sysstart, sysend)
);

INSERT INTO dbo.Employees (empid, empname, department, salary, sysstart, sysend)
    VALUES
        (1 , 'Sara', 'IT'       , 52500.00, '2016-02-16 17:20:02', '9999-12-31 23:59:59')
        ,(2 , 'Don' , 'HR'       , 45000.00, '2016-02-16 17:08:41', '9999-12-31 23:59:59')
        ,(3 , 'Judy', 'IT'       , 55000.00, '2016-02-16 17:28:10', '9999-12-31 23:59:59')
        ,(4 , 'Yael', 'Marketing', 55000.00, '2016-02-16 17:08:41', '9999-12-31 23:59:59')
        ,(5 , 'Sven', 'Sales'    , 47250.00, '2016-02-16 17:28:10', '9999-12-31 23:59:59');

CREATE TABLE dbo.EmployeesHistory (
    empid        INT
    ,empname     VARCHAR(25)     NOT NULL
    ,department  VARCHAR(50)     NOT NULL
    ,salary      NUMERIC(10,2)   NOT NULL
    ,sysstart    DATETIME2(0)    NOT NULL
    ,sysend      DATETIME2(0)    NOT NULL

    ,INDEX IX_Employees CLUSTERED (sysstart, sysend)
        WITH (DATA_COMPRESSION = PAGE)
);

INSERT INTO dbo.EmployeesHistory(empid, empname, department, salary, sysstart, sysend)
    VALUES
        (6 , 'Paul', 'Sales' , 40000.00, '2016-02-16 17:08:41', '2016-02-16 17:15:26')
        ,(1 , 'Sara', 'IT'    , 50000.00, '2016-02-16 17:08:41', '2016-02-16 17:20:02')
        ,(5 , 'Sven', 'IT'    , 45000.00, '2016-02-16 17:08:41', '2016-02-16 17:20:02')
        ,(3 , 'Judy', 'Sales' , 55000.00, '2016-02-16 17:08:41', '2016-02-16 17:28:10')
        ,(5 , 'Sven', 'IT'    , 47250.00, '2016-02-16 17:20:02', '2016-02-16 17:28:10');

ALTER TABLE dbo.Employees ADD PERIOD FOR SYSTEM_TIME (sysstart, sysend);

ALTER TABLE dbo.Employees ALTER COLUMN sysstart ADD HIDDEN;

ALTER TABLE dbo.Employees ALTER COLUMN sysend ADD HIDDEN;

ALTER TABLE dbo.Employees
    SET ( SYSTEM_VERSIONING = ON ( HISTORY_TABLE = dbo.EmployeesHistory ) );


-- Query Current State
SELECT * FROM dbo.Employees;
SELECT *, sysstart, sysend FROM dbo.Employees;


-- Query Past State
SELECT *, sysstart, sysend
FROM dbo.Employees FOR SYSTEM_TIME AS OF '2016-02-16 17:10:00';


-- Compare Different States
SELECT
    T2.empid
    ,T2.empname
    ,CAST( (T2.salary / T1.salary - 1.0) * 100.0 AS NUMERIC(10, 2) ) AS pctdiff
FROM dbo.Employees FOR SYSTEM_TIME AS OF '2016-02-16 17:10:00' AS T1
    INNER JOIN dbo.Employees FOR SYSTEM_TIME AS OF '2016-02-16 17:25:00' AS T2
        ON T1.empid = T2.empid
        AND T2.salary > T1.salary;


-- Specifying Start and End Period
SELECT *, sysstart, sysend
FROM dbo.Employees FOR SYSTEM_TIME FROM '2016-02-16 17:15:26' TO '2016-02-16 17:20:02'; -- Not inclusive

SELECT *, sysstart, sysend
FROM dbo.Employees FOR SYSTEM_TIME BETWEEN '2016-02-16 17:15:26' AND '2016-02-16 17:20:02'; -- Inclusive

SELECT *, sysstart, sysend
FROM dbo.Employees FOR SYSTEM_TIME CONTAINED IN ('2016-02-16 17:00:00', '2016-02-16 18:00:00');


-- Return ALL Rows From Both Tables (Current and History)
SELECT *, sysstart, sysend
FROM dbo.Employees FOR SYSTEM_TIME ALL;


/* Subclause Summary
Subclause                       Qualifying Rows
AS OF @datetime                 sysstart <= @datetime AND sysend > @datetime
FROM @start TO @end             sysstart < @end AND sysend > @start
BETWEEN @start AND @end         sysstart <= @end AND sysend > @start
CONTAINED IN (@start, @end)     sysstart >= @start AND sysend <= @end
*/