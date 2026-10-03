with employees as (
    select * from {{ ref('stg_employee') }}
),

managers as (
    select
        employee_id   as manager_id,
        employee_name as manager_name
    from {{ ref('stg_employee') }}
)

select
    e.employee_id,
    e.employee_name,
    e.job_title,
    e.manager_id,
    m.manager_name,
    e.hire_date,
    e.salary,
    e.commission,
    e.department_id
from employees e
left join managers m
    on e.manager_id = m.manager_id