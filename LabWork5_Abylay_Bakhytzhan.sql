-- Laboratory Work 5: Database Constraints
-- Student: Abylay Bakhytzhan
-- Student ID: 24B032192
-- PostgreSQL
--
-- Invalid INSERT/DELETE tests are commented out so the whole script can run.
-- Expected errors and test results are documented beside the relevant statements.

-- PART 1: CHECK CONSTRAINTS

-- Task 1.1: age must be between 18 and 65; salary must be > 0.
CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);
INSERT INTO employees VALUES
(1, 'John', 'Smith', 30, 75000),
(2, 'Sarah', 'Johnson', 25, 65000);
-- Expected failure: age below 18.
-- INSERT INTO employees VALUES (3, 'Tom', 'Young', 16, 30000);
-- Expected failure: salary is not greater than 0.
-- INSERT INTO employees VALUES (4, 'Ann', 'Stone', 35, 0);

-- Task 1.2: named CHECK constraint valid_discount.
CREATE TABLE products_catalog (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    regular_price NUMERIC NOT NULL,
    discount_price NUMERIC NOT NULL,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0 AND discount_price > 0
        AND discount_price < regular_price
    )
);
INSERT INTO products_catalog VALUES
(1, 'Keyboard', 100, 80),
(2, 'Mouse', 50, 35);
-- Expected failure: discount_price is not less than regular_price.
-- INSERT INTO products_catalog VALUES (3, 'Monitor', 100, 120);
-- Expected failure: regular_price must be > 0.
-- INSERT INTO products_catalog VALUES (4, 'Cable', 0, 1);
-- Expected failure: discount_price must be > 0.
-- INSERT INTO products_catalog VALUES (5, 'Adapter', 20, 0);

-- Task 1.3: guest count and booking date checks.
CREATE TABLE bookings (
    booking_id INTEGER PRIMARY KEY,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10),
    CONSTRAINT valid_booking_dates CHECK (check_out_date > check_in_date)
);
INSERT INTO bookings VALUES
(1, '2026-11-01', '2026-11-05', 2),
(2, '2026-12-10', '2026-12-12', 4);
-- Expected failure: more than 10 guests.
-- INSERT INTO bookings VALUES (3, '2026-11-01', '2026-11-05', 11);
-- Expected failure: checkout is not after check-in.
-- INSERT INTO bookings VALUES (4, '2026-11-05', '2026-11-05', 2);

-- Task 1.4: valid rows are inserted above; invalid test cases are commented out
-- because they intentionally violate CHECK constraints.

-- PART 2: NOT NULL CONSTRAINTS

-- Task 2.1: customer_id, email, registration_date cannot be NULL.
CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);
INSERT INTO customers VALUES
(1, 'john@example.com', '+77010000001', '2026-01-10'),
(2, 'sarah@example.com', NULL, '2026-02-15');
-- Expected failure: email is NOT NULL.
-- INSERT INTO customers VALUES (3, NULL, '+77010000003', '2026-03-01');
-- Expected failure: registration_date is NOT NULL.
-- INSERT INTO customers VALUES (4, 'tom@example.com', '+77010000004', NULL);
-- Valid: phone is nullable.
INSERT INTO customers VALUES (5, 'lisa@example.com', NULL, '2026-04-01');

-- Task 2.2: NOT NULL and CHECK constraints.
CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);
INSERT INTO inventory VALUES
(1, 'Notebook', 100, 2.50, CURRENT_TIMESTAMP),
(2, 'Pen', 50, 1.20, CURRENT_TIMESTAMP);
-- Expected failure: item_name is NOT NULL.
-- INSERT INTO inventory VALUES (3, NULL, 10, 2.00, CURRENT_TIMESTAMP);
-- Expected failure: quantity cannot be negative.
-- INSERT INTO inventory VALUES (4, 'Pencil', -1, 0.50, CURRENT_TIMESTAMP);
-- Expected failure: unit_price must be > 0.
-- INSERT INTO inventory VALUES (5, 'Ruler', 10, 0, CURRENT_TIMESTAMP);

-- Task 2.3: NULL tests are shown above; phone is allowed to be NULL.

-- PART 3: UNIQUE CONSTRAINTS

-- Task 3.1 and 3.3: named UNIQUE constraints.
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    username TEXT CONSTRAINT unique_username UNIQUE,
    email TEXT CONSTRAINT unique_email UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO users (user_id, username, email) VALUES
(1, 'abylay', 'abylay@example.com'),
(2, 'dana', 'dana@example.com');
-- Expected failure: username already exists (unique_username).
-- INSERT INTO users (user_id, username, email) VALUES (3, 'abylay', 'new@example.com');
-- Expected failure: email already exists (unique_email).
-- INSERT INTO users (user_id, username, email) VALUES (4, 'newuser', 'dana@example.com');

