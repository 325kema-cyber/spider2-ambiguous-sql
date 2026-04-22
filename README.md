# Spider 2.0 Snow Ambiguous Questions SQL Submission

This repository contains five selected ambiguous questions from the Spider 2.0 Snow dataset. For each question, I provide multiple SQL interpretations that can reproduce different execution results, explain why the original question is ambiguous, and describe how the queries differ.


## Selected Question IDs

- [sf_bq014](#sf_bq014)
- [sf_bq022](#sf_bq022)
- [sf_local244](#sf_local244)
- [sf_bq007](#sf_bq007)
- [sf_bq272](#sf_bq272)


## sf_bq014


### Question
Can you help me figure out the revenue for the product category that has the highest number of customers making a purchase in their first non-cancelled and non-returned order?

### Why ambiguous
The question has two main ambiguities. First, “first non-cancelled and non-returned order” can be defined using the order-level status in `ORDERS`, or using the item-level status in `ORDER_ITEMS`. These can lead to different first valid purchases if an order and its items do not have the same status.

Second, after the top category is identified, “the revenue for the product category” is not fully specified. It could mean revenue from only the first valid orders used to choose the category, or total revenue from that category across all valid orders.

### Relevant schema
The relevant tables are `THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDERS`, `THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS`, and `THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS`.

`ORDERS` provides order-level fields: `order_id`, `user_id`, `created_at`, and `status`.

`ORDER_ITEMS` provides item-level purchase fields: `order_id`, `user_id`, `product_id`, `created_at`, `status`, and `sale_price`.

`PRODUCTS` provides product category information through `id` and `category`.



#### Interpretation 1
Use order-level status to define each customer’s first valid order, and calculate revenue only from those first valid orders.

#### SQL Query 1
```sql
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
```



#### Interpretation 2
Use order-level status to define the first valid order and choose the top category, but calculate revenue from that category across all valid orders.

#### SQL Query 2
```sql
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
```



#### Interpretation 3
Use item-level status to define each customer’s first valid purchase, and calculate revenue only from valid items in those first purchase orders.

#### SQL Query 3
```sql
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
```



### Differences
Query 1 defines a customer’s first valid order using the status of the whole order in `ORDERS`. A customer’s first valid order is the earliest order whose order status is not `Cancelled` or `Returned`. It then finds which product category appears in the first valid orders of the most distinct customers, and sums revenue only from those first valid orders in that selected category.

Query 2 uses the same order-level definition as Query 1 to identify each customer’s first valid order and to choose the winning product category. The difference is the revenue scope: after the category is selected, Query 2 sums revenue from all non-cancelled and non-returned orders in that category, not just from customers’ first valid orders. Because it includes later orders too, the revenue can be larger than in Query 1 even if the winning category is the same.

Query 3 changes the validity rule. Instead of judging whether a purchase is valid by the whole order’s status, it uses item-level status from `ORDER_ITEMS`. That means a customer’s first valid purchase is based on the earliest non-cancelled and non-returned item, not necessarily the earliest valid order in `ORDERS`. This can change which first purchase is selected for each customer, which category has the most first-purchase customers, and the final revenue total.

### Execution Results

#### Query 1 Result
Full CSV: [`results_csv/sf_bq014/query_1.csv`](results_csv/sf_bq014/query_1.csv)

| category | REVENUE |
| --- | --- |
| Intimates | 237128.470314264 |

#### Query 2 Result
Full CSV: [`results_csv/sf_bq014/query_2.csv`](results_csv/sf_bq014/query_2.csv)

| category | REVENUE |
| --- | --- |
| Intimates | 332464.960487843 |

#### Query 3 Result
Full CSV: [`results_csv/sf_bq014/query_3.csv`](results_csv/sf_bq014/query_3.csv)

| category | REVENUE |
| --- | --- |
| Intimates | 236704.410313845 |


## sf_bq022


### Question
Calculate the minimum and maximum trip duration in minutes (rounded to the nearest whole number), total number of trips, and average fare for each of six equal quantile groups based on trip duration, considering only trips between 0 and 60 minutes.

### Why ambiguous
Trip duration is stored as seconds, but the requested output is in rounded minutes. The question does not specify whether quantile groups should be created before or after converting and rounding seconds to minutes. This matters because grouping by exact seconds can assign trips differently than grouping by rounded whole-minute values.

The phrase “between 0 and 60 minutes” is also ambiguous because it can be applied to raw duration before rounding, or to rounded duration after converting to minutes. Finally, “six equal quantile groups” can mean six nearly equal row-count groups using `NTILE`, or percentile-based duration ranges where trips with the same duration remain in the same range.

### Relevant schema
Use `CHICAGO.CHICAGO_TAXI_TRIPS.TAXI_TRIPS`. The key columns are `trip_seconds` for trip duration and `fare` for fare amount.



#### Interpretation 1
Use raw seconds for filtering and `NTILE` grouping; round minutes only in the final output.

#### SQL Query 1
```sql
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
```



#### Interpretation 2
Round trip duration to whole minutes first, then filter and create `NTILE` groups using the rounded minute value.

#### SQL Query 2
```sql
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
```



#### Interpretation 3
Use raw seconds for the 0-to-60-minute filter, but form six percentile-based duration ranges instead of six `NTILE` row-count groups.

#### SQL Query 3
```sql
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
```



### Differences
Query 1 creates the six groups from exact trip duration in seconds. It first filters trips to `0` through `3600` seconds, then uses `NTILE(6)` to split the filtered trips into six nearly equal row-count groups. The minute values are rounded only after each group has already been formed, so rounding affects the displayed min/max duration but not which group a trip belongs to.

Query 2 changes when rounding happens. It first converts `trip_seconds` into rounded whole minutes, then applies the `0` to `60` filter and creates the six `NTILE` groups using that rounded value. Because filtering and grouping happen after rounding, trips near the 60-minute boundary may be included differently, and trips with similar raw durations can move into different groups compared with Query 1.

Query 3 keeps the same raw-second filter as Query 1, but changes the meaning of “quantile group.” Instead of using `NTILE(6)` to force six nearly equal row-count groups, it calculates percentile cutoffs and assigns trips into duration ranges. This keeps the grouping tied to duration thresholds, but the number of trips per group may be less even, and the average fare can change because the group membership is different.

### Execution Results

#### Query 1 Result
_No result table is included because this query exceeded the available Snowflake statement/warehouse time limit during execution, not because of a SQL syntax error: Statement reached its statement or warehouse timeout of 120 second(s) and was canceled._

#### Query 2 Result
_No result table is included because this query exceeded the available Snowflake statement/warehouse time limit during execution, not because of a SQL syntax error: Statement reached its statement or warehouse timeout of 120 second(s) and was canceled._

#### Query 3 Result
Full CSV: [`results_csv/sf_bq022/query_3.csv`](results_csv/sf_bq022/query_3.csv)

| DURATION_QUANTILE | MIN_DURATION_MINUTES | MAX_DURATION_MINUTES | TOTAL_TRIPS | AVERAGE_FARE |
| --- | --- | --- | --- | --- |
| 1 | 0 | 4 | 37372811 | 7.59 |
| 2 | 4 | 7 | 41157078 | 6.52 |
| 3 | 7 | 9 | 25639171 | 7.99 |
| 4 | 9 | 13 | 36589157 | 10.07 |
| 5 | 13 | 21 | 32747651 | 15.46 |
| 6 | 21 | 60 | 34427543 | 33.32 |


## sf_local244


### Question
Calculate the duration of each track, classify them as short, medium, or long, output the minimum and maximum time for each kind (in minutes) and the total revenue for each category, group by the category.

### Why ambiguous
The short/medium/long category definitions come from `music_length_type.md`, where the cutoffs depend on the minimum, average, and maximum track duration. The question does not specify whether those min/avg/max values should be calculated from all tracks in the catalog or only from tracks that were actually sold. This matters because unsold tracks can change the cutoffs and therefore change which tracks fall into each category.

The question also does not specify whether “total revenue” should use the actual invoice-line sale price or the catalog price stored on the track table.

### External knowledge
`music_length_type.md` defines the track length categories using duration cutoffs:

- short: from min duration to `(min + avg) / 2`
- medium: from `(min + avg) / 2` to `(avg + max) / 2`
- long: from `(avg + max) / 2` to max duration

### Relevant schema
The relevant tables are `MUSIC.MUSIC.TRACK` and `MUSIC.MUSIC.INVOICELINE`.

`TRACK` provides track-level fields: `TrackId`, `Milliseconds`, and `UnitPrice`.

`INVOICELINE` provides sales-level fields: `TrackId`, `UnitPrice`, and `Quantity`.



#### Interpretation 1
Use all catalog tracks for duration classification, and use actual invoice-line prices for revenue.

#### SQL Query 1
```sql
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
```



#### Interpretation 2
Use only sold tracks for duration classification, and use actual invoice-line prices for revenue.

#### SQL Query 2
```sql
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
```



#### Interpretation 3
Use all catalog tracks for duration classification, but use catalog track prices for revenue.

#### SQL Query 3
```sql
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
```



### Differences
Query 1 treats the full music catalog as the population used to calculate the short/medium/long duration cutoffs from `music_length_type.md`. It computes the minimum, average, and maximum duration from all tracks in `TRACK`, classifies every track, and reports the min/max duration for each category using all catalog tracks. Revenue is based on actual invoice-line sales, using `INVOICELINE.UnitPrice * INVOICELINE.Quantity`.

Query 2 changes the population used for the `music_length_type.md` cutoffs. It only includes tracks that appear in `INVOICELINE`, so unsold tracks do not affect the min/avg/max duration, the short/medium/long boundaries, or the reported min/max duration. Revenue is still based on actual invoice-line sales. Compared with Query 1, this can change which tracks are classified as short, medium, or long.

Query 3 keeps the same full-catalog duration classification as Query 1, so the `music_length_type.md` cutoffs and category min/max values are based on all tracks in `TRACK`. The difference is the revenue formula: Query 3 uses the catalog price from `TRACK.UnitPrice` multiplied by invoice quantity, while Query 1 uses the actual sale price from `INVOICELINE.UnitPrice`. If those two prices differ, the revenue totals by category will differ.

### Execution Results

#### Query 1 Result
Full CSV: [`results_csv/sf_local244/query_1.csv`](results_csv/sf_local244/query_1.csv)

| LENGTH_CATEGORY | MIN_TIME_MINUTES | MAX_TIME_MINUTES | TOTAL_REVENUE |
| --- | --- | --- | --- |
| long | 47.726183 | 88.115883 | 41.79 |
| medium | 3.289250 | 47.086100 | 1817.55 |
| short | 0.017850 | 3.288800 | 469.26 |

#### Query 2 Result
Full CSV: [`results_csv/sf_local244/query_2.csv`](results_csv/sf_local244/query_2.csv)

| LENGTH_CATEGORY | MIN_TIME_MINUTES | MAX_TIME_MINUTES | TOTAL_REVENUE |
| --- | --- | --- | --- |
| long | 47.832550 | 88.115883 | 41.79 |
| medium | 3.243533 | 47.086100 | 1849.23 |
| short | 0.106217 | 3.242667 | 437.58 |

#### Query 3 Result
Full CSV: [`results_csv/sf_local244/query_3.csv`](results_csv/sf_local244/query_3.csv)

| LENGTH_CATEGORY | MIN_TIME_MINUTES | MAX_TIME_MINUTES | TOTAL_REVENUE |
| --- | --- | --- | --- |
| long | 47.726183 | 88.115883 | 41.79 |
| medium | 3.289250 | 47.086100 | 1817.55 |
| short | 0.017850 | 3.288800 | 469.26 |


## sf_bq007


### Question
Identify the top 10 U.S. states with the highest vulnerable population, calculated based on a weighted sum of employment sectors using 2017 ACS 5-Year data, and determine their average median income change from 2015 to 2018 using zip code data.

### Why ambiguous
“Vulnerable population” is not a stored column; it must be calculated from `total_vulnerable_weights.md` by multiplying 2017 ACS employment counts by sector-specific weights and summing the weighted values by state. The ambiguity is that some weighted sector labels can map to different real columns. For example, “Natural Resources, Construction, and Maintenance” can be mapped to an occupation column or approximated from industry-sector columns. “Services” can also mean an occupation column or an industry-sector column.

The question also does not specify whether “median income change” should be measured as an absolute dollar change or a percentage change from 2015 to 2018.

### External knowledge
`total_vulnerable_weights.md` defines total vulnerable population as a weighted sum of employment sectors:

- Wholesale Trade: `0.38423645320197042`
- Natural Resources, Construction, and Maintenance: `0.48071410777129553`
- Arts, Entertainment, Recreation, Accommodation, and Food: `0.89455676291236841`
- Information: `0.31315240083507306`
- Retail Trade: `0.51`
- Public Administration: `0.039299298394228743`
- Services: `0.36555534476489654`
- Education, Health, and Social Services: `0.20323178400562944`
- Transportation, Warehousing, and Utilities: `0.3680506593618087`
- Manufacturing: `0.40618955512572535`

### Relevant schema
Use `ZIP_CODES_2017_5YR` for 2017 employment counts, `ZIP_CODES_2015_5YR` and `ZIP_CODES_2018_5YR` for `median_income`, and `GEO_US_BOUNDARIES.ZIP_CODES` to map ZIP codes to states using `geo_id = zip_code`.



#### Interpretation 1
Use the occupation-style column mapping and calculate average ZIP-level dollar income change.

#### SQL Query 1
```sql
WITH vulnerable_by_state AS (
    SELECT
        b."state_code",
        b."state_name",
        SUM(z17."employed_wholesale_trade") * 0.38423645320197042 +
        SUM(z17."occupation_natural_resources_construction_maintenance") * 0.48071410777129553 +
        SUM(z17."employed_arts_entertainment_recreation_accommodation_food") * 0.89455676291236841 +
        SUM(z17."employed_information") * 0.31315240083507306 +
        SUM(z17."employed_retail_trade") * 0.51 +
        SUM(z17."employed_public_administration") * 0.039299298394228743 +
        SUM(z17."occupation_services") * 0.36555534476489654 +
        SUM(z17."employed_education_health_social") * 0.20323178400562944 +
        SUM(z17."employed_transportation_warehousing_utilities") * 0.3680506593618087 +
        SUM(z17."employed_manufacturing") * 0.40618955512572535 AS vulnerable_population
    FROM CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2017_5YR z17
    JOIN CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES b
      ON z17."geo_id" = b."zip_code"
    WHERE b."state_fips_code" BETWEEN '01' AND '56'
    GROUP BY b."state_code", b."state_name"
),
top_states AS (
    SELECT *
    FROM vulnerable_by_state
    ORDER BY vulnerable_population DESC
    LIMIT 10
),
income_change AS (
    SELECT
        b."state_code",
        AVG(z18."median_income" - z15."median_income") AS avg_median_income_change
    FROM CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES b
    JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2015_5YR z15
      ON z15."geo_id" = b."zip_code"
    JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2018_5YR z18
      ON z18."geo_id" = b."zip_code"
    WHERE b."state_fips_code" BETWEEN '01' AND '56'
    GROUP BY b."state_code"
)
SELECT
    t."state_name",
    t.vulnerable_population,
    i.avg_median_income_change
FROM top_states t
JOIN income_change i
  ON i."state_code" = t."state_code"
ORDER BY t.vulnerable_population DESC;
```



#### Interpretation 2
Use the same occupation-style vulnerable-population mapping, but calculate average ZIP-level percentage income change.

#### SQL Query 2
```sql
WITH vulnerable_by_state AS (
    SELECT
        b."state_code",
        b."state_name",
        SUM(z17."employed_wholesale_trade") * 0.38423645320197042 +
        SUM(z17."occupation_natural_resources_construction_maintenance") * 0.48071410777129553 +
        SUM(z17."employed_arts_entertainment_recreation_accommodation_food") * 0.89455676291236841 +
        SUM(z17."employed_information") * 0.31315240083507306 +
        SUM(z17."employed_retail_trade") * 0.51 +
        SUM(z17."employed_public_administration") * 0.039299298394228743 +
        SUM(z17."occupation_services") * 0.36555534476489654 +
        SUM(z17."employed_education_health_social") * 0.20323178400562944 +
        SUM(z17."employed_transportation_warehousing_utilities") * 0.3680506593618087 +
        SUM(z17."employed_manufacturing") * 0.40618955512572535 AS vulnerable_population
    FROM CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2017_5YR z17
    JOIN CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES b
      ON z17."geo_id" = b."zip_code"
    WHERE b."state_fips_code" BETWEEN '01' AND '56'
    GROUP BY b."state_code", b."state_name"
),
top_states AS (
    SELECT *
    FROM vulnerable_by_state
    ORDER BY vulnerable_population DESC
    LIMIT 10
),
income_change AS (
    SELECT
        b."state_code",
        AVG((z18."median_income" - z15."median_income") * 100.0 / z15."median_income") AS avg_median_income_pct_change
    FROM CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES b
    JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2015_5YR z15
      ON z15."geo_id" = b."zip_code"
    JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2018_5YR z18
      ON z18."geo_id" = b."zip_code"
    WHERE b."state_fips_code" BETWEEN '01' AND '56'
    GROUP BY b."state_code"
)
SELECT
    t."state_name",
    t.vulnerable_population,
    i.avg_median_income_pct_change
FROM top_states t
JOIN income_change i
  ON i."state_code" = t."state_code"
ORDER BY t.vulnerable_population DESC;
```



#### Interpretation 3
Use the industry-sector column mapping and calculate average ZIP-level dollar income change.

#### SQL Query 3
```sql
WITH vulnerable_by_state AS (
    SELECT
        b."state_code",
        b."state_name",
        SUM(z17."employed_wholesale_trade") * 0.38423645320197042 +
        (
            SUM(z17."employed_agriculture_forestry_fishing_hunting_mining") +
            SUM(z17."employed_construction")
        ) * 0.48071410777129553 +
        SUM(z17."employed_arts_entertainment_recreation_accommodation_food") * 0.89455676291236841 +
        SUM(z17."employed_information") * 0.31315240083507306 +
        SUM(z17."employed_retail_trade") * 0.51 +
        SUM(z17."employed_public_administration") * 0.039299298394228743 +
        SUM(z17."employed_other_services_not_public_admin") * 0.36555534476489654 +
        SUM(z17."employed_education_health_social") * 0.20323178400562944 +
        SUM(z17."employed_transportation_warehousing_utilities") * 0.3680506593618087 +
        SUM(z17."employed_manufacturing") * 0.40618955512572535 AS vulnerable_population
    FROM CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2017_5YR z17
    JOIN CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES b
      ON z17."geo_id" = b."zip_code"
    WHERE b."state_fips_code" BETWEEN '01' AND '56'
    GROUP BY b."state_code", b."state_name"
),
top_states AS (
    SELECT *
    FROM vulnerable_by_state
    ORDER BY vulnerable_population DESC
    LIMIT 10
),
income_change AS (
    SELECT
        b."state_code",
        AVG(z18."median_income" - z15."median_income") AS avg_median_income_change
    FROM CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES b
    JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2015_5YR z15
      ON z15."geo_id" = b."zip_code"
    JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2018_5YR z18
      ON z18."geo_id" = b."zip_code"
    WHERE b."state_fips_code" BETWEEN '01' AND '56'
    GROUP BY b."state_code"
)
SELECT
    t."state_name",
    t.vulnerable_population,
    i.avg_median_income_change
FROM top_states t
JOIN income_change i
  ON i."state_code" = t."state_code"
ORDER BY t.vulnerable_population DESC;
```



### Differences
Query 1 treats “Natural Resources, Construction, and Maintenance” and “Services” as occupation-based categories. It maps them to `occupation_natural_resources_construction_maintenance` and `occupation_services`, then calculates vulnerable population using the weighted-sum formula from `total_vulnerable_weights.md`. The income change is the average ZIP-code dollar difference between 2018 and 2015 median income.

Query 2 keeps the vulnerable-population ranking the same as Query 1, using the same occupation-style column mapping and the same weighted-sum formula from `total_vulnerable_weights.md`. The difference is that it reports income change as an average percentage change instead of an average dollar change.

Query 3 treats the weighted categories as industry sectors instead of occupation categories. It uses agriculture/mining plus construction for the natural resources/construction category, and `employed_other_services_not_public_admin` for services. Because this changes the employment columns used in the weighted sum, the vulnerable-population totals and the top 10 state ranking can change.

### Execution Results

#### Query 1 Result
Full CSV: [`results_csv/sf_bq007/query_1.csv`](results_csv/sf_bq007/query_1.csv)

| state_name | VULNERABLE_POPULATION | AVG_MEDIAN_INCOME_CHANGE |
| --- | --- | --- |
| California | 6875058.77255139 | 9077.418488445 |
| Texas | 4752596.16420815 | 5327.083763626 |
| Florida | 3578412.40390639 | 5752.321543408 |
| New York | 3489063.40778643 | 6418.964814815 |
| Illinois | 2305619.91568066 | 5366.212734082 |
| Pennsylvania | 2289607.51563287 | 5292.067360686 |
| Ohio | 2128558.53267136 | 5449.008050089 |
| Michigan | 1798093.66029114 | 5717.455602537 |
| North Carolina | 1762677.72119045 | 5335.980106101 |
| Georgia | 1701288.72964206 | 5060.998538012 |

#### Query 2 Result
Full CSV: [`results_csv/sf_bq007/query_2.csv`](results_csv/sf_bq007/query_2.csv)

| state_name | VULNERABLE_POPULATION | AVG_MEDIAN_INCOME_PCT_CHANGE |
| --- | --- | --- |
| California | 6875058.77255139 | 15.650930273 |
| Texas | 4752596.16420815 | 11.89671628 |
| Florida | 3578412.40390639 | 12.187282788 |
| New York | 3489063.40778643 | 11.10014671 |
| Illinois | 2305619.91568066 | 10.435989088 |
| Pennsylvania | 2289607.51563287 | 11.088694195 |
| Ohio | 2128558.53267136 | 11.69617794 |
| Michigan | 1798093.66029114 | 12.098627999 |
| North Carolina | 1762677.72119045 | 13.00928855 |
| Georgia | 1701288.72964206 | 14.06381757 |

#### Query 3 Result
Full CSV: [`results_csv/sf_bq007/query_3.csv`](results_csv/sf_bq007/query_3.csv)

| state_name | VULNERABLE_POPULATION | AVG_MEDIAN_INCOME_CHANGE |
| --- | --- | --- |
| California | 5936498.34048096 | 9077.418488445 |
| Texas | 4221752.10200567 | 5327.083763626 |
| Florida | 3038904.91127392 | 5752.321543408 |
| New York | 2917601.0087565 | 6418.964814815 |
| Illinois | 1994720.89885404 | 5366.212734082 |
| Pennsylvania | 1974700.12492188 | 5292.067360686 |
| Ohio | 1834530.91591807 | 5449.008050089 |
| Michigan | 1546629.33070483 | 5717.455602537 |
| North Carolina | 1525452.90809395 | 5335.980106101 |
| Georgia | 1476652.18946035 | 5060.998538012 |


## sf_bq272


### Question
Please provide the names of the top three most profitable products for each month from January 2019 through August 2022, excluding any products associated with orders that were canceled or returned. For each product in each month, the profit should be calculated as the sum of the sale prices of all order items minus the sum of the costs of those sold items in that month.

### Why ambiguous
The main ambiguity is what counts as the identity of a “product.” The prompt asks for product names, but the schema has both `PRODUCTS.id` and `PRODUCTS.name`. If products are grouped only by name, two different product records with the same name are combined before profit is calculated and ranked. If products are grouped by product ID, those records remain separate even if they share the same name.

The output format is also open to interpretation. The month can be shown as a `YYYY-MM` string or as a month-start date, and the result can either include or omit the rank and product ID.

### Relevant schema
The relevant tables are `THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS` and `THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS`.

`ORDER_ITEMS` provides item-level sales fields: `product_id`, `created_at`, `status`, and `sale_price`.

`PRODUCTS` provides product fields: `id`, `name`, and `cost`.



#### Interpretation 1
Group products by product name, output month, product name, and profit.

#### SQL Query 1
```sql
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
```



#### Interpretation 2
Group products by product name, but include the monthly rank and show month as a month-start date.

#### SQL Query 2
```sql
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
```



#### Interpretation 3
Group products by product ID and product name, and include product ID and rank in the output.

#### SQL Query 3
```sql
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
```



#### Interpretation 4
Group and rank products by product ID, but output only month, product name, and profit.

#### SQL Query 4
```sql
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
```



### Differences
Query 1 treats product name as the product identity. It groups all order items with the same `PRODUCTS.name` together within each month, calculates profit as total sale price minus total product cost, ranks product names within each month, and returns the top three names. If two product IDs share the same name, they are combined into one monthly profit total.

Query 2 uses the same product-name grouping and profit calculation as Query 1, so the business logic is the same. The difference is presentation: it outputs the month as a month-start date instead of a `YYYY-MM` string and includes the product’s rank within that month.

Query 3 treats product ID as the product identity. It groups by `PRODUCTS.id` as well as product name, so two products with the same name remain separate if they have different IDs. It also outputs `product_id` and rank, making it clear exactly which product record was ranked.

Query 4 also calculates and ranks profit at the product-ID level, like Query 3, so same-name products remain separate during the ranking step. The difference is that it hides `product_id` and rank in the final output. This follows the prompt’s request for product names, but it can show repeated product names in the same month if different product IDs share that name.

### Execution Results

#### Query 1 Result
Full CSV: [`results_csv/sf_bq272/query_1.csv`](results_csv/sf_bq272/query_1.csv)

| MONTH | PRODUCT_NAME | PROFIT |
| --- | --- | --- |
| 2019-01 | Robert Rodriguez Women's Tux Boyfriend Blazer | 114.558749541 |
| 2019-01 | Sutton Studio Women's Single Button Blazer Jacket | 51.673538448 |
| 2019-01 | L*Space Sahara's Dream Tab Side Hipster Bottom | 40.124999732 |
| 2019-02 | Alpha Industries A-2 Leather Jacket | 237.99999943 |
| 2019-02 | True Religion Men's TRBJ Flatlock Raw Edge Hoodie | 120.851954608 |
| 2019-02 | Bailey 44 Women's Venom Dress | 103.5 |
| 2019-03 | The North Face Apex Bionic Mens Soft Shell Ski Jacket 2013 | 483.104998453 |
| 2019-03 | Parker Women's Strapless Studded Dress | 229.68000003 |
| 2019-03 | Magaschoni Women's 100% Cashmere Peplum Back Sweater | 195.047999583 |
| 2019-04 | BCBGMAXAZRIA Women's Gisela Criss Cross Foil Print Dress | 196.880000398 |
| ... |  |  |

_Showing first 10 of 126 rows. See the CSV file for the full result._

#### Query 2 Result
Full CSV: [`results_csv/sf_bq272/query_2.csv`](results_csv/sf_bq272/query_2.csv)

| MONTH | PRODUCT_NAME | PROFIT | RANK |
| --- | --- | --- | --- |
| 2019-01-01 00:00:00.000 | Robert Rodriguez Women's Tux Boyfriend Blazer | 114.558749541 | 1 |
| 2019-01-01 00:00:00.000 | Sutton Studio Women's Single Button Blazer Jacket | 51.673538448 | 2 |
| 2019-01-01 00:00:00.000 | L*Space Sahara's Dream Tab Side Hipster Bottom | 40.124999732 | 3 |
| 2019-02-01 00:00:00.000 | Alpha Industries A-2 Leather Jacket | 237.99999943 | 1 |
| 2019-02-01 00:00:00.000 | True Religion Men's TRBJ Flatlock Raw Edge Hoodie | 120.851954608 | 2 |
| 2019-02-01 00:00:00.000 | Bailey 44 Women's Venom Dress | 103.5 | 3 |
| 2019-03-01 00:00:00.000 | The North Face Apex Bionic Mens Soft Shell Ski Jacket 2013 | 483.104998453 | 1 |
| 2019-03-01 00:00:00.000 | Parker Women's Strapless Studded Dress | 229.68000003 | 2 |
| 2019-03-01 00:00:00.000 | Magaschoni Women's 100% Cashmere Peplum Back Sweater | 195.047999583 | 3 |
| 2019-04-01 00:00:00.000 | BCBGMAXAZRIA Women's Gisela Criss Cross Foil Print Dress | 196.880000398 | 1 |
| ... |  |  |  |

_Showing first 10 of 138 rows. See the CSV file for the full result._

#### Query 3 Result
Full CSV: [`results_csv/sf_bq272/query_3.csv`](results_csv/sf_bq272/query_3.csv)

| YEAR_MONTH | PRODUCT_ID | PRODUCT_NAME | TOTAL_PROFIT | RANK |
| --- | --- | --- | --- | --- |
| 2019-01 | 7487 | Robert Rodriguez Women's Tux Boyfriend Blazer | 114.558749541 | 1 |
| 2019-01 | 7986 | Sutton Studio Women's Single Button Blazer Jacket | 51.673538448 | 2 |
| 2019-01 | 13151 | L*Space Sahara's Dream Tab Side Hipster Bottom | 40.124999732 | 3 |
| 2019-02 | 23908 | Alpha Industries A-2 Leather Jacket | 237.99999943 | 1 |
| 2019-02 | 17106 | True Religion Men's TRBJ Flatlock Raw Edge Hoodie | 120.851954608 | 2 |
| 2019-02 | 3253 | Bailey 44 Women's Venom Dress | 103.5 | 3 |
| 2019-03 | 24428 | The North Face Apex Bionic Mens Soft Shell Ski Jacket 2013 | 483.104998453 | 1 |
| 2019-03 | 3383 | Parker Women's Strapless Studded Dress | 229.68000003 | 2 |
| 2019-03 | 899 | Magaschoni Women's 100% Cashmere Peplum Back Sweater | 195.047999583 | 3 |
| 2019-04 | 3454 | BCBGMAXAZRIA Women's Gisela Criss Cross Foil Print Dress | 196.880000398 | 1 |
| ... |  |  |  |  |

_Showing first 10 of 132 rows. See the CSV file for the full result._

#### Query 4 Result
Full CSV: [`results_csv/sf_bq272/query_4.csv`](results_csv/sf_bq272/query_4.csv)

| MONTH | PRODUCT_NAME | PROFIT |
| --- | --- | --- |
| 2019-01-01 00:00:00.000 | Robert Rodriguez Women's Tux Boyfriend Blazer | 114.558749541 |
| 2019-01-01 00:00:00.000 | Sutton Studio Women's Single Button Blazer Jacket | 51.673538448 |
| 2019-01-01 00:00:00.000 | L*Space Sahara's Dream Tab Side Hipster Bottom | 40.124999732 |
| 2019-02-01 00:00:00.000 | Alpha Industries A-2 Leather Jacket | 237.99999943 |
| 2019-02-01 00:00:00.000 | True Religion Men's TRBJ Flatlock Raw Edge Hoodie | 120.851954608 |
| 2019-02-01 00:00:00.000 | Bailey 44 Women's Venom Dress | 103.5 |
| 2019-03-01 00:00:00.000 | The North Face Apex Bionic Mens Soft Shell Ski Jacket 2013 | 483.104998453 |
| 2019-03-01 00:00:00.000 | Parker Women's Strapless Studded Dress | 229.68000003 |
| 2019-03-01 00:00:00.000 | Magaschoni Women's 100% Cashmere Peplum Back Sweater | 195.047999583 |
| 2019-04-01 00:00:00.000 | BCBGMAXAZRIA Women's Gisela Criss Cross Foil Print Dress | 196.880000398 |
| ... |  |  |

_Showing first 10 of 132 rows. See the CSV file for the full result._
