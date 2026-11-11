-- Laboratory Work 7: SQL Views and Roles
-- Student: Abylay Bakhytzhan
-- PostgreSQL
-- Requires the employees, departments, and projects tables from Lab 6.
-- Run as a PostgreSQL superuser (for example, postgres).

-- PART 1. CLEANUP OF PREVIOUS LAB 7 OBJECTS

DROP MATERIALIZED VIEW IF EXISTS project_stats_mv;
DROP MATERIALIZED VIEW IF EXISTS dept_summary_mv;

DROP VIEW IF EXISTS
    dept_dashboard,
    high_budget_projects,
    finance_employee_view,
    hr_employee_view,
    top_performers,
    high_earners,
    temp_view,
    it_employees,
    employee_salaries,
    project_overview,
    dept_statistics,
    employee_details
CASCADE;


-- PART 2. CREATING BASIC VIEWS

-- Exercise 2.1
CREATE VIEW employee_details AS
SELECT e.emp_name, e.salary, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

SELECT * FROM employee_details;

-- Exercise 2.2
CREATE VIEW dept_statistics AS
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS average_salary,
    MAX(e.salary) AS maximum_salary,
    MIN(e.salary) AS minimum_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

SELECT * FROM dept_statistics
ORDER BY employee_count DESC;

-- Exercise 2.3
CREATE VIEW project_overview AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    d.location,
    (
        SELECT COUNT(*)
        FROM employees e
        WHERE e.dept_id = p.dept_id
    ) AS team_size
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id;

SELECT * FROM project_overview;

-- Exercise 2.4
CREATE VIEW high_earners AS
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

SELECT * FROM high_earners;


-- PART 3. MODIFYING AND MANAGING VIEWS

-- Exercise 3.1
CREATE OR REPLACE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location,
    CASE
        WHEN e.salary > 60000 THEN 'High'
        WHEN e.salary > 50000 THEN 'Medium'
        ELSE 'Standard'
    END AS salary_grade
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

-- Exercise 3.2
ALTER VIEW high_earners RENAME TO top_performers;

SELECT * FROM top_performers;

-- Exercise 3.3
CREATE VIEW temp_view AS
SELECT emp_id, emp_name, salary
FROM employees
WHERE salary < 50000;

DROP VIEW temp_view;


-- PART 4. UPDATABLE VIEWS

-- Exercise 4.1
CREATE VIEW employee_salaries AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees;

-- Exercise 4.2
UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';

SELECT * FROM employees
WHERE emp_name = 'John Smith';

-- Exercise 4.3
DELETE FROM employee_salaries
WHERE emp_id = 6;

INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);

SELECT * FROM employees
WHERE emp_id = 6;

-- Exercise 4.4
CREATE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

DO $$
BEGIN
    INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
    VALUES (7, 'Bob Wilson', 103, 60000);
EXCEPTION
    WHEN SQLSTATE '44000' THEN
        RAISE NOTICE 'Insert rejected by the view CHECK OPTION.';
END;
$$;


-- PART 5. MATERIALIZED VIEWS

-- Exercise 5.1
CREATE MATERIALIZED VIEW dept_summary_mv AS
WITH employee_totals AS (
    SELECT
        dept_id,
        COUNT(*) AS total_employees,
        COALESCE(SUM(salary), 0) AS total_salaries
    FROM employees
    GROUP BY dept_id
),
project_totals AS (
    SELECT
        dept_id,
        COUNT(*) AS total_projects,
        COALESCE(SUM(budget), 0) AS total_project_budget
    FROM projects
    GROUP BY dept_id
)
SELECT
    d.dept_id,
    d.dept_name,
    COALESCE(e.total_employees, 0) AS total_employees,
    COALESCE(e.total_salaries, 0) AS total_salaries,
    COALESCE(p.total_projects, 0) AS total_projects,
    COALESCE(p.total_project_budget, 0) AS total_project_budget
FROM departments d
LEFT JOIN employee_totals e ON d.dept_id = e.dept_id
LEFT JOIN project_totals p ON d.dept_id = p.dept_id
WITH DATA;

SELECT * FROM dept_summary_mv
ORDER BY total_employees DESC;

-- Exercise 5.2
DELETE FROM employees WHERE emp_id = 8;

INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);

SELECT * FROM dept_summary_mv
ORDER BY total_employees DESC;

REFRESH MATERIALIZED VIEW dept_summary_mv;

SELECT * FROM dept_summary_mv
ORDER BY total_employees DESC;

