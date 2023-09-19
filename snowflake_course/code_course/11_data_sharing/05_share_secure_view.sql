use role accountadmin;
use warehouse compute_wh;


-- create secure view
-- only secure views can be shared
create or replace secure view demo_db_share.public.customer_view as (
    select
        first_name,
        last_name,
        email
    from demo_db.public.customers
    where job != 'data scientist'
);


-- create share object
use role accountadmin;
create or replace share customer_share;


-- grant usage
grant usage on database demo_db_share to share customer_share;
grant usage on schema demo_db_share.public to share customer_share;


-- grant select permission on view
grant select on view  demo_db_share.public.customer_view to share customer_share;


-- add account to share
alter share customer_share
    add account = <'account-id'>