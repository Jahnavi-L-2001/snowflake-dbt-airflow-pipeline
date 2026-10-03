{% macro mask_column(column_name, visible_chars=4) %}
    CASE WHEN {{ is_admin() }} THEN {{ column_name }}
         ELSE 'XXX-XXX-' || RIGHT({{ column_name }}, {{ visible_chars }}) END
{% endmacro %}