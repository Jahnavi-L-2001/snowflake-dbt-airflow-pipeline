-- =========================================================
-- 05_snowpipes.sql
-- Continuous ingestion (auto-ingest pipes). These replace
-- the manual COPY INTO once you go to production —
-- new files landing in S3 trigger load automatically via
-- the SQS notification configured on the stage's bucket.
-- =========================================================

USE DATABASE ANALYTICS_DB;
USE SCHEMA RAW;

CREATE OR REPLACE PIPE orders_pipe
  AUTO_INGEST = TRUE
AS
COPY INTO orders (order_id, customer_name, order_date, category, amount)
FROM (
  SELECT
    $1:order_id::INT,
    $1:customer_name::STRING,
    TO_DATE(TO_TIMESTAMP_NTZ($1:order_date::NUMBER, 6)),
    $1:category::STRING,
    $1:amount::FLOAT
  FROM @s3_stage/orders/
)
FILE_FORMAT = (FORMAT_NAME = parquet_format);

CREATE OR REPLACE PIPE employee_pipe
  AUTO_INGEST = TRUE
AS
COPY INTO employee
FROM @s3_stage/employee/
FILE_FORMAT = (FORMAT_NAME = csv_format);

CREATE OR REPLACE PIPE family_pipe
  AUTO_INGEST = TRUE
AS
COPY INTO family_raw
FROM @s3_stage/family/
FILE_FORMAT = (FORMAT_NAME = json_format);

SHOW PIPES;

SELECT SYSTEM$PIPE_STATUS('orders_pipe');
SELECT SYSTEM$PIPE_STATUS('employee_pipe');
SELECT SYSTEM$PIPE_STATUS('family_pipe');