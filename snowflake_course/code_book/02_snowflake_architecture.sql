/* create warehouse syntax
create [ or replace ] warehouse [ if not exists ] <name>
       [ [ with ] objectproperties ]
       [ [ with ] tag ( <tag_name> = '<tag_value>' [ , <tag_name> = '<tag_value>' , ... ] ) ]
       [ objectparams ]


where:
objectproperties ::=
  warehouse_type = { standard | snowpark-optimized }
  warehouse_size = { xsmall | small | medium | large | xlarge | xxlarge | xxxlarge | x4large | x5large | x6large }
  max_cluster_count = <num>
  min_cluster_count = <num> -- to create a maximized multi-cluter warehouse, min and max cluster count must be > 1, and equal
  scaling_policy = { standard | economy }
  auto_suspend = { <num> | null }
  auto_resume = { true | false }
  initially_suspended = { true | false }
  resource_monitor = <monitor_name>
  comment = '<string_literal>'
  enable_query_acceleration = { true | false }
  query_acceleration_max_scale_factor = <num>
 */


-- set role context
use role sysadmin;


-- create medium warehouse
create or replace warehouse compute_wh_ch2
with
    warehouse_size = 'medium'
    auto_suspend = 300
    auto_resume = true
    initially_suspended = true; -- best practice


-- scaling up a virtual warehouse
alter warehouse compute_wh_ch2
    set warehouse_size = large;


-- scaling out a virtual warehouse
alter warehouse compute_wh_ch2
    set 
        min_cluster_count = 1,
        max_cluster_count = 3;


-- set warehouse context
use warehouse compute_wh_ch2;


-- create new warehouse for accounting domain
create or replace warehouse compute_wh_ch2_acct
with
    warehouse_size = 'medium'
    min_cluster_count = 1
    max_cluster_count = 6
    scaling_policy = 'standard'
    auto_suspend = 300
    auto_resume = true
    initially_suspended = true;


 -- create multi-cluster warehouse
create or replace warehouse compute_wh_ch2
with 
    warehouse_size = 'xsmall'
    min_cluster_count = 1
    max_cluster_count = 3
    auto_suspend = 600
    auto_resume = true
    initially_suspended = true;


 -- create maximized multi-cluster warehouse
create or replace warehouse compute_wh_ch2
with 
    warehouse_size = 'xsmall'
    min_cluster_count = 3
    max_cluster_count = 3
    auto_suspend = 600
    auto_resume = true
    initially_suspended = true;


-- disaple result cache
-- necessary for a/b testing
-- important to re-enable after testing
alter session
    set use_cached_result = false;


-- clean up
alter session
    set use_cached_result = true;

drop warehouse compute_wh_ch2;

drop warehouse compute_wh_ch2_acct;