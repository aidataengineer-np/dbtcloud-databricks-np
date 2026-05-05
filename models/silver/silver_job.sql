{{
    config(
        materialized='incremental',
        unique_key='job_id',
        incremental_strategy='merge',
        on_schema_change='sync_all_columns'
    )
}}

-- depends_on: {{ ref('transformation_rules') }}

with src as (
    select *
    from {{ ref('stg_workday_job') }}
    {% if is_incremental() %}
        where updated_at > (
            select coalesce(max(source_updated_at), timestamp('1900-01-01'))
            from {{ this }}
        )
    {% endif %}
),

standardized as (
    select
        {{ apply_rules(
            rule_set_name=var('rule_set_name'),
            target_model='silver_job',
            source_alias='src'
        ) }},
        {{ audit_columns("'workday'") }}
    from src
)

select
    {{ surrogate_key(['job_id']) }} as job_sk,
    job_id,
    job_title,
    job_family,
    min_salary,
    max_salary,
    source_updated_at,
    dbt_processed_at,
    dbt_invocation_id,
    source_system
from standardized
