---------------------------------------------------------------------------
-- Chapter 3: Creating and Managing Snowflake Securable Database Objects --
---------------------------------------------------------------------------

-------------------------------------------
-- databases, schemas, tables, and views --
-------------------------------------------

-- set warehouse context
use warehouse data_engineer_wh;


-- create permanent database
-- context is set when created
use role sysadmin;
create or replace database demo3a_db;


-- create transient database
use role sysadmin;
create or replace transient database demo3b_db;


-- show database metadata
-- accountadmin inherits permissions to databases created by sysadmin
-- retention time (time travel) defaults to 1 day
use role accountadmin;
show databases;


-- update retention time
-- permanent databases can be set to a max of 90 (enterprise edition or higher)
-- transient databases can be set to a max of 1
use role sysadmin;
alter database demo3a_db set data_retention_time_in_days = 10;
-- alter database demo3b_db set data_retention_time_in_days = 10; -- will fail due to being a transient db

use role accountadmin;
show databases;


-- create tables
-- default table type is permanent for permanent db
-- default table type is transient for transient db
-- cannot create a permanent table in a transient db
use role sysadmin;

create or replace table demo3a_db.public.summary (
    cash_amt         number
    ,receivables_amt number
    ,customer_amt    number
); -- permanent table in permanent db, inherets retention time from db

create or replace transient table demo3a_db.public.summary_transient (
    cash_amt         number
    ,receivables_amt number
    ,customer_amt    number
); -- transient table in permanent db, retention time set to max of 1 day for transient tables

create or replace table demo3b_db.public.summary (
    cash_amt         number
    ,receivables_amt number
    ,customer_amt    number
); -- transient table in transient db, transient by default (does not need to be specified)

use database demo3a_db;
show tables;

use database demo3b_db;
show tables;


-- create schema using context
use role sysadmin;
use database demo3a_db;
create or replace schema banking;


-- create schema using fully qualified name (preferred)
use role sysadmin;
create or replace schema demo3a_db.banking;

show schemas;

-- change schema retention time
-- schema inherits database configuration, but can be manually set
use role accountadmin;
alter schema demo3a_db.banking
    set data_retention_time_in_days = 1;

show schemas;


-- move existing table to a different schema
use role sysadmin;
create or replace schema demo3b_db.banking;
alter table demo3b_db.public.summary
    rename to demo3b_db.banking.summary;


-- create managed access schema
use role sysadmin;
create or replace schema demo3a_db.mschema with managed access;

show schemas;


-- information schema account views
-- returns account level metadata even though context is set to a specified db
use role accountadmin;
select * from snowflake_sample_data.information_schema.applicable_roles;
select * from snowflake_sample_data.information_schema.databases;
select * from snowflake_sample_data.information_schema.enabled_roles;
select * from snowflake_sample_data.information_schema.information_schema_catalog_name;
select * from snowflake_sample_data.information_schema.load_history;
select * from snowflake_sample_data.information_schema.replication_databases;


-- information schema database views
select * from snowflake_sample_data.information_schema.columns;
select * from snowflake_sample_data.information_schema.external_tables;
select * from snowflake_sample_data.information_schema.file_formats;
select * from snowflake_sample_data.information_schema.functions;
select * from snowflake_sample_data.information_schema.object_privileges;
select * from snowflake_sample_data.information_schema.pipes;
select * from snowflake_sample_data.information_schema.procedures;
select * from snowflake_sample_data.information_schema.referential_constraints;
select * from snowflake_sample_data.information_schema.schemata;
select * from snowflake_sample_data.information_schema.sequences;
select * from snowflake_sample_data.information_schema.stages;
select * from snowflake_sample_data.information_schema.table_constraints;
select * from snowflake_sample_data.information_schema.table_privileges;
select * from snowflake_sample_data.information_schema.table_storage_metrics;
select * from snowflake_sample_data.information_schema.tables;
select * from snowflake_sample_data.information_schema.usage_privileges;
select * from snowflake_sample_data.information_schema.views;


    -- using information schema to return column metadata for a specified table
    select * from snowflake_sample_data.information_schema.columns
    where table_schema = 'TPCH_SF100' and table_name = 'LINEITEM'
    order by ordinal_position asc;

    -- alternative with less metadata
    desc table snowflake_sample_data.tpch_sf100.lineitem;


