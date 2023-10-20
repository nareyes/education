/*
- file formats
- file format options
- copy into <table> statement
- copy into <table> copy options
- copy into <table> load transformation
- copy into <table> load validation
*/

--set context
use role sysadmin;
use database films_db;
use schema films_schema;

select 
    $1, $2, $3 
from @films_stage/films.csv (file_format => 'csv_file_format');


-- reading file error
copy into films from @films_stage/films.csv;


-- set file format options directly on copy into statement
copy into films from @films_stage/films.csv
    file_format = (
        type = 'csv' 
        skip_header = 1
    );

    
-- set file format object on copy into statement
copy into films from @films_stage/films.csv
    file_format = csv_file_format;

    
-- set file format object on stage
alter stage films_stage set file_format = csv_file_format;

copy into films from @films_stage/films.csv force = true;


-- copy from table stage
copy into films from @%films/films.csv force = true;


-- set file format on table stage
alter table films set stage_file_format = (format_name = 'csv_file_format');

copy into films from @%films/films.csv force = true;


-- files copy option
copy into films from @films_stage
    file_format = csv_file_format
    files = ('films.csv')
    force = true;

-- pattern copy option
copy into films from @films_stage
    file_format = csv_file_format
    pattern = '.*[.]csv'
    force = true;

    
-- omit columns
copy into films (id, title) from ( 
    select 
         $1,
         $2
    from @%films/films.csv)
    file_format = csv_file_format
    force = true;
    

-- cast columns
copy into films from ( 
    select 
        $1,
        $2,
        to_date($3)
    from @%films/films.csv)
    file_format = csv_file_format
    force = true;
    

-- reorder columns
copy into films from ( 
    select 
        $2,
        $1,
        date($3)
    from @%films/films.csv)
    file_format = csv_file_format
    force = true;


-- validation mode copy option. possible values: return_<number>_rows, return_errors, return_all_errors
copy into films from @films_stage/films.csv
    validation_mode = 'return_rows';

    
-- validate function to validate historical copy into execution via query id
copy into films from @films_stage
    file_format = (type='csv', skip_header=0)
    on_error = continue
    files = ('films.csv')
    force = true;

select * from table(validate(films, job_id=>'<failed_job_id>'));