WITH SupplierBalances AS (
    SELECT
        sup.supplier_id,
        sup.name AS supplier_name,
        inv.invoice_amount,
        LAST_DAY(inv.due_date) AS due_date
    FROM
        SEXI.SUPPLIER AS sup
        INNER JOIN SEXI.INVOICE AS inv ON sup.supplier_id = inv.supplier_id
),