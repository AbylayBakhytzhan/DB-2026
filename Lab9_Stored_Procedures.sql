-- Laboratory Work 9: Stored Procedures and User-Defined Functions
-- Student: Abylay Bakhytzhan
-- PostgreSQL 12+

-- PART 1. DATABASE SETUP

DROP TABLE IF EXISTS rentals, bikes, members, stations CASCADE;

CREATE TABLE stations (
    station_id INT PRIMARY KEY,
    station_name VARCHAR(50) NOT NULL,
    city VARCHAR(40) NOT NULL,
    capacity INT NOT NULL
);

CREATE TABLE bikes (
    bike_id INT PRIMARY KEY,
    model VARCHAR(50) NOT NULL,
    station_id INT REFERENCES stations(station_id),
    daily_rate NUMERIC(8,2) NOT NULL
);

CREATE TABLE members (
    member_id INT PRIMARY KEY,
    full_name VARCHAR(60) NOT NULL,
    city VARCHAR(40) NOT NULL,
    joined_on DATE NOT NULL
);

CREATE TABLE rentals (
    rental_id INT PRIMARY KEY,
    member_id INT REFERENCES members(member_id),
    bike_id INT REFERENCES bikes(bike_id),
    start_date DATE NOT NULL,
    end_date DATE,
    fee NUMERIC(8,2)
);

INSERT INTO stations VALUES
(10, 'Central Park', 'Almaty', 4),
(20, 'Riverside', 'Almaty', 3),
(30, 'Expo Gate', 'Astana', 5),
(40, 'Old Town', 'Shymkent', 2),
(50, 'Depot', 'Astana', 0);

INSERT INTO bikes VALUES
(101, 'City Cruiser', 10, 4.50),
(102, 'City Cruiser', 10, 4.50),
(103, 'Mountain X', 20, 7.00),
(104, 'Mountain X', 30, 7.00),
(105, 'Road Sprint', 30, 9.25),
(106, 'Folding Mini', 40, 3.75),
(107, 'Cargo Hauler', 20, 12.00),
(108, 'Road Sprint', 10, 9.25);

INSERT INTO members VALUES
(1, 'Aisha Nurlanova', 'Almaty', DATE '2023-03-14'),
(2, 'Daniyar Serik', 'Almaty', DATE '2023-07-02'),
(3, 'Marta Kowalski', 'Astana', DATE '2024-01-20'),
(4, 'Chen Wei', 'Astana', DATE '2024-05-11'),
(5, 'Omar Haddad', 'Shymkent', DATE '2024-09-30'),
(6, 'Elena Petrova', 'Almaty', DATE '2025-02-05');

INSERT INTO rentals VALUES
(1, 1, 101, DATE '2024-04-05', DATE '2024-04-08', 13.50),
(2, 1, 103, DATE '2024-06-11', DATE '2024-06-16', 35.00),
(3, 1, 108, DATE '2025-02-02', DATE '2025-02-04', 18.50),
(4, 1, 102, DATE '2025-05-20', DATE '2025-05-27', 31.50),
(5, 2, 101, DATE '2024-05-01', DATE '2024-05-02', 4.50),
(6, 2, 107, DATE '2024-11-15', DATE '2024-11-19', 48.00),
(7, 2, 107, DATE '2025-03-08', DATE '2025-03-14', 72.00),
(8, 3, 104, DATE '2024-02-14', DATE '2024-02-18', 28.00),
(9, 3, 105, DATE '2024-08-03', DATE '2024-08-06', 27.75),
(10, 3, 104, DATE '2025-01-09', DATE '2025-01-10', 7.00),
(11, 3, 105, DATE '2025-06-01', DATE '2025-06-09', 74.00),
(12, 4, 104, DATE '2024-07-19', DATE '2024-07-21', 14.00),
(13, 4, 105, DATE '2025-04-12', DATE '2025-04-15', 27.75),
(14, 4, 103, DATE '2025-07-23', DATE '2025-07-29', 42.00),
(15, 5, 106, DATE '2024-10-05', DATE '2024-10-12', 26.25),
(16, 5, 106, DATE '2025-01-18', DATE '2025-01-20', 7.50),
(17, 5, 106, DATE '2025-08-14', DATE '2025-08-21', 26.25),
(18, 2, 102, DATE '2025-09-02', DATE '2025-09-05', 13.50),
(19, 1, 101, DATE '2025-10-10', NULL, NULL),
(20, 4, 108, DATE '2024-12-28', DATE '2025-01-03', 55.50),
(21, 3, 103, DATE '2025-02-26', DATE '2025-03-02', 28.00),
(22, 5, 104, DATE '2025-05-05', DATE '2025-05-08', 21.00);

