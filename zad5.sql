-- 1. Dodaj nowy departament (EDUCATION) z ID o 10 większym niż maks
DECLARE
  v_max_id departments.department_id%TYPE;
  v_new_name departments.department_name%TYPE := 'EDUCATION';
BEGIN
  SELECT MAX(department_id) INTO v_max_id FROM departments;

  INSERT INTO departments (department_id, department_name, location_id)
  VALUES (v_max_id + 10, v_new_name, 1700);

  DBMS_OUTPUT.PUT_LINE('Dodano departament ID: ' || (v_max_id + 10));
END;
/
  
-- 2. Zmień location_id dla departamentu 3000
BEGIN
  UPDATE departments
  SET location_id = 9999
  WHERE department_id = 3000;

  DBMS_OUTPUT.PUT_LINE('Zmieniono location_id dla departamentu 3000');
END;
/

-- 3. Wpisz do tabeli NOWA liczby 1-10 bez 4 i 6
BEGIN
  FOR i IN 1..10 LOOP
    IF i NOT IN (4, 6) THEN
      INSERT INTO nowa (wartosc) VALUES (TO_CHAR(i));
    END IF;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Wpisano liczby do tabeli NOWA');
END;
/

-- 4. Pobierz dane o kraju CA z COUNTRIES
DECLARE
  v_country countries%ROWTYPE;
BEGIN
  SELECT * INTO v_country FROM countries WHERE country_id = 'CA';
  DBMS_OUTPUT.PUT_LINE('Kraj: ' || v_country.country_name || ', Region: ' || v_country.region_id);
END;
/

-- 5. Kursor: podwyżka zależnie od pensji (department_id = 50)
DECLARE
  CURSOR c IS
    SELECT last_name, salary FROM employees;
BEGIN
  FOR r IN c LOOP
    IF r.salary > 3100 THEN
      DBMS_OUTPUT.PUT_LINE(r.last_name || ' - nie dawać podwyżki');
    ELSE
      DBMS_OUTPUT.PUT_LINE(r.last_name || ' - dać podwyżkę');
    END IF;
  END LOOP;
END;
/


-- 6. Kursor z parametrami: zakres płac i fragment imienia
DECLARE
  CURSOR cur(p_min NUMBER, p_max NUMBER, p_name VARCHAR2) IS
    SELECT first_name, last_name, salary
    FROM employees
    WHERE salary BETWEEN p_min AND p_max
      AND LOWER(first_name) LIKE '%' || LOWER(p_name) || '%';
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Zakres 1000–5000, imię zawiera "a" ---');
  FOR r IN cur(1000, 5000, 'a') LOOP
    DBMS_OUTPUT.PUT_LINE(r.first_name || ' ' || r.last_name || ' - ' || r.salary);
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('--- Zakres 5000–20000, imię zawiera "u" ---');
  FOR r IN cur(5000, 20000, 'u') LOOP
    DBMS_OUTPUT.PUT_LINE(r.first_name || ' ' || r.last_name || ' - ' || r.salary);
  END LOOP;
END;
/

-- 9a. Procedura dodająca nowy zawód
CREATE OR REPLACE PROCEDURE add_job(p_id VARCHAR2, p_title VARCHAR2) AS
BEGIN
  INSERT INTO jobs (job_id, job_title) VALUES (p_id, p_title);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/

-- 9b. Procedura aktualizująca tytuł zawodu
CREATE OR REPLACE PROCEDURE update_job(p_id VARCHAR2, p_new_title VARCHAR2) AS
  v_count NUMBER;
BEGIN
  UPDATE jobs SET job_title = p_new_title WHERE job_id = p_id;
  v_count := SQL%ROWCOUNT;
  IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Brak zaktualizowanych zawodów.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/

-- 9c. Procedura usuwająca zawód
CREATE OR REPLACE PROCEDURE delete_job(p_id VARCHAR2) AS
  v_count NUMBER;
BEGIN
  DELETE FROM jobs WHERE job_id = p_id;
  v_count := SQL%ROWCOUNT;
  IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Brak usuniętych zawodów.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/

-- 9d. Procedura pobierająca dane pracownika
CREATE OR REPLACE PROCEDURE get_emp_data(
  p_emp_id NUMBER,
  p_salary OUT NUMBER,
  p_last_name OUT VARCHAR2
) AS
BEGIN
  SELECT salary, last_name INTO p_salary, p_last_name
  FROM employees WHERE id = p_emp_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Brak pracownika.');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/

-- 9e. Procedura dodająca pracownika (jeśli salary <= 20000)
CREATE OR REPLACE PROCEDURE add_employee(
  p_first_name VARCHAR2,
  p_last_name VARCHAR2,
  p_salary NUMBER
) AS
BEGIN
  IF p_salary > 20000 THEN
    RAISE_APPLICATION_ERROR(-20003, 'Zarobki za wysokie!');
  END IF;

  INSERT INTO employees (id, first_name, last_name, salary)
  VALUES (employees_seq.NEXTVAL, p_first_name, p_last_name, p_salary);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/
