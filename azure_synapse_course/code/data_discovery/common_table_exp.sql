USE NYC_Taxi_Serverless
GO


-- Identify Percentage of Cash & Credit Card Trips by Borough
WITH

CTE_PaymentType AS (
    SELECT
        CAST(JSON_VALUE(jsonDoc, '$.payment_type') AS SMALLINT) payment_type
        ,CAST(JSON_VALUE(jsonDoc, '$.payment_type_desc') AS VARCHAR(15)) payment_type_desc
    FROM OPENROWSET(
        BULK 'payment_type.json',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'CSV',
        PARSER_VERSION = '1.0', 
        FIELDTERMINATOR = '0x0b',
        FIELDQUOTE = '0x0b',
        ROWTERMINATOR = '0x0a'
    )
    WITH(
        jsonDoc NVARCHAR(MAX)
    ) AS payment_type
),

CTE_TaxiZone AS (
    SELECT
        *
    FROM
        OPENROWSET(
            BULK 'taxi_zone.csv',
            DATA_SOURCE = 'NYC_Taxi_Raw',
            FORMAT = 'CSV',
            PARSER_VERSION = '2.0',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n'
        ) 
        WITH (
            location_id SMALLINT        1
            ,borough VARCHAR(15)         2
            ,zone VARCHAR(50)            3
            ,service_zone VARCHAR(15)    4
        ) AS TaxiZone
),

CTE_TripData AS (
    SELECT
        *
    FROM
        OPENROWSET(
            BULK 'trip_data_green_parquet/year=*/month=*/**',
            FORMAT = 'PARQUET',
            DATA_SOURCE = 'NYC_Taxi_Raw'
        ) AS TripData
)

SELECT 
    CTE_TaxiZone.borough AS Borough
    ,COUNT(1) AS TotalTrips
    ,SUM(CASE WHEN CTE_PaymentType.payment_type_desc = 'Cash' THEN 1 ELSE 0 END) AS CashTrips
    ,SUM(CASE WHEN CTE_PaymentType.payment_type_desc = 'Credit card' THEN 1 ELSE 0 END) AS CardTrips
    ,CAST((SUM(CASE WHEN CTE_PaymentType.payment_type_desc = 'Cash' THEN 1 ELSE 0 END)/ CAST(COUNT(1) AS DECIMAL)) * 100 AS DECIMAL(5, 2)) AS CashTripsPercentage
    ,CAST((SUM(CASE WHEN CTE_PaymentType.payment_type_desc = 'Credit card' THEN 1 ELSE 0 END)/ CAST(COUNT(1) AS DECIMAL)) * 100 AS DECIMAL(5, 2)) AS CardTripsPercentage
FROM CTE_TripData 
    LEFT JOIN CTE_PaymentType
        ON (CTE_TripData.payment_type = CTE_PaymentType.payment_type)
    LEFT JOIN CTE_TaxiZone
        ON (CTE_TripData.PULocationId = CTE_TaxiZone.location_id)
WHERE CTE_PaymentType.payment_type_desc IN ('Cash', 'Credit card')
GROUP BY CTE_TaxiZone.borough
ORDER BY CTE_TaxiZone.borough;