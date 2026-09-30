CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100),
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(100) DEFAULT 'Unassigned',
    salary INTEGER DEFAULT 50000,
    hire_date DATE,
    status VARCHAR(30) DEFAULT 'Active'
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);


-- ============================================================
-- LAB 3 - ADVANCED DML OPERATIONS
-- Student: Abylay Bakhytzhan
-- ID: 24B032192
-- ============================================================


-- ============================================================
-- 2. INSERT WITH COLUMN SPECIFICATION
-- ============================================================

INSERT INTO employees
    (emp_id, first_name, last_name, department)
VALUES
    (100, 'Abylay', 'Bakhytzhan', 'IT');

-- Synchronize sequence after explicit emp_id = 100
SELECT setval(
    pg_get_serial_sequence('employees', 'emp_id'),
    100,
    true
);


-- ============================================================
-- 3. INSERT WITH DEFAULT VALUES
-- salary and status use DEFAULT
-- ============================================================

INSERT INTO employees
    (first_name, last_name, department, hire_date)
VALUES
    ('Aidos', 'Sarsenov', 'Finance', '2023-09-15');


-- ============================================================
-- 4. INSERT MULTIPLE ROWS
-- ============================================================

INSERT INTO departments
    (dept_name, budget, manager_id)
VALUES
    ('IT', 150000, NULL),
    ('Finance', 100000, NULL),
    ('Marketing', 80000, NULL),
    ('Support', 60000, NULL);


-- ============================================================
-- 5. INSERT WITH EXPRESSIONS
-- ============================================================

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date)
VALUES
    ('Nursultan', 'Akhmetov', 'IT', 50000 * 1.1, CURRENT_DATE);


-- ============================================================
-- 6. INSERT FROM SELECT
-- ============================================================

CREATE TEMPORARY TABLE temp_employees AS
SELECT *
FROM employees
WHERE FALSE;

INSERT INTO temp_employees
SELECT *
FROM employees
WHERE department = 'IT';


-- ============================================================
-- 7. UPDATE WITH ARITHMETIC EXPRESSIONS
-- ============================================================

UPDATE employees
SET salary = salary * 1.10
WHERE salary IS NOT NULL;


-- ============================================================
-- 8. UPDATE WITH WHERE AND MULTIPLE CONDITIONS
-- ============================================================

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';


-- ============================================================
-- 9. UPDATE USING CASE
-- ============================================================

UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END
WHERE salary IS NOT NULL;


-- ============================================================
-- 10. UPDATE WITH DEFAULT
-- ============================================================

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';


-- ============================================================
-- 11. UPDATE WITH SUBQUERY
-- ============================================================

UPDATE departments d
SET budget = (
    SELECT COALESCE(AVG(e.salary), 0) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
)::INTEGER
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department = d.dept_name
);


-- ============================================================
-- Restore employees for department-based tests
-- ============================================================

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date)
VALUES
    ('Dias', 'Kassymov', 'IT', 60000, '2022-05-10'),
    ('Miras', 'Orazov', 'IT', 65000, '2021-06-15'),
    ('Arman', 'Bekov', 'IT', 55000, '2023-02-10'),
    ('Erlan', 'Tulegenov', 'IT', 50000, '2023-03-20'),
    ('Madina', 'Yerlanova', 'Finance', 60000, '2022-04-10');


-- ============================================================
-- 12. UPDATE MULTIPLE COLUMNS
-- ============================================================

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date)
VALUES
    ('Sanzhar', 'Nurlanov', 'Sales', 60000, '2022-05-10');

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';


-- ============================================================
-- 13. DELETE WITH SIMPLE WHERE
-- ============================================================

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date, status)
VALUES
    ('Bekzat', 'Amanov', 'HR', 30000, '2020-01-01', 'Terminated');

DELETE FROM employees
WHERE status = 'Terminated';


-- ============================================================
-- 14. DELETE WITH COMPLEX WHERE
-- ============================================================

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date, status)
VALUES
    ('Test', 'Employee', NULL, 35000, '2024-01-01', 'Active');

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;


-- ============================================================
-- 15. DELETE WITH SUBQUERY
-- Delete unused Support department
-- ============================================================

DELETE FROM departments d
WHERE d.dept_name NOT IN (
    SELECT DISTINCT e.department
    FROM employees e
    WHERE e.department IS NOT NULL
)
AND d.dept_name = 'Support';


-- ============================================================
-- 16. DELETE WITH RETURNING
-- ============================================================

INSERT INTO projects
    (project_name, dept_id, start_date, end_date, budget)
