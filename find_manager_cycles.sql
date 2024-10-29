/* In order to create the relation, we are going to use the array_join together with the array_agg.
 aarra_join will create the array based on employee_id.
 For more information check: 
 - https://trino.io/docs/current/functions/array.html#array_join
 */
USE memory.default;

SELECT
    emp.employee_id AS g_employee_id,
    array_join(
        array_agg(CAST(mng.employee_id AS VARCHAR)),
        ','
    ) AS employee_approver
FROM
    sexi.EMPLOYEE emp
    LEFT JOIN sexi.EMPLOYEE mng ON emp.manager_id = mng.employee_id
group by
    emp.employee_id;