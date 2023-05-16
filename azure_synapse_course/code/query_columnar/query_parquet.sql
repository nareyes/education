USE NYC_Taxi_Serverless
GO

-- Query Single File
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=2020/month=01/*.parquet',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'PARQUET'
    ) AS TripData


-- Query Data Types
-- Parquet Infers Data Types from Metadata (More Accurate)
EXEC sp_describe_first_result_set N'
    SELECT
        TOP 100 *
    FROM
        OPENROWSET(
            BULK ''trip_data_green_parquet/year=2020/month=01/*.parquet'',
            DATA_SOURCE = ''NYC_Taxi_Raw'',
            FORMAT = ''PARQUET''
        ) AS TripData
'


-- Query w/ Explicit Data Types
-- Most Inferred Data Types are Correct
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=2020/month=01/*.parquet',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'PARQUET'
    ) 
    WITH(
        VendorID                INT
        ,lpep_pickup_datetime   DATETIME2(7)
        ,lpep_dropoff_datetime  DATETIME2(7)
        ,store_and_fwd_flag     CHAR(1)
        ,RatecodeID             INT
        ,PULocationID           INT
        ,DOLocationID           INT
        ,passenger_count        INT
        ,trip_distance          FLOAT
        ,fare_amount            FLOAT
        ,extra                  FLOAT
        ,mta_tax                FLOAT
        ,tip_amount             FLOAT
        ,tolls_amount           FLOAT
        ,ehail_fee              INT
        ,improvement_surcharge  FLOAT
        ,total_amount           FLOAT
        ,payment_type           INT
        ,trip_type              INT
        ,congestion_surcharge   FLOAT
    ) AS TripData


-- Query w/ Explicit Data Types and Columns (More Cost Efficient)
-- Most Inferred Data Types are Correct
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=2020/month=01/*.parquet',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'PARQUET'
    ) 
    WITH(
        VendorID                INT
        ,lpep_pickup_datetime   DATETIME2(7)
        ,lpep_dropoff_datetime  DATETIME2(7)
        ,trip_distance          FLOAT
        ,fare_amount            FLOAT
        ,tip_amount             FLOAT
        ,tolls_amount           FLOAT
        ,total_amount           FLOAT
        ,trip_type              INT
    ) AS TripData