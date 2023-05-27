USE NYC_Taxi_Serverless
GO

DROP VIEW IF EXISTS Curated.View_TripDemand
GO

CREATE VIEW Curated.View_TripDemand
AS

    SELECT
        *
    FROM
        OPENROWSET (
            BULK 'trip_demand/**'
            ,DATA_SOURCE = 'NYC_Taxi_Curated'
            ,FORMAT = 'PARQUET'
        )

            WITH (
                PartitionYear       VARCHAR(4)
                ,PartitionMonth     VARCHAR(2)
                ,Borough            VARCHAR(20)
                ,TripDate           DATE
                ,TripDay            VARCHAR(10)
                ,IsWeekend          TINYINT
                ,StreetHailCount    INT
                ,DispatchCount      INT
                ,TripDistance       FLOAT
                ,TripDuration       INT  
                ,FareAmount         FLOAT      
            ) AS TripDemand
GO


-- Query w/ Partition Pruning
SELECT TOP 10 *
FROM Curated.View_TripDemand
WHERE PartitionYear = '2020' AND PartitionMonth = '01';