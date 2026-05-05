-- Ad hoc analysis example. This does not create a table by default.
-- Use dbt compile, then run the compiled SQL in Databricks SQL if needed.

select
    business_unit,
    department_name,
    count(*) as total_employees,
    sum(case when employment_status = 'Active' then 1 else 0 end) as active_employees,
    sum(case when employment_status in ('Inactive', 'Terminated') then 1 else 0 end) as inactive_or_terminated_employees,
    avg(salary) as avg_salary
from {{ ref('dim_employee') }}
group by
    business_unit,
    department_name
order by
    business_unit,
    department_name
