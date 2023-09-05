use role sysadmin;
use warehouse compute_wh;


-- create table
create or replace table demo_db.public.order_details (
    order_id varchar(30),
    amount int,
    profit int,
    quantity int,
    category varchar(30),
    subcategory varchar(30)
);


-- inspect stage (created prior notebook)
list @manage_db.external_stage.aws_stage;


-- load data
copy into demo_db.public.order_details
    from @manage_db.external_stage.aws_stage
    files = ('OrderDetails.csv')
    file_format = (
        type = csv
        field_delimiter = ','
        skip_header = 1
    );


-- inspect data
select * from demo_db.public.order_details
limit 10;

select
    category,
    sum (amount) as total_amount,
    sum (profit) as total_profit
from demo_db.public.order_details
group by category
order by category asc