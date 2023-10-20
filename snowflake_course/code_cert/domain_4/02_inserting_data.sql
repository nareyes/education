/*
- insert statement variations 
- uploading data via the ui
*/

--set context
use role sysadmin;


-- create demo objects
create database films_db;

create schema films_schema;

create table films (
    id string, 
    title string, 
    release_date date
);


-- clone only structure
create table films_2000 clone films;


-- insert one row via a select query without specifying columns
insert into films select 'fi3p9f8hu8', 'parasite', date('2019-05-30');

            
-- insert one row via a select query and specify columns (omit release date column)
insert into  films (id, title) select 'dm8d7g7mng', '12 angry men';


-- insert one row via values syntax
insert into films values ('ily1n9muxd','back to the future',date('1985-12-04'));


-- insert multiple rows via values syntax
insert into films 
values 
    ('9x3wnr0zit', 'citizen kane', date('1942-01-24')),
    ('2wyaojnzfq', 'old boy', date('2004-10-15')), 
    ('0s0smukk2p', 'ratatouille', date('2007-06-29'));

select * from films;


-- insert all rows from another table - must be structurally identical
insert into films_2000 select * from films where release_date > date('2000-01-01');
insert into films_2000 select * from films where release_date > date('2000-01-01');

-- executing previous statement twice will load duplicates
select * from films_2000;


-- effectively truncates tables and inserts select statement
insert overwrite into films_2000 select * from films where release_date > date('2000-01-01');

select * from films_2000;


-- clean up
drop database films_db;