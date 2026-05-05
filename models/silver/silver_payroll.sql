{{
    config(
        materialized='incremental',
        unique_key='payroll_id',
        incremental_strategy='merge',
        on_schema_change='sync_all_columns',
        tblproperties={'delta.enableChangeDataFeed': 'true'}
    )
}}

-- depends_on: {{ ref('transformation_rules') }}

with src as (
    select *
    from {{ ref('stg_dayforce_payroll') }}
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
            target_model='silver_payroll',
            source_alias='src'
        ) }},
        {{ audit_columns("'dayforce'") }}
    from src
)

select
    {{ surrogate_key(['payroll_id']) }} as payroll_sk,
    payroll_id,
    employee_id,
    pay_period_start,
    pay_period_end,
    gross_pay,
    bonus,
    tax,
    net_pay,
    source_updated_at,
    dbt_processed_at,
    dbt_invocation_id,
    source_system
from standardized
