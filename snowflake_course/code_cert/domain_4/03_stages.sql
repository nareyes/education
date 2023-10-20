/*
- stage types
- listing staged data files
- put command
- querying staged data files
- removing staged data files
*/

--set context
use role sysadmin;


-- create demo objects
create database films_db;

create schema films_schema;

create table films (
    id string, 
    title string, 
    release_date date
);


-- internal stages
-- list contents of user stage (contains worksheet data)
ls @~;
list @~;


-- list contents of table stage 
ls @%films;


-- create internal named stage
create stage films_stage;


-- list contents of internal named stage 
ls @films_stage;


-- external stages
-- create external stage 
create stage external_stage
  url = 's3://<bucket_name>/path1/'
  storage_integration = s3_int;

-- create storage integration object
create storage integration s3_int
  type = external_stage
  storage_provider = s3
  storage_aws_role_arn = 'arn:aws:iam::001234567890:role/<aws_role_name>'
  enabled = true
  storage_allowed_locations = ('s3://<bucket_name>/path1/', 's3://<bucket_name>/path2/');
  
  
-- put command (execute from within snowsql)
use role sysadmin;
use database films_db;
use schema films_schema;

-- put file://c:\users\admin\downloads\films.csv @~ auto_compress=false;
-- put file://c:\users\admin\downloads\films.csv @%films auto_compress=false;
-- put file://c:\users\admin\downloads\films.csv @films_stage auto_compress=false;

ls @~/films.csv;

ls @%films; 

ls @films_stage;


-- contents of a stage can be queried
select $1, $2, $3 from @~/films.csv;


-- create csv file format to parse files in stage
create file format csv_file_format
  type = csv
  skip_header = 1;

  
-- metadata columns and file format
select 
    metadata$filename, 
    metadata$file_row_number, 
    $1, $2, $3 
from @%films (file_format => 'csv_file_format');


-- pattern
select 
    metadata$filename, 
    metadata$file_row_number, 
    $1, $2, $3 
from @films_stage (file_format => 'csv_file_format', pattern=>'.*[.]csv') t;


-- path
select 
    metadata$filename, 
    metadata$file_row_number, 
    $1, $2, $3 
from @films_stage/films.csv (file_format => 'csv_file_format') t;


-- remove file from stage
rm @~/films.csv;
rm @%films; 
rm @films_stage;
remove @~/films.csv;