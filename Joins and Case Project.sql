/* Analysis of U.S.Census Bureau datasets evaluating demographic,population and growth trends to identify high potential markets for business expansion*/
/* Query1.Calculate the total population by reporting year.*/ 
SELECT reporting_year,
       SUM(population_total) AS total_population
FROM census_by_zip_code
GROUP BY reporting_year
ORDER BY reporting_year;

/*Query2.list counties with most zip codes*/
SELECT 
state_name,
county,
COUNT(zip_code)
FROM zip_codes
WHERE county IS NOT NULL
GROUP BY state_name,
          county
ORDER BY COUNT(zip_code) DESC;

/* Query3.List all zip codes, and in a new column, categorize those zip codes based on their median
age in 2018*/
SELECT zip_code,median_age,
    CASE 
        WHEN population_total < 150 THEN 'unable to calculate'
        WHEN median_age<=35 THEN 'young adults'
        WHEN median_age>35 and median_age<=55 THEN'middle-aged adults'
        WHEN median_age>55 THEN 'older adults'
        END AS age_category,
FROM census_by_zip_code
WHERE reporting_year = 2018
ORDER BY zip_code;

/*Query4.Count the number of zip codes in each of the previously-defined age categories*/
SELECT 
      CASE 
          WHEN population_total < 150 THEN 'unable to calculate'
          WHEN median_age<=35 THEN 'young adults'
          WHEN median_age>35 and median_age<=55 THEN'middle-aged adults'
          WHEN median_age>55 THEN 'older adults'
          END AS age_category,
          COUNT(zip_code)
FROM census_by_zip_code
WHERE reporting_year = 2018
GROUP BY age_category;

/*Query5.List all zip codes along with a column that classifies their gender distribution in 2018.*/
SELECT zip_code,
ROUND((population_female*1.0/population_total)*100,2) AS gender_distribution_percent,
 CASE 
   WHEN (population_female/population_total)> 0.60 THEN 'predominantly female'
   WHEN (population_female/population_total)< 0.40 THEN 'predominantly male'
   ELSE 'evenly distributed' END AS gender_distribution_classification
FROM census_by_zip_code
WHERE  population_total>=1000
   AND reporting_year = 2018
ORDER BY zip_code;

/*Query6.Sum the children in grades 1-8 by state and county in 2018.*/
SELECT 
zip_codes.state_name,
zip_codes.county,
SUM(census_by_zip_code.children_in_grades_1_TO_4 + census_by_zip_code.CHILDREN_IN_GRADES_5_TO_8) AS total_children_in_grades_1_8
FROM census_by_zip_code
LEFT JOIN zip_codes
ON census_by_zip_code.zip_code = zip_codes.zip_code
WHERE reporting_year = 2018
GROUP BY state_name,
         county
HAVING total_children_in_grades_1_8 >= 100000 
ORDER BY state_name,

         county;
