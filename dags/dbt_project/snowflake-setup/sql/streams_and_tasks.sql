-- =========================================================
-- 06_streams_and_tasks.sql
-- CDC pattern: a stream tracks changes on `orders`, a task
-- merges them on a schedule. This is infra, not a dbt model
-- (dbt has no native concept of a Snowflake Task/Stream).
-- =========================================================

USE DATABASE ANALYTICS_DB;
USE SCHEMA RAW;

CREATE OR REPLACE STREAM orders_stream ON TABLE orders;

CREATE OR REPLACE TASK merge_orders_task
  WAREHOUSE = DBT_WH
  SCHEDULE = '5 MINUTE'
AS
MERGE INTO orders tgt
USING (
  SELECT order_id, customer_name, order_date, category, amount
  FROM orders_stream
  WHERE METADATA$ACTION = 'INSERT'
) src
ON tgt.order_id = src.order_id
WHEN MATCHED THEN UPDATE SET
  tgt.customer_name = src.customer_name,
  tgt.amount = src.amount
WHEN NOT MATCHED THEN INSERT (order_id, customer_name, order_date, category, amount)
VALUES (src.order_id, src.customer_name, src.order_date, src.category, src.amount);

ALTER TASK merge_orders_task RESUME;

SHOW TASKS;

-- ---- verification queries (run ad hoc, not part of deploy) ----
-- UPDATE orders SET amount = 9999 WHERE order_id = 111;
-- SELECT * FROM orders_stream;
-- SELECT COUNT(*) FROM orders_stream;
-- SELECT * FROM orders WHERE order_id = 111;

SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
  TASK_NAME => 'MERGE_ORDERS_TASK',
  SCHEDULED_TIME_RANGE_START => DATEADD('hour', -1, CURRENT_TIMESTAMP())
))
ORDER BY SCHEDULED_TIME DESC;