-- account_usage warehouse metering history (track credits used over time)
use role accountadmin;

select
    start_time::date as usage_date
    ,warehouse_name
    ,sum (credits_used) as total_credits_consumed
from snowflake.account_usage.warehouse_metering_history
where start_time >= date_trunc(month, current_date)
group by usage_date, warehouse_name
order by warehouse_name, usage_date;

select
    warehouse_name
    ,sum (credits_used) as total_credits_consumed
    ,(total_credits_consumed / 250) * 100 as per_monthly_budget
from snowflake.account_usage.warehouse_metering_history
where start_time >= date_trunc(month, current_date)
group by warehouse_name
order by warehouse_name;


-- create tables
use role sysadmin;

create or replace schema demo3a_db.banking;

create or replace table demo3a_db.banking.customer_acct (
    customer_account    int
    ,amount             int 
    ,transaction_ts     timestamp
);

create or replace table demo3a_db.banking.cash (
    customer_account    int
    ,amount             int 
    ,transaction_ts     timestamp
);

create or replace table demo3a_db.banking.receivables (
    customer_account    int
    ,amount             int 
    ,transaction_ts     timestamp
);

use database demo3a_db;
use schema banking;
show tables;


-- create non-materialized and materialized views
use role sysadmin;

create or replace view demo3b_db.banking.summary_vw as
    select * from demo3b_db.banking.summary; -- non-materialized default

create or replace materialized view demo3b_db.banking.summary_mvw as
    select * from demo3b_db.banking.summary; -- limitation: joins not supported

use database demo3b_db;
use schema banking;
show views;
show materialized views;

describe view demo3b_db.banking.summary_vw;
describe view demo3b_db.banking.summary_mvw;


-----------------------------------
-- stage and file format objects --
-----------------------------------

-- create basic file format object
use role sysadmin;
use database demo3b_db;
use schema banking;

create or replace file format ff_json
    type = json;

show file formats;


-- create basic internal named stage
use role sysadmin;
use database demo3b_db;
use schema banking;

create or replace temporary stage banking_stg
    file_format = ff_json;

show stages;


-------------------
-- udfs and udtf --
-------------------

-- create function to return properties available for javascript udf's and procedures
use role sysadmin;

create or replace database demo3c_db;
create or replace function js_properties()
    returns string
    language javascript
    as $$ return Object.getOwnPropertyNames(this); $$;

select js_properties();


-- create simple udf
use role sysadmin;
use database demo3c_db;

create or replace function factorial(n variant)
    returns variant
    language javascript
    as
        'var f=n;
        for (i=n-1; i>0; i--) {
            f=f*i
        }
        return f';

select factorial(5);
-- select factorial(34); -- fails due to udf size/depth limitations


-- create sample data for udtf example
use role sysadmin;
create or replace database demo3d_db;
create or replace table demo3d_db.public.sales as (
    select * from snowflake_sample_data.tpcds_sf100tcl.web_sales
    limit 100000
);

select * from demo3d_db.public.sales;


-- create udtf
use role sysadmin;
create or replace secure function demo3d_db.public.get_mktbasket(input_web_site_sk number(38)) 
returns table (
    input_item number(38, 0)
    ,basket_item number(38, 0)
    ,baskets number(38, 0)
) as 
    'select
        input_web_site_sk
        ,ws_web_site_sk as basket_item
        ,count (distinct ws_order_number) as baskets
    from demo3d_db.public.sales
    where ws_order_number in (
        select ws_order_number
        from demo3d_db.public.sales
        where ws_web_site_sk = input_web_site_sk
    )
    group by ws_web_site_sk
    order by baskets desc, basket_item asc';

