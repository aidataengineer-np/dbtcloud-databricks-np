{{ config(alias='stg_workday_job') }}

select
    cast(job_id as string) as job_id,
    cast(job_title as string) as job_title,
    cast(job_family as string) as job_family,
    cast(min_salary as decimal(18,2)) as min_salary,
    cast(max_salary as decimal(18,2)) as max_salary,
    cast(updated_at as timestamp) as updated_at,
    cast(ingestion_ts as timestamp) as ingestion_ts
from {{ source('bronze_hr', 'job_raw') }}
