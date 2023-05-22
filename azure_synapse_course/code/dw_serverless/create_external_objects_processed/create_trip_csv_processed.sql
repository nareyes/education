USE NYC_Taxi_Serverless
GO

-- Data Written to ADLS Cannot be Deleted Here
-- Delete via Pipelines and Call Script as a Best Practice

-- Taxi Zone
IF OBJECT_ID ('Processed.Trip') IS NOT NULL
    DROP EXTERNAL TABLE Processed.Trip
    GO

CREATE EXTERNAL TABLE Processed.Trip

    WITH (
        LOCATION = 'trip'
        ,DATA_SOURCE = NYC_Taxi_Processed
        ,FILE_FORMAT = Parquet_File_Format
    )

AS

    -- SELECT *
    -- FROM Raw.TripCSV;

    -- Alternate: Use OPENROWSET if Raw Table Does Not Exists
    -- Preferred Method, Simple Column Renaming
    -- Issue w/ Partitioned Data: This Will Not Maintain Partitions (Added ParitionYear and PartitionMonth for Simple Parition-Like Filtering)
    -- Reference create_trip_csv_sp_processed for Stored Procedure Workaround (Using Spark Pool is a Preferred Solution)
    SELECT
        Trip.filepath(1) AS PartitionYear
        ,Trip.filepath(2) AS PartitionMonth
        ,Trip.*
    FROM
        OPENROWSET (
            BULK 'trip_data_green_csv/year=*/month=*/*.csv'
            ,DATA_SOURCE = 'NYC_Taxi_Raw'
            ,FORMAT = 'CSV'
            ,PARSER_VERSION = '2.0'
            ,HEADER_ROW = TRUE
        ) 

        WITH (
            VendorID	            TINYINT         1
            ,PickupDateTime     	DATETIME2(0)    2
            ,DropoffDateTime    	DATETIME2(0)    3
            ,StoreFwdFlag   	    VARCHAR(10)     4
            ,RateCodeID	            SMALLINT        5
            ,PULocationID	        SMALLINT        6
            ,DOLocationID	        SMALLINT        7
            ,PassengerCount 	    TINYINT         8
            ,TripDistance	        FLOAT           9
            ,FareAmount 	        FLOAT           10
            ,Extra	                FLOAT           11
            ,MTATax 	            FLOAT           12
            ,TipAmount	            FLOAT           13
            ,TollsAmount	        FLOAT           14
            ,eHailFee	            VARCHAR(50)     15
            ,ImprovementSurcharge   FLOAT           16
            ,TotalAmount	        FLOAT           17
            ,PaymentType	        BIGINT          18
            ,TripType               BIGINT          19
            ,CongestionSurcharge    FLOAT           20
        ) AS Trip


-- Query Processed Table
SELECT TOP 10 * FROM Processed.Trip
WHERE PartitionYear = 2020;