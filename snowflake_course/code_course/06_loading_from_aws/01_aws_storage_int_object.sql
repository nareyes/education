use role accountadmin;
use warehouse compute_wh;
 

-- create storage integration object
create or replace storage integration s3_int
    type = external_stage
    storage_provider = s3
    enabled = true
    storage_aws_role_arn = ''
    -- storage_allowed_locations = ('<cloud>://<bucket>/<path>/')
    storage_allowed_locations = ('s3://s3snowflakestorage/csv', 's3://s3snowflakestorage/json');


-- inspect storage integration properties
desc integration s3_int;