CREATE OR REPLACE PROCEDURE ADD_JOB_HIST(
    p_emp_id INT,
    p_new_job_id VARCHAR
)
    LANGUAGE plpgsql
AS $$
BEGIN
    -- Добавление записи в JOB_HISTORY
    INSERT INTO JOB_HISTORY (employee_id, job_id, start_date, end_date)
    SELECT e.employee_id, e.job_id, e.hire_date, CURRENT_DATE
    FROM EMPLOYEES e
    WHERE e.employee_id = p_emp_id;

    -- Обновляем сотрудника в таблице EMPLOYEES
    UPDATE EMPLOYEES
    SET job_id = p_new_job_id,
        hire_date = CURRENT_DATE,
        salary = (SELECT min_salary + 500 FROM JOBS WHERE job_id = p_new_job_id)
    WHERE employee_id = p_emp_id;

    -- Обработка случая, если сотрудника нет
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Сотрудник с ID % не найден', p_emp_id;
    END IF;
END;
$$;

-- Отключение триггеров
ALTER TABLE EMPLOYEES DISABLE TRIGGER ALL;
ALTER TABLE JOBS DISABLE TRIGGER ALL;
ALTER TABLE JOB_HISTORY DISABLE TRIGGER ALL;

CALL ADD_JOB_HIST(106, 'SY_ANAL');

-- Проверка
SELECT * FROM JOB_HISTORY WHERE employee_id = 106;
SELECT * FROM EMPLOYEES WHERE employee_id = 106;

-- Включение триггеров
ALTER TABLE EMPLOYEES ENABLE TRIGGER ALL;
ALTER TABLE JOBS ENABLE TRIGGER ALL;
ALTER TABLE JOB_HISTORY ENABLE TRIGGER ALL;
