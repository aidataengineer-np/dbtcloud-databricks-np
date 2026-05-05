{{ config(materialized='table') }}

select
    e.employee_sk,
    e.employee_id,
    e.employee_name,
    e.gender,
    e.email,
    e.hire_date,
    e.employment_status,
    e.salary,
    d.department_sk,
    d.department_id,
    d.department_name,
    d.business_unit,
    j.job_sk,
    j.job_id,
    j.job_title,
    j.job_family,
    e.source_updated_at,
    current_timestamp() as gold_processed_at
from {{ ref('silver_employee') }} e
left join {{ ref('silver_department') }} d
    on e.department_id = d.department_id
left join {{ ref('silver_job') }} j
    on e.job_id = j.job_id
