CREATE OR REPLACE FUNCTION GET_JOB_COUNT(p_emp_id INT)
    RETURNS INT
    LANGUAGE plpgsql
AS $$
DECLARE
    v_job_count INT;
BEGIN
    SELECT COUNT(DISTINCT job_id) INTO v_job_count
    FROM (
             SELECT job_id FROM JOB_HISTORY WHERE employee_id = p_emp_id
             UNION
             SELECT job_id FROM EMPLOYEES WHERE employee_id = p_emp_id
         ) AS jobs;

    IF v_job_count IS NULL THEN
        RAISE EXCEPTION 'Работник с ID % не найден', p_emp_id;
    END IF;

    RETURN v_job_count;
END;
$$;

-- Вызов функции
SELECT GET_JOB_COUNT(176);
