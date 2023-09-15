use role accountadmin;
use warehouse compute_wh;


-- create storage integration object
create or replace storage integration azure_int
    type = external_stage
    storage_provider = azure
    enabled = true
    azure_tenant_id = ''
    -- storage_allowed_locations = ('<cloud>://<bucket>/<path>/')
    storage_allowed_locations = ('azure://snowflakestoracct.blob.core.windows.net/csv', 'azure://snowflakestoracct.blob.core.windows.net/json');


-- inspect storage integration properties
desc storage integration azure_int;