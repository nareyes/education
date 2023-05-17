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


-- Explore DATEDIFF
-- Determine Count of Trips per Hour Duration
SELECT
    DATEDIFF (MINUTE, lpep_pickup_datetime, lpep_dropoff_datetime) / 60 AS min_range_hour
    ,(DATEDIFF (MINUTE, lpep_pickup_datetime, lpep_dropoff_datetime) / 60) + 1 AS max_range_hour
    ,COUNT(1) AS trip_count
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=*/month=*/*.parquet',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'PARQUET'
    ) AS TripData
GROUP BY
    DATEDIFF (MINUTE, lpep_pickup_datetime, lpep_dropoff_datetime) / 60
    ,(DATEDIFF (MINUTE, lpep_pickup_datetime, lpep_dropoff_datetime) / 60) + 1
ORDER BY min_range_hour ASC;


/* In this case, we would want to delete the records where drop off is < pick up.
This is not possible and there are only 2 such records in the data.
*/