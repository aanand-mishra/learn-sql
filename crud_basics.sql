-- SQL CRUD Basics
-- Create Queries
-- Create Database
CREATE DATABASE chai_db;

-- Connect/Select Database
USE chai_db;

-- Create Table in Selected Database
CREATE TABLE
    chai_store (
        id SERIAL PRIMARY KEY,
        chai_name VARCHAR(50),
        price DECIMAL(5, 2),
        chai_type VARCHAR(50),
        is_available BOOLEAN
    );

-- Add Rows/Records into Table
INSERT INTO
    chai_store (chai_name, price, chai_type, is_available)
VALUES
    ('Masala Chai', 30, 'Spiced', TRUE),
    ('Green Chai', 25.00, 'Herbal', TRUE),
    ('Black Chai', 20.00, 'Classic', TRUE),
    ('Iced Chai', 35.00, 'Cold', FALSE),
    ('Oolang Chai', 40.00, 'Specialty', TRUE);

-- Read Queries
-- Display Entire Records From Table
SELECT
    *
FROM
    chai_store;

-- Display all chai names and prices, using column aliases like "Chai Name" and "Cost in INR"
SELECT
    chai_name AS "Chai Name",
    price AS "Cost in INR"
FROM
    chai_store;

-- Find all chai varieties that have the word "Black Chai" in there name
SELECT
    *
FROM
    chai_store
WHERE
    chai_name = 'Black Chai';

-- Find all chai varieties that have the word "Chai" in there name
SELECT
    *
FROM
    chai_store
WHERE
    chai_name LIKE '%Chai%';

-- List all chai varieties that costs less than 30
SELECT
    *
FROM
    chai_store
WHERE
    price < 30.00;

-- Show chai varieties sorted by price highest to lowest
SELECT
    *
FROM
    chai_store
ORDER BY
    price DESC;

-- Update Queries
-- "Iced Chai" Price Update to 38.00 and Available
UPDATE chai_store
SET
    price = 38.00,
    is_available = TRUE
WHERE
    chai_name = 'Iced Chai';

-- Display Updated Table
SELECT
    *
FROM
    chai_store;

-- Delete Queries
-- Delete the record for "Black Chai"
DELETE FROM chai_store
WHERE
    chai_name = 'Black Chai';

-- Display Updated Table After Deletion
SELECT
    *
FROM
    chai_store;