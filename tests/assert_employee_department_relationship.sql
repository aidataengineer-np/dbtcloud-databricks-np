select
    e.employee_id,
    e.department_id
from {{ ref('dim_employee') }} e
left join {{ ref('dim_department') }} d
    on e.department_id = d.department_id
where d.department_id is null
