use role sysadmin;
use warehouse exercise_wh;


-- create stage
create or replace stage exercise_db.external_stage.json_stage
    url = 's3://snowflake-assignments-mc/unstructureddata/';

list @exercise_db.external_stage.json_stage;


-- create json file format
create or replace file format exercise_db.file_formats.json_format
    type = json;

desc file format exercise_db.file_formats.json_format;


-- create table
create or replace table exercise_db.public.job_skills_raw_json (
    raw_file variant
);


-- copy json data
copy into exercise_db.public.job_skills_raw_json
    from @exercise_db.external_stage.json_stage
    file_format = exercise_db.file_formats.json_format
    files = ('Jobskills.json');


-- inspect data
select * from exercise_db.public.job_skills_raw_json;