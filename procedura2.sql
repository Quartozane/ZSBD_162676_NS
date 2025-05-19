CREATE OR REPLACE PACKAGE regions_pkg IS
  PROCEDURE add_region(p_region_id NUMBER, p_region_name VARCHAR2);
  PROCEDURE update_region_name(p_region_id NUMBER, p_new_name VARCHAR2);
  PROCEDURE delete_region(p_region_id NUMBER);
  FUNCTION get_region_name_by_id(p_region_id NUMBER) RETURN VARCHAR2;
  FUNCTION get_region_id_by_name(p_region_name VARCHAR2) RETURN NUMBER;
END regions_pkg;
/

CREATE OR REPLACE PACKAGE BODY regions_pkg IS

  PROCEDURE add_region(p_region_id NUMBER, p_region_name VARCHAR2) IS
  BEGIN
    INSERT INTO hr.regions(region_id, region_name)
    VALUES (p_region_id, p_region_name);
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      RAISE_APPLICATION_ERROR(-20010, 'Region ID already exists.');
  END add_region;

  PROCEDURE update_region_name(p_region_id NUMBER, p_new_name VARCHAR2) IS
  BEGIN
    UPDATE hr.regions
    SET region_name = p_new_name
    WHERE region_id = p_region_id;
    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20011, 'Region ID not found.');
    END IF;
  END update_region_name;

  PROCEDURE delete_region(p_region_id NUMBER) IS
  BEGIN
    DELETE FROM hr.regions WHERE region_id = p_region_id;
    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20012, 'Region ID not found.');
    END IF;
  END delete_region;

  FUNCTION get_region_name_by_id(p_region_id NUMBER) RETURN VARCHAR2 IS
    v_name VARCHAR2(50);
  BEGIN
    SELECT region_name INTO v_name FROM hr.regions WHERE region_id = p_region_id;
    RETURN v_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_region_name_by_id;

  FUNCTION get_region_id_by_name(p_region_name VARCHAR2) RETURN NUMBER IS
    v_id NUMBER;
  BEGIN
    SELECT region_id INTO v_id FROM hr.regions WHERE region_name = p_region_name;
    RETURN v_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_region_id_by_name;

END regions_pkg;
/
