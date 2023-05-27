USE NYC_Taxi_Serverless
GO

SELECT DISTINCT
    PartitionYear
    ,PartitionMonth
FROM Processed.View_TripPartitioned;