--------------------------------------------------------------
-- Chapter 10: Configuring and Managing Secure Data Sharing --
--------------------------------------------------------------

---------------
-- prep work --
---------------

use role accountadmin;
use warehouse compute_wh;
create or replace database demo10_db;
use schema demo10_db.public;
create or replace table sharingdata (i integer);


-------------------
-- direct shares --
-------------------

-- create share
use role accountadmin;
create or replace share demo10_share2;
grant usage on database demo10_db to share demo10_share2;
grant usage on schema demo10_db.public to share demo10_share2;
grant select on table demo10_db.public.sharingdata to share demo10_share2;

-- add accounts to share
alter share <name_of_share> add accounts = <name_of_consumer_account>;

-- create share with rls
-- setup
use role accountadmin;
use database demo10_db;
create or replace schema private;

create or replace table demo10_db.private.sensitive_data  (
    nation string,     
    price float,
    size int,
    id string
);

insert into demo10_db.private.sensitive_data 
    values('usa', 123.5, 10,'region1'),
          ('usa', 89.2, 14, 'region1'),
          ('can', 99.0, 35, 'region2'),
          ('can', 58.0, 22, 'region2'),
          ('mex', 112.6,18, 'region2'),
          ('mex', 144.2,15, 'region2'),
          ('ire', 96.8, 22, 'region3'),
          ('ire', 107.4,19, 'region3');

create or replace table demo10_db.private.sharing_access 
    (id string,snowflake_account string);

insert into sharing_access values('region1', current_account());
insert into sharing_access values('region2', 'acct2'); -- replace acct2 with actual accountname
insert into sharing_access values('region3', 'acct3'); -- replace acct3 with actual accountname

select * from sharing_access;

create or replace secure view demo10_db.public.paid_sensitive_data as
    select nation, price, size
    from demo10_db.private.sensitive_data sd
    join demo10_db.private.sharing_access sa on sd.id = sa.id
    and sa.snowflake_account = current_account();

grant select on demo10_db.public.paid_sensitive_data to public;

-- testing
select * from demo10_db.private.sensitive_data;

select * from demo10_db.public.paid_sensitive_data;

alter session set simulated_data_sharing_consumer='acct2';
select * from demo10_db.public.paid_sensitive_data;

alter session set simulated_data_sharing_consumer='acct3';
select * from demo10_db.public.paid_sensitive_data;

-- create share
use role accountadmin;
use database demo10_db;
use schema demo10_db.public;
create or replace share nations_shared;
show shares;

grant usage on database demo10_db to share nations_shared;
grant usage on schema demo10_db.public to share nations_shared;
grant select on demo10_db.public.paid_sensitive_data to share nations_shared;

alter session unset simulated_data_sharing_consumer;

show grants to share nations_shared;

-- alter share nations_shared add accounts = <account>, <account>;

show grants of share nations_shared;


--------------------
-- inbound shares --
--------------------

-- create database from share
create database <name_of_new_database> from share <name_of_inbound_share>;


--------------
-- clean up --
--------------
use role accountadmin;
revoke usage on database demo10_db from share nations_shared;
revoke usage on database demo10_db from share demo10_share;
revoke usage on database demo10_db from share demo10_share2;
drop database demo10_db;