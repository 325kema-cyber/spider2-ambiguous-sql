-- Question ID: sf_bq007
-- This file contains all SQL interpretations for this question.

-- ============================================================================
-- SQL Query 1
-- Interpretation 1:
-- ============================================================================
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

-- ============================================================================
-- SQL Query 2
-- Interpretation 2:
-- ============================================================================
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

-- ============================================================================
-- SQL Query 3
-- Interpretation 3:
-- ============================================================================
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
