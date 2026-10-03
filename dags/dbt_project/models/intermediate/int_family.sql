with family as (
    select * from {{ ref('stg_family') }}
),
employees as (
    select * from {{ ref('stg_employee') }}
)
select
    {{ dbt_utils.generate_surrogate_key(['e.employee_id', 'f.parent_name']) }} as family_key,
    e.employee_id,
    e.employee_name,
    f.parent_name,
    f.parent_gender,
    f.parent_dob,
    f.city,
    f.state,
    f.house_number,
    f.office_phone,
    f.personal_phone,
    f.kid_name
from employees e
left join family f
    on upper(e.employee_name) = upper(f.parent_name)