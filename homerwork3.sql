-- ZADANIE 1
CREATE OR REPLACE VIEW v_wysokie_pensje AS
SELECT * FROM employees
WHERE salary > 6000;

-- ZADANIE 2
CREATE OR REPLACE VIEW v_wysokie_pensje AS
SELECT * FROM employees
WHERE salary > 12000;

-- ZADANIE 3
DROP VIEW v_wysokie_pensje;

-- ZADANIE 4
CREATE OR REPLACE VIEW v_finance_employees AS
SELECT employee_id, last_name, first_name
FROM employees
WHERE department_id = (
    SELECT department_id
    FROM departments
    WHERE department_name = 'Finance'
);

-- ZADANIE 5
CREATE OR REPLACE VIEW v_pensje_5000_12000 AS
SELECT employee_id, last_name, first_name, salary, job_id, email, hire_date
FROM employees
WHERE salary BETWEEN 5000 AND 12000;

-- ZADANIE 6a
INSERT INTO v_pensje_5000_12000 (
    employee_id, last_name, first_name, salary, job_id, email, hire_date
)
VALUES (
    999, 'Test', 'Insert', 7000, 'IT_PROG', 'insert@test.com', SYSDATE
);

-- ZADANIE 6b
UPDATE v_pensje_5000_12000
SET salary = 8000
WHERE employee_id = 999;

-- ZADANIE 6c
DELETE FROM v_pensje_5000_12000
WHERE employee_id = 999;

-- ZADANIE 7
CREATE OR REPLACE VIEW v_dzialy_statystyki AS
SELECT d.department_id, d.department_name,
       COUNT(e.employee_id) AS liczba_pracownikow,
       ROUND(AVG(e.salary)) AS srednia_pensja,
       MAX(e.salary) AS max_pensja
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(e.employee_id) >= 4;

-- ZADANIE 8
CREATE OR REPLACE VIEW v_pensje_check AS
SELECT employee_id, last_name, first_name, salary, email, hire_date, job_id
FROM employees
WHERE salary BETWEEN 5000 AND 12000
WITH CHECK OPTION;

-- ZADANIE 8a(i)
INSERT INTO v_pensje_check (
    employee_id, last_name, first_name, salary, email, hire_date, job_id
)
VALUES (
    2001, 'Test', 'Ok', 6000, 'ok@test.com', SYSDATE, 'IT_PROG'
);

-- ZADANIE 8a(ii)
-- (poniższy INSERT zakończy się błędem przez WITH CHECK OPTION)
-- INSERT INTO v_pensje_check (
--     employee_id, last_name, first_name, salary, email, hire_date, job_id
-- )
-- VALUES (
--     1002, 'Test', 'Fail', 13000, 'fail@test.com', SYSDATE, 'IT_PROG'
-- );

-- ZADANIE 9
DROP MATERIALIZED VIEW v_managerowie;

CREATE MATERIALIZED VIEW v_managerowie
BUILD IMMEDIATE
REFRESH COMPLETE
AS
SELECT e.employee_id, e.first_name, e.last_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.employee_id IN (
    SELECT DISTINCT manager_id
    FROM employees
    WHERE manager_id IS NOT NULL
);

-- ZADANIE 10
CREATE OR REPLACE VIEW v_najlepiej_oplacani AS
SELECT *
FROM (
    SELECT * FROM employees ORDER BY salary DESC
)
WHERE ROWNUM <= 10;
