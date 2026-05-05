{{
    config(
        materialized='incremental',
        unique_key='payroll_id',
        incremental_strategy='merge',
        on_schema_change='sync_all_columns'
    )
}}

select
    p.payroll_sk,
    p.payroll_id,
    e.employee_sk,
    p.employee_id,
    p.pay_period_start,
    p.pay_period_end,
    p.gross_pay,
    p.bonus,
    p.tax,
    p.net_pay,
    d.department_sk,
    d.department_id,
    j.job_sk,
    j.job_id,
    p.source_updated_at,
    current_timestamp() as gold_processed_at
from {{ ref('silver_payroll') }} p
left join {{ ref('silver_employee') }} e
    on p.employee_id = e.employee_id
left join {{ ref('silver_department') }} d
    on e.department_id = d.department_id
left join {{ ref('silver_job') }} j
    on e.job_id = j.job_id
{% if is_incremental() %}
where p.source_updated_at > (
    select coalesce(max(source_updated_at), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}
