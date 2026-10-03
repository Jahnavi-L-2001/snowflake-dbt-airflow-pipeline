# Snowflake Setup Project

Practice project for setting up and managing a Snowflake environment using SQL scripts and Python (Snowpark).

## Project Structure

sql/ - Core Snowflake setup scripts
  warehouse_database_schema.sql - Warehouse and database/schema creation
  file_formats_and_stage.sql - File formats (JSON, Parquet) and external stage setup
  storage_integration.sql - S3 storage integration configuration
  raw_tables_and_load.sql - Raw table definitions and data loading
  rbac_and_secure_views.sql - Role-based access control and secure views
  streams_and_tasks.sql - Streams and tasks for change tracking/automation
  snowpipes.sql - Snowpipe setup for continuous data ingestion
  

snowpark/ - Python scripts using Snowpark
  connect.py - Establishes a connection to Snowflake

## Setup

1. Create a .env file in the root with your Snowflake credentials:

   SNOWFLAKE_ACCOUNT=your_account
   SNOWFLAKE_USER=your_user
   SNOWFLAKE_PASSWORD=your_password
   SNOWFLAKE_WAREHOUSE=your_warehouse
   SNOWFLAKE_DATABASE=your_database
   SNOWFLAKE_SCHEMA=your_schema
   SNOWFLAKE_ROLE=your_role

2. Install dependencies: pip install -r requirements.txt
3. Run connect.py to test the Snowflake connection.

## Notes

This is a learning/practice repository for exploring Snowflake features: storage integrations, file formats, RBAC, streams, tasks, and Snowpipe.