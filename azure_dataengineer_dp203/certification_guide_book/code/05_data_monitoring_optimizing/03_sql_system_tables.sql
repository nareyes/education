-- Querying the system tables
-- Synapse SQL Pool provides the following system tables that can be used to monitor the query performance:

-- sys.dm_pdw_exec_requests – contains all the current and recently active requests in Azure Synapse Analytics. It contains details like total_elapsed_time, submit_time, start_time, end_time, command, result_cache_hit and so on.
SELECT * FROM sys.dm_pdw_exec_requests;

-- sys.dm_pdw_waits – contains details of the wait states in a query, including locks and waits on transmission queues. 
SELECT * FROM sys.dm_pdw_waits;


-- Enable query store for Synapse SQL
ALTER DATABASE <database_name> 
SET QUERY_STORE = ON (OPERATION_MODE = READ_WRITE);


-- Query Store System Tables
-- Query detailes
SELECT * FROM sys.query_store_query;
SELECT * FROM sys.query_store_query_text;

-- Plan Details
SELECT * FROM sys.query_store_plan;

-- Runtime statistics
SELECT * FROM sys.query_store_runtime_stats;
SELECT * FROM sys.query_store_runtime_stats_interval;