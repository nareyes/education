create or replace warehouse compute_wh_sql
with
    warehouse_size = xsmall
    max_cluster_count = 3 -- enables multi-cluster warehouse
    auto_resume = true
    auto_suspend = 600 -- in seconds
    initially_suspended = true

-- drop warehouse compute_wh_sql