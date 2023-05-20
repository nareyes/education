USE NYC_Taxi_Serverless
GO

-- Rate Code (JSON Source)
DROP VIEW IF EXISTS Raw.View_RateCode
GO

CREATE VIEW Raw.View_RateCode
AS
    SELECT
        RateCodeID
        ,RateCodeDescription
    FROM
        OPENROWSET (
            BULK 'rate_code.json',
            DATA_SOURCE = 'NYC_Taxi_Raw',
            FORMAT = 'CSV', -- Even for JSON
            PARSER_VERSION = '1.0',
            FIELDTERMINATOR = '0x0b',
            FIELDQUOTE = '0x0b',
            ROWTERMINATOR = '0x0b' -- Vertical Tab
        ) 

            WITH (
                jsonDoc NVARCHAR(MAX)
            ) AS RateCode

    CROSS APPLY OPENJSON(jsonDoc) -- Return Key Value Pairs
        WITH (
            RateCodeID              TINYINT     '$.rate_code_id'
            ,RateCodeDescription    VARCHAR(20) '$.rate_code'
        );
GO

SELECT * FROM Raw.View_RateCode;
GO


-- Payment Type
DROP VIEW IF EXISTS Raw.View_PaymentType
GO

CREATE VIEW Raw.View_PaymentType
AS
    SELECT
        PaymentType
        ,PaymentTypeDescription
    FROM
        OPENROWSET (
            BULK 'payment_type.json'
            ,DATA_SOURCE = 'NYC_Taxi_Raw'
            ,FORMAT = 'CSV' -- Even for JSON
            ,PARSER_VERSION = '1.0'
            ,FIELDTERMINATOR = '0x0b'
            ,FIELDQUOTE = '0x0b'
            ,ROWTERMINATOR = '0x0a'
        ) 

            WITH (
                jsonDoc NVARCHAR(MAX)
            ) AS PaymentType

    CROSS APPLY OPENJSON(jsonDoc) -- Return Key Value Pairs
        WITH (
            PaymentType             SMALLINT    '$.payment_type'
            ,PaymentTypeDescription VARCHAR(15) '$.payment_type_desc'
        )
GO

SELECT * FROM Raw.View_PaymentType;
GO


-- Partition Pruning for Views (Workaround for External Table Pruning)
-- External Tables Do Not Support Partition Pruning
DROP VIEW IF EXISTS Raw.View_TripCSV
GO

CREATE VIEW Raw.View_TripCSV
AS
    SELECT
        TripCSV.filepath(1) AS PartitionYear
        ,TripCSV.filepath(2) AS PartitionMonth
        ,TripCSV.*
    FROM
        OPENROWSET (
            BULK 'trip_data_green_csv/year=*/month=*/*.csv'
            ,DATA_SOURCE = 'NYC_Taxi_Raw'
            ,FORMAT = 'CSV'
            ,PARSER_VERSION = '2.0'
            ,HEADER_ROW = TRUE
        )

            WITH (
                VendorID	            TINYINT
                ,lpep_pickup_datetime	DATETIME2(0)
                ,lpep_dropoff_datetime	DATETIME2(0)
                ,store_and_fwd_flag	    VARCHAR(10)
                ,RatecodeID	            SMALLINT
                ,PULocationID	        SMALLINT
                ,DOLocationID	        SMALLINT
                ,passenger_count	    TINYINT
                ,trip_distance	        FLOAT
                ,fare_amount	        FLOAT
                ,extra	                FLOAT
                ,mta_tax	            FLOAT
                ,tip_amount	            FLOAT
                ,tolls_amount	        FLOAT
                ,ehail_fee	            VARCHAR(50)
                ,improvement_surcharge  FLOAT
                ,total_amount	        FLOAT
                ,payment_type	        BIGINT
                ,trip_type              BIGINT
                ,congestion_surcharge   FLOAT
            ) AS TripCSV
GO

SELECT TOP 10 * FROM Raw.View_TripCSV;

SELECT
    PartitionYear
    ,PartitionMonth
    ,COUNT(1) AS RecordCount
FROM Raw.View_TripCSV
WHERE PartitionYear = 2020
GROUP BY PartitionYear,PartitionMonth
ORDER BY PartitionMonth;
GO