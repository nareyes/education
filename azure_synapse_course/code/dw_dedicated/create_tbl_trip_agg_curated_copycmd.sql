-- Create Table Using Bulk Load
IF NOT EXISTS (SELECT * FROM sys.objects O JOIN sys.schemas S ON O.schema_id = S.schema_id WHERE O.NAME = 'TripDemand' AND O.TYPE = 'U' AND S.NAME = 'Curated')

CREATE TABLE Curated.TripDemand (
	[PartitionYear]      NVARCHAR(4000)
	,[PartitionMonth]    NVARCHAR(4000)
	,[Borough]           NVARCHAR(4000)
	,[TripDate]          DATE
	,[TripDay]           NVARCHAR(4000)
	,[IsWeekend]         INT
	,[StreetHailCount]   INT
	,[DispatchCount]     INT
	,[TripDistance]      FLOAT
	,[TripDuration]      INT
	,[FareAmount]        FLOAT
)
	WITH (
		CLUSTERED COLUMNSTORE INDEX
		,DISTRIBUTION = ROUND_ROBIN
	)

GO


-- Copy Intro Table
COPY INTO Curated.TripDemand (
	PartitionYear 		1
	,PartitionMonth 	2
	,Borough 			3
	,TripDate 			4
	,TripDay 			5
	,IsWeekend 			6
	,StreetHailCount	7
	,DispatchCount 		8
	,TripDistance 		9
	,TripDuration 		10
	,FareAmount 		11
)
	FROM 'https://synlakehousedev.dfs.core.windows.net/nyc-taxi/curated/trip_demand'

	WITH (
		FILE_TYPE = 'PARQUET'
		,MAXERRORS = 0
		,COMPRESSION = 'snappy'
		,AUTO_CREATE_TABLE = 'ON'
	)

GO


SELECT TOP 100 * FROM Curated.TripDemand;