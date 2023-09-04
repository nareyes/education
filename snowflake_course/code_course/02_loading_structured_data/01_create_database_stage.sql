-- set context
use role sysadmin;

use warehouse compute_wh;


-- create managed object database
create or replace database manage_db;


-- create schema for external stage
create or replace schema manage_db.external_stage;


-- create external stage
-- use storage integration object in production env
create or replace stage manage_db.external_stage.aws_stage
    url = 's3://bucketsnowflakes3';
    -- credentials = (
    --     aws_key_id = '<>'
    --     aws_secret_key = '<>'
    -- );


-- describe stage
desc stage manage_db.external_stage.aws_stage;


-- list files in stage
list @manage_db.external_stage.aws_stage;