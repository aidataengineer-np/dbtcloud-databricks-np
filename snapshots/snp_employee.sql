{% snapshot snp_employee %}

{{
    config(
        target_schema='snapshots',
        unique_key='employee_id',
        strategy='timestamp',
        updated_at='source_updated_at'
    )
}}

select
    employee_id,
    employee_name,
    gender,
    email,
    department_id,
    job_id,
    hire_date,
    employment_status,
    salary,
    source_updated_at
from {{ ref('silver_employee') }}

{% endsnapshot %}
