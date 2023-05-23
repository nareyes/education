USE NYC_Taxi_Serverless
GO


-- Demand Taxi Data
SELECT
    T.PartitionYear
    ,T.PartitionMonth
    ,Z.Borough
    ,CAST (T.PickupDateTime AS DATE) AS TripDate
    ,C.DayName AS TripDay
    ,CASE WHEN C.DayName IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END AS IsWeekend
    ,SUM (CASE WHEN TT.TripType = 1 THEN 1 ELSE 0 END) AS StreetHailCount -- Trip Type: Street Hail
    ,SUM (CASE WHEN TT.TripType = 2 THEN 1 ELSE 0 END) AS DispatchCount -- Trip Type: Dispatch
    ,SUM (T.TripDistance) AS TripDistance
    ,SUM (DATEDIFF (MINUTE, T.PickupDateTime, T.DropoffDateTime)) AS TripDuration
    ,SUM (T.FareAmount) AS FareAmount
FROM Processed.View_TripPartitioned AS T
    INNER JOIN Processed.TaxiZone AS Z
        ON T.PULocationID = Z.LocationID
    INNER JOIN Processed.Calendar AS C
        ON CAST (T.PickupDateTime AS DATE) = C.Date
    INNER JOIN Processed.PaymentType AS P
        ON T.PaymentType = P.PaymentType
    INNER JOIN Processed.TripType AS TT
        ON T.TripType = TT.TripType 
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
EXEC Curated.InsertTripDemand @PartitionYear = '2020', @PartitionMonth = '01';
EXEC Curated.InsertTripDemand @PartitionYear = '2020', @PartitionMonth = '02';
EXEC Curated.InsertTripDemand @PartitionYear = '2020', @PartitionMonth = '03';
EXEC Curated.InsertTripDemand @PartitionYear = '2020', @PartitionMonth = '04';
EXEC Curated.InsertTripDemand @PartitionYear = '2020', @PartitionMonth = '05';
EXEC Curated.InsertTripDemand @PartitionYear = '2020', @PartitionMonth = '06';
EXEC Curated.InsertTripDemand @PartitionYear = '2020', @PartitionMonth = '07';
EXEC Curated.InsertTripDemand @PartitionYear = '2020', @PartitionMonth = '08';
EXEC Curated.InsertTripDemand @PartitionYear = '2020', @PartitionMonth = '09';
EXEC Curated.InsertTripDemand @PartitionYear = '2020', @PartitionMonth = '10';
EXEC Curated.InsertTripDemand @PartitionYear = '2020', @PartitionMonth = '11';
EXEC Curated.InsertTripDemand @PartitionYear = '2020', @PartitionMonth = '12';
EXEC Curated.InsertTripDemand @PartitionYear = '2021', @PartitionMonth = '01';
EXEC Curated.InsertTripDemand @PartitionYear = '2021', @PartitionMonth = '02';
EXEC Curated.InsertTripDemand @PartitionYear = '2021', @PartitionMonth = '03';
EXEC Curated.InsertTripDemand @PartitionYear = '2021', @PartitionMonth = '04';
EXEC Curated.InsertTripDemand @PartitionYear = '2021', @PartitionMonth = '05';
EXEC Curated.InsertTripDemand @PartitionYear = '2021', @PartitionMonth = '06';
EXEC Curated.InsertTripDemand @PartitionYear = '2021', @PartitionMonth = '07';