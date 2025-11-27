--QUERY #1: Count the number of storm events and sum the amount of crop damage by reference location.
SELECT
COUNT(event_id)AS no_of_events,
SUM(damage_crops) AS total_damage,
CONCAT(state_fips_code,'-',cz_fips_code,'-',reference_location)
FROM severe_weather
WHERE cz_type = 'C'
GROUP BY CONCAT(state_fips_code,'-',cz_fips_code,'-',reference_location)
ORDER BY total_damage DESC,
         no_of_events DESC
LIMIT 100;

--QUERY #2: Calculate the duration of events in minutes.
SELECT 
event_id,
event_type,
event_begin_time,
event_end_time,
DATEDIFF(MINUTE,event_begin_time,event_end_time) AS duration_in_mins
FROM severe_weather
ORDER BY duration_in_mins DESC;

--QUERY #3:How many events were under an hour?
SELECT category.duration_category,
COUNT(*) AS event_count
FROM (
  SELECT event_id,
         event_type,
         event_begin_time,
         event_end_time,
         DATEDIFF(MINUTE,event_begin_time,event_end_time) AS duration_in_mins,
         CASE 
           WHEN duration_in_mins < 60 THEN 'under an hour'
           WHEN duration_in_mins >= 60 THEN 'at least an hour'
           END AS duration_category
           FROM severe_weather) AS category
    GROUP BY category.duration_category
    ORDER BY category.duration_category;

--QUERY #4: Count the number of storm events by Weather Forecast Office (WFO) and month
SELECT
WFO,
EXTRACT(month FROM event_begin_time)AS storm_month,
COUNT(event_id)AS no_of_events,
FROM severe_weather
GROUP BY WFO,storm_month
ORDER BY WFO,storm_month;

--QUERY #5: For the Bismarck office (BIS), how many total storm events were there during the year?
SELECT
WFO,
EXTRACT(month FROM event_begin_time)AS storm_month,
COUNT(*)AS no_of_events_month,
SUM(no_of_events_month)OVER(
PARTITION BY WFO,EXTRACT(YEAR FROM event_begin_time)) AS yearly_event_count
FROM severe_weather
GROUP BY WFO,
         EXTRACT(YEAR FROM event_begin_time),
         EXTRACT(month FROM event_begin_time)
ORDER BY WFO,storm_month;

--QUERY #6: Delete the "severe_weather" table
DROP TABLE severe_weather;

--QUERY #7: Restore the "severe_weather" table.(Then, confirm it was restored).
UNDROP TABLE severe_weather;
SELECT*
FROM severe_weather;

--QUERY #8: Change all event types in the "severe_weather" table to "spilled milk".
UPDATE severe_weather
SET event_type = 'spilled milk';

--QUERY #9:  Roll back the "severe_weather" table to before the previous change.  
CREATE OR REPLACE TABLE severe_weather AS 
(SELECT *
FROM severe_weather BEFORE
(statement =>'01c037cb-0003-d271-0009-d0f60012805a'));

--(Then, confirm it was fixed.)
SELECT*
FROM severe_weather
LIMIT 5;

--QUERY #10: Copy the "state_sizes" table for development.
CREATE TABLE state_sizes_dev CLONE state_sizes;

--QUERY #11: Look up recent query history.
SELECT *
FROM table(information_schema.query_history())
ORDER BY start_time DESC;