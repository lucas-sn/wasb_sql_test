-- Where are going to use HAVING to filter the aggregation based on employee and manager data.
USE memory.default;

SELECT
    emp.employee_id,
    emp.employee_name,
    emp.manager_id,
    emp.manager_name,
    SUM(exp.unit_price * exp.quantity) AS total_expensed_amount
FROM
    (
        SELECT
            emp.employee_id,
            CONCAT(emp.first_name, ' ', emp.last_name) AS employee_name,
            CONCAT(mng.first_name, ' ', mng.last_name) AS manager_name,
            mng.employee_id AS manager_id
        FROM
            SEXI.EMPLOYEE emp
            LEFT JOIN SEXI.EMPLOYEE mng ON emp.manager_id = mng.employee_id
    ) as emp
    INNER JOIN SEXI.EXPENSE exp ON emp.employee_id = exp.employee_id
GROUP BY
    emp.employee_name,
    emp.manager_name,
    emp.manager_id,
    emp.employee_id
HAVING
    SUM(exp.unit_price * exp.quantity) > 1000
ORDER BY
    total_expensed_amount DESC;