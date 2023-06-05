-- Create Schema
CREATE SCHEMA Curated
GO


-- Create Table
CREATE TABLE Curated.TripAggregated
    WITH (
        CLUSTERED COLUMNSTORE INDEX
        ,DISTRIBUTION = ROUND_ROBIN
    )

    AS

    SELECT
        [PartitionYear] 	
        ,[PartitionMonth]	
        ,[Borough] 			
        ,[TripDate] 		
        ,[TripDay] 			
        ,[IsWeekend] 		
        ,[CardTripCount]	
        ,[CashTripCount]
    FROM Staging.TripAggregated

GO


SELECT * FROM Curated.TripAggregated;