-- Task 3.2: unique student/course/semester combination.
CREATE TABLE course_enrollments (
    enrollment_id INTEGER PRIMARY KEY,
    student_id INTEGER NOT NULL,
    course_code TEXT NOT NULL,
    semester TEXT NOT NULL,
    CONSTRAINT unique_course_enrollment UNIQUE (student_id, course_code, semester)
);
INSERT INTO course_enrollments VALUES
(1, 1001, 'DB101', 'Fall 2026'),
(2, 1001, 'SE101', 'Fall 2026'),
(3, 1002, 'DB101', 'Fall 2026');
-- Expected failure: duplicate student/course/semester combination.
-- INSERT INTO course_enrollments VALUES (4, 1001, 'DB101', 'Fall 2026');

-- PART 4: PRIMARY KEY CONSTRAINTS

-- Task 4.1: primary key department ID.
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);
INSERT INTO departments VALUES
(1, 'IT', 'Almaty'),
(2, 'Sales', 'Astana'),
(3, 'HR', 'Shymkent');
-- Expected failure: duplicate primary key.
-- INSERT INTO departments VALUES (1, 'Finance', 'Almaty');
-- Expected failure: primary key cannot be NULL.
-- INSERT INTO departments VALUES (NULL, 'Finance', 'Almaty');

-- Task 4.2: composite primary key.
CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);
INSERT INTO student_courses VALUES
(1001, 101, '2026-09-01', 'A'),
(1001, 102, '2026-09-01', 'B'),
(1002, 101, '2026-09-02', 'A');
-- Expected failure: pair (student_id, course_id) already exists.
-- INSERT INTO student_courses VALUES (1001, 101, '2026-09-03', 'C');

-- Task 4.3: comparison exercise.
-- UNIQUE vs PRIMARY KEY: PRIMARY KEY uniquely identifies every row and cannot
-- contain NULL. UNIQUE prevents duplicate values/combinations; in PostgreSQL,
-- UNIQUE allows NULL unless NOT NULL is also specified.
-- A table has one PRIMARY KEY constraint (which may include multiple columns),
-- but it can have several UNIQUE constraints.
-- Use a single-column primary key when one value identifies a row. Use a
-- composite key when a combination identifies a row, e.g. student_id + course_id.

-- PART 5: FOREIGN KEY CONSTRAINTS

-- Task 5.1: department reference.
CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);
INSERT INTO employees_dept VALUES
(1, 'John Smith', 1, '2024-01-15'),
(2, 'Sarah Johnson', 2, '2024-03-20');
-- Expected failure: department 99 does not exist.
-- INSERT INTO employees_dept VALUES (3, 'Tom Young', 99, '2025-01-01');

-- Task 5.2: library schema.
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);
CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);
CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);
INSERT INTO authors VALUES
(1, 'George Orwell', 'United Kingdom'),
(2, 'J. K. Rowling', 'United Kingdom'),
(3, 'Chingiz Aitmatov', 'Kyrgyzstan'),
(4, 'Paulo Coelho', 'Brazil'),
(5, 'Jane Austen', 'United Kingdom');
INSERT INTO publishers VALUES
(1, 'Penguin Books', 'London'),
(2, 'Bloomsbury', 'London'),
(3, 'Vintage', 'New York'),
(4, 'Everyman Library', 'London'),
(5, 'Kyrgyzstan Publishing House', 'Bishkek');
INSERT INTO books VALUES
(1, '1984', 1, 1, 1949, '9780451524935'),
(2, 'Harry Potter and the Philosopher''s Stone', 2, 2, 1997, '9780747532699'),
(3, 'The Day Lasts More Than a Hundred Years', 3, 5, 1980, '9780140060901'),
(4, 'The Alchemist', 4, 3, 1988, '9780061122415'),
(5, 'Pride and Prejudice', 5, 4, 1813, '9780141439518');
-- Expected failure: author 99 does not exist.
-- INSERT INTO books VALUES (6, 'Unknown Book', 99, 1, 2020, '9780000000001');
-- Expected failure: ISBN must be unique.
-- INSERT INTO books VALUES (7, 'Duplicate ISBN Book', 1, 1, 2021, '9780451524935');

-- Task 5.3: ON DELETE RESTRICT and CASCADE.
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);
CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);
CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);
INSERT INTO categories VALUES (1, 'Electronics'), (2, 'Stationery');
INSERT INTO products_fk VALUES (1, 'Headphones', 1), (2, 'Notebook', 2);
INSERT INTO orders VALUES (1, '2026-10-01'), (2, '2026-10-02');
INSERT INTO order_items VALUES
(1, 1, 1, 2),
(2, 1, 2, 1),
(3, 2, 1, 1);
-- Expected: fails because category 1 is referenced by a product (RESTRICT).
-- DELETE FROM categories WHERE category_id = 1;
-- CASCADE test (uncomment to run): order_items for order 1 are automatically deleted.
-- SELECT * FROM order_items WHERE order_id = 1;
-- DELETE FROM orders WHERE order_id = 1;
-- SELECT * FROM order_items WHERE order_id = 1;

