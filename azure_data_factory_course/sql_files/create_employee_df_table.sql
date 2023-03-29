CREATE TABLE EmployeeDF (
    Emp_Key     INT NOT NULL IDENTITY(1, 1) PRIMARY KEY
    ,Emp_Id     INT NOT NULL
    ,Name       VARCHAR(MAX)
    ,Gender     VARCHAR(MAX)
    ,Salary     INT
    ,Dept_Id    INT
    ,Updated    DATETIME DEFAULT GETDATE()
);


CREATE TABLE EmployeeDept (
    Emp_Key     INT NOT NULL IDENTITY(1, 1) PRIMARY KEY
    ,Emp_Id     INT NOT NULL
    ,Name       VARCHAR(MAX)
    ,Gender     VARCHAR(MAX)
    ,Salary     INT
    ,Dept_Id    INT
    ,Dept_Name  VARCHAR(MAX)
    ,Updated    DATETIME DEFAULT GETDATE()
);


CREATE TABLE EmployeeRank (
    Emp_Key     INT NOT NULL IDENTITY(1, 1) PRIMARY KEY
    ,Emp_Id     INT NOT NULL
    ,Name       VARCHAR(MAX)
    ,Gender     VARCHAR(MAX)
    ,Salary     INT
    ,Salary_Rnk BIGINT
    ,Dept_Id    INT
    ,Updated    DATETIME DEFAULT GETDATE()
);


CREATE TABLE EmployeeAgg (
    Dept_Id     INT
    ,Dept_Name  VARCHAR(MAX)
    ,Emp_Count  INT 
    ,Max_Salary BIGINT
    ,Avg_Salary BIGINT
    ,Updated    DATETIME DEFAULT GETDATE()
);


CREATE TABLE EmployeeGender (
    Dept_Id     INT
    ,Total_F    INT 
    ,Total_M    INT
    ,Updated    DATETIME DEFAULT GETDATE()
);


CREATE TABLE EmployeeDerived (
    Emp_Key             INT NOT NULL IDENTITY(1, 1) PRIMARY KEY
    ,Emp_Id             INT NOT NULL
    ,Gender_Name        VARCHAR(MAX)
    ,Salary             INT
    ,Salary_Weekly      INT
    ,Dept_Id            INT
    ,Department_Name    VARCHAR(MAX)
    ,Updated            DATETIME DEFAULT GETDATE()
);


-- Create Conditional Split Tables
CREATE TABLE EmployeeIT (
    Emp_Key     INT NOT NULL IDENTITY(1, 1) PRIMARY KEY
    ,Emp_Id     INT NOT NULL
    ,Name       VARCHAR(MAX)
    ,Gender     VARCHAR(MAX)
    ,Salary     INT
    ,Dept_Id    INT
    ,Updated    DATETIME DEFAULT GETDATE()
);


CREATE TABLE EmployeeHR (
    Emp_Key     INT NOT NULL IDENTITY(1, 1) PRIMARY KEY
    ,Emp_Id     INT NOT NULL
    ,Name       VARCHAR(MAX)
    ,Gender     VARCHAR(MAX)
    ,Salary     INT
    ,Dept_Id    INT
    ,Updated    DATETIME DEFAULT GETDATE()
);


CREATE TABLE EmployeeOther (
    Emp_Key     INT NOT NULL IDENTITY(1, 1) PRIMARY KEY
    ,Emp_Id     INT NOT NULL
    ,Name       VARCHAR(MAX)
    ,Gender     VARCHAR(MAX)
    ,Salary     INT
    ,Dept_Id    INT
    ,Updated    DATETIME DEFAULT GETDATE()
);


-- Validate DF Runs
SELECT Updated, COUNT (*)
FROM Table_Name
GROUP BY Updated
ORDER BY Updated DESC;

SELECT *
FROM Table_Name
WHERE Updated = (
    SELECT MAX (Updated)
    FROM EmployeeDF
);