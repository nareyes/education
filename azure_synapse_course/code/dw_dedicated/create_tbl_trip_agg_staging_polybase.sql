-- Creaye Data Format
IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'Parquet_File_Format') 
	CREATE EXTERNAL FILE FORMAT [Parquet_File_Format] 
	WITH ( FORMAT_TYPE = PARQUET)
GO


-- Create Data Source
IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'NYC_Taxi_Curated') 
	CREATE EXTERNAL DATA SOURCE NYC_Taxi_Curated 
	WITH (
		LOCATION = 'https://synlakehousedev.dfs.core.windows.net/nyc-taxi/curated' 
	)
GO


-- Create Schema
CREATE SCHEMA Staging
GO


-- Create Staging Table (External)
CREATE EXTERNAL TABLE Staging.TripAggregated (
	[PartitionYear] 	NVARCHAR(4000)
	,[PartitionMonth]	NVARCHAR(4000)
	,[Borough] 			NVARCHAR(4000)
	,[TripDate] 		DATE
	,[TripDay] 			NVARCHAR(4000)
	,[IsWeekend] 		INT
	,[CardTripCount]	INT
	,[CashTripCount] 	INT
	)

	WITH (
	LOCATION = 'trip_aggregated',
	DATA_SOURCE = NYC_Taxi_Curated,
	FILE_FORMAT = Parquet_File_Format
	)

GO


SELECT TOP 100 * FROM Staging.TripAggregated
GO