{{
    config(
        materialized='incremental',
        unique_key='employee_id',
        incremental_strategy='merge',
        on_schema_change='sync_all_columns',
        tblproperties={'delta.enableChangeDataFeed': 'true'}
    )
}}

-- Force dbt dependency detection because this model uses transformation_rules through a macro/run_query.
-- depends_on: {{ ref('transformation_rules') }}

with src as (
    select *
    from {{ ref('stg_workday_employee') }}
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
            target_model='silver_employee',
            source_alias='src'
        ) }},
        {{ audit_columns("'workday'") }}
    from src
),

deduped as (
    select
        *,
        row_number() over (
            partition by employee_id
            order by source_updated_at desc
        ) as rn
    from standardized
)

select
    {{ surrogate_key(['employee_id']) }} as employee_sk,
    employee_id,
    employee_name,
    gender,
    email,
    department_id,
    job_id,
    hire_date,
    employment_status,
    salary,
    source_updated_at,
    dbt_processed_at,
    dbt_invocation_id,
    source_system
from deduped
where rn = 1