SELECT
    'Old Project',
    d.dept_id,
    '2021-01-01',
    '2022-01-01',
    40000
FROM departments d
WHERE d.dept_name = 'IT'
LIMIT 1;

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;


-- ============================================================
-- 17. INSERT WITH NULL VALUES
-- ============================================================

INSERT INTO employees
    (first_name, last_name, salary, department)
VALUES
    ('Alikhan', 'Serikov', NULL, NULL);


-- ============================================================
-- 18. UPDATE NULL HANDLING
-- ============================================================

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;


-- ============================================================
-- 19. DELETE WITH NULL CONDITIONS
-- ============================================================

INSERT INTO employees
    (first_name, last_name, salary, department)
VALUES
    ('Aruzhan', 'Kanatova', NULL, 'IT');

INSERT INTO employees
    (first_name, last_name, salary, department)
VALUES
    ('Dana', 'Maratova', 40000, NULL);

DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;


-- ============================================================
-- 20. INSERT WITH RETURNING
-- ============================================================

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date)
VALUES
    ('Zhansaya', 'Serikova', 'IT', 60000, CURRENT_DATE)
RETURNING
    emp_id,
    first_name || ' ' || last_name AS full_name;


-- ============================================================
-- 21. UPDATE WITH RETURNING
-- IT salary +5000
-- ============================================================

WITH old_values AS (
    SELECT
        emp_id,
        salary AS old_salary
    FROM employees
    WHERE department = 'IT'
)
UPDATE employees e
SET salary = e.salary + 5000
FROM old_values o
WHERE e.emp_id = o.emp_id
RETURNING
    e.emp_id,
    o.old_salary,
    e.salary AS new_salary;


-- ============================================================
-- 22. DELETE WITH RETURNING ALL COLUMNS
-- ============================================================

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;


-- ============================================================
-- 23. CONDITIONAL INSERT
-- ============================================================

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date)
SELECT
    'Abylay',
    'Bakhytzhan',
    'IT',
    70000,
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM employees
    WHERE first_name = 'Abylay'
      AND last_name = 'Bakhytzhan'
);


-- ============================================================
-- 24. UPDATE WITH JOIN LOGIC USING SUBQUERY
-- ============================================================

UPDATE employees e
SET salary = e.salary *
    CASE
        WHEN d.budget > 100000 THEN 1.10
        ELSE 1.05
    END
FROM departments d
WHERE e.department = d.dept_name;


-- ============================================================
-- 25. BULK OPERATIONS
-- ============================================================

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date)
VALUES
    ('Aigerim', 'Bolatova', 'IT', 40000, CURRENT_DATE),
    ('Madina', 'Yerlanova', 'IT', 41000, CURRENT_DATE),
    ('Aruzhan', 'Kanatova', 'Finance', 42000, CURRENT_DATE),
    ('Dana', 'Maratova', 'Marketing', 43000, CURRENT_DATE),
    ('Zhansaya', 'Serikova', 'Finance', 44000, CURRENT_DATE);

UPDATE employees
SET salary = salary * 1.10
WHERE first_name IN
    ('Aigerim', 'Madina', 'Aruzhan', 'Dana', 'Zhansaya');


-- ============================================================
-- 26. DATA MIGRATION SIMULATION
-- ============================================================

CREATE TABLE employee_archive (
    emp_id INTEGER,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(100),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(30),
    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date, status)
VALUES
    ('Bekzat', 'Amanov', 'Finance', 45000, '2022-02-15', 'Inactive');

INSERT INTO employee_archive
    (emp_id, first_name, last_name, department, salary, hire_date, status)
SELECT
    emp_id,
    first_name,
    last_name,
    department,
    salary,
    hire_date,
    status
FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';


-- ============================================================
-- 27. COMPLEX BUSINESS LOGIC
-- ============================================================

INSERT INTO projects
    (project_name, dept_id, start_date, end_date, budget)
SELECT
    'Kazakhstan Project',
    d.dept_id,
    CURRENT_DATE,
    CURRENT_DATE + INTERVAL '60 days',
    75000
FROM departments d
WHERE d.dept_name = 'IT'
LIMIT 1;

UPDATE projects p
SET end_date = p.end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND p.dept_id IN (
      SELECT d.dept_id
      FROM departments d
      JOIN employees e
        ON e.department = d.dept_name
      GROUP BY d.dept_id
      HAVING COUNT(e.emp_id) > 3
  );


-- ============================================================
-- FINAL OUTPUT
-- ============================================================

SELECT * FROM employees;

SELECT * FROM departments;

SELECT * FROM projects;

SELECT * FROM employee_archive;
