USE NYC_Taxi_Serverless
GO

CREATE OR ALTER PROCEDURE Curated.InsertTripDemand

@PartitionYear  VARCHAR(4),
@PartitionMonth VARCHAR(2)

AS

BEGIN

    DECLARE @CreateStatement    NVARCHAR(MAX),
            @DropStatement      NVARCHAR(MAX);
    

    SET @CreateStatement =
        'CREATE EXTERNAL TABLE Curated.TripDemand_' + @PartitionYear + '_' + @PartitionMonth +

            ' WITH (
                LOCATION = ''trip_demand/year=' + @PartitionYear + '/month=' + @PartitionMonth + '''
                ,DATA_SOURCE = NYC_Taxi_Curated
                ,FILE_FORMAT = Parquet_File_Format
            )

        AS

            SELECT
                T.PartitionYear
                ,T.PartitionMonth
                ,Z.Borough
                ,CAST (T.PickupDateTime AS DATE) AS TripDate
                ,C.DayName AS TripDay
                ,CASE WHEN C.DayName IN (''Saturday'', ''Sunday'') THEN 1 ELSE 0 END AS IsWeekend
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
                AND T.PartitionYear = ''' + @PartitionYear + ''' 
                AND T.PartitionMonth = ''' + @PartitionMonth + '''
            GROUP BY
                T.PartitionYear
                ,T.PartitionMonth
                ,Z.Borough
                ,CAST (T.PickupDateTime AS DATE)
                ,C.DayName';


    PRINT(@CreateStatement)
    EXEC sp_executesql @CreateStatement;


    SET @DropStatement =
        'DROP EXTERNAL TABLE Curated.TripDemand_' + @PartitionYear + '_' + @PartitionMonth;
    
    PRINT(@DropStatement)
    EXEC sp_executesql @DropStatement;

END;