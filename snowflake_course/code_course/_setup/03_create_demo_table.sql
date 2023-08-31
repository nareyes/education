use database demo_db;

-- create demo table
create or replace table demo_db.demo_schema.loan_payment (
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

-- query table
select * from demo_db.demo_schema.loan_payment;

-- load data from aws s3
copy into demo_db.demo_schema.loan_payment
    from 's3://bucketsnowflakes3/Loan_payments_data.csv'
    file_format = (
        type = csv 
        field_delimiter = ','
        skip_header = 1
    );

-- validate data
select * from demo_db.demo_schema.loan_payment;