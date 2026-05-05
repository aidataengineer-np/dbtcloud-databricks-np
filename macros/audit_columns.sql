{% macro audit_columns(source_system="'unknown'") %}
    current_timestamp() as dbt_processed_at,
    '{{ invocation_id }}' as dbt_invocation_id,
    {{ source_system }} as source_system
{% endmacro %}
