{{ config(materialized='table') }}

select
    c.customer_id,
    count(o.order_id)               as total_orders,
    coalesce(sum(o.order_total), 0) as total_spent
from {{ source('shop', 'customers') }} c
left join {{ ref('order_totals') }} o
  on o.customer_id = c.customer_id
group by c.customer_id
