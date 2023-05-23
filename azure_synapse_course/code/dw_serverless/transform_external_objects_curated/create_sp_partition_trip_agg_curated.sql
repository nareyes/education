USE NYC_Taxi_Serverless
GO

CREATE OR ALTER PROCEDURE Curated.InsertTripAggregated

@PartitionYear  VARCHAR(4),
@PartitionMonth VARCHAR(2)

AS

BEGIN

    DECLARE @CreateStatement    NVARCHAR(MAX),
            @DropStatement      NVARCHAR(MAX);
    

    SET @CreateStatement =
        'CREATE EXTERNAL TABLE Curated.TripAggregated_' + @PartitionYear + '_' + @PartitionMonth +

            ' WITH (
                LOCATION = ''trip_aggregated/year=' + @PartitionYear + '/month=' + @PartitionMonth + '''
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
        'DROP EXTERNAL TABLE Curated.TripAggregated_' + @PartitionYear + '_' + @PartitionMonth;
    
    PRINT(@DropStatement)
    EXEC sp_executesql @DropStatement;

END;