select * from table(demo3d_db.public.get_mktbasket(1));
select * from table(demo3d_db.public.get_mktbasket(2));


-----------------------
-- stored procedures --
-----------------------

-- create simple procedure
use role sysadmin;
create or replace database demo3e_db;
create or replace procedure storedproc_demo(user_input varchar) 
    returns string not null 
    language javascript as
        $$
        var input_argument = USER_INPUT;
        var result = `${input_argument}` 
        return result;
        $$;

call storedproc_demo('test user input');

-- return procedure info
select * from demo3e_db.information_schema.procedures;

-- create complex procedures for accounting example
-- documentation:
    /* the deposit procedure processes deposits, taking a float account number and amount, 
    then inserts these into cash and customer_acct tables, enhancing respective balances with a current timestamp.
    
    the withdrawal procedure processes account withdrawals by accepting float account number and amount, 
    debiting the customer's account, and crediting the cash account, with both actions timestamped.
    
    the loan_payment procedure processes loan payments using float account number and amount, 
    depositing into cash and reducing receivables with a corresponding negative entry, timestamp included.
    
    the transactions_summary procedure summarizes transactions by first clearing the summary table, 
    then inserting calculated sums of cash, receivables, and customer_acct into it, reflecting total balances. */

-- deposit transaction sproc
use role sysadmin; 
use database demo3a_db; 
use schema banking;
create or replace procedure deposit(param_acct float, param_amt float)
    returns string 
    language javascript as 
        $$
        var ret_val = ""; var cmd_debit = ""; var cmd_credit = "";
        // insert data into tables
        cmd_debit = "insert into demo3a_db.banking.cash values ("+ PARAM_ACCT + "," + PARAM_AMT + ",current_timestamp());";
        cmd_credit = "insert into demo3a_db.banking.customer_acct values ("+ PARAM_ACCT + "," + PARAM_AMT + ",current_timestamp());";
        // begin transaction 
        snowflake.execute ({sqlText: cmd_debit});
        snowflake.execute ({sqlText: cmd_credit});
            ret_val = "Deposit Transaction Succeeded";  
        return ret_val;
        $$;

call deposit(21, 100);

    -- inspect tables 
    select * from demo3a_db.banking.cash;
    select * from demo3a_db.banking.customer_acct;


-- withdrawal transaction sproc
use role sysadmin;
use database demo3a_db; 
use schema banking;
create or replace procedure withdrawal(param_acct float, param_amt float)
    returns string 
    language javascript as 
        $$
        var ret_val = "";  var cmd_debit = "";  var cmd_credit = "";
        // insert data into tables
        cmd_debit = "insert into demo3a_db.banking.customer_acct values ("+ PARAM_ACCT + "," + (-PARAM_AMT) + ",current_timestamp());";
        cmd_credit = "insert into demo3a_db.banking.cash values ("+ PARAM_ACCT + "," + (-PARAM_AMT) + ",current_timestamp());";
        // begin transaction 
        snowflake.execute ({sqlText: cmd_debit});
        snowflake.execute ({sqlText: cmd_credit});
            ret_val = "Withdrawal Transaction Succeeded";
        return ret_val;
        $$;

call withdrawal(21, 50);

    -- inspect tables
    select * from demo3a_db.banking.cash;
    select * from demo3a_db.banking.customer_acct;


