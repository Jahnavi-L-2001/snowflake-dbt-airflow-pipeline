{{ config(materialized='incremental', unique_key='order_id') }}

SELECT
    s.order_id,
    TO_NUMBER(TO_CHAR(s.order_date, 'YYYYMMDD')) AS date_key,
    c.customer_key,
    cat.category_key,
    s.amount_inr,
    s.inr_to_usd_rate,
    s.amount_usd,
    s.order_date
FROM {{ ref('mart_sales_usd') }} s
LEFT JOIN {{ ref('dim_customer') }} c
    ON c.customer_name = s.customer_name
   AND s.order_date >= c.valid_from
   AND s.order_date <  c.valid_to
LEFT JOIN {{ ref('dim_category') }} cat
    ON cat.category_name = UPPER(s.product_category)
{% if is_incremental() %}
WHERE s.order_date > (SELECT MAX(order_date) FROM {{ this }})
{% endif %}