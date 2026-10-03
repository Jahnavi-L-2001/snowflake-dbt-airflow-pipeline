# Snowflake Data Platform & dbt Pipeline

A self-directed practice project simulating an end-to-end analytics engineering
workflow on **Snowflake**, using **dbt** for transformation and modeling, with
supporting Snowflake setup scripts for infrastructure, security, and data
ingestion.

## Overview

This project builds a layered dbt pipeline (staging → intermediate → marts)
on top of Snowflake, along with the raw Snowflake-side setup (warehouses,
file formats, stages, RBAC, Snowpipe, streams/tasks) needed to support it.

## Tech Stack

- **Snowflake** — cloud data warehouse
- **dbt** — data transformation and modeling
- **Snowpark (Python)** — programmatic Snowflake connectivity
- **Snowpipe / Streams & Tasks** — automated ingestion and change tracking

## Project Structure

models/
  staging/         Cleaned, renamed source data (stg_employee, stg_family, stg_orders)
  intermediate/    Business logic layer, including an incremental orders model
  marts/           Final consumption-ready tables (employee directory, sales by category, masked data)
seeds/             Static reference data (e.g. valid_categories.csv)
snapshots/         Type-2 historical tracking (orders_snapshot)
macros/            Reusable dbt macros, including column-masking logic
analyses/          Ad-hoc/debug queries
tests/             dbt tests
snowflake-setup/   Raw Snowflake SQL: warehouses, file formats, stages,
                   storage integration, RBAC, streams & tasks, Snowpipe
                   plus a Snowpark Python connection script, see its own README

## Key Features

- Layered modeling: staging to intermediate to marts, following dbt best practices
- Incremental models: int_orders_incremental demonstrates incremental materialization
- Snapshots: orders_snapshot tracks historical changes (SCD Type 2)
- Data masking: custom macro (mask_column) applied to a family_masked mart for sensitive-column protection
- Seeds: reference/lookup data loaded via dbt seeds
- Snowflake infrastructure as code: see snowflake-setup/README.md for details

## Setup

1. Configure Snowflake credentials (see snowflake-setup/requirements.txt).
2. Run the SQL scripts in snowflake-setup/sql/ in order to provision the
   warehouse, database/schema, file formats, stages, and RBAC.
3. Configure your dbt profiles.yml to point at the provisioned Snowflake
   warehouse/database/schema.
4. From the project root, run:
   dbt deps
   dbt seed
   dbt run
   dbt test
   dbt snapshot

## Notes

This is a learning/practice project built to gain hands-on experience with
the Snowflake + dbt stack, including modeling patterns, incremental loads,
snapshots, masking, and the underlying Snowflake account setup typically
owned by a data engineer.
