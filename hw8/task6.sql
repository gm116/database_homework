CREATE OR REPLACE FUNCTION CHECK_SAL_RANGE()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM EMPLOYEES
        WHERE job_id = NEW.job_id
          AND (salary < NEW.min_salary OR salary > NEW.max_salary)
    ) THEN
        RAISE EXCEPTION 'Зарплата работника вне диапазона';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER check_salary_range
    BEFORE UPDATE OF min_salary, max_salary
    ON JOBS
    FOR EACH ROW
EXECUTE FUNCTION CHECK_SAL_RANGE();

-- Тестирование триггера
UPDATE JOBS SET min_salary = 5000, max_salary = 7000 WHERE job_id = 'SY_ANAL';
UPDATE JOBS SET min_salary = 7000, max_salary = 18000 WHERE job_id = 'SY_ANAL';
