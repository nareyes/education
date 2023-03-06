CREATE TABLE dbo.Department (
    Dept_Id   INT,
    Dept_Name VARCHAR(MAX),

);

INSERT INTO dbo.Department(Dept_Id, Dept_Name) VALUES (1,'IT');
INSERT INTO dbo.Department(Dept_Id, Dept_Name) VALUES (2,'HR');
INSERT INTO dbo.Department(Dept_Id, Dept_Name) VALUES (3,'Payroll');


SELECT * FROM dbo.Department;