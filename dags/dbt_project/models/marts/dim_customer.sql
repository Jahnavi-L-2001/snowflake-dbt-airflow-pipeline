SELECT
    {{ dbt_utils.generate_surrogate_key(['customer_name', 'dbt_valid_from']) }} AS customer_key,
    customer_name,
    city,
    segment,
    CASE WHEN ROW_NUMBER() OVER (PARTITION BY customer_name ORDER BY dbt_valid_from) = 1
         THEN '1900-01-01'::timestamp_ntz
         ELSE dbt_valid_from::timestamp_ntz END AS valid_from,
    COALESCE(dbt_valid_to::timestamp_ntz, '9999-12-31'::timestamp_ntz) AS valid_to,
    dbt_valid_to IS NULL AS is_current
FROM {{ ref('customers_snapshot') }}