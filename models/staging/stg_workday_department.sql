{{ config(alias='stg_workday_department') }}

select
    cast(department_id as string) as department_id,
    cast(department_name as string) as department_name,
    cast(business_unit as string) as business_unit,
    cast(updated_at as timestamp) as updated_at,
    cast(ingestion_ts as timestamp) as ingestion_ts
from {{ source('bronze_hr', 'department_raw') }}
