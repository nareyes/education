use role accountadmin;
use warehouse compute_wh;


-- list policies
desc masking policy demo_db.public.phone;
show masking policies;


-- query columns with applied policies
select *
from table (demo_db.information_schema.policy_references (policy_name => 'phone'));


-- remove policy
alter table if exists demo_db.public.customers_mask
    modify column phone
    unset masking policy;


-- create new policy
create or replace masking policy demo_db.public.full_name
    as (val varchar) returns varchar ->
        case
            when current_role() in ('analyst_full', 'accountadmin') then val
            else concat (left (val, 2), '**********')
        end;

create or replace masking policy demo_db.public.email
    as (val varchar) returns varchar ->
        case
            when current_role() in ('analyst_full', 'accountadmin') then val
            when current_role() in ('analyst_masked') then regexp_replace (val,'.+\@','*****@')
            else '**********'
        end;


-- apply policies
alter table if exists demo_db.public.customers_mask
    modify column phone
    set masking policy demo_db.public.phone;

alter table if exists demo_db.public.customers_mask
    modify column full_name
    set masking policy demo_db.public.full_name;

alter table if exists demo_db.public.customers_mask
    modify column email
    set masking policy demo_db.public.email;


-- validate policies
use role analyst_full;
select * from demo_db.public.customers_mask;

use role analyst_masked;
select * from demo_db.public.customers_mask;