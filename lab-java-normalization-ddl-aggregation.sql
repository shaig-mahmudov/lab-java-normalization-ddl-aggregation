DROP TABLE IF EXISTS articles CASCADE;
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS flights CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS aircrafts CASCADE;

CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE articles (
    article_id SERIAL PRIMARY KEY,
    author_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    word_count INT CHECK (word_count >= 0),
    views INT DEFAULT 0 CHECK (views >= 0),
    CONSTRAINT fk_article_author FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

INSERT INTO authors (author_name) VALUES 
('Maria Charlotte'), 
('Juan Perez'), 
('Gemma Alcocer');

INSERT INTO articles (author_id, title, word_count, views) VALUES
((SELECT author_id FROM authors WHERE author_name = 'Maria Charlotte'), 'Best Paint Colors', 814, 14),
((SELECT author_id FROM authors WHERE author_name = 'Juan Perez'), 'Small Space Decorating Tips', 1146, 221),
((SELECT author_id FROM authors WHERE author_name = 'Maria Charlotte'), 'Hot Accessories', 986, 105),
((SELECT author_id FROM authors WHERE author_name = 'Maria Charlotte'), 'Mixing Textures', 765, 22),
((SELECT author_id FROM authors WHERE author_name = 'Juan Perez'), 'Kitchen Refresh', 1242, 307),
((SELECT author_id FROM authors WHERE author_name = 'Maria Charlotte'), 'Homemade Art Hacks', 1002, 193),
((SELECT author_id FROM authors WHERE author_name = 'Gemma Alcocer'), 'Refinishing Wood Floors', 1571, 7542);

CREATE TABLE aircrafts (
    aircraft_id SERIAL PRIMARY KEY,
    aircraft_model VARCHAR(100) NOT NULL UNIQUE,
    total_seats INT NOT NULL CHECK (total_seats > 0)
);

CREATE TABLE flights (
    flight_number VARCHAR(10) PRIMARY KEY, -- Alphanumeric, e.g., 'DL143'
    aircraft_id INT NOT NULL,
    flight_mileage INT NOT NULL CHECK (flight_mileage > 0),
    CONSTRAINT fk_flight_aircraft FOREIGN KEY (aircraft_id) REFERENCES aircrafts(aircraft_id)
);

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    customer_status VARCHAR(20) NOT NULL CHECK (customer_status IN ('Gold', 'Silver', 'None')),
    total_customer_mileage INT NOT NULL DEFAULT 0 CHECK (total_customer_mileage >= 0)
);

CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    flight_number VARCHAR(10) NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_booking_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_booking_flight FOREIGN KEY (flight_number) REFERENCES flights(flight_number) ON DELETE CASCADE
);

INSERT INTO aircrafts (aircraft_model, total_seats) VALUES
('Boeing 747', 400),
('Airbus A330', 236),
('Boeing 777', 264);

INSERT INTO flights (flight_number, aircraft_id, flight_mileage) VALUES
('DL143', (SELECT aircraft_id FROM aircrafts WHERE aircraft_model = 'Boeing 747'), 135),
('DL122', (SELECT aircraft_id FROM aircrafts WHERE aircraft_model = 'Airbus A330'), 4370),
('DL53',  (SELECT aircraft_id FROM aircrafts WHERE aircraft_model = 'Boeing 777'), 2078),
('DL222', (SELECT aircraft_id FROM aircrafts WHERE aircraft_model = 'Boeing 777'), 1765),
('DL37',  (SELECT aircraft_id FROM aircrafts WHERE aircraft_model = 'Boeing 747'), 531);

INSERT INTO customers (customer_name, customer_status, total_customer_mileage) VALUES
('Agustine Riviera', 'Silver', 115235),
('Alaina Sepulvida', 'None', 6008),
('Tom Jones', 'Gold', 205767),
('Sam Rio', 'None', 2653),
('Jessica James', 'Silver', 127656),
('Ana Janco', 'Silver', 136773),
('Jennifer Cortez', 'Gold', 300582),
('Christian Janco', 'Silver', 14642);

INSERT INTO bookings (customer_id, flight_number) VALUES
((SELECT customer_id FROM customers WHERE customer_name = 'Agustine Riviera'), 'DL143'),
((SELECT customer_id FROM customers WHERE customer_name = 'Agustine Riviera'), 'DL122'),
((SELECT customer_id FROM customers WHERE customer_name = 'Alaina Sepulvida'), 'DL122'),
((SELECT customer_id FROM customers WHERE customer_name = 'Agustine Riviera'), 'DL143'),
((SELECT customer_id FROM customers WHERE customer_name = 'Tom Jones'), 'DL122'),
((SELECT customer_id FROM customers WHERE customer_name = 'Tom Jones'), 'DL53'),
((SELECT customer_id FROM customers WHERE customer_name = 'Agustine Riviera'), 'DL143'),
((SELECT customer_id FROM customers WHERE customer_name = 'Sam Rio'), 'DL143'),
((SELECT customer_id FROM customers WHERE customer_name = 'Tom Jones'), 'DL222'),
((SELECT customer_id FROM customers WHERE customer_name = 'Jessica James'), 'DL143'),
((SELECT customer_id FROM customers WHERE customer_name = 'Sam Rio'), 'DL143'),
((SELECT customer_id FROM customers WHERE customer_name = 'Ana Janco'), 'DL222'),
((SELECT customer_id FROM customers WHERE customer_name = 'Jennifer Cortez'), 'DL222'),
((SELECT customer_id FROM customers WHERE customer_name = 'Jessica James'), 'DL122'),
((SELECT customer_id FROM customers WHERE customer_name = 'Sam Rio'), 'DL37'),
((SELECT customer_id FROM customers WHERE customer_name = 'Christian Janco'), 'DL222');

CREATE INDEX idx_bookings_customer_id ON bookings(customer_id);
CREATE INDEX idx_bookings_flight_number ON bookings(flight_number);
CREATE INDEX idx_flights_aircraft_id ON flights(aircraft_id);

CREATE INDEX idx_customers_status ON customers(customer_status);

SELECT COUNT(flight_number) AS total_flights FROM flights;

SELECT AVG(flight_mileage) AS avg_flight_distance FROM flights;

SELECT AVG(total_seats) AS avg_seats FROM aircrafts;

SELECT customer_status, ROUND(AVG(total_customer_mileage), 2) AS avg_customer_mileage 
FROM customers 
GROUP BY customer_status;

SELECT customer_status, MAX(total_customer_mileage) AS max_customer_mileage 
FROM customers 
GROUP BY customer_status;

SELECT COUNT(*) AS boeing_aircraft_count 
FROM aircrafts 
WHERE aircraft_model LIKE '%Boeing%';

SELECT flight_number, flight_mileage 
FROM flights 
WHERE flight_mileage BETWEEN 300 AND 2000;

SELECT c.customer_status, ROUND(AVG(f.flight_mileage), 2) AS avg_booked_distance
FROM bookings b
JOIN customers c ON b.customer_id = c.customer_id
JOIN flights f ON b.flight_number = f.flight_number
GROUP BY c.customer_status;

SELECT a.aircraft_model, COUNT(b.booking_id) AS total_bookings
FROM bookings b
JOIN customers c ON b.customer_id = c.customer_id
JOIN flights f ON b.flight_number = f.flight_number
JOIN aircrafts a ON f.aircraft_id = a.aircraft_id
WHERE c.customer_status = 'Gold'
GROUP BY a.aircraft_model
ORDER BY total_bookings DESC
LIMIT 1;