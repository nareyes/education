/*
- json file format 
- json file format options
- three methods of semi-structured data loading: elt, etl, automatic schema detection
- querying semi-structured data
- semi-structured functions
*/

--set context
use role sysadmin;
use database films_db;
use schema films_schema;


-- create json file format object with default options
create or replace file format json_file_format
    type = 'json',
    file_extension = null,
    date_format = 'auto',
    time_format = 'auto',
    timestamp_format = 'auto',
    binary_format = 'hex',
    trim_space = false,
    null_if = '',
    compression = 'auto',
    enable_octal = false,
    allow_duplicate = false,
    strip_outer_array = false,
    strip_null_values = false,
    ignore_utf8_errors = false,
    replace_invalid_characters = false,
    skip_byte_order_mark = true;


-- put command (execute from within snowsql)
use role sysadmin;
use database films_db;
use schema films_schema;

--put file://c:\users\admin\downloads\films.json @films_stage auto_compress=false;


-- create demo object
create or replace table films_elt (
    json_variant variant
);

copy into films_elt from @films_stage/films.json
    file_format = json_file_format;    

    
select json_variant from films_elt;


truncate table films_elt;


-- query semi-structured data type
select 
    json_variant:id as id, 
    json_variant:title as title, 
    json_variant:release_date as release_date, 
    json_variant:release_date::date as release_date_dd_cast, 
    to_date(json_variant:release_date) as release_date_func_cast,
    json_variant:actors as actors,
    json_variant:actors[0] as first_actor,
    json_variant:ratings as ratings,
    json_variant:ratings.imdb_rating as imdb_rating
from films_elt
where release_date >= date('2000-01-01');


-- query semi-structured data type - case sensitivity
select 
    json_variant:id as id, 
    json_variant:title as title, 
    json_variant:release_date::date as release_date, 
    json_variant:actors[0] as first_actor,
    json_variant:ratings.imdb_rating as imdb_rating
from films_elt
where release_date >= date('2000-01-01');


-- query semi-structured data type with bracket notation
select 
    json_variant['id'] as id, 
    json_variant['title'] as title, 
    json_variant['release_date']::date as release_date, 
    json_variant['actors'][0] as first_actor,
    json_variant['ratings']['imdb_rating'] as imdb_rating
from films_elt
where release_date >= date('2000-01-01');


-- flatten table function
select 
    json_variant:title, 
    json_variant:ratings 
from films_elt limit 1;

select * from table(flatten(input => select json_variant:ratings from films_elt limit 1)) ;

select value from table(flatten(input => select json_variant:ratings from films_elt limit 1));


-- lateral flatten
select 
    json_variant:title,
    json_variant:release_date::date,
    l.value 
from films_elt f,
lateral flatten(input => f.json_variant:ratings) l
limit 2;
 
create or replace table films_etl (
    id string, 
    title string, 
    release_date date, 
    stars array, 
    ratings object
);

copy into films_etl from (
    select
        $1:id,
        $1:title,
        $1:release_date::date,
        $1:actors,
        $1:ratings
    from @films_stage/films.json
)

    file_format = json_file_format
    force=true;

select * from films_etl;

select 
    id, 
    title, 
    release_date, 
    stars[0]::string as first_star, 
    ratings['imdb_rating'] as imdb_rating 
from films_etl;


-- match by column name
truncate table films_etl;

copy into films_etl
    from @films_stage/films.json
    file_format = json_file_format
    match_by_column_name = case_insensitive
    force = true;

select * from films_etl;


-- clean up
drop database films_db;