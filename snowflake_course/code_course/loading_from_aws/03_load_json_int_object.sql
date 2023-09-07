use role sysadmin;
use warehouse compute_wh;


-- create file format object
create or replace file format manage_db.public.json_format
    type = json;

desc file format manage_db.public.json_format;


-- create stage
create or replace stage manage_db.public.instrument_stage
    url = 's3://s3snowflakestorage/json/'
    storage_integration = s3_int
    file_format = manage_db.public.json_format;

list @manage_db.public.instrument_stage;


-- query stage to determine json format
select * from @manage_db.public.instrument_stage;


-- query stage with formatted columns
select 
    $1:asin::string as asin,
    $1:helpful as helpful,
    $1:overall as overall,
    $1:reviewtext::string as review_text,
    $1:reviewtime::string as review_time,
    date_from_parts (
        right ($1:reviewtime::string,4),
        left ($1:reviewtime::string,2),
        case 
            when substring ($1:reviewtime::string,5,1) = ','
            then substring ($1:reviewtime::string,4,1)
            else substring ($1:reviewtime::string,4,2)
        end
    ) as review_time_formatted,
    $1:reviewerid::string as reviewer_id,
    $1:reviewername::string as reviewer_name,
    $1:summary::string as summary,
    date($1:unixreviewtime::int) as unix_review_time
from @manage_db.public.instrument_stage;


-- create destination table
create or replace table demo_db.public.instrument_reviews (
    asin string,
    helpful string,
    overall string,
    review_text string,
    review_time date,
    reviewer_id string,
    reviewer_name string,
    summary string,
    unix_review_time date
);

select * from demo_db.public.instrument_reviews;


-- load transofrmed json data
copy into demo_db.public.instrument_reviews
    from (
        select 
            $1:asin::string as asin,
            $1:helpful as helpful,
            $1:overall as overall,
            $1:reviewtext::string as review_text,
            date_from_parts (
                right ($1:reviewtime::string,4),
                left ($1:reviewtime::string,2),
                case 
                    when substring ($1:reviewtime::string,5,1) = ','
                    then substring ($1:reviewtime::string,4,1)
                    else substring ($1:reviewtime::string,4,2)
                end
            ) as review_time,
            $1:reviewerid::string as reviewer_id,
            $1:reviewername::string as reviewer_name,
            $1:summary::string as summary,
            date($1:unixreviewtime::int) as unix_review_time
        from @manage_db.public.instrument_stage
    );


-- inspect data
select * from demo_db.public.instrument_reviews;