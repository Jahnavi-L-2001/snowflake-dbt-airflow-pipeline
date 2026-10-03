{{ config(materialized='incremental', unique_key='order_id') }}

SELECT * FROM {{ ref('stg_orders') }}
{% if is_incremental() %}
WHERE order_id > (SELECT MAX(order_id) FROM {{ this }})
{% endif %}