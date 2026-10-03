select
    product_category,
    count(order_id)           as total_orders,
    sum(order_amount)         as total_sales,
    avg(order_amount)         as avg_order_value
from {{ ref('stg_orders') }}
group by product_category
order by total_sales desc