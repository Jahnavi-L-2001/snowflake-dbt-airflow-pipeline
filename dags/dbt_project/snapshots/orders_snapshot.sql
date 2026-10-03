{% snapshot orders_snapshot %}
{{ config(target_schema='snapshots',
     unique_key='order_id',
     strategy='timestamp',
     updated_at='_loaded_at') 
}}
SELECT *, CURRENT_TIMESTAMP() AS _loaded_at FROM {{ source('raw', 'orders') }}
{% endsnapshot %}