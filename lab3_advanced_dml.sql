-- ============================================
-- LABORATORY WORK #3 - ADVANCED DML
-- Name: Abylay Bakhytzhan
-- ID: 24B032192
-- ============================================

-- ============================================
-- PART A: DATABASE AND TABLE SETUP
-- ============================================

CREATE DATABASE advanced_lab;

-- Connect to advanced_lab before running the rest of the code.

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50) DEFAULT 'Unassigned',
    salary INTEGER DEFAULT 0,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);

-- ============================================
-- SAMPLE DATA
-- ============================================

INSERT INTO employees
(first_name, last_name, department, salary, hire_date, status)
VALUES
('John', 'Smith', 'IT', 70000, '2019-05-10', 'Active'),
('Alice', 'Brown', 'Sales', 55000, '2021-03-15', 'Active'),
('Michael', 'Johnson', 'IT', 90000, '2018-07-20', 'Active'),
('Sarah', 'Davis', 'HR', 45000, '2022-02-10', 'Active'),
('David', 'Wilson', 'Sales', 65000, '2019-11-01', 'Active'),
('Emma', 'Taylor', 'IT', 80000, '2020-06-25', 'Inactive'),
('James', 'Anderson', 'Marketing', 35000, '2024-01-15', 'Active'),
('Olivia', 'Thomas', 'HR', 50000, '2017-04-12', 'Active');

INSERT INTO departments
(dept_name, budget, manager_id)
VALUES
('IT', 150000, 1),
('Sales', 90000, 2),
('HR', 70000, 4);

INSERT INTO projects
(project_name, dept_id, start_date, end_date, budget)
VALUES
('Website Development', 1, '2023-01-10', '2023-12-01', 80000),
('Sales Campaign', 2, '2023-03-01', '2023-10-01', 40000),
('HR System', 3, '2022-01-01', '2022-12-01', 60000),
('Old Project', 1, '2021-01-01', '2022-01-01', 30000);

-- ============================================
-- PART B: ADVANCED INSERT OPERATIONS
-- ============================================

-- 2. INSERT with column specification
INSERT INTO employees
(emp_id, first_name, last_name, department)
VALUES
(100, 'Robert', 'Miller', 'IT');

-- 3. INSERT with DEFAULT values
INSERT INTO employees
(first_name, last_name, salary, status)
VALUES
('Daniel', 'Moore', DEFAULT, DEFAULT);

-- 4. INSERT multiple rows in single statement
INSERT INTO departments
(dept_name, budget, manager_id)
VALUES
('Finance', 120000, 5),
('Marketing', 80000, 7),
('Support', 60000, 8);

-- 5. INSERT with expressions
INSERT INTO employees
(first_name, last_name, salary, hire_date, department)
VALUES
('Peter', 'Clark', 50000 * 1.1, CURRENT_DATE, 'IT');

-- 6. INSERT from SELECT (subquery)
CREATE TEMPORARY TABLE temp_employees AS
SELECT *
FROM employees
WHERE department = 'IT';

SELECT * FROM temp_employees;

-- ============================================
-- PART C: COMPLEX UPDATE OPERATIONS
-- ============================================

-- 7. UPDATE with arithmetic expressions
UPDATE employees
SET salary = salary * 1.10;

-- 8. UPDATE with WHERE clause and multiple conditions
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';

-- 9. UPDATE using CASE expression
UPDATE employees
SET department =
    CASE
        WHEN salary > 80000 THEN 'Management'
        WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
        ELSE 'Junior'
    END;

-- 10. UPDATE with DEFAULT
UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

-- 11. UPDATE with subquery
UPDATE departments d
SET budget = (
    SELECT COALESCE(AVG(e.salary), 0) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
);

-- 12. UPDATE multiple columns
UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

-- ============================================
-- PART D: ADVANCED DELETE OPERATIONS
-- ============================================

-- 13. DELETE with simple WHERE condition
DELETE FROM employees
WHERE status = 'Terminated';

-- 14. DELETE with complex WHERE clause
DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

-- 15. DELETE with subquery
DELETE FROM departments d
WHERE d.dept_id NOT IN (
    SELECT DISTINCT p.dept_id
    FROM projects p
    WHERE p.dept_id IS NOT NULL
);

-- 16. DELETE with RETURNING clause
DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

-- ============================================
-- PART E: OPERATIONS WITH NULL VALUES
-- ============================================

-- 17. INSERT with NULL values
INSERT INTO employees
(first_name, last_name, salary, department)
VALUES
('Tom', 'Jackson', NULL, NULL);

-- 18. UPDATE NULL handling
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

-- 19. DELETE with NULL conditions
DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;

-- ============================================
-- PART F: RETURNING CLAUSE OPERATIONS
-- ============================================

-- 20. INSERT with RETURNING
INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
VALUES
('William', 'Harris', 'IT', 65000, CURRENT_DATE)
RETURNING
    emp_id,
    first_name || ' ' || last_name AS full_name;

-- 21. UPDATE with RETURNING
WITH old_values AS (
    SELECT emp_id, salary AS old_salary
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

-- 22. DELETE with RETURNING all columns
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

-- ============================================
-- PART G: ADVANCED DML PATTERNS
-- ============================================

-- 23. Conditional INSERT
INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
SELECT
    'George',
    'Martin',
    'IT',
    60000,
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM employees
    WHERE first_name = 'George'
      AND last_name = 'Martin'
);

-- 24. UPDATE with JOIN logic using subqueries
UPDATE employees e
SET salary =
    CASE
        WHEN (
            SELECT d.budget
            FROM departments d
            WHERE d.dept_name = e.department
        ) > 100000
        THEN e.salary * 1.10
        ELSE e.salary * 1.05
    END;

-- 25. BULK OPERATIONS
INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
VALUES
('Henry', 'Lee', 'IT', 50000, CURRENT_DATE),
('Jack', 'Walker', 'Sales', 55000, CURRENT_DATE),
('Sophia', 'Hall', 'HR', 48000, CURRENT_DATE),
('Liam', 'Allen', 'Marketing', 45000, CURRENT_DATE),
('Mia', 'Young', 'IT', 60000, CURRENT_DATE);

UPDATE employees
SET salary = salary * 1.10
WHERE first_name IN
('Henry', 'Jack', 'Sophia', 'Liam', 'Mia');

-- ============================================
-- 26. DATA MIGRATION SIMULATION
-- ============================================

CREATE TABLE employee_archive (
    emp_id INTEGER,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20),
    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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

-- ============================================
-- 27. COMPLEX BUSINESS LOGIC
-- ============================================

UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
  AND (
      SELECT COUNT(*)
      FROM employees e
      JOIN departments d
        ON d.dept_name = e.department
      WHERE d.dept_id = p.dept_id
  ) > 3;

-- ============================================
-- FINAL CHECKS
-- ============================================

SELECT * FROM employees;
SELECT * FROM departments;
SELECT * FROM projects;
SELECT * FROM employee_archive;
