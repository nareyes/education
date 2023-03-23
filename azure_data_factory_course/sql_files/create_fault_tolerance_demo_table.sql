-- Fault Tolerance Demo
CREATE TABLE dbo.EmployeeDetailsFault (
    Name      VARCHAR(8)
    ,Gender  CHAR(1)
    ,Salary  INT
    ,Dept    CHAR(1)
    ,DOJ     DATE
);

SELECT * FROM dbo.EmployeeDetailsFault;