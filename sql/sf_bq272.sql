-- Question ID: sf_bq272
-- This file contains all SQL interpretations for this question.

-- ============================================================================
-- SQL Query 1
-- Interpretation 1:
-- ============================================================================
WITH monthly_product_profit AS (
    SELECT
        TO_CHAR(DATE_TRUNC('MONTH', TO_TIMESTAMP_NTZ(oi."created_at" / 1000000)), 'YYYY-MM') AS month,
        p."name" AS product_name,
        SUM(oi."sale_price") - SUM(p."cost") AS profit
    FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS oi
    JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS p
      ON oi."product_id" = p."id"
    WHERE oi."status" NOT IN ('Cancelled', 'Returned')
      AND TO_TIMESTAMP_NTZ(oi."created_at" / 1000000) >= '2019-01-01'
      AND TO_TIMESTAMP_NTZ(oi."created_at" / 1000000) < '2022-09-01'
    GROUP BY
        TO_CHAR(DATE_TRUNC('MONTH', TO_TIMESTAMP_NTZ(oi."created_at" / 1000000)), 'YYYY-MM'),
        p."name"
),
ranked_products AS (
    SELECT
        month,
        product_name,
        profit,
        ROW_NUMBER() OVER (
            PARTITION BY month
            ORDER BY profit DESC, product_name
        ) AS rank
    FROM monthly_product_profit
)
SELECT
    month,
    product_name,
    profit
FROM ranked_products
WHERE rank <= 3
ORDER BY month, rank;

-- ============================================================================
-- SQL Query 2
-- Interpretation 2:
-- ============================================================================
WITH monthly_product_profit AS (
    SELECT
        DATE_TRUNC('MONTH', TO_TIMESTAMP_NTZ(oi."created_at" / 1000000)) AS month,
        p."name" AS product_name,
        SUM(oi."sale_price") - SUM(p."cost") AS profit
    FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS oi
    JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS p
      ON oi."product_id" = p."id"
    WHERE oi."status" NOT IN ('Cancelled', 'Returned')
      AND TO_TIMESTAMP_NTZ(oi."created_at" / 1000000) >= '2019-01-01'
      AND TO_TIMESTAMP_NTZ(oi."created_at" / 1000000) < '2022-09-01'
    GROUP BY
        DATE_TRUNC('MONTH', TO_TIMESTAMP_NTZ(oi."created_at" / 1000000)),
        p."name"
),
ranked_products AS (
    SELECT
        month,
        product_name,
        profit,
        ROW_NUMBER() OVER (
            PARTITION BY month
            ORDER BY profit DESC, product_name
        ) AS rank
    FROM monthly_product_profit
)
SELECT
    month AS MONTH,
    product_name AS PRODUCT_NAME,
    profit AS PROFIT,
    rank AS RANK
FROM ranked_products
WHERE rank <= 3
ORDER BY month, rank;

-- ============================================================================
-- SQL Query 3
-- Interpretation 3:
-- ============================================================================
WITH monthly_product_profit AS (
    SELECT
        TO_CHAR(DATE_TRUNC('MONTH', TO_TIMESTAMP_NTZ(oi."created_at" / 1000000)), 'YYYY-MM') AS year_month,
        p."id" AS product_id,
        p."name" AS product_name,
        SUM(oi."sale_price") - SUM(p."cost") AS total_profit
    FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS oi
    JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS p
      ON oi."product_id" = p."id"
    WHERE oi."status" NOT IN ('Cancelled', 'Returned')
      AND TO_TIMESTAMP_NTZ(oi."created_at" / 1000000) >= '2019-01-01'
      AND TO_TIMESTAMP_NTZ(oi."created_at" / 1000000) < '2022-09-01'
    GROUP BY
        TO_CHAR(DATE_TRUNC('MONTH', TO_TIMESTAMP_NTZ(oi."created_at" / 1000000)), 'YYYY-MM'),
        p."id",
        p."name"
),
ranked_products AS (
    SELECT
        year_month,
        product_id,
        product_name,
        total_profit,
        ROW_NUMBER() OVER (
            PARTITION BY year_month
            ORDER BY total_profit DESC, product_id
        ) AS rank
    FROM monthly_product_profit
)
SELECT
    year_month AS YEAR_MONTH,
    product_id AS PRODUCT_ID,
    product_name AS PRODUCT_NAME,
    total_profit AS TOTAL_PROFIT,
    rank AS RANK
FROM ranked_products
WHERE rank <= 3
ORDER BY year_month, rank;

-- ============================================================================
-- SQL Query 4
-- Interpretation 4:
-- ============================================================================
WITH monthly_product_profit AS (
    SELECT
        DATE_TRUNC('MONTH', TO_TIMESTAMP_NTZ(oi."created_at" / 1000000)) AS month,
        p."id" AS product_id,
        p."name" AS product_name,
        SUM(oi."sale_price") - SUM(p."cost") AS profit
    FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS oi
    JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS p
      ON oi."product_id" = p."id"
    WHERE oi."status" NOT IN ('Cancelled', 'Returned')
      AND TO_TIMESTAMP_NTZ(oi."created_at" / 1000000) >= '2019-01-01'
      AND TO_TIMESTAMP_NTZ(oi."created_at" / 1000000) < '2022-09-01'
    GROUP BY
        DATE_TRUNC('MONTH', TO_TIMESTAMP_NTZ(oi."created_at" / 1000000)),
        p."id",
        p."name"
),
ranked_products AS (
    SELECT
        month,
        product_id,
        product_name,
        profit,
        ROW_NUMBER() OVER (
            PARTITION BY month
            ORDER BY profit DESC, product_id
        ) AS rank
    FROM monthly_product_profit
)
SELECT
    month,
    product_name,
    profit
FROM ranked_products
WHERE rank <= 3
ORDER BY month, rank;
