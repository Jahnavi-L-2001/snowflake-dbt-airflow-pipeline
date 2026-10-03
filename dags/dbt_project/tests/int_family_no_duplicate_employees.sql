select
    employee_id,
    count(*) as row_count
from {{ ref('int_family') }}
group by employee_id
having count(*) > 1