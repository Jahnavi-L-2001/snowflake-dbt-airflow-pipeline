SELECT
  order_id,
  TRIM(customer_name)        AS customer_name,
  order_date,
  UPPER(TRIM(category))      AS product_category,
  amount                     AS order_amount
FROM {{ source('raw', 'orders') }}