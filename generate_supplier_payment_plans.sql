/*
 -- This script generates a report of outstanding balances by:
 1. Calculating the number of installments and their values for each invoice.
 2. Creating a monthly calendar and calculating the month difference from the last day of the current month to the final due date.
 3. Merging installments with the monthly calendar using the installment key and month difference, then grouping by supplier and date range, summing `payment_amount`.
 4. Calculating `BALANCE_OUTSTANDING` using a window function as: SUM(Total invoice amount) - (Total payments already paid).
 */
USE memory.default;
WITH PAYMENT_DATE_RANGE AS (
    SELECT
        PAYMENT_DATE,
        ROW_NUMBER() OVER(
            ORDER BY
                PAYMENT_DATE ASC
        ) -1 AS months_diff
    FROM
        UNNEST(
            sequence(
                LAST_DAY_OF_MONTH(CURRENT_DATE),
                (
                    SELECT
                        MAX(DUE_DATE)
                    FROM
                        SEXI.INVOICE
                ),
                interval '1' month
            )
        ) AS t (PAYMENT_DATE)
),
INVOICE_INSTALLMENTS AS (
    SELECT
        sup.supplier_id AS supplier_id,
        sup.name AS supplier_name,
        date_diff(
            'month',
            LAST_DAY_OF_MONTH(CURRENT_DATE),
            inv.due_date
        ) AS installments_number,
        ROUND(
            invoice_amount / date_diff(
                'month',
                LAST_DAY_OF_MONTH(CURRENT_DATE),
                inv.due_date
            ),
            2
        ) AS PAYMENT_AMOUNT
    FROM
        SEXI.INVOICE inv
        INNER JOIN SEXI.SUPPLIER sup ON inv.supplier_id = sup.supplier_id
),
INVOICE_PAYMENTS AS (
    SELECT
        inv.supplier_id,
        inv.supplier_name,
        SUM(inv.payment_amount) AS payment_amount,
        payment_date
    FROM
        INVOICE_INSTALLMENTS inv
        INNER JOIN PAYMENT_DATE_RANGE pd ON inv.installments_number > pd.months_diff
    GROUP BY
        supplier_id,
        supplier_name,
        payment_date
)
SELECT
    supplier_id,
    supplier_name,
    payment_amount,
    SUM(payment_amount) OVER(PARTITION BY supplier_id) - SUM(payment_amount) OVER(
        PARTITION BY supplier_id
        ORDER BY
            payment_date ASC
    ) AS balance_outstanding,
    payment_date
FROM
    INVOICE_PAYMENTS;