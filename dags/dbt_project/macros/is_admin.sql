{% macro is_admin() %}
    CURRENT_ROLE() = 'ACCOUNTADMIN'
{% endmacro %}