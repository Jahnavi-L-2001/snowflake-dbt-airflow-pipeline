-- models/marts/mart_employee_directory.sql
select
    e.employee_id,
    e.employee_name,
    e.job_title,
    e.manager_name,
    e.department_id,
    e.salary,
    f.parent_name,
    f.city,
    f.state,
    f.kid_name
from {{ ref('int_employee') }} e
left join {{ ref('int_family') }} f
    on e.employee_id = f.employee_id