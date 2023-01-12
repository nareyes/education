-----------------------------------------------
-- Chapter 1: Introduction to T-SQL Querying --
-----------------------------------------------
USE tsql_fundamentals;

-- CREATE TABLE w/ PK Constraint
DROP TABLE IF EXISTS dbo.Employees;

CREATE TABLE dbo.Employees (
--  Attribute   Data Type       Nullability
    EmpID       INT             NOT NULL
    , FirstName VARCHAR (30)    NOT NULL
    , LastName  VARCHAR (30)    NOT NULL
    , MgrID     INT             NULL 
    , SSN       VARCHAR(20)     NOT NULL
    , Salary    MONEY           NOT NULL
--  CONSTRAINTS
    CONSTRAINT  PK_Employees
        PRIMARY KEY (EmpID)
);

SELECT * FROM dbo.Employees;


-- Add Unique Constraint w/ ALTER TABLE
ALTER TABLE dbo.Employees
    ADD CONSTRAINT  UNQ_Employees_SSN
    UNIQUE          (SSN);


-- Add Unique Constraint Allowing Duplicate NULLs
CREATE UNIQUE INDEX IDX_SSN_NOTNULL
    ON dbo.Employees(SSN)
    WHERE SSN IS NOT NULL;


-- CREATE TABLE w/ FK Constraints
DROP TABLE IF EXISTS dbo.Orders;

CREATE TABLE dbo.Orders (
    OrderID     INT         NOT NULL
    , EmpID     INT         NOT NULL 
    , CustID    VARCHAR(10) NOT NULL
    , OrderTS   DATETIME2   NOT NULL
    , Qty       INT         NOT NULL

    CONSTRAINT  PK_Orders
        PRIMARY KEY (OrderID)
    
    CONSTRAINT  FK_Orders_Employees
        FOREIGN KEY (EmpID)
        REFERENCES dbo.Employees(EmpID)
);


-- Self-Referencing FK Constraint (MgrID IN EmpID)
ALTER TABLE dbo.Employees
    ADD CONSTRAINT  FK_Employees_Employees
    FOREIGN KEY     (MgrID)
    REFERENCES      dbo.Employees(EmpID);


-- ALTER TABLE w/ CHK Constraint (Predicate Filters Negative Values)
-- Only Positive and NULL Values Allowed
ALTER TABLE dbo.Employees
    ADD CONSTRAINT  CHK_Employees_Salary
    CHECK (Salary > 0.00);


-- ALTER TABLE w/ DFT Constraint
ALTER TABLE dbo.Orders
    ADD CONSTRAINT  DFT_Orders_OrderTS
    DEFAULT (SYSDATETIME ()) FOR OrderTS;


-- PK, FK, CHK, DFT Constraints Defined in CREATE TABLE
DROP TABLE IF EXISTS dbo.Orders;

CREATE TABLE dbo.Orders (
    OrderID     INT         NOT NULL
    , EmpID     INT         NOT NULL 
    , CustID    VARCHAR(10) NOT NULL
    , OrderTS   DATETIME2   NOT NULL
    , Qty       INT         NOT NULL

    CONSTRAINT  PK_Orders
        PRIMARY KEY (OrderID)
    
    CONSTRAINT  FK_Orders_Employees
        FOREIGN KEY (EmpID)
        REFERENCES dbo.Employees(EmpID)
    
    CONSTRAINT CHK_Orders_Qty
        CHECK (Qty > 0.00)
    
    CONSTRAINT  DFT_Orders_OrderTS
        DEFAULT (SYSDATETIME ()) FOR OrderTS
);


-- CLEAN UP
DROP TABLE IF EXISTS dbo.Orders, dbo.Employees;