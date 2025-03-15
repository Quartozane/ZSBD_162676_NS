BEGIN
   FOR cur_rec IN (SELECT table_name FROM user_tables) LOOP
      EXECUTE IMMEDIATE 'DROP TABLE ' || cur_rec.table_name || ' CASCADE CONSTRAINTS PURGE';
   END LOOP;
END;
/

CREATE TABLE employees AS SELECT * FROM HR.employees;
CREATE TABLE departments AS SELECT * FROM HR.departments;
CREATE TABLE jobs AS SELECT * FROM HR.jobs;
CREATE TABLE locations AS SELECT * FROM HR.locations;
CREATE TABLE countries AS SELECT * FROM HR.countries;
CREATE TABLE regions AS SELECT * FROM HR.regions;
CREATE TABLE job_history AS SELECT * FROM HR.job_history;

ALTER TABLE employees ADD CONSTRAINT emp_pk PRIMARY KEY (employee_id);
ALTER TABLE departments ADD CONSTRAINT dept_pk PRIMARY KEY (department_id);
ALTER TABLE jobs ADD CONSTRAINT job_pk PRIMARY KEY (job_id);
ALTER TABLE locations ADD CONSTRAINT loc_pk PRIMARY KEY (location_id);
ALTER TABLE countries ADD CONSTRAINT country_pk PRIMARY KEY (country_id);
ALTER TABLE regions ADD CONSTRAINT region_pk PRIMARY KEY (region_id);
ALTER TABLE job_history ADD CONSTRAINT job_hist_pk PRIMARY KEY (employee_id, start_date);

ALTER TABLE employees ADD CONSTRAINT emp_dept_fk FOREIGN KEY (department_id) REFERENCES departments(department_id);
ALTER TABLE employees ADD CONSTRAINT emp_job_fk FOREIGN KEY (job_id) REFERENCES jobs(job_id);
ALTER TABLE employees ADD CONSTRAINT emp_mgr_fk FOREIGN KEY (manager_id) REFERENCES employees(employee_id);
ALTER TABLE departments ADD CONSTRAINT dept_loc_fk FOREIGN KEY (location_id) REFERENCES locations(location_id);
ALTER TABLE locations ADD CONSTRAINT loc_country_fk FOREIGN KEY (country_id) REFERENCES countries(country_id);
ALTER TABLE countries ADD CONSTRAINT country_region_fk FOREIGN KEY (region_id) REFERENCES regions(region_id);
ALTER TABLE job_history ADD CONSTRAINT job_hist_emp_fk FOREIGN KEY (employee_id) REFERENCES employees(employee_id);
ALTER TABLE job_history ADD CONSTRAINT job_hist_job_fk FOREIGN KEY (job_id) REFERENCES jobs(job_id);
ALTER TABLE job_history ADD CONSTRAINT job_hist_dept_fk FOREIGN KEY (department_id) REFERENCES departments(department_id);

-- Zadanie 1
SELECT last_name || ' ' || salary AS wynagrodzenie FROM employees WHERE department_id IN (20, 50) AND salary BETWEEN 2000 AND 7000 ORDER BY last_name;

-- Zadanie 2
SELECT hire_date, last_name, 'custom_column_value' AS custom_column FROM employees WHERE manager_id IS NOT NULL AND EXTRACT(YEAR FROM hire_date) = 2005 ORDER BY hire_date;

-- Zadanie 3
SELECT first_name || ' ' || last_name AS full_name, salary, phone_number FROM employees WHERE last_name LIKE '__e%' AND first_name LIKE 'custom_name%' ORDER BY full_name DESC, salary ASC;

-- Zadanie 4
SELECT first_name, last_name, ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) AS months_worked, CASE WHEN ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) < 150 THEN salary * 0.1 WHEN ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) BETWEEN 150 AND 200 THEN salary * 0.2 ELSE salary * 0.3 END AS wysokosc_dodatku FROM employees ORDER BY months_worked;

-- Zadanie 5
SELECT department_id, SUM(salary) AS total_salary, ROUND(AVG(salary)) AS avg_salary FROM employees GROUP BY department_id HAVING MIN(salary) > 5000;

-- Zadanie 6
SELECT e.last_name, e.department_id, d.department_name, e.job_id FROM employees e JOIN departments d ON e.department_id = d.department_id WHERE d.location_id IN (SELECT location_id FROM locations WHERE city = 'Toronto');

-- Zadanie 7
SELECT e1.first_name, e1.last_name, e2.first_name AS coworker_first, e2.last_name AS coworker_last FROM employees e1 JOIN employees e2 ON e1.department_id = e2.department_id WHERE e1.first_name = 'Jennifer';

-- Zadanie 8
SELECT department_name FROM departments WHERE department_id NOT IN (SELECT DISTINCT department_id FROM employees);

-- Zadanie 9
SELECT e.first_name, e.last_name, e.job_id, d.department_name, e.salary, CASE WHEN salary < 5000 THEN 'Low' WHEN salary BETWEEN 5000 AND 10000 THEN 'Medium' ELSE 'High' END AS grade FROM employees e JOIN departments d ON e.department_id = d.department_id;

-- Zadanie 10
SELECT first_name, last_name, salary FROM employees WHERE salary > (SELECT AVG(salary) FROM employees) ORDER BY salary DESC;

-- Zadanie 11
SELECT e1.employee_id, e1.first_name, e1.last_name FROM employees e1 WHERE e1.department_id IN (SELECT DISTINCT department_id FROM employees WHERE last_name LIKE '%u%');

-- Zadanie 12
SELECT first_name, last_name FROM employees WHERE MONTHS_BETWEEN(SYSDATE, hire_date) > (SELECT AVG(MONTHS_BETWEEN(SYSDATE, hire_date)) FROM employees);

-- Zadanie 13
SELECT d.department_name, COUNT(e.employee_id) AS num_employees, AVG(e.salary) AS avg_salary FROM departments d LEFT JOIN employees e ON d.department_id = e.department_id GROUP BY d.department_name ORDER BY num_employees DESC;

-- Zadanie 14
SELECT first_name, last_name FROM employees WHERE salary < ANY (SELECT salary FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'IT'));

-- Zadanie 15
SELECT department_name FROM departments WHERE department_id IN (SELECT department_id FROM employees WHERE salary > (SELECT AVG(salary) FROM employees));

-- Zadanie 16
SELECT job_id, AVG(salary) AS avg_salary FROM employees GROUP BY job_id ORDER BY avg_salary DESC FETCH FIRST 5 ROWS ONLY;

-- Zadanie 17
SELECT r.region_name, COUNT(DISTINCT c.country_id) AS num_countries, COUNT(e.employee_id) AS num_employees FROM regions r JOIN countries c ON r.region_id = c.region_id JOIN locations l ON c.country_id = l.country_id JOIN departments d ON l.location_id = d.location_id JOIN employees e ON d.department_id = e.department_id GROUP BY r.region_name;

-- Zadanie 18
SELECT e.first_name, e.last_name FROM employees e WHERE e.salary > (SELECT salary FROM employees WHERE employee_id = e.manager_id);

-- Zadanie 19
SELECT TO_CHAR(hire_date, 'MM') AS hire_month, COUNT(*) AS num_hires FROM employees GROUP BY TO_CHAR(hire_date, 'MM');

-- Zadanie 20
SELECT department_name, AVG(salary) AS avg_salary FROM employees e JOIN departments d ON e.department_id = d.department_id GROUP BY department_name ORDER BY avg_salary DESC FETCH FIRST 3 ROWS ONLY;