SELECT
    (SELECT COUNT(*) FROM stations) AS stations,
    (SELECT COUNT(*) FROM bikes) AS bikes,
    (SELECT COUNT(*) FROM members) AS members,
    (SELECT COUNT(*) FROM rentals) AS rentals;


-- PART 2. YOUR FIRST FUNCTION

-- Exercise 2.1
CREATE OR REPLACE FUNCTION rental_days(p_rental_id INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_days INT;
BEGIN
    SELECT end_date - start_date
    INTO v_days
    FROM rentals
    WHERE rental_id = p_rental_id;

    RETURN v_days;
END;
$$;

SELECT rental_days(2);
SELECT rental_days(11);
SELECT rental_days(19);
SELECT rental_days(999);

-- Rental 19 returns NULL because end_date is NULL; rental 999 returns NULL
-- because no matching row exists.

-- Exercise 2.2
CREATE OR REPLACE FUNCTION member_rental_count(p_member_id INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*)::INT
    INTO v_count
    FROM rentals
    WHERE member_id = p_member_id;

    RETURN v_count;
END;
$$;

SELECT member_rental_count(1);
SELECT member_rental_count(5);
SELECT member_rental_count(6);
SELECT member_rental_count(99);

-- COUNT(*) returns 0 for an empty set, not NULL.

-- Exercise 2.3
CREATE OR REPLACE FUNCTION station_city(p_station_id INT)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
    v_city VARCHAR;
BEGIN
    SELECT city
    INTO v_city
    FROM stations
    WHERE station_id = p_station_id;

    RETURN v_city;
END;
$$;

SELECT station_city(30);
SELECT station_city(77);

-- Exercise 2.4
SELECT
    r.rental_id,
    r.member_id,
    rental_days(r.rental_id) AS duration_days
FROM rentals r
WHERE rental_days(r.rental_id) > 4
ORDER BY duration_days DESC;


-- PART 3. PARAMETER MODES

-- Exercise 3.1
CREATE OR REPLACE FUNCTION fee_with_discount(p_fee NUMERIC, p_percent NUMERIC)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN ROUND(p_fee * (1 - p_percent / 100), 2);
END;
$$;

SELECT fee_with_discount(74.00, 15);

-- Exercise 3.2
CREATE OR REPLACE FUNCTION member_stats(
    p_member_id INT,
    OUT rental_cnt INT,
    OUT total_fee NUMERIC,
    OUT last_start DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT
        COUNT(*)::INT,
        COALESCE(SUM(r.fee), 0),
        MAX(r.start_date)
    INTO rental_cnt, total_fee, last_start
    FROM rentals r
    WHERE r.member_id = p_member_id;
END;
$$;

SELECT member_stats(3);
SELECT * FROM member_stats(3);
SELECT * FROM member_stats(6);

-- SELECT function_call returns one composite value; SELECT * FROM expands its columns.
-- Member 6 returns 0 rentals, 0 total fees and NULL for last_start.

-- Exercise 3.3
CREATE OR REPLACE FUNCTION apply_late_fee(INOUT p_fee NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
    p_fee := p_fee + 5.00;
END;
$$;

SELECT apply_late_fee(fee)
FROM rentals
WHERE rental_id = 1;

-- INOUT returns the modified parameter as the function result.

-- Exercise 3.4
CREATE OR REPLACE FUNCTION fee_summary(
    VARIADIC p_fees NUMERIC[],
    OUT total NUMERIC,
    OUT average NUMERIC,
    OUT largest NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT
        COALESCE(SUM(p_fees[g.i]), 0),
        ROUND(AVG(p_fees[g.i]), 2),
        MAX(p_fees[g.i])
    INTO total, average, largest
    FROM generate_subscripts(p_fees, 1) AS g(i);
END;
$$;

SELECT * FROM fee_summary(13.50, 35.00, 18.50, 31.50);
SELECT * FROM fee_summary();

-- With no arguments total is 0 and average/largest are NULL.
-- VARIADIC must be last because it collects all remaining arguments into an array.

-- Exercise 3.5
-- (a) IN: supplies the row id for lookup.
-- (b) INOUT: accepts a value and returns its modified value.
-- (c) VARIADIC: accepts a variable-length list of station ids.
-- (d) OUT: returns multiple statistics from one table query.


-- PART 4. DEFAULT VALUES AND FUNCTION OVERLOADING

-- Exercise 4.1
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO v_total
    FROM rentals
    WHERE member_id = p_member_id;

    RETURN v_total;
END;
$$;

SELECT total_fees(1);
SELECT total_fees(6);

-- Exercise 4.2
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT, p_from_date DATE)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO v_total
    FROM rentals
    WHERE member_id = p_member_id
      AND start_date >= p_from_date;

    RETURN v_total;
END;
$$;

SELECT total_fees(1, DATE '2024-01-01');
SELECT total_fees(1, DATE '2025-01-01');

-- Exercise 4.3
CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT,
    p_from_date DATE DEFAULT DATE '2025-01-01'
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO v_total
    FROM rentals
    WHERE member_id = p_member_id
      AND start_date >= p_from_date;

    RETURN v_total;
END;
$$;

DO $$
BEGIN
    BEGIN
        EXECUTE 'SELECT total_fees(1)';
    EXCEPTION
        WHEN ambiguous_function THEN
            RAISE NOTICE 'Ambiguous call: %', SQLERRM;
    END;
END;
$$;

-- The one-argument call can match both overloads because the second version
-- supplies a default value for its date parameter.

-- Exercise 4.4
DROP FUNCTION total_fees(INT);
SELECT total_fees(1);

-- The two-argument version handles the call using its default date.

-- Exercise 4.5
CREATE OR REPLACE FUNCTION total_fees(p_member_name VARCHAR)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(r.fee), 0)
    INTO v_total
    FROM members m
    LEFT JOIN rentals r ON r.member_id = m.member_id
    WHERE m.full_name = p_member_name;

    RETURN v_total;
END;
$$;

SELECT total_fees('Aisha Nurlanova'::VARCHAR);
SELECT total_fees(1);

-- The VARCHAR call selects the name overload; the integer call selects
-- the remaining INT, DATE-default overload.


-- PART 5. FUNCTIONS THAT RETURN A TABLE

-- Exercise 5.1
CREATE OR REPLACE FUNCTION find_bikes(p_pattern VARCHAR)
RETURNS TABLE (
    found_id INT,
    found_model VARCHAR,
    found_rate NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model::VARCHAR, b.daily_rate::NUMERIC
    FROM bikes b
    WHERE b.model ILIKE p_pattern
    ORDER BY b.bike_id;
END;
$$;

SELECT * FROM find_bikes('%road%');
SELECT * FROM find_bikes('%Mini');
SELECT find_bikes('%road%');

-- FROM expands the returned rows and columns; without FROM each row is
-- returned as one composite value in a single result column.

-- Exercise 5.2
CREATE OR REPLACE FUNCTION member_history(p_member_id INT)
RETURNS TABLE (
    rental_id INT,
    bike_model VARCHAR,
    station_name VARCHAR,
    duration_days INT,
    rental_fee NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.rental_id,
        b.model::VARCHAR,
        s.station_name::VARCHAR,
        CASE
            WHEN r.end_date IS NULL THEN NULL::INT
            ELSE r.end_date - r.start_date
        END,
        r.fee::NUMERIC
    FROM rentals r
    JOIN bikes b ON b.bike_id = r.bike_id
    LEFT JOIN stations s ON s.station_id = b.station_id
    WHERE r.member_id = p_member_id
    ORDER BY r.start_date;
END;
$$;

SELECT * FROM member_history(3);

-- Exercise 5.3
CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (bike_id INT, model VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT bike_id, model
    FROM bikes
    WHERE station_id = p_station_id;
END;
$$;

DO $$
BEGIN
    BEGIN
        EXECUTE 'SELECT * FROM bike_list(10)';
    EXCEPTION
        WHEN ambiguous_column THEN
            RAISE NOTICE 'Ambiguous column: %', SQLERRM;
    END;
END;
$$;

-- First fix: rename the output columns.
DROP FUNCTION bike_list(INT);

CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (found_bike_id INT, found_model VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model::VARCHAR
    FROM bikes b
    WHERE b.station_id = p_station_id;
END;
$$;

SELECT * FROM bike_list(10);

-- Second fix: keep the output names and qualify source columns.
DROP FUNCTION bike_list(INT);

CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (bike_id INT, model VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model::VARCHAR
    FROM bikes b
    WHERE b.station_id = p_station_id;
END;
$$;

SELECT * FROM bike_list(10);

-- Exercise 5.4
CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
RETURNS TABLE (
    s_name VARCHAR,
    s_bikes INT,
    s_free INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.station_name::VARCHAR,
        COUNT(b.bike_id)::INT,
        (s.capacity - COUNT(b.bike_id))::INT
    FROM stations s
    LEFT JOIN bikes b ON b.station_id = s.station_id
    WHERE s.city = p_city
    GROUP BY s.station_id, s.station_name, s.capacity
    ORDER BY s.station_id;
END;
$$;

SELECT * FROM station_board('Almaty');
SELECT * FROM station_board('Astana');

-- COUNT returns BIGINT; assigning it to an INT output requires an explicit cast.


-- PART 6. BLOCK STRUCTURE, DO BLOCKS AND SUBBLOCKS

-- Exercise 6.1
DO $$
<<rental_report>>
DECLARE
    total_rentals INT := 0;
BEGIN
    SELECT COUNT(*)::INT
    INTO total_rentals
    FROM rentals;

    RAISE NOTICE 'The rentals table holds % rows.', total_rentals;
END rental_report;
$$;

-- A mismatched block label causes a syntax error.

-- Exercise 6.2
DO $$
<<rental_report>>
DECLARE
    fee_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO fee_total
    FROM rentals;

    RAISE NOTICE 'Outer total before subblock: %', fee_total;

    DECLARE
        fee_total NUMERIC;
    BEGIN
        SELECT COALESCE(SUM(fee), 0)
        INTO fee_total
        FROM rentals
        WHERE start_date >= DATE '2025-01-01';

        RAISE NOTICE 'Subblock total: %', fee_total;
        RAISE NOTICE 'Outer total from subblock: %', rental_report.fee_total;
    END;

    RAISE NOTICE 'Outer total after subblock: %', fee_total;
END rental_report;
$$;

-- Exercise 6.3
DO $$
DECLARE
    shared_value INT := 100;
BEGIN
    DECLARE
        local_value INT := 10;
    BEGIN
        RAISE NOTICE 'First subblock local value: %', local_value;
        RAISE NOTICE 'Shared value: %', shared_value;
    END;

    DECLARE
        local_value INT := 20;
    BEGIN
        RAISE NOTICE 'Second subblock local value: %', local_value;
        RAISE NOTICE 'Shared value: %', shared_value;
    END;
END;
$$;

-- A variable declared in one subblock is not visible in another.
-- Declaring shared_value in the outer block makes it visible in both.

-- Exercise 6.4
CREATE OR REPLACE FUNCTION fee_split(
    p_from_date DATE,
    OUT before_total NUMERIC,
    OUT after_total NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT
        COALESCE(SUM(fee) FILTER (WHERE start_date < p_from_date), 0),
        COALESCE(SUM(fee) FILTER (WHERE start_date >= p_from_date), 0)
    INTO before_total, after_total
    FROM rentals;
END;
$$;

SELECT * FROM fee_split(DATE '2025-01-01');

SELECT
    before_total,
    after_total,
    before_total + after_total AS combined_total,
    (SELECT COALESCE(SUM(fee), 0) FROM rentals) AS table_total
FROM fee_split(DATE '2025-01-01');


-- PART 7. PRACTICAL SCENARIOS

-- Exercise 7.1
CREATE OR REPLACE FUNCTION station_load(
    p_station_id INT,
    OUT bikes_parked INT,
    OUT capacity_pct NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_capacity INT;
BEGIN
    SELECT COUNT(b.bike_id)::INT, s.capacity
    INTO bikes_parked, v_capacity
    FROM stations s
    LEFT JOIN bikes b ON b.station_id = s.station_id
    WHERE s.station_id = p_station_id
    GROUP BY s.capacity;

    capacity_pct := CASE
        WHEN v_capacity = 0 THEN NULL
        ELSE ROUND(bikes_parked * 100.0 / v_capacity, 1)
    END;
END;
$$;

SELECT s.station_id, s.station_name, l.*
FROM stations s
CROSS JOIN LATERAL station_load(s.station_id) l
ORDER BY s.station_id;

-- A zero-capacity station has no meaningful occupancy percentage, so it returns NULL.

-- Exercise 7.2
CREATE OR REPLACE FUNCTION top_members(p_limit INT DEFAULT 3)
RETURNS TABLE (
    member_name VARCHAR,
    rental_count BIGINT,
    total_spent NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.full_name::VARCHAR,
        COUNT(r.rental_id),
        COALESCE(SUM(r.fee), 0)::NUMERIC
    FROM members m
    LEFT JOIN rentals r ON r.member_id = m.member_id
    GROUP BY m.member_id, m.full_name
    ORDER BY COALESCE(SUM(r.fee), 0) DESC,
             COUNT(r.rental_id) DESC,
             m.full_name
    LIMIT p_limit;
END;
$$;

SELECT * FROM top_members();
SELECT * FROM top_members(6);

-- Members are ranked by total amount spent first, not by rental count.

-- Exercise 7.3
CREATE OR REPLACE FUNCTION rental_invoice(p_rental_id INT)
RETURNS TABLE (
    member_name VARCHAR,
    bike_model VARCHAR,
    duration_days INT,
    amount_owed NUMERIC,
    rental_status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.full_name::VARCHAR,
        b.model::VARCHAR,
        (COALESCE(r.end_date, CURRENT_DATE) - r.start_date)::INT,
        ROUND(
            (COALESCE(r.end_date, CURRENT_DATE) - r.start_date) * b.daily_rate,
            2
        )::NUMERIC,
        CASE
            WHEN r.end_date IS NULL THEN 'OPEN'::VARCHAR
            ELSE 'CLOSED'::VARCHAR
        END
    FROM rentals r
    JOIN members m ON m.member_id = r.member_id
    JOIN bikes b ON b.bike_id = r.bike_id
    WHERE r.rental_id = p_rental_id;
END;
$$;

SELECT * FROM rental_invoice(11);
SELECT * FROM rental_invoice(19);

-- Rental 11's calculated amount equals its stored fee. Rental 19 changes with
-- CURRENT_DATE, so this function cannot be IMMUTABLE.

-- Exercise 7.4
CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR)
RETURNS TABLE (
    member_count BIGINT,
    rental_count BIGINT,
    total_revenue NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT m.member_id),
        COUNT(r.rental_id),
        COALESCE(SUM(r.fee), 0)::NUMERIC
    FROM members m
    LEFT JOIN rentals r ON r.member_id = m.member_id
    WHERE m.city = p_city;
END;
$$;

CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR, p_from_date DATE)
RETURNS TABLE (
    member_count BIGINT,
    rental_count BIGINT,
    total_revenue NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT m.member_id),
        COUNT(r.rental_id),
        COALESCE(SUM(r.fee), 0)::NUMERIC
    FROM members m
    LEFT JOIN rentals r
        ON r.member_id = m.member_id
       AND r.start_date >= p_from_date
    WHERE m.city = p_city;
END;
$$;

SELECT * FROM city_report('Almaty');
SELECT * FROM city_report('Almaty', DATE '2025-01-01');

-- The date condition belongs in ON. Putting it in WHERE removes members
-- without qualifying rentals from the result.


-- LAB QUESTIONS

-- 1. A function name is its identifier; its signature includes the argument types.
--    DROP FUNCTION needs the signature because overloaded functions share a name.
-- 2. Dollar quoting marks a function body without escaping every single quote.
--    Example: BEGIN RAISE NOTICE 'Rental is open'; END;
-- 3. OUT parameters suit a fixed set of scalar results. RETURNS TABLE is better
--    when returning multiple rows with named columns.
-- 4. VARIADIC must be last so the remaining arguments can be collected into
--    its array; otherwise PostgreSQL cannot determine where that list ends.
-- 5. RETURN ends a scalar function with a value; RETURN QUERY appends rows
--    from a query to a set-returning function's result.
-- 6. A DEFAULT can make a shorter call match multiple overloads. Avoid this
--    by checking signatures and call resolution before deploying an overload.
-- 7. A subblock variable is inaccessible after the subblock ends. A shadowed
--    outer variable can be referenced using the outer block label.
-- 8. Advantage: business rules are shared and run close to the data.
--    Disadvantage: database-specific logic is harder to version and test.
-- 9. PL/pgSQL is trusted, so ordinary users with privileges can create functions.
--    PL/Python is untrusted and requires superuser privileges.
-- 10. CREATE OR REPLACE with different argument types creates a new overload;
--     it does not replace the old signature and may cause ambiguous calls.


-- OPTIONAL CHALLENGES

-- Challenge 1
CREATE OR REPLACE FUNCTION busiest_station(
    p_from_date DATE DEFAULT DATE '2024-01-01'
)
RETURNS TABLE (
    station_id INT,
    station_name VARCHAR,
    rented_days BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.station_id,
        s.station_name::VARCHAR,
        COALESCE(SUM(COALESCE(r.end_date, CURRENT_DATE) - r.start_date), 0)::BIGINT
    FROM stations s
    JOIN bikes b ON b.station_id = s.station_id
    LEFT JOIN rentals r
        ON r.bike_id = b.bike_id
       AND r.start_date >= p_from_date
    GROUP BY s.station_id, s.station_name
    ORDER BY COALESCE(SUM(COALESCE(r.end_date, CURRENT_DATE) - r.start_date), 0) DESC,
             s.station_id
    LIMIT 1;
END;
$$;

SELECT * FROM busiest_station();
SELECT * FROM busiest_station(DATE '2025-01-01');

-- Challenge 2
DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT
            m.full_name,
            COUNT(r.rental_id) AS rental_count,
            COALESCE(SUM(r.fee), 0) AS total_spent
        FROM members m
        LEFT JOIN rentals r ON r.member_id = m.member_id
        GROUP BY m.member_id, m.full_name
        ORDER BY m.member_id
    LOOP
        RAISE NOTICE '%: % rentals, total fees %',
            rec.full_name, rec.rental_count, rec.total_spent;
    END LOOP;
END;
$$;

-- A single SELECT is preferable for returning report rows to an application.

-- Challenge 3
CREATE OR REPLACE FUNCTION rental_days(p_rental_id INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_days INT;
BEGIN
    SELECT end_date - start_date
    INTO v_days
    FROM rentals
    WHERE rental_id = p_rental_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Rental id % does not exist', p_rental_id;
    END IF;

    RETURN v_days;
END;
$$;

-- Raising an exception is useful for direct lookups, but can stop a query
-- processing many rows if one referenced rental id is missing.

-- Challenge 4
CREATE OR REPLACE FUNCTION fee_report(p_member_id INT)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT COALESCE(SUM(fee), 0)
    FROM rentals
    WHERE member_id = p_member_id;
$$;

CREATE OR REPLACE FUNCTION fee_report(p_member_name VARCHAR)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT COALESCE(SUM(r.fee), 0)
    FROM members m
    LEFT JOIN rentals r ON r.member_id = m.member_id
    WHERE m.full_name = p_member_name;
$$;

CREATE OR REPLACE FUNCTION fee_report(p_member_name TEXT)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT COALESCE(SUM(r.fee), 0)
    FROM members m
    LEFT JOIN rentals r ON r.member_id = m.member_id
    WHERE m.full_name = p_member_name;
$$;

SELECT fee_report(1);
SELECT fee_report('Aisha Nurlanova'::VARCHAR);
SELECT fee_report('Aisha Nurlanova'::TEXT);

-- Challenge 5
CREATE OR REPLACE PROCEDURE close_rental(
    p_rental_id INT,
    p_end_date DATE DEFAULT CURRENT_DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_date DATE;
    v_daily_rate NUMERIC(8,2);
BEGIN
    SELECT r.start_date, b.daily_rate
    INTO v_start_date, v_daily_rate
    FROM rentals r
    JOIN bikes b ON b.bike_id = r.bike_id
    WHERE r.rental_id = p_rental_id
      AND r.end_date IS NULL;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Open rental id % does not exist', p_rental_id;
    END IF;

    IF p_end_date < v_start_date THEN
        RAISE EXCEPTION 'End date cannot be before start date';
    END IF;

    UPDATE rentals
    SET end_date = p_end_date,
        fee = ROUND((p_end_date - v_start_date) * v_daily_rate, 2)
    WHERE rental_id = p_rental_id;
END;
$$;

-- Example call; uncomment to close rental 19 and update the sample data.
-- CALL close_rental(19, CURRENT_DATE);
-- Procedures are invoked with CALL and can perform transaction control
-- in contexts where functions cannot.
