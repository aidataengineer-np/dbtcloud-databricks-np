{% test is_non_negative(model, column_name) %}
    select *
    from {{ model }}
    where {{ column_name }} < 0
{% endtest %}

{% test valid_email_format(model, column_name) %}
    select *
    from {{ model }}
    where {{ column_name }} is not null
      and not ({{ column_name }} rlike '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
{% endtest %}
