--  Watermark Example

DROP TABLE IF EXISTS  [dbo].[FactTrips];

CREATE TABLE [dbo.[FactTrips] (
[TripID] INT
, [CustomerID] INT
, [LastModifiedTime] DATETIME2
);

-- Insert Dummy Values
INSERT INTO [dbo].[FactTrips] VALUES (100, 200, CURRENT_TIMESTAMP);
INSERT INTO [dbo].[FactTrips] VALUES (101, 201, CURRENT_TIMESTAMP);
INSERT INTO [dbo].[FactTrips] VALUES (102, 202, CURRENT_TIMESTAMP);

SELECT * FROM [dbo].[FactTrips];

-- Sample Watermark Table (Table Name and Last Update Value)
DROP TABLE IF EXISTS WatermarkTable;

CREATE TABLE WatermarkTable (
  [TableName] VARCHAR(100)
  , [WatermarkValue] DATETIME
);

INSERT INTO [dbo].[WatermarkTable] VALUES ('FactTrips', CURRENT_TIMESTAMP);
SELECT * FROM WatermarkTable;
GO

-- Update Watermark Table Manually
UPDATE [dbo].[WatermarkTable] SET [WatermarkValue] = CURRENT_TIMESTAMP WHERE [TableName] = 'FactTrips';

-- Update Watermark Table with Stored Procedure (Automated on Update)
DROP PROCEDURE IF EXISTS uspUpdateWatermark
GO

CREATE PROCEDURE [dbo].uspUpdateWatermark
    @LastModifiedtime DATETIME
    , @TableName VARCHAR(100)
AS

BEGIN
UPDATE [dbo].[WatermarkTable] 
    SET [WatermarkValue] = @LastModifiedtime 
    WHERE [TableName] = @TableName
END

GO

-- Executing the Stored Procedure
DECLARE @timestamp AS DATETIME = CURRENT_TIMESTAMP;
EXECUTE uspUpdateWatermark
    @LastModifiedtime=@timestamp
    , @TableName='FactTrips';

SELECT * FROM WatermarkTable;