-------------------------------------------
-- Chapter 6: Data Loading and Unloading --
-------------------------------------------

---------------
-- prep work --
---------------

use role sysadmin;
use warehouse compute_wh;

create or replace database demo6_db
    comment = "database for all chapter 6 examples";
create or replace schema ws 
    comment = "schema for worksheet insert examples";
create or replace schema ui 
    comment = "schema for web ui uploads";
create or replace schema snow 
    comment = "schema for snowsql loads";
create or replace warehouse load_wh
    comment = "warehouse for ch 6 load examples";

-- create demo csv table
-- ID,F_NAME,L_NAME,CITY
-- 1,Anthony,Robinson,Atlanta
-- 2,Peggy,Mathison,Birmingham
-- 3,Marshall,Baker,Chicago
-- 4,Kevin,Cline,Denver


----------------------
-- data loading sql --
----------------------

-- create a new database and schema to be used for examples 
use warehouse load_wh;
use database demo6_db;
use schema ws; 

-- create table for single-row inserts for structured data
create or replace table table1
    (id integer, f_name string, l_name string, city string)
comment = "single-row insert for structured data
    using explicitly specified values";
 
-- insert values into the table and confirm there is one row of data in the table 
insert into table1 (id, f_name, l_name, city)
values (1, 'anthony', 'robinson', 'atlanta');
select * from table1;

-- insert another row and confirm
insert into table1 (id, f_name, l_name, city)
values (2, 'peggy', 'mathison', 'birmingham');
select * from table1;

-- create a table to be used for semi-structured datra
create or replace table table2
    (id integer, variant1 variant)
comment = "single-row insert for semi-structured json data";

-- use a query clause to insert values and confirm there is one row of data
insert into table2 (id, variant1)
select 1, parse_json(' {"f_name": "anthony", "l_name": "robinson",
 "city": "atlanta" } ');
select * from table2;

-- insert another row of data
insert into table2 (id, variant1)
select 2, parse_json(' {"f_name": "peggy", "l_name": "mathison",
 "city": "birmingham" } ');
select * from table2;

-- create a new table and insert two rows of data at one time
create or replace table table3
    (id integer, f_name string, l_name string, city string)
comment = "multi-row insert for structured data using explicitly stated values";
insert into table3 (id, f_name, l_name, city) values
    (1, 'anthony', 'robinson', 'atlanta'), (2, 'peggy', 'mathison',
    'birmingham');
select * from table3;

-- create a new table and insert only specific records form an existing table
create or replace table table4
    (id integer, f_name string, l_name string, city string)
comment = "multi-row insert for structured data using query, all columns same";
insert into table4 (id, f_name, l_name, city)
    select * from table3 where contains (city, 'atlanta');
select * from table4;

-- create a new table 
create or replace table table5
    (id integer, f_name string, l_name string, city string)
comment = "multi-row insert for structured data using query, fewer columns";

-- attempt to insert fewer column values in the new table than from the existing table without specifying columns
-- error is expected
-- insert into table5
--  (id, f_name, l_name) select * from table3 where contains (city, 'atlanta');
 
--  insert fewer column values in the new table than from the existing table
insert into table5 (id, f_name, l_name)
    select id, f_name, l_name from table3 where contains (city, 'atlanta');
select * from table5;

-- create a table and insert values that will be used in next example
create or replace table table6
    (id integer, first_name string, last_name string, city_name string)
comment = "table to be used as part of next demo";

insert into table6 (id, first_name, last_name, city_name) values
    (1, 'anthony', 'robinson', 'atlanta'),
    (2, 'peggy', 'mathison', 'birmingham');
 
-- create a new table and use cte 
create or replace table table7
    (id integer, f_name string, l_name string, city string)
comment = "multi-row insert for structured data using cte"; 

insert into table7 (id, f_name, l_name, city)
    with cte as
    (select id, first_name as f_name, last_name as l_name,
        city_name as city from table6)
    select id, f_name, l_name, city
    from cte;
select * from table7;

-- create a new table that will be used in next example
create or replace table table8
    (id integer, f_name string, l_name string, zip_code string)
comment = "table to be used as part of next demo";
insert into table8 (id, f_name, l_name, zip_code)
values (1, 'anthony', 'robinson', '30301'), (2, 'peggy', 'mathison', '35005');

-- create another table that will be used in the next example
create or replace table table9
(id integer, zip_code string, city string, state string)
comment = "table to be used as part of next demo";
insert into table9 (id, zip_code, city, state) values
    (1, '30301', 'atlanta', 'georgia'),
    (2, '35005', 'birmingham', 'alabama');
 
-- create a new table to use for inserting records using an ineer join  
create or replace table table10
    (id integer, f_name string, l_name string, city string,
    state string, zip_code string)
comment = "multi-row inserts from two tables using an inner join on zip_code";

insert into table10 (id, f_name, l_name, city, state, zip_code)
select a.id, a.f_name, a.l_name, b.city, b.state, a.zip_code
from table8 a
    inner join table9 b on a.zip_code = b.zip_code;
select *from table10;
 
-- create a new table to be used for semi-structured data 
create or replace table table11
    (variant1 variant)
comment = "multi-row insert for semi-structured json data";