-- Exercise 5.3
CREATE UNIQUE INDEX dept_summary_mv_dept_id_idx
ON dept_summary_mv (dept_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;

-- Exercise 5.4
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    (
        SELECT COUNT(*)
        FROM employees e
        WHERE e.dept_id = p.dept_id
    ) AS assigned_employee_count
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
WITH NO DATA;

DO $$
BEGIN
    BEGIN
        PERFORM 1 FROM project_stats_mv;
    EXCEPTION
        WHEN SQLSTATE '55000' THEN
            RAISE NOTICE 'Materialized view is not populated. Refresh it first.';
    END;
END;
$$;

REFRESH MATERIALIZED VIEW project_stats_mv;

SELECT * FROM project_stats_mv;


-- PART 6. DATABASE ROLES

DO $$
DECLARE
    role_name TEXT;
BEGIN
    FOREACH role_name IN ARRAY ARRAY[
        'analyst', 'data_viewer', 'report_user',
        'db_creator', 'user_manager', 'admin_user',
        'hr_team', 'finance_team', 'it_team',
        'hr_user1', 'hr_user2', 'finance_user1',
        'read_only', 'junior_analyst', 'senior_analyst',
        'project_manager', 'temp_owner',
        'viewer_role', 'entry_role', 'analyst_role', 'manager_role',
        'alice', 'bob', 'charlie'
    ]
    LOOP
        IF NOT EXISTS (
            SELECT 1 FROM pg_roles WHERE rolname = role_name
        ) THEN
            EXECUTE format('CREATE ROLE %I', role_name);
        END IF;
    END LOOP;
END;
$$;

-- Exercise 6.1
ALTER ROLE analyst NOLOGIN;
ALTER ROLE data_viewer WITH LOGIN PASSWORD 'viewer123';
ALTER ROLE report_user WITH LOGIN PASSWORD 'report456';

SELECT rolname
FROM pg_roles
WHERE rolname NOT LIKE 'pg_%'
ORDER BY rolname;

-- Exercise 6.2
ALTER ROLE db_creator WITH CREATEDB LOGIN PASSWORD 'creator789';
ALTER ROLE user_manager WITH CREATEROLE LOGIN PASSWORD 'manager101';
ALTER ROLE admin_user WITH SUPERUSER LOGIN PASSWORD 'admin999';

-- Exercise 6.3
GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;

-- Exercise 6.4
ALTER ROLE hr_team NOLOGIN;
ALTER ROLE finance_team NOLOGIN;
ALTER ROLE it_team NOLOGIN;

ALTER ROLE hr_user1 WITH LOGIN PASSWORD 'hr001';
ALTER ROLE hr_user2 WITH LOGIN PASSWORD 'hr002';
ALTER ROLE finance_user1 WITH LOGIN PASSWORD 'fin001';

GRANT hr_team TO hr_user1, hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;

-- Exercise 6.5
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;

-- Exercise 6.6
ALTER ROLE analyst WITH LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager WITH SUPERUSER;
ALTER ROLE analyst PASSWORD NULL;
ALTER ROLE data_viewer CONNECTION LIMIT 5;


-- PART 7. ADVANCED ROLE MANAGEMENT

-- Exercise 7.1
ALTER ROLE read_only NOLOGIN;
GRANT USAGE ON SCHEMA public TO read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

ALTER ROLE junior_analyst WITH LOGIN PASSWORD 'junior123';
ALTER ROLE senior_analyst WITH LOGIN PASSWORD 'senior123';

GRANT read_only TO junior_analyst, senior_analyst;
GRANT INSERT, UPDATE ON employees TO senior_analyst;

-- Exercise 7.2
ALTER ROLE project_manager WITH LOGIN PASSWORD 'pm123';
GRANT USAGE, CREATE ON SCHEMA public TO project_manager;
GRANT SELECT ON employees, departments TO project_manager;

ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;

SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- Exercise 7.3
ALTER ROLE temp_owner WITH LOGIN;
DROP TABLE IF EXISTS temp_table;

CREATE TABLE temp_table (
    id INT
);

ALTER TABLE temp_table OWNER TO temp_owner;

REASSIGN OWNED BY temp_owner TO postgres;
DROP OWNED BY temp_owner;
DROP ROLE temp_owner;

-- Exercise 7.4
CREATE VIEW hr_employee_view AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 102;

GRANT SELECT ON hr_employee_view TO hr_team;

CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;

GRANT SELECT ON finance_employee_view TO finance_team;


-- PART 8. PRACTICAL SCENARIOS

-- Exercise 8.1
CREATE VIEW dept_dashboard AS
WITH employee_totals AS (
    SELECT
        dept_id,
        COUNT(*) AS employee_count,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY dept_id
),
project_totals AS (
    SELECT
        dept_id,
        COUNT(*) AS active_projects,
        COALESCE(SUM(budget), 0) AS total_project_budget
    FROM projects
    GROUP BY dept_id
)
SELECT
    d.dept_name,
    d.location,
    COALESCE(e.employee_count, 0) AS employee_count,
    ROUND(COALESCE(e.average_salary, 0), 2) AS average_salary,
    COALESCE(p.active_projects, 0) AS active_projects,
    COALESCE(p.total_project_budget, 0) AS total_project_budget,
    CASE
        WHEN COALESCE(e.employee_count, 0) = 0 THEN 0::NUMERIC
        ELSE ROUND(
            COALESCE(p.total_project_budget, 0) / e.employee_count,
            2
        )
    END AS budget_per_employee
FROM departments d
LEFT JOIN employee_totals e ON d.dept_id = e.dept_id
LEFT JOIN project_totals p ON d.dept_id = p.dept_id;

-- Exercise 8.2
ALTER TABLE projects
ADD COLUMN IF NOT EXISTS created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE VIEW high_budget_projects AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
    CASE
        WHEN p.budget > 150000 THEN 'Critical Review Required'
        WHEN p.budget > 100000 THEN 'Management Approval Needed'
        ELSE 'Standard Process'
    END AS approval_status
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

-- Exercise 8.3
ALTER ROLE viewer_role NOLOGIN;
ALTER ROLE entry_role NOLOGIN;
ALTER ROLE analyst_role NOLOGIN;
ALTER ROLE manager_role NOLOGIN;

GRANT USAGE ON SCHEMA public TO viewer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

ALTER ROLE alice WITH LOGIN PASSWORD 'alice123';
ALTER ROLE bob WITH LOGIN PASSWORD 'bob123';
ALTER ROLE charlie WITH LOGIN PASSWORD 'charlie123';

GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;
