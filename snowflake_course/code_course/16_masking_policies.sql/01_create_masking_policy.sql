use role accountadmin;
use warehouse compute_wh;


-- create table 
create or replace table demo_db.public.customers_mask (
    id number,
    full_name varchar,
    email varchar,
    phone varchar,
    spent number,
    created_date date default current_date
);


-- insert values
insert into demo_db.public.customers_mask (id, full_name, email, phone, spent)
    values
      (1, 'Lewiss MacDwyer', 'lmacdwyer0@un.org', '262-665-9168', 140),
      (2, 'Ty Pettingall' ,'tpettingall1@mayoclinic.com', '734-987-7120', 254),
      (3, 'Marlee Spadazzi' ,'mspadazzi2@txnews.com', '867-946-3659', 120),
      (4, 'Heywood Tearney' ,'htearney3@patch.com', '563-853-8192', 1230),
      (5, 'Odilia Seti' ,'oseti4@globo.com', '730-451-8637', 143),
      (6, 'Meggie Washtell' ,'mwashtell5@rediff.com', '568-896-6138', 600);


-- create roles
create or replace role analyst_masked;
create or replace role analyst_full;


-- grant select on table to roles
grant select on table demo_db.public.customers_mask to role analyst_masked;
grant select on table demo_db.public.customers_mask to role analyst_full;


-- grant database access to roles
grant usage on database demo_db to role analyst_masked;
grant usage on database demo_db to role analyst_full;


-- grant schema access to roles
grant usage on schema demo_db.public to role analyst_masked;
grant usage on schema demo_db.public to role analyst_full;


-- grant warehouse access to roles
grant usage on warehouse compute_wh to role analyst_masked;
grant usage on warehouse compute_wh to role analyst_full;


-- assign roles to a user
grant role analyst_masked to user nareyes;
grant role analyst_full to user nareyes;


-- set up masking policy
create or replace masking policy demo_db.public.phone
    as (val varchar) returns varchar ->
        case
            when current_role() in ('analyst_full', 'accountadmin') then val
            else '###-###-###'
        end;


-- apply policy on specific column
alter table if exists demo_db.public.customers_mask
    modify column phone
    set masking policy demo_db.public.phone;


-- validate policies
use role analyst_full;
select * from demo_db.public.customers_mask;

use role analyst_masked;
select * from demo_db.public.customers_mask;