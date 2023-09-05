use role sysadmin;
use warehouse compute_wh;


-- inspect raw data from prior worksheet
select raw_file
from demo_db.public.hr_raw_json
limit 10;


-- querying raw data
select
    $1: city, -- shorthand, $1 references the first column (raw_file) in this case
    raw_file: first_name
from demo_db.public.hr_raw_json;


-- querying raw data and formatting
select
    raw_file: id:: int as id,
    raw_file: first_name:: string as first_name,
    raw_file: last_name:: string as last_name,
    raw_file: gender:: string as gender
from demo_db.public.hr_raw_json;


-- querying nested objects
select raw_file: job as job -- nested objects
from demo_db.public.hr_raw_json;

select
    raw_file: id:: int as id,
    raw_file: first_name:: string as first_name,
    raw_file: last_name:: string as last_name,
    raw_file: gender:: string as gender,
    raw_file: job.title:: string as job_title,
    raw_file: job.salary:: float as salary
from demo_db.public.hr_raw_json;


-- querying nested array
select raw_file: prev_company as prev_company
from demo_db.public.hr_raw_json;

select
    raw_file: id:: int as id,
    raw_file: first_name:: string as first_name,
    raw_file: last_name:: string as last_name,
    raw_file: job.title:: string as job_title,
    raw_file: prev_company[0]:: string as prev_company_1,
    raw_file: prev_company[1]:: string as prev_company_2,
    raw_file: prev_company[2]:: string as prev_company_3,
    array_size (raw_file: prev_company) as prev_company_count
from demo_db.public.hr_raw_json
order by id asc;


-- querying nested array (additional example)
select raw_file: spoken_languages as spoken_languages
from demo_db.public.hr_raw_json;


-- querying array with nested objects
select
    raw_file: id:: int as id,
    raw_file: first_name:: string as first_name,
    raw_file: last_name:: string as last_name,
    raw_file: spoken_languages[0].language:: string as language_1,
    raw_file: spoken_languages[0].level:: string as language_1_level,
    raw_file: spoken_languages[1].language:: string as language_2,
    raw_file: spoken_languages[1].level:: string as language_2_level,
    raw_file: spoken_languages[2].language:: string as language_3,
    raw_file: spoken_languages[2].level:: string as language_3_level
from demo_db.public.hr_raw_json
order by id asc;



-- create table as to insert parsed data (example 1)
create or replace table demo_db.public.employee_salary as 
    select
        raw_file: id:: int as id,
        raw_file: first_name:: string as first_name,
        raw_file: last_name:: string as last_name,
        raw_file: gender:: string as gender,
        raw_file: job.title:: string as job_title,
        raw_file: job.salary:: float as salary,
        raw_file: prev_company[0]:: string as prev_company_1,
        raw_file: prev_company[1]:: string as prev_company_2,
        raw_file: prev_company[2]:: string as prev_company_3
    from demo_db.public.hr_raw_json;


-- inspect data (example 1)
select * from demo_db.public.employee_salary;


-- create table and insert parsed data (example 2)
create or replace table demo_db.public.employee_languages (
    id int,
    first_name varchar(30),
    last_name varchar(30),
    gender varchar(30),
    language_1 varchar(30),
    language_1_level varchar(30),
    language_2 varchar(30),
    language_2_level varchar(30),
    language_3 varchar(30),
    language_3_level varchar(30)
);

insert into demo_db.public.employee_languages (
    select
        raw_file: id:: int as id,
        raw_file: first_name:: string as first_name,
        raw_file: last_name:: string as last_name,
        raw_file: gender:: string as gender,
        raw_file: spoken_languages[0].language:: string as language_1,
        raw_file: spoken_languages[0].level:: string as language_1_level,
        raw_file: spoken_languages[1].language:: string as language_2,
        raw_file: spoken_languages[1].level:: string as language_2_level,
        raw_file: spoken_languages[2].language:: string as language_3,
        raw_file: spoken_languages[2].level:: string as language_3_level
    from demo_db.public.hr_raw_json
    where raw_file: prev_company[0] is not null
);


-- inspect data (example 2)
select * from demo_db.public.employee_languages;