CREATE OR REPLACE PACKAGE BODY my_utils_pkg IS

  FUNCTION get_job_title(p_employee_id NUMBER) RETURN VARCHAR2 IS
    v_title VARCHAR2(50);
  BEGIN
    SELECT position INTO v_title FROM employees WHERE id = p_employee_id;
    RETURN v_title;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001, 'Employee ID not found');
  END get_job_title;

  FUNCTION get_annual_salary(p_employee_id NUMBER) RETURN NUMBER IS
    v_salary NUMBER;
  BEGIN
    SELECT salary INTO v_salary FROM employees WHERE id = p_employee_id;
    RETURN v_salary * 12;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20002, 'Employee ID not found');
  END get_annual_salary;

  FUNCTION get_area_code(p_phone VARCHAR2) RETURN VARCHAR2 IS
    v_area_code VARCHAR2(10);
  BEGIN
    -- Wyciągamy kod z numeru w formacie (xxx)
    v_area_code := REGEXP_SUBSTR(p_phone, '\((\d+)\)', 1, 1, NULL, 1);
    RETURN v_area_code;
  END get_area_code;

  FUNCTION capitalize_first_last(p_str VARCHAR2) RETURN VARCHAR2 IS
    v_len PLS_INTEGER := LENGTH(p_str);
    v_result VARCHAR2(4000);
  BEGIN
    IF v_len = 0 THEN RETURN NULL; END IF;
    IF v_len = 1 THEN
      RETURN UPPER(p_str);
    END IF;
    v_result := UPPER(SUBSTR(p_str,1,1)) || LOWER(SUBSTR(p_str,2,v_len-2)) || UPPER(SUBSTR(p_str,v_len,1));
    RETURN v_result;
  END capitalize_first_last;

  FUNCTION pesel_to_date(p_pesel VARCHAR2) RETURN DATE IS
    v_year NUMBER;
    v_month NUMBER;
    v_day NUMBER;
    v_century NUMBER;
    v_real_year NUMBER;
  BEGIN
    IF LENGTH(p_pesel) <> 11 THEN
      RAISE_APPLICATION_ERROR(-20003, 'Invalid PESEL length');
    END IF;

    v_year := TO_NUMBER(SUBSTR(p_pesel,1,2));
    v_month := TO_NUMBER(SUBSTR(p_pesel,3,2));
    v_day := TO_NUMBER(SUBSTR(p_pesel,5,2));

    IF v_month > 80 THEN
      v_century := 1800;
      v_month := v_month - 80;
    ELSIF v_month > 60 THEN
      v_century := 2200;
      v_month := v_month - 60;
    ELSIF v_month > 40 THEN
      v_century := 2100;
      v_month := v_month - 40;
    ELSIF v_month > 20 THEN
      v_century := 2000;
      v_month := v_month - 20;
    ELSE
      v_century := 1900;
    END IF;

    v_real_year := v_century + v_year;

    RETURN TO_DATE(v_real_year || '-' || LPAD(v_month,2,'0') || '-' || LPAD(v_day,2,'0'), 'YYYY-MM-DD');
  END pesel_to_date;

  PROCEDURE get_counts_by_country(
    p_country_name IN VARCHAR2, 
    o_emp_count OUT NUMBER, 
    o_dept_count OUT NUMBER
  ) IS
    v_country_id countries.country_id%TYPE;
  BEGIN
    SELECT country_id INTO v_country_id FROM countries WHERE country_name = p_country_name;

    -- Liczymy wszystkich pracowników
    SELECT COUNT(*) INTO o_emp_count FROM employees;

    -- Liczymy wszystkie departamenty
    SELECT COUNT(*) INTO o_dept_count FROM departments;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      o_emp_count := 0;
      o_dept_count := 0;
  END get_counts_by_country;

END my_utils_pkg;
/
