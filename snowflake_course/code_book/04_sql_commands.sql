----------------------------------------------------------------------------
-- Chapter 4: Exploring Snowflake SQL Commands, Data Types, and Functions --
----------------------------------------------------------------------------

---------------
-- prep work --
---------------

use role sysadmin;
use warehouse compute_wh;

create or replace database demo4_db;
create or replace schema subqueries;

create or replace table demo4_db.subqueries.derived (
    id integer
    ,amt integer
    ,total integer
);

insert into derived (id, amt, total)
    values 
    (1,1000,4000)
    ,(2,2000,3500)
    ,(3,3000, 9900)
    ,(4,4000,3000)
    ,(5,5000,3700)
    ,(6,6000,2222);

select * from demo4_db.subqueries.derived;

create or replace table demo4_db.subqueries.table2 (
    id integer
    ,amt integer
    ,total integer
);

insert into table2 (id, amt, total)
    values 
    (1,1000,8300)
    ,(2,1001,1900)
    ,(3,3000,4400)
    ,(4,1010,3535)
    ,(5,1200,3232)
    ,(6,1000,2222);

select * from demo4_db.subqueries.table2;


----------------
-- subqueries --
----------------

-- uncorrelated subquery (independent)
select
    id
    ,amt
from demo4_db.subqueries.derived
where amt = (
    select max(amt)
    from demo4_db.subqueries.table2
);


-- correlated subquery (dependent)
select
    id
    ,amt
from demo4_db.subqueries.derived
where amt = (
    select max(amt)
    from demo4_db.subqueries.table2
    where id = id
);

select
    id
    ,amt
from demo4_db.subqueries.derived
where amt > (
    select max(amt)
    from demo4_db.subqueries.table2
    where id = id
);

select
    id
    ,amt
from demo4_db.subqueries.derived
where amt > (
    select avg(amt)
    from demo4_db.subqueries.table2
    where id = id
);


-- derived columns
select
    id
    ,amt
    ,amt * 10 as amt1
    ,amt1 + 20 as amt2
from demo4_db.subqueries.derived;


-- derived column with subquery
select
    sub.id
    ,sub.amt
    ,sub.amt1
    ,sub.amt1 + 20 as amt2
from (
    select id, amt, amt * 10 as amt1
    from demo4_db.subqueries.derived
) as sub;


-- derived column with cte
with 

cte1 as (
    select 
        id
        ,amt
        ,amt * 10 as amt1
    from demo4_db.subqueries.derived
)

select
    a.id
    ,b.amt
    ,b.amt1
    ,b.amt1 + 20 as amt2
from demo4_db.subqueries.derived as a
    join cte1 as b
        on a.id = b.id;


----------------
-- data types --
----------------

-- fixed-point numbers (all stored as number)
use role sysadmin;
create or replace schema demo4_db.datatypes;
create or replace table numfixed (
    num       number
    ,num12    number(12, 0)
    ,decimal  decimal (10, 2)
    ,int      int
    ,integer  integer
);

desc table numfixed;


-- float numbers (all stored as float)
use role sysadmin;
use schema demo4_db.datatypes;
create or replace table numfloat (
    float    float
    ,double  double
    ,dp      double precision
    ,real    real
);

desc table numfloat;


-- strings (all stored as varchar)
use role sysadmin; 
use schema demo4_db.datatypes;
create or replace table textstring (
    varchar varchar
    ,v100     varchar(100)
    ,char     char
    ,c100     char(100)
    ,string   string
    ,s100     string(100)
    ,text     text
    ,t100     text(100)
);

desc table textstring;


--------------
-- clean up --
--------------

drop database demo4_db;