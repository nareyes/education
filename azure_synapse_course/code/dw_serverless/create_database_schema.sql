Use MASTER
GO

-- Create & Alter Database
CREATE DATABASE NYC_Taxi_Serverless
GO

ALTER DATABASE NYC_Taxi_Serverless
COLLATE Latin1_General_100_BIN2_UTF8
GO


USE NYC_Taxi_Serverless
GO

-- Create Schemas
CREATE SCHEMA Raw
GO

CREATE SCHEMA Processed
GO

CREATE SCHEMA Curated
GO