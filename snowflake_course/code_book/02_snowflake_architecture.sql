-----------------------------------------------------------------
-- Chapter 2: Creating and Managing the Snowflake Architecture --
-----------------------------------------------------------------

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
use role sysadmin; -- recommended for object creation


-- create medium warehouse
-- context is set when created
create or replace warehouse ch2_wh
    with
    warehouse_size = 'medium'
    auto_suspend = 300
    auto_resume = true
    initially_suspended = true; -- best practice


-- alter warehouse
alter warehouse ch2_wh
    set warehouse_size = large;


-- create multi-cluster warehouse
-- context is set when created
create or replace warehouse ch2_mc_wh
    with
    warehouse_size = medium
    auto_suspend = 300
    auto_resume = true
    initially_suspended = true
    min_cluster_count = 1
    max_cluster_count = 6
    scaling_policy = 'standard';


-- alter results cache setting
-- this can be useful for testing
alter session set use_cached_result = false;
alter session set use_cached_result = true;


-- clean up
drop warehouse ch2_wh;
drop warehouse ch2_mc_wh;