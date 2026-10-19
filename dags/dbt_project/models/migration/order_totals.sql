{{ config(materialized='table') }}

select
    o.order_id,
    o.customer_id,
    o.product_id,
    o.quantity,
    o.order_date,
    o.status,
    case
        when o.quantity >= 3 then p.unit_price * o.quantity * 0.90
        else p.unit_price * o.quantity
    end as order_total
from {{ source('shop', 'orders') }} o
join {{ source('shop', 'products') }} p
  on p.product_id = o.product_id
