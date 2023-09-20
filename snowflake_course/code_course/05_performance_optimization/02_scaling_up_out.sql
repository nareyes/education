use role accountadmin;


-- scale up for known patterns of high work load (changing size)
alter warehouse compute_wh
    set warehouse_size = 'large';

alter warehouse compute_wh
    set warehouse_size = 'x-small';


-- scale out for unknown patterns of work load (multi-cluster warehouses)
alter warehouse compute_wh
    set max_cluster_count = 6;

alter warehouse exercise_wh
    set max_cluster_count = 6;


-- view warehouse configurations
show warehouses;