-- loan payment transaction sproc
use role sysadmin;
use database demo3a_db; 
use schema banking;
create or replace procedure loan_payment(param_acct float, param_amt float)
    returns string 
    language javascript as 
        $$
        var ret_val = "";  var cmd_debit = "";  var cmd_credit = "";
        // insert data into the tables
        cmd_debit = "insert into demo3a_db.banking.cash values ("+ PARAM_ACCT + "," + PARAM_AMT + ",current_timestamp());";
        cmd_credit = "insert into demo3a_db.banking.receivables values ("+ PARAM_ACCT + "," +(-PARAM_AMT) + ",current_timestamp());";     
        // begin transaction 
        snowflake.execute ({sqlText: cmd_debit});                 
        snowflake.execute ({sqlText: cmd_credit});
    	    ret_val = "Loan Payment Transaction Succeeded";  
        return ret_val;
        $$;

call loan_payment(21, 20);

    -- inspect tables
    use role sysadmin; 

    select * from demo3a_db.banking.cash;
    select * from demo3a_db.banking.receivables;


-- transaction summary sproc
use role sysadmin; 
use database demo3b_db; 
use schema banking;
create or replace procedure transactions_summary()
    returns string 
    language javascript as
        $$
        var cmd_truncate = "truncate table if exists demo3b_db.banking.summary;"
        var sql = snowflake.createStatement({sqlText: cmd_truncate});
        // summarize cash amount  
        var cmd_cash = "insert into demo3b_db.banking.summary (cash_amt)
            select sum(amount) from demo3a_db.banking.cash;"
        var sql = snowflake.createStatement({sqlText: cmd_cash});
        // summarize receivables amount
        var cmd_receivables = "insert into demo3b_db.banking.summary (receivables_amt)
            select sum(amount) from demo3a_db.banking.receivables;"
        var sql = snowflake.createStatement({sqlText: cmd_receivables});
        // summarize customer account amount
        var cmd_customer = "insert into demo3b_db.banking.summary (customer_amt)
            select sum(amount) from demo3a_db.banking.customer_acct;"
        var sql = snowflake.createStatement({sqlText: cmd_customer});
        // begin transaction 
        snowflake.execute ({sqlText: cmd_truncate});                 
        snowflake.execute ({sqlText: cmd_cash});
        snowflake.execute ({sqlText: cmd_receivables});
        snowflake.execute ({sqlText: cmd_customer});
        ret_val = "Transactions Successfully Summarized";  
        return ret_val;
        $$;

call transactions_summary();

    -- inspect table
    select * from demo3b_db.banking.summary;


-- truncate base tables
use role sysadmin; 
truncate table demo3a_db.banking.customer_acct;
truncate table demo3a_db.banking.cash;
truncate table demo3a_db.banking.receivables;

-- use procedure to input transactions
use role sysadmin;
use database demo3a_db;
use schema banking;
call deposit(21, 10000);
call deposit(21, 400);
call loan_payment(14, 1000);
call withdrawal(21, 500);
call deposit(72, 4000);
call withdrawal(21, 250);

-- generate summary
use role sysadmin;
use database demo3b_db; 
use schema banking;
call transactions_summary();

-- view results
use role sysadmin; 
use database demo3b_db;
use schema banking;
select * from demo3b_db.banking.summary;

-- both mvw and standard view remain in sync with base table
select * from demo3b_db.banking.summary_mvw;
select * from demo3b_db.banking.summary_vw;


-- create procedure to drop database 
use role sysadmin;
use database demo3e_db;
create or replace procedure drop_db(db_name varchar)
    returns string 
    language javascript as 
    $$
    var cmd = "drop database " + DB_NAME + ";"
    var sql = snowflake.createStatement({sqlText: cmd});
    var result = sql.execute();

    return DB_NAME + " Database Successfully Dropped";
    $$;

call drop_db('demo3a_db');


-- create task to use drop_db procedure at later time
use role sysadmin;
use database demo3e_db;
create or replace task demo_tsk
    warehouse = data_engineer_wh
    schedule = '2 minute'
    as
        call drop_db('demo3b_db');


    -- grant permission to execute task 
    use role accountadmin;
    grant execute task on account to role sysadmin;

    -- resume task
    use role sysadmin;
    alter task if exists demo_tsk resume;

    -- query information schema to see task is scheduled
    use role sysadmin;
    select * from table(
        information_schema.task_history(
            task_name => 'demo_tsk',
            scheduled_time_range_start =>
            dateadd('hour', -1, current_timestamp())
        )
    );

    -- suspend task
    use role sysadmin;
    alter task if exists demo_tsk suspend;



