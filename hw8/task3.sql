CREATE OR REPLACE PROCEDURE UPD_JOBSAL(
    p_job_id VARCHAR,
    p_new_min_salary NUMERIC,
    p_new_max_salary NUMERIC
)
    LANGUAGE plpgsql
AS $$
BEGIN
    -- Проверка на корректность зарплат
    IF p_new_max_salary < p_new_min_salary THEN
        RAISE EXCEPTION 'Максимальная зарплата не может быть меньше минимальной';
    END IF;

    -- Обновляем зарплаты
    UPDATE JOBS
    SET min_salary = p_new_min_salary,
        max_salary = p_new_max_salary
    WHERE job_id = p_job_id;

    IF NOT FOUND THEN
        RAISE NOTICE 'ID должности % не найдено', p_job_id;
    END IF;
END;
$$;

CALL UPD_JOBSAL('SY_ANAL', 7000, 14000);

-- Проверка изменений
SELECT * FROM JOBS WHERE job_id = 'SY_ANAL';
