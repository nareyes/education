/* copy syntax
https://docs.snowflake.com/en/sql-reference/sql/copy-into-table

-- standard data load 
copy into [<namespace>.]<table_name>
    from { internalstage | externalstage | externallocation }
    [ files = ( '<file_name>' [ , '<file_name>' ] [ , ... ] ) ]
    [ pattern = '<regex_pattern>' ]
    [ file_format = ( { format_name = '[<namespace>.]<file_format_name>' |
                        type = { csv | json | avro | orc | parquet | xml } [ formattypeoptions ] } ) ]
    [ copyoptions ]
    [ validation_mode = return_<n>_rows | return_errors | return_all_errors ]

-- data load with transformation 
copy into [<namespace>.]<table_name> [ ( <col_name> [ , <col_name> ... ] ) ]
    from ( select [<alias>.]$<file_col_num>[.<element>] [ , [<alias>.]$<file_col_num>[.<element>] ... ]
        from { internalstage | externalstage } )
    [ files = ( '<file_name>' [ , '<file_name>' ] [ , ... ] ) ]
    [ pattern = '<regex_pattern>' ]
    [ file_format = ( { format_name = '[<namespace>.]<file_format_name>' |
                        type = { csv | json | avro | orc | parquet | xml } [ formattypeoptions ] } ) ]
    [ copyoptions ]

-- copy options
copyoptions ::=
    on_error = { continue | skip_file | skip_file_<num> | 'skip_file_<num>%' | abort_statement }
    size_limit = <num>
    purge = true | false
    return_failed_only = true | false
    match_by_column_name = case_sensitive | case_insensitive | none
    enforce_length = true | false
    truncatecolumns = true | false
    force = true | false
    load_uncertain_files = true | false
*/


use role accountadmin;
use warehouse compute_wh;


-- create table
create or replace table demo_db.public.orders_validate (
    order_id varchar(30),
    amount varchar(30),
    profit int,
    quantity int,
    category varchar(30),
    subcategory varchar(30)
);


-- prepare stage object
create or replace stage manage_db.public.aws_stage_validate
    url = 's3://snowflakebucket-copyoption/size/';

list @manage_db.public.aws_stage_validate;


-- validate data using copy command and return_errors (data is not loaded)
copy into demo_db.public.orders_validate
    from @manage_db.public.aws_stage_validate
    file_format = manage_db.file_formats.csv_format
    files = ('Orders.csv', 'Orders2.csv')
    validation_mode = return_errors;


-- verify no data has been laoded
select * from demo_db.public.orders_validate;


-- validate data using copy command and return n rows (data is not loaded)
copy into demo_db.public.orders_validate
    from @manage_db.public.aws_stage_validate
    file_format = manage_db.file_formats.csv_format
    files = ('Orders.csv', 'Orders2.csv')
    validation_mode = return_5_rows;


-- verify no data has been laoded
select * from demo_db.public.orders_validate;