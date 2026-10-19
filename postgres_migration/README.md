# PostgreSQL → Snowflake migration (shop)

## Source
PostgreSQL 16 in Docker (`pg-source`, port 5433), schema `shop`: customers,
products, orders, customer_summary, plus two row-by-row PL/pgSQL procedures.

## Legacy logic
- `calculate_order_totals`: loops over every order, looks up the product's
  unit price and sets `order_total = price × quantity`, with a 10% discount
  when quantity >= 3.
- `refresh_customer_summary`: clears `customer_summary`, then loops over every
  customer and inserts their order count and the sum of `order_total`.

## Migration steps
1. `01_source_setup.sql` builds the source schema, seed data and procedures.
2. Tables exported to CSV with `COPY ... TO STDOUT` (`exports/`).
3. Files loaded into the internal stage `SHOP_STAGE`, then `COPY INTO`
   `ANALYTICS_DB.RAW_SHOP` tables.
4. Procedures rewritten as set-based dbt models (`dags/dbt_project/models/migration/`):
   - `order_totals`: join to products + `CASE` for the discount
   - `customer_summary`: `LEFT JOIN` + `GROUP BY`

## Validation
- `MINUS` in both directions between `customer_summary` (dbt) and
  `customer_summary_legacy` (Postgres) returns 0 rows.