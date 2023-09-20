use role accountadmin;
use warehouse compute_wh;


-- create table
create or replace table demo_db.public.order_details_profit (
    id number autoincrement start 1 increment 1, -- identity column
    order_id varchar(30),
    amount int,
    profit int,
    profit_flag varchar(30)
);


-- load data with transformation
copy into demo_db.public.order_details_profit (order_id, amount, profit, profit_flag)
    from (
        select
            s.$1, -- $1 is the first column in the file
            s.$2,
            s.$3,
            case
                when cast (s.$3 as int) < 0 then 'Not Profitable'
                when cast (s.$3 as int) = 0 then 'Break Even'
                else 'Profitable'
            end
        from @manage_db.external_stage.aws_stage as s
    )
    
    file_format = (
        type = csv
        field_delimiter = ','
        skip_header = 1
    )
    
    files = ('OrderDetails.csv');


-- inspect data
select * from demo_db.public.order_details_profit
limit 10;

select
    profit_flag,
    avg (amount) as avg_amount,
    avg (profit) as avg_profit
from demo_db.public.order_details_profit
group by profit_flag
order by profit_flag asc;