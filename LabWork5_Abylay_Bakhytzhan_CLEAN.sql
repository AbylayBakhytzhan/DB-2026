-- Name: Abylay Bakhytzhan
-- Student ID: 24B032192

-- Task 1.1
CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);

-- Task 1.2
CREATE TABLE products_catalog (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    regular_price NUMERIC NOT NULL,
    discount_price NUMERIC NOT NULL,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
    )
);

-- Task 1.3
CREATE TABLE bookings (
    booking_id INTEGER PRIMARY KEY,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10),
    CONSTRAINT valid_booking_dates CHECK (check_out_date > check_in_date)
);

-- Task 1.4
INSERT INTO employees VALUES
(1, 'John', 'Smith', 30, 75000),
(2, 'Sarah', 'Johnson', 25, 65000);

INSERT INTO products_catalog VALUES
(1, 'Keyboard', 100, 80),
(2, 'Mouse', 50, 35);

INSERT INTO bookings VALUES
(1, '2026-11-01', '2026-11-05', 2),
(2, '2026-12-10', '2026-12-12', 4);

-- Task 2.1
CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

-- Task 2.2
CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

-- Task 2.3
INSERT INTO customers VALUES
(1, 'john@example.com', '+77010000001', '2026-01-10'),
(2, 'sarah@example.com', NULL, '2026-02-15'),
(3, 'lisa@example.com', NULL, '2026-04-01');

INSERT INTO inventory VALUES
(1, 'Notebook', 100, 2.50, CURRENT_TIMESTAMP),
(2, 'Pen', 50, 1.20, CURRENT_TIMESTAMP);

-- Task 3.1
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Task 3.2
CREATE TABLE course_enrollments (
    enrollment_id INTEGER PRIMARY KEY,
    student_id INTEGER NOT NULL,
    course_code TEXT NOT NULL,
    semester TEXT NOT NULL,
    CONSTRAINT unique_course_enrollment UNIQUE (student_id, course_code, semester)
);

-- Task 3.3
ALTER TABLE users
ADD CONSTRAINT unique_username UNIQUE (username);

ALTER TABLE users
ADD CONSTRAINT unique_email UNIQUE (email);

INSERT INTO users (user_id, username, email) VALUES
(1, 'abylay', 'abylay@example.com'),
(2, 'dana', 'dana@example.com');

-- Task 4.1
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments VALUES
(1, 'IT', 'Almaty'),
(2, 'Sales', 'Astana'),
(3, 'HR', 'Shymkent');

-- Task 4.2
CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

-- Task 4.3
-- PRIMARY KEY uniquely identifies a row and cannot be NULL.
-- UNIQUE prevents duplicate values or combinations.
-- A table can have one PRIMARY KEY constraint and multiple UNIQUE constraints.
-- Use a single-column key when one column identifies a row.
-- Use a composite key when a combination of columns identifies a row.

-- Task 5.1
CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);

INSERT INTO employees_dept VALUES
(1, 'John Smith', 1, '2024-01-15'),
(2, 'Sarah Johnson', 2, '2024-03-20');

-- Task 5.2
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

-- Task 5.3
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

INSERT INTO categories VALUES
(1, 'Electronics'),
(2, 'Stationery');

INSERT INTO products_fk VALUES
(1, 'Headphones', 1),
(2, 'Notebook', 2);

INSERT INTO orders VALUES
(1, '2026-10-01'),
(2, '2026-10-02');

INSERT INTO order_items VALUES
(1, 1, 1, 2),
(2, 1, 2, 1),
(3, 2, 1, 1);

-- Task 6.1
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

INSERT INTO ecommerce_customers VALUES
(1, 'Abylay Bakhytzhan', 'abylay@example.com', '+77010000001', '2026-01-10'),
(2, 'Dana Karimova', 'dana@example.com', '+77010000002', '2026-02-12'),
(3, 'Arman Sadykov', 'arman@example.com', NULL, '2026-03-05'),
(4, 'Aigerim Nurlan', 'aigerim@example.com', '+77010000004', '2026-04-20'),
(5, 'Dias Omarov', 'dias@example.com', NULL, '2026-05-11');

INSERT INTO products VALUES
(1, 'Laptop', 'Portable computer', 450000, 10),
(2, 'Mouse', 'Wireless mouse', 8000, 50),
(3, 'Keyboard', 'Mechanical keyboard', 25000, 25),
(4, 'Monitor', '27-inch monitor', 120000, 12),
(5, 'USB Cable', 'USB-C cable', 3000, 100);

INSERT INTO ecommerce_orders VALUES
(1, 1, '2026-09-01', 466000, 'delivered'),
(2, 2, '2026-09-05', 25000, 'shipped'),
(3, 3, '2026-09-10', 120000, 'processing'),
(4, 4, '2026-09-15', 6000, 'pending'),
(5, 5, '2026-09-20', 450000, 'cancelled');

INSERT INTO order_details VALUES
(1, 1, 1, 1, 450000),
(2, 1, 2, 2, 8000),
(3, 2, 3, 1, 25000),
(4, 3, 4, 1, 120000),
(5, 4, 5, 2, 3000),
(6, 5, 1, 1, 450000);
