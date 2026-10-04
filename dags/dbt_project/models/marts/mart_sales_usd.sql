WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),
rates AS (
    SELECT rate_date, rate
    FROM {{ ref('stg_exchange_rates') }}
    WHERE base_currency = 'INR' AND target_currency = 'USD'
)
SELECT
    o.order_id,
    o.customer_name,
    o.order_date,
    o.product_category,
    o.order_amount AS amount_inr,
    r.rate_date AS rate_date_used,
    r.rate AS inr_to_usd_rate,
    ROUND(o.order_amount * r.rate, 2) AS amount_usd
FROM orders o
LEFT JOIN rates r
    ON r.rate_date <= o.order_date
QUALIFY ROW_NUMBER() OVER (PARTITION BY o.order_id ORDER BY r.rate_date DESC) = 1