---------------------------
-- sequences and streams --
---------------------------

-- create sequence
use role sysadmin;
use database demo3e_db;

create or replace sequence seq_01
    start = 1
    increment = 1;

select seq_01.nextval; -- 1
select seq_01.nextval; -- 2
select seq_01.nextval; -- 3
select seq_01.nextval; -- 4
select seq_01.nextval; -- 5

create or replace sequence seq_02
    start = 2
    increment = 2;
    
select seq_02.nextval; -- 2
select seq_02.nextval; -- 4
select seq_02.nextval; -- 6
select seq_02.nextval; -- 8
select seq_02.nextval; -- 10


-- create stream
use role sysadmin;
create or replace database demo3f_db;
create or replace schema banking;

create or replace table demo3f_db.banking.branch (
    id      varchar
    ,city   varchar
    ,amount number (20,2)
);

insert into demo3f_db.banking.branch (id, city, amount)
    values
    (12001, 'Abilene', 5387.97),
    (12002, 'Barstow', 34478.10),
    (12003, 'Cadbury', 8994.63);

select * from branch;
/*ID	CITY	AMOUNT
12001	Abilene	5,387.97
12002	Barstow	34,478.1
12003	Cadbury	8,994.63 */

create or replace stream stream_a on table demo3f_db.banking.branch;
show streams;


-- query streams (empty until inserts)
select * from demo3f_db.banking.stream_a;


-- insert new records
insert into demo3f_db.banking.branch (id, city, amount)
    values
    (12004, 'Denton', 41242.93),
    (12005, 'Everett', 6175.22),
    (12006, 'Fargo', 443689.75);


    -- query table and stream
    select * from  demo3f_db.banking.branch;
    /* ID	CITY	AMOUNT
    12001	Abilene	5387.97
    12002	Barstow	34478.1
    12003	Cadbury	8994.63
    12004	Denton	41242.93
    12005	Everett	6175.22
    12006	Fargo	443689.75 */

    select * from  demo3f_db.banking.stream_a; 
    /* ID	CITY	AMOUNT	    METADATA$ACTION	METADATA$ISUPDATE	METADATA$ROW_ID
    12004	Denton	41,242.93	INSERT	        FALSE	            204bea9462d1662f53415b8c7eea0b5e58fcba12
    12005	Everett	6,175.22	INSERT	        FALSE	            2a63e637f63d4428efbd17ccdc6ea8915f99dcba
    12006	Fargo	443,689.75	INSERT	        FALSE	            88f2a54c430bc34b12bfd3ecc40b4e6bdb57b9da */


-- insert new records again
insert into demo3f_db.banking.branch (id, city, amount)
    values
    (12007, 'Galveston', 351247.79),
    (12008, 'Houston', 817011.27);


    -- query table and stream
    select * from  demo3f_db.banking.branch;
    /* ID	CITY	  AMOUNT
    12001	Abilene	  5387.97
    12002	Barstow	  34478.1
    12003	Cadbury	  8994.63
    12004	Denton	  41242.93
    12005	Everett	  6175.22
    12006	Fargo	  443689.75
    12007	Galveston 351247.79
    12008	Houston	  817011.27 */

    select * from  demo3f_db.banking.stream_a; 
    /* ID	CITY	  AMOUNT	METADATA$ACTION	METADATA$ISUPDATE	METADATA$ROW_ID
    12004	Denton	  41242.93	INSERT	        FALSE	            afb2f66ad97ad71a99ffb5af03bbd6f2cbc588dc
    12005	Everett	  6175.22	INSERT	        FALSE	            4389ab45dc01dc691a2e42a15cc0d42ccb2deb3c
    12006	Fargo	  443689.75	INSERT	        FALSE	            c5dcb465da1ce62978e451a5a5ac47fa4012b65e
    12007	Galveston 351247.79	INSERT	        FALSE	            ebc40c57c2d4b9f5d9add8fa3665c39f0547304c
    12008	Houston	  817011.27	INSERT	        FALSE	            c73f3e3505da25f94b82fbc62705d23ebdf28c62 */


