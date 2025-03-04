// Snowflake Definitive Guide 1st Edition by Joyce Kay Avila - August 2022
// ISBN-10 : 1098103823
// ISBN-13 : 978-1098103828
// Contact the author: https://www.linkedin.com/in/joycekayavila/
// Chapter 2: Creating and Managing the Snowflake Architecture


// Page 23 - Prep Work
// Create new worksheet: Chapter2 Creating and Managing Snowflake Architecture
// Context setting - make sure role is set to SYSADMIN and COMPUTE_WH is the virtual warehouse

// Page 32 - Optional
// Navigate back to the worksheet, if needed
// Create a new small virtual warehouse in UI: Original_WH
// Increase the cluster size to medium
// Scale back down but change to multi-cluster
// Note if you create this optional virtual warehouse, be sure to drop it during code cleanup

// Page 38 - Create a new virtual warehouse
USE ROLE SYSADMIN;
CREATE WAREHOUSE CH2_WH WITH WAREHOUSE_SIZE = MEDIUM
 AUTO_SUSPEND = 300 AUTO_RESUME = true INITIALLY_SUSPENDED = true;
 
// Page 38 - Scaling up a virtual warehouse 
USE ROLE SYSADMIN;
ALTER WAREHOUSE CH2_WH
SET WAREHOUSE_SIZE = LARGE;

// Page 39 - Set context for virtual warehouse to be used
USE WAREHOUSE CH2_WH;

// Page 39 - Set context for virtual warehouse to be used
// Use the menu to set the context for the virtual warehouse

// Page 39 - Editing a virtual warehouse from the Web UI
// Navigate to Admin -> Warehouses
// Refresh the page if needed
// Select the Edit option from the ellipsis from the right, for the CH2_WH virtual warehouse 

// Page 43 - Create new virtual warehouse
// Navigate back to the worksheet, if needed
USE ROLE SYSADMIN;
CREATE OR REPLACE WAREHOUSE ACCOUNTING_WH
 WITH Warehouse_Size = MEDIUM MIN_CLUSTER_COUNT = 1
 MAX_CLUSTER_COUNT = 6 SCALING_POLICY = 'STANDARD';

// Page 47 - Disable the Reseult Cache
ALTER SESSION SET USE_CACHED_RESULT=FALSE;

// Page 50 - Code Cleanup
// Set the cached results back to true
USE ROLE SYSADMIN;
ALTER SESSION SET USE_CACHED_RESULT=TRUE;
// Drop the virtual warehouses created in this chapter
USE ROLE SYSADMIN;
DROP WAREHOUSE CH2_WH;
DROP WAREHOUSE ACCOUNTING_WH;
