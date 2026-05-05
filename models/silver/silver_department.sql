{{
    config(
        materialized='incremental',
        unique_key='department_id',
        incremental_strategy='merge',
        on_schema_change='sync_all_columns'
    )
}}

-- depends_on: {{ ref('transformation_rules') }}

with src as (
    select *
    from {{ ref('stg_workday_department') }}
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
            target_model='silver_department',
            source_alias='src'
        ) }},
        {{ audit_columns("'workday'") }}
    from src
)

select
    {{ surrogate_key(['department_id']) }} as department_sk,
    department_id,
    department_name,
    business_unit,
    source_updated_at,
    dbt_processed_at,
    dbt_invocation_id,
    source_system
from standardized
