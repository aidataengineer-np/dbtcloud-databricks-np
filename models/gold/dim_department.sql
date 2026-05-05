{{ config(materialized='table') }}

select
    department_sk,
    department_id,
    department_name,
    business_unit,
    source_updated_at,
    current_timestamp() as gold_processed_at
from {{ ref('silver_department') }}
