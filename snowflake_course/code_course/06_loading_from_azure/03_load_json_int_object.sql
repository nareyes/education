use role sysadmin;
use warehouse compute_wh; 


-- create file format object
create or replace file format manage_db.file_formats.json_format
    type = json;

desc file format manage_db.file_formats.json_format;


-- create stage
create or replace stage manage_db.external_stage.azure_stage
    url = 'azure://snowflakestoracct.blob.core.windows.net/json/'
    storage_integration = azure_int
    file_format = manage_db.file_formats.json_format;

list @manage_db.external_stage.instrument_stage;


-- query stage to determine json format
select * from @manage_db.external_stage.azure_stage;


-- query stage with formatted columns
select 
    $1:"car model"::string as car_model, 
    $1:"car model year"::int as car_model_year,
    $1:"car make"::string as car_make, 
    $1:"first_name"::string as first_name,
    $1:"last_name"::string as last_name
from @manage_db.external_stage.azure_stage; 


-- create destination table
create or replace table demo_db.public.car_owner (
    car_model varchar,
    car_model_year int,
    car_make varchar,
    first_name varchar,
    last_name varchar
);

select * from demo_db.public.car_owner;


-- load data
copy into demo_db.public.car_owner
from (
    select 
        $1:"car model"::string as car_model, 
        $1:"car model year"::int as car_model_year,
        $1:"car make"::string as car_make, 
        $1:"first_name"::string as first_name,
        $1:"last_name"::string as last_name
    from @manage_db.external_stage.azure_stage
);


-- inspect data
select * from demo_db.public.car_owner;