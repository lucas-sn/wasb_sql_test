USE memory.default;

-- Creating schema if I doesn't not exist.
CREATE SCHEMA IF NOT EXISTS SEXI;

CREATE TABLE IF NOT EXISTS SEXI.EXPENSE (
    employee_id TINYINT,
    unit_price DECIMAL(8, 2),
    quantity TINYINT
);

/*
 -- As we need to get the employee_id, we are going to do a join between the employee_name's
 receipts and the employee.first_name + employee.last_name
 */
INSERT INTO
    SEXI.EXPENSE (employee_id, unit_price, quantity)
SELECT
    emp.employee_id,
    rec.unit_price,
    rec.quantity
FROM
    (
        SELECT
            'Alex Jacobson' AS employee_name,
            6.50 as unit_price,
            14 as quantity
        UNION
        ALL
        SELECT
            'Alex Jacobson',
            11.00,
            20
        UNION
        ALL
        SELECT
            'Alex Jacobson',
            22.00,
            18
        UNION
        ALL
        SELECT
            'Alex Jacobson',
            13.00,
            75
        UNION
        ALL
        SELECT
            'Andrea Ghibaudi',
            300,
            1
        UNION
        ALL
        SELECT
            'Darren Poynton',
            40.00,
            9
        UNION
        ALL
        SELECT
            'Umberto Torrielli',
            17.50,
            4
    ) as rec
    LEFT JOIN SEXI.employee emp ON UPPER(CONCAT(emp.first_name, ' ', emp.last_name)) = upper(rec.employee_name);