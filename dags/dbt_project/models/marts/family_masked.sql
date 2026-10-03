{{ config(materialized='view', secure=true) }}

SELECT
  parent_name,
  parent_gender,
  parent_dob,
  city,
  state,
  house_number,
  {{ mask_column('office_phone') }} AS office_phone,
  {{ mask_column('personal_phone') }} AS personal_phone,
  kid_name
FROM {{ ref('stg_family') }}