CREATE OR REPLACE FUNCTION GET_YEARS_SERVICE(p_emp_id INT)
    RETURNS INT
    LANGUAGE plpgsql
AS $$
DECLARE
    v_years INT;
BEGIN
    SELECT EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date)) INTO v_years
    FROM EMPLOYEES
    WHERE employee_id = p_emp_id;

    IF v_years IS NULL THEN
        RAISE EXCEPTION 'Работник с ID % не найден', p_emp_id;
    END IF;

    RETURN v_years;
END;
$$;

SELECT GET_YEARS_SERVICE(999);
SELECT GET_YEARS_SERVICE(106);
