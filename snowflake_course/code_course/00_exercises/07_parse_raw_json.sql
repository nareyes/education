use role sysadmin;
use warehouse exercise_wh;


-- inspect raw data from prior worksheet
select raw_file
from exercise_db.public.job_skills_raw_json
limit 10;


-- parse first_name, last_name, and skills
select
    raw_file: first_name:: string as first_name,
    raw_file: last_name:: string as last_name,
    raw_file: Skills[0]:: string as skill_1,
    raw_file: Skills[1]:: string as skill_2
from exercise_db.public.job_skills_raw_json;


-- create table
create or replace table exercise_db.public.job_skills as
    select
        raw_file: first_name:: string as first_name,
        raw_file: last_name:: string as last_name,
        raw_file: Skills[0]:: string as skill_1,
        raw_file: Skills[1]:: string as skill_2
    from exercise_db.public.job_skills_raw_json;


-- query table
select *
from exercise_db.public.job_skills
where first_name = 'Florina';










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


-- querying array with nested data
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