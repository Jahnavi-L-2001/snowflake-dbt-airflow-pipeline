SELECT
  rate_date,
  base_currency,
  target_currency,
  rate
FROM {{ source('raw', 'exchange_rates') }}