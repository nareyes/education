use role accountadmin;
use warehouse compute_wh; 


-- create table
create or replace table demo_db.public.movie_titles (
    show_id string,
    type string,
    title string,
    director string,
    cast string,
    country string,
    date_added string,
    release_year string,
    rating string,
    duration string,
    listed_in string,
    description string
);


-- create file format object
create or replace file format manage_db.file_formats.csv_format
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('null', 'null')
    empty_field_as_null = true
    field_optionally_enclosed_by = '"';

desc file format manage_db.file_formats.csv_format;


-- create stage
create or replace stage manage_db.external_stage.netflix_stage
    url = 's3://s3snowflakestorage/csv/'
    storage_integration = s3_int
    file_format = manage_db.file_formats.csv_format;

list @manage_db.external_stage.netflix_stage;


-- load data
copy into demo_db.public.movie_titles
    from @manage_db.external_stage.netflix_stage
    files = ('netflix_titles.csv');


-- inspect data
select * from demo_db.public.movie_titles;