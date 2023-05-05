CREATE TABLE EmployeesSCD2 (
    Emp_Key     INT NOT NULL IDENTITY(1,1) PRIMARY KEY
    ,Emp_Id     INT NOT NULL
    ,Name       VARCHAR(MAX)
    ,Gender     VARCHAR(MAX)
    ,Salary     INT
    ,Dept_Id    INT
    ,Is_Active  CHAR(1)
    ,Updated    DATETIME DEFAULT GETDATE()
);

SELECT * FROM EmployeesSCD2;


INSERT INTO dbo.EmployeesSCD2(Emp_Id, Name, Gender, Salary, Dept_id, Is_Active, Updated) VALUES(4,'Abhro','M',35000,1,'Y');
INSERT INTO dbo.EmployeesSCD2(Emp_Id, Name, Gender, Salary, Dept_id, Is_Active, Updated) VALUES(9,'Happy','M',20000,2,'Y');