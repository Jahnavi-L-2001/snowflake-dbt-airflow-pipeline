{% snapshot customers_snapshot %}
{{ config(target_schema='SNAPSHOTS', unique_key='customer_name',
          strategy='check', check_cols=['city','segment']) }}
select * from {{ ref('customers') }}
{% endsnapshot %}