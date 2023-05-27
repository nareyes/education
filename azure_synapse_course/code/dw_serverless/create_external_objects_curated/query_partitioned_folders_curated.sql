USE NYC_Taxi_Serverless
GO

SELECT DISTINCT
    PartitionYear
    ,PartitionMonth
FROM Curated.View_TripAggregated;

SELECT DISTINCT
    PartitionYear
    ,PartitionMonth
FROM Curated.View_TripDemand;