-- insert values into the table
insert into table11
 select parse_json(column1)
 from values
 ('{ "_id": "1",
 "name": { "first": "anthony", "last": "robinson" },
 "company": "pascal",
 "email": "anthony@pascal.com",
 "phone": "+1 (999) 444-2222"}'),
 ('{ "id": "2",
 "name": { "first": "peggy", "last": "mathison" },
 "company": "ada",
 "email": "peggy@ada.com",
 "phone": "+1 (999) 555-3333"}');
select * from table11;

-- create a source table and insert values
create or replace table table12
(id integer, first_name string, last_name string, city_name string)
comment = "source table to be used as part of next demo for unconditional table
inserts";
insert into table12 (id, first_name, last_name, city_name) values
(1, 'anthony', 'robinson', 'atlanta'), (2, 'peggy', 'mathison', 'birmingham');

-- create two target tables
create or replace table table13
(id integer, f_name string, l_name string, city string)
comment = "unconditional table insert - destination table 1 for unconditional
    multi-table insert";

create or replace table table14
(id integer, f_name string, l_name string, city string)
comment = "unconditional table insert - destination table 2 for unconditional
    multi-table insert";

-- use data from table 12 to insert into two tables -- one insertion for all data and another insertion for select values`
insert all
    into table13
    into table13 (id, f_name, l_name, city)
        values (id, last_name, first_name, default)
    into table14 (id, f_name, l_name, city)
    into table14 values (id, city_name, last_name, first_name)
select id, first_name, last_name, city_name from table12;

-- look at data in table13
select * from table13;

-- look at data in table14
select * from table14;

-- create a source table for the next example and insert values
create or replace table table15
(id integer, first_name string, last_name string, city_name string)
comment = "source table to be used as part of next demo for
    conditional multi-table insert";
insert into table15 (id, first_name, last_name, city_name)
values
(1, 'anthony', 'robinson', 'atlanta'),
(2, 'peggy', 'mathison', 'birmingham'),
(3, 'marshall', 'baker', 'chicago'),(4, 'kevin', 'cline', 'denver'),
(5, 'amy', 'ranger', 'everly'),(6, 'andy', 'murray', 'fresno');

-- create two target tables
create or replace table table16
    (id integer, f_name string, l_name string, city string)
comment = "destination table 1 for conditional multi-table insert";

create or replace table table17
    (id integer, f_name string, l_name string, city string)
comment = "destination table 2 for conditional multi-table insert";

-- demonstration of a conditional multitable insert
insert all
    when id <5 then
        into table16
    when id <3 then
        into table16
        into table17
    when id = 1 then
        into table16 (id, f_name) values (id, first_name)
    else
        into table17
select id, first_name, last_name, city_name from table15;

-- look at data in table16
select * from table16;

-- look at data in table17
select * from table17;

-- create a table to be used for the next example
create or replace table table18
 (array variant)
comment = "insert array";

-- insert values into table18
insert into table18
select array_insert(array_construct(0, 1, 2, 3), 4, 4);

-- see the data in table18
select * from table18;

-- insert values in a different position
insert into table18
select array_insert(array_construct(0, 1, 2, 3), 7, 4);

-- see the data in table18
select * from table18;

-- create a new table to be used for next example
create or replace table table19
    (object variant)
comment = "insert object";

-- insert key-value pairs
insert into table19
    select object_insert(object_construct('a', 1, 'b', 2, 'c', 3), 'd', 4);
select * from table19;

-- insert values with blank value and different types of null values
insert into table19 select
    object_insert(object_construct('a', 1, 'b', 2, 'c', 3), 'd', ' ');
insert into table19 select
    object_insert(object_construct('a', 1, 'b', 2, 'c', 3), 'd', 'null');
insert into table19 select
    object_insert(object_construct('a', 1, 'b', 2, 'c', 3), 'd', null);
insert into table19 select
    object_insert(object_construct('a', 1, 'b', 2, 'c', 3), null, 'd');
select * from table19;

-- review the table comments
show tables like '%table%';


---------------------
-- data loading ui --
---------------------

-- create the table to be used for the next example
use schema ui;
create or replace table table20
    (id integer, f_name string, l_name string, city string)
comment = "load structured data file via the web ui wizard";

-- manually load data using snowsight ui as described in the chapter

-- confirm that the data was uploaded
use database demo6_db;
use schema ui;
select * from table20;


---------------------------
-- data loading snow sql --
---------------------------

-- install snowsql

-- run commands from cli (be mindful of case)

-- snowsql -a gu14977.us-east-2.aws -u nreyes 

-- use role accountadmin;
-- use warehouse load_wh;
-- use database demo6_db;
-- use schema snow;

-- create or replace table table20 (id integer, f_name string, l_name string, city string);

-- put file:///users/<file_path> @"DEMO6_DB"."SNOW".%"TABLE20";
-- put file:///users/nick/table20.csv @"DEMO6_DB"."SNOW".%"TABLE20";

-- copy into "TABLE20" FROM @"DEMO6_DB"."SNOW".%"TABLE20" file_format=(type=csv skip_header=1);

-- select * from table20;

-- !quit OR !q

-- confirm that the data was uploaded
use role accountadmin;
use database demo6_db;
use schema snow;
select * from table20;


--------------
-- clean up --
--------------

use role sysadmin;
use warehouse compute_wh;
drop warehouse load_wh;
drop database demo6_db;