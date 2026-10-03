SELECT
  TRIM(parent_name)      AS parent_name,
  gender                 AS parent_gender,
  dob                    AS parent_dob,
  city,
  state,
  house_number,
  office_phone,
  personal_phone,
  kid_name
FROM {{ source('raw', 'family') }}