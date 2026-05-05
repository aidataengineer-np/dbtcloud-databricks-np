{{ config(alias='stg_dayforce_payroll') }}

select
    cast(payroll_id as bigint) as payroll_id,
    cast(employee_id as bigint) as employee_id,
    cast(pay_period_start as string) as pay_period_start,
    cast(pay_period_end as string) as pay_period_end,
    cast(gross_pay as decimal(18,2)) as gross_pay,
    cast(bonus as decimal(18,2)) as bonus,
    cast(tax as decimal(18,2)) as tax,
    cast(net_pay as decimal(18,2)) as net_pay,
    cast(updated_at as timestamp) as updated_at,
    cast(ingestion_ts as timestamp) as ingestion_ts
from {{ source('bronze_hr', 'payroll_raw') }}
