-- Create demo table with dynamic data masking
DROP TABLE IF EXISTS dbo.DimEmployeeDDM;
CREATE TABLE dbo.DimEmployeeDDM (
    EmployeeKey     INT             NOT NULL
    , FirstName     NVARCHAR(50)    MASKED WITH (FUNCTION = 'partial(1, "XXXXXXX", 0)') NOT NULL 
    , LastName      NVARCHAR(50)    NOT NULL
    , EmailAddress  NVARCHAR(250)   MASKED WITH (FUNCTION = 'email()') NULL
    , Phone         NVARCHAR(25)    MASKED WITH (FUNCTION = 'default()') NULL
    , EmployeePin   INT             MASKED WITH (FUNCTION = 'random(1, 1000)') NOT NULL
    , SSN           VARCHAR(12)     MASKED WITH (FUNCTION = 'default()') NOT NULL
);


-- Insert sample data
INSERT INTO dbo.DimEmployeeDDM
SELECT
    EmployeeKey
    , FirstName
    , LastName
    , EmailAddress
    , Phone
    , 1111 AS Pin
    , '111-222-3333' AS SSN
FROM dbo.DimEmployee;


-- Create User
CREATE LOGIN DemoUser
WITH PASSWORD = 'DemoUser';

CREATE USER DemoUser
FROM LOGIN DemoUser
WITH DEFAULT_SCHEMA = dbo;

EXEC SP_AddRoleMember N'db_datareader', N'DemoUser';
-- Connect with new user


-- Query table with DDM from new user
SELECT * FROM dbo.DimEmployeeDDM;


-- Query system w/ DDM functions
SELECT
    C.Name 
    , T.Name 
    , C.Is_Masked 
    , C.Masking_Function
FROM SYS.Masked_Columns AS C
    INNER JOIN SYS.Tables AS T
        ON C.Object_ID = T.Object_ID;