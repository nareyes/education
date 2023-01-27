USE tsql_fundamentals;
-- Qyerying Metadata (Section in Chapter 2)
-- Reference MSFT Documentation for Detailed Information

-------------------
-- CATALOG VIEWS --
-------------------

-- Return Schema and Table Names
SELECT
    SCHEMA_NAME(schema_id) AS schema_name
    , Name AS table_name
FROM sys.tables
ORDER BY schema_name, table_name;


-- Return Column Information for a Specified Table
SELECT
  Name AS column_name
  , TYPE_NAME(system_type_id) AS column_type
  , max_length
  , collation_name
  , is_nullable
FROM sys.columns
WHERE object_id = OBJECT_ID(N'Sales.Orders');


------------------------------
-- INFORMATION SCHEMA VIEWS --
------------------------------
-- SAME RESULTS AS CATALOG VIEWS

-- Return Schema and Table Names
SELECT
    TABLE_SCHEMA
    , TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = N'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;


-- Return Column Information for a Specified Table
SELECT
    COLUMN_NAME
    , DATA_TYPE
    , CHARACTER_MAXIMUM_LENGTH
    , COLLATION_NAME
    , IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_SCHEMA = N'Sales'
    AND TABLE_NAME = N'Orders';


-------------------------------
-- SYSTEM STORED PROCEDURES  --
-------------------------------

-- Return Objects That Can be Queried (Tables and Views)
EXEC sys.sp_tables;


-- Return Detailed Specified Object Information
EXEC sys.sp_help
    @objname = N'Sales.Orders';


-- Return Column Information for a Specified Object
EXEC sys.sp_columns
    @table_owner = N'Sales', -- Schema
    @table_name = N'Orders';


-- Return Constraint Information for a Specified Object
EXEC sys.sp_helpconstraint
    @objname = N'Sales.Orders';


----------------------
-- SYSTEM FUNCTIONS --
----------------------

-- Return Instance Product Level
SELECT SERVERPROPERTY('ProductLevel') AS product_level;


-- Return Specified Property of Database
SELECT DATABASEPROPERTYEX(N'TSQLV4', 'Collation');


-- Return Specified Property for Specified Object
-- OBJECTPROPERTY Function Requires OBJECT_ID (Use OBJECT_ID Function to Get ID)
SELECT OBJECTPROPERTY(OBJECT_ID(N'Sales.Orders'), 'TableHasPrimaryKey') AS object_property;


-- Return Specified Property for Specified Column
-- OBJECTPROPERTY Function Requires OBJECT_ID (Use OBJECT_ID Function to Get ID)
SELECT COLUMNPROPERTY(OBJECT_ID(N'Sales.Orders'), N'shipcountry', 'AllowsNull') AS column_property;