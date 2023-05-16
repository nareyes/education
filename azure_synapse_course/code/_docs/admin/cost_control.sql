-- Data Processed
SELECT * FROM sys.dm_external_data_processed;

-- Current Cost Control Settings
SELECT * FROM sys.configurations
WHERE Name LIKE 'Data Processed%';

-- Set Cost Control Limits
sp_set_data_processed_limit
    @type = N'daily',
    @limit_tb = 1;

sp_set_data_processed_limit
    @type = N'weekly',
    @limit_tb = 1;

sp_set_data_processed_limit
    @type = N'monthly',
    @limit_tb = 2;