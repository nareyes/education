use role accountadmin;
use warehouse compute_wh;


-- create table
create or replace table demo_db.public.loan_payment (
    loan_id string,
    loan_status string,
    principal string,
    terms string,
    effective_date string,
    due_date string,
    paid_off_time string,
    past_due_days string,
    age string,
    education string,
    gender string
);


-- load data
copy into demo_db.public.loan_payment
    from 's3://bucketsnowflakes3/Loan_payments_data.csv'
    file_format = manage_db.file_formats.csv_format;
    
    
-- inspect data
select * from demo_db.public.loan_payment
limit 10;