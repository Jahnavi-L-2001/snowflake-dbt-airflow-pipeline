-- =========================================================
-- 02_storage_integration.sql
-- Links Snowflake to the S3 bucket. Requires ACCOUNTADMIN
-- (or a role with CREATE INTEGRATION privilege).
-- Contains an AWS role ARN -> do NOT treat this file as
-- fully public; keep the bucket/role scoped tightly.
-- =========================================================

USE DATABASE ANALYTICS_DB;
USE SCHEMA RAW;

CREATE OR REPLACE STORAGE INTEGRATION s3_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::<your_aws_account_id>:role/<your_role_name>'
  STORAGE_ALLOWED_LOCATIONS = ('s3://<your-bucket>/<your-prefix>/')

DESC STORAGE INTEGRATION s3_int;