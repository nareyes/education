USE NYC_Taxi_Serverless
GO


-- Pre-Aggregated Taxi Data
SELECT
    T.PartitionYear
    ,T.PartitionMonth
    ,Z.Borough
    ,CAST (T.PickupDateTime AS DATE) AS TripDate
    ,C.DayName AS TripDay
    ,CASE WHEN C.DayName IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END AS IsWeekend
    ,SUM (CASE WHEN P.PaymentType = 1 THEN 1 ELSE 0 END) AS CardTripCount -- Payment Type: Card
    ,SUM (CASE WHEN P.PaymentType = 2 THEN 1 ELSE 0 END) AS CashTripCount -- Payment Type: Cash
FROM Processed.View_TripPartitioned AS T
    INNER JOIN Processed.TaxiZone AS Z
        ON T.PULocationID = Z.LocationID
    INNER JOIN Processed.Calendar AS C
        ON CAST (T.PickupDateTime AS DATE) = C.Date
    INNER JOIN Processed.PaymentType AS P
        ON T.PaymentType = P.PaymentType
WHERE 1=1
    AND T.PartitionYear = '2020' 
    AND T.PartitionMonth = '01'
GROUP BY
    T.PartitionYear
    ,T.PartitionMonth
    ,Z.Borough
    ,CAST (T.PickupDateTime AS DATE)
    ,C.DayName;


-- Copy Data to Serverless and ADLS (Delete Serverless)
EXEC Curated.InsertTripAggregated @PartitionYear = '2020', @PartitionMonth = '01';
EXEC Curated.InsertTripAggregated @PartitionYear = '2020', @PartitionMonth = '02';
EXEC Curated.InsertTripAggregated @PartitionYear = '2020', @PartitionMonth = '03';
EXEC Curated.InsertTripAggregated @PartitionYear = '2020', @PartitionMonth = '04';
EXEC Curated.InsertTripAggregated @PartitionYear = '2020', @PartitionMonth = '05';
EXEC Curated.InsertTripAggregated @PartitionYear = '2020', @PartitionMonth = '06';
EXEC Curated.InsertTripAggregated @PartitionYear = '2020', @PartitionMonth = '07';
EXEC Curated.InsertTripAggregated @PartitionYear = '2020', @PartitionMonth = '08';
EXEC Curated.InsertTripAggregated @PartitionYear = '2020', @PartitionMonth = '09';
EXEC Curated.InsertTripAggregated @PartitionYear = '2020', @PartitionMonth = '10';
EXEC Curated.InsertTripAggregated @PartitionYear = '2020', @PartitionMonth = '11';
EXEC Curated.InsertTripAggregated @PartitionYear = '2020', @PartitionMonth = '12';
EXEC Curated.InsertTripAggregated @PartitionYear = '2021', @PartitionMonth = '01';
EXEC Curated.InsertTripAggregated @PartitionYear = '2021', @PartitionMonth = '02';
EXEC Curated.InsertTripAggregated @PartitionYear = '2021', @PartitionMonth = '03';
EXEC Curated.InsertTripAggregated @PartitionYear = '2021', @PartitionMonth = '04';
EXEC Curated.InsertTripAggregated @PartitionYear = '2021', @PartitionMonth = '05';
EXEC Curated.InsertTripAggregated @PartitionYear = '2021', @PartitionMonth = '06';
EXEC Curated.InsertTripAggregated @PartitionYear = '2021', @PartitionMonth = '07';