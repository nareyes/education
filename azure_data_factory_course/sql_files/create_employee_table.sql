CREATE TABLE dbo.Employee (
    Name        VARCHAR(MAX)
    ,Gender    VARCHAR(MAX)
    ,Dept      VARCHAR(MAX)
);


INSERT INTO dbo.Employee(Name, Gender, Dept) VALUES ('Tanmoy', 'M', 'IT');
INSERT INTO dbo.Employee(Name, Gender, Dept) VALUES ('Roop', 'M', 'HR');
INSERT INTO dbo.Employee(Name, Gender, Dept) VALUES ('Malathy', 'F', 'IT');
INSERT INTO dbo.Employee(Name, Gender, Dept) VALUES ('Kranthi', 'M', 'HR');
INSERT INTO dbo.Employee(Name, Gender, Dept) VALUES ('Bhuvi', 'F', 'Payrole');

SELECT * FROM dbo.Employee;