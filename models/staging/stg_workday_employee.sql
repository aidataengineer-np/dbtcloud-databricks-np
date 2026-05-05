{{ config(alias='stg_workday_employee') }}

select
    cast(employee_id as bigint) as employee_id,
    cast(first_name as string) as first_name,
    cast(last_name as string) as last_name,
    cast(gender as string) as gender,
    cast(email as string) as email,
    cast(department_id as string) as department_id,
    cast(job_id as string) as job_id,
    cast(hire_date as string) as hire_date,
    cast(employment_status as string) as employment_status,
    cast(salary as decimal(18,2)) as salary,
    cast(updated_at as timestamp) as updated_at,
    cast(ingestion_ts as timestamp) as ingestion_ts
from {{ source('bronze_hr', 'employee_raw') }}
