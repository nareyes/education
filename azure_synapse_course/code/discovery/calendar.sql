USE NYC_Taxi_Serverless
GO


SELECT
    *
FROM
    OPENROWSET(
        BULK 'calendar.csv',
        DATA_SOURCE = 'NYC_Taxi_File_Drop',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        FIRSTROW = 2
    ) 
    WITH(
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