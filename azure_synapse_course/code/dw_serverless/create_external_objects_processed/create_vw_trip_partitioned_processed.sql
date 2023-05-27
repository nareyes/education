USE NYC_Taxi_Serverless
GO

DROP VIEW IF EXISTS Processed.View_TripPartitioned
GO

CREATE VIEW Processed.View_TripPartitioned
AS

    SELECT
        *
    FROM
        OPENROWSET (
            BULK 'trip_partitioned/**'
            ,DATA_SOURCE = 'NYC_Taxi_Processed'
            ,FORMAT = 'PARQUET'
        )

            WITH (
                PartitionYear           VARCHAR(4)
                ,PartitionMonth         VARCHAR(2)
                ,VendorID	            TINYINT         
                ,PickupDateTime     	DATETIME2(0)    
                ,DropoffDateTime    	DATETIME2(0)    
                ,StoreFwdFlag   	    VARCHAR(10)     
                ,RateCodeID	            SMALLINT        
                ,PULocationID	        SMALLINT        
                ,DOLocationID	        SMALLINT        
                ,PassengerCount 	    TINYINT         
                ,TripDistance	        FLOAT           
                ,FareAmount 	        FLOAT           
                ,Extra	                FLOAT           
                ,MTATax 	            FLOAT           
                ,TipAmount	            FLOAT           
                ,TollsAmount	        FLOAT           
                ,eHailFee	            VARCHAR(50)     
                ,ImprovementSurcharge   FLOAT           
                ,TotalAmount	        FLOAT           
                ,PaymentType	        BIGINT          
                ,TripType               BIGINT          
                ,CongestionSurcharge    FLOAT           
            ) AS TripPartitioned
GO


-- Query w/ Partition Pruning
SELECT TOP 10 *
FROM Processed.View_TripPartitioned
WHERE PartitionYear = '2020' AND PartitionMonth = '01';