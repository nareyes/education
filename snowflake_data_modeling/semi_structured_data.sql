--------------------------------------------------
-- create a table and load semi-structured data --
--------------------------------------------------

create or replace schema ch15_semistruct;


create or replace table pirate_json (
    __load_id   number not null autoincrement start 1 increment 1,
    __load_name varchar not null,
    __load_dts  timestamp_ntz not null,
    v           variant not null,

    constraint pirate_json___load_id primary key ( __load_id )
)
comment = 'table w. a variant for pirate data, with meta elt fields';

insert into pirate_json (-- __load_id is omitted to allow autoincrement
    __load_name
    , __load_dts
    , v
) 
select 'ad-hoc load', current_timestamp, parse_json($1) from 
values ('
{
  "name": "Edward Teach",
  "nickname": "Blackbeard",
  "years_active": [
    1716,
    1717,
    1718
  ],
  "born": 1680,
  "died": 1718,
  "cause_of_death": "Killed in action",
  "crew": [
    {
      "name": "Stede Bonnet",
      "nickname": "Gentleman pirate",
      "weapons": [
        "blunderbuss"
      ],
      "years_active": [
        1717,
        1718
      ]
    },
    {
      "name": "Israel Hands",
      "nickname": null,
      "had_bird": true,
      "weapons": [
        "flintlock pistol",
        "cutlass",
        "boarding axe"
      ],
      "years_active": [
        1716,
        1717,
        1718
      ]
    }
  ],
  "ship": {
    "name": "Queen Anne\'s Revenge",
    "type": "Frigate",
    "original_name": "La Concorde",
    "year_captured": 1717
  }
}
')
;


-------------------------------------
-- read from semi-structured data --
-------------------------------------

select * from pirate_json;
            
            
--cast and alias basic attributes
select v:name as pirate_name_json
 , v:name::string as pirate_name_string
 , v:nickname::string as pirate_name_string
from pirate_json; 


--select sub-columns
select v:name::string as pirate_name
, v:ship.name::string as ship_name
from pirate_json; 


--select a colum that has vanished
select v:name::string as pirate_name
, v:loc_buried_treasure::string as pirate_treasure_location
from pirate_json; 


--select from an array
select v:name::string as pirate_name
, v:years_active as years_active
, v:years_active[0] as active_from
, v:years_active[array_size(v:years_active)-1] as active_to
from pirate_json; 


--query multiple elements
select v:name::string as pirate_name
 , v:crew::variant as pirate_crew
from pirate_json; 


--flatten crew members into rows
select v:name::string as pirate_name
, c.value:name::string as crew_name
, c.value:nickname::string as crew_nickname
from pirate_json, lateral flatten(v:crew) c; 


--flatten crew members and their weapons into rows
select v:name::string as pirate_name
, c.value:name::string as crew_name
, w.value::string as crew_weapons
from pirate_json, lateral flatten(v:crew) c
		,lateral flatten(c.value:weapons) w;

--perform aggregation and filtering just like on tabular data 
select count(crew_weapons) as num_weapons from (
select c.value:name::string as crew_name
, w.value::string as crew_weapons
from pirate_json, lateral flatten(v:crew) c
		,lateral flatten(c.value:weapons) w
where crew_name = 'Israel Hands' );