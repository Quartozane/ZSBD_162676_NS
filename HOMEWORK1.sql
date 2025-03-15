DROP TABLE EMPLOYEES;
DROP TABLE JOBS;

CREATE TABLE REGIONS (
    region_id     NUMBER PRIMARY KEY,
    region_name   VARCHAR2(50)
);


CREATE TABLE COUNTRIES (
    country_id    CHAR(2) PRIMARY KEY,
    country_name  VARCHAR2(40),
    region_id     NUMBER,
    CONSTRAINT fk_countries_regions
        FOREIGN KEY (region_id) REFERENCES REGIONS(region_id)
);


CREATE TABLE LOCATIONS (
    location_id    NUMBER PRIMARY KEY,
    street_address VARCHAR2(100),
    postal_code    VARCHAR2(20),
    city           VARCHAR2(50) NOT NULL,
    state_province VARCHAR2(50),
    country_id     CHAR(2),
    CONSTRAINT fk_locations_countries
        FOREIGN KEY (country_id) REFERENCES COUNTRIES(country_id)
);


CREATE TABLE DEPARTMENTS (
    department_id   NUMBER PRIMARY KEY,
    department_name VARCHAR2(50) NOT NULL,
    manager_id      NUMBER,
    location_id     NUMBER,
    CONSTRAINT fk_departments_locations
        FOREIGN KEY (location_id) REFERENCES LOCATIONS(location_id),
    CONSTRAINT fk_departments_manager
        FOREIGN KEY (manager_id) REFERENCES EMPLOYEES(employee_id)
);


CREATE TABLE JOBS (
    job_id     NUMBER PRIMARY KEY,
    job_title  VARCHAR2(50) NOT NULL,
    min_salary NUMBER,
    max_salary NUMBER
);


CREATE TABLE EMPLOYEES (
    employee_id     NUMBER PRIMARY KEY,
    first_name      VARCHAR2(50),
    last_name       VARCHAR2(50) NOT NULL,
    email           VARCHAR2(100) NOT NULL,
    phone_number    VARCHAR2(20),
    hire_date       DATE NOT NULL,
    job_id          NUMBER NOT NULL,
    salary          NUMBER(8,2),
    commission_pct  NUMBER(2,2),
    manager_id      NUMBER,
    department_id   NUMBER,
    CONSTRAINT fk_employees_jobs
        FOREIGN KEY (job_id) REFERENCES JOBS(job_id),
    CONSTRAINT fk_employees_manager
        FOREIGN KEY (manager_id) REFERENCES EMPLOYEES(employee_id),
    CONSTRAINT fk_employees_department
        FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id)
);


CREATE TABLE JOB_HISTORY (
    employee_id     NUMBER,
    start_date      DATE,
    end_date        DATE,
    job_id          NUMBER,
    department_id   NUMBER,
    PRIMARY KEY (employee_id, start_date),
    CONSTRAINT fk_jh_employee
        FOREIGN KEY (employee_id) REFERENCES EMPLOYEES(employee_id),
    CONSTRAINT fk_jh_job
        FOREIGN KEY (job_id) REFERENCES JOBS(job_id),
    CONSTRAINT fk_jh_department
        FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id)
);

INSERT INTO JOBS (job_id, job_title, min_salary, max_salary)
VALUES (1, 'Business Analyst', 3000, 6000);

INSERT INTO JOBS (job_id, job_title, min_salary, max_salary)
VALUES (2, 'Software Engineer', 5000, 9000);

INSERT INTO JOBS (job_id, job_title, min_salary, max_salary)
VALUES (3, 'Sales Manager', 4000, 7000);

INSERT INTO JOBS (job_id, job_title, min_salary, max_salary)
VALUES (4, 'HR Specialist', 3500, 5800);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, manager_id)
VALUES (1, 'Anna', 'Nowak', 'anna.nowak@example.com', '123456789', TO_DATE('2023-01-10', 'YYYY-MM-DD'), 1, 4000, NULL);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, manager_id)
VALUES (2, 'Jan', 'Kowalski', 'jan.kowalski@example.com', '987654321', TO_DATE('2023-02-01', 'YYYY-MM-DD'), 2, 6000, 1);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, manager_id)
VALUES (3, 'Ewa', 'Wiśniewska', 'ewa.wisniewska@example.com', '111222333', TO_DATE('2023-03-15', 'YYYY-MM-DD'), 3, 5500, 1);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, manager_id)
VALUES (4, 'Marek', 'Zieliński', 'marek.zielinski@example.com', '444555666', TO_DATE('2023-04-01', 'YYYY-MM-DD'), 4, 3700, 2);

UPDATE EMPLOYEES
SET manager_id = 1
WHERE employee_id IN (2, 3);

UPDATE JOBS
SET min_salary = min_salary + 500,
    max_salary = max_salary + 500
WHERE LOWER(job_title) LIKE '%b%' OR LOWER(job_title) LIKE '%s%';

DELETE FROM JOBS
WHERE max_salary > 9000;

DROP TABLE EMPLOYEES;

CREATE TABLE EMPLOYEES (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone_number VARCHAR(20),
    hire_date DATE,
    job_id INT,
    salary DECIMAL(10,2),
    manager_id INT,
    FOREIGN KEY (job_id) REFERENCES JOBS(job_id),
    FOREIGN KEY (manager_id) REFERENCES EMPLOYEES(employee_id)
);


