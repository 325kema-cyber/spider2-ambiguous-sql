-- Question ID: sf_bq014
-- This file contains all SQL interpretations for this question.

-- ============================================================================
-- SQL Query 1
-- Interpretation 1:
-- ============================================================================
WITH ranked_orders AS (
    SELECT
        "order_id",
        "user_id",
        "created_at",
        ROW_NUMBER() OVER (
            PARTITION BY "user_id"
            ORDER BY "created_at", "order_id"
        ) AS rn
    FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDERS
    WHERE "status" NOT IN ('Cancelled', 'Returned')
),
first_valid_orders AS (
    SELECT
        "order_id",
        "user_id",
        "created_at"
    FROM ranked_orders
    WHERE rn = 1
),
category_counts AS (
    SELECT
        p."category",
        COUNT(DISTINCT f."user_id") AS customer_count
    FROM first_valid_orders f
    JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS oi
      ON oi."order_id" = f."order_id"
    JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS p
      ON p."id" = oi."product_id"
    GROUP BY p."category"
),
top_category AS (
    SELECT "category"
    FROM category_counts
    ORDER BY customer_count DESC
    LIMIT 1
)
SELECT
    p."category",
    SUM(oi."sale_price") AS revenue
FROM first_valid_orders f
JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS oi
  ON oi."order_id" = f."order_id"
JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS p
  ON p."id" = oi."product_id"
JOIN top_category t
  ON t."category" = p."category"
GROUP BY p."category";

-- ============================================================================
-- SQL Query 2
-- Interpretation 2:
-- ============================================================================
WITH ranked_orders AS (
    SELECT
        "order_id",
        "user_id",
        "created_at",
        ROW_NUMBER() OVER (
            PARTITION BY "user_id"
            ORDER BY "created_at", "order_id"
        ) AS rn
    FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDERS
    WHERE "status" NOT IN ('Cancelled', 'Returned')
),
first_valid_orders AS (
    SELECT
        "order_id",
        "user_id",
        "created_at"
    FROM ranked_orders
    WHERE rn = 1
),
category_counts AS (
    SELECT
        p."category",
        COUNT(DISTINCT f."user_id") AS customer_count
    FROM first_valid_orders f
    JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS oi
      ON oi."order_id" = f."order_id"
    JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS p
      ON p."id" = oi."product_id"
    GROUP BY p."category"
),
top_category AS (
    SELECT "category"
    FROM category_counts
    ORDER BY customer_count DESC
    LIMIT 1
)
SELECT
    p."category",
    SUM(oi."sale_price") AS revenue
FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS oi
JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDERS o
  ON o."order_id" = oi."order_id"
JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS p
  ON p."id" = oi."product_id"
JOIN top_category t
  ON t."category" = p."category"
WHERE o."status" NOT IN ('Cancelled', 'Returned')
GROUP BY p."category";

-- ============================================================================
-- SQL Query 3
-- Interpretation 3:
-- ============================================================================
WITH ranked_order_items AS (
    SELECT
        "order_id",
        "user_id",
        "created_at",
        ROW_NUMBER() OVER (
            PARTITION BY "user_id"
            ORDER BY "created_at", "order_id"
        ) AS rn
    FROM THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS
    WHERE "status" NOT IN ('Cancelled', 'Returned')
),
first_valid_orders AS (
    SELECT
        "order_id",
        "user_id",
        "created_at"
    FROM ranked_order_items
    WHERE rn = 1
),
category_counts AS (
    SELECT
        p."category",
        COUNT(DISTINCT f."user_id") AS customer_count
    FROM first_valid_orders f
    JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS oi
      ON oi."order_id" = f."order_id"
     AND oi."user_id" = f."user_id"
    JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS p
      ON p."id" = oi."product_id"
    WHERE oi."status" NOT IN ('Cancelled', 'Returned')
    GROUP BY p."category"
),
top_category AS (
    SELECT "category"
    FROM category_counts
    ORDER BY customer_count DESC
    LIMIT 1
)
SELECT
    p."category",
    SUM(oi."sale_price") AS revenue
FROM first_valid_orders f
JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS oi
  ON oi."order_id" = f."order_id"
 AND oi."user_id" = f."user_id"
JOIN THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS p
  ON p."id" = oi."product_id"
JOIN top_category t
  ON t."category" = p."category"
WHERE oi."status" NOT IN ('Cancelled', 'Returned')
GROUP BY p."category";
