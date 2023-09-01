use warehouse compute_wh;


-- create new stage
create or replace stage manage_db.external_stage.aws_stage_error
    url = 's3://bucketsnowflakes4';

list @manage_db.external_stage.aws_stage_error;


-- create table
create or replace table demo_db.public.order_details_errors (
    order_id varchar(30),
    amount int,
    profit int,
    quanitty int,
    category varchar(30),
    subcategory varchar(30)
);


-- load data without error handling (aborts entire load if an error is caused from any file)
copy into demo_db.public.order_details_errors
    from @manage_db.external_stage.aws_stage_error
    file_format = (
        type = csv
        field_delimiter = ','
        skip_header = 1
    )
    files = ('OrderDetails_error.csv', 'OrderDetails_error2.csv');


-- load data with continue on error (skips loading records that cause error and outputs load metadata)
copy into demo_db.public.order_details_errors
    from @manage_db.external_stage.aws_stage_error
    file_format = (
        type = csv
        field_delimiter = ','
        skip_header = 1
    )
    files = ('OrderDetails_error.csv', 'orderdetails_error2.csv')
    on_error = 'continue';

truncate table demo_db.public.order_details_errors;


-- load data with abort on error (aborts entire load if an error is caused from any file)
copy into demo_db.public.order_details_errors
    from @manage_db.external_stage.aws_stage_error
    file_format = (
        type = csv
        field_delimiter = ','
        skip_header = 1
    )
    files = ('OrderDetails_error.csv', 'OrderDetails_error2.csv')
    on_error = 'abort_statement';

truncate table demo_db.public.order_details_errors;


-- load data with skip file on error (skips file if there is an error and outputs load metadata)
copy into demo_db.public.order_details_errors
    from @manage_db.external_stage.aws_stage_error
    file_format = (
        type = csv
        field_delimiter = ','
        skip_header = 1
    )
    files = ('OrderDetails_error.csv', 'OrderDetails_error2.csv')
    on_error = 'skip_file';

truncate table demo_db.public.order_details_errors;


-- copy data with skip file on error (skips file if there is n errors and outputs load metadata)
copy into demo_db.public.order_details_errors
    from @manage_db.external_stage.aws_stage_error
    file_format = (
        type = csv
        field_delimiter = ','
        skip_header = 1
    )
    files = ('OrderDetails_error.csv', 'OrderDetails_error2.csv')
    on_error = 'skip_file_3'; -- specify number of errors to skip

truncate table demo_db.public.order_details_errors;


-- load data with skip file on error (skips file if there is n% errors)
copy into demo_db.public.order_details_errors
    from @manage_db.external_stage.aws_stage_error
    file_format = (
        type = csv
        field_delimiter = ','
        skip_header = 1
    )
    files = ('OrderDetails_error.csv', 'OrderDetails_error2.csv')
    on_error = 'skip_file_1%'; -- specify percentage of errors to skip

truncate table demo_db.public.order_details_errors;


-- clean up
drop table if exists demo_db.public.order_details_errors;