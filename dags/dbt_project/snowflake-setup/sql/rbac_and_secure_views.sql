-- =========================================================
-- 07_rbac_and_secure_views.sql
-- Read-only analyst role + secure views with masking/
-- row-level filtering. Run as ACCOUNTADMIN or SECURITYADMIN.
-- =========================================================

USE DATABASE ANALYTICS_DB;
USE SCHEMA RAW;

-- Read-only analyst role
CREATE ROLE IF NOT EXISTS analyst_role;
GRANT USAGE ON WAREHOUSE DBT_WH TO ROLE analyst_role;
GRANT USAGE ON DATABASE ANALYTICS_DB TO ROLE analyst_role;
GRANT USAGE ON SCHEMA RAW TO ROLE analyst_role;
GRANT SELECT ON ALL TABLES IN SCHEMA RAW TO ROLE analyst_role;

-- Replace with the actual user(s) who should get this role
GRANT ROLE analyst_role TO USER JAHNAVI;

-- NOTE: family_masked secure view has moved into the dbt project:
--   dbt/models/marts/family_masked.sql
-- It now uses the is_admin() and mask_column() macros, so it must
-- be built via `dbt run --select family_masked`, not run as raw SQL.
-- (Plain SQL files can't compile Jinja macros, so it can't stay here.)

-- Row-restricted view: non-admins only see deptno = 10
CREATE OR REPLACE SECURE VIEW employee_dept_restricted AS
SELECT *
FROM employee
WHERE CURRENT_ROLE() = 'ACCOUNTADMIN' OR deptno = 10;

-- ---- verification (ad hoc) ----
-- USE ROLE analyst_role;  SELECT * FROM family_masked;
-- USE ROLE ACCOUNTADMIN;  SELECT * FROM family_masked;
-- USE ROLE analyst_role;  SELECT * FROM employee_dept_restricted;
-- USE ROLE ACCOUNTADMIN;  SELECT * FROM employee_dept_restricted;

USE ROLE analyst_role;
SELECT * FROM ANALYTICS_DB.dbt_jl.Familymasked LIMIT 5;

