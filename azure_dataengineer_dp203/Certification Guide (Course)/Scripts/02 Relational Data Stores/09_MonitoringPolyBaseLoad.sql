-- Check the progress of the PolyBase load
-- Should see 60 WRITER threads
SELECT *
FROM SYS.DM_PDW_EXEC_REQUESTS AS R 
    JOIN SYS.DM_PDW_DMS_WORKERS AS W
        ON R.Request_ID = W.Request_ID
WHERE R.[Label] = 'Load [prod].[FactTransactionHistory]'
ORDER BY W.Start_Time DESC;