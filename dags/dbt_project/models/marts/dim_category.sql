SELECT
    {{ dbt_utils.generate_surrogate_key(['category']) }} AS category_key,
    category AS category_name
FROM {{ ref('valid_categories') }}