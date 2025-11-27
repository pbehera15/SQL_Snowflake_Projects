/*Query #1: Identify zip codes with high % of people with advance degree*/
SELECT zip_code,
(education_masters_degree/population_total) AS percentage_masters,
  CASE 
      WHEN percentage_masters >= 0.05 THEN 'high'
      ELSE 'low'
      END AS education_category
FROM census_by_zip_code
WHERE reporting_year = 2018
AND population_total> 0
AND percentage_masters>=0.60
ORDER BY percentage_masters DESC;

/*Query #2: List the zip codes in the following counties and their # of households in 2018 -- Clark County (NV), â€œLos Angeles County(CA), and Maricopa County (AZ)*/
SELECT zip_code,households
FROM census_by_zip_code
WHERE reporting_year = 2018
AND zip_code IN (SELECT zip_code
FROM zip_codes
WHERE county IN ('Clark County','Los Angeles County','Maricopa County'))
ORDER BY households DESC;

/*Query #3: Identify the top 10 zip codes with the most total population growth*/
WITH census_2013 AS(
-- list 2013 total population by zip code
SELECT zip_code,population_total AS population_2013
FROM census_by_zip_code
WHERE reporting_year = 2013
AND population_total >= 5000
),
census_2018 AS(
-- list 2018 total population by zip code
SELECT zip_code,population_total AS population_2018
FROM census_by_zip_code
WHERE reporting_year = 2018
),
--calculate growth between 2013 and 2018 
population_growth AS ( 
SELECT census_2018.zip_code,
population_2013,
population_2018,
census_2018.population_2018-census_2013.population_2013 AS num_additional_residents,
ROUND((num_additional_residents/census_2013.population_2013)*100,2) AS percentage_change_in_residents
FROM census_2018
INNER JOIN census_2013
ON census_2018.zip_code = census_2013.zip_code
WHERE percentage_change_in_residents IS NOT NULL
ORDER BY percentage_change_in_residents DESC
)
SELECT * FROM population_growth
ORDER BY percentage_change_in_residents DESC
LIMIT 10;