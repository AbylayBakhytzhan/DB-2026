-- PART 1
-- TASK 1.1: Database Creation with Parameters
-- ============================================

CREATE DATABASE university_main
WITH
    OWNER = postgres
    TEMPLATE = template0
    ENCODING = 'UTF8';


CREATE DATABASE university_archive
WITH
    OWNER = postgres
    TEMPLATE = template0
    CONNECTION LIMIT = 50;


CREATE DATABASE university_test
WITH
    OWNER = postgres
    TEMPLATE = template0
    CONNECTION LIMIT = 10;

ALTER DATABASE university_test IS_TEMPLATE = true;


-- ============================================
-- TASK 1.2: Tablespace Operations
-- ============================================

CREATE TABLESPACE student_data
LOCATION '/data/students';


CREATE TABLESPACE course_data
OWNER postgres
LOCATION '/data/courses';


CREATE DATABASE university_distributed
WITH
    TEMPLATE = template0
    ENCODING = 'LATIN9'
    TABLESPACE = student_data;


-- ============================================
-- PART 2
-- TASK 2.1: University Management System
-- Database: university_main
-- ============================================

CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone CHAR(15),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa DECIMAL(4,2),
    is_active BOOLEAN,
    graduation_year SMALLINT
);


CREATE TABLE professors (
    professor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    office_number VARCHAR(20),
    hire_date DATE,
    salary DECIMAL(12,2),
    is_tenured BOOLEAN,
    years_experience INTEGER
);


CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code CHAR(8),
    course_title VARCHAR(100),
    description TEXT,
    credits SMALLINT,
    max_enrollment INTEGER,
    course_fee DECIMAL(10,2),
    is_online BOOLEAN,
    created_at TIMESTAMP WITHOUT TIME ZONE
);


-- ============================================
-- TASK 2.2: Time-based and Specialized Tables
-- ============================================

CREATE TABLE class_schedule (
    schedule_id SERIAL PRIMARY KEY,
    course_id INTEGER,
    professor_id INTEGER,
    classroom VARCHAR(20),
    class_date DATE,
    start_time TIME WITHOUT TIME ZONE,
    end_time TIME WITHOUT TIME ZONE,
    duration INTERVAL
);


CREATE TABLE student_records (
    record_id SERIAL PRIMARY KEY,
    student_id INTEGER,
    course_id INTEGER,
    semester VARCHAR(20),
    year INTEGER,
    grade CHAR(2),
    attendance_percentage DECIMAL(4,1),
    submission_timestamp TIMESTAMP WITH TIME ZONE,
    last_updated TIMESTAMP WITH TIME ZONE
);


-- ============================================
-- PART 3
-- TASK 3.1: Modifying Existing Tables
-- ============================================

-- Students

ALTER TABLE students
ADD COLUMN middle_name VARCHAR(30);

ALTER TABLE students
ADD COLUMN student_status VARCHAR(20);

ALTER TABLE students
ALTER COLUMN phone TYPE VARCHAR(20);

ALTER TABLE students
ALTER COLUMN student_status SET DEFAULT 'ACTIVE';

ALTER TABLE students
ALTER COLUMN gpa SET DEFAULT 0.00;


-- Professors

ALTER TABLE professors
ADD COLUMN department_code CHAR(5);

ALTER TABLE professors
ADD COLUMN research_area TEXT;

ALTER TABLE professors
ALTER COLUMN years_experience TYPE SMALLINT;

ALTER TABLE professors
ALTER COLUMN is_tenured SET DEFAULT FALSE;

ALTER TABLE professors
ADD COLUMN last_promotion_date DATE;


-- Courses

ALTER TABLE courses
ADD COLUMN prerequisite_course_id INTEGER;

ALTER TABLE courses
ADD COLUMN difficulty_level SMALLINT;

ALTER TABLE courses
ALTER COLUMN course_code TYPE VARCHAR(10);

ALTER TABLE courses
ALTER COLUMN credits SET DEFAULT 3;

ALTER TABLE courses
ADD COLUMN lab_required BOOLEAN DEFAULT FALSE;


-- ============================================
-- TASK 3.2: Column Management Operations
-- ============================================

-- Class Schedule

ALTER TABLE class_schedule
ADD COLUMN room_capacity INTEGER;

ALTER TABLE class_schedule
DROP COLUMN duration;

ALTER TABLE class_schedule
ADD COLUMN session_type VARCHAR(15);

ALTER TABLE class_schedule
ALTER COLUMN classroom TYPE VARCHAR(30);

ALTER TABLE class_schedule
ADD COLUMN equipment_needed TEXT;


-- Student Records

ALTER TABLE student_records
ADD COLUMN extra_credit_points DECIMAL(4,1);

ALTER TABLE student_records
ALTER COLUMN grade TYPE VARCHAR(5);

ALTER TABLE student_records
ALTER COLUMN extra_credit_points SET DEFAULT 0.0;

ALTER TABLE student_records
ADD COLUMN final_exam_date DATE;

ALTER TABLE student_records
DROP COLUMN last_updated;


-- ============================================
-- PART 4
-- TASK 4.1: Additional Supporting Tables
-- ============================================

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100),
    department_code CHAR(5),
    building VARCHAR(50),
    phone VARCHAR(15),
    budget DECIMAL(15,2),
    established_year INTEGER
);


CREATE TABLE library_books (
    book_id SERIAL PRIMARY KEY,
    isbn CHAR(13),
    title VARCHAR(200),
    author VARCHAR(100),
    publisher VARCHAR(100),
    publication_date DATE,
    price DECIMAL(10,2),
    is_available BOOLEAN,
    acquisition_timestamp TIMESTAMP WITHOUT TIME ZONE
);


CREATE TABLE student_book_loans (
    loan_id SERIAL PRIMARY KEY,
    student_id INTEGER,
    book_id INTEGER,
    loan_date DATE,
    due_date DATE,
    return_date DATE,
    fine_amount DECIMAL(10,2),
    loan_status VARCHAR(20)
);


-- ============================================
-- TASK 4.2: Table Modifications for Integration
-- ============================================

ALTER TABLE professors
ADD COLUMN department_id INTEGER;

ALTER TABLE students
ADD COLUMN advisor_id INTEGER;

ALTER TABLE courses
ADD COLUMN department_id INTEGER;


CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage DECIMAL(4,1),
    max_percentage DECIMAL(4,1),
    gpa_points DECIMAL(4,2)
);


CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INTEGER,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN
);


-- ============================================
-- PART 5
-- TASK 5.1: Conditional Table Operations
-- ============================================

DROP TABLE IF EXISTS student_book_loans;

DROP TABLE IF EXISTS library_books;

DROP TABLE IF EXISTS grade_scale;


-- Recreate grade_scale with description

CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage DECIMAL(4,1),
    max_percentage DECIMAL(4,1),
    gpa_points DECIMAL(4,2),
    description TEXT
);


-- Drop and recreate semester_calendar

DROP TABLE IF EXISTS semester_calendar CASCADE;


CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INTEGER,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN
);


-- ============================================
-- TASK 5.2: Database Cleanup
-- ============================================

-- university_test was a template database,
-- so it must first be changed back to a normal database.

ALTER DATABASE university_test IS_TEMPLATE = false;

DROP DATABASE IF EXISTS university_test;

DROP DATABASE IF EXISTS university_distributed;


-- Create backup database using university_main as template

CREATE DATABASE university_backup
WITH
    OWNER = postgres
    TEMPLATE = university_main;
