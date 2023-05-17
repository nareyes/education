USE NYC_Taxi_Serverless
GO

-- Explore
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=2020/month=01/*.parquet',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'PARQUET'
    ) AS TripData


-- Check TotalAmount Statistics
SELECT
    MIN (total_amount)      AS min_total_amount -- Unexpected MIN Value
    ,MAX (total_amount)     AS max_total_amount
    ,AVG (total_amount)     AS avg_total_amount
    ,COUNT(1)               AS record_count
    ,COUNT(total_amount)    AS record_count_not_null
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=*/month=*/*.parquet',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'PARQUET'
    ) AS TripData


-- Check Negative TotalAmount Values
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=2020/month=01/*.parquet',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'PARQUET'
    ) AS TripData
WHERE total_amount < 0;


-- Check PaymentType Counts for Negative TotalAmount Values
SELECT
    payment_type -- Outliers: 3 & 4
    ,COUNT(1) AS payment_type_count
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=*/month=*/*.parquet',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'PARQUET'
    ) AS TripData
WHERE total_amount < 0
GROUP BY payment_type
ORDER BY payment_type ASC;


-- Check Payment Type Descriptions (Interested in 3 and 4)
-- Payment Type Descriptions: 3 = No Charge, 4 = Dispute
SELECT
    JSON_VALUE (jsonDoc, '$.payment_type') AS PaymentType
    ,JSON_VALUE (jsonDoc, '$.payment_type_desc') AS PaymentTypeDescription
FROM
    OPENROWSET(
        BULK 'payment_type.json',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'CSV', -- Even for JSON
        PARSER_VERSION = '1.0',
        FIELDTERMINATOR = '0x0b',
        FIELDQUOTE = '0x0b',
        ROWTERMINATOR = '0x0a'
    ) 
    WITH(
        jsonDoc NVARCHAR(MAX)
    ) AS PaymentType


-- Check Percentage of Payment Type
SELECT
    payment_type
    ,COUNT(1) AS payment_type_count
    ,COUNT(1) * 100.0 / total_count AS payment_type_percentage
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=*/month=*/*.parquet',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'PARQUET'
    ) AS TripData
CROSS JOIN(
        SELECT COUNT(1) AS total_count
        FROM OPENROWSET(
            BULK 'trip_data_green_parquet/year=*/month=*/*.parquet',
            DATA_SOURCE = 'NYC_Taxi_Raw',
            FORMAT = 'PARQUET'
        ) AS TripData
    ) AS TotalCount
GROUP BY payment_type, total_count
ORDER BY payment_type ASC;