-- delete records
delete from demo3f_db.banking.branch where id = 12001; -- inserted before stream created
delete from demo3f_db.banking.branch where id = 12004; -- inserted after stream created
delete from demo3f_db.banking.branch where id = 12007; -- inserted after stream created


    -- query table and stream
    select * from demo3f_db.banking.branch;
    /* ID	CITY	AMOUNT
    12002	Barstow	34478.1
    12003	Cadbury	8994.63
    12005	Everett	6175.22
    12006	Fargo	443689.75
    12008	Houston	817011.27 */

    select * from demo3f_db.banking.stream_a;
        /* ID	CITY	  AMOUNT	METADATA$ACTION	METADATA$ISUPDATE	METADATA$ROW_ID
        12005	Everett	  6175.22	INSERT	        FALSE	            4389ab45dc01dc691a2e42a15cc0d42ccb2deb3c
        12006	Fargo	  443689.75	INSERT	        FALSE	            c5dcb465da1ce62978e451a5a5ac47fa4012b65e
        12008	Houston	  817011.27	INSERT	        FALSE	            c73f3e3505da25f94b82fbc62705d23ebdf28c62 
        12001	Abilene	  5387.97	DELETE	        FALSE	            4eb47a2fdb36b4c760369331fb571bcda5112309 */


-- update record
update demo3f_db.banking.branch
    set city = 'Fayetteville'
    where id = 12002;


    -- query table and stream
    select * from demo3f_db.banking.branch;
    /* ID	CITY	     AMOUNT
    12002	Fayetteville 34478.1
    12003	Cadbury	     8994.63
    12005	Everett	     6175.22
    12006	Fargo        443689.75
    12008	Houston	     817011.27 */

    select * from demo3f_db.banking.stream_a;
    /* ID	CITY	        AMOUNT	  METADATA$ACTION	METADATA$ISUPDATE	METADATA$ROW_ID
    12002	Fayetteville	34478.1	  INSERT	        TRUE	            4f89e873b2b60f25225282b6203682367fca4160
    12005	Everett	        6175.22	  INSERT	        FALSE	            3073ef3123ed35fe445eac7affc6c5b340b490f0
    12006	Fargo	        443689.75 INSERT	        FALSE	            b62956f5bef94d31668da391eb1ad3b8c4d0533a
    12008	Houston	        817011.27 INSERT	        FALSE	            4d2b6565edcc8b282cf1f2de3222527b64dabd61
    12002	Barstow	        34478.1	  DELETE	        TRUE	            4f89e873b2b60f25225282b6203682367fca4160
    12001	Abilene 	    5387.97	  DELETE	        FALSE	            4cc06a70168e62950ba875736bd8bbf9e2f3aa37 */


-----------
-- tasks --
-----------

-- create demo table and stream, insert records
use role accountadmin; -- preferable to create a taskadmin role
use warehouse data_engineer_wh;
use database demo3f_db;
create or replace schema tasksdemo;

create or replace table demo3f_db.tasksdemo.product (
    prod_id   int,
    prod_desc varchar(),
    category  varchar(30),
    segment   varchar(20),
    mfg_id    int,
    mfg_name  varchar(50)
);

