use role sysadmin;
use warehouse compute_wh;

-- create storage integration object
create or replace storage integration s3_int
    type = external_stage
    storage_provider = s3
    enabled = true
    storage_aws_role_arn = 'arn:aws:iam::929339109708:role/snowflake-access-role'
    storage_allowed_locations = ('s3://s3snowflakestorage/csv', 's3://s3snowflakestorage/json')
        comment = 'optional comment';


-- inspect storage integration properties
desc integration s3_int;