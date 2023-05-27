USE NYC_Taxi_Serverless
GO

CREATE OR ALTER PROCEDURE Processed.InsertCalendar

AS

BEGIN

    -- Calendar
    IF OBJECT_ID ('Processed.Calendar') IS NOT NULL
        DROP EXTERNAL TABLE Processed.Calendar;

    CREATE EXTERNAL TABLE Processed.Calendar

        WITH (
            LOCATION = 'calendar'
            ,DATA_SOURCE = NYC_Taxi_Processed
            ,FILE_FORMAT = Parquet_File_Format
        )

    AS

        SELECT
            *
        FROM
            OPENROWSET (
                BULK 'calendar.csv'
                ,DATA_SOURCE = 'NYC_Taxi_Raw'
                ,FORMAT = 'CSV'
                ,PARSER_VERSION = '2.0'
                ,FIRSTROW = 2
            )

            WITH (
                DateKey         INT         1
                ,Date           DATE        2
                ,Year           SMALLINT    3
                ,Month          TINYINT     4
                ,Day            TINYINT     5
                ,DayName        VARCHAR(10) 6
                ,DayOfYear      SMALLINT    7
                ,WeekOfMonth    TINYINT     8
                ,WeekOfYear     TINYINT     9
                ,MonthName      VARCHAR(10) 10
                ,YearMonth      INT         11
                ,YearWeek       INT         12
            ) AS Calendar

END;