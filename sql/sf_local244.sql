-- Question ID: sf_local244
-- This file contains all SQL interpretations for this question.

-- ============================================================================
-- SQL Query 1
-- Interpretation 1:
-- ============================================================================
WITH duration_stats AS (
    SELECT
        MIN("Milliseconds") AS min_ms,
        AVG("Milliseconds") AS avg_ms,
        MAX("Milliseconds") AS max_ms
    FROM MUSIC.MUSIC.TRACK
),
track_categories AS (
    SELECT
        t."TrackId",
        t."Milliseconds" / 60000.0 AS duration_minutes,
        CASE
            WHEN t."Milliseconds" < (s.min_ms + s.avg_ms) / 2 THEN 'short'
            WHEN t."Milliseconds" < (s.avg_ms + s.max_ms) / 2 THEN 'medium'
            ELSE 'long'
        END AS length_category
    FROM MUSIC.MUSIC.TRACK t
    CROSS JOIN duration_stats s
),
track_revenue AS (
    SELECT
        "TrackId",
        SUM("UnitPrice" * "Quantity") AS revenue
    FROM MUSIC.MUSIC.INVOICELINE
    GROUP BY "TrackId"
)
SELECT
    tc.length_category,
    MIN(tc.duration_minutes) AS min_time_minutes,
    MAX(tc.duration_minutes) AS max_time_minutes,
    SUM(tr.revenue) AS total_revenue
FROM track_categories tc
LEFT JOIN track_revenue tr
  ON tr."TrackId" = tc."TrackId"
GROUP BY tc.length_category
ORDER BY tc.length_category;

-- ============================================================================
-- SQL Query 2
-- Interpretation 2:
-- ============================================================================
WITH sold_tracks AS (
    SELECT DISTINCT
        t."TrackId",
        t."Milliseconds"
    FROM MUSIC.MUSIC.TRACK t
    JOIN MUSIC.MUSIC.INVOICELINE il
      ON il."TrackId" = t."TrackId"
),
duration_stats AS (
    SELECT
        MIN("Milliseconds") AS min_ms,
        AVG("Milliseconds") AS avg_ms,
        MAX("Milliseconds") AS max_ms
    FROM sold_tracks
),
track_categories AS (
    SELECT
        st."TrackId",
        st."Milliseconds" / 60000.0 AS duration_minutes,
        CASE
            WHEN st."Milliseconds" < (s.min_ms + s.avg_ms) / 2 THEN 'short'
            WHEN st."Milliseconds" < (s.avg_ms + s.max_ms) / 2 THEN 'medium'
            ELSE 'long'
        END AS length_category
    FROM sold_tracks st
    CROSS JOIN duration_stats s
),
track_revenue AS (
    SELECT
        "TrackId",
        SUM("UnitPrice" * "Quantity") AS revenue
    FROM MUSIC.MUSIC.INVOICELINE
    GROUP BY "TrackId"
)
SELECT
    tc.length_category,
    MIN(tc.duration_minutes) AS min_time_minutes,
    MAX(tc.duration_minutes) AS max_time_minutes,
    SUM(tr.revenue) AS total_revenue
FROM track_categories tc
JOIN track_revenue tr
  ON tr."TrackId" = tc."TrackId"
GROUP BY tc.length_category
ORDER BY tc.length_category;

-- ============================================================================
-- SQL Query 3
-- Interpretation 3:
-- ============================================================================
WITH duration_stats AS (
    SELECT
        MIN("Milliseconds") AS min_ms,
        AVG("Milliseconds") AS avg_ms,
        MAX("Milliseconds") AS max_ms
    FROM MUSIC.MUSIC.TRACK
),
track_categories AS (
    SELECT
        t."TrackId",
        t."UnitPrice",
        t."Milliseconds" / 60000.0 AS duration_minutes,
        CASE
            WHEN t."Milliseconds" < (s.min_ms + s.avg_ms) / 2 THEN 'short'
            WHEN t."Milliseconds" < (s.avg_ms + s.max_ms) / 2 THEN 'medium'
            ELSE 'long'
        END AS length_category
    FROM MUSIC.MUSIC.TRACK t
    CROSS JOIN duration_stats s
)
SELECT
    tc.length_category,
    MIN(tc.duration_minutes) AS min_time_minutes,
    MAX(tc.duration_minutes) AS max_time_minutes,
    SUM(tc."UnitPrice" * il."Quantity") AS total_revenue
FROM track_categories tc
LEFT JOIN MUSIC.MUSIC.INVOICELINE il
  ON il."TrackId" = tc."TrackId"
GROUP BY tc.length_category
ORDER BY tc.length_category;
