-- =========================================================
-- 03_file_formats_and_stage.sql
-- File formats + the external stage pointing at S3.
-- =========================================================

USE DATABASE ANALYTICS_DB;
USE SCHEMA RAW;

CREATE OR REPLACE FILE FORMAT csv_format
  TYPE = CSV
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"';

CREATE OR REPLACE FILE FORMAT json_format
  TYPE = JSON;

CREATE OR REPLACE FILE FORMAT parquet_format
  TYPE = PARQUET;

CREATE OR REPLACE STAGE s3_stage
  URL = 's3://<your-bucket>/<your-prefix>/'
  STORAGE_INTEGRATION = s3_int;

LIST @s3_stage;