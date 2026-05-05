{% macro apply_rules(rule_set_name, target_model, source_alias='src') %}
    {%- set rules_sql -%}
        select
            target_column,
            rule_sql
        from {{ ref('transformation_rules') }}
        where rule_set_name = '{{ rule_set_name }}'
          and target_model = '{{ target_model }}'
          and is_active = true
          and effective_start_date <= to_date('{{ var("rules_effective_date") }}')
          and (effective_end_date is null or effective_end_date >= to_date('{{ var("rules_effective_date") }}'))
        order by rule_order
    {%- endset -%}

    {%- if execute -%}
        {%- set rules = run_query(rules_sql) -%}
        {%- if rules is none or rules.rows | length == 0 -%}
            {{ exceptions.raise_compiler_error("No active transformation rules found for rule_set_name='" ~ rule_set_name ~ "', target_model='" ~ target_model ~ "'") }}
        {%- endif -%}

        {%- for row in rules.rows -%}
            {{ row['rule_sql'] | replace('__SRC__', source_alias) }} as {{ row['target_column'] }}{% if not loop.last %},{% endif %}
        {%- endfor -%}
    {%- else -%}
        1 as _dbt_parse_placeholder
    {%- endif -%}
{% endmacro %}
