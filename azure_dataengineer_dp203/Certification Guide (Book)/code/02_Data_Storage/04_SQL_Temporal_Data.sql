-- Temporal Data Example
CREATE TABLE [dbo].[DimCustomerTemp] (
  [customerId] INT NOT NULL PRIMARY KEY CLUSTERED
  , [name] VARCHAR(100) NOT NULL
  , [address] VARCHAR(100) NOT NULL
  , [email] VARCHAR (100) NOT NULL
  , [phone] VARCHAR(12) NOT NULL
  , [validFrom] DATETIME2 GENERATED ALWAYS AS ROW START
  , [validTo] DATETIME2 GENERATED ALWAYS AS ROW END
  , PERIOD FOR SYSTEM_TIME (validFrom, validTo)
)

WITH (SYSTEM_VERSIONING = ON);

-- Insert Dummy Values
INSERT INTO [dbo].[DimCustomerTemp] ([customerId], [name], [address], [email], [phone]) VALUES (101, 'Alan Li', '101 Test Lane, LA', 'alan@li.com', '111-222-3333');
INSERT INTO [dbo].[DimCustomerTemp] ([customerId], [name], [address], [email], [phone]) VALUES (102, 'Becky King', '202 Second Lane, SF', 'becky@king.com', '222-333-4444');
INSERT INTO [dbo].[DimCustomerTemp] ([customerId], [name], [address], [email], [phone]) VALUES (103, 'Daniel Martin', '303 Third Lane, NY', 'daniel@someone.com', '333-444-5555');

-- Check Values
SELECT * FROM DimCustomerTemp;

-- Update A Record
UPDATE [dbo].[DimCustomerTemp] SET [address] = '111 Updated Lane, LA' WHERE [customerId] = 101;


-- Validate Temporal Behavior
SELECT 
    [customerId]
   , [name]
   , [address]
   , [validFrom]
   , [validTo]
   , IIF (YEAR ([validTo]) = 9999, 1, 0) AS IsActual
FROM dbo.DimCustomerTemp
FOR SYSTEM_TIME BETWEEN 'START DATE' AND 'END DATE'
WHERE [CustomerId] = 101
ORDER BY [validFrom] DESC;