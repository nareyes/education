CREATE TABLE EmployeeDF (
    Emp_Key     INT NOT NULL IDENTITY(1,1) PRIMARY KEY
    ,Emp_Id     INT NOT NULL
    ,Name       VARCHAR(MAX)
    ,Gender     VARCHAR(MAX)
    ,Salary     INT
    ,Dept_Id    INT
    ,Updated    DATETIME DEFAULT GETDATE()
);

SELECT * FROM EmployeeDF;


-- Create Conditional Split Tables
CREATE TABLE EmployeeIT (
    Emp_Key     INT NOT NULL IDENTITY(1,1) PRIMARY KEY
    ,Emp_Id     INT NOT NULL
    ,Name       VARCHAR(MAX)
    ,Gender     VARCHAR(MAX)
    ,Salary     INT
    ,Dept_Id    INT
    ,Updated    DATETIME DEFAULT GETDATE()
);

SELECT * FROM EmployeeIT;


CREATE TABLE EmployeeHR (
    Emp_Key     INT NOT NULL IDENTITY(1,1) PRIMARY KEY
    ,Emp_Id     INT NOT NULL
    ,Name       VARCHAR(MAX)
    ,Gender     VARCHAR(MAX)
    ,Salary     INT
    ,Dept_Id    INT
    ,Updated    DATETIME DEFAULT GETDATE()
);

SELECT * FROM EmployeeHR;


CREATE TABLE EmployeeOther (
    Emp_Key     INT NOT NULL IDENTITY(1,1) PRIMARY KEY
    ,Emp_Id     INT NOT NULL
    ,Name       VARCHAR(MAX)
    ,Gender     VARCHAR(MAX)
    ,Salary     INT
    ,Dept_Id    INT
    ,Updated    DATETIME DEFAULT GETDATE()
);

SELECT * FROM EmployeeOther;


-- Validate DF Runs
SELECT Updated, COUNT (*)
FROM EmployeeDF
GROUP BY Updated
ORDER BY Updated DESC;

SELECT Updated, COUNT (*)
FROM EmployeeIT
GROUP BY Updated
ORDER BY Updated DESC;

SELECT Updated, COUNT (*)
FROM EmployeeHR
GROUP BY Updated
ORDER BY Updated DESC;

SELECT Updated, COUNT (*)
FROM EmployeeOther
GROUP BY Updated
ORDER BY Updated DESC;

SELECT *
FROM EmployeeDF
WHERE Updated = (
    SELECT MAX (Updated)
    FROM EmployeeDF
);