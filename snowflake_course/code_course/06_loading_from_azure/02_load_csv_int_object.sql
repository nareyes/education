use role sysadmin;
use warehouse compute_wh; 


-- create file format object
create or replace file format manage_db.file_formats.csv_format
    type = csv
    field_delimiter = ','
    skip_header = 1;

desc file format manage_db.file_formats.csv_format;


-- create stage
create or replace stage manage_db.external_stage.azure_stage
    url = 'azure://snowflakestoracct.blob.core.windows.net/csv/'
    storage_integration = azure_int
    file_format = manage_db.file_formats.csv_format;

list @manage_db.external_stage.azure_stage;


-- query data from stage
select 
    $1,
    $2,
    $3,
    $4,
    $5,
    $6,
    $7,
    $8,
    $9,
    $10,
    $11,
    $12,
    $13,
    $14,
    $15,
    $16,
    $17,
    $18,
    $19,
    $20
from @manage_db.external_stage.azure_stage;


-- create table
create or replace table demo_db.public.happiness_2021 (
    country_name varchar,
    regional_indicator varchar,
    ladder_score number(4,3),
    standard_error number(4,3),
    upper_whisker number(4,3),
    lower_whisker number(4,3),
    logged_gdp number(5,3),
    social_support number(4,3),
    healthy_life_expectancy number(5,3),
    freedom_to_make_life_choices number(4,3),
    generosity number(4,3),
    perceptions_of_corruption number(4,3),
    ladder_score_in_dystopia number(4,3),
    explained_by_log_gdp_per_capita number(4,3),
    explained_by_social_support number(4,3),
    explained_by_healthy_life_expectancy number(4,3),
    explained_by_freedom_to_make_life_choices number(4,3),
    explained_by_generosity number(4,3),
    explained_by_perceptions_of_corruption number(4,3),
    dystopia_result number(4,3)
);


-- load data
copy into demo_db.public.happiness_2021
    from @manage_db.external_stage.azure_stage
    files = ('world_happiness_report_2021.csv');


-- inspect data
select * from demo_db.public.movie_titles;