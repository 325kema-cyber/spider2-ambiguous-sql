-- Question ID: sf_bq022
-- This file contains all SQL interpretations for this question.

-- ============================================================================
-- SQL Query 1
-- Interpretation 1:
-- ============================================================================
WITH filtered_trips AS (
    SELECT
        "trip_seconds",
        "fare",
        NTILE(6) OVER (ORDER BY "trip_seconds") AS duration_quantile
    FROM CHICAGO.CHICAGO_TAXI_TRIPS.TAXI_TRIPS
    WHERE "trip_seconds" BETWEEN 0 AND 3600
)
SELECT
    duration_quantile,
    ROUND(MIN("trip_seconds" / 60.0)) AS min_duration_minutes,
    ROUND(MAX("trip_seconds" / 60.0)) AS max_duration_minutes,
    COUNT(*) AS total_trips,
    ROUND(AVG("fare"), 2) AS average_fare
FROM filtered_trips
GROUP BY duration_quantile
ORDER BY duration_quantile;

-- ============================================================================
-- SQL Query 2
-- Interpretation 2:
-- ============================================================================
WITH rounded_trips AS (
    SELECT
        ROUND("trip_seconds" / 60.0) AS duration_minutes,
        "fare"
    FROM CHICAGO.CHICAGO_TAXI_TRIPS.TAXI_TRIPS
),
quantiled_trips AS (
    SELECT
        duration_minutes,
        "fare",
        NTILE(6) OVER (ORDER BY duration_minutes) AS duration_quantile
    FROM rounded_trips
    WHERE duration_minutes BETWEEN 0 AND 60
)
SELECT
    duration_quantile,
    MIN(duration_minutes) AS min_duration_minutes,
    MAX(duration_minutes) AS max_duration_minutes,
    COUNT(*) AS total_trips,
    ROUND(AVG("fare"), 2) AS average_fare
FROM quantiled_trips
GROUP BY duration_quantile
ORDER BY duration_quantile;

-- ============================================================================
-- SQL Query 3
-- Interpretation 3:
-- ============================================================================
WITH filtered_trips AS (
    SELECT
        "trip_seconds",
        "fare"
    FROM CHICAGO.CHICAGO_TAXI_TRIPS.TAXI_TRIPS
    WHERE "trip_seconds" BETWEEN 0 AND 3600
),
cutoffs AS (
    SELECT
        PERCENTILE_CONT(0.166667) WITHIN GROUP (ORDER BY "trip_seconds") AS p1,
        PERCENTILE_CONT(0.333333) WITHIN GROUP (ORDER BY "trip_seconds") AS p2,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "trip_seconds") AS p3,
        PERCENTILE_CONT(0.666667) WITHIN GROUP (ORDER BY "trip_seconds") AS p4,
        PERCENTILE_CONT(0.833333) WITHIN GROUP (ORDER BY "trip_seconds") AS p5
    FROM filtered_trips
),
grouped_trips AS (
    SELECT
        f."trip_seconds",
        f."fare",
        CASE
            WHEN f."trip_seconds" <= c.p1 THEN 1
            WHEN f."trip_seconds" <= c.p2 THEN 2
            WHEN f."trip_seconds" <= c.p3 THEN 3
            WHEN f."trip_seconds" <= c.p4 THEN 4
            WHEN f."trip_seconds" <= c.p5 THEN 5
            ELSE 6
        END AS duration_quantile
    FROM filtered_trips f
    CROSS JOIN cutoffs c
)
SELECT
    duration_quantile,
    ROUND(MIN("trip_seconds" / 60.0)) AS min_duration_minutes,
    ROUND(MAX("trip_seconds" / 60.0)) AS max_duration_minutes,
    COUNT(*) AS total_trips,
    ROUND(AVG("fare"), 2) AS average_fare
FROM grouped_trips
GROUP BY duration_quantile
ORDER BY duration_quantile;
