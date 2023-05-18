-- Query Session ID
SELECT DB_NAME(database_id), 'kill '+ CAST(session_id AS VARCHAR(10)), *
    FROM sys.dm_exec_sessions
    WHERE DB_NAME(database_id) NOT IN ('master')
    ORDER BY 1;


-- Kill Session ID
KILL <session_id>;