insert into demo3f_db.tasksdemo.product
    values
    (1201, 'Product 1201', 'Category 1201', 'Segment 1201', '1201', 'Mfg 1201'),
    (1202, 'Product 1202', 'Category 1202', 'Segment 1202', '1202', 'Mfg 1202'),
    (1203, 'Product 1203', 'Category 1203', 'Segment 1203', '1203', 'Mfg 1203'),
    (1204, 'Product 1204', 'Category 1204', 'Segment 1204', '1204', 'Mfg 1204'),
    (1205, 'Product 1205', 'Category 1205', 'Segment 1205', '1205', 'Mfg 1205'),
    (1206, 'Product 1206', 'Category 1206', 'Segment 1206', '1206', 'Mfg 1206');

select * from demo3f_db.tasksdemo.product;

create or replace table demo3f_db.tasksdemo.sales (
  prod_id  int,
  customer varchar(),
  zip      varchar(),
  qty      int,
  revenue  decimal(10,2)
);

create or replace stream demo3f_db.tasksdemo.sales_stream
    on table demo3f_db.tasksdemo.sales
    append_only = true;

insert into demo3f_db.tasksdemo.sales
    values
    (1201, 'Amy Johnson', 45466, 45, 2345.67),
    (1201, 'Harold Robinson', 89701, 45, 2345.67),
    (1203, 'Chad Norton', 33236, 45, 2345.67),
    (1206, 'Horatio Simon', 75148, 45, 2345.67),
    (1205, 'Misty Crawford', 10001, 45, 2345.67);

select * from demo3f_db.tasksdemo.sales;
select * from demo3f_db.tasksdemo.sales_stream;

create or replace table demo3f_db.tasksdemo.sales_transact (
    prod_id    int,
    prod_desc  varchar(),
    category   varchar(30),
    segment    varchar(20),
    mfg_id     int,
    mfg_name   varchar(50),
    customer   varchar(),
    zip        varchar(),
    qty        int,
    revenue    decimal (10, 2),
    ts         timestamp
);

insert into demo3f_db.tasksdemo.sales_transact
    select
        s.prod_id
        ,p.prod_desc
        ,p.category
        ,p.segment
        ,p.mfg_id,
        p.mfg_name
        ,s.customer
        ,s.zip
        ,s.qty
        ,s.revenue
        ,current_timestamp
    from demo3f_db.tasksdemo.sales_stream as s
        inner join demo3f_db.tasksdemo.product as p 
            on s.prod_id = p.prod_id;

select * from demo3f_db.tasksdemo.sales_transact;


-- create task
create or replace task demo3f_db.tasksdemo.sales_task
    warehouse = compute_wh 
    schedule  = '1 minute'
    when system$stream_has_data('demo3f_db.tasksdemo.sales_stream')
    as
        insert into demo3f_db.tasksdemo.sales_transact
            select
                s.prod_id
                ,p.prod_desc
                ,p.category
                ,p.segment
                ,p.mfg_id,
                p.mfg_name
                ,s.customer
                ,s.zip
                ,s.qty
                ,s.revenue
                ,current_timestamp
            from demo3f_db.tasksdemo.sales_stream as s
                inner join demo3f_db.tasksdemo.product as p 
                    on s.prod_id = p.prod_id;
    
alter task demo3f_db.tasksdemo.sales_task resume;

insert into demo3f_db.tasksdemo.sales 
    values
    (1201, 'Edward Jameson', 45466, 45, 2345.67),
    (1201, 'Margaret Volt', 89701, 45, 2345.67),
    (1203, 'Antoine Lancaster', 33236, 45, 2345.67),
    (1204, 'Esther Baker', 75148, 45, 2345.67),
    (1206, 'Quintin Anderson', 10001, 45, 2345.67);

select * from demo3f_db.tasksdemo.sales_stream;
select * from demo3f_db.tasksdemo.sales_transact;

alter task demo3f_db.tasksdemo.sales_task suspend;


--------------
-- clean up --
--------------

use role sysadmin;
-- drop database demo3a_db; 
-- drop database demo3b_db;
drop database demo3c_db; 
drop database demo3d_db;
drop database demo3e_db; 
drop database demo3f_db;