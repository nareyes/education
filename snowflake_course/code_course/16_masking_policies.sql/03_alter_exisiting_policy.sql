use role accountadmin;
use warehouse compute_wh;


-- alter exisiting policy
alter masking policy demo_db.public.phone
    set body ->
        case
            when current_role() in ('analyst_full', 'accountadmin') then val
            else '###-###-####'
        end;


-- list policies
desc masking policy demo_db.public.phone;
show masking policies;


-- validate policies
use role analyst_full;
select * from demo_db.public.customers_mask;

use role analyst_masked;
select * from demo_db.public.customers_mask;