-- MAZIMIZE AUTOMATIC CACHING
-- AUTOMATIC CACHING TAKES PLACE WHEN QUERYS ARE RE-RUN
-- RESULTS ARE CACHED FOR 24 HOURS OR UNTIL UNDERLYING DATA HAS CHANGED
-- ENSURE SIMILAR QUERIES ARE RAN UNDER SAME WAREHOUSE FOR OPTIMAL CACHING


-- RUN QUERY
SELECT AVG (C_BIRTH_YEAR)
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER;
-- INITIAL ATTEMPT (DURATION = 2.8 SECONDS)
-- SECOND ATTEMPT (DURATION = 131 MILISECONDS)