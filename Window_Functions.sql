--QUERY #1: What have been our top 5 most common sources of severe weather information?
SELECT source,
COUNT(event_id) AS num_of_events
FROM severe_weather
GROUP BY source
ORDER BY num_of_events DESC;

--QUERY #2: What were the property damage totals by state and event type?
SELECT state,
event_type,
SUM(damage_property)
FROM severe_weather
GROUP BY state,event_type
ORDER BY state,event_type;

--QUERY #3: How many days did the longest weather event last?
SELECT event_id,
TIMESTAMPDIFF(DAY,event_begin_time,event_end_time) AS duration_days
FROM severe_weather
ORDER BY duration_days DESC;

--QUERY #4: List all weather events and sequence those events by county and storm.
SELECT cz_name,
state,
event_id,
event_type,
episode_id,
DENSE_RANK()OVER(
PARTITION BY cz_name
ORDER BY event_begin_time)AS episode_sequence
FROM severe_weather
WHERE cz_type='C'
ORDER BY cz_name,episode_id;

--QUERY #5: For each month, summarize property damage and cumulative damage.
SELECT 
EXTRACT( month FROM event_begin_time) AS event_month,
SUM(damage_property)AS damage_total,
SUM(damage_total)OVER (
ORDER BY event_month
ROWS UNBOUNDED PRECEDING) AS cumulative_damage
FROM severe_weather
GROUP BY event_month;

--QUERY #6: Prepare a CASE statement
SELECT source,
   COUNT(event_id) AS event_count,
       CASE
        WHEN event_count > 2000 THEN 'major source'
        ELSE 'minor source'
        END AS source_category
FROM severe_weather
GROUP BY source
ORDER BY event_count DESC;

/* Create a table to store state sizes. */
CREATE TABLE state_sizes
(
state_fips_code INTEGER,
state_name STRING,
area_land_meters INTEGER,
area_water_meters INTEGER
);
/* List the files in the staging area (S3). */
LIST @severe_weather;
/* Load the state sizing data. */
COPY INTO state_sizes
FROM @severe_weather/state_sizing.csv
file_format = csv_format;
/* Preview data in the state sizing table. */
SELECT * FROM state_sizes LIMIT 5;

--QUERY #7: Prepare common table expressions (CTEs)
WITH state_area_km AS (
SELECT state_name,
state_fips_code,
ROUND(area_land_meters/1000000,2) AS area_land_sq_km
FROM state_sizes
),
storm_count_by_state AS (
SELECT state_fips_code,
COUNT(event_id)AS number_of_storms
FROM severe_weather
GROUP BY state_fips_code
),
storms_per_sq_land_km AS(
SELECT 
state_area_km.state_name,
storm_count_by_state.number_of_storms,
state_area_km.area_land_sq_km,
ROUND(storm_count_by_state.number_of_storms/state_area_km.area_land_sq_km,2) AS storms_per_sq_land_km
FROM state_area_km
INNER JOIN storm_count_by_state
ON state_area_km.state_fips_code = storm_count_by_state.state_fips_code
)
SELECT*
FROM storms_per_sq_land_km
ORDER BY storms_per_sq_land_km DESC;
