SELECT
    TO_NUMBER(TO_CHAR(date_day, 'YYYYMMDD')) AS date_key,
    date_day,
    YEAR(date_day) AS year,
    MONTH(date_day) AS month,
    DAYNAME(date_day) AS day_name,
    DAYOFWEEK(date_day) IN (0, 6) AS is_weekend
FROM (
    SELECT DATEADD(day, SEQ4(), '2026-01-01'::date) AS date_day
    FROM TABLE(GENERATOR(ROWCOUNT => 365))
)