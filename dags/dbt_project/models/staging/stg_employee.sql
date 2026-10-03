SELECT
  empno      AS employee_id,
  ename      AS employee_name,
  job        AS job_title,
  mgr        AS manager_id,
  hiredate   AS hire_date,
  sal        AS salary,
  COALESCE(comm, 0) AS commission,
  deptno     AS department_id
FROM {{ source('raw', 'employee') }}