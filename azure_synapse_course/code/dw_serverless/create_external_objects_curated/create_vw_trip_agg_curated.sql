USE NYC_Taxi_Serverless
GO

DROP VIEW IF EXISTS Curated.View_TripAggregated
GO

CREATE VIEW Curated.View_TripAggregated
AS

    SELECT
        *
    FROM
        OPENROWSET (
            BULK 'trip_aggregated/**'
            ,DATA_SOURCE = 'NYC_Taxi_Curated'
            ,FORMAT = 'PARQUET'
        )

            WITH (
                PartitionYear   VARCHAR(4)
                ,PartitionMonth VARCHAR(2)
                ,Borough        VARCHAR(20)
                ,TripDate       DATE
                ,TripDay        VARCHAR(10)
                ,IsWeekend      TINYINT
                ,CardTripCount  INT
                ,CashTripCount  INT         
            ) AS TripAggregated
GO


-- Query w/ Partition Pruning
SELECT TOP 10 *
FROM Curated.View_TripAggregated
WHERE PartitionYear = '2020' AND PartitionMonth = '01';