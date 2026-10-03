-- =========================================================
-- 04_raw_tables_and_load.sql
-- Raw table DDL + one-time historical load via COPY INTO.
-- These are the tables your dbt sources/staging models
-- will read FROM (dbt never creates these).
-- =========================================================

USE DATABASE ANALYTICS_DB;
USE SCHEMA RAW;

-- employee -------------------------------------------------
CREATE OR REPLACE TABLE employee (
  empno INT, ename STRING, job STRING, mgr INT,
  hiredate DATE, sal FLOAT, comm FLOAT, deptno INT
);

COPY INTO employee
FROM @s3_stage/employee/
FILE_FORMAT = (FORMAT_NAME = csv_format)
ON_ERROR = 'CONTINUE';

-- family (raw JSON, kept as VARIANT) ------------------------
CREATE OR REPLACE TABLE family_raw (raw_data VARIANT);

COPY INTO family_raw
FROM @s3_stage/family/
FILE_FORMAT = (FORMAT_NAME = json_format)
ON_ERROR = 'CONTINUE';

-- orders (parquet, flattened on load) -----------------------
CREATE OR REPLACE TABLE orders (
  order_id INT,
  customer_name STRING,
  order_date DATE,
  category STRING,
  amount FLOAT
);

COPY INTO orders (order_id, customer_name, order_date, category, amount)
FROM (
  SELECT
    $1:order_id::INT,
    $1:customer_name::STRING,
    TO_DATE(TO_TIMESTAMP_NTZ($1:order_date::NUMBER, 6)) AS order_date,
    $1:category::STRING,
    $1:amount::FLOAT
  FROM @s3_stage/orders/
)
FILE_FORMAT = (FORMAT_NAME = parquet_format);

-- Sanity checks
SELECT * FROM employee;
SELECT * FROM family_raw;
SELECT COUNT(*) FROM family_raw;
SELECT * FROM orders;