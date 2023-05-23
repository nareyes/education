USE NYC_Taxi_Serverless
GO

CREATE OR ALTER PROCEDURE Processed.InsertPartitionTripData

@PartitionYear  VARCHAR(4),
@PartitionMonth VARCHAR(2)

AS

BEGIN

    DECLARE @CreateStatement    NVARCHAR(MAX),
            @DropStatement      NVARCHAR(MAX);
    

    SET @CreateStatement =
        'CREATE EXTERNAL TABLE Processed.TripPartitioned_' + @PartitionYear + '_' + @PartitionMonth +

            ' WITH (
                LOCATION = ''trip_partitioned/year=' + @PartitionYear + '/month=' + @PartitionMonth + '''
                ,DATA_SOURCE = NYC_Taxi_Processed
                ,FILE_FORMAT = Parquet_File_Format
            )

        AS

            SELECT *
            FROM Processed.Trip
            WHERE 1=1
                AND PartitionYear = ''' + @PartitionYear + ''' 
                AND PartitionMonth = ''' + @PartitionMonth + '''';
    
    PRINT(@CreateStatement)
    EXEC sp_executesql @CreateStatement;


    SET @DropStatement =
        'DROP EXTERNAL TABLE Processed.TripPartitioned_' + @PartitionYear + '_' + @PartitionMonth;
    
    PRINT(@DropStatement)
    EXEC sp_executesql @DropStatement;

END;