CREATE OR REPLACE PROCEDURE NEW_JOB(
    p_job_id VARCHAR,
    p_job_title VARCHAR,
    p_min_salary NUMERIC
)
    LANGUAGE plpgsql
AS $$
BEGIN
    -- Проверяем существует ли запись с таким job_id
    IF EXISTS (SELECT 1 FROM JOBS WHERE job_id = p_job_id) THEN
        RAISE NOTICE 'Профессия с ID % уже существует. Ошибка добавления.', p_job_id;
    ELSE
        -- Вставляем новую работу с max_salary в два раза больше min_salary
        INSERT INTO JOBS (job_id, job_title, min_salary, max_salary)
        VALUES (p_job_id, p_job_title, p_min_salary, p_min_salary * 2);

        RAISE NOTICE 'Новая профессия % успешно добавлена.', p_job_id;
    END IF;
END;
$$;

CALL NEW_JOB('SY_ANALYS', 'System Analyst2', 6000);
