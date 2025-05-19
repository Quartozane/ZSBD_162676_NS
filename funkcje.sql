-- 1. Funkcja zwracająca nazwę pracy dla podanego id (POSITION w employees)
CREATE OR REPLACE FUNCTION get_job_title(p_emp_id NUMBER) RETURN VARCHAR2 IS
  v_position employees.position%TYPE;
BEGIN
  SELECT position INTO v_position FROM employees WHERE id = p_emp_id;
  RETURN v_position;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20001, 'Nie znaleziono pracownika o ID: ' || p_emp_id);
END;
/

-- 2. Funkcja zwracająca roczne zarobki pracownika (SALARY * 12, brak commission_pct w strukturze)
CREATE OR REPLACE FUNCTION get_annual_salary(p_emp_id NUMBER) RETURN NUMBER IS
  v_salary employees.salary%TYPE;
BEGIN
  SELECT salary INTO v_salary FROM employees WHERE id = p_emp_id;
  RETURN v_salary * 12;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20002, 'Nie znaleziono pracownika o ID: ' || p_emp_id);
END;
/

-- 3. Funkcja wyciągająca numer kierunkowy z telefonu (załóżmy format: (+XX) reszta)
CREATE OR REPLACE FUNCTION get_area_code(p_phone VARCHAR2) RETURN VARCHAR2 IS
  v_area_code VARCHAR2(10);
BEGIN
  v_area_code := REGEXP_SUBSTR(p_phone, '\(\+?([0-9]+)\)', 1, 1, NULL, 1);
  RETURN v_area_code;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/

-- 4. Funkcja zmieniająca pierwszą i ostatnią literę na wielką, resztę na małe
CREATE OR REPLACE FUNCTION capitalize_first_last(p_str VARCHAR2) RETURN VARCHAR2 IS
  v_len NUMBER := LENGTH(p_str);
  v_result VARCHAR2(100);
BEGIN
  IF v_len = 0 THEN
    RETURN NULL;
  ELSIF v_len = 1 THEN
    RETURN UPPER(p_str);
  ELSE
    v_result := UPPER(SUBSTR(p_str, 1, 1)) ||
                LOWER(SUBSTR(p_str, 2, v_len - 2)) ||
                UPPER(SUBSTR(p_str, v_len, 1));
    RETURN v_result;
  END IF;
END;
/

-- 5. Funkcja konwertująca PESEL na datę urodzenia (yyyy-mm-dd)
CREATE OR REPLACE FUNCTION pesel_to_date(p_pesel VARCHAR2) RETURN DATE IS
  v_year NUMBER;
  v_month NUMBER;
  v_day NUMBER;
  v_century NUMBER := 1900;
  v_real_month NUMBER;
BEGIN
  IF LENGTH(p_pesel) < 6 THEN
    RAISE_APPLICATION_ERROR(-20003, 'PESEL za krótki');
  END IF;

  v_year := TO_NUMBER(SUBSTR(p_pesel, 1, 2));
  v_month := TO_NUMBER(SUBSTR(p_pesel, 3, 2));
  v_day := TO_NUMBER(SUBSTR(p_pesel, 5, 2));

  IF v_month > 80 THEN
    v_century := 1800;
    v_real_month := v_month - 80;
  ELSIF v_month > 60 THEN
    v_century := 2200;
    v_real_month := v_month - 60;
  ELSIF v_month > 40 THEN
    v_century := 2100;
    v_real_month := v_month - 40;
  ELSIF v_month > 20 THEN
    v_century := 2000;
    v_real_month := v_month - 20;
  ELSE
    v_real_month := v_month;
  END IF;

  v_year := v_century + v_year;

  RETURN TO_DATE(TO_CHAR(v_year) || '-' || LPAD(v_real_month, 2, '0') || '-' || LPAD(v_day, 2, '0'), 'YYYY-MM-DD');
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20004, 'Niepoprawny PESEL lub data');
END;
/

-- 6. Procedura zwracająca liczbę pracowników i departamentów w kraju o podanej nazwie
CREATE OR REPLACE PROCEDURE get_counts_by_country(
  p_country_name IN VARCHAR2,
  p_emp_count OUT NUMBER,
  p_dept_count OUT NUMBER
) AS
  v_country_id countries.country_id%TYPE;
BEGIN
  -- Znajdź ID kraju
  SELECT country_id INTO v_country_id
  FROM countries
  WHERE country_name = p_country_name;

  -- Liczba departamentów w tym kraju (zakładamy kolumnę COUNTRY_ID w departments!)
  SELECT COUNT(*) INTO p_dept_count
  FROM departments
  WHERE department_id IN (
    SELECT d.department_id
    FROM departments d
    JOIN countries c ON c.country_id = v_country_id
  );

  -- Liczba pracowników (zakładamy kolumnę POSITION jako powiązaną logicznie z departamentem — zmień, jeśli masz inną strukturę)
  SELECT COUNT(*) INTO p_emp_count
  FROM employees
  WHERE id IN (
    SELECT e.id
    FROM employees e
    JOIN departments d ON e.position = d.department_name
    WHERE d.department_id IN (
      SELECT d.department_id
      FROM departments d
      JOIN countries c ON c.country_id = v_country_id
    )
  );

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20005, 'Brak kraju o nazwie: ' || p_country_name);
END;
/