-- PART 6: PRACTICAL APPLICATION - E-COMMERCE DATABASE

-- Customer deletion is restricted when orders exist. Order details cascade
-- when an order is deleted. Product deletion is restricted when referenced.
CREATE TABLE ecommerce_customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    registration_date DATE NOT NULL
);
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);
CREATE TABLE ecommerce_orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES ecommerce_customers(customer_id) ON DELETE RESTRICT,
    order_date DATE NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (
        status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')
    )
);
CREATE TABLE order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES ecommerce_orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);

-- At least 5 customers.
INSERT INTO ecommerce_customers VALUES
(1, 'Abylay Bakhytzhan', 'abylay@example.com', '+77010000001', '2026-01-10'),
(2, 'Dana Karimova', 'dana@example.com', '+77010000002', '2026-02-12'),
(3, 'Arman Sadykov', 'arman@example.com', NULL, '2026-03-05'),
(4, 'Aigerim Nurlan', 'aigerim@example.com', '+77010000004', '2026-04-20'),
(5, 'Dias Omarov', 'dias@example.com', NULL, '2026-05-11');

-- At least 5 products.
INSERT INTO products VALUES
(1, 'Laptop', 'Portable computer', 450000, 10),
(2, 'Mouse', 'Wireless mouse', 8000, 50),
(3, 'Keyboard', 'Mechanical keyboard', 25000, 25),
(4, 'Monitor', '27-inch monitor', 120000, 12),
(5, 'USB Cable', 'USB-C cable', 3000, 100);

-- At least 5 orders.
INSERT INTO ecommerce_orders VALUES
(1, 1, '2026-09-01', 466000, 'delivered'),
(2, 2, '2026-09-05', 25000, 'shipped'),
(3, 3, '2026-09-10', 120000, 'processing'),
(4, 4, '2026-09-15', 6000, 'pending'),
(5, 5, '2026-09-20', 450000, 'cancelled');

-- At least 5 order details.
INSERT INTO order_details VALUES
(1, 1, 1, 1, 450000),
(2, 1, 2, 2, 8000),
(3, 2, 3, 1, 25000),
(4, 3, 4, 1, 120000),
(5, 4, 5, 2, 3000),
(6, 5, 1, 1, 450000);

-- Constraint tests: expected failures are commented out.
-- Duplicate email violates UNIQUE.
-- INSERT INTO ecommerce_customers VALUES (6, 'Duplicate Email', 'abylay@example.com', NULL, CURRENT_DATE);
-- Negative price violates CHECK (price >= 0).
-- INSERT INTO products VALUES (6, 'Invalid Product', 'Negative price', -10, 5);
-- Negative stock violates CHECK (stock_quantity >= 0).
-- INSERT INTO products VALUES (7, 'Invalid Stock', 'Negative stock', 10, -1);
-- Invalid status violates the status CHECK constraint.
-- INSERT INTO ecommerce_orders VALUES (6, 1, CURRENT_DATE, 100, 'returned');
-- Zero quantity violates CHECK (quantity > 0).
-- INSERT INTO order_details VALUES (7, 1, 2, 0, 8000);
-- Unknown customer violates FOREIGN KEY.
-- INSERT INTO ecommerce_orders VALUES (7, 99, CURRENT_DATE, 100, 'pending');
-- Unknown product violates FOREIGN KEY.
-- INSERT INTO order_details VALUES (8, 1, 99, 1, 100);

-- VERIFICATION QUERIES
SELECT * FROM employees ORDER BY employee_id;
SELECT * FROM products_catalog ORDER BY product_id;
SELECT * FROM bookings ORDER BY booking_id;
SELECT * FROM customers ORDER BY customer_id;
SELECT * FROM inventory ORDER BY item_id;
SELECT * FROM users ORDER BY user_id;
SELECT * FROM course_enrollments ORDER BY enrollment_id;
SELECT * FROM departments ORDER BY dept_id;
SELECT * FROM student_courses ORDER BY student_id, course_id;
SELECT * FROM employees_dept ORDER BY emp_id;
SELECT * FROM authors ORDER BY author_id;
SELECT * FROM publishers ORDER BY publisher_id;
SELECT * FROM books ORDER BY book_id;
SELECT * FROM categories ORDER BY category_id;
SELECT * FROM products_fk ORDER BY product_id;
SELECT * FROM orders ORDER BY order_id;
SELECT * FROM order_items ORDER BY item_id;
SELECT * FROM ecommerce_customers ORDER BY customer_id;
SELECT * FROM products ORDER BY product_id;
SELECT * FROM ecommerce_orders ORDER BY order_id;
SELECT * FROM order_details ORDER BY order_detail_id;

-- END OF LABORATORY WORK 5
