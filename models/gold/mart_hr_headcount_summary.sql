{{ config(materialized='table') }}

select
    business_unit,
    department_name,
    job_family,
    employment_status,
    count(*) as employee_count,
    avg(salary) as avg_salary,
    min(hire_date) as earliest_hire_date,
    max(hire_date) as latest_hire_date,
    current_timestamp() as mart_processed_at
from {{ ref('dim_employee') }}
group by
    business_unit,
    department_name,
    job_family,
    employment_status
