-- Laboratory Work 8: SQL Indexes
-- Student: Abylay Bakhytzhan
-- PostgreSQL
-- Uses employees, departments, and projects tables from Lab 6.

-- PART 1. PREPARATION

DROP VIEW IF EXISTS index_documentation;

DROP INDEX IF EXISTS
    emp_salary_idx,
    employees_salary_index,
    emp_dept_idx,
    emp_dept_salary_idx,
    emp_salary_dept_idx,
    emp_email_unique_idx,
    emp_salary_desc_idx,
    proj_budget_nulls_first_idx,
    emp_name_lower_idx,
    emp_hire_year_idx,
    emp_salary_filter_idx,
    proj_high_budget_idx,
    dept_name_hash_idx,
    proj_name_btree_idx,
    proj_name_hash_idx,
    emp_hire_month_idx,
    emp_dept_email_unique_idx,
    emp_covering_idx;

ALTER TABLE employees ADD COLUMN IF NOT EXISTS email VARCHAR(100);
ALTER TABLE employees ADD COLUMN IF NOT EXISTS phone VARCHAR(20);
ALTER TABLE employees ADD COLUMN IF NOT EXISTS hire_date DATE;

UPDATE employees
SET email = CASE emp_id
    WHEN 1 THEN 'john.smith@company.com'
    WHEN 2 THEN 'jane.doe@company.com'
    WHEN 3 THEN 'mike.johnson@company.com'
    WHEN 4 THEN 'sarah.williams@company.com'
    WHEN 5 THEN 'tom.brown@company.com'
    ELSE email
END
WHERE emp_id BETWEEN 1 AND 5;

UPDATE employees
SET hire_date = CASE emp_id
    WHEN 1 THEN DATE '2020-01-15'
    WHEN 2 THEN DATE '2019-06-20'
    WHEN 3 THEN DATE '2021-03-10'
    WHEN 4 THEN DATE '2020-11-05'
    WHEN 5 THEN DATE '2018-08-25'
    ELSE hire_date
END
WHERE emp_id BETWEEN 1 AND 5;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'employees'::regclass
          AND conname = 'employees_phone_key'
    ) THEN
        ALTER TABLE employees
        ADD CONSTRAINT employees_phone_key UNIQUE (phone);
    END IF;
END;
$$;


-- PART 2. BASIC INDEXES

-- Exercise 2.1
CREATE INDEX emp_salary_idx ON employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public' AND tablename = 'employees'
ORDER BY indexname;

-- Exercise 2.2
CREATE INDEX emp_dept_idx ON employees(dept_id);

SELECT * FROM employees WHERE dept_id = 101;

-- Exercise 2.3
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;


-- PART 3. MULTICOLUMN INDEXES

-- Exercise 3.1
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;

-- Exercise 3.2
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);

SELECT *
FROM employees
WHERE dept_id = 102 AND salary > 50000;

SELECT *
FROM employees
WHERE salary > 50000 AND dept_id = 102;


-- PART 4. UNIQUE INDEXES

-- Exercise 4.1
CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

DO $$
BEGIN
    BEGIN
        INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
        VALUES (99999, 'New Employee', 101, 55000, 'john.smith@company.com');
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'Duplicate email rejected by the unique index.';
    END;
END;
$$;

-- Exercise 4.2
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'employees'
  AND indexname LIKE '%phone%';


-- PART 5. INDEXES AND SORTING

-- Exercise 5.1
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

-- Exercise 5.2
CREATE INDEX proj_budget_nulls_first_idx
ON projects(budget NULLS FIRST);

SELECT project_name, budget
FROM projects
ORDER BY budget NULLS FIRST;


-- PART 6. INDEXES ON EXPRESSIONS

-- Exercise 6.1
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));

SELECT *
FROM employees
WHERE LOWER(emp_name) = 'john smith';

-- Exercise 6.2
CREATE INDEX emp_hire_year_idx
ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;


-- PART 7. MANAGING INDEXES

-- Exercise 7.1
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;

SELECT indexname
FROM pg_indexes
WHERE schemaname = 'public' AND tablename = 'employees'
ORDER BY indexname;

-- Exercise 7.2
DROP INDEX emp_salary_dept_idx;

-- Exercise 7.3
REINDEX INDEX employees_salary_index;


-- PART 8. PRACTICAL SCENARIOS

-- Exercise 8.1
CREATE INDEX emp_salary_filter_idx
ON employees(salary)
WHERE salary > 50000;

SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

-- Exercise 8.2
CREATE INDEX proj_high_budget_idx
ON projects(budget)
WHERE budget > 80000;

SELECT project_name, budget
FROM projects
WHERE budget > 80000;

-- Exercise 8.3
EXPLAIN
SELECT * FROM employees WHERE salary > 52000;


-- PART 9. INDEX TYPES COMPARISON

-- Exercise 9.1
CREATE INDEX dept_name_hash_idx
ON departments USING HASH (dept_name);

SELECT * FROM departments WHERE dept_name = 'IT';

-- Exercise 9.2
CREATE INDEX proj_name_btree_idx ON projects(project_name);
CREATE INDEX proj_name_hash_idx
ON projects USING HASH (project_name);

SELECT * FROM projects WHERE project_name = 'Website Redesign';

SELECT * FROM projects WHERE project_name > 'Database';


-- PART 10. CLEANUP AND BEST PRACTICES

-- Exercise 10.1
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(
        pg_relation_size(
            (quote_ident(schemaname) || '.' || quote_ident(indexname))::regclass
        )
    ) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Exercise 10.2
DROP INDEX IF EXISTS proj_name_hash_idx;

-- Exercise 10.3
CREATE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE '%salary%';

SELECT * FROM index_documentation;


-- SUMMARY QUESTIONS

-- 1. B-tree is the default index type in PostgreSQL.
-- 2. Index frequently filtered columns, JOIN columns, and ORDER BY columns.
-- 3. Avoid indexes on rarely queried columns and very small tables.
-- 4. INSERT, UPDATE, and DELETE operations also maintain indexes,
--    which adds write overhead.
-- 5. Use EXPLAIN or EXPLAIN ANALYZE to inspect the query plan.


-- OPTIONAL CHALLENGES

-- Challenge 1
CREATE INDEX emp_hire_month_idx
ON employees(EXTRACT(MONTH FROM hire_date));

SELECT *
FROM employees
WHERE EXTRACT(MONTH FROM hire_date) = 1;

-- Challenge 2
CREATE UNIQUE INDEX emp_dept_email_unique_idx
ON employees(dept_id, email);

-- Challenge 3
EXPLAIN ANALYZE
SELECT * FROM employees WHERE salary > 52000;

SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;

EXPLAIN ANALYZE
SELECT * FROM employees WHERE salary > 52000;

RESET enable_indexscan;
RESET enable_bitmapscan;

-- Challenge 4
CREATE INDEX emp_covering_idx
ON employees(dept_id) INCLUDE (emp_name, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101;
