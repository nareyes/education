USE NYC_Taxi_Serverless
GO

-- Query CSV File w/ Additional Comma
-- ", Inc" Ignored
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'vendor_unquoted.csv',
        DATA_SOURCE = 'NYC_Taxi_File_Drop',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
) AS Vendor


-- Escape Character
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'vendor_escaped.csv',
        DATA_SOURCE = 'NYC_Taxi_File_Drop',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        ESCAPECHAR = '\'
) AS Vendor


-- Quote Character
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'vendor.csv',
        DATA_SOURCE = 'NYC_Taxi_File_Drop',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDQUOTE = '"' -- Optional. Default is ""
) AS Vendor