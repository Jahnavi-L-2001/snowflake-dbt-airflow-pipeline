-- =========================================================
-- 01_warehouse_database_schema.sql
-- One-time / rarely-changed account setup.
-- Run manually as ACCOUNTADMIN (or via a setup CI job),
-- NEVER as part of `dbt run`.
-- =========================================================

CREATE WAREHOUSE IF NOT EXISTS DBT_WH
WITH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

CREATE DATABASE IF NOT EXISTS ANALYTICS_DB;

CREATE SCHEMA IF NOT EXISTS ANALYTICS_DB.RAW;
CREATE SCHEMA IF NOT EXISTS ANALYTICS_DB.ANALYTICS;

USE WAREHOUSE DBT_WH;
USE DATABASE ANALYTICS_DB;
USE SCHEMA RAW;

-- Sanity checks
SHOW WAREHOUSES;
SHOW DATABASES;
SHOW SCHEMAS;
SELECT CURRENT_ROLE();