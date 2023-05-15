USE NYC_Taxi_Serverless
GO

-- Query Trip Type TSV File
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'trip_type.tsv',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'CSV',
        FIELDTERMINATOR = '\t',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
) AS TripType


-- Query Trip Type Data Types
EXEC sp_describe_first_result_set N'
    SELECT
        TOP 100 *
    FROM
        OPENROWSET(
            BULK ''trip_type.tsv'',
            DATA_SOURCE = ''NYC_Taxi_Raw'',
            FORMAT = ''CSV'',
            FIELDTERMINATOR = ''\t'',
            PARSER_VERSION = ''2.0'',
            HEADER_ROW = TRUE
    ) AS TripType
'


-- Query Trip Type TSV File w/ Optimizaed Data Types and Size
SELECT
    *
FROM
    OPENROWSET(
        BULK 'trip_type.tsv',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'CSV',
        FIELDTERMINATOR = '\t',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    )
    WITH(
        TripType                SMALLINT    1
        ,TripTypeDescription    VARCHAR(25) 2
    ) AS TripType