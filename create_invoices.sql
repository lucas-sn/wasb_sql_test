/*
 We will create a temporary table to store all of the invoices_due data with the transformations.
 Then, we are going query the temporary table to populate the invoice and supplier table. After that, we are going to delete the temporary table.
 About the transformations:
 1. In order to generate the supplier_id, we are going to use DENSE_RANK so
 that we can ensure that we are going to have the same id for a same supplier when there is more than one record per supplier
 2. In order to get the last day of the month, we are going to use the last_day_of_month, add_date and current_date functions
 */
USE memory.default;

-- Creating schema if I doesn't not exist.
CREATE SCHEMA IF NOT EXISTS SEXI;

CREATE TABLE IF NOT EXISTS SEXI.TEMP_INVOICE_DUE AS
SELECT
    dense_rank() OVER(
        ORDER BY
            supplier_name ASC
    ) AS supplier_id,
    supplier_name,
    invoice_amount,
    last_day_of_month(date_add('month', due_date, CURRENT_DATE)) as due_date
FROM
    (
        VALUES
            ('Party Animals', 6000, 3),
            ('Catering Plus', 2000, 2),
            ('Catering Plus', 1500, 3),
            ('Dave''s Discos', 500, 1),
            ('Entertainment tonight', 6000, 3),
            ('Ice Ice Baby', 4000, 6)
    ) AS TREST (supplier_name, invoice_amount, due_date);

CREATE TABLE IF NOT EXISTS SEXI.INVOICE (
    supplier_id TINYINT,
    invoice_amount DECIMAL(8, 2),
    due_date DATE
);

-- Create the SUPPLIER table with the specified columns
CREATE TABLE IF NOT EXISTS SEXI.SUPPLIER (supplier_id TINYINT, name VARCHAR);

INSERT INTO
    SEXI.INVOICE (supplier_id, invoice_amount, due_date)
SELECT
    supplier_id,
    invoice_amount,
    due_date
FROM
    SEXI.TEMP_INVOICE_DUE;

INSERT INTO
    SEXI.SUPPLIER (supplier_id, name)
SELECT
    DISTINCT supplier_id,
    supplier_name
FROM
    SEXI.TEMP_INVOICE_DUE;

DROP TABLE SEXI.TEMP_INVOICE_DUE;