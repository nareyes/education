-------------------------------------------
--  Chapter 9 Exercises: Temporal Tables --
-------------------------------------------


-- EXERCISE 1
-- Create a system-versioned temporal table called Departments with an associated history table called DepartmentsHistory in the database TSQLV4. 
-- The table should have the following columns: deptid INT, deptname VARCHAR(25), and mgrid INT, all disallowing NULLs. 
-- Also include columns called validfrom and validto that define the validity period of the row. Define those with precision zero (1 second), and make them hidden.
IF OBJECT_ID(N'dbo.Departments', N'U') IS NOT NULL
BEGIN
    IF OBJECTPROPERTY(OBJECT_ID(N'dbo.Departments', N'U'), N'TableTemporalType') = 2
        ALTER TABLE dbo.Departments
            SET ( SYSTEM_VERSIONING = OFF );
    DROP TABLE IF EXISTS dbo.DepartmentsHistory, dbo.Departments;
END
GO

CREATE TABLE dbo.Departments (
    deptid       INT          NOT NULL CONSTRAINT PK_Departments PRIMARY KEY
    ,deptname    VARCHAR(25)  NOT NULL
    ,mgrid       INT          NOT NULL
    ,validfrom   DATETIME2(0) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL
    ,validto     DATETIME2(0) GENERATED ALWAYS AS ROW END   HIDDEN NOT NULL
    ,PERIOD FOR SYSTEM_TIME (validfrom, validto)
)

    WITH (
        SYSTEM_VERSIONING = ON (
            HISTORY_TABLE = dbo.DepartmentsHistory
        )
);

SELECT *, validfrom, validto FROM dbo.Departments;
SELECT * FROM dbo.DepartmentsHistory;

/*
Requirements for creating system-versioned temporal tables;
- A primary key: defined based on the deptid column.
- The table option SYSTEM_VERSIONING set to ON.
- Two non-nullable DATETIME2 columns, with any precision (in our case 0), representing the start and end of the row’s validity period (validfrom and validto)
- The start column (validfrom) marked with the option GENERATED ALWAYS AS ROW START.
- The end column (validto) marked with the option GENERATED ALWAYS AS ROW END.
- A designation of the period columns: PERIOD FOR SYSTEM_TIME (validfrom, validto).
- A linked history table called DepartmentsHistory (which SQL Server creates for you) to hold the past states of modified rows.
*/


-- EXERCISE 2.1
-- Insert four rows to the table Departments with the following details, and note the time when you apply this insert (call it P1).
SELECT CAST (SYSDATETIME() AS DATETIME2(0)) AS P1; -- 2023-04-28 10:57:55

INSERT INTO dbo.Departments (deptid, deptname, mgrid)
    VALUES
        (1, 'HR', 7),
        (2, 'IT', 5),
        (3, 'Sales', 11),
        (4, 'Marketing', 13);

SELECT *, validfrom, validto FROM dbo.Departments;

-- EXERCISE 2.2
-- In one transaction, update the name of department 3 to Sales and Marketing and delete department 4. Call the point in time when the transaction starts P2.
SELECT CAST (SYSDATETIME() AS DATETIME2(0)) AS P2; -- 2023-04-28 10:59:25

BEGIN TRAN;

UPDATE dbo.Departments
    SET deptname = 'Sales and Marketing'
WHERE deptid = 3;

DELETE FROM dbo.Departments
WHERE deptid = 4;

COMMIT TRAN;

-- EXERCISE 2.3
-- Update the manager ID of department 3 to 13. Call the point in time when you apply this update P3.
SELECT CAST (SYSDATETIME() AS DATETIME2(0)) AS P3; --2023-04-28 11:00:10

UPDATE dbo.Departments
    SET mgrid = 13
WHERE mgrid = 3;

-- Inspect Temporal Table Changes
SELECT *, validfrom, validto FROM dbo.Departments;
SELECT * FROM dbo.DepartmentsHistory;


-- EXERCISE 3.1
-- Query the current state of the table Departments.
SELECT *, validfrom, validto FROM dbo.Departments;

-- EXERCISE 3.2
-- Query the state of the table Departments at a point in time after P2 and before P3.
SELECT * FROM dbo.Departments
FOR SYSTEM_TIME AS OF '2023-04-28 10:59:30';

-- EXERCISE 3.3
-- Query the state of the table Departments in the period between P2 and P3.
-- Be explicit about the column names in the SELECT list, and include the validfrom and validto columns.
SELECT
    deptid
    ,deptname
    ,mgrid
    ,validfrom
    ,validto
FROM dbo.Departments
FOR SYSTEM_TIME BETWEEN '2023-04-28 10:59:25' AND '2023-04-28 11:00:10'; -- P1 and P2


-- EXERCISE 4
-- Drop the table Departments and its associated history table.
IF OBJECT_ID(N'dbo.Departments', N'U') IS NOT NULL
BEGIN
    IF OBJECTPROPERTY(OBJECT_ID(N'dbo.Departments', N'U'), N'TableTemporalType') = 2
        ALTER TABLE dbo.Departments
            SET ( SYSTEM_VERSIONING = OFF );
    DROP TABLE IF EXISTS dbo.DepartmentsHistory, dbo.Departments;
END
GO

-- Alternate
ALTER TABLE dbo.Departments
    SET (
        SYSTEM_VERSIONING = OFF
    );
    
DROP TABLE IF EXISTS dbo.Departments, dbo.DepartmentsHistory
GO