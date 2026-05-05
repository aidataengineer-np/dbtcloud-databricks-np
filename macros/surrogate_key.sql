{% macro surrogate_key(columns) %}
    sha2(
        concat_ws(
            '||'
            {%- for col in columns -%}
                , coalesce(cast({{ col }} as string), '__dbt_null__')
            {%- endfor -%}
        ),
        256
    )
{% endmacro %}
