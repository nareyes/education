use role sysadmin;
use warehouse compute_wh;


-- create stage
create or replace stage manage_db.external_stage.json_stage
    url = 's3://bucketsnowflake-jsondemo/';

list @manage_db.external_stage.json_stage;


-- create json file format
create or replace file format manage_db.file_formats.json_format
    type = json;

desc file format manage_db.file_formats.json_format;


-- create table
create or replace table demo_db.public.hr_raw_json (
    raw_file variant
);


-- copy json data
copy into demo_db.public.hr_raw_json
    from @manage_db.external_stage.json_stage
    file_format = manage_db.file_formats.json_format
    files = ('HR_data.json');


-- inspect data
select * from demo_db.public.